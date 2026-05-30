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

const SCROLL_SPEED: float = 8.0
var _scroll_keys: Dictionary = {
	KEY_W: Vector2( 0, -1),
	KEY_A: Vector2(-1,  0),
	KEY_S: Vector2( 0,  1),
	KEY_D: Vector2( 1,  0),
}
signal tile_selected(pos: Vector2i)

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	queue_redraw()

func refresh() -> void:
	queue_redraw()

# ── hex coordinate helpers ────────────────────────────────

func _hex_center(col: int, row: int) -> Vector2:
	return Vector2(
		col * COL_STEP + HEX_W * 0.5,
		row * HEX_H + (col % 2) * ODD_OFF + HEX_H * 0.5
	)

func _hex_points(cx: float, cy: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(cx - 15, cy - 26), Vector2(cx + 15, cy - 26),
		Vector2(cx + 30, cy),      Vector2(cx + 15, cy + 26),
		Vector2(cx - 15, cy + 26), Vector2(cx - 30, cy),
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
	var state: WorldState = _bridge.get_state()
	var player_tid: int   = _bridge.get_player_team_id()
	var discovered: Array = state.team_discovered.get(player_tid, []) if player_tid >= 0 else []

	# draw tiles
	for key in state.world.tiles:
		var tile: HexTileData = state.world.tiles[key]
		var col: int = tile.tile_pos.x
		var row: int = tile.tile_pos.y
		var center: Vector2 = _world_to_screen(_hex_center(col, row))

		var pts: PackedVector2Array = _hex_points(center.x, center.y)
		var is_discovered: bool = _is_tile_discovered(tile.tile_pos, state, player_tid, discovered)

		var base_color: Color = TERRAIN_COLOR.get(tile.terrain, Color(0.5, 0.5, 0.5))
		draw_colored_polygon(pts, base_color)
		draw_polyline(pts + PackedVector2Array([pts[0]]), BORDER_COLOR, 1.0)

		if not is_discovered:
			draw_colored_polygon(pts, FOG_COLOR)

	# draw teams
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if not _is_team_visible(tid, state, player_tid, discovered): continue
		var center: Vector2 = _world_to_screen(_hex_center(team.tile_pos.x, team.tile_pos.y))
		_draw_team_marker(team, tid, center, state, player_tid)

	# draw selected highlight
	if _selected.x >= 0:
		var center: Vector2 = _world_to_screen(_hex_center(_selected.x, _selected.y))
		var pts: PackedVector2Array = _hex_points(center.x, center.y)
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color.WHITE, 2.0)

func _is_tile_discovered(pos: Vector2i, state: WorldState,
		player_tid: int, discovered: Array) -> bool:
	if player_tid < 0: return true
	var player_team: TeamData = state.teams.get(player_tid)
	if player_team == null: return false
	if player_team.tile_pos == pos: return true
	for tid in discovered:
		var t: TeamData = state.teams.get(tid)
		if t and t.tile_pos == pos: return true
	# reveal tiles within vision radius 3
	var dx: int = pos.x - player_team.tile_pos.x
	var dy: int = pos.y - player_team.tile_pos.y
	var dist: int = (abs(dx) + abs(dx + dy) + abs(dy)) / 2
	return dist <= 3

func _is_team_visible(tid: int, state: WorldState,
		player_tid: int, discovered: Array) -> bool:
	if player_tid < 0: return true
	return tid == player_tid or discovered.has(tid)

func _draw_team_marker(team: TeamData, tid: int, center: Vector2,
		state: WorldState, player_tid: int) -> void:
	var border: Color
	if state.player_hostile_teams.has(tid):
		border = Color.RED
	elif player_tid >= 0 and tid == player_tid:
		border = Color.DODGER_BLUE
	elif team.faction_id >= 0:
		var player_team: TeamData = state.teams.get(player_tid)
		if player_team and player_team.faction_id == team.faction_id:
			border = Color.GREEN
		else:
			border = Color.YELLOW
	else:
		border = Color(0.7, 0.7, 0.7)

	draw_circle(center, 10.0 * _zoom, border)
	if tid == player_tid:
		draw_circle(center, 6.0 * _zoom, Color.WHITE)

func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	for key in _scroll_keys:
		if Input.is_key_pressed(key):
			dir += _scroll_keys[key]
	if dir != Vector2.ZERO:
		_camera += dir * SCROLL_SPEED * (1.0 / _zoom)
		queue_redraw()

func _input(event: InputEvent) -> void:
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
