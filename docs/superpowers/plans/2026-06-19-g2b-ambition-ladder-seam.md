# G2b 野心階梯狀態 + 統一 seam Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建「leader values → 隊野心階梯狀態(rung+archetype+cap)」單一真值源，存 `TeamData`，由 faction_ai 每 cadence 更新 + log；`strategic_ai` 改**讀階梯衍生** faction 戰略目標（真 reader，非 dormant）。

**Architecture:** `AmbitionLadder` 純 static helper 從 leader values derive archetype/cap、從隊安全 + 個性算 rung（升降/躁進）。狀態存 TeamData。faction_ai evaluate_all 每 cadence 呼 update。`strategic_ai._update_faction_goals` 重構：讀 faction-leader 階梯（取代 :50/63 raw value 計分）。**全閾值/權重 TEST VALUE**（藍圖平衡 pass 調）。

**Tech Stack:** Godot 4.2.2 GDScript；新 `class_name AmbitionLadder` → 建後 `--import`；headless harness。

## Global Constraints

- wrapper：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`；新 class_name 後先 `--import`。
- 新 `_test_*` 註冊於 `_initialize()`。
- WHAT：`specs/2026-06-19-g2-goal-anchor-design`（§3.1-3.3 階梯/升降、§3.2 archetype）；HOW：`specs/2026-06-19-g2-goal-anchor-how-design` §3。依賴 G2a（已 merged）。
- **行為變有界**：本 plan 只改 faction **strategic_goals 的衍生來源**（raw values → 階梯）。骨架求 TEST-VALUE 等價，不求平衡。`get_goal_task_override` caller + 每階 task 全表 = **G2c（不在本 plan）**。
- 回歸閘：`=== DONE ===` + 0 assert fail + InvariantAudit 0 + coin_eq 守恆 + 1000 Tick 無崩潰。strategic 行為位移屬預期（不 gate multi drift）。
- 全 TEST VALUE 標註，呈報藍圖磨 feel（handback `systems-to-blueprint-g2b-feel`）。

## File Structure

- `scripts/simulation/ambition_ladder.gd`（新，static helper）。
- `scripts/data/team_data.gd`（加 ambition 欄位，:91 prosperity_eval 附近）。
- `scripts/simulation/faction_ai_system.gd`（evaluate_all 加 ladder update cadence）。
- `scripts/simulation/strategic_ai_system.gd`（`_update_faction_goals` 重構讀階梯）。
- `scripts/debug/headless_test.gd`（測試）。

## Global Constants（TEST VALUE，AmbitionLadder 內）

```
RUNG_SURVIVE=0 RUNG_ACCUMULATE=1 RUNG_EXPAND=2 RUNG_STATE=3 RUNG_HEGEMON=4
ARCHETYPE_FORCE="武力" ARCHETYPE_TRADE="商業" ARCHETYPE_SETTLE="定居"
LADDER_EVAL_CADENCE = 10 * WorldState.TICKS_PER_HOUR   # 同 STRATEGIC_INTERVAL 量級
# 安全門檻(proxy,TEST VALUE)：
SURPLUS_DAYS=7  EXPAND_MIN_POP=8  STATE_MIN_FACTION_TEAMS=2  HEGEMON_MIN_FACTION_TEAMS=4
```

---

### Task 1: TeamData ambition 欄位 + AmbitionLadder archetype/cap derive

**Files:**
- Create: `scripts/simulation/ambition_ladder.gd`
- Modify: `scripts/data/team_data.gd`（:91 附近）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces:
  - `TeamData`: `ambition_archetype:String=""`、`ambition_cap:int=0`、`ambition_rung:int=0`、`ambition_eval_next_tick:int=0`。
  - `AmbitionLadder.derive_archetype(leader:PersonData) -> String`（武力/商業/定居；values 最高軸；平手序 武力>商業>定居）。
  - `AmbitionLadder.derive_cap(leader:PersonData) -> int`（`野心` → 封頂 rung：<0.3→1, <0.55→2, <0.8→3, else 4；TEST VALUE）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_ambition_derive() -> void:
	print("--- AmbitionLadder archetype/cap derive ---")
	var warlord := PersonData.new()
	warlord.values = {"野心": 0.9, "好戰": 0.8, "貪婪": 0.2, "義氣": 0.2, "慎重": 0.2}
	assert(AmbitionLadder.derive_archetype(warlord) == "武力", "高野心好戰→武力")
	assert(AmbitionLadder.derive_cap(warlord) == 4, "野心0.9→封頂稱霸(4)")
	var merchant := PersonData.new()
	merchant.values = {"野心": 0.4, "好戰": 0.2, "貪婪": 0.9, "義氣": 0.3, "慎重": 0.5}
	assert(AmbitionLadder.derive_archetype(merchant) == "商業", "高貪婪→商業")
	assert(AmbitionLadder.derive_cap(merchant) == 2, "野心0.4→封頂擴張(2)")
	var settler := PersonData.new()
	settler.values = {"野心": 0.2, "好戰": 0.1, "貪婪": 0.2, "義氣": 0.9, "慎重": 0.8}
	assert(AmbitionLadder.derive_archetype(settler) == "定居", "高義氣慎重→定居")
	print("ambition derive OK")

func _test_team_ambition_default() -> void:
	print("--- TeamData ambition 預設 ---")
	var t := TeamData.new()
	assert(t.ambition_rung == 0 and t.ambition_cap == 0 and t.ambition_archetype == "", "預設生存/空")
	print("team ambition default OK")
```

