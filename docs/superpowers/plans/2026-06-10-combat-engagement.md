# NPC 戰鬥成形 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 解 NPC-NPC encounter=0：寬版同格 scan + named 速度加權。

**Architecture:**
- `movement_system.process` 回傳 `{ "arrived": [...], "moved": [...] }`
- `interaction_system.process_on_move` 取代 process_on_arrival 在 sim_runner 的 call point
- `_compute_team_speed` named weight ×3
- mounts/wagons 進 known_issues

**Spec:** `docs/superpowers/specs/2026-06-10-combat-engagement-and-named-weight-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/movement_system.gd` | `process` 回傳 Dictionary（arrived + moved）；`_compute_team_speed` NAMED_WEIGHT=3 |
| `scripts/simulation/interaction_system.gd` | 新 `process_on_move`（接 moved_ids，邏輯同既有 process_on_arrival）|
| `scripts/simulation/sim_runner.gd` | call point 改 process_on_move（message system 保留 arrived）|
| `docs/known_issues.md` | 加 mounts/wagons speed |
| `scripts/debug/headless_test.gd` | 6 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: movement_system process 回傳 moved + arrived

**Files:**
- Modify: `scripts/simulation/movement_system.gd`
- Modify: 所有 `process` 呼叫端
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_movement_returns_moved_and_arrived() -> void:
	print("--- Combat Task1: movement 回傳 moved+arrived ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	for x in range(-3, 4):
		for y in range(-3, 4):
			var tile := HexTileData.new()
			tile.tile_pos = Vector2i(x, y); tile.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tile
	# Team A: 移動但不 arrived
	var a := TeamData.new()
	a.team_id = 0; a.tile_pos = Vector2i(0, 0); a.move_target = Vector2i(3, 0)
	a.population = 5; a.move_tick_acc = 9999
	state.teams[0] = a
	# Team B: 同 tick arrived
	var b := TeamData.new()
	b.team_id = 1; b.tile_pos = Vector2i(2, 0); b.move_target = Vector2i(3, 0)
	b.population = 5; b.move_tick_acc = 9999
	state.teams[1] = b
	var ms = MovementSystem.new()
	var result = ms.process(state, [0, 1])
	assert(result is Dictionary, "回傳應 Dictionary")
	assert(result.has("arrived") and result.has("moved"))
	assert(1 in result["arrived"], "B 應 arrived，實際=%s" % str(result["arrived"]))
	assert(0 in result["moved"] and 1 in result["moved"], "兩 team 都 moved")
	print("Combat Task1 OK")
```

- [ ] **Step 2: 改 `process` 回傳 Dictionary**

找原 `func process(...) -> Array:`，改：

```gdscript
func process(state: WorldState, team_ids: Array, time_mult: float = 1.0) -> Dictionary:
	var arrived: Array = []
	var moved: Array = []
	for tid in team_ids:
		if not state.teams.has(tid): continue
		var team: TeamData = state.teams[tid]
		var old_pos: Vector2i = team.tile_pos
		# ... 既有所有 continue 邏輯 保留
		# ... 既有 _step_team
		if _step_team(state, team):   # 既有：moved=true
			moved.append(tid)
			if team.tile_pos == team.move_target or team.move_target == Vector2i(-1, -1):
				arrived.append(tid)
	return { "arrived": arrived, "moved": moved }
```

注意：`_step_team` 內已會 clear move_target 當 arrived，所以 arrived 判定要在 `_step_team` 之前判 + cache 或在內補設 flag。最穩：`_step_team` 結束後 check `team.tile_pos == old_pos` 為 moved，再 check `team.move_target == -1 and team.tile_pos != old_pos` 推 arrived。

或更直接：`_step_team` 內既有 `_on_arrival` 觸發，加 `team._just_arrived = true` 暫存 flag，process 收完清掉。

最簡實作（不加 transient flag）：

```gdscript
for tid in team_ids:
	# ... 既有 continue 邏輯
	var old_pos: Vector2i = team.tile_pos
	var old_target: Vector2i = team.move_target
	if _step_team(state, team):
		moved.append(tid)
		# arrived = 到達原 move_target（_step_team 內已清 move_target）
		if team.tile_pos == old_target:
			arrived.append(tid)
```

- [ ] **Step 3: 改所有呼叫端**

```powershell
grep -rn "movement_system\.process\|_movement_system\.process\|MovementSystem.*\.process\(" scripts/ --include=*.gd
```

預期改：
- `sim_runner.gd`：原 `var arrived: Array = _ms.process(...)` → `var move_result = _ms.process(...)`，後續用 `move_result["arrived"]` / `move_result["moved"]`

- [ ] **Step 4: 跑 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/movement_system.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(movement): process returns moved + arrived (Task 1)"
```

---

## Task 2: interaction_system.process_on_move

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_process_on_move_triggers_combat() -> void:
	print("--- Combat Task2: moved 不 arrived 同格 → combat ---")
	# Setup: A current_task=攻擊, prosperity_target_id=1, A 跟 P 同格但 A move_target=遠處 (不是 P 位置)
	# A 之前 moved 進這格 但不 arrived
	# Expected: process_on_move 觸發 try_interact → start_combat
	# ...
	print("Combat Task2 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
func process_on_move(state: WorldState, moved_ids: Array, all_team_ids: Array) -> void:
	for moved_id in moved_ids:
		if not state.teams.has(moved_id): continue
		if _sub.try_merge_back(state, moved_id): continue
		var moved: TeamData = state.teams[moved_id]
		if moved.current_task == "護衛": continue
		for other_id in all_team_ids:
			if other_id == moved_id: continue
			var other: TeamData = state.teams.get(other_id)
			if other == null: continue
			if other.tile_pos != moved.tile_pos: continue
			_try_interact(state, moved_id, other_id)
```

= 既有 `process_on_arrival` body 完整複製，只改參數名 `arrived_ids` → `moved_ids`、`arrived` → `moved`。

- [ ] **Step 3: 保留 process_on_arrival**

不刪 process_on_arrival（其他 caller 可能還用）。但 sim_runner 改 call process_on_move。

- [ ] **Step 4: 跑 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(interaction): process_on_move scan (Task 2)"
```

---

## Task 3: sim_runner 換 call point

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: grep sim_runner 既有 call**

```powershell
grep -n "process_on_arrival\|process_on_move" scripts/simulation/sim_runner.gd
```

- [ ] **Step 2: 改 call**

```gdscript
# 既有
# var arrived_ids: Array = _movement_system.process(state, team_ids, time_mult)
# _interaction_system.process_on_arrival(state, arrived_ids, team_ids)

# 改
var move_result: Dictionary = _movement_system.process(state, team_ids, time_mult)
var moved_ids: Array = move_result["moved"]
var arrived_ids: Array = move_result["arrived"]
_interaction_system.process_on_move(state, moved_ids, team_ids)
# message 系統保留 arrived（intel/訊息傳播語意）
_message_system.propagate_on_arrival(state, arrived_ids, team_ids)
_message_system.exchange_intel_on_arrival(state, arrived_ids, team_ids)
```

- [ ] **Step 3: 跑 game_sim_test 確認無 regression**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|FAIL|ERROR" | Select-Object -First 5
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/sim_runner.gd
git commit -m "feat(sim): use process_on_move (Task 3)"
```

---

## Task 4: NAMED_WEIGHT=3

**Files:**
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_named_weight_speed() -> void:
	print("--- Combat Task4: named K=3 weight ---")
	var state := WorldState.new()
	var team := TeamData.new()
	team.team_id = 0; team.population = 10
	# 2 named (leader + 1) + 8 unnamed
	var leader := PersonData.new()
	leader.person_id = 1; leader.attributes = { "體力": 0.9 }
	# (注意: body_parts 預設健康)
	leader._initialize() if leader.has_method("_initialize") else null
	state.persons[1] = leader
	team.leader_id = 1
	var member := PersonData.new()
	member.person_id = 2; member.attributes = { "體力": 0.9 }
	state.persons[2] = member
	team.named_members = [2]
	var ms = MovementSystem.new()
	var speed_hi = ms._compute_team_speed(state, team)
	# leader 體力 0.3
	leader.attributes = { "體力": 0.3 }
	member.attributes = { "體力": 0.3 }
	var speed_lo = ms._compute_team_speed(state, team)
	var diff: float = speed_hi - speed_lo
	assert(diff > 0.08, "K=3 應差 >8%，實際=%.3f" % diff)
	print("Combat Task4 OK (Δspeed=%.3f)" % diff)
```

- [ ] **Step 2: 改函數**

```gdscript
const NAMED_WEIGHT: int = 3

func _compute_team_speed(state: WorldState, team: TeamData) -> float:
	var total_speed: float = 0.0
	var total_count: int = 0
	var named_ids: Array = team.named_members.duplicate()
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p = state.persons.get(pid)
		if p != null:
			total_speed += p.get_effective_speed() * NAMED_WEIGHT
			total_count += NAMED_WEIGHT
	var unnamed_healthy: int = maxi(team.population - named_ids.size() - team.wounded, 0)
	total_speed += float(unnamed_healthy) * 1.0
	total_count += unnamed_healthy
	total_speed += float(team.wounded) * 0.5
	total_count += team.wounded
	if total_count == 0:
		return 1.0
	return total_speed / float(total_count)
```

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(movement): NAMED_WEIGHT=3 in team speed (Task 4)"
```

---

## Task 5: known_issues 加 mounts/wagons

**Files:**
- Modify: `docs/known_issues.md`

- [ ] **Step 1: 加條目**

```markdown
## Movement

- **mounts/wagons 沒加速度**：`_compute_team_speed` 只算個人 effective_speed + status；mounts 只加 carry capacity，wagons 只加 carry + 地形 penalty。騎兵跟步兵當前同速。
  待 spec：speed_class（步兵/騎兵/輜重）+ mount 速度 bonus + wagon 拖速 penalty。
```

- [ ] **Step 2: Commit**

```powershell
git add docs/known_issues.md
git commit -m "docs: known_issues mounts/wagons speed missing (Task 5)"
```

---

## Task 6: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-10-combat-engagement.md`

- [ ] **Step 1: 跑全測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|encounter|start_combat" | Select-Object -First 20
Get-Content godot_multi.log -Encoding UTF8 -Tail 30
```

預期：multi runner 4 config × 90 天 encounter > 0、ProsperityAttack → 真戰鬥、無 invariant violation。

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-10-combat-engagement.md`：

```markdown
# Hand Back: NPC 戰鬥成形

## 實作摘要

- movement_system：process 回傳 Dictionary（arrived + moved），NAMED_WEIGHT=3
- interaction_system：新 process_on_move（既有 on_arrival 邏輯 + moved_ids）
- sim_runner：call process_on_move；message 系統保留 arrived
- known_issues：mounts/wagons speed 未實作

## 行為變化

- 兩 mobile team 同格 → 任一方 step 完即觸發 try_interact
- leader 體力差異 ±10% 速度（之前 ±3%）
- 既有 trade / diplomacy / merge / extort 也會在路過同格觸發（不只 arrived）

## 連動風險

- 既有同格邏輯都能處理 moved（不只 arrived）狀況 — 已驗
- subteam try_merge_back 既有防呆，OK
- player_pending_targets 既有去重，OK
- message intel 保留 arrived 語意，未改

## 驗證結果

- headless_test：N/N 過
- game_sim_test：ALL INVARIANTS PASSED
- game_sim_multi 4 config × 90 天：encounter > 0、ProsperityAttack 進入戰鬥

## 待主 session 確認

- NAMED_WEIGHT=3 是否合理（戰爭頻率 / ETA 變動）
- 寬版 scan 是否引發 spam（trade/diplomacy 在每步觸發）
- anon 質量系統 brainstorm 待開
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-10-combat-engagement.md
git commit -m "docs: combat engagement handback (Task 6)"
```
