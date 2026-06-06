# scripts/ui/encounter_view.gd
extends Control

signal encounter_ended()

const HEX_SIZE: float      = 26.0   # circumradius; horizontal spacing ≈ 45 px
const MAP_RADIUS_VIEW: int = 12     # must match EncounterSystem.MAP_RADIUS

const TERRAIN_COLOR: Dictionary = {
	"plains":   Color(0.3, 0.65, 0.3),
	"forest":   Color(0.1, 0.4, 0.15),
	"mountain": Color(0.55, 0.55, 0.55),
}

var _bridge: SimBridge
var _camera: Vector2 = Vector2.ZERO
var _zoom:   float   = 1.0
var _cursor: Vector2i = Vector2i(-1, -1)
var _mode:   String  = "idle"
var _waiting_for_player: bool = false

var _lbl_health:      Label
var _lbl_equip:       Label
var _lbl_actions:     Label
var _lbl_cursor_info: Label

var _post_combat: bool = false   # 遭遇戰結束後，等待玩家按 [J] 收編或任意鍵離開

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	visible = false

func show_encounter() -> void:
	visible = true
	_post_combat = false
	# Center camera so axial (0,0) appears at viewport center.
	var vp_size: Vector2 = get_viewport_rect().size
	_camera = vp_size * 0.5 - _hex_center(Vector2i.ZERO) * _zoom
	_refresh_ui()
	queue_redraw()
	_waiting_for_player = false
	_advance_until_player_or_end()

func hide_encounter() -> void:
	visible = false
	encounter_ended.emit()

func _ready() -> void:
	_build_layout()

func _build_layout() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0

	var right := VBoxContainer.new()
	right.name = "RightPanel"
	right.custom_minimum_size = Vector2(210, 0)
	right.anchor_left   = 0.75
	right.anchor_right  = 1.0
	right.anchor_bottom = 1.0
	add_child(right)

	right.add_child(_make_section_label("主角狀態"))
	_lbl_health = Label.new()
	_lbl_health.autowrap_mode = TextServer.AUTOWRAP_WORD
	right.add_child(_lbl_health)

	right.add_child(_make_section_label("裝備"))
	_lbl_equip = Label.new()
	right.add_child(_lbl_equip)

	right.add_child(_make_section_label("行動"))
	_lbl_actions = Label.new()
	_lbl_actions.text = "QWEASD:移動  R:攻擊\nZ:命令  Space:待機"
	right.add_child(_lbl_actions)

	right.add_child(_make_section_label("游標"))
	_lbl_cursor_info = Label.new()
	_lbl_cursor_info.autowrap_mode = TextServer.AUTOWRAP_WORD
	right.add_child(_lbl_cursor_info)

func _make_section_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.modulate = Color.YELLOW
	return lbl

func _refresh_ui() -> void:
	if _bridge == null: return
	var state: WorldState = _bridge.get_state()
	var player_unit: Dictionary = _find_player_unit(state)
	if player_unit.is_empty(): return

	# health — using status strings from body_parts
	var lines: Array = []
	var body: Dictionary = player_unit.get("body_parts", {})
	for part in body:
		var s: String = body[part].get("status", "healthy")
		lines.append("%s: %s" % [part, s])
	_lbl_health.text = "\n".join(lines)

	# equip
	var eq: Dictionary = player_unit.get("equipment", {})
	var rh: Dictionary = eq.get("hand_1", {})
	var lh: Dictionary = eq.get("hand_2", {})
	_lbl_equip.text = "右手: %s\n左手: %s" % [rh.get("grade", "空") if rh.get("type","none") != "none" else "空", lh.get("grade", "空") if lh.get("type","none") != "none" else "空"]

	# action hints
	var state_ui: WorldState = _bridge.get_state()
	var action_hints: String = "QWEAD:移動  R:攻擊\nZ:命令  S:投降  Space:待機"
	if not state_ui.encounter_active and state_ui.last_encounter_result.get("can_subjugate", false):
		action_hints += "\nJ:收編敗者"
	_lbl_actions.text = action_hints

func _find_player_unit(state: WorldState) -> Dictionary:
	for unit in state.encounter_units:
		if unit.get("person_id", -1) == state.player_id:
			return unit
	return {}

# ── hex helpers ───────────────────────────────────────────

