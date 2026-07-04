# Encounter Group A — Coordinate System Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace offset-grid rendering/movement in `encounter_view.gd` with correct axial hex math, and move spawn positions from MAP_RADIUS (edge) to SPAWN_RADIUS=8 (inner ring) to prevent immediate-exit-on-retreat.

**Architecture:** `encounter_system.gd` already uses axial coords `(q, r)` throughout (hex_dist formula, edge hex generation). `encounter_view.gd` currently renders using offset-grid stagger (`COL_STEP`, `ODD_OFF`, even/odd column tables), causing visual distortion and movement misalignment. Fix: replace rendering with pointy-top axial→pixel math, replace movement neighbor tables with single axial dict, add `_world_to_axial` for click handling, add boundary check to `_do_move`.

**Tech Stack:** GDScript 4.2, Godot 4.2.2. Headless test runner: `A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe`

**Bugs fixed:** BUG-2 (offset rendering), BUG-5a (no boundary check in _do_move), BUG-16 (spawn at edge)

**Depends on:** Nothing — implement first.

---

## File Map

| File | Action |
|---|---|
| `scripts/ui/encounter_view.gd` | Modify — replace coord helpers, fix input, fix movement |
| `scripts/simulation/encounter_system.gd` | Modify — add SPAWN_RADIUS, fix spawn positions |

---

## Task 1: Replace Coordinate Constants and `_hex_center`

**Files:**
- Modify: `scripts/ui/encounter_view.gd:6-10` (constants), `scripts/ui/encounter_view.gd:126-130` (_hex_center)

- [ ] **Step 1: Replace constants block (lines 6–10)**

**Current:**
```gdscript
const HEX_W: float         = 60.0
const HEX_H: float         = 52.0
const COL_STEP: float      = 45.0
const ODD_OFF: float       = 26.0
const MAP_RADIUS_VIEW: int = 12
```

**Replace with:**
```gdscript
const HEX_SIZE: float      = 26.0   # circumradius; horizontal spacing ≈ 45 px
const MAP_RADIUS_VIEW: int = 12     # must match EncounterSystem.MAP_RADIUS
```

- [ ] **Step 2: Replace `_hex_center` (lines 126–130)**

**Current:**
```gdscript
func _hex_center(col: int, row: int) -> Vector2:
	var odd_off: float = ODD_OFF if (abs(col) % 2 == 1) else 0.0
	return Vector2(col * COL_STEP + HEX_W * 0.5,
				   row * HEX_H + odd_off + HEX_H * 0.5)
```

**Replace with:**
```gdscript
func _hex_center(axial: Vector2i) -> Vector2:
	# Pointy-top axial: q=axial.x, r=axial.y
	var q: float = float(axial.x)
	var r: float = float(axial.y)
	return Vector2(
		HEX_SIZE * (1.7321 * q + 0.8660 * r),   # sqrt(3) ≈ 1.7321
		HEX_SIZE * 1.5 * r
	)
```

- [ ] **Step 3: Replace `_hex_points` (lines 132–137)**

**Current:**
```gdscript
func _hex_points(cx: float, cy: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(cx - 15, cy - 26), Vector2(cx + 15, cy - 26),
		Vector2(cx + 30, cy),      Vector2(cx + 15, cy + 26),
		Vector2(cx - 15, cy + 26), Vector2(cx - 30, cy),
	])
```

**Replace with:**
```gdscript
func _hex_points(center: Vector2) -> PackedVector2Array:
	# Pointy-top hexagon; r=HEX_SIZE, h=r*sqrt(3)/2
	var r: float = HEX_SIZE
	var h: float = HEX_SIZE * 0.8660
	return PackedVector2Array([
		Vector2(center.x,       center.y - r),
		Vector2(center.x + h,   center.y - r * 0.5),
		Vector2(center.x + h,   center.y + r * 0.5),
		Vector2(center.x,       center.y + r),
		Vector2(center.x - h,   center.y + r * 0.5),
		Vector2(center.x - h,   center.y - r * 0.5),
	])
```

---

## Task 2: Update `_draw()` and `show_encounter` Call Sites

**Files:**
- Modify: `scripts/ui/encounter_view.gd:40-41` (show_encounter), `scripts/ui/encounter_view.gd:147-183` (_draw)

- [ ] **Step 1: Fix `show_encounter` camera centering (line 41)**

**Current:**
```gdscript
_camera = vp_size * 0.5 - _hex_center(0, 0) * _zoom
```

**Replace with:**
```gdscript
_camera = vp_size * 0.5 - _hex_center(Vector2i.ZERO) * _zoom
```

Note: `_hex_center(Vector2i.ZERO)` returns `Vector2(0, 0)` so `_camera = vp_size * 0.5`. Correct.