`_initialize()` 加兩行。

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `AmbitionLadder`/欄位不存在 → parse/assert 失敗。

- [ ] **Step 3: 建 AmbitionLadder + 欄位**

`scripts/data/team_data.gd` 在 `var prosperity_eval_next_tick`（:91）下加：

```gdscript
# G2 野心階梯（leader values 衍生，單一真值源；見 AmbitionLadder）
var ambition_archetype: String = ""   # 武力/商業/定居
var ambition_cap: int = 0             # 終極野心封頂 rung
var ambition_rung: int = 0            # 當前實際 rung（0 生存…4 稱霸）
var ambition_eval_next_tick: int = 0
```

建 `scripts/simulation/ambition_ladder.gd`：

```gdscript
class_name AmbitionLadder

const RUNG_SURVIVE: int = 0
const RUNG_ACCUMULATE: int = 1
const RUNG_EXPAND: int = 2
const RUNG_STATE: int = 3
const RUNG_HEGEMON: int = 4

const ARCHETYPE_FORCE: String = "武力"
const ARCHETYPE_TRADE: String = "商業"
const ARCHETYPE_SETTLE: String = "定居"

const LADDER_EVAL_CADENCE: int = 10 * WorldState.TICKS_PER_HOUR
# 安全門檻 proxy（TEST VALUE）
const SURPLUS_DAYS: float = 7.0
const EXPAND_MIN_POP: int = 8
const STATE_MIN_FACTION_TEAMS: int = 2
const HEGEMON_MIN_FACTION_TEAMS: int = 4

# leader values 最高軸 → archetype（平手序 武力>商業>定居）。TEST VALUE 權重。
static func derive_archetype(leader: PersonData) -> String:
	if leader == null:
		return ARCHETYPE_SETTLE
	var v: Dictionary = leader.values
	var force: float = float(v.get("野心", 0.5)) * 0.5 + float(v.get("好戰", 0.5)) * 0.5
	var trade: float = float(v.get("貪婪", 0.5))
	var settle: float = float(v.get("義氣", 0.5)) * 0.5 + float(v.get("慎重", 0.5)) * 0.5
	if force >= trade and force >= settle:
		return ARCHETYPE_FORCE
	if trade >= settle:
		return ARCHETYPE_TRADE
	return ARCHETYPE_SETTLE

# 野心 → 封頂 rung（TEST VALUE）
static func derive_cap(leader: PersonData) -> int:
	if leader == null:
		return RUNG_ACCUMULATE
	var amb: float = float(leader.values.get("野心", 0.5))
	if amb < 0.3: return RUNG_ACCUMULATE
	if amb < 0.55: return RUNG_EXPAND
	if amb < 0.8: return RUNG_STATE
	return RUNG_HEGEMON
```

- [ ] **Step 4: --import + 跑 harness 驗證通過**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `ambition derive OK` / `team ambition default OK`，`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/ambition_ladder.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(g2b): TeamData ambition 欄位 + AmbitionLadder archetype/cap derive"
```

---

### Task 2: rung 評估（升降/躁進）+ faction_ai cadence update + log