func _hex_center(axial: Vector2i) -> Vector2:
	# Pointy-top axial: q=axial.x, r=axial.y
	var q: float = float(axial.x)
	var r: float = float(axial.y)
	return Vector2(
		HEX_SIZE * (1.7321 * q + 0.8660 * r),   # sqrt(3) ≈ 1.7321
		HEX_SIZE * 1.5 * r
	)

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

func _world_to_screen(pos: Vector2) -> Vector2:
	return pos * _zoom + _camera

func _screen_to_world(pos: Vector2) -> Vector2:
	return (pos - _camera) / _zoom

# ── draw ─────────────────────────────────────────────────

func _draw() -> void:
	if _bridge == null or not visible: return
	var state: WorldState = _bridge.get_state()

	# Draw hex circle — MAP_RADIUS_VIEW=12, centered at axial (0,0)
	for row in range(-MAP_RADIUS_VIEW, MAP_RADIUS_VIEW + 1):
		for col in range(-MAP_RADIUS_VIEW, MAP_RADIUS_VIEW + 1):
			if _hex_dist(Vector2i(col, row), Vector2i.ZERO) > MAP_RADIUS_VIEW:
				continue
			var center: Vector2 = _world_to_screen(_hex_center(Vector2i(col, row)))
			var pts: PackedVector2Array = _hex_points(center)
			draw_colored_polygon(pts, Color(0.3, 0.6, 0.3))
			draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0, 0, 0, 0.4), 1.0)

	# Draw units
	for unit in state.encounter_units:
		var pos: Vector2i = unit.get("pos", Vector2i(-1, -1))
		if pos.x < 0: continue
		var center: Vector2 = _world_to_screen(_hex_center(pos))
		var is_player: bool = unit.get("person_id", -1) == state.player_id
		var team_id: int    = unit.get("team_id", -1)
		var attacker_id: int = state.encounter_attacker_id
		var is_enemy: bool  = team_id == attacker_id and not is_player

		var color: Color = Color.DODGER_BLUE if is_player else (Color.RED if is_enemy else Color.GREEN)
		draw_circle(center, 12.0 * _zoom, color)
		if is_player:
			draw_circle(center, 7.0 * _zoom, Color.WHITE)
		if unit.get("is_messenger", false):
			draw_circle(center, 4.0 * _zoom, Color.YELLOW)

	# Draw cursor
	if _cursor.x >= 0:
		var center: Vector2 = _world_to_screen(_hex_center(_cursor))
		var pts: PackedVector2Array = _hex_points(center)
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color.WHITE, 2.0)

# ── player input ─────────────────────────────────────────

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

