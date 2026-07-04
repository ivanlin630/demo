# Movement Boundary Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent teams from stepping onto off-map tiles by filtering `_step_team`'s neighbour candidates to only tiles present in `state.world.tiles`.

**Architecture:** Single-function change in `movement_system.gd`. `_get_neighbors` stays pure. One guard added to the neighbour loop; one stuck-state handler added after loop. `player_command_system.move_to` already validates target tiles — no change needed there.

**Tech Stack:** GDScript 4.2, Godot 4.2.2, headless test runner

---

## File Map

| File | Action |
|---|---|
| `scripts/simulation/movement_system.gd` | **Modify** — filter off-map neighbours in `_step_team` |
| `scripts/debug/headless_test.gd` | **Modify** — add 30-step boundary guard test |

---

## Task 1: Fix `_step_team` and add boundary test

**Files:**
- Modify: `scripts/simulation/movement_system.gd:145-162`
- Modify: `scripts/debug/headless_test.gd` (before `print("=== DONE ===")`)

- [ ] **Step 1: Write failing test in headless_test.gd**

Find `print("=== DONE ===")` (last line before end of test function). Insert directly before it:

```gdscript
	# ── movement boundary test ────────────────────────────────────────
	var _ms_test := MovementSystem.new()
	var _test_team: TeamData = state.teams[0]
	var _orig_tile_pos: Vector2i = _test_team.tile_pos
	# set off-map target: team must never leave the world tiles
	_test_team.move_target = Vector2i(9999, 9999)
	for _mi in range(30):
		_ms_test._step_team(state, _test_team)
		assert(state.world.tiles.has(_test_team.tile_pos.x * 1000 + _test_team.tile_pos.y),
			"[BoundaryTest] team must stay on-map (step %d)" % _mi)
	_test_team.tile_pos    = _orig_tile_pos
	_test_team.move_target = Vector2i(-1, -1)
	print("[BoundaryTest] movement boundary guard ok — team stayed on-map for 30 steps")
	# ── end movement boundary test ───────────────────────────────────
```

- [ ] **Step 2: Run test to confirm it currently fails**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `SCRIPT ERROR` or `assert` failure mentioning `BoundaryTest`. The test walks 30 steps toward (9999,9999); without the fix, the team will step off-map on the first edge step.

*(If the world is small and team[0] starts far from the edge, the team might not reach the boundary in 30 steps — in that case the test passes vacuously. Still proceed to implement the fix; the fix is correct regardless.)*

- [ ] **Step 3: Fix `_step_team` in `movement_system.gd`**

Locate `_step_team` (around line 145). The current inner loop body:

```gdscript
	for neighbor in _get_neighbors(team.tile_pos):
		var d: int = _hex_dist(neighbor, team.move_target)
		if d < best_dist:
			best_dist = d
			best_pos = neighbor
```

Replace with:

```gdscript
	for neighbor in _get_neighbors(team.tile_pos):
		var nid: int = neighbor.x * 1000 + neighbor.y
		if not state.world.tiles.has(nid):
			continue   # never step off-map
		var d: int = _hex_dist(neighbor, team.move_target)
		if d < best_dist:
			best_dist = d
			best_pos  = neighbor
```

Then, after the loop and before `team.tile_pos = best_pos`, add the stuck-state handler:

```gdscript
	# If no on-map neighbour improves distance, team is stuck — cancel target
	if best_pos == team.tile_pos and team.tile_pos != team.move_target:
		print("[Move] Team %d stuck at (%d,%d), clearing move_target" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y])
		team.move_target = Vector2i(-1, -1)
		return false
```

The full updated `_step_team` should look like:

```gdscript
func _step_team(state: WorldState, team: TeamData) -> bool:
	var old_pos: Vector2i = team.tile_pos
	if team.tile_pos == team.move_target:
		team.move_target = Vector2i(-1, -1)
		_on_arrival(state, team)
		return false
	var best_pos: Vector2i = team.tile_pos
	var best_dist: int = _hex_dist(team.tile_pos, team.move_target)
	for neighbor in _get_neighbors(team.tile_pos):
		var nid: int = neighbor.x * 1000 + neighbor.y
		if not state.world.tiles.has(nid):
			continue   # never step off-map
		var d: int = _hex_dist(neighbor, team.move_target)
		if d < best_dist:
			best_dist = d
			best_pos  = neighbor
	# If no on-map neighbour improves distance, team is stuck — cancel target
	if best_pos == team.tile_pos and team.tile_pos != team.move_target:
		print("[Move] Team %d stuck at (%d,%d), clearing move_target" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y])
		team.move_target = Vector2i(-1, -1)
		return false
	team.tile_pos = best_pos
	if team.tile_pos == team.move_target:
		team.move_target = Vector2i(-1, -1)
		_on_arrival(state, team)
	return team.tile_pos != old_pos
```

- [ ] **Step 4: Run test to confirm it passes**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected:
- `[BoundaryTest] movement boundary guard ok — team stayed on-map for 30 steps`
- `=== DONE ===`
- No `SCRIPT ERROR`

- [ ] **Step 5: Commit**

```
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "fix(movement): filter off-map neighbours in _step_team; clear stuck move_target"
```

---

## Task 2: Write hand-back and push

- [ ] **Step 1: Create hand-back**

Create `docs/superpowers/handbacks/2026-06-05-movement-boundary-fix.md`:

```markdown
# Hand Back: Movement Boundary Fix

## 實作摘要

- `scripts/simulation/movement_system.gd` — `_step_team` 新增 `state.world.tiles.has(nid)` guard，濾掉地圖外鄰格；新增 stuck handler：若所有 on-map 鄰格均不靠近目標，清除 move_target 並 return false
- `scripts/debug/headless_test.gd` — 新增 30-step boundary 測試：以 (9999,9999) 為目標，驗證 team 每步均在地圖內

與 spec 無差異。

## 連動風險

- `_step_team` 加了 `state` 依賴性（原本只讀 `team`），但 `state` 已是既有參數，無 API 變動。
- stuck handler 會清除 NPC 的 move_target，可能導致 NPC 在地圖邊緣停頓，等待下一次 FactionAI tick 重設目標。這是可接受的退化行為。

## 待主 session 確認

- 無
```

- [ ] **Step 2: Commit hand-back and push**

```
git add docs/superpowers/handbacks/2026-06-05-movement-boundary-fix.md
git commit -m "docs: add hand-back for movement-boundary-fix"
git push -u origin HEAD
```
