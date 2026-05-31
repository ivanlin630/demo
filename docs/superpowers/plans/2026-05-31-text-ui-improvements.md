# Text UI Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix hex map rendering, add cursor bounds, G/M/P/I keys, debug bar, and full status panel to text UI.

**Architecture:** All changes in `scripts/ui/text_ui_main.gd` and `scripts/ui/text_map_renderer.gd`; scene structure updated in `scenes/TextUI.tscn`. No simulation logic changes.

**Tech Stack:** Godot 4.2.2 GDScript, existing PlayerSystem/WorldState APIs.

---

## Files

| Action | File |
|---|---|
| Modify | `scripts/ui/text_map_renderer.gd` |
| Modify | `scripts/debug/map_render_test.gd` |
| Modify | `scenes/TextUI.tscn` |
| Modify | `scripts/ui/text_ui_main.gd` |

---

## Task 1: TextMapRenderer — Axial→Visual Fix

**Files:**
- Modify: `scripts/ui/text_map_renderer.gd`
- Modify: `scripts/debug/map_render_test.gd`

**Background:** Current renderer splits tiles by `(x - xmin) % 2` on raw axial X. Row y=0 only has tiles at x=4..8, so the entire map skews right (parallelogram). Fix: compute `display_col = tile_pos.x + int(floor(float(tile_pos.y - mid_y) / 2.0))`, then split by `(dcol - dcol_min) % 2`.

- [ ] **Step 1: Replace `render()` in `text_map_renderer.gd`**

Replace the entire `render()` function (lines 7–41):

```gdscript
static func render(state: WorldState, player_tid: int, cursor: Vector2i) -> String:
	var player_team: TeamData = state.teams.get(player_tid)
	var player_pos: Vector2i  = player_team.tile_pos if player_team else Vector2i(4, 4)
	var discovered: Array     = state.team_discovered.get(player_tid, [])

	# 找地圖邊界
	var xs: Array = []; var ys: Array = []
	for tile in state.world.tiles.values():
		xs.append(tile.tile_pos.x); ys.append(tile.tile_pos.y)
	if xs.is_empty(): return "（無地圖）"
	var xmin: int = xs.min(); var xmax: int = xs.max()
	var ymin: int = ys.min(); var ymax: int = ys.max()
	var mid_y: int = (ymin + ymax) / 2

	# 建 team 位置查詢表（tile_key → team_id list）
	var team_at: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var k: int = t.tile_pos.x * 1000 + t.tile_pos.y
		if not team_at.has(k): team_at[k] = []
		(team_at[k] as Array).append(tid)

	# 計算 display_col 範圍
	# display_col = tile_pos.x + int(floor(float(tile_pos.y - mid_y) / 2.0))
	var dcol_min: int = 9999; var dcol_max: int = -9999
	for tile in state.world.tiles.values():
		var dcol: int = tile.tile_pos.x + int(floor(float(tile.tile_pos.y - mid_y) / 2.0))
		if dcol < dcol_min: dcol_min = dcol
		if dcol > dcol_max: dcol_max = dcol

	# Render: 每個 display_row 輸出兩個子行
	# 偶數 dcol（相對 dcol_min）→ even_line；奇數 → odd_line（縮排 1 空格）
	var lines: Array = []
	for drow in range(ymin, ymax + 1):
		var even_line: String = ""
		var odd_line:  String = " "
		for dcol in range(dcol_min, dcol_max + 1):
			# 反推 tile_pos：tile_pos.x = dcol - int(floor(float(drow - mid_y) / 2.0))
			var tx: int = dcol - int(floor(float(drow - mid_y) / 2.0))
			var pos := Vector2i(tx, drow)
			var cell := _cell(state, pos, player_pos, player_tid, cursor, discovered, team_at)
			if (dcol - dcol_min) % 2 == 0:
				even_line += cell
			else:
				odd_line += cell
		lines.append(even_line)
		lines.append(odd_line)
	return "\n".join(lines)
```

- [ ] **Step 2: Add assertions to `map_render_test.gd`**

