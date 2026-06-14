# SoloAI 主動尋家 + 承諾慣性 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 擴充 `_evaluate_solo`：無家流浪團不缺糧時，依個性主動尋家（紮營/投靠），與 roving 競爭；加承諾慣性（solo_intent）止 flip-flop。reuse desperation 已建 helpers，零新機制。

**Architecture:** 在 `_evaluate_solo` scores dict 加 `紮營`(TASK_CAMP)/`投靠`，gated 無 own outpost、**純 value 加權不乘 `_tag_weight`**（該函數對流亡 tag 回 0，會歸零最需尋家的流亡團）。新增 `solo_intent` 欄位 + 重評時對上次方向加 `SOLO_COMMITMENT_BONUS`。紮營到達結算**已存在**（`_evaluate_survival` 頂部 TASK_CAMP 檢查，每隊每 cadence 跑，不受食物 gate）→ 無需新接線。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-soloai-proactive-home-design.md`。

---

## 檔案結構

- `scripts/data/team_data.gd`（改）：`var solo_intent: String = ""`。
- `scripts/simulation/faction_ai_system.gd`（改）：`_evaluate_solo` 加尋家評分 + match 分支 + 承諾慣性；`SOLO_COMMITMENT_BONUS` const。
- `scripts/debug/headless_test.gd`（改）：測試。

可用既有 helpers（已 merge，勿重寫）：`_find_own_outpost` / `_find_unowned_farmable_tile` / `_find_strong_neighbor` / `establish_crude_camp`（到達結算已接於 `_evaluate_survival` 頂）。

---

## Task 1: solo_intent 欄位 + 承諾慣性

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/simulation/faction_ai_system.gd`（`_evaluate_solo` 加慣性 + 記 intent）
- Test: `scripts/debug/headless_test.gd`（新 `_test_solo_commitment`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_solo_commitment() -> void:
	print("--- SoloAI 承諾慣性 ---")
	var fai := FactionAISystem.new()
	# 中性個性，攻擊/掠奪/外交 分數接近 → 無慣性會抖；有慣性則黏上次
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.values = {"好戰": 0.5, "貪婪": 0.5, "野心": 0.5}
	state.persons[0] = leader
	# 兩個獨立鄰隊供 攻擊/掠奪/外交 target
	for tid in [1, 2]:
		var o := TeamData.new(); o.team_id = tid; o.tile_pos = Vector2i(4+tid, 4)
		o.population = 3; o.faction_id = -1
		state.teams[tid] = o
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4,4)
	team.population = 8; team.tags = ["軍隊"]; team.current_task = "idle"
	team.solo_intent = "掠奪"   # 上次選掠奪
	team.resources = {"food": 100.0}
	state.teams[0] = team
	fai._evaluate_solo(state, team)
	assert(team.current_task == "掠奪", "有 solo_intent=掠奪 + 慣性 → 應續掠奪，實際=%s" % team.current_task)
	assert(team.solo_intent == "掠奪", "選後 solo_intent 記錄")
	print("solo commitment OK")
```

- [ ] **Step 2: 跑確認失敗** — `solo_intent` 欄位未定義 / 無慣性邏輯。

- [ ] **Step 3: 實作**

`team_data.gd`（`forage_today` 附近）：
```gdscript
var solo_intent: String = ""   # 上次 SoloAI 選的策略方向（承諾慣性用）
```

`faction_ai_system.gd` const 區：
```gdscript
const SOLO_COMMITMENT_BONUS: float = 0.15   # TEST VALUE — SoloAI 慣性加成（止 flip-flop，非鎖死）
```

`_evaluate_solo`，**算完 scores、選 best_task 之前**加：
```gdscript
	# 承諾慣性：上次方向加分（非明顯更優不換）
	if team.solo_intent != "" and scores.has(team.solo_intent):
		scores[team.solo_intent] = float(scores[team.solo_intent]) + SOLO_COMMITMENT_BONUS
```

`best_task != "idle"` 且 try_set 成功後，記 intent（在現有 `print("[SoloAI]...")` 前）：
```gdscript
	team.solo_intent = best_task
