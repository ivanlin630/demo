# G2d 私人驅動脫軌（血仇）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓 G2a 的 feud 關係邊**驅動行為**：強血仇 + 衝動個性 leader → **脫軌**拉隊去打仇人（覆蓋階梯常態，但不覆蓋生存/威脅）。順手刪已 dormant 的 `get_goal_task_override`（框架債）。

**Architecture:** feud 邊**已由戰鬥 populate**（`_end_combat` 寫 looted 記憶 → G2a `write_memory` 映射 feud 邊，敗方含 leader 獲 feud→勝方 leader）。本 plan = **reader**：`NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate(好戰高/慎重低) → 回仇人 team；faction_ai 以 `PRIO_VENDETTA`(55，生存下/prosperity 上) try_set TASK_ATTACK。= G2a relation_edges 的真 consumer（消 G2a dormant）。

**Tech Stack:** Godot 4.2.2 GDScript；headless harness。依賴 G2a（relation_edges/RelationGraph，已 merged）。

## Global Constraints

- wrapper 跑；新 `_test_*` 註冊 `_initialize()`。
- 復用：`RelationGraph`（G2a 讀 feud 邊）、`TaskArbiter.try_set`、既有 looted 記憶→feud（不重做血仇 populate）。
- 行為變：強仇+衝動 leader 會脫軌攻擊（emergent drama，藍圖 §3.4 願景）。回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick 無崩潰。
- 來源：藍圖 G2 spec §3.4；HOW `g2-goal-anchor-how-design` §5。
- **OUT**：弱仇「偏置」（擴張優先挑仇人邊，= refinement，本 plan 只做強仇脫軌）；kin/家族樹 feud 傳播（G2a 留骨架，完整家族=後續）；killed 型別深用。

## File Structure

- `scripts/simulation/task_arbiter.gd`（加 `PRIO_VENDETTA`）。
- `scripts/simulation/npc_ai_system.gd`（加 `vendetta_target`；刪 dormant `get_goal_task_override`）。
- `scripts/simulation/faction_ai_system.gd`（evaluate_all 加 vendetta caller）。
- `scripts/debug/headless_test.gd`（測試）。

## Global Constants

```
TaskArbiter.PRIO_VENDETTA = 55          # 生存(80)/威脅(70)下；prosperity(50)上
NpcAiSystem.VENDETTA_INTENSITY = 0.6    # TEST VALUE：脫軌的最低仇恨強度
NpcAiSystem.VENDETTA_BELLIGERENCE = 0.6 # 好戰 ≥ 此
NpcAiSystem.VENDETTA_PRUDENCE = 0.4     # 慎重 < 此
```

---

### Task 1: `NpcAiSystem.vendetta_target` — 讀 feud 邊 + 衝動 gate

**Files:**
- Modify: `scripts/simulation/npc_ai_system.gd`（加 `vendetta_target` + const）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `vendetta_target(state, leader: PersonData) -> int`：取 `RelationGraph.strongest(leader.relation_edges, "feud")`；若 intensity ≥ VENDETTA_INTENSITY 且 `好戰 ≥ VENDETTA_BELLIGERENCE` 且 `慎重 < VENDETTA_PRUDENCE` → 解 feud target person → 回其 `team_id`（須存在且非自隊）；否則 -1。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_vendetta_target() -> void:
	print("--- G2d：vendetta_target 脫軌判定 ---")
	var ai := NpcAiSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 1
	leader.values = {"好戰": 0.8, "慎重": 0.2}   # 衝動
	var foe := PersonData.new(); foe.id = 99; foe.team_id = 2
	s.persons[1] = leader; s.persons[99] = foe
	var t2 := TeamData.new(); t2.team_id = 2; s.teams[2] = t2
	# 強 feud 邊 → 仇人 team 2
	RelationGraph.add_edge(leader.relation_edges, "feud", 99, 0.8, 100)
	assert(ai.vendetta_target(s, leader) == 2, "強仇+衝動→脫軌打 team2")
	# 弱仇 → 不脫軌
	var calm := PersonData.new(); calm.id = 3; calm.team_id = 1
	calm.values = {"好戰": 0.8, "慎重": 0.2}
	RelationGraph.add_edge(calm.relation_edges, "feud", 99, 0.3, 100)   # 強度不足
	assert(ai.vendetta_target(s, calm) == -1, "弱仇不脫軌")
	# 強仇但冷靜(高慎重) → 不脫軌
	var prudent := PersonData.new(); prudent.id = 4; prudent.team_id = 1
	prudent.values = {"好戰": 0.8, "慎重": 0.7}
	RelationGraph.add_edge(prudent.relation_edges, "feud", 99, 0.9, 100)
	assert(ai.vendetta_target(s, prudent) == -1, "冷靜不脫軌(隱忍)")
	print("vendetta_target OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `vendetta_target` 不存在 → fail。

- [ ] **Step 3: 實作**

`scripts/simulation/npc_ai_system.gd` 加 const（檔頭）+ 函數：

```gdscript
const VENDETTA_INTENSITY: float = 0.6     # TEST VALUE
const VENDETTA_BELLIGERENCE: float = 0.6
const VENDETTA_PRUDENCE: float = 0.4