**Files:**
- Modify: `scripts/simulation/ambition_ladder.gd`（加 `eval_rung` + `update`）
- Modify: `scripts/simulation/faction_ai_system.gd`（evaluate_all :502-505 區，加 ladder update）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: Task 1 derive。
- Produces:
  - `AmbitionLadder.target_rung(state, team, leader) -> int`（安全門檻達到的最高 rung，capped by `ambition_cap`）。
  - `AmbitionLadder.update(state, team) -> void`（重 derive archetype/cap；rung 朝 target 移動：躁進(高野心+低慎重)直跳、否則一步；安全崩退階；變動 print log；設 `ambition_eval_next_tick`）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _mk_ambition_team(amb: float, prudence: float, food: float, pop: int) -> Array:
	var s := WorldState.new(); s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 1
	var l := PersonData.new(); l.id = 1000; l.team_id = 1
	l.values = {"野心": amb, "好戰": 0.6, "貪婪": 0.3, "義氣": 0.3, "慎重": prudence}
	s.persons[1000] = l; t.leader_id = l.id
	if pop > 1: AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop - 1)
	t.resources = {"food": food}
	s.teams[1] = t
	return [s, t]

func _test_ambition_rung_climb() -> void:
	print("--- AmbitionLadder rung 升降 ---")
	# 高野心低慎重(躁進) + 足糧 + 夠人 → 快爬
	var r := _mk_ambition_team(0.9, 0.1, 9999.0, 12)
	var s: WorldState = r[0]; var t: TeamData = r[1]
	AmbitionLadder.update(s, t)
	assert(t.ambition_archetype != "" and t.ambition_cap == 4, "derive 生效")
	assert(t.ambition_rung >= AmbitionLadder.RUNG_EXPAND, "躁進+足糧足人應達擴張+，實際=%d" % t.ambition_rung)
	# 安全崩（無糧）→ 退階
	t.resources["food"] = 0.0
	AmbitionLadder.update(s, t)
	assert(t.ambition_rung < AmbitionLadder.RUNG_EXPAND, "無糧應退階，實際=%d" % t.ambition_rung)

func _test_ambition_cap_limits() -> void:
	print("--- AmbitionLadder cap 封頂 ---")
	# 低野心(cap=積累) 即使足糧足人 → 卡 cap
	var r := _mk_ambition_team(0.2, 0.5, 9999.0, 20)
	var s: WorldState = r[0]; var t: TeamData = r[1]
	for _i in range(5): AmbitionLadder.update(s, t)
	assert(t.ambition_rung <= AmbitionLadder.RUNG_ACCUMULATE, "低野心卡 cap(積累)，實際=%d" % t.ambition_rung)
	print("ambition cap OK")
```

`_initialize()` 加兩行。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `target_rung`/`update` 不存在 → 失敗。

- [ ] **Step 3: 實作 eval + update**

`scripts/simulation/ambition_ladder.gd` 加：

```gdscript
# 安全門檻達到的最高 rung（capped by ambition_cap）。proxy 指標 TEST VALUE。
static func target_rung(state: WorldState, team: TeamData, leader: PersonData) -> int:
	var rung: int = RUNG_SURVIVE
	var pop: int = team.population
	var food: float = float(team.resources.get("food", 0))
	var surplus_need: float = float(pop) * 2.4 * SURPLUS_DAYS   # 2.4 = 日餐量量級(對齊既有)
	# 積累：糧盈餘
	if food >= surplus_need:
		rung = RUNG_ACCUMULATE
		# 擴張：盈餘 + 夠人
		if pop >= EXPAND_MIN_POP:
			rung = RUNG_EXPAND
			# 立國/稱霸：faction 規模
			if team.faction_id != -1 and state.factions.has(team.faction_id):
				var fteams: int = state.factions[team.faction_id].member_team_ids.size()
				if fteams >= STATE_MIN_FACTION_TEAMS:
					rung = RUNG_STATE
				if fteams >= HEGEMON_MIN_FACTION_TEAMS:
					rung = RUNG_HEGEMON
	return mini(rung, team.ambition_cap)