```

- [ ] **Step 4: 跑確認通過** — `solo commitment OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: SoloAI 承諾慣性（solo_intent + commitment bonus）"
```

---

## Task 2: 紮營/投靠 尋家評分（無家團，bypass _tag_weight）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_evaluate_solo` scores + match）
- Test: `scripts/debug/headless_test.gd`（新 `_test_solo_seek_home`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_solo_seek_home() -> void:
	print("--- SoloAI 主動尋家 ---")
	var fai := FactionAISystem.new()
	# 共用世界：本格 + 鄰格無主可農地（供紮營）
	var state := WorldState.new(); state.world = WorldData.new()
	for p in [Vector2i(4,4), Vector2i(5,4)]:
		var tile := HexTileData.new()
		tile.tile_id = p.x*1000+p.y; tile.tile_pos = p; tile.terrain = "plains"
		tile.outpost_owner = -1; tile.outpost_level = 0; tile.resource_cap = {"food": 50.0}
		state.world.tiles[tile.tile_id] = tile
	# 求生型流亡團（不兇）→ 應主動紮營（流亡 tag 不該歸零尋家）
	var refugee := PersonData.new(); refugee.id = 0; refugee.team_id = 0
	refugee.values = {"好戰": 0.2, "貪婪": 0.2, "野心": 0.4, "求生欲": 0.9, "慎重": 0.7}
	state.persons[0] = refugee
	var t0 := TeamData.new(); t0.team_id = 0; t0.leader_id = 0; t0.tile_pos = Vector2i(4,4)
	t0.population = 4; t0.tags = ["流亡"]; t0.current_task = "idle"; t0.resources = {"food": 100.0}
	state.teams[0] = t0
	fai._evaluate_solo(state, t0)
	assert(t0.current_task == TeamData.TASK_CAMP or t0.current_task == "投靠",
		"求生型流亡團應主動尋家，實際=%s" % t0.current_task)
	# 好戰盜匪（有獵物）→ 掠奪壓過尋家（不找家）
	var prey := TeamData.new(); prey.team_id = 9; prey.tile_pos = Vector2i(3,4)
	prey.population = 2; prey.faction_id = -1; prey.resources = {"food": 30.0}
	state.teams[9] = prey
	var raider := PersonData.new(); raider.id = 1000; raider.team_id = 1
	raider.values = {"好戰": 0.9, "貪婪": 0.9, "野心": 0.5, "求生欲": 0.5}
	state.persons[1000] = raider
	var t1 := TeamData.new(); t1.team_id = 1; t1.leader_id = 1000; t1.tile_pos = Vector2i(4,4)
	t1.population = 10; t1.tags = ["軍隊"]; t1.current_task = "idle"; t1.resources = {"food": 100.0}
	state.teams[1] = t1
	fai._evaluate_solo(state, t1)
	assert(t1.current_task == "掠奪" or t1.current_task == "攻擊",
		"好戰盜匪應 roving 非尋家，實際=%s" % t1.current_task)
	print("solo seek home OK")
```

- [ ] **Step 2: 跑確認失敗** — 尋家選項未加；流亡團 _tag_weight=0 → 全 idle。

- [ ] **Step 3: 實作**

`_evaluate_solo`，在 roving scores（攻擊/掠奪/外交…）之後、承諾慣性之前，加尋家評分（**純 value，不乘 _tag_weight**）：

```gdscript
	# 主動尋家（僅無 own outpost 的流浪團）：純 value 加權，與 roving 競爭。
	# 不乘 _tag_weight（該函數對「流亡」tag 回 0，會歸零最需尋家的流亡團）。
	if _find_own_outpost(state, team) == Vector2i(-1, -1):
		if _find_unowned_farmable_tile(state, team) != Vector2i(-1, -1):
			scores[TeamData.TASK_CAMP] = survival * 0.3 \
				+ float(leader_p.values.get("慎重", 0.5)) * 0.3 + ambition * 0.3
		if _find_strong_neighbor(state, team) != -1:
			scores["投靠"] = float(leader_p.values.get("義氣", 0.5)) * 0.4 + survival * 0.4
