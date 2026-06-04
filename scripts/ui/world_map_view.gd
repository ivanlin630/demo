# scripts/ui/world_map_view.gd
extends Node2D

const HEX_W: float    = 60.0
const HEX_H: float    = 52.0
const COL_STEP: float = 45.0   # HEX_W × 0.75
const ODD_OFF: float  = 26.0   # HEX_H × 0.5

const TERRAIN_COLOR: Dictionary = {
	"plains":   Color(0.3, 0.65, 0.3),
	"forest":   Color(0.1, 0.4, 0.15),
	"mountain": Color(0.55, 0.55, 0.55),
}
const FOG_COLOR:    Color = Color(0.04, 0.04, 0.04, 0.88)
const BORDER_COLOR: Color = Color(0.0, 0.0, 0.0, 0.5)

var _bridge: SimBridge
var _camera: Vector2   = Vector2.ZERO
var _zoom:   float     = 1.0
var _selected: Vector2i = Vector2i(-1, -1)
var _cached_tiles: Dictionary = {}   # tile_key(int) → render dict
var _cached_teams: Array = []        # from query_visible_teams_render
var _render_ctx: Dictionary = {}     # player_tile_pos, discovered_team_positions, vision_radius

const SCROLL_SPEED: float = 8.0
var _scroll_keys: Dictionary = {
	KEY_W: Vector2( 0,  1),
	KEY_A: Vector2( 1,  0),
	KEY_S: Vector2( 0, -1),
	KEY_D: Vector2(-1,  0),
}
signal tile_selected(pos: Vector2i)

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_refresh_cache()
	_center_on_player()
	queue_redraw()

func _refresh_cache() -> void:
	if _bridge == null: return
	_cached_tiles = _bridge.query_world_tiles()
	_cached_teams = _bridge.query_visible_teams_render()
	_render_ctx   = _bridge.query_render_context()

func refresh() -> void:
	_refresh_cache()
	queue_redraw()

func _center_on_player() -> void:
	if _bridge == null: return
	var pos: Vector2i = _bridge.get_player_tile_pos()
	var wc: Vector2 = _hex_center(pos.x, pos.y)
	var vsize: Vector2 = get_viewport_rect().size
	_camera = vsize * 0.5 - wc * _zoom

# ── hex coordinate helpers ────────────────────────────────

func _hex_center(col: int, row: int) -> Vector2:
	return Vector2(
		col * COL_STEP + HEX_W * 0.5,
		row * HEX_H + (col % 2) * ODD_OFF + HEX_H * 0.5
	)

func _hex_points(cx: float, cy: float) -> PackedVector2Array:
	var z: float = _zoom
	return PackedVector2Array([
		Vector2(cx - 15*z, cy - 26*z), Vector2(cx + 15*z, cy - 26*z),
		Vector2(cx + 30*z, cy),        Vector2(cx + 15*z, cy + 26*z),
		Vector2(cx - 15*z, cy + 26*z), Vector2(cx - 30*z, cy),
	])

func _world_to_screen(world_pos: Vector2) -> Vector2:
	return world_pos * _zoom + _camera

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return (screen_pos - _camera) / _zoom

func pixel_to_hex(screen_pos: Vector2) -> Vector2i:
	var w: Vector2 = _screen_to_world(screen_pos)
	var col: int = int(w.x / COL_STEP)
	var best: Vector2i = Vector2i(col, 0)
	var best_d: float  = INF
	for dc in [-1, 0, 1]:
		var c: int = col + dc
		if c < 0: continue
		var off_y: float = (c % 2) * ODD_OFF
		var row: int = int((w.y - off_y) / HEX_H)
		for dr in [-1, 0, 1]:
			var r: int = row + dr
			if r < 0: continue
			var center: Vector2 = _hex_center(c, r)
			var d: float = w.distance_to(center)
			if d < best_d:
				best_d = d
				best = Vector2i(c, r)
	return best

# ── drawing ───────────────────────────────────────────────

func _draw() -> void:
	if _bridge == null: return
	var player_pos: Vector2i = _render_ctx.get("player_tile_pos", Vector2i(-1, -1))
	var disc_positions: Array = _render_ctx.get("discovered_team_positions", [])
	var vision_r: int = _render_ctx.get("vision_radius", 3)

	# draw tiles
	for key in _cached_tiles:
		var tile_data: Dictionary = _cached_tiles[key]
		var tpos: Vector2i = tile_data.get("tile_pos", Vector2i(-1, -1))
		var center: Vector2 = _world_to_screen(_hex_center(tpos.x, tpos.y))
		var pts: PackedVector2Array = _hex_points(center.x, center.y)

		var base_color: Color = TERRAIN_COLOR.get(tile_data.get("terrain", ""), Color(0.5, 0.5, 0.5))
		draw_colored_polygon(pts, base_color)
		draw_polyline(pts + PackedVector2Array([pts[0]]), BORDER_COLOR, 1.0)

		if not _is_tile_visible(tpos, player_pos, disc_positions, vision_r):
			draw_colored_polygon(pts, FOG_COLOR)

	# draw teams
	var player_faction_id: int = -1
	for td in _cached_teams:
		if td.get("is_player", false):
			player_faction_id = td.get("faction_id", -1)
			break

	for team_data in _cached_teams:
		var tpos2: Vector2i = team_data.get("tile_pos", Vector2i(-1, -1))
		var center: Vector2 = _world_to_screen(_hex_center(tpos2.x, tpos2.y))
		var is_player: bool = team_data.get("is_player", false)
		var draw_mode: String = team_data.get("draw_mode", "current")

		if draw_mode == "ghost":
			draw_circle(center, 8.0 * _zoom, Color(0.5, 0.5, 0.5, 0.6))
			continue

		var faction_id: int = team_data.get("faction_id", -1)
		var is_hostile: bool = team_data.get("is_hostile", false)
		var border: Color
		if is_hostile:
			border = Color.RED
		elif is_player:
			border = Color.DODGER_BLUE
		elif faction_id >= 0 and faction_id == player_faction_id:
			border = Color.GREEN
		elif faction_id >= 0:
			border = Color.YELLOW
		else:
			border = Color(0.7, 0.7, 0.7)

		draw_circle(center, 10.0 * _zoom, border)
		if is_player:
			draw_circle(center, 6.0 * _zoom, Color.WHITE)

	# draw selected highlight
	if _selected.x >= 0:
		var center: Vector2 = _world_to_screen(_hex_center(_selected.x, _selected.y))
		var pts: PackedVector2Array = _hex_points(center.x, center.y)
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color.WHITE, 2.0)

func _is_tile_visible(pos: Vector2i, player_pos: Vector2i,
		disc_positions: Array, vision_r: int) -> bool:
	if pos == player_pos: return true
	var dx: int = pos.x - player_pos.x
	var dy: int = pos.y - player_pos.y
	if (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= vision_r: return true
	for dpos in disc_positions:
		if (dpos as Vector2i) == pos: return true
	return false

func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	for key in _scroll_keys:
		if Input.is_key_pressed(key):
			dir += _scroll_keys[key]
	if dir != Vector2.ZERO:
		_camera += dir * SCROLL_SPEED * (1.0 / _zoom)
		queue_redraw()
	if Input.is_key_pressed(KEY_H):
		_center_on_player()
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var hex: Vector2i = pixel_to_hex(get_local_mouse_position())
			_selected = hex
			queue_redraw()
			tile_selected.emit(hex)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom = minf(_zoom * 1.1, 4.0)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom = maxf(_zoom / 1.1, 0.3)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_selected = Vector2i(-1, -1)
			queue_redraw()
