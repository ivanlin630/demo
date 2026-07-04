# Encounter Bug Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 3 confirmed encounter-system bugs — (1) player attack skips init_encounter so combat resolves instantly, (2) encounter view tight loop can block frame if "ongoing" is ever returned, (3) encounter view renders wrong 10×10 rectangular area instead of MAP_RADIUS=12 hex circle.

**Architecture:** Bug 1 is in simulation layer (`player_command_system.gd`). Bugs 2–3 are in UI layer (`encounter_view.gd`). All three are independent 1–2 file edits. Fix in task order.

**Tech Stack:** Godot 4.2.2 GDScript. Headless test: `scripts/debug/headless_test.gd`. No new files.

---

### File Map

| File | Change |
|---|---|
| `scripts/simulation/player_command_system.gd` | Task 1: add `init_encounter` call in `_action_attack` |
| `scripts/ui/encounter_view.gd` | Task 2: add `await` in `_advance_until_player_or_end`; Task 3: fix `_draw()` + `_hex_center()` + `show_encounter()` |

---

### Task 1: Fix `_action_attack` — call `init_encounter`

**Files:**
- Modify: `scripts/simulation/player_command_system.gd:151-162`

**Root cause:** `_action_attack` sets `encounter_active=true` but never calls `init_encounter`. `encounter_units` stays empty. On first `advance_encounter_tick`: `_has_active_units(defender_id)` returns `false` → immediate "attacker_win" → encounter resolves in one tick.

Note: `init_encounter` internally sets `encounter_active=true`, `encounter_attacker_id`, and `encounter_defender_id`, so remove those 3 redundant lines.

- [ ] **Step 1: Read the target lines**

Read `scripts/simulation/player_command_system.gd` lines 151–162 to confirm text matches before editing.

- [ ] **Step 2: Apply fix**

Replace:
```gdscript
func _action_attack(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	state.encounter_attacker_id = pt_id
	state.encounter_defender_id = target_id
	state.encounter_active      = true
	if not state.player_hostile_teams.has(target_id):
		state.player_hostile_teams.append(target_id)
	state.player_pending_targets.erase(target_id)
	print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
	return { "ok": true, "msg": "發起攻擊" }
```

With:
```gdscript
func _action_attack(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	_encounter.init_encounter(state, pt_id, target_id, "normal")
	if not state.player_hostile_teams.has(target_id):
		state.player_hostile_teams.append(target_id)
	state.player_pending_targets.erase(target_id)
	print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
	return { "ok": true, "msg": "發起攻擊" }
```

- [ ] **Step 3: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`, zero `SCRIPT ERROR` lines.

- [ ] **Step 4: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "fix(encounter): call init_encounter in _action_attack"
```

---

### Task 2: Fix `_advance_until_player_or_end` tight loop

**Files:**
- Modify: `scripts/ui/encounter_view.gd:305-324`

**Root cause:** `while true` loop calls `_bridge.advance_encounter_tick()` without any `await`. If the bridge ever returns a value not in `{"player_turn", "encounter_ended", "no_encounter"}` (i.e. `"ongoing"`), the match block has no matching arm, no `return` fires, and the loop spins indefinitely on the current frame, freezing Godot. Adding `await get_tree().process_frame` after the match block catches this and also makes future changes to tick granularity safe.

`sim_bridge.advance_encounter_tick` currently returns `"ongoing"` when `encounter_active=true` but no player unit is found (line 75). After encounter_system spawns the player unit, this path won't fire — but the `await` defends against any future case where "ongoing" can return.

- [ ] **Step 1: Read the target lines**

Read `scripts/ui/encounter_view.gd` lines 305–324 to confirm text before editing.

- [ ] **Step 2: Apply fix**

Replace:
```gdscript
func _advance_until_player_or_end() -> void:
	while true:
		var result: String = _bridge.advance_encounter_tick()
		queue_redraw()
		_refresh_ui()
		match result:
			"player_turn":
				_waiting_for_player = true
				return
			"encounter_ended":
				var end_state: WorldState = _bridge.get_state()
				if end_state.last_encounter_result.get("can_subjugate", false):
					_post_combat = true
					_waiting_for_player = true
					_refresh_ui()
					return   # 留在畫面等待 [J] 或任意鍵
				hide_encounter()
				return
			"no_encounter":
				return
```

With:
```gdscript
func _advance_until_player_or_end() -> void:
	while true:
		var result: String = _bridge.advance_encounter_tick()
		queue_redraw()
		_refresh_ui()
		match result:
			"player_turn":
				_waiting_for_player = true
				return
			"encounter_ended":
				var end_state: WorldState = _bridge.get_state()
				if end_state.last_encounter_result.get("can_subjugate", false):
					_post_combat = true
					_waiting_for_player = true
					_refresh_ui()
					return   # 留在畫面等待 [J] 或任意鍵
				hide_encounter()
				return
			"no_encounter":
				return
		await get_tree().process_frame
```

The `await` executes only if no `return` fired (i.e. result was `"ongoing"`). It yields one frame, preventing a freeze, then loops.