```
（`survival` / `ambition` 為 `_evaluate_solo` 既有區域變數。`慎重` 取自 leader_p。）

best_task match 區加分支：
```gdscript
		TeamData.TASK_CAMP:
			var cpos: Vector2i = _find_unowned_farmable_tile(state, team)
			if cpos == Vector2i(-1, -1): return
			solo_target = cpos
		"投靠":
			var ally: int = _find_strong_neighbor(state, team)
			if ally == -1: return
			solo_target = state.teams[ally].tile_pos
			team.combat_target = ally
```

注意：紮營到達結算已存在於 `_evaluate_survival` 頂（每隊每 cadence 跑、不受食物 gate）→ SoloAI 設的 TASK_CAMP 到達會自動 `establish_crude_camp`。投靠到達走既有投靠邏輯。`TASK_CAMP`/`投靠` 已在 `SURVIVAL_TASKS`（釋放一致）。

- [ ] **Step 4: 跑確認通過** — `solo seek home OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: SoloAI 主動尋家（紮營/投靠 value 加權，bypass _tag_weight）"
```

---

## Task 3: 註冊 + 重量測

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize`）

- [ ] **Step 1: 註冊** `_test_solo_commitment` / `_test_solo_seek_home`。

- [ ] **Step 2: 全測試** — `--import` 後跑，無新增 SCRIPT ERROR、既有測試不回歸。

- [ ] **Step 3: 重量測 2 年 ×3**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_solohome.log
iconv -f UTF-16LE -t UTF-8 godot_solohome.log > godot_solohome_u8.log
grep -a "多配置對比\|CoinAudit\|SCRIPT ERROR" godot_solohome_u8.log
for m in SoloAI CrudeCamp 投靠 SurvivalLoot ProsperityAttack; do printf "%-16s " "$m"; grep -ac "$m" godot_solohome_u8.log; done
```

**驗收：**
- 三 config `died=no`、`coin_eq delta=0.00`、無新增 SCRIPT ERROR
- **主動安身率↑**：[CrudeCamp]/投靠 較 desperation-only（前次量測）增加 → 流浪團不缺糧也找家
- **行為仍多元**：[SoloAI] 出現 攻擊/掠奪/貿易/紮營/投靠 多種（roving 未消失，非全定居）
- **策略連貫**：同隊不每 cadence 換 task kind（solo_intent 慣性生效）— 抽查 [SoloAI] log 同隊連續選擇
- 無誤觸：有 own outpost 的隊不出現尋家 task

- [ ] **Step 4: 判斷 + tune（一次一變因）**

| 觀測 | 動作 |
|---|---|
| 流浪團仍 idle 不找家 | 查尋家評分是否被 _tag_weight 誤乘 / own_outpost gate / helper 回 -1 |
| 全擠定居（roving 消失） | 降紮營/投靠 value 權重，或確認軍隊 tag roving 分仍高 |
| 仍 flip-flop | 升 SOLO_COMMITMENT_BONUS |
| 遍地建村 | 降紮營權重 / 加 pop 或 readiness 門檻 |

- [ ] **Step 5: handback** — `docs/superpowers/handbacks/2026-06-14-soloai-proactive-home.md`，附 SoloAI 行為分佈 + 安身率 vs 前次 + 連貫性觀察。

---

## 注意事項（給實作者）

- **尋家不乘 `_tag_weight`**：該函數對「流亡」回 0，會歸零最需尋家的流亡團。尋家純 value。roving 選項維持乘 _tag_weight（流亡 roving 歸零、尋家保留 → 流亡傾向安身，合理）。
- **camp 到達結算已存在**（`_evaluate_survival` 頂 TASK_CAMP 檢查，每隊跑）→ 勿重複接線。
- **reuse helpers**：`_find_own_outpost`/`_find_unowned_farmable_tile`/`_find_strong_neighbor`/`establish_crude_camp` 已 merge，勿重寫。
- **守恆**：camp 已守恆（認領無主地）；coin_eq delta=0 必驗。
- **勿膨脹**：只擴 `_evaluate_solo` + 一欄位 + 一 const。非戰略引擎。深層目標錨屬待 spec。
- **數值 TEST VALUE**：尋家權重 / `SOLO_COMMITMENT_BONUS` → Step 4 量測 tune，一次一變因。
