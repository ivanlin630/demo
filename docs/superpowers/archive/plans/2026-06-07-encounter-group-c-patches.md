# Encounter Group C — Bug Patches Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 13 confirmed logic bugs across encounter system, UI, and health system. No new features — surgical patches only.

**Architecture:** Patches are independent of each other and touch well-isolated locations. Execute tasks in order; each task commits its own changes.

**Tech Stack:** GDScript 4.2, Godot 4.2.2. Headless test: `A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe`

**Bugs fixed:** BUG-1, BUG-3 (already partially fixed by Group A), BUG-4, BUG-5b, BUG-8, BUG-9, BUG-10, BUG-11, BUG-12, BUG-13, BUG-14, BUG-15, BUG-B

**Depends on:** Group A (must be applied first — Group A fixes spawn dedup and axial movement; Group C builds on that)

---

## File Map

| File | Action |
|---|---|
| `scripts/ui/text_ui_main.gd` | Modify — BUG-1: guard Q key during encounter |
| `scripts/simulation/encounter_system.gd` | Modify — BUG-4, 5b, 8, 10, 15, B |
| `scripts/ui/encounter_view.gd` | Modify — BUG-9, 12, 13, 14 |
| `scripts/simulation/health_system.gd` | Modify — BUG-11 |

---

## Task 1: BUG-1 — Q Key Exits Game During Encounter

**Files:**
- Modify: `scripts/ui/text_ui_main.gd:269-270`

Background: `text_ui_main.gd` extends Node and handles input globally. `encounter_view.gd` extends Control and handles Q as northwest movement. Both receive input simultaneously. When encounter is active, text_ui_main must not process Q.

- [ ] **Step 1: Guard Q key with encounter check**

**Current (line 269–270):**
```gdscript
		KEY_Q:
			get_tree().quit()
```

**Replace with:**
```gdscript
		KEY_Q:
			if _bridge != null and _bridge.get_state().encounter_active:
				pass    # encounter_view handles Q as northwest movement
			else:
				get_tree().quit()
```

- [ ] **Step 2: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

- [ ] **Step 3: Commit**

```powershell
git add scripts/ui/text_ui_main.gd
git commit -m "fix(encounter): guard Q key in text_ui_main during encounter (BUG-1)"
```

---

## Task 2: BUG-4 — NPC Move Teleports to Target Position

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:416` (_decide_action move branch)
- Modify: `scripts/simulation/encounter_system.gd:358-360` (escort_move)

Background: `_decide_action` sets `"move_to": target["pos"]` — the target's actual position — instead of one step toward it. When `advance_encounter_tick` applies the move, `unit["pos"] = action["move_to"]` teleports the unit.

- [ ] **Step 1: Add `_calc_next_step` helper to `encounter_system.gd`**

Add after `_calc_retreat_dir` (around line 441):

```gdscript
func _calc_next_step(from: Vector2i, to: Vector2i) -> Vector2i:
	# Returns one axial step from `from` toward `to`
	const DIRS: Array = [
		Vector2i( 1,  0), Vector2i(-1,  0),
		Vector2i( 0,  1), Vector2i( 0, -1),
		Vector2i( 1, -1), Vector2i(-1,  1),
	]
	var best: Vector2i = from
	var best_dist: int = hex_dist(from, to)
	for d in DIRS:
		var candidate: Vector2i = from + d
		var dist: int = hex_dist(candidate, to)
		if dist < best_dist:
			best_dist = dist
			best = candidate
	return best
```

- [ ] **Step 2: Fix `move` action in `_decide_action` (line 416–417)**

**Current:**
```gdscript
	return { "type": "move", "target_idx": nearest,
		"move_to": target["pos"], "attack_part": "" }
```

**Replace with:**
```gdscript
	return { "type": "move", "target_idx": nearest,
		"move_to": _calc_next_step(unit["pos"], target["pos"]), "attack_part": "" }
```

- [ ] **Step 3: Fix `start_escort` action (line 358–359)**

**Current:**
```gdscript
		return { "type": "start_escort", "target_idx": escort_idx,
			"move_to": state.encounter_units[escort_idx]["pos"], "attack_part": "" }
```

**Replace with:**
```gdscript
		return { "type": "start_escort", "target_idx": escort_idx,
			"move_to": _calc_next_step(unit["pos"], state.encounter_units[escort_idx]["pos"]),
			"attack_part": "" }