static func update(state: WorldState, team: TeamData) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	team.ambition_archetype = derive_archetype(leader)
	team.ambition_cap = derive_cap(leader)
	var target: int = target_rung(state, team, leader)
	var old: int = team.ambition_rung
	if target < old:
		team.ambition_rung = old - 1        # 安全崩：一步退（可連續退到生存）
	elif target > old:
		var amb: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
		var prud: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
		var reckless: bool = amb > 0.65 and prud < 0.4
		team.ambition_rung = target if reckless else old + 1   # 躁進直跳 / 否則一步
	team.ambition_eval_next_tick = state.world.current_tick + LADDER_EVAL_CADENCE
	if team.ambition_rung != old:
		print("[Ambition] Team%d rung %d→%d (%s cap=%d)" % [
			team.team_id, old, team.ambition_rung, team.ambition_archetype, team.ambition_cap])
```

`scripts/simulation/faction_ai_system.gd` evaluate_all 迴圈內（:502 leader 補位後、:505 survival 前）加：

```gdscript
		# G2b：野心階梯狀態更新（cadence）
		if team.leader_id != -1 and state.world.current_tick >= team.ambition_eval_next_tick:
			AmbitionLadder.update(state, team)
```

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: rung 升降/cap 測試過；`=== DONE ===`、coin_eq 守恆、InvariantAudit 0、1000 Tick 無崩潰（log 出現 `[Ambition]` rung 變動）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/ambition_ladder.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g2b): rung 升降/躁進 eval + faction_ai cadence update + log"
```

---

### Task 3: strategic_ai 讀階梯衍生戰略目標（真 reader，消 dormant）

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`（`_update_faction_goals` :42-68）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: faction-leader team 的 `ambition_rung/archetype`。
- Produces: `_update_faction_goals` 改為**階梯 gate**：`expand` 僅 `rung>=RUNG_EXPAND` 且 archetype==武力；`trade_net` 僅 archetype==商業（任何 rung>=積累）；`defend` 維持（faction 多隊）。取代 :50/63 的 raw value 計分。**這是 ambition_rung 的真 consumer**（非 dormant）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_strategic_reads_ladder() -> void:
	print("--- strategic_ai 讀階梯 gate ---")
	var sai := StrategicAiSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var lt := TeamData.new(); lt.team_id = 1; lt.tile_pos = Vector2i(0,0)
	var l := PersonData.new(); l.id = 1000; l.team_id = 1
	l.values = {"野心": 0.9, "好戰": 0.8, "貪婪": 0.2}
	s.persons[1000] = l; lt.leader_id = l.id
	lt.ambition_archetype = "武力"
	s.teams[1] = lt
	var f := FactionData.new(); f.faction_id = 0; f.leader_team_id = 1; f.member_team_ids = [1]
	s.factions[0] = f
	# 低 rung(生存) → 不該 expand
	lt.ambition_rung = AmbitionLadder.RUNG_SURVIVE
	sai._update_faction_goals(s, f)
	var has_expand_low: bool = false
	for g in f.strategic_goals: if g["type"] == "expand": has_expand_low = true
	assert(not has_expand_low, "rung 生存不該 expand")
	# 高 rung(擴張) + 武力 → 該 expand（需有獨立目標可選；無則略過此斷言）
	lt.ambition_rung = AmbitionLadder.RUNG_EXPAND
	sai._update_faction_goals(s, f)
	print("strategic reads ladder OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: 現 `_update_faction_goals` 用 raw values（不看 rung）→ 低 rung 仍可能 expand → assert 失敗。

- [ ] **Step 3: 重構 _update_faction_goals 讀階梯**

`scripts/simulation/strategic_ai_system.gd` `_update_faction_goals`（:42-68）的 expand/trade_net 計分改階梯 gate。把 :50-66 區：

```gdscript
	var expand_score: float = v.get("野心", 0.5) * 0.5 + v.get("好戰", 0.5) * 0.5
	if expand_score > 0.4:
		var tgt_id: int = _nearest_independent(state, leader_team)
		if tgt_id != -1:
			faction.strategic_goals.append({ "type": "expand", "target_id": tgt_id,
				"priority": expand_score })

	if faction.member_team_ids.size() > 1:
		var weakest_id: int = _find_weakest_member(state, faction)
		if weakest_id != -1 and weakest_id != faction.leader_team_id:
			faction.strategic_goals.append({ "type": "defend", "target_id": weakest_id,
				"priority": 0.7 })

	var trade_score: float = v.get("貪婪", 0.5) * 0.4 + (1.0 - v.get("好戰", 0.5)) * 0.3
	if trade_score > 0.35:
		faction.strategic_goals.append({ "type": "trade_net", "target_id": -1,
			"priority": trade_score })