After the existing `print("=== END MAP ===")` line, add:

```gdscript
	# 驗證：radius=4 → ymin=0, ymax=8 → 9 rows × 2 sub-lines = 18 lines
	var lines_arr := map_str.split("\n")
	assert(lines_arr.size() == 18, "地圖應有 18 行，實際: %d" % lines_arr.size())
	# 玩家在 (4,4) = display_row 4 = 第 9 行（index 8），even sub-line
	var center_line: String = lines_arr[8]
	assert(center_line.contains("@"), "中間行應含 '@'，實際: '%s'" % center_line)
	print("=== ASSERTIONS PASSED ===")
```

- [ ] **Step 3: Run map render test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/map_render_test.gd
```

Expected:
- `=== ASSERTIONS PASSED ===`
- No `SCRIPT ERROR`
- Map visually has a diamond/hex shape (top/bottom rows shorter than middle)

- [ ] **Step 4: Commit**

```
git add scripts/ui/text_map_renderer.gd scripts/debug/map_render_test.gd
git commit -m "fix(ui): axial→visual display_col fix in TextMapRenderer"
```

---

## Task 2: Scene Structure Update

**Files:**
- Modify: `scenes/TextUI.tscn`

Add `DebugBar` label (before HBox) and `InputBar` label (before HintLabel). Also update HintLabel text.

- [ ] **Step 1: Replace `scenes/TextUI.tscn`**

Full new content:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/ui/text_ui_main.gd" id="1"]

[node name="TextUI" type="Node"]
script = ExtResource("1")

[node name="VBox" type="VBoxContainer" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0

[node name="DebugBar" type="Label" parent="VBox"]
text = "..."
autowrap_mode = 3

[node name="HBox" type="HBoxContainer" parent="VBox"]
size_flags_vertical = 3

[node name="MapLabel" type="RichTextLabel" parent="VBox/HBox"]
size_flags_horizontal = 3
bbcode_enabled = false
text = "載入中..."

[node name="StateLabel" type="Label" parent="VBox/HBox"]
custom_minimum_size = Vector2(220, 0)
text = "狀態..."
vertical_alignment = 0

[node name="EventLabel" type="Label" parent="VBox"]
text = "事件 log..."
autowrap_mode = 3

[node name="InputBar" type="Label" parent="VBox"]
text = ""

[node name="HintLabel" type="Label" parent="VBox"]
text = "[WASD]游標 [Enter]選中 [M]移動(自動) [Space]+1天 [G]跳N tick [H]回玩家 [P]成員 [I]背包 [Q]離開"
```

- [ ] **Step 2: Add `@onready` refs for new labels in `text_ui_main.gd`**

Replace the three `@onready` lines (lines 13–15):

```gdscript
@onready var _map_label:   RichTextLabel = $VBox/HBox/MapLabel
@onready var _state_label: Label         = $VBox/HBox/StateLabel
@onready var _event_label: Label         = $VBox/EventLabel
@onready var _debug_bar:   Label         = $VBox/DebugBar
@onready var _input_bar:   Label         = $VBox/InputBar
```

- [ ] **Step 3: Run headless test to confirm no crash**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 4: Commit**

```
git add scenes/TextUI.tscn scripts/ui/text_ui_main.gd
git commit -m "feat(ui): add DebugBar + InputBar to TextUI scene"
```

---

## Task 3: Cursor Bounds

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1: Fix `_move_cursor()` to check tile existence**

Replace the current `_move_cursor` function (lines 84–87):

```gdscript
func _move_cursor(delta: Vector2i) -> void:
	var new_pos := _cursor + delta
	var key: int = new_pos.x * 1000 + new_pos.y
	if _state.world.tiles.has(key):
		_cursor = new_pos
	_refresh()
```

- [ ] **Step 2: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`.

- [ ] **Step 3: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "fix(ui): cursor bounds — WASD cannot move outside map tiles"
```

---

## Task 4: G Key — Custom Tick Skip

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1: Add mode variables after existing var declarations**

After `var _events: Array = []` (line 11), add:

