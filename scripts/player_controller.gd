extends Node3D
## Player pawn.  Activated when the player presses Enter.
## Handles hex movement (numpad or letter fallback) and stays within map bounds.

var step_interval: float = 0.12
var map_width:  int   = 128
var map_height: int   = 128
var active:     bool  = false
var _step_cd:   float = 0.0
var hex_radius: float = 0.5
var hex_row_step: float = 0.8660254
var _grid_pos: Vector2i = Vector2i.ZERO

func _process(delta: float) -> void:
	if not active:
		return
	_step_cd = max(0.0, _step_cd - delta)
	if _step_cd > 0.0:
		return

	var from := _grid_pos
	var next := from

	if Input.is_action_pressed("move_right"):
		next += Vector2i(1, 0)
	elif Input.is_action_pressed("move_left"):
		next += Vector2i(-1, 0)
	elif Input.is_action_pressed("move_nw"):
		next += _hex_offset(from, "nw")
	elif Input.is_action_pressed("move_ne"):
		next += _hex_offset(from, "ne")
	elif Input.is_action_pressed("move_sw"):
		next += _hex_offset(from, "sw")
	elif Input.is_action_pressed("move_se"):
		next += _hex_offset(from, "se")
	else:
		return

	next.x = clamp(next.x, 0, map_width - 1)
	next.y = clamp(next.y, 0, map_height - 1)
	_grid_pos = next
	position = _grid_to_world(_grid_pos) + Vector3(0.0, 0.5, 0.0)
	_step_cd = step_interval

func set_grid_pos(pos: Vector2i) -> void:
	_grid_pos = pos
	position = _grid_to_world(_grid_pos) + Vector3(0.0, 0.5, 0.0)

func get_grid_pos() -> Vector2i:
	return _grid_pos

func _grid_to_world(pos: Vector2i) -> Vector3:
	var wx := float(pos.x) + (0.5 if (pos.y % 2 != 0) else 0.0)
	var wz := float(pos.y) * hex_row_step
	return Vector3(wx, 0.0, wz)

func _hex_offset(pos: Vector2i, direction: String) -> Vector2i:
	var even := (pos.y % 2 == 0)
	match direction:
		"nw":
			return Vector2i(-1, -1) if even else Vector2i(0, -1)
		"ne":
			return Vector2i(0, -1) if even else Vector2i(1, -1)
		"sw":
			return Vector2i(-1, 1) if even else Vector2i(0, 1)
		"se":
			return Vector2i(0, 1) if even else Vector2i(1, 1)
		_:
			return Vector2i.ZERO