```

換成（讀 leader_team 階梯）：

```gdscript
	# G2b：戰略目標由 faction-leader 野心階梯衍生（取代 raw value 計分）
	var rung: int = leader_team.ambition_rung
	var arche: String = leader_team.ambition_archetype
	# expand：武力 archetype + rung≥擴張
	if arche == AmbitionLadder.ARCHETYPE_FORCE and rung >= AmbitionLadder.RUNG_EXPAND:
		var tgt_id: int = _nearest_independent(state, leader_team)
		if tgt_id != -1:
			faction.strategic_goals.append({ "type": "expand", "target_id": tgt_id,
				"priority": 0.5 + float(v.get("野心", 0.5)) * 0.5 })

	if faction.member_team_ids.size() > 1:
		var weakest_id: int = _find_weakest_member(state, faction)
		if weakest_id != -1 and weakest_id != faction.leader_team_id:
			faction.strategic_goals.append({ "type": "defend", "target_id": weakest_id,
				"priority": 0.7 })

	# trade_net：商業 archetype + rung≥積累
	if arche == AmbitionLadder.ARCHETYPE_TRADE and rung >= AmbitionLadder.RUNG_ACCUMULATE:
		faction.strategic_goals.append({ "type": "trade_net", "target_id": -1,
			"priority": 0.4 + float(v.get("貪婪", 0.5)) * 0.4 })
```

> `v` 仍取自 faction_leader.values（既有 :48）。定居 archetype 的擴張(開墾/招民) = G2c 全表，本 plan 不加新 strategic 型別。

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: `strategic reads ladder OK`；`=== DONE ===`、coin_eq 守恆、InvariantAudit 0、1000 Tick 無崩潰。strategic 行為位移（expand/trade 改由階梯 gate）屬預期。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g2b): strategic_ai 戰略目標改由 faction-leader 野心階梯衍生(真 reader)"
```

---

### Task 4: invariant + 回歸 + 觀測

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`

- [ ] **Step 1: 加 invariant**

`docs/invariants.md`：

```markdown
### 隊目標單一 owner = leader 野心階梯
- 隊無獨立目標。`TeamData.ambition_rung/archetype/cap` 由 leader values + 隊安全經 `AmbitionLadder` derive，**單一真值源**。換 leader → 重 derive（方向劇變）。
- faction strategic_goals **衍生**自 faction-leader 階梯（`strategic_ai._update_faction_goals` 讀 rung/archetype），禁他處獨立定隊/勢力戰略目標。
- 階梯門檻/權重全 TEST VALUE（正式平衡 pass 調）。rung→每階 task/tag 全表 = G2c；個人脫軌 = G2d。
```

- [ ] **Step 2: known_issues 註記**

`docs/known_issues.md`：G2 進度——G2a(關係圖)+G2b(階梯狀態+strategic 衍生) ✅；`get_goal_task_override` 接入 + 每階 task 全表待 G2c、私驅動/血仇待 G2d。

- [ ] **Step 3: 全回歸 + 觀測**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick 無崩潰。log 應見 `[Ambition]` rung 變動（多階弧可觀測，藍圖 §9 驗收鋪路）。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md
git commit -m "docs(g2b): 隊目標單一 owner invariant + G2 進度註記"
```

---

## Self-Review 註記

- **無 dormant**：`ambition_rung` 有真 reader = strategic_ai（Task3）。不是寫了沒人讀。
- **spec 覆蓋**：欄位+derive(T1)、升降/躁進+cadence(T2)、strategic reader(T3)、invariant(T4)。`get_goal_task_override` caller + 每階 task 全表 + 私驅動 = 明確 OUT（G2c/G2d）。
- **行為位移**：strategic_goals 來源換（raw values→階梯）；骨架 TEST-VALUE 等價，平衡 pass 校。coin_eq/invariant 守恆不可破。
- **TEST VALUE 待藍圖磨**：archetype 權重、cap 野心切點、rung 安全門檻、躁進條件——全呈報藍圖（handback）。
- **依賴**：G2a 已 merged（本 plan 不用 relation_edges，G2d 才用）。
- **新 class_name AmbitionLadder** → 每次跑測試前 `--import`。
- **執行確認**：faction_ai update 注入點在 leader 補位(:502)後、survival(:505)前；確認 `state.factions` / `member_team_ids` 欄位名對（strategic_ai 既有用法對齊）。
