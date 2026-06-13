# 經濟死水解鎖 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** A 自給階梯(tools fallback) + B 治理接 faction leader + W3 生育反應分層。解凍世界(W5/W6 後)現在主動餓死 → 讓 team 蓋農田生產自救 + 生育維持人口。

**Spec:** `docs/superpowers/specs/2026-06-13-economy-bootstrap-design.md`

**Context（解凍後現況）:** W5/W6 修完,世界不再凍結但**主動餓死**(tyrant 60→4、warzone 54→7)。建造仍 1/0/1/0(A/B 未修)、生育 P5 偶觸發但遠不足。本 plan 讓建造/生育起來 → 人口止跌。

**Verified facts:**
- `_pick_outpost_type`（faction_ai :1665）：好戰+野心 > 慎重+貪婪 → military；caller `_evaluate_infrastructure` 蓋新 outpost 段 `_pick_outpost_type(leader)`
- `_evaluate_infrastructure`（faction_ai :1670+，僅 faction leader 跑）：(1)升級 (2)擴建設施 (3)蓋新 outpost(`_dispatch_builder`)。`GOVERN_MATERIAL_TARGET`=75 const 已存在（w4）
- `_find_own_outpost`（:1953→現位移）回自家 outpost pos
- `_evaluate_solo`（:893，獨立隊）已有「治理」選項（w4-leader-develop）；faction leader **無**治理（B 要補）
- `_evaluate_person`（reaction_system :104）winner-take-all 含 P5_breed；`_score_breed`（:167）安全+溫飽+cap；`_apply_reaction` P5_breed case（:218）minor cap=int(pop×0.2)
- `evaluate_all`（reaction_system :10-30）per person 跑 `_evaluate_person` + `_apply_reaction`
- `manufacturing_level` = 工坊 level（tile 欄位，產 tools）；`OUTPOST_COST` civilian L1 純 mat 50 / military mat+tools
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`；遙測 TeamTrace 已在（game_sim_test 每日 dump）

---

## Task 1: A — 自給階梯（tools affordability fallback）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_pick_civilian_no_tools() -> void:
	print("--- Bootstrap Task1: 自給階梯 ---")
	# 好戰 leader + tools 0 + 無工坊 → _pick_outpost_type 回 civilian（個性想軍鎮也買不起）
	# ...
	print("Bootstrap Task1a OK")

func _test_pick_military_with_workshop() -> void:
	# faction 有 workshop outpost(manufacturing_level>0) → has_tools → 好戰回 military
	# ...
	print("Bootstrap Task1b OK")

func _test_pick_military_tools_stock() -> void:
	# tools 庫存 >= 3（模擬買來，forward-compat）→ 無工坊也 has_tools → military 可選
	# ...
	print("Bootstrap Task1c OK")
```

- [ ] **Step 2: 改 `_pick_outpost_type` + helper**

```gdscript
func _pick_outpost_type(state: WorldState, leader_team: TeamData, leader: PersonData) -> String:
	# 文明階梯：軍鎮需 tools；無 tools 來源 → 只能蓋民村（個性想軍鎮也買不起）
	var has_tools: bool = float(leader_team.resources.get("tools", 0)) >= 3.0 \
		or _faction_has_workshop(state, leader_team)
	if not has_tools:
		return "civilian"
	var military: float = float(leader.values.get("好戰", 0.5)) + float(leader.values.get("野心", 0.5))
	var civilian: float = float(leader.values.get("慎重", 0.5)) + float(leader.values.get("貪婪", 0.5))
	return "military" if military > civilian else "civilian"

func _faction_has_workshop(state: WorldState, leader_team: TeamData) -> bool:
	for tile_id in state.world.tiles:
		var t: HexTileData = state.world.tiles[tile_id]
		if t.outpost_level > 0 and int(t.manufacturing_level) > 0:
			if t.outpost_owner == leader_team.team_id:
				return true
			var o: TeamData = state.teams.get(t.outpost_owner)
			if o != null and o.faction_id == leader_team.faction_id and leader_team.faction_id != -1:
				return true
	return false
```

caller（`_evaluate_infrastructure` 蓋新 outpost 段）改 `_pick_outpost_type(state, leader_team, leader)`。

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(bootstrap): 自給階梯 — 無 tools fallback civilian (供應鏈 forward-compat) (Task 1)"
```

---

## Task 2: B — 治理接 faction leader

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_govern_faction_leader() -> void:
	print("--- Bootstrap Task2: 治理接 faction leader ---")
	# faction leader 不在自家 outpost + 公庫 material < 75 + idle → 設「治理」task、target=自家 outpost
	# ...
	print("Bootstrap Task2a OK")

func _test_govern_skip_when_vault_full() -> void:
	# 公庫 material >= 75 → 不治理（正常派工路徑）
	# ...
	print("Bootstrap Task2b OK")
```

- [ ] **Step 2: `_evaluate_infrastructure` 蓋新 outpost 段前加治理**

`_dispatch_builder` 呼叫前（蓋新 outpost 段）：

