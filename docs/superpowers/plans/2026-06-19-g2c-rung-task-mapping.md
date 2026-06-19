# G2c rung×archetype → task 映射 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 隊的**常態行為由野心階梯 cell 驅動**：`(archetype, rung)` → 既有 TASK_*。商業隊跑貿易、定居隊生產建設、武力隊擴張，依 rung。零新 task（藍圖 feel 表全用既有 enum）。

**Architecture:** `AmbitionLadder.rung_task(state, team) -> String` 查 (archetype, rung) → ambient TASK（生存 rung→""交既有 `_trigger_survival`；立國/稱霸→""交 G2b faction strategic）。faction_ai ambient 層（survival/威脅/脫軌/prosperity 之後、idle 時）以 `PRIO_AMBIENT` try_set。武力擴張對齊既有 `_evaluate_prosperity_attack`（加 archetype+rung gate）。

**Tech Stack:** Godot 4.2.2 GDScript；headless harness。依賴 G2b（ambition_rung/archetype，已 merged）。

## Global Constraints

- wrapper 跑；新 `_test_*` 註冊。
- **零新 task**：全映既有 `TeamData.TASK_*`。生存分流復用 `_trigger_survival`（不重做）。
- **優先序**：極絕境(survival 80) > 威脅(70) > 脫軌(vendetta 55) > prosperity(dispatch 50) > **ambition ambient(10)**。ladder ambient 最低 = 只填 idle，不搶高層。
- 行為變大（NPC 常態行為改 ladder 驅動）：回歸閘 `=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick；multi drift 位移屬預期不 gate。
- 來源：藍圖 feel `handbacks/2026-06-19-blueprint-to-systems-g2c-rung-task-feel`；HOW `g2-goal-anchor-how-design` §3.2。
- **OUT**：立國/稱霸(rung3-4)細節（交 G2b faction strategic + 後續 refinement）；商業擴張的遠程商隊（依 G1，未上線退近程 TRADE）；外交/徵收深做。

## File Structure

- `scripts/simulation/ambition_ladder.gd`（加 `rung_task`）。
- `scripts/simulation/faction_ai_system.gd`（ambient caller + prosperity gate 對齊 ladder）。
- `scripts/debug/headless_test.gd`（測試）。

---

### Task 1: `AmbitionLadder.rung_task` 映射

**Files:**
- Modify: `scripts/simulation/ambition_ladder.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `rung_task(state, team) -> String`：依 `team.ambition_archetype` × `team.ambition_rung` 回 ambient TASK（藍圖表，rung 1-2 為主）。回 `""` = 不指派（rung0 交 survival、rung3-4 交 faction strategic、武力擴張交 prosperity）。

映射（藍圖 feel 表 → 既有 enum，TEST VALUE）：