- [ ] **Step 3: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`, zero `SCRIPT ERROR` lines.

- [ ] **Step 4: Commit**

```
git add scripts/ui/encounter_view.gd
git commit -m "fix(encounter): add await frame break for ongoing ticks in _advance_until_player_or_end"
```

---

### Task 3: Fix encounter view hex map — replace 10×10 rect with MAP_RADIUS=12 hex circle

**Files:**
- Modify: `scripts/ui/encounter_view.gd` (constants block, `_hex_center`, `_draw`, `show_encounter`)

**Root cause (3 sub-issues):**

1. `_draw()` iterates `range(10) × range(10)` — covers only columns 0–9, rows 0–9. `EncounterSystem` places units at axial hex coords centered at `(0,0)`, radius 12. Defender units spawn at edge 3 (`Vector2i(-12, 12)` area) — invisible on a 0–9 grid.

2. `_hex_center(col, row)` uses `(col % 2)` for the odd-column vertical stagger. GDScript modulo returns negative values for negative operands (`-1 % 2 == -1`). For negative columns this applies a stagger of `−26.0` instead of `+26.0`, misaligning all odd-index negative columns.

3. Initial camera is `Vector2.ZERO`, so the map origin (0,0) tile appears at screen top-left instead of viewport center.

- [ ] **Step 1: Read constants block and _hex_center**

Read `scripts/ui/encounter_view.gd` lines 1–15 and lines 122–131.

- [ ] **Step 2: Add MAP_RADIUS_VIEW constant**

Find lines 6–9:
```gdscript
const HEX_W: float    = 60.0
const HEX_H: float    = 52.0
const COL_STEP: float = 45.0
const ODD_OFF: float  = 26.0
```

Replace with:
```gdscript
const HEX_W: float        = 60.0
const HEX_H: float        = 52.0
const COL_STEP: float     = 45.0
const ODD_OFF: float      = 26.0
const MAP_RADIUS_VIEW: int = 12  # must match EncounterSystem.MAP_RADIUS
```

- [ ] **Step 3: Fix `_hex_center` for negative columns**

Replace:
```gdscript
func _hex_center(col: int, row: int) -> Vector2:
	return Vector2(col * COL_STEP + HEX_W * 0.5,
				   row * HEX_H + (col % 2) * ODD_OFF + HEX_H * 0.5)
```

With:
```gdscript
func _hex_center(col: int, row: int) -> Vector2:
	# Use abs(col) % 2 so odd-column stagger is always positive for negative cols.
	var odd_off: float = ODD_OFF if (abs(col) % 2 == 1) else 0.0
	return Vector2(col * COL_STEP + HEX_W * 0.5,
				   row * HEX_H + odd_off + HEX_H * 0.5)
```

- [ ] **Step 4: Fix `_draw()` to render hex circle**

Read `scripts/ui/encounter_view.gd` lines 141–175 to confirm text before editing.

Replace the tile-drawing block inside `_draw()` (the `# Draw 10×10 grid` section):

```gdscript
	# Draw 10×10 grid
	for row in range(10):
		for col in range(10):
			var center: Vector2 = _world_to_screen(_hex_center(col, row))
			var pts: PackedVector2Array = _hex_points(center.x, center.y)
			draw_colored_polygon(pts, Color(0.3, 0.6, 0.3))
			draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0, 0, 0, 0.4), 1.0)
```

With:
```gdscript
	# Draw hex circle — MAP_RADIUS_VIEW=12, centered at axial (0,0)
	for row in range(-MAP_RADIUS_VIEW, MAP_RADIUS_VIEW + 1):
		for col in range(-MAP_RADIUS_VIEW, MAP_RADIUS_VIEW + 1):
			if _hex_dist(Vector2i(col, row), Vector2i.ZERO) > MAP_RADIUS_VIEW:
				continue
			var center: Vector2 = _world_to_screen(_hex_center(col, row))
			var pts: PackedVector2Array = _hex_points(center.x, center.y)
			draw_colored_polygon(pts, Color(0.3, 0.6, 0.3))
			draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0, 0, 0, 0.4), 1.0)
```

- [ ] **Step 5: Center camera on map open**

Read `scripts/ui/encounter_view.gd` lines 35–41 (`show_encounter`).

Replace:
```gdscript
func show_encounter() -> void:
	visible = true
	_post_combat = false
	_refresh_ui()
	queue_redraw()
	_waiting_for_player = false
	_advance_until_player_or_end()
```

With:
```gdscript
func show_encounter() -> void:
	visible = true
	_post_combat = false
	# Center camera so axial (0,0) appears at viewport center.
	var vp_size: Vector2 = get_viewport_rect().size
	_camera = vp_size * 0.5 - _hex_center(0, 0) * _zoom
	_refresh_ui()
	queue_redraw()
	_waiting_for_player = false
	_advance_until_player_or_end()
```

- [ ] **Step 6: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`, zero `SCRIPT ERROR` lines.

- [ ] **Step 7: Commit**

```
git add scripts/ui/encounter_view.gd
git commit -m "fix(encounter): render MAP_RADIUS hex circle centered at origin"
```

---

### Self-Review

**Spec coverage:**
- Bug 1 (`_action_attack` missing `init_encounter`) → Task 1 ✅
- Bug 2 (tight loop no await) → Task 2 ✅
- Bug 3 (rectangular render) → Task 3 ✅

**Placeholder scan:** No TBD, no "implement later". All code blocks show exact replacements.

**Type consistency:**
- `_hex_dist` used in Task 3 Step 4 is already defined in `encounter_view.gd` line 339–342 — no new function needed ✅
- `MAP_RADIUS_VIEW` constant added in Task 3 Step 2, used in Steps 4 ✅
- `_hex_center` signature unchanged ✅
- `_encounter` member (`EncounterSystem`) already exists in `player_command_system.gd` line 9 ✅
