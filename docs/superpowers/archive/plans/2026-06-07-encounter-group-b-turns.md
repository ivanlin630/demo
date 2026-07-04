# Encounter Group B — Turn Control Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the broken turn-control chain that causes NPCs to never move (BUG-7: sim_bridge resets player timer to 0 every tick, giving player 10× too many turns) and the missing `_max_timer` key (BUG-6).

**Architecture:** The fix propagates upward through 3 layers:
1. `encounter_system.gd` — detect when player's timer hits 0 with no pending action → return `"player_turn"` early (stop processing remaining units)
2. `sim_runner.gd` — change `advance_tick` return type from `void` to `String`; return encounter result to caller
3. `sim_bridge.gd` — remove manual `action_timer = 0` override; use runner's returned result
4. `encounter_view.gd` — remove `unit["action_timer"] = unit.get("_max_timer", 10)` from `_end_player_turn`

**Tech Stack:** GDScript 4.2, Godot 4.2.2. Headless test: `A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe`

**Bugs fixed:** BUG-7 (sim_bridge timer override), BUG-6 (_max_timer missing key)

**Depends on:** Group A (coordinate fix) is independent — can be done in either order.

---

## File Map

| File | Action |
|---|---|
| `scripts/simulation/encounter_system.gd` | Modify — add player-turn early return |
| `scripts/simulation/sim_runner.gd` | Modify — return String from advance_tick |
| `scripts/ui/sim_bridge.gd` | Modify — use runner result, remove timer override |
| `scripts/ui/encounter_view.gd` | Modify — remove timer reset in _end_player_turn |
| `scripts/debug/headless_test.gd` | Modify — add EncounterTest |

---

## Task 1: Fix `encounter_system.advance_encounter_tick` — Player Turn Detection

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:637-691` (advance_encounter_tick)

Background: The unit processing loop decrements `action_timer`. When player's timer hits 0:
- If no `pending_action` → stop processing, return `"player_turn"` (keep timer at 0)
- If `pending_action` set → process it, erase it, reset timer normally

- [ ] **Step 1: Add player-turn detection block inside the unit loop**

Find the per-unit processing block in `advance_encounter_tick` (around line 650–680). The relevant section currently reads:

```gdscript
		HealthSystem.tick_status_effects(unit, state)
		unit["action_timer"] -= 1
		if unit["action_timer"] > 0: continue

		var action: Dictionary = _decide_action(i, state, -1)
		match action["type"]:
			...
		unit["action_timer"] = _max_timer(unit, state)
```

**Replace with** (insert the player-turn block between timer check and _decide_action):

```gdscript
		HealthSystem.tick_status_effects(unit, state)
		unit["action_timer"] -= 1
		if unit["action_timer"] > 0: continue

		# Player turn: if timer reached 0 and no pending action, stop and wait
		if unit.get("person_id", -1) == state.player_id:
			if unit.get("pending_action", {}).is_empty():
				unit["action_timer"] = 0   # keep at 0; don't go negative
				return "player_turn"
			# Has pending_action — fall through to process it

		var action: Dictionary = _decide_action(i, state, -1)
		match action["type"]:
			...
		# After processing player action, clear pending_action
		if unit.get("person_id", -1) == state.player_id:
			unit.erase("pending_action")
		unit["action_timer"] = _max_timer(unit, state)
```

The `unit.erase("pending_action")` line goes AFTER the full `match action["type"]:` block and BEFORE `unit["action_timer"] = _max_timer(...)`.

- [ ] **Step 2: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

---

## Task 2: Fix `sim_runner.advance_tick` — Return String

**Files:**
- Modify: `scripts/simulation/sim_runner.gd:59-65` (advance_tick)

- [ ] **Step 1: Change return type and propagate encounter result**

**Current:**
```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> void:
	if state.encounter_active:
		var result: String = _encounter_system.advance_encounter_tick(state)
		if result != "ongoing":
			_encounter_system.resolve_encounter_end(state, result)
		_step1_advance_time(state)
		return
```

**Replace with:**
```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> String:
	if state.encounter_active:
		var result: String = _encounter_system.advance_encounter_tick(state)
		if result not in ["ongoing", "player_turn"]:
			_encounter_system.resolve_encounter_end(state, result)
		_step1_advance_time(state)
		return result    # propagate to bridge
```

Also find the `return` at the end of the non-encounter branch and add `return ""`:
The function continues after the encounter block for the world simulation path. Find the end of `advance_tick` and ensure it returns `""` (or `"ongoing"`) for non-encounter ticks:

```gdscript
	# ... rest of world sim code unchanged ...
	return ""   # non-encounter tick
```

- [ ] **Step 2: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

---

## Task 3: Fix `sim_bridge.advance_encounter_tick` — Remove Timer Override

**Files:**
- Modify: `scripts/ui/sim_bridge.gd:63-75`

- [ ] **Step 1: Replace the full function**

**Current:**
```gdscript
func advance_encounter_tick() -> String:
	if not _state.encounter_active:
		return "no_encounter"
	var player_pos: Vector2i = _player_tile()
	_runner.advance_tick(_state, player_pos)
	if not _state.encounter_active:
		return "encounter_ended"
	# Reset player's timer to 0 after each round so UI gets a turn
	for unit in _state.encounter_units:
		if unit.get("person_id", -1) == _state.player_id:
			unit["action_timer"] = 0
			return "player_turn"
	return "ongoing"