```gdscript
# (3) 蓋新 outpost 前：公庫不足 + leader 不在家 + idle → 回家治理攢公庫
var own_pos: Vector2i = _find_own_outpost(state, leader_team)
if own_pos != Vector2i(-1, -1) and leader_team.tile_pos != own_pos:
	var home_tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
	var vault_mat: float = float(home_tile.public_storage.get("material", 0)) if home_tile else 0.0
	if vault_mat < GOVERN_MATERIAL_TARGET and leader_team.current_task == TeamData.TASK_IDLE:
		if TaskArbiter.try_set(state, leader_team, "治理", own_pos,
				TaskArbiter.PRIO_DISPATCH, "govern_accumulate"):
			return
```

（leader 回家 → idle-on-home 自動採集 + 一般稅積公庫[fief 已實裝] → 公庫達標 → 下次 eval 派工 caravan-load[w4 已實裝]）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(bootstrap): 治理接 faction leader (公庫不足回家攢) (Task 2)"
```

---

## Task 3: W3 — 生育反應分層（行動 / 生命事件）

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_breed_decoupled() -> void:
	print("--- Bootstrap Task3: 生育分層 ---")
	# P5 移出 _evaluate_person（行動反應不含 P5）
	# ...
	print("Bootstrap Task3a OK")

func _test_breed_life_event() -> void:
	# 安全+溫飽+盈餘+未滿 cap → _evaluate_life_events 可回 P5_breed（機率）；不滿足 → 空
	# ...
	print("Bootstrap Task3b OK")

func _test_breed_parallel_with_action() -> void:
	# 同 person 同 tick：行動反應 P1_comply + 生命事件 P5_breed 並行
	# ...
	print("Bootstrap Task3c OK")

func _test_breed_cap() -> void:
	# pop=4 → cap=maxi(1, int(4×0.25))=1（可生 1）；pop=20 → cap=5
	# ...
	print("Bootstrap Task3d OK")
```

- [ ] **Step 2: 實作**

`_evaluate_person`（:105 scores dict）移除 `"P5_breed": _score_breed(...)`。`_apply_reaction` 移除 `"P5_breed"` case（:218-224）。

`evaluate_all`（:26-30 per person）加生命事件層：

```gdscript
var reaction: String = _evaluate_person(person, team)
if reaction != "none":
	_apply_reaction(state, person, team, reaction)
	if skill_sys != null:
		skill_sys.on_reaction(person, reaction)
# 生命事件（獨立，可與行動並行）
for ev in _evaluate_life_events(person, team):
	_apply_life_event(state, person, team, ev)
```

```gdscript
const BREED_BASE_CHANCE: float = 0.15   # TEST VALUE

func _evaluate_life_events(p: PersonData, t: TeamData) -> Array:
	var events: Array = []
	var safe: bool = float(p.needs.get("safety", 1.0)) > 0.7
	var fed: bool = float(p.needs.get("food", 1.0)) > 0.7
	var surplus_ok: bool = float(t.resources.get("food", 0)) \
		> float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 7.0
	var cap: int = maxi(1, int(t.population * 0.25))
	if safe and fed and surplus_ok and t.minor_population < cap:
		var chance: float = BREED_BASE_CHANCE + float(p.skills.get("醫療", 0.0)) * 0.1
		if randf() < chance:
			events.append("P5_breed")
	return events

func _apply_life_event(_state: WorldState, _person: PersonData, team: TeamData, ev: String) -> void:
	match ev:
		"P5_breed":
			team.minor_population += 1
```

（`_score_breed` 可刪或留；minor 長大 = `population_system._mature_minors` 既有月 10%→平民，接上）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(bootstrap): W3 生育反應分層 (行動/生命事件並行 + cap maxi(1,pop×0.25)) (Task 3)"
```

---

## Task 4: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-13-economy-bootstrap.md`

- [ ] **Step 1: 全測試 + multi + 2 年**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "設施完工|FacilityStats|P5_breed|長大|PopSample|CoinAudit" | Select-Object -First 30
```

2 年：config max_ticks 21600→172800（**Edit 工具改，嚴禁 PowerShell -replace 毀中文**），跑完還原。

驗收：
- **新據點/設施建造 > baseline（解凍後 1/0/1/0）** — A+B 解
- 軍閥 config(warzone/tyrant)先蓋民村起步（civilian outpost 出現）→ 工坊產 tools → 後期軍鎮
- **生育 > 0 且人口止跌**（W3 — 解凍後 pop 暴跌 tyrant 60→4，目標：建造+生育後 pop 穩定或回升）
- coin_eq delta 0（守恆不破）；ALL INVARIANTS PASSED
- 若 pop 仍崩 → 回報（建造/生育速率不足？famine 太兇？）

- [ ] **Step 2: handback + Commit**

```markdown
# Hand Back: 經濟死水解鎖
## 實作摘要 / 行為變化（建造數 before/after、軍民階梯、生育與人口曲線、解凍世界存活率）/ 守恆驗證 / 待確認（BREED_CHANCE/GOVERN_TARGET 參數、軍鎮是否成形、pop 是否止跌）
```

```powershell
git add docs/superpowers/handbacks/2026-06-13-economy-bootstrap.md
git commit -m "docs: economy bootstrap handback (Task 4)"
```