```

- [ ] **Step 4: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): NPC move uses _calc_next_step, not teleport (BUG-4)"
```

---

## Task 3: BUG-5b and BUG-15 — NPC Move: Boundary Check + Occupancy Check

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:663-667` (move branch in advance_encounter_tick)

Background: Two bugs at the same location:
- BUG-5b: `unit["pos"] = action["move_to"]` never checks `_is_in_map` → unit can exit map unexpectedly
- BUG-15: No occupancy check → multiple NPCs can stack on same hex

- [ ] **Step 1: Add boundary + occupancy guards to move branch**

Find the `"move", "move_back", "escort_move", "start_escort":` match arm in `advance_encounter_tick` (around line 663):

**Current:**
```gdscript
			"move", "move_back", "escort_move", "start_escort":
				var drain_mult: float = HealthSystem.get_weight_stamina_drain_mult(unit, state)
				var stamina_cost: float = STANCE_MOVE_STAMINA.get(unit.get("stance", "walk"), 0.02)
				unit["pos"]     = action["move_to"]
				unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - stamina_cost * drain_mult, 0.0)
```

**Replace with:**
```gdscript
			"move", "move_back", "escort_move", "start_escort":
				var drain_mult: float = HealthSystem.get_weight_stamina_drain_mult(unit, state)
				var stamina_cost: float = STANCE_MOVE_STAMINA.get(unit.get("stance", "walk"), 0.02)
				var move_target: Vector2i = action["move_to"]
				# BUG-5b: boundary check
				if _is_in_map(move_target):
					# BUG-15: occupancy check (skip dead/exited units)
					var occupied: bool = false
					for other in state.encounter_units:
						if other == unit: continue
						if is_dead(other, state) or other.get("has_exited", false): continue
						if other.get("pos") == move_target:
							occupied = true; break
					if not occupied:
						unit["pos"] = move_target
				unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - stamina_cost * drain_mult, 0.0)
```

- [ ] **Step 2: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): NPC move boundary + occupancy checks (BUG-5b, BUG-15)"
```

---

## Task 4: BUG-8 and BUG-10 — Prisoner Breaks Win Condition; Draw Assigns Wrong Winner

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:705-711` (_all_exited)
- Modify: `scripts/simulation/encounter_system.gd:880-881` (resolve_encounter_end)

Background:
- BUG-8: `_all_exited` doesn't exclude `is_prisoner` units. Prisoners count as "still on field" → team never considered all-exited → prevents win condition.
- BUG-10: `resolve_encounter_end` when result is `"draw"` falls through to `winner_id = def_id`, incorrectly running prisoner/loot logic with defender as winner.

- [ ] **Step 1: Fix `_all_exited` — exclude prisoners (lines 705–711)**

**Current:**
```gdscript
func _all_exited(team_id: int, state: WorldState) -> bool:
	var had_units: bool = false
	for u in state.encounter_units:
		if u["team_id"] != team_id: continue
		had_units = true
		if not is_dead(u, state) and not u.get("has_exited", false): return false
	return had_units
```

**Replace with:**
```gdscript
func _all_exited(team_id: int, state: WorldState) -> bool:
	var had_units: bool = false
	for u in state.encounter_units:
		if u["team_id"] != team_id: continue
		had_units = true
		if u.get("is_prisoner", false): continue   # BUG-8: prisoners don't block all_exited
		if not is_dead(u, state) and not u.get("has_exited", false): return false
	return had_units
```

- [ ] **Step 2: Fix `resolve_encounter_end` — guard draw result (around line 880)**

**Current:**
```gdscript
	var winner_id: int = atk_id if result == "attacker_win" else def_id
	var loser_id: int  = def_id if result == "attacker_win" else atk_id
	var winner_team: TeamData = state.teams.get(winner_id)
	# 新：俘虜存入 prisoner_population...
	for u in state.encounter_units:
		...
```

**Replace the winner/loser assignment block with:**
```gdscript
	# BUG-10: "draw" has no winner; skip prisoner/loot logic
	if result == "draw":
		for team_id in [atk_id, def_id]:
			var t: TeamData = state.teams.get(team_id)
			if t: t.combat_target = -1
		print("[Encounter] 遭遇戰結算完成 result=%s" % result)
		return

	var winner_id: int = atk_id if result == "attacker_win" else def_id
	var loser_id: int  = def_id if result == "attacker_win" else atk_id
	var winner_team: TeamData = state.teams.get(winner_id)
	# ... rest of prisoner/loot logic unchanged ...
