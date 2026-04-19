extends Node3D
## Player pawn.  Activated when the player presses Enter.
## Handles WASD movement on the XZ plane and stays within map bounds.

var speed:      float = 15.0
var map_width:  int   = 128
var map_height: int   = 128
var active:     bool  = false

func _process(delta: float) -> void:
	if not active:
		return

	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"): dir.z -= 1.0
	if Input.is_action_pressed("move_back"):    dir.z += 1.0
	if Input.is_action_pressed("move_left"):    dir.x -= 1.0
	if Input.is_action_pressed("move_right"):   dir.x += 1.0

	if dir.length_squared() > 0.0:
		dir = dir.normalized()
	position      += dir * speed * delta
	position.x     = clamp(position.x, 0.0, float(map_width  - 1))
	position.z     = clamp(position.z, 0.0, float(map_height - 1))