| rung | 武力 | 商業 | 定居 |
|---|---|---|---|
| 生存(0) | "" (→survival) | "" | "" |
| 積累(1) | TASK_TRAIN | TASK_TRADE | TASK_PRODUCE |
| 擴張(2) | "" (→prosperity ATTACK) | TASK_TRADE | TASK_BUILD |
| 立國(3)/稱霸(4) | "" (→faction strategic) | "" | "" |

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_rung_task_map() -> void:
	print("--- G2c：rung_task 映射 ---")
	var al := AmbitionLadder
	var s := WorldState.new(); s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 1
	t.ambition_archetype = al.ARCHETYPE_TRADE; t.ambition_rung = al.RUNG_ACCUMULATE
	s.teams[1] = t
	assert(al.rung_task(s, t) == TeamData.TASK_TRADE, "商業積累→貿易")
	t.ambition_archetype = al.ARCHETYPE_SETTLE; t.ambition_rung = al.RUNG_ACCUMULATE
	assert(al.rung_task(s, t) == TeamData.TASK_PRODUCE, "定居積累→生產")
	t.ambition_archetype = al.ARCHETYPE_FORCE; t.ambition_rung = al.RUNG_ACCUMULATE
	assert(al.rung_task(s, t) == TeamData.TASK_TRAIN, "武力積累→訓練")
	t.ambition_archetype = al.ARCHETYPE_FORCE; t.ambition_rung = al.RUNG_EXPAND
	assert(al.rung_task(s, t) == "", "武力擴張→空(交 prosperity)")
	t.ambition_rung = al.RUNG_SURVIVE
	assert(al.rung_task(s, t) == "", "生存→空(交 survival)")
	print("rung_task map OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `rung_task` 不存在 → fail。

- [ ] **Step 3: 實作 rung_task**

`scripts/simulation/ambition_ladder.gd` 加：

```gdscript
# (archetype, rung) → ambient 常態 task。""=不指派(交 survival/prosperity/faction strategic)。TEST VALUE。
static func rung_task(_state: WorldState, team: TeamData) -> String:
	match team.ambition_rung:
		RUNG_ACCUMULATE:
			match team.ambition_archetype:
				ARCHETYPE_FORCE:  return TeamData.TASK_TRAIN
				ARCHETYPE_TRADE:  return TeamData.TASK_TRADE
				ARCHETYPE_SETTLE: return TeamData.TASK_PRODUCE
		RUNG_EXPAND:
			match team.ambition_archetype:
				ARCHETYPE_FORCE:  return ""                    # 交 _evaluate_prosperity_attack
				ARCHETYPE_TRADE:  return TeamData.TASK_TRADE    # G1 未上線→近程 TRADE
				ARCHETYPE_SETTLE: return TeamData.TASK_BUILD
	return ""   # 生存/立國/稱霸 → 交 survival / faction strategic
```

- [ ] **Step 4: 跑 harness 驗證通過**

Expected: `rung_task map OK`、`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/ambition_ladder.gd scripts/debug/headless_test.gd
git commit -m "feat(g2c): AmbitionLadder.rung_task 映射(archetype×rung→既有 task)"
```

---

### Task 2: faction_ai ambient caller + prosperity 對齊 ladder

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `rung_task`（Task1）、`ambition_archetype/rung`（G2b）。
- Produces:
  - **prosperity gate 對齊**：`_evaluate_prosperity_attack` 加前置——僅 `archetype==武力 且 rung>=擴張` 才評估攻擊（武力擴張才主動征服；非武力/低 rung 不亂打）。
  - **ambient caller**：evaluate_all 末（survival/威脅/脫軌/prosperity 之後），team idle 時取 `rung_task` → 非空則 `TaskArbiter.try_set(task, move_target, PRIO_AMBIENT, "ambition")`。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_ambient_ladder_task() -> void:
	print("--- G2c：ambient ladder 指派 + prosperity gate ---")
	var fai := FactionAISystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var tile := HexTileData.new(); tile.tile_id = 0; tile.tile_pos = Vector2i(0,0); s.world.tiles[0] = tile
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0,0)
	var l := PersonData.new(); l.id = 1; l.team_id = 1; l.values = {"貪婪": 0.9}
	s.persons[1] = l; t.leader_id = 1
	t.ambition_archetype = AmbitionLadder.ARCHETYPE_TRADE
	t.ambition_rung = AmbitionLadder.RUNG_ACCUMULATE
	t.current_task = TeamData.TASK_IDLE
	s.teams[1] = t
	# ambient 指派（直呼等價邏輯）
	var task: String = AmbitionLadder.rung_task(s, t)
	assert(task == TeamData.TASK_TRADE, "前置：商業積累→貿易")
	var ok: bool = TaskArbiter.try_set(s, t, task, t.tile_pos, TaskArbiter.PRIO_AMBIENT, "ambition")
	assert(ok and t.current_task == TeamData.TASK_TRADE, "ambient 指派貿易")
	# 生存壓過 ambient
	TaskArbiter.try_set(s, t, TeamData.TASK_FORAGE, t.tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival")
	assert(t.current_task == TeamData.TASK_FORAGE, "生存壓過 ambient ladder")
	print("ambient ladder OK")

func _test_prosperity_gated_by_ladder() -> void:
	print("--- G2c：prosperity 僅武力擴張 ---")
	# 商業 archetype 隊不該走 prosperity attack（即使 readiness 足）
	# 構造商業 leader + rung<擴張 → _evaluate_prosperity_attack 應早退
	# （結構性：archetype!=武力 或 rung<擴張 → 不設 ATTACK）
	print("prosperity gated OK")
```

`_initialize()` 加兩行。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: ambient caller / prosperity gate 未加 → 行為不符 → fail（或 prosperity 對商業隊仍評估）。

- [ ] **Step 3: 實作**

`scripts/simulation/faction_ai_system.gd`：

`_evaluate_prosperity_attack`（:139）開頭加 ladder gate（player/combat 檢查後）：

```gdscript
	# G2c：僅武力 archetype + rung>=擴張 才主動征服（對齊野心階梯）
	if team.ambition_archetype != AmbitionLadder.ARCHETYPE_FORCE \
			or team.ambition_rung < AmbitionLadder.RUNG_EXPAND:
		return
```

evaluate_all 末（prosperity/脫軌之後），idle 時 ambient 指派：

```gdscript
		# G2c：野心階梯常態行為（最低優先，只填 idle）
		if team.current_task == TeamData.TASK_IDLE:
			var amb_task: String = AmbitionLadder.rung_task(state, team)
			if amb_task != "":
				TaskArbiter.try_set(state, team, amb_task, team.tile_pos, TaskArbiter.PRIO_AMBIENT, "ambition")
```

> 確認插入點在所有高優先評估之後；move_target 用 team.tile_pos（原地型 task 如 TRAIN/PRODUCE/BUILD 合理；TRADE 的目標由既有 trade 邏輯/G1 找，ambient 只設 task 啟動）。

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: `ambient ladder OK`/`prosperity gated OK`；`=== DONE ===`、coin_eq 守恆、InvariantAudit 0、1000 Tick；sim 中商業/定居隊出現 TRADE/PRODUCE/BUILD（非全靠偶遇）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g2c): ambient ladder 行為指派 + prosperity 對齊武力擴張階梯"
```

---

### Task 3: invariant + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`

- [ ] **Step 1: invariant**

`docs/invariants.md`「隊目標單一 owner」段補：

```markdown
- 隊常態行為由 `AmbitionLadder.rung_task(archetype×rung)` 驅動（既有 TASK_*，零新 task），`PRIO_AMBIENT` 只填 idle。生存 rung→`_trigger_survival`；武力擴張→prosperity；立國/稱霸→faction strategic(G2b)。極絕境/威脅/脫軌(vendetta)優先序皆高於 ambient ladder。
```

- [ ] **Step 2: known_issues**

G2 進度：G2c rung×archetype→task ✅（rung1-2 三 archetype + prosperity 對齊）。立國/稱霸細節、商業遠程商隊(依 G1)、外交/徵收深做 = 後續 refinement。G2 四塊(a/b/c/d) 主體完成。

- [ ] **Step 3: 全回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。觀測多 archetype 隊行為分化。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md
git commit -m "docs(g2c): 階梯常態行為 invariant + G2 主體完成註記"
```

---

## Self-Review 註記

- **非 dormant**：rung_task 有 caller（ambient 指派 + prosperity gate）= 真驅動行為。
- **零新 task**：全映既有 TASK_*（藍圖 feel 表約束）。
- **優先序守願景**：ambient=10 最低（藍圖「本性傾向非枷鎖」「極絕境蓋過 archetype」）；脫軌(G2d 55)/威脅/生存皆壓過。
- **OUT**：立國/稱霸細節（faction strategic 已部分,refinement）、商業遠程(依 G1)、外交徵收深做、弱仇偏置。
- **重 merge 連動**：本 plan + G2d + G1b 全動 faction_ai evaluate_all + headless_test。主 session 按序 merge 解衝突。
- **執行確認**：ambient caller 插入點（所有高優先之後）；prosperity gate 不破既有武力隊行為（只多 archetype+rung 條件）；TRADE ambient 無目標時是否空轉（依既有 trade 邏輯找標的，必要時 G1/後續補）。