```

- [ ] **Step 3: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): _all_exited excludes prisoners; draw skips winner logic (BUG-8, BUG-10)"
```

---

## Task 5: BUG-B — `_count_nearby_enemies` Counts Prisoners

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:252-260` (_count_nearby_enemies)

Background: A prisoner unit counts as an "enemy" for capture threshold check, allowing chain-capture of groups of prisoners.

- [ ] **Step 1: Add prisoner exclusion**

**Current:**
```gdscript
func _count_nearby_enemies(unit: Dictionary, state: WorldState,
		range_hex: int) -> int:
	var count: int = 0
	for other in state.encounter_units:
		if other["team_id"] == unit["team_id"]: continue
		if is_dead(other, state) or other.get("has_exited", false): continue
		if hex_dist(unit["pos"], other["pos"]) <= range_hex:
			count += 1
	return count
```

**Replace with:**
```gdscript
func _count_nearby_enemies(unit: Dictionary, state: WorldState,
		range_hex: int) -> int:
	var count: int = 0
	for other in state.encounter_units:
		if other["team_id"] == unit["team_id"]: continue
		if is_dead(other, state) or other.get("has_exited", false): continue
		if other.get("is_prisoner", false): continue   # BUG-B: prisoners don't guard
		if hex_dist(unit["pos"], other["pos"]) <= range_hex:
			count += 1
	return count
```

- [ ] **Step 2: Compile + test (BUG-B assertion should now pass)**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `[EncounterTest] encounter logic ok` (if Group B's test was added and had the `_count_nearby_enemies` assert).

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): _count_nearby_enemies excludes prisoners (BUG-B)"
```

---

## Task 6: BUG-9 — Player Health Panel Shows Empty Body Parts

**Files:**
- Modify: `scripts/ui/encounter_view.gd:97-103` (_refresh_ui health section)

Background: Named units store body_parts in `state.persons[pid].body_parts`, not in the unit dict. `player_unit.get("body_parts", {})` always returns `{}` for named player unit.

- [ ] **Step 1: Fix body_parts lookup in `_refresh_ui`**

**Current:**
```gdscript
	# health — using status strings from body_parts
	var lines: Array = []
	var body: Dictionary = player_unit.get("body_parts", {})
	for part in body:
		var s: String = body[part].get("status", "healthy")
		lines.append("%s: %s" % [part, s])
	_lbl_health.text = "\n".join(lines)
```

**Replace with:**
```gdscript
	# health — named units store body_parts in state.persons, not unit dict
	var lines: Array = []
	var pid: int = player_unit.get("person_id", -1)
	var body: Dictionary
	if pid >= 0:
		var p: PersonData = state.persons.get(pid)
		body = p.body_parts if p != null else {}
	else:
		body = player_unit.get("body_parts", {})
	for part in body:
		var s: String = body[part].get("status", "healthy")
		lines.append("%s: %s" % [part, s])
	_lbl_health.text = "\n".join(lines)
```

- [ ] **Step 2: Add `_is_unit_dead` helper (needed for BUG-13 and BUG-14)**

Add this helper after `_find_player_unit`:

```gdscript
func _is_unit_dead(unit: Dictionary, state: WorldState) -> bool:
	var pid: int = unit.get("person_id", -1)
	var bp: Dictionary
	if pid >= 0:
		var p: PersonData = state.persons.get(pid)
		bp = p.body_parts if p != null else {}
	else:
		bp = unit.get("body_parts", {})
	return bp.get("torso", {}).get("status", "healthy") == "severed"
```