```gdscript
var _input_mode: bool   = false   # G key numeric input
var _input_buffer: String = ""
var _member_mode: bool  = false   # P key member panel
var _inv_mode: bool     = false   # I key inventory panel
var _inv_selection: int = -1      # selected slot index in inv panel
```

- [ ] **Step 2: Add `_handle_input_mode()` function**

Add before `_move_cursor()`:

```gdscript
func _handle_input_mode(keycode: int) -> void:
	if keycode >= KEY_0 and keycode <= KEY_9:
		if _input_buffer.length() < 6:
			_input_buffer += str(keycode - KEY_0)
		_input_bar.text = "跳過 tick 數: %s_" % _input_buffer
		return
	match keycode:
		KEY_BACKSPACE:
			if _input_buffer.length() > 0:
				_input_buffer = _input_buffer.left(_input_buffer.length() - 1)
			_input_bar.text = "跳過 tick 數: %s_" % _input_buffer
		KEY_ENTER:
			if _input_buffer.length() > 0 and int(_input_buffer) > 0:
				var n: int = mini(int(_input_buffer), 99999)
				_input_mode = false
				_input_bar.text = ""
				for _i in range(n):
					var evts: Array = _bridge.advance_ticks(1)
					_events.append_array(evts)
				if _events.size() > 100:
					_events = _events.slice(_events.size() - 100)
				_refresh()
		KEY_ESCAPE:
			_input_mode = false
			_input_buffer = ""
			_input_bar.text = ""
			_refresh()
```

- [ ] **Step 3: Update `_input()` to intercept G key and dispatch input mode**

Replace the existing `_input()` function (lines 53–82):

```gdscript
func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return
	# G key numeric input mode — intercepts all keys
	if _input_mode:
		_handle_input_mode(event.keycode)
		return
	match event.keycode:
		KEY_W: _move_cursor(Vector2i(0, -1))
		KEY_S: _move_cursor(Vector2i(0,  1))
		KEY_A: _move_cursor(Vector2i(-1, 0))
		KEY_D: _move_cursor(Vector2i( 1, 0))
		KEY_ENTER:
			_selected = _cursor
			_refresh()
		KEY_M:
			var player_team: TeamData = _state.teams.get(_player_tid)
			if player_team and _state.world.tiles.has(_cursor.x * 1000 + _cursor.y):
				player_team.move_target = _cursor
				_log_event("移動目標設為 (%d,%d)" % [_cursor.x, _cursor.y])
				_refresh()
		KEY_SPACE:
			for _i in range(WorldState.TICKS_PER_DAY):
				var evts: Array = _bridge.advance_ticks(1)
				_events.append_array(evts)
			if _events.size() > 100:
				_events = _events.slice(_events.size() - 100)
			_refresh()
		KEY_G:
			_input_mode = true
			_input_buffer = ""
			_input_bar.text = "跳過 tick 數: _"
		KEY_H:
			var pt: TeamData = _state.teams.get(_player_tid)
			if pt: _cursor = pt.tile_pos
			_refresh()
		KEY_P:
			_member_mode = not _member_mode
			if _inv_mode: _inv_mode = false
			_refresh()
		KEY_I:
			_inv_mode = not _inv_mode
			if _member_mode: _member_mode = false
			_inv_selection = -1
			_refresh()
		KEY_Q:
			get_tree().quit()
```

- [ ] **Step 4: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`.

- [ ] **Step 5: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): G key custom tick skip with numeric input mode"
```

---

## Task 5: M Key — Auto-Advance to Target

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

Replace the old M key handler (which only set move_target) with a full auto-advance loop.

- [ ] **Step 1: Add `_do_move_auto()` function**

Add after `_handle_input_mode()`:

```gdscript
func _do_move_auto() -> void:
	var player_team: TeamData = _state.teams.get(_player_tid)
	if player_team == null: return
	if not _state.world.tiles.has(_cursor.x * 1000 + _cursor.y):
		_log_event("目標格不在地圖內")
		_refresh()
		return
	player_team.move_target = _cursor
	var target: Vector2i = _cursor
	var max_ticks: int = 1000
	var ticks_run: int = 0
	while ticks_run < max_ticks:
		var evts: Array = _bridge.advance_ticks(1)
		_events.append_array(evts)
		ticks_run += 1
		if player_team.tile_pos == target:
			_log_event("Team%d 到達 (%d,%d)" % [_player_tid, target.x, target.y])
			break
		if ticks_run % WorldState.TICKS_PER_DAY == 0:
			_refresh()
	if ticks_run >= max_ticks and player_team.tile_pos != target:
		_log_event("移動逾時（已推進 %d ticks）" % ticks_run)
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)
	_refresh()
```

- [ ] **Step 2: Update M key handler in `_input()` to call `_do_move_auto()`**

In the `_input()` function (just updated in Task 4), replace the `KEY_M` block:

```gdscript
		KEY_M:
			_do_move_auto()
```

- [ ] **Step 3: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`.

- [ ] **Step 4: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): M key auto-advances to target (max 1000 ticks, refresh each day)"
```

---

## Task 6: Debug Bar + Enhanced Status Panel

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1: Add `_get_hp_status()` helper**

Add before `_build_state_str()`:

```gdscript
func _get_hp_status(person: PersonData) -> String:
	var has_severe: bool = false
	var has_wound: bool  = false
	for part in person.body_parts.values():
		var status: String = part.get("status", "healthy")
		if status == "severed" or status == "critical":
			has_severe = true
		elif status == "wounded":
			has_wound = true
	if has_severe: return "重傷"
	if has_wound:  return "輕傷"
	return "正常"
```

- [ ] **Step 2: Add `_visible_team_at()` helper**

Add after `_get_hp_status()`:

```gdscript
func _visible_team_at(tile_key: int) -> int:
	var discovered: Array = _state.team_discovered.get(_player_tid, [])
	for tid in _state.teams:
		if tid == _player_tid: continue
		var t: TeamData = _state.teams[tid]
		if t.tile_pos.x * 1000 + t.tile_pos.y == tile_key and discovered.has(tid):
			return tid
	return -1
```

- [ ] **Step 3: Replace `_build_state_str()`**

Replace the entire function:

```gdscript
func _build_state_str() -> String:
	var pt: TeamData = _state.teams.get(_player_tid)
	if pt == null: return "（無玩家 team）"
	var lines: Array = []

	var faction_name: String = "獨立"
	if pt.faction_id >= 0 and _state.factions.has(pt.faction_id):
		faction_name = "勢力%d" % pt.faction_id
	lines.append("Team%d @ (%d,%d) [%s]" % [_player_tid, pt.tile_pos.x, pt.tile_pos.y, faction_name])
	lines.append("任務: %s  疲勞: %d%%" % [pt.current_task, int(pt.fatigue * 100)])
	lines.append("人口: %d | 未成年: %d" % [pt.population, pt.minor_population])

	# 玩家角色資料（健康 + 技能）
	var player: PersonData = _state.persons.get(_state.player_id)
	if player:
		lines.append("────────────────")
		lines.append("玩家: %s  HP:%s" % [player.person_name, _get_hp_status(player)])
		var skill_parts: Array = []
		for sk in player.skills:
			var sv: float = float(player.skills[sk])
			if sv > 0.01:
				skill_parts.append("%s:%.2f" % [sk, sv])
		if not skill_parts.is_empty():
			lines.append("  " + " ".join(skill_parts))

	# 完整資源
	var res: Dictionary = pt.resources
	lines.append("────────────────")
	lines.append("資源:")
	lines.append("  食:%d 幣:%d 材:%d" % [int(res.get("food", 0)), int(res.get("coin", 0)), int(res.get("material", 0))])
	lines.append("  低武:%d 高武:%d" % [int(res.get("weapon_melee_low", 0)), int(res.get("weapon_melee_high", 0))])
	lines.append("  低甲:%d 高甲:%d" % [int(res.get("armor_low", 0)), int(res.get("armor_high", 0))])
	lines.append("  藥:%d 工:%d" % [int(res.get("medicine", 0)), int(res.get("tools", 0))])

	# 選中格 team 資訊
	if _selected != Vector2i(-1, -1):
		var sel_key: int = _selected.x * 1000 + _selected.y
		var sel_tile = _state.world.tiles.get(sel_key)
		lines.append("────────────────")
		if sel_tile:
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.terrain])
			lines.append("  農:%.0f%%  食:%d" % [sel_tile.productivity * 100, int(sel_tile.resources.get("food", 0))])
			var sel_tid: int = _visible_team_at(sel_key)
			if sel_tid >= 0:
				var sel_t: TeamData = _state.teams[sel_tid]
				var sel_f: String   = "獨立" if sel_t.faction_id < 0 else "勢力%d" % sel_t.faction_id
				lines.append("  Team%d [%s] 人口:%d" % [sel_tid, sel_f, sel_t.population])
		else:
			lines.append("選中: (%d,%d) [無效格]" % [_selected.x, _selected.y])

	lines.append("────────────────")
	lines.append("Tick: %d  (Day %d)" % [
		_state.world.current_tick,
		_state.world.current_tick / WorldState.TICKS_PER_DAY])
	return "\n".join(lines)
```