```

**Replace with:**
```gdscript
func advance_encounter_tick() -> String:
	if not _state.encounter_active:
		return "no_encounter"
	var player_pos: Vector2i = _player_tile()
	var enc_result: String = _runner.advance_tick(_state, player_pos)
	# Translate encounter_system result to view-facing result
	match enc_result:
		"player_turn":
			return "player_turn"
		"attacker_win", "defender_win", "draw":
			return "encounter_ended"
		_:
			if not _state.encounter_active:
				return "encounter_ended"
			return "ongoing"
```

- [ ] **Step 2: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

---

## Task 4: Fix `encounter_view._end_player_turn` — Remove Bogus Timer Reset (BUG-6)

**Files:**
- Modify: `scripts/ui/encounter_view.gd:308-311` (_end_player_turn)

- [ ] **Step 1: Remove timer reset**

**Current:**
```gdscript
func _end_player_turn(unit: Dictionary) -> void:
	unit["action_timer"] = unit.get("_max_timer", 10)
	_waiting_for_player = false
	_advance_until_player_or_end()
```

**Replace with:**
```gdscript
func _end_player_turn(unit: Dictionary) -> void:
	# Timer reset handled by encounter_system._max_timer() after action processed
	_waiting_for_player = false
	_advance_until_player_or_end()
```

- [ ] **Step 2: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

---

## Task 5: Add `[EncounterTest]` to headless_test.gd

**Files:**
- Modify: `scripts/debug/headless_test.gd` — add before `print("=== DONE ===")`

- [ ] **Step 1: Add encounter system unit tests**

Add this block immediately before `print("=== DONE ===")`:

```gdscript
# ── encounter system test ────────────────────────────────────────────────
var _enc_sys := EncounterSystem.new()

# hex_dist correctness
assert(_enc_sys.hex_dist(Vector2i(0,0), Vector2i(3,0)) == 3,
	"[EncounterTest] hex_dist(0,0→3,0) should be 3")
assert(_enc_sys.hex_dist(Vector2i(0,0), Vector2i(2,-2)) == 2,
	"[EncounterTest] hex_dist diagonal should be 2")
assert(_enc_sys.hex_dist(Vector2i(1,2), Vector2i(-1,2)) == 2,
	"[EncounterTest] hex_dist negative q should be 2")

# _all_exited with prisoner: prisoner should be ignored (not block the "all exited" result)
var _enc_state2 := WorldState.new()
_enc_state2.encounter_attacker_id = 10
_enc_state2.encounter_defender_id = 11
# Add one prisoner unit from team 11
var _prisoner_bp: Dictionary = _enc_sys._default_body_parts()
var _prisoner_unit: Dictionary = {
	"team_id": 11, "person_id": -1, "pos": Vector2i(0, 0),
	"has_exited": false, "is_prisoner": true, "body_parts": _prisoner_bp,
}
_enc_state2.encounter_units.append(_prisoner_unit)
# _all_exited should return true (prisoner ignored → team 11 has no active non-prisoner, non-dead units)
assert(_enc_sys._all_exited(11, _enc_state2) == true,
	"[EncounterTest] _all_exited must exclude prisoners")

# _count_nearby_enemies should exclude prisoners
var _guard_unit: Dictionary = {
	"team_id": 10, "person_id": -1, "pos": Vector2i(1, 0),
	"has_exited": false, "is_prisoner": false, "body_parts": _enc_sys._default_body_parts(),
}
_enc_state2.encounter_units.append(_guard_unit)
# prisoner at (0,0) adjacent to guard at (1,0). Count nearby enemies of prisoner:
assert(_enc_sys._count_nearby_enemies(_prisoner_unit, _enc_state2, 1) == 0,
	"[EncounterTest] _count_nearby_enemies must not count guard as enemy of prisoner (is_prisoner filter)")

print("[EncounterTest] encounter logic ok")
```

**Note on `_count_nearby_enemies` test:** This test will FAIL until Group C BUG-B fix is applied (`_count_nearby_enemies` excluding prisoners). That is intentional — it confirms the bug exists. The test will pass after Group C.

If you want the test to pass NOW without Group C: temporarily remove the `_count_nearby_enemies` assert, or add the `is_prisoner` filter to `_count_nearby_enemies` as part of this task.

- [ ] **Step 2: Run full test suite**

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
[EncounterTest] encounter logic ok
=== DONE ===
```

Zero `SCRIPT ERROR`. The `_count_nearby_enemies` assert may fail if Group C hasn't been applied yet — remove it temporarily in that case.

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/simulation/sim_runner.gd scripts/ui/sim_bridge.gd scripts/ui/encounter_view.gd scripts/debug/headless_test.gd
git commit -m "fix(encounter): turn control — player_turn detection, remove timer override"
```