- [ ] **Step 2: Fix `_draw()` grid rendering (lines 156–159)**

**Current:**
```gdscript
var center: Vector2 = _world_to_screen(_hex_center(col, row))
var pts: PackedVector2Array = _hex_points(center.x, center.y)
draw_colored_polygon(pts, Color(0.3, 0.6, 0.3))
draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0, 0, 0, 0.4), 1.0)
```

**Replace with:**
```gdscript
var center: Vector2 = _world_to_screen(_hex_center(Vector2i(col, row)))
var pts: PackedVector2Array = _hex_points(center)
draw_colored_polygon(pts, Color(0.3, 0.6, 0.3))
draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0, 0, 0, 0.4), 1.0)
```

- [ ] **Step 3: Fix `_draw()` unit rendering (line 165)**

**Current:**
```gdscript
var center: Vector2 = _world_to_screen(_hex_center(pos.x, pos.y))
```

**Replace with:**
```gdscript
var center: Vector2 = _world_to_screen(_hex_center(pos))
```

- [ ] **Step 4: Fix `_draw()` cursor rendering (lines 180–182)**

**Current:**
```gdscript
var center: Vector2 = _world_to_screen(_hex_center(_cursor.x, _cursor.y))
var pts: PackedVector2Array = _hex_points(center.x, center.y)
```

**Replace with:**
```gdscript
var center: Vector2 = _world_to_screen(_hex_center(_cursor))
var pts: PackedVector2Array = _hex_points(center)
```

- [ ] **Step 5: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`. If parse errors, fix before continuing.

---

## Task 3: Fix Hex Movement and Click Input

**Files:**
- Modify: `scripts/ui/encounter_view.gd:186-204` (HEX_DIRS + _hex_neighbor), `scripts/ui/encounter_view.gd:276-289` (_handle_click)

- [ ] **Step 1: Replace `HEX_DIRS` and `_hex_neighbor` (lines 186–204)**

**Current:**
```gdscript
const HEX_DIRS: Dictionary = {
	KEY_Q: true, KEY_W: true, KEY_E: true,
	KEY_A: true, KEY_S: true, KEY_D: true,
}

func _hex_neighbor(pos: Vector2i, dir_key: int) -> Vector2i:
	var dirs_even: Dictionary = {
		KEY_Q: Vector2i(-1, -1), KEY_W: Vector2i(0, -1), KEY_E: Vector2i(1, -1),
		KEY_A: Vector2i(-1,  0),                          KEY_D: Vector2i(1,  0),
		KEY_S: Vector2i(0,  1),
	}
	var dirs_odd: Dictionary = {
		KEY_Q: Vector2i(-1,  0), KEY_W: Vector2i(0, -1), KEY_E: Vector2i(1,  0),
		KEY_A: Vector2i(-1,  1),                          KEY_D: Vector2i(1,  1),
		KEY_S: Vector2i(0,  1),
	}
	var dirs: Dictionary = dirs_even if pos.x % 2 == 0 else dirs_odd
	var delta: Vector2i = dirs.get(dir_key, Vector2i.ZERO)
	return pos + delta
```

**Replace with:**
```gdscript
const HEX_DIRS: Dictionary = {
	KEY_Q: true, KEY_W: true, KEY_E: true,
	KEY_A: true, KEY_S: true, KEY_D: true,
}

func _hex_neighbor(pos: Vector2i, dir_key: int) -> Vector2i:
	# Pointy-top axial directions — no even/odd split needed
	var dirs: Dictionary = {
		KEY_Q: Vector2i(-1,  0),   # west-NW
		KEY_W: Vector2i( 0, -1),   # north
		KEY_E: Vector2i( 1, -1),   # northeast
		KEY_A: Vector2i(-1,  1),   # southwest
		KEY_S: Vector2i( 0,  1),   # south
		KEY_D: Vector2i( 1,  0),   # east-SE
	}
	return pos + dirs.get(dir_key, Vector2i.ZERO)
```

Note: S remains in HEX_DIRS. In current code S is intercepted by surrender check before reaching movement. Group C plan (BUG-12) will move surrender to F key, making S work for movement.

- [ ] **Step 2: Add `_is_in_map`, `_world_to_axial`, `_axial_round` helpers**

Add these three functions after `_hex_neighbor` (before `_input`):

```gdscript
func _is_in_map(pos: Vector2i) -> bool:
	var dx: int = pos.x; var dy: int = pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= MAP_RADIUS_VIEW

func _world_to_axial(world: Vector2) -> Vector2i:
	# Inverse of pointy-top axial → pixel
	var q: float = (world.x * 0.5774 - world.y / 3.0) / HEX_SIZE  # 0.5774 ≈ 1/sqrt(3)
	var r: float = (world.y * (2.0 / 3.0)) / HEX_SIZE
	return _axial_round(q, r)

