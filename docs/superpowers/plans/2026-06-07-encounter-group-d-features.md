# Encounter Group D — Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three features: (1) player can select attack body part with ↑↓ arrows; (2) NPC guard logic — idle NPCs move to guard incapacitated enemies; (3) prisoner visual marker + "X 被 Y 俘虜" message.

**Architecture:** All three features are isolated additions with minimal coupling. Attack part selection adds one variable and modifies input handling. Guard logic adds one helper function to `_decide_action`. Prisoner UI adds one draw call and updates `_check_prisoners` message.

**Tech Stack:** GDScript 4.2, Godot 4.2.2. Headless test: `A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe`

**Depends on:** Group C (BUG-12 must be applied — F key is surrender, S is free for movement; attack_select mode should work cleanly before adding part selection).

---

## File Map

| File | Action |
|---|---|
| `scripts/ui/encounter_view.gd` | Modify — attack part selection UI, prisoner visual |
| `scripts/simulation/encounter_system.gd` | Modify — NPC guard logic, prisoner message |

---

## Task 1: Attack Body Part Selection (↑↓ in attack_select mode)

**Files:**
- Modify: `scripts/ui/encounter_view.gd`

Design: In `attack_select` mode, ↑/↓ cycles through 6 body parts displayed in the UI. Enter confirms attack on selected part. The selected part is stored in `_selected_part` instance var and reset when entering attack_select mode.

- [ ] **Step 1: Add instance variable and constants**

Add after existing `var _post_combat: bool = false`:

```gdscript
var _selected_part: String = "torso"   # attack target body part, chosen in attack_select mode

const BODY_PARTS: Array = [
	"head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"
]
```

- [ ] **Step 2: Reset `_selected_part` when entering attack_select mode**

Find in `_handle_key` (inside `"idle"` match arm, around line 259):
```gdscript
			elif keycode == KEY_R:
				_mode = "attack_select"
				_cursor = player_unit.get("pos", Vector2i.ZERO)
				queue_redraw()
```

**Replace with:**
```gdscript
			elif keycode == KEY_R:
				_mode = "attack_select"
				_selected_part = "torso"   # reset to default each time
				_cursor = player_unit.get("pos", Vector2i.ZERO)
				_refresh_ui()
				queue_redraw()
```

- [ ] **Step 3: Add ↑↓ handling in `attack_select` mode**

Find the `"attack_select":` match arm in `_handle_key` (around line 267):

**Current:**
```gdscript
		"attack_select":
			if HEX_DIRS.has(keycode):
				_cursor = _hex_neighbor(_cursor, keycode)
				queue_redraw()
				_lbl_cursor_info.text = _describe_hex(_cursor, state)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
				_do_attack(player_unit, _cursor, state)
				_mode = "idle"; _cursor = Vector2i(-1, -1)
```

**Replace with:**
```gdscript
		"attack_select":
			if keycode == KEY_UP:
				var idx: int = BODY_PARTS.find(_selected_part)
				_selected_part = BODY_PARTS[(idx - 1 + BODY_PARTS.size()) % BODY_PARTS.size()]
				_refresh_ui()
			elif keycode == KEY_DOWN:
				var idx: int = BODY_PARTS.find(_selected_part)
				_selected_part = BODY_PARTS[(idx + 1) % BODY_PARTS.size()]
				_refresh_ui()
			elif HEX_DIRS.has(keycode):
				_cursor = _hex_neighbor(_cursor, keycode)
				queue_redraw()
				_lbl_cursor_info.text = _describe_hex(_cursor, state)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
				_do_attack_with_part(player_unit, _cursor, state, _selected_part)
				_mode = "idle"; _cursor = Vector2i(-1, -1)
				_selected_part = "torso"   # reset after use
```

- [ ] **Step 4: Add `_do_attack_with_part` function**

Replace existing `_do_attack` function (or add new one alongside):

```gdscript
func _do_attack_with_part(unit: Dictionary, target: Vector2i,
		state: WorldState, part: String) -> void:
	for u in state.encounter_units:
		if u.get("pos") == target and u.get("team_id") != unit.get("team_id"):
			if _is_unit_dead(u, state) or u.get("has_exited", false): continue
			unit["pending_action"] = {
				"type": "attack",
				"target_idx": state.encounter_units.find(u),
				"attack_part": part,
			}
			break
	_end_player_turn(unit)
```

Also update the existing `_do_attack` (called from `_handle_click`) to use the selected part:
```gdscript
func _do_attack(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	_do_attack_with_part(unit, target, state, _selected_part)
```

- [ ] **Step 5: Update `_refresh_ui` to show selected part in attack_select mode**

At the end of `_refresh_ui`, add:

```gdscript
	if _mode == "attack_select":
		_lbl_cursor_info.text = "攻擊部位 ↑↓: %s" % _selected_part
```

- [ ] **Step 6: Update `_decide_action` in encounter_system to use player's attack_part**

In `encounter_system._decide_action`, when processing player's `pending_action` (around line 322–329):

**Current:**
```gdscript
			return { "type": "attack", "target_idx": tidx,
				"move_to": tgt["pos"],
				"attack_part": _choose_attack_part(unit, state) }
```

**Replace with:**
```gdscript
			return { "type": "attack", "target_idx": tidx,
				"move_to": tgt["pos"],
				"attack_part": pa.get("attack_part", _choose_attack_part(unit, state)) }
```

This uses the player's chosen part if set, falls back to auto-select if not.

- [ ] **Step 7: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

- [ ] **Step 8: Commit**

```powershell
git add scripts/ui/encounter_view.gd scripts/simulation/encounter_system.gd
git commit -m "feat(encounter): attack part selection with arrow keys in attack_select mode"
```

---

## Task 2: NPC Guard Logic — Idle Units Guard Incapacitated Enemies

**Files:**
- Modify: `scripts/simulation/encounter_system.gd` (_decide_action, add `_find_guard_target`)

Design: At the lowest priority in `_decide_action` (just before returning `"idle"`), check if there's an incapacitated enemy with fewer than 2 guards nearby. If found, move one step toward it.