func _input(event: InputEvent) -> void:
	if not visible or not _waiting_for_player: return
	if event is InputEventKey and event.pressed:
		_handle_key(event.keycode)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom = minf(_zoom * 1.1, 4.0); queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom = maxf(_zoom / 1.1, 0.3); queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click(get_local_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_mode = "idle"; _cursor = Vector2i(-1, -1); queue_redraw()

func _handle_key(keycode: int) -> void:
	# 戰後收編階段：任意鍵離開，[J] 則先收編再離開
	if _post_combat:
		if keycode == KEY_J:
			var r := _bridge.command_player("execute_action",
				{"action_id": "subjugate_enemy",
				 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log(r.get("message", ""))
		_post_combat = false
		_waiting_for_player = false
		hide_encounter()
		return
	var state: WorldState = _bridge.get_state()
	var player_unit: Dictionary = _find_player_unit(state)
	if player_unit.is_empty(): return

	match _mode:
		"idle":
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
			if keycode == KEY_J:
				var state3: WorldState = _bridge.get_state()
				if not state3.encounter_active and state3.last_encounter_result.get("can_subjugate", false):
					var r := _bridge.command_player("execute_action",
						{"action_id": "subjugate_enemy",
						 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
					_log(r.get("message", ""))
			elif HEX_DIRS.has(keycode):
				var cur_pos: Vector2i = player_unit.get("pos", Vector2i.ZERO)
				var target: Vector2i = _hex_neighbor(cur_pos, keycode)
				_do_move(player_unit, target, state)
			elif keycode == KEY_R:
				_mode = "attack_select"
				_cursor = player_unit.get("pos", Vector2i.ZERO)
				queue_redraw()
			elif keycode == KEY_SPACE:
				_do_wait(player_unit)
			elif keycode == KEY_Z:
				_open_command_menu(player_unit, state)
		"attack_select":
			if HEX_DIRS.has(keycode):
				_cursor = _hex_neighbor(_cursor, keycode)
				queue_redraw()
				_lbl_cursor_info.text = _describe_hex(_cursor, state)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
				_do_attack(player_unit, _cursor, state)
				_mode = "idle"; _cursor = Vector2i(-1, -1)

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

func _do_move(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	if not _is_in_map(target): return        # BUG-5a: out of bounds
	for u in state.encounter_units:
		if u.get("pos") == target: return    # occupied
	unit["pos"] = target
	_end_player_turn(unit)

func _do_attack(unit: Dictionary, target: Vector2i, state: WorldState) -> void:
	for u in state.encounter_units:
		if u.get("pos") == target and u.get("team_id") != unit.get("team_id"):
			unit["pending_action"] = { "type": "attack", "target_idx": state.encounter_units.find(u) }
			break
	_end_player_turn(unit)

func _do_wait(unit: Dictionary) -> void:
	unit["pending_action"] = { "type": "wait" }
	_end_player_turn(unit)

func _end_player_turn(unit: Dictionary) -> void:
	# Timer reset handled by encounter_system._max_timer() after action processed
	_waiting_for_player = false
	_advance_until_player_or_end()

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

func _describe_hex(pos: Vector2i, state: WorldState) -> String:
	var lines: Array = ["格(%d,%d)" % [pos.x, pos.y]]
	for u in state.encounter_units:
		if u.get("pos") == pos:
			var pid: int = u.get("person_id", -1)
			var name_str: String = "P%d" % pid if pid >= 0 else "匿名"
			lines.append("單位: %s" % name_str)
	return "\n".join(lines)

# ── command menu + sound range ────────────────────────────

const SOUND_RANGE: int = 3   # TEST VALUE

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x; var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _open_command_menu(player_unit: Dictionary, state: WorldState) -> void:
	var player_pos: Vector2i = player_unit.get("pos", Vector2i.ZERO)
	var player_tid: int      = player_unit.get("team_id", -1)

	var popup := PopupMenu.new()
	popup.name = "CommandMenu"

	for i in range(state.encounter_units.size()):
		var u: Dictionary = state.encounter_units[i]
		if u.get("team_id", -1) != player_tid: continue
		if u.get("person_id", -1) == state.player_id: continue
		var upos: Vector2i = u.get("pos", Vector2i.ZERO)
		var dist: int = _hex_dist(player_pos, upos)
		var pid: int  = u.get("person_id", -1)
		var label: String = "P%d" % pid if pid >= 0 else "匿名%d" % i
		if dist <= SOUND_RANGE:
			popup.add_item("命令 %s..." % label, i)
		else:
			popup.add_item("超出範圍 %s — 派信使" % label, 1000 + i)

	popup.id_pressed.connect(func(id: int): _on_command_selected(id, player_unit, state))
	add_child(popup)
	popup.popup(Rect2(get_viewport().get_mouse_position(), Vector2.ZERO))
	_waiting_for_player = true

func _on_command_selected(id: int, player_unit: Dictionary, state: WorldState) -> void:
	if id >= 1000:
		var target_idx: int = id - 1000
		_dispatch_messenger(player_unit, target_idx, state)
	else:
		_open_sub_command(id, player_unit, state)
	_waiting_for_player = true

func _dispatch_messenger(player_unit: Dictionary, target_idx: int, state: WorldState) -> void:
	var player_tid: int = player_unit.get("team_id", -1)
	for u in state.encounter_units:
		if u.get("team_id", -1) != player_tid: continue
		if u.get("person_id", -1) == state.player_id: continue
		if u.get("is_messenger", false): continue
		if u.get("person_id", -1) < 0: continue
		u["is_messenger"]         = true
		u["messenger_target_idx"] = target_idx
		u["current_order"]        = { "type": "messenger", "target": target_idx }
		print("[Encounter] 派信使 P%d → unit%d" % [u["person_id"], target_idx])
		queue_redraw()
		return
	print("[Encounter] 無可用信使")

func _open_sub_command(unit_idx: int, player_unit: Dictionary, state: WorldState) -> void:
	if unit_idx < 0 or unit_idx >= state.encounter_units.size(): return
	var target_unit: Dictionary = state.encounter_units[unit_idx]
	target_unit["current_order"] = { "type": "follow_player", "target": -1 }
	print("[Encounter] 命令 unit%d 跟隨" % unit_idx)

func _log(msg: String) -> void:
	print("[EncounterView] ", msg)