func _axial_round(fq: float, fr: float) -> Vector2i:
	var fs: float = -fq - fr
	var rq: int = roundi(fq); var rr: int = roundi(fr); var rs: int = roundi(fs)
	var dq: float = abs(float(rq) - fq)
	var dr: float = abs(float(rr) - fr)
	var ds: float = abs(float(rs) - fs)
	if dq > dr and dq > ds:
		rq = -rr - rs
	elif dr > ds:
		rr = -rq - rs
	return Vector2i(rq, rr)
```

- [ ] **Step 3: Fix `_handle_click` (lines 276–289)**

**Current:**
```gdscript
func _handle_click(screen_pos: Vector2) -> void:
	var state: WorldState = _bridge.get_state()
	var player_unit: Dictionary = _find_player_unit(state)
	if player_unit.is_empty(): return
	var w: Vector2 = _screen_to_world(screen_pos)
	var col: int = int(w.x / COL_STEP)
	var row: int = int(w.y / HEX_H)
	var clicked: Vector2i = Vector2i(col, row)
	match _mode:
		"idle":
			_lbl_cursor_info.text = _describe_hex(clicked, state)
		"attack_select":
			_do_attack(player_unit, clicked, state)
			_mode = "idle"; _cursor = Vector2i(-1, -1)
```

**Replace with:**
```gdscript
func _handle_click(screen_pos: Vector2) -> void:
	var state: WorldState = _bridge.get_state()
	var player_unit: Dictionary = _find_player_unit(state)
	if player_unit.is_empty(): return
	var world: Vector2 = _screen_to_world(screen_pos)
	var clicked: Vector2i = _world_to_axial(world)
	match _mode:
		"idle":
			_lbl_cursor_info.text = _describe_hex(clicked, state)
		"attack_select":
			_do_attack(player_unit, clicked, state)
			_mode = "idle"; _cursor = Vector2i(-1, -1)
