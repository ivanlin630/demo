extends Node3D
## Main scene script.
## Orchestrates world generation, simulation loop, rendering,
## player spawning, and UI updates.

# ── Signals ───────────────────────────────────────────────────────────────────
signal turn_advanced(turn: int)
signal outpost_selected(outpost)   # WorldState.OutpostData or null

# ── Simulation state ──────────────────────────────────────────────────────────
var world_state:     WorldState
var world_generator: WorldGenerator
var faction_system:  FactionSystem
var message_system:  MessageSystem

var turns_per_advance: int  = 1
var player_active:     bool = false

# ── Scene nodes ───────────────────────────────────────────────────────────────
var _camera:          Camera3D
var _map_mesh:        MeshInstance3D
var _faction_markers: Node3D
var _player:          Node3D      # player_controller.gd

# Texture for the map plane
var _map_image:   Image
var _map_texture: ImageTexture

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_register_input_actions()
	_build_scene()
	_init_game()
	# Initialize HUD (child added via main.tscn)
	var hud := $HUD
	if hud.has_method("initialize"):
		hud.initialize(world_state, self)

# ── Input ─────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_turn"):
		_advance_turns(turns_per_advance)
	elif event.is_action_pressed("speed_up"):
		turns_per_advance = min(turns_per_advance + 1, 20)
	elif event.is_action_pressed("speed_down"):
		turns_per_advance = max(turns_per_advance - 1, 1)
	elif event.is_action_pressed("player_spawn") and not player_active:
		_spawn_player()
	elif event.is_action_pressed("interact") and player_active:
		_check_interact()

# ── Process ───────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if player_active:
		_follow_camera(delta)

# ── Simulation ────────────────────────────────────────────────────────────────

func _advance_turns(count: int) -> void:
	for _i in range(count):
		world_state.current_turn += 1
		faction_system.update_turn()
		message_system.update_turn()
	_update_map_texture()
	_refresh_faction_markers()
	turn_advanced.emit(world_state.current_turn)

# ── Player ────────────────────────────────────────────────────────────────────

func _spawn_player() -> void:
	player_active     = true
	_player.visible   = true

	# Spawn adjacent to the first outpost
	if world_state.outposts.size() > 0:
		var op := world_state.outposts[0] as WorldState.OutpostData
		_player.position = Vector3(op.pos.x + 4, 0.5, op.pos.y)
	else:
		_player.position = Vector3(
			world_state.map_width  * 0.5,
			0.5,
			world_state.map_height * 0.5
		)

	# Activate movement in player controller
	if _player.has_method("set") or "active" in _player:
		_player.set("active", true)

func _check_interact() -> void:
	var gp := Vector2i(int(_player.position.x), int(_player.position.z))
	var nearest: WorldState.OutpostData = null
	var nearest_dist := 999999

	for item in world_state.outposts:
		var op   := item as WorldState.OutpostData
		var dist := abs(op.pos.x - gp.x) + abs(op.pos.y - gp.y)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest      = op

	if nearest != null and nearest_dist <= 6:
		outpost_selected.emit(nearest)
	else:
		outpost_selected.emit(null)

# ── Camera ────────────────────────────────────────────────────────────────────

func _follow_camera(delta: float) -> void:
	var target := _player.position + Vector3(0.0, 30.0, 20.0)
	_camera.position = _camera.position.lerp(target, 5.0 * delta)

# ── Scene construction ────────────────────────────────────────────────────────

func _build_scene() -> void:
	# Camera: isometric-ish top-down view
	_camera                  = Camera3D.new()
	_camera.name             = "Camera3D"
	var hw := GameConfig.map_width  * 0.5
	var hh := GameConfig.map_height * 0.5
	_camera.position         = Vector3(hw, 80.0, hh + 55.0)
	_camera.rotation_degrees = Vector3(-55.0, 0.0, 0.0)
	add_child(_camera)

	# Environment
	var env_node          := WorldEnvironment.new()
	var env               := Environment.new()
	env.background_mode    = Environment.BG_COLOR
	env.background_color   = Color(0.45, 0.55, 0.75)
	env.ambient_light_color  = Color(0.6, 0.6, 0.6)
	env.ambient_light_energy = 1.0
	env_node.environment   = env
	add_child(env_node)

	# Sun
	var light                 := DirectionalLight3D.new()
	light.rotation_degrees     = Vector3(-50.0, 45.0, 0.0)
	light.light_energy         = 1.2
	add_child(light)

	# Map plane (textured with terrain colours)
	_map_mesh      = MeshInstance3D.new()
	_map_mesh.name = "MapMesh"
	add_child(_map_mesh)

	# Parent node for all faction billboards
	_faction_markers      = Node3D.new()
	_faction_markers.name = "FactionMarkers"
	add_child(_faction_markers)

	# Player node (hidden until Enter is pressed)
	_player         = _make_player_node()
	_player.visible = false
	add_child(_player)