- [ ] **Step 3: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/ui/encounter_view.gd
git commit -m "fix(encounter): player body_parts from state.persons; add _is_unit_dead helper (BUG-9)"
```

---

## Task 7: BUG-13 and BUG-14 — Dead Units Block Movement; Player Can Attack Dead Units

**Files:**
- Modify: `scripts/ui/encounter_view.gd:291-301` (_do_move, _do_attack)

Background:
- BUG-13: `_do_move` occupancy check includes dead/exited units → corpses block movement
- BUG-14: `_do_attack` finds enemy unit without checking if dead/exited

- [ ] **Step 1: Fix `_do_move` occupancy check (lines 292–293)**

**Current:**
```gdscript
func _do_move(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	if not _is_in_map(target): return        # BUG-5a already fixed in Group A
	for u in state.encounter_units:
		if u.get("pos") == target: return   # occupied — includes dead units
	unit["pos"] = target
	_end_player_turn(unit)
```

**Replace with:**
```gdscript
func _do_move(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	if not _is_in_map(target): return
	for u in state.encounter_units:
		if _is_unit_dead(u, state) or u.get("has_exited", false): continue   # BUG-13: skip corpses
		if u.get("pos") == target: return   # occupied by live unit
	unit["pos"] = target
	_end_player_turn(unit)
```

- [ ] **Step 2: Fix `_do_attack` dead unit filter (lines 298–301)**

**Current:**
```gdscript
func _do_attack(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	for u in state.encounter_units:
		if u.get("pos") == target and u.get("team_id") != unit.get("team_id"):
			unit["pending_action"] = { "type": "attack", "target_idx": state.encounter_units.find(u) }
			break
	_end_player_turn(unit)
```

**Replace with:**
```gdscript
func _do_attack(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	for u in state.encounter_units:
		if u.get("pos") == target and u.get("team_id") != unit.get("team_id"):
			if _is_unit_dead(u, state) or u.get("has_exited", false): continue   # BUG-14: skip dead
			unit["pending_action"] = { "type": "attack", "target_idx": state.encounter_units.find(u) }
			break
	_end_player_turn(unit)
```

- [ ] **Step 3: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/ui/encounter_view.gd
git commit -m "fix(encounter): dead units don't block movement; attack filters dead targets (BUG-13, BUG-14)"
```

---

## Task 8: BUG-12 — S Key Surrender Intercepts Movement; Reassign to F

**Files:**
- Modify: `scripts/ui/encounter_view.gd:113` (action hints label), `scripts/ui/encounter_view.gd:238-246` (_handle_key surrender check)

Background: S is intercepted by surrender before reaching `HEX_DIRS` movement. Since Group A already has S in the axial HEX_DIRS, we only need to change the surrender key from S to F.

- [ ] **Step 1: Update action hints label (line 113)**

**Current:**
```gdscript
	var action_hints: String = "QWEAD:移動  R:攻擊\nZ:命令  S:投降  Space:待機"
```

**Replace with:**
```gdscript
	var action_hints: String = "QWEASD:移動  R:攻擊\nZ:命令  F:投降  Space:待機"
```

Also update the label in `_build_layout` (line 77):
```gdscript
	_lbl_actions.text = "QWEASD:移動  R:攻擊\nZ:命令  F:投降  Space:待機"
```

- [ ] **Step 2: Change surrender key from S to F in `_handle_key` (lines 238–246)**

**Current:**
```gdscript
			if keycode == KEY_S:
				var state2: WorldState = _bridge.get_state()
				if state2.encounter_active:
					var r := _bridge.command_player("execute_action",
						{"action_id": "surrender_in_encounter",
						 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
					_log(r.get("message", ""))
					_refresh_ui()
					return   # don't fall through to movement
				# else: encounter_active == false, fall through to HEX_DIRS movement below
```

**Replace with:**
```gdscript
			if keycode == KEY_F:   # BUG-12: was KEY_S; S now used for south movement
				var state2: WorldState = _bridge.get_state()
				if state2.encounter_active:
					var r := _bridge.command_player("execute_action",
						{"action_id": "surrender_in_encounter",
						 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
					_log(r.get("message", ""))
					_refresh_ui()
					return
```

Note: Remove the `else:` branch (it was only needed because S had dual purpose). F is only surrender — no fallthrough needed.

- [ ] **Step 3: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/ui/encounter_view.gd
git commit -m "fix(encounter): S=south movement, F=surrender; all 6 movement keys work (BUG-12)"
```

---

## Task 9: BUG-11 — `health_system.gd` Unsafe Team Lookup

**Files:**
- Modify: `scripts/simulation/health_system.gd:156`

- [ ] **Step 1: Fix dict access**

Find line 156 in `health_system.gd`. It reads:
```gdscript
	var team: TeamData = state.teams[team_id]
```

**Replace with:**
```gdscript
	var team: TeamData = state.teams.get(team_id)
```

(The full context: this is inside `resolve_anon_units`. The `team` variable is checked for null right after, so `.get()` returning null is handled correctly.)

- [ ] **Step 2: Run full test suite**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: all tests pass, zero `SCRIPT ERROR`.

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/health_system.gd
git commit -m "fix(encounter): health_system safe team lookup (BUG-11)"
```