- [ ] **Step 4: Add `_build_debug_str()` function**

Add after `_build_state_str()`:

```gdscript
func _build_debug_str() -> String:
	var tick: int  = _state.world.current_tick
	var hour: int  = (tick / WorldState.TICKS_PER_HOUR) % 24
	var day: int   = (tick / WorldState.TICKS_PER_DAY) % 30 + 1
	var month: int = (tick / WorldState.TICKS_PER_MONTH) % 12
	var season_names: Array = ["春","春","春","夏","夏","夏","秋","秋","秋","冬","冬","冬"]
	var season: String = season_names[month]
	var lines: Array = []
	lines.append("[DEBUG] Tick:%d Hour:%d Day:%d Month:%d Season:%s" % [tick, hour, day, month + 1, season])

	# Teams
	var team_strs: Array = []
	for tid in _state.teams:
		var t: TeamData = _state.teams[tid]
		team_strs.append("T%d@(%d,%d)pop=%d %s" % [tid, t.tile_pos.x, t.tile_pos.y, t.population, t.current_task])
	lines.append("Teams: " + " | ".join(team_strs))

	# Events last 10
	var evt_strs: Array = []
	for i in range(maxi(0, _events.size() - 10), _events.size()):
		var e = _events[i]
		evt_strs.append("[%s]%s" % [str(e.get("type","?")), str(e.get("msg",""))])
	lines.append("Events(last10): " + " | ".join(evt_strs))

	# Global messages last 10
	var msg_strs: Array = []
	for i in range(maxi(0, _state.global_messages.size() - 10), _state.global_messages.size()):
		msg_strs.append(str(_state.global_messages[i]))
	lines.append("Msgs(last10): " + " | ".join(msg_strs))

	return "\n".join(lines)
```

- [ ] **Step 5: Update `_refresh()` to update `_debug_bar`**

Replace the entire `_refresh()` function:

```gdscript
func _refresh() -> void:
	_map_label.text  = TextMapRenderer.render(_state, _player_tid, _cursor)
	_state_label.text = _build_state_str()
	_debug_bar.text  = _build_debug_str()

	if _member_mode:
		_event_label.text = _build_member_str()
	elif _inv_mode:
		_event_label.text = _build_inv_str()
	else:
		var log_lines: Array = []
		var show_count: int = mini(_events.size(), 6)
		for i in range(_events.size() - show_count, _events.size()):
			var e = _events[i]
			log_lines.append("[T%d] %s" % [_state.world.current_tick, str(e)])
		_event_label.text = "\n".join(log_lines)
```

Note: `_build_member_str()` and `_build_inv_str()` are defined in Task 7. Add stub placeholders for now so the file compiles:

```gdscript
func _build_member_str() -> String:
	return "（成員欄）"

func _build_inv_str() -> String:
	return "（背包欄）"
```