func _make_player_node() -> Node3D:
	var player_script := load("res://scripts/player_controller.gd")
	var p             := Node3D.new()
	p.set_script(player_script)
	p.name            = "Player"

	var label            := Label3D.new()
	label.text           = "▶ 你"
	label.font_size      = 28
	label.modulate       = Color.WHITE
	label.billboard      = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test  = true
	label.position       = Vector3(0.0, 1.5, 0.0)
	p.add_child(label)
	return p

# ── Game initialisation ───────────────────────────────────────────────────────

func _init_game() -> void:
	world_generator = WorldGenerator.new()
	world_state     = world_generator.generate()
	message_system  = MessageSystem.new(world_state)
	faction_system  = FactionSystem.new(world_state, message_system)

	_build_map_mesh()
	_spawn_faction_markers()

	# Patch player node with correct map bounds
	if "map_width"  in _player: _player.set("map_width",  world_state.map_width)
	if "map_height" in _player: _player.set("map_height", world_state.map_height)

# ── Map rendering ─────────────────────────────────────────────────────────────

func _build_map_mesh() -> void:
	var w: int = world_state.map_width
	var h: int = world_state.map_height

	_map_image = Image.create(w, h, false, Image.FORMAT_RGB8)
	_update_map_image()

	_map_texture = ImageTexture.create_from_image(_map_image)

	var plane      := PlaneMesh.new()
	plane.size      = Vector2(float(w), float(h))
	_map_mesh.mesh  = plane
	# Centre the plane so (0,0,0) is the map corner
	_map_mesh.position = Vector3(w * 0.5, 0.0, h * 0.5)

	var mat                   := StandardMaterial3D.new()
	mat.albedo_texture         = _map_texture
	mat.texture_filter         = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_map_mesh.material_override = mat

func _update_map_image() -> void:
	for y in range(world_state.map_height):
		for x in range(world_state.map_width):
			var cell := world_state.get_cell(x, y)
			if cell == null:
				continue
			var color: Color = GameConfig.TERRAIN_COLORS[cell.terrain]
			# Blend faction colour for owned territory
			if cell.faction_id >= 0:
				var f := world_state.get_faction(cell.faction_id)
				if f != null:
					color = color.lerp(f.color, 0.28)
			_map_image.set_pixel(x, y, color)

func _update_map_texture() -> void:
	_update_map_image()
	if _map_texture != null:
		_map_texture.update(_map_image)

# ── Faction billboard markers ─────────────────────────────────────────────────

func _spawn_faction_markers() -> void:
	for child in _faction_markers.get_children():
		child.queue_free()

	for item in world_state.outposts:
		var op := item as WorldState.OutpostData
		var f  := world_state.get_faction(op.faction_id)
		if f == null:
			continue

		var marker               := Label3D.new()
		marker.name               = "Outpost_%d" % f.id
		marker.text               = _faction_marker_text(f)
		marker.font_size          = 18
		marker.modulate           = f.color
		marker.billboard          = BaseMaterial3D.BILLBOARD_ENABLED
		marker.no_depth_test      = true
		marker.position           = Vector3(
			op.pos.x + 0.5, 3.0, op.pos.y + 0.5
		)
		_faction_markers.add_child(marker)

func _refresh_faction_markers() -> void:
	for item in world_state.outposts:
		var op := item as WorldState.OutpostData
		var f  := world_state.get_faction(op.faction_id)
		if f == null:
			continue
		var marker := _faction_markers.get_node_or_null("Outpost_%d" % f.id)
		if marker != null:
			marker.text = _faction_marker_text(f)

func _faction_marker_text(f: WorldState.FactionData) -> String:
	return "⚑ %s\n👥%d  ⚔%d" % [f.name, int(f.population), int(f.military)]

# ── Input action registration ─────────────────────────────────────────────────

func _register_input_actions() -> void:
	var bindings := {
		"advance_turn":  KEY_SPACE,
		"speed_up":      KEY_EQUAL,
		"speed_down":    KEY_MINUS,
		"player_spawn":  KEY_ENTER,
		"interact":      KEY_E,
		"move_forward":  KEY_W,
		"move_back":     KEY_S,
		"move_left":     KEY_A,
		"move_right":    KEY_D,
	}
	for action_name: String in bindings:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var ev        := InputEventKey.new()
			ev.keycode     = bindings[action_name]
			InputMap.action_add_event(action_name, ev)
