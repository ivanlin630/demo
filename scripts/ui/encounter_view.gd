# scripts/ui/encounter_view.gd
extends Control

const HEX_W: float    = 60.0
const HEX_H: float    = 52.0
const COL_STEP: float = 45.0
const ODD_OFF: float  = 26.0

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

var _lbl_health:      Label
var _lbl_equip:       Label
var _lbl_actions:     Label
var _lbl_cursor_info: Label

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	visible = false

func show_encounter() -> void:
	visible = true
	_refresh_ui()
	queue_redraw()

func hide_encounter() -> void:
	visible = false

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
	var rh: Dictionary = eq.get("right_hand", {})
	var lh: Dictionary = eq.get("left_hand", {})
	_lbl_equip.text = "右手: %s\n左手: %s" % [rh.get("grade", "空") if rh.get("type","none") != "none" else "空", lh.get("grade", "空") if lh.get("type","none") != "none" else "空"]

func _find_player_unit(state: WorldState) -> Dictionary:
	for unit in state.encounter_units:
		if unit.get("person_id", -1) == state.player_id:
			return unit
	return {}

# ── hex helpers ───────────────────────────────────────────

func _hex_center(col: int, row: int) -> Vector2:
	return Vector2(col * COL_STEP + HEX_W * 0.5,
				   row * HEX_H + (col % 2) * ODD_OFF + HEX_H * 0.5)

func _hex_points(cx: float, cy: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(cx - 15, cy - 26), Vector2(cx + 15, cy - 26),
		Vector2(cx + 30, cy),      Vector2(cx + 15, cy + 26),
		Vector2(cx - 15, cy + 26), Vector2(cx - 30, cy),
	])

func _world_to_screen(pos: Vector2) -> Vector2:
	return pos * _zoom + _camera

func _screen_to_world(pos: Vector2) -> Vector2:
	return (pos - _camera) / _zoom

# ── draw ─────────────────────────────────────────────────

func _draw() -> void:
	if _bridge == null or not visible: return
	var state: WorldState = _bridge.get_state()

	# Draw 10×10 grid
	for row in range(10):
		for col in range(10):
			var center: Vector2 = _world_to_screen(_hex_center(col, row))
			var pts: PackedVector2Array = _hex_points(center.x, center.y)
			draw_colored_polygon(pts, Color(0.3, 0.6, 0.3))
			draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0, 0, 0, 0.4), 1.0)

	# Draw units
	for unit in state.encounter_units:
		var pos: Vector2i = unit.get("pos", Vector2i(-1, -1))
		if pos.x < 0: continue
		var center: Vector2 = _world_to_screen(_hex_center(pos.x, pos.y))
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
		var center: Vector2 = _world_to_screen(_hex_center(_cursor.x, _cursor.y))
		var pts: PackedVector2Array = _hex_points(center.x, center.y)
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color.WHITE, 2.0)