- [ ] **Step 6: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`.

- [ ] **Step 7: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): debug bar + enhanced status panel (HP/skills/full-resources/selected-tile)"
```

---

## Task 7: P Key Member Panel + I Key Inventory Panel

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1: Replace stub `_build_member_str()`**

Replace the stub with:

```gdscript
func _build_member_str() -> String:
	var pt: TeamData = _state.teams.get(_player_tid)
	if pt == null: return "（無玩家 team）"
	var lines: Array = []
	lines.append("── 成員 Team%d ──" % _player_tid)

	var leader: PersonData = _state.persons.get(pt.leader_id)
	if leader:
		var hand1: String = leader.equipment.get("hand_1", {}).get("grade", "")
		if hand1.is_empty(): hand1 = "空"
		lines.append("[隊長] %s  裝備:%s  HP:%s" % [leader.person_name, hand1, _get_hp_status(leader)])

	for pid in pt.named_members:
		var p: PersonData = _state.persons.get(pid)
		if p == null: continue
		var hand1: String = p.equipment.get("hand_1", {}).get("grade", "")
		if hand1.is_empty(): hand1 = "空"
		lines.append("[成員] %s  裝備:%s  HP:%s" % [p.person_name, hand1, _get_hp_status(p)])

	var named_count: int = (1 if pt.leader_id >= 0 else 0) + pt.named_members.size()
	var anon: int = maxi(0, pt.population - named_count)
	var weapons: int = (int(pt.resources.get("weapon_melee_low",   0))
		+ int(pt.resources.get("weapon_melee_high",  0))
		+ int(pt.resources.get("weapon_ranged_low",  0))
		+ int(pt.resources.get("weapon_ranged_high", 0)))
	var armed_rate: float = float(weapons) / maxf(float(pt.population), 1.0)
	lines.append("匿名人口: %d  武裝率: %d%%" % [anon, int(armed_rate * 100)])
	lines.append("── [P/Esc] 關閉 ──")
	return "\n".join(lines)
```

- [ ] **Step 2: Add `_get_team_takeable_items()` helper**

Add before `_build_inv_str()`:

```gdscript
func _get_team_takeable_items(_pt: TeamData) -> Array:
	return ["weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high",
		"armor_low", "armor_high", "medicine", "tools"]
```

- [ ] **Step 3: Replace stub `_build_inv_str()`**

Replace with:

```gdscript
func _build_inv_str() -> String:
	var player: PersonData = _state.persons.get(_state.player_id)
	var pt: TeamData       = _state.teams.get(_player_tid)
	if player == null or pt == null: return "（無資料）"
	var lines: Array = []

	# 裝備
	lines.append("── 裝備 ──")
	var h1: String = player.equipment.get("hand_1", {}).get("grade", "")
	var h2: String = player.equipment.get("hand_2", {}).get("grade", "")
	lines.append("  右手:%s  左手:%s" % [h1 if not h1.is_empty() else "空", h2 if not h2.is_empty() else "空"])
	var body_slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var body_names: Array = ["頭", "胸", "右臂", "左臂", "右腿", "左腿"]
	var body_strs: Array = []
	for i in range(body_slots.size()):
		var g: String = player.equipment.get(body_slots[i], {}).get("grade", "")
		body_strs.append("%s:%s" % [body_names[i], g if not g.is_empty() else "空"])
	lines.append("  " + " ".join(body_strs))

	# 背包
	var inv: Array = _state.player_state.get("inventory", [])
	lines.append("── 背包 (%d/%d) ──" % [inv.size(), PlayerSystem.PLAYER_INVENTORY_MAX_SLOTS])
	for i in range(inv.size()):
		var item = inv[i]
		var prefix: String = "[%d]*" % (i + 1) if _inv_selection == i else "[%d]" % (i + 1)
		lines.append("  %s %s × %d" % [prefix, item.get("grade", "?"), item.get("qty", 0)])

	# Team 取出
	var team_items: Array = _get_team_takeable_items(pt)
	lines.append("── 從 Team 取出 ──")
	for i in range(team_items.size()):
		var idx: int = inv.size() + i
		var prefix: String = "[T%d]*" % (i + 1) if _inv_selection == idx else "[T%d]" % (i + 1)
		var qty: int = int(pt.resources.get(team_items[i], 0))
		lines.append("  %s %s: %d%s" % [prefix, team_items[i], qty, "" if qty > 0 else "（灰）"])

	lines.append("── [數字]選取 [E]裝備 [S]存入 [G]取出 [I/Esc]關閉 ──")
	return "\n".join(lines)
```