```

- [ ] **Step 4: Fix `_do_move` — add boundary check (BUG-5a)**

**Current:**
```gdscript
func _do_move(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	for u in state.encounter_units:
		if u.get("pos") == target: return   # occupied
	unit["pos"] = target
	_end_player_turn(unit)
```

**Replace with:**
```gdscript
func _do_move(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	if not _is_in_map(target): return        # BUG-5a: out of bounds
	for u in state.encounter_units:
		if u.get("pos") == target: return    # occupied
	unit["pos"] = target
	_end_player_turn(unit)
```

- [ ] **Step 5: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

---

## Task 4: Fix Spawn Positions in `encounter_system.gd` (BUG-16)

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:4` (constants area), `scripts/simulation/encounter_system.gd:166-172` (_get_edge_entry_positions), `scripts/simulation/encounter_system.gd:174-195` (_get_edge_hexes), `scripts/simulation/encounter_system.gd:212-242` (init_encounter), `scripts/simulation/encounter_system.gd:814-838` (_spawn_team_units)

- [ ] **Step 1: Add SPAWN_RADIUS constant (after line 4, in constants block)**

Add after `const ANON_UNIT_CAP`:
```gdscript
const SPAWN_RADIUS: int = 8    # Units spawn here; MAP_RADIUS-4 buffer to map edge
```

- [ ] **Step 2: Extend `_get_edge_hexes` with optional radius param (lines 174–195)**

**Current:**
```gdscript
func _get_edge_hexes(edge: int) -> Array:
	var result: Array = []
	match edge:
		0:  for x in range(0, MAP_RADIUS + 1):  result.append(Vector2i(x, -MAP_RADIUS))
		1:  for y in range(-MAP_RADIUS, 1):      result.append(Vector2i(MAP_RADIUS, y))
		2:  for x in range(0, MAP_RADIUS + 1):  result.append(Vector2i(x, MAP_RADIUS - x))
		3:  for x in range(-MAP_RADIUS, 1):     result.append(Vector2i(x, MAP_RADIUS))
		4:  for y in range(0, MAP_RADIUS + 1):  result.append(Vector2i(-MAP_RADIUS, y))
		5:  for x in range(-MAP_RADIUS, 1):     result.append(Vector2i(x, -MAP_RADIUS - x))
	return result
```

**Replace with:**
```gdscript
func _get_edge_hexes(edge: int, radius: int = MAP_RADIUS) -> Array:
	var result: Array = []
	var R: int = radius
	match edge:
		0:  for x in range(0, R + 1):   result.append(Vector2i(x, -R))
		1:  for y in range(-R, 1):       result.append(Vector2i(R, y))
		2:  for x in range(0, R + 1):   result.append(Vector2i(x, R - x))
		3:  for x in range(-R, 1):      result.append(Vector2i(x, R))
		4:  for y in range(0, R + 1):   result.append(Vector2i(-R, y))
		5:  for x in range(-R, 1):      result.append(Vector2i(x, -R - x))
	return result
```

- [ ] **Step 3: Add `_get_spawn_positions` helper (add after `_get_edge_hexes`)**

```gdscript
func _get_spawn_positions(side: int, count: int) -> Array:
	# side=0: edges 5,0,1 (upper); side=1: edges 2,3,4 (lower)
	# At SPAWN_RADIUS=8, each edge has 9 hexes → 3 edges = 27 hexes total per side
	var edges: Array = [5, 0, 1] if side == 0 else [2, 3, 4]
	var positions: Array = []
	for e in edges:
		positions += _get_edge_hexes(e, SPAWN_RADIUS)
	positions.shuffle()
	return positions.slice(0, mini(count, positions.size()))
```

- [ ] **Step 4: Update `init_encounter` to use `_get_spawn_positions` (lines 233–239)**

**Current:**
```gdscript
else:
	var atk_anon: int = mini(int(float(atk.population) * atk.armed_anon_ratio), ANON_UNIT_CAP)
	var def_anon: int = mini(int(float(def.population) * def.armed_anon_ratio), ANON_UNIT_CAP)
	var atk_pos := _get_edge_entry_positions(0, atk.named_members.size() + 1 + atk_anon)
	var def_pos := _get_edge_entry_positions(3, def.named_members.size() + 1 + def_anon)
	_spawn_team_units(state, atk, atk_pos)
	_spawn_team_units(state, def, def_pos)
```

**Replace with:**
```gdscript
else:
	var atk_anon: int = mini(int(float(atk.population) * atk.armed_anon_ratio), ANON_UNIT_CAP)
	var def_anon: int = mini(int(float(def.population) * def.armed_anon_ratio), ANON_UNIT_CAP)
	var total_atk: int = atk.named_members.size() + 1 + atk_anon
	var total_def: int = def.named_members.size() + 1 + def_anon
	var atk_pos: Array = _get_spawn_positions(0, total_atk)
	var def_pos: Array = _get_spawn_positions(1, total_def)
	_spawn_team_units(state, atk, atk_pos)
	_spawn_team_units(state, def, def_pos)
```

Also update the pursuit branch (lines 229–232) to use SPAWN_RADIUS for attacker:
```gdscript
var atk_positions: Array = []
for e in edges:
	atk_positions += _get_edge_hexes(e, SPAWN_RADIUS)   # was: no radius arg
atk_positions.shuffle()
```

- [ ] **Step 5: Fix `_spawn_team_units` — remove `%` wrapping (lines 821, 831)**

**Current (line 821):**
```gdscript
var pos: Vector2i = positions[pos_idx % positions.size()]
```
(appears twice — once for named, once for anon)

**Replace both occurrences with bounds check:**

Full replacement for the loop body:
```gdscript
func _spawn_team_units(state: WorldState, team: TeamData,
		positions: Array) -> void:
	var pos_idx: int = 0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		if pos_idx >= positions.size(): break   # no more spawn slots
		var pos: Vector2i = positions[pos_idx]
		pos_idx += 1
		var unit: Dictionary = _create_named_unit(pid, team.team_id, pos, state)
		_init_named_unit(unit, p, team, state)
		state.encounter_units.append(unit)
	var armed_count: int = int(float(team.population) * team.armed_anon_ratio)
	var spawn_count: int = mini(armed_count, ANON_UNIT_CAP)
	for _i in range(spawn_count):
		if pos_idx >= positions.size(): break   # no more spawn slots
		var pos: Vector2i = positions[pos_idx]
		pos_idx += 1
		var unit: Dictionary = _create_anon_unit(team, pos)
		_init_anon_unit(unit, team, state)
		state.encounter_units.append(unit)
	print("[Encounter] Team%d spawn: %d具名 + %d匿名（武裝率%.0f%%，人口%d）" % [
		team.team_id, named_ids.size(), spawn_count,
		team.armed_anon_ratio * 100, team.population])
```

---

## Task 5: Run Tests and Commit

**Files:**
- No new test file needed — existing headless test validates compile + 1000-tick stability

- [ ] **Step 1: Run import to rebuild class cache**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

- [ ] **Step 2: Run headless test suite**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected:
```
[MergeTest] ...ok
[DiploTest] ...ok
[BoundaryTest] ...ok
[MsgPruneTest] message TTL prune ok
[OverflowTest] check_overflow_for_team ok
[SkillTest] SkillSystem.cap_add ok
=== DONE ===
```

Zero `SCRIPT ERROR`. If any encounter-related error appears, check that all `_hex_center` call sites were updated.

- [ ] **Step 3: Commit**

```powershell
git add scripts/ui/encounter_view.gd scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): axial coord rendering + boundary check + inner spawn ring"
```