# 強血仇 + 衝動 → 脫軌目標 team_id（否則 -1）。讀 G2a feud 邊。
func vendetta_target(state: WorldState, leader: PersonData) -> int:
	if leader == null:
		return -1
	if float(leader.values.get("好戰", 0.5)) < VENDETTA_BELLIGERENCE:
		return -1
	if float(leader.values.get("慎重", 0.5)) >= VENDETTA_PRUDENCE:
		return -1
	var edge: Dictionary = RelationGraph.strongest(leader.relation_edges, "feud")
	if edge.is_empty() or float(edge.get("intensity", 0.0)) < VENDETTA_INTENSITY:
		return -1
	var foe: PersonData = state.persons.get(int(edge.get("target", -1)))
	if foe == null or foe.team_id == leader.team_id or not state.teams.has(foe.team_id):
		return -1
	return foe.team_id
```

- [ ] **Step 4: 跑 harness 驗證通過**

Expected: `vendetta_target OK`、`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/npc_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g2d): NpcAiSystem.vendetta_target 讀 feud 邊+衝動 gate"
```

---

### Task 2: faction_ai 脫軌 caller + PRIO_VENDETTA + 刪 dormant override

**Files:**
- Modify: `scripts/simulation/task_arbiter.gd`（加 `PRIO_VENDETTA`）
- Modify: `scripts/simulation/faction_ai_system.gd`（evaluate_all 加 vendetta caller）
- Modify: `scripts/simulation/npc_ai_system.gd`（刪 dormant `get_goal_task_override`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `vendetta_target`（Task1）。
- Produces: faction_ai evaluate_all 內，**威脅評估後、prosperity 前**：取 leader vendetta_target → 非 -1 則 `TaskArbiter.try_set(state, team, TASK_ATTACK, foe_tile, PRIO_VENDETTA, "vendetta")` + 設 `prosperity_target_id`（追擊用，比照 prosperity）。`PRIO_VENDETTA=55`（生存80/威脅70 擋得住、prosperity50 擋不住）。

- [ ] **Step 1: 確認 dormant override 無 caller**

```bash
grep -rn "get_goal_task_override" scripts/
```
Expected: 只定義處（npc_ai_system），無 production caller（dormant，框架債記載）。若有 caller → 停報。

- [ ] **Step 2: 寫失敗測試**

```gdscript
func _test_vendetta_derail_task() -> void:
	print("--- G2d：脫軌 caller 設 ATTACK ---")
	var fai := FactionAISystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0,0)
	var l := PersonData.new(); l.id = 1; l.team_id = 1
	l.values = {"好戰": 0.8, "慎重": 0.2, "野心": 0.5}
	s.persons[1] = l; t.leader_id = 1
	var foe_t := TeamData.new(); foe_t.team_id = 2; foe_t.tile_pos = Vector2i(3,3)
	var foe := PersonData.new(); foe.id = 99; foe.team_id = 2; s.persons[99] = foe
	s.teams[1] = t; s.teams[2] = foe_t
	RelationGraph.add_edge(l.relation_edges, "feud", 99, 0.8, 100)
	# 直呼脫軌判定+try_set（等價 evaluate_all 內邏輯）
	var vt: int = NpcAiSystem.new().vendetta_target(s, l)
	assert(vt == 2, "前置：脫軌目標 team2")
	var ok: bool = TaskArbiter.try_set(s, t, TeamData.TASK_ATTACK, foe_t.tile_pos, TaskArbiter.PRIO_VENDETTA, "vendetta")
	assert(ok and t.current_task == TeamData.TASK_ATTACK and t.task_priority == TaskArbiter.PRIO_VENDETTA, "脫軌設 ATTACK@55")
	# 生存(80) 擋得住脫軌
	TaskArbiter.try_set(s, t, TeamData.TASK_FORAGE, Vector2i(0,0), TaskArbiter.PRIO_SURVIVAL, "survival")
	assert(t.current_task == TeamData.TASK_FORAGE, "生存壓過脫軌")
	print("vendetta derail OK")