Trigger condition: unit would otherwise idle AND unit is combat capable AND no combat-capable enemies reachable within 2 hexes (don't interrupt active combat to guard).

- [ ] **Step 1: Add `_find_guard_target` helper**

Add after `_count_nearby_enemies`:

```gdscript
func _find_guard_target(unit: Dictionary, state: WorldState) -> int:
	# Returns index of an incapacitated enemy unit that has < 2 guards; -1 if none
	# Only called when unit has no combat-capable enemies nearby (not interrupting combat)
	for i in range(state.encounter_units.size()):
		var candidate: Dictionary = state.encounter_units[i]
		if candidate["team_id"] == unit["team_id"]: continue
		if is_dead(candidate, state) or candidate.get("has_exited", false): continue
		if is_combat_capable(candidate, state): continue   # target must be incapacitated
		if candidate.get("is_prisoner", false): continue   # already guarded
		# Count how many friendly units are adjacent to this candidate
		var guard_count: int = 0
		for other in state.encounter_units:
			if other["team_id"] != unit["team_id"]: continue
			if is_dead(other, state): continue
			if hex_dist(other["pos"], candidate["pos"]) <= 1:
				guard_count += 1
		if guard_count < 2:
			return i
	return -1
```

- [ ] **Step 2: Add guard logic at end of `_decide_action` (before final idle return)**

Find the final `return { "type": "idle", ... }` in `_decide_action` (around line 390–392):

**Current:**
```gdscript
	var nearest: int = _get_nearest_enemy_index(unit, state)
	if nearest == -1:
		return { "type": "idle", "target_idx": -1,
			"move_to": unit["pos"], "attack_part": "" }
```

**Replace with:**
```gdscript
	var nearest: int = _get_nearest_enemy_index(unit, state)
	if nearest == -1:
		# No combat-capable enemies visible — check if we should guard an incapacitated enemy
		var guard_idx: int = _find_guard_target(unit, state)
		if guard_idx != -1:
			var guard_pos: Vector2i = state.encounter_units[guard_idx]["pos"]
			return { "type": "move", "target_idx": guard_idx,
				"move_to": _calc_next_step(unit["pos"], guard_pos), "attack_part": "" }
		return { "type": "idle", "target_idx": -1,
			"move_to": unit["pos"], "attack_part": "" }
```

Note: `_calc_next_step` was added in Group C Task 2.

- [ ] **Step 3: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/encounter_system.gd
git commit -m "feat(encounter): NPC guard logic — idle units move to guard incapacitated enemies"
```

---

## Task 3: Prisoner Visual Marker + "X 被 Y 俘虜" Message

**Files:**
- Modify: `scripts/ui/encounter_view.gd:161-177` (_draw unit section)
- Modify: `scripts/simulation/encounter_system.gd:455-468` (_check_prisoners)

- [ ] **Step 1: Add prisoner visual marker in `_draw()`**

Find the unit drawing loop in `_draw()` (around line 162–177):

After the existing draw calls (after `draw_circle(center, 4.0 * _zoom, Color.YELLOW)` for messenger), add:

```gdscript
		# Prisoner: orange ring
		if unit.get("is_prisoner", false):
			draw_arc(center, 14.0 * _zoom, 0.0, TAU, 12, Color.ORANGE, 2.0 * _zoom)
```

Full context of where to insert (after the messenger circle):
```gdscript
		if unit.get("is_messenger", false):
			draw_circle(center, 4.0 * _zoom, Color.YELLOW)
		# Prisoner: orange ring around unit
		if unit.get("is_prisoner", false):
			draw_arc(center, 14.0 * _zoom, 0.0, TAU, 12, Color.ORANGE, 2.0 * _zoom)
```

- [ ] **Step 2: Add dead unit visual (grey) — improves readability**

Also in the unit draw loop, add a grey overlay for dead units:

```gdscript
		# Dead: draw as grey (after color circle, over it)
		if _is_unit_dead(unit, state):
			draw_circle(center, 12.0 * _zoom, Color(0.4, 0.4, 0.4, 0.8))
```

Add immediately after the main color circle draws.

- [ ] **Step 3: Fix `_check_prisoners` to output "X 被 Y 俘虜" message**

Find `_check_prisoners` in `encounter_system.gd` (around line 455–468):

**Current:**
```gdscript
		if nearby_enemies >= 2:
			unit["is_prisoner"] = true
			var winner_team_id: int = _get_enemy_team_id(unit["team_id"], state)
			print("[Encounter] Unit(team=%d) 被俘虜，歸入 Team%d" % [
				unit["team_id"], winner_team_id])
```

**Replace with:**
```gdscript
		if nearby_enemies >= 2:
			unit["is_prisoner"] = true
			var winner_team_id: int = _get_enemy_team_id(unit["team_id"], state)
			# Format: "X 被 Y 俘虜"
			var prisoner_name: String
			if unit["person_id"] >= 0:
				var pp: PersonData = state.persons.get(unit["person_id"])
				prisoner_name = pp.name if pp != null else ("Person%d" % unit["person_id"])
			else:
				prisoner_name = "匿名兵(Team%d)" % unit["team_id"]
			var captor_team: TeamData = state.teams.get(winner_team_id)
			var captor_name: String
			if captor_team != null and captor_team.leader_id >= 0:
				var cp: PersonData = state.persons.get(captor_team.leader_id)
				captor_name = ("%s隊" % cp.name) if cp != null else ("Team%d" % winner_team_id)
			else:
				captor_name = "Team%d" % winner_team_id
			print("[Encounter] %s 被 %s 俘虜" % [prisoner_name, captor_name])
```

- [ ] **Step 4: Compile check**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

Expected: no `ERROR`.

- [ ] **Step 5: Run full test suite**

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

Zero `SCRIPT ERROR`.

- [ ] **Step 6: Commit**

```powershell
git add scripts/ui/encounter_view.gd scripts/simulation/encounter_system.gd
git commit -m "feat(encounter): prisoner visual marker, dead unit grey, 'X 被 Y 俘虜' message"
```

---

## Task 4: Hand-back

- [ ] **Step 1: Create hand-back doc**

Create `docs/superpowers/handbacks/2026-06-07-encounter-group-d.md`:

```markdown
# Hand Back: Encounter Group D — Features

## 實作摘要

- 攻擊部位選擇：`attack_select` 模式用 ↑↓ 循環 6 個部位，Enter 確認。`encounter_view` 新增 `_selected_part` var + `BODY_PARTS` 常數 + `_do_attack_with_part()`。`encounter_system._decide_action` 使用 `pa.get("attack_part")` 優先。
- NPC 守衛邏輯：`encounter_system._find_guard_target()` 找需要守衛的失能敵人；`_decide_action` 最末端插入，只在 idle 時觸發，不影響進攻優先權。
- 俘虜視覺：`_draw()` 對 `is_prisoner` 單位畫橙色外環；死亡單位畫灰色遮罩。
- 俘虜訊息：`_check_prisoners` 輸出「X 被 Y 俘虜」，顯示 person.name 或 team leader 名稱。

## 連動風險

- `_do_attack_with_part` 取代 `_do_attack` 的 pending_action 格式，新增 `attack_part` 欄位。encounter_system 的 `_decide_action` 對玩家 pending_action 已更新，相容。
- NPC 守衛移動使用 `"move"` 類型，受 Group C BUG-15 佔位檢查保護，不會疊格。
- `_calc_next_step` 需已被 Group C Task 2 加入，否則守衛邏輯無法編譯。

## 待後續

- 俘虜管理系統（審訊、出售、釋放）
- 玩家失能後遭遇戰系統（玩家被俘虜後的流程）
```

- [ ] **Step 2: Final commit**

```powershell
git add docs/superpowers/handbacks/2026-06-07-encounter-group-d.md
git commit -m "docs: add hand-back for encounter group D features"
```