- [ ] **Step 4: Add `_handle_inv_mode()` function**

Add after `_handle_input_mode()`:

```gdscript
func _handle_inv_mode(keycode: int) -> void:
	var inv: Array         = _state.player_state.get("inventory", [])
	var pt: TeamData       = _state.teams.get(_player_tid)
	var team_items: Array  = _get_team_takeable_items(pt)
	var player_sys         := PlayerSystem.new()

	if keycode >= KEY_1 and keycode <= KEY_9:
		var num: int  = keycode - KEY_1   # 0-indexed
		var total: int = inv.size() + team_items.size()
		if num < total:
			_inv_selection = num
		_refresh()
		return

	match keycode:
		KEY_E:
			if _inv_selection >= 0 and _inv_selection < inv.size():
				var grade: String = inv[_inv_selection].get("grade", "")
				var slot: String  = "torso" if grade.begins_with("armor") else "hand_1"
				player_sys.equip_item(_state, slot, grade)
				_inv_selection = -1
		KEY_S:
			if _inv_selection >= 0 and _inv_selection < inv.size():
				var grade: String = inv[_inv_selection].get("grade", "")
				var qty: int      = inv[_inv_selection].get("qty", 0)
				player_sys.deposit_to_team(_state, grade, qty)
				_inv_selection = -1
		KEY_G:
			var team_idx: int = _inv_selection - inv.size()
			if team_idx >= 0 and team_idx < team_items.size():
				player_sys.take_from_team(_state, team_items[team_idx], 1)
				_inv_selection = -1
		KEY_I, KEY_ESCAPE:
			_inv_mode = false
			_inv_selection = -1
	_refresh()
```

- [ ] **Step 5: Update `_input()` to dispatch inventory mode**

At the top of `_input()`, after the `_input_mode` check, add inventory mode dispatch:

```gdscript
func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return
	if _input_mode:
		_handle_input_mode(event.keycode)
		return
	if _inv_mode:
		_handle_inv_mode(event.keycode)
		return
	# ... rest of match unchanged
```

Also update the `KEY_P` case to handle Escape for member mode:

```gdscript
		KEY_ESCAPE:
			if _member_mode:
				_member_mode = false
				_refresh()
			elif _inv_mode:
				_inv_mode = false
				_inv_selection = -1
				_refresh()
```

Add `KEY_ESCAPE` to the main `match` block (after `KEY_Q`).

- [ ] **Step 6: Verify `player_state` initialised in `_ready()`**

In `_ready()`, check that `_state.player_state` is initialized (PlayerSystem.init_player is not called in UI, so add manually):

After `_state.player_id = 0`, add:

```gdscript
	_state.player_state = { "inventory": [], "coin": 50.0 }
```

- [ ] **Step 7: Run headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`, no `SCRIPT ERROR`.

- [ ] **Step 8: Run map render test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/map_render_test.gd
```

Expected: `=== ASSERTIONS PASSED ===`.

- [ ] **Step 9: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): P key member panel + I key inventory panel with equip/deposit/take"
```

---

## Final Verification

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/map_render_test.gd
```

Both must pass. Then run headless test for 1000 ticks — confirm `=== DONE ===` with no crash.

---

## Hand-Back Checklist

After implementation:
1. Push branch: `git push -u origin feat/text-ui-improvements`
2. Write hand-back to `docs/superpowers/handbacks/2026-05-31-text-ui-improvements.md`
3. **finishing-a-development-branch skill 彈出選單時選 Option 3（Keep as-is）**