```

`_initialize()` 加。

- [ ] **Step 3: 跑 harness 驗證失敗**

Expected: `PRIO_VENDETTA` 不存在 → parse fail。

- [ ] **Step 4: 實作**

`scripts/simulation/task_arbiter.gd` 加（PLAYER 60 與 DISPATCH 50 之間）：

```gdscript
const PRIO_VENDETTA:  int = 55   # 私人脫軌（強仇+衝動）：生存/威脅下、prosperity 上
```

`scripts/simulation/faction_ai_system.gd` evaluate_all，**威脅評估(`_evaluate_threat`)後、prosperity 評估前**加：

```gdscript
		# G2d：私人脫軌（強血仇+衝動 leader 拉隊打仇人；生存/威脅擋得住）
		var _vleader: PersonData = state.persons.get(team.leader_id)
		if _vleader != null:
			var _vfoe: int = NpcAiSystem.new().vendetta_target(state, _vleader)
			if _vfoe != -1 and state.teams.has(_vfoe):
				if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
						state.teams[_vfoe].tile_pos, TaskArbiter.PRIO_VENDETTA, "vendetta"):
					team.prosperity_target_id = _vfoe   # 追擊刷新復用
```

> 確認插入點在 `_evaluate_threat` 之後、prosperity 之前（讀 evaluate_all 既有順序對齊）。

刪 `scripts/simulation/npc_ai_system.gd` 的 `get_goal_task_override`（dormant，無 caller，revenge 意圖已由 vendetta_target 經 G2a 圖取代）。保留 `check_goal_alignment`（loyalty nudge，有 caller）。

- [ ] **Step 5: --import + 跑 harness 驗證通過**

Expected: `vendetta derail OK`；`=== DONE ===`、coin_eq 守恆、InvariantAudit 0、1000 Tick 無崩潰；sim 中觀測到 `[抗命]`/vendetta ATTACK（脫軌 emergent）。既有 task/combat 測試不破。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/task_arbiter.gd scripts/simulation/faction_ai_system.gd scripts/simulation/npc_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g2d): 脫軌 caller(PRIO_VENDETTA 攻擊仇人)+刪 dormant get_goal_task_override"
```

---

### Task 3: invariant + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`(若記 dormant 清理)

- [ ] **Step 1: invariant**

`docs/invariants.md`：

```markdown
### 私人脫軌（血仇）
- feud 邊由戰鬥（looted 記憶→G2a 映射）populate；`NpcAiSystem.vendetta_target` 讀 leader 最強 feud + 衝動 gate(好戰≥/慎重<)。
- 脫軌 = `TaskArbiter` `PRIO_VENDETTA`(55)：生存(80)/威脅(70) 擋得住、prosperity(50) 擋不住。冷靜 leader 隱忍不脫軌。
- relation_edges 的行為 consumer = vendetta_target（G2a 圖不再 dormant）。
```

- [ ] **Step 2: known_issues / progress**

known_issues G2 進度：G2d 脫軌 ✅；弱仇偏置 = refinement、kin feud 傳播 = 家族樹後續。框架債：dormant `get_goal_task_override` 已刪（接 `[[project_framework_seams]]` dormant 清理）。

- [ ] **Step 3: 全回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md docs/progress.md
git commit -m "docs(g2d): 私人脫軌 invariant + dormant override 清理註記"
```

---

## Self-Review 註記

- **消雙 dormant**：(1) G2a relation_edges 終於有行為 reader（vendetta_target）；(2) 刪掉 pre-existing dormant `get_goal_task_override`（框架債）。
- **血仇 populate 不重做**：戰鬥 looted 記憶→G2a feud 邊已存在（敗方含 leader）→ 本 plan 只加 reader。
- **優先序正確**：PRIO_VENDETTA=55 在生存(80)/威脅(70) 下、prosperity(50) 上（藍圖 §3.4「不覆蓋生存」）。
- **OUT**：弱仇偏置（擴張挑仇人邊）= refinement；kin/家族 feud 傳播 = G2a 骨架後續；killed 型別深用。
- **執行確認**：evaluate_all 插入點（_evaluate_threat 後/prosperity 前）；get_goal_task_override 刪前 grep 無 caller。
- **G2c 未動**：rung→task 全表 + prosperity 接階梯 = G2c（待藍圖 feel）。本 plan 只私驅動脫軌層。
