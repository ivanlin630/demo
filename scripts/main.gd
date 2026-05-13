extends Node3D
## Main scene script.
## Orchestrates world generation, simulation loop, rendering,
## player spawning, and UI updates.

# ── Signals ───────────────────────────────────────────────────────────────────
signal turn_advanced(turn: int)
signal outpost_selected(outpost)   # WorldState.OutpostData or null
signal simulation_settings_changed(paused: bool, seconds_per_turn: float)
signal battle_state_changed(active: bool, text: String)

# ── Simulation state ──────────────────────────────────────────────────────────
var world_state:     WorldState
var world_generator: WorldGenerator
var faction_system:  FactionSystem
var message_system:  MessageSystem
var npc_memory:      NpcMemorySystem

var turns_per_advance: int  = 1
var player_active:     bool = false
var simulation_paused: bool  = false
var seconds_per_turn:  float = 0.35
var _turn_accumulator: float = 0.0
var world_tick: int = 0
var player_speed_factor: float = 1.0

enum TimeSystem {
	TURN_BASED,
	SEMI_REALTIME,
}
var time_system: TimeSystem = TimeSystem.SEMI_REALTIME
var player_hp: int = 100
var player_max_hp: int = 100
var player_faction_id: int = -1
var player_lives_used: int = 0

var encounter_battle: EncounterBattle
var battle_active: bool = false
var battle_status_text: String = ""
var camera_zoom: float = 34.0
var _last_player_grid_pos: Vector2i = Vector2i.ZERO

# ── Scene nodes ───────────────────────────────────────────────────────────────
var _camera:          Camera3D
var _hex_tiles:       MultiMeshInstance3D
var _faction_markers: Node3D
var _player:          Node3D      # player_controller.gd

const HEX_RADIUS: float = 0.5
const HEX_ROW_STEP: float = 0.8660254
const HEX_TILE_HEIGHT: float = 0.10
const CAMERA_ZOOM_MIN: float = 12.0
const CAMERA_ZOOM_MAX: float = 70.0

func _has_property(obj: Object, property_name: StringName) -> bool:
	for p in obj.get_property_list():
		if p.name == property_name:
			return true
	return false

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_register_input_actions()
	_build_scene()
	_init_game()
	# Initialize HUD (child added via main.tscn)
	var hud := $HUD
	if hud.has_method("initialize"):
		hud.initialize(world_state, self)
	simulation_settings_changed.emit(simulation_paused, seconds_per_turn)
	_update_camera_zoom()

# ── Input ─────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("battle_start") and player_active:
		_try_start_battle()
		return

	if event.is_action_pressed("zoom_in"):
		_adjust_camera_zoom(-2.0)
		return
	if event.is_action_pressed("zoom_out"):
		_adjust_camera_zoom(2.0)
		return
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_camera_zoom(-2.0)
			return
		if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_camera_zoom(2.0)
			return

	if event.is_action_pressed("time_mode_toggle"):
		_toggle_time_system()
		return

	if event.is_action_pressed("advance_turn"):
		_advance_world_ticks(turns_per_advance * _turn_to_tick())
	elif event.is_action_pressed("pause_toggle"):
		simulation_paused = not simulation_paused
		simulation_settings_changed.emit(simulation_paused, seconds_per_turn)
	elif event.is_action_pressed("auto_speed_up"):
		seconds_per_turn = max(0.05, seconds_per_turn - 0.05)
		simulation_settings_changed.emit(simulation_paused, seconds_per_turn)
	elif event.is_action_pressed("auto_speed_down"):
		seconds_per_turn = min(2.0, seconds_per_turn + 0.05)
		simulation_settings_changed.emit(simulation_paused, seconds_per_turn)
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
	if battle_active:
		encounter_battle.update(delta)
		battle_status_text = encounter_battle.get_status_text()
		battle_state_changed.emit(true, battle_status_text)
		if encounter_battle.finished:
			_resolve_battle()
		return

	if time_system == TimeSystem.SEMI_REALTIME and not simulation_paused:
		_turn_accumulator += delta
		while _turn_accumulator >= seconds_per_turn:
			_turn_accumulator -= seconds_per_turn
			_advance_world_ticks(_turn_to_tick())

	if player_active:
		_follow_camera(delta)
		if time_system == TimeSystem.TURN_BASED:
			var gp := get_player_grid_pos()
			if gp != _last_player_grid_pos:
				_last_player_grid_pos = gp
				_advance_world_ticks(get_player_move_tick_cost())

# ── Simulation ────────────────────────────────────────────────────────────────

func _advance_turns(count: int) -> void:
	for _i in range(count):
		world_state.current_turn += 1
		faction_system.update_turn()
		message_system.update_turn()
		npc_memory.update_turn()
	_update_map_texture()
	_refresh_faction_markers()
	turn_advanced.emit(world_state.current_turn)

func _advance_world_ticks(ticks: int) -> void:
	if ticks <= 0:
		return
	world_tick += ticks
	var target_turn: int = int(world_tick / _turn_to_tick())
	var delta_turn: int = max(0, target_turn - world_state.current_turn)
	if delta_turn > 0:
		_advance_turns(delta_turn)
	else:
		# Even when no turn boundary is crossed, notify HUD for world-time display.
		turn_advanced.emit(world_state.current_turn)

# ── Player ────────────────────────────────────────────────────────────────────

func _spawn_player() -> void:
	player_active     = true
	player_hp         = player_max_hp
	_player.visible   = true

	# Spawn adjacent to the first outpost
	if world_state.outposts.size() > 0:
		var op := world_state.outposts[0] as WorldState.OutpostData
		var spawn_pos := op.pos + Vector2i(1, 0)
		if not world_state.is_valid_pos(spawn_pos):
			spawn_pos = op.pos
		if _player.has_method("set_grid_pos"):
			_player.call("set_grid_pos", spawn_pos)
		else:
			_player.position = _grid_to_world(spawn_pos) + Vector3(0.0, 0.5, 0.0)
		_last_player_grid_pos = spawn_pos
		player_faction_id = op.faction_id
	else:
		var center := Vector2i(world_state.map_width / 2, world_state.map_height / 2)
		if _player.has_method("set_grid_pos"):
			_player.call("set_grid_pos", center)
		else:
			_player.position = _grid_to_world(center) + Vector3(0.0, 0.5, 0.0)
		_last_player_grid_pos = center
		player_faction_id = -1

	# Activate movement in player controller
	if _has_property(_player, &"active"):
		_player.set("active", true)

func _check_interact() -> void:
	var gp := get_player_grid_pos()
	var nearest: WorldState.OutpostData = null
	var nearest_dist := 999999

	for item in world_state.outposts:
		var op   := item as WorldState.OutpostData
		var dist: int = world_state.hex_distance(op.pos, gp)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest      = op

	if nearest != null and nearest_dist <= 6:
		# Transfer this faction's known messages to the player's personal journal.
		# Player only learns what this specific NPC/faction knows.
		var contact_faction := world_state.get_faction(nearest.faction_id)
		if contact_faction != null:
			for mvar in contact_faction.known_messages:
				var msg := mvar as MessageSystem.MessageData
				# Deduplicate: same event = same type + source + origin turn
				var already := false
				for pvar in world_state.player_known_messages:
					var pm := pvar as MessageSystem.MessageData
					if pm.origin_turn == msg.origin_turn \
							and pm.type == msg.type \
							and pm.source_pos == msg.source_pos:
						already = true
						break
				if not already:
					var copy := MessageSystem.MessageData.new(
						msg.type, msg.description, msg.source_pos,
						msg.faction_id, msg.origin_turn, msg.strength)
					copy.received_turn = world_state.current_turn
					world_state.player_known_messages.append(copy)

		# Create a random NPC at this outpost on first contact (resident NPC)
		var profiles: Array = npc_memory.get_faction_profiles(nearest.faction_id)
		# Always emit outpost info; include one NPC profile if available
		outpost_selected.emit(nearest)

		# Chance to encounter a new NPC on each visit
		if randf() < 0.4 or profiles.size() < 2:
			var f := world_state.get_faction(nearest.faction_id)
			var fname: String = f.name if f != null else "未知"
			var npc_name: String = fname + " 居民%d" % (profiles.size() + 1)
			var new_npc: NpcMemorySystem.NpcProfile = npc_memory.create_profile(npc_name, "", nearest.faction_id)
			# Meeting this NPC is a slight memory for the player context
			npc_memory.record_event(new_npc.id, "meeting",
				"與玩家在 %s 相遇" % fname, GameConfig.MEM_SLIGHT)
	else:
		outpost_selected.emit(null)

# ── Camera ────────────────────────────────────────────────────────────────────

func _follow_camera(delta: float) -> void:
	var target := _player.position + Vector3(0.0, 90.0, 0.0)
	_camera.position = _camera.position.lerp(target, 5.0 * delta)

func _adjust_camera_zoom(delta: float) -> void:
	camera_zoom = clamp(camera_zoom + delta, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)
	_update_camera_zoom()

func _update_camera_zoom() -> void:
	if _camera != null:
		_camera.size = camera_zoom

# ── Scene construction ────────────────────────────────────────────────────────

func _build_scene() -> void:
	# Camera: isometric-ish top-down view
	_camera                  = Camera3D.new()
	_camera.name             = "Camera3D"
	var center := _grid_to_world(Vector2i(GameConfig.map_width / 2, GameConfig.map_height / 2))
	_camera.projection       = Camera3D.PROJECTION_ORTHOGONAL
	_camera.position         = center + Vector3(0.0, 90.0, 0.0)
	_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
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

	# Hex map container
	_hex_tiles      = MultiMeshInstance3D.new()
	_hex_tiles.name = "HexTiles"
	add_child(_hex_tiles)

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
	npc_memory      = NpcMemorySystem.new(world_state)
	encounter_battle = EncounterBattle.new(world_state.seed_value + 777)
	player_speed_factor = GameConfig.PLAYER_SPEED_FACTOR_DEFAULT
	world_tick = world_state.current_turn * _turn_to_tick()

	# Seed NPC profiles for initial outpost leaders
	for item in world_state.outposts:
		var op := item as WorldState.OutpostData
		var f  := world_state.get_faction(op.faction_id)
		if f == null:
			continue
		var leader: NpcMemorySystem.NpcProfile = npc_memory.create_profile(f.name + " 領袖", "貴族", op.faction_id)
		npc_memory.record_event(leader.id, "founding",
			"建立了 %s 的統治" % f.name, GameConfig.MEM_DEEP)

	_build_map_mesh()
	_spawn_faction_markers()

	# Patch player node with correct map bounds
	if _has_property(_player, &"map_width"):  _player.set("map_width",  world_state.map_width)
	if _has_property(_player, &"map_height"): _player.set("map_height", world_state.map_height)
	if _has_property(_player, &"hex_radius"): _player.set("hex_radius", HEX_RADIUS)
	if _has_property(_player, &"hex_row_step"): _player.set("hex_row_step", HEX_ROW_STEP)

# ── Map rendering ─────────────────────────────────────────────────────────────

func _build_map_mesh() -> void:
	var w: int = world_state.map_width
	var h: int = world_state.map_height

	var hex_mesh := CylinderMesh.new()
	hex_mesh.top_radius = HEX_RADIUS
	hex_mesh.bottom_radius = HEX_RADIUS
	hex_mesh.height = HEX_TILE_HEIGHT
	hex_mesh.radial_segments = 6
	hex_mesh.rings = 1

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 1.0
	mat.metallic = 0.0

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = hex_mesh
	mm.instance_count = w * h

	for y in range(h):
		for x in range(w):
			var idx := _cell_index(x, y)
			var pos := _grid_to_world(Vector2i(x, y))
			mm.set_instance_transform(idx, Transform3D(Basis.IDENTITY, pos))

	_hex_tiles.multimesh = mm
	_hex_tiles.material_override = mat
	_update_map_texture()

func _update_map_texture() -> void:
	if _hex_tiles == null or _hex_tiles.multimesh == null:
		return
	var mm := _hex_tiles.multimesh
	for y in range(world_state.map_height):
		for x in range(world_state.map_width):
			var cell := world_state.get_cell(x, y)
			if cell == null:
				continue
			var color: Color = GameConfig.TERRAIN_COLORS[cell.terrain]
			if cell.faction_id >= 0:
				var f := world_state.get_faction(cell.faction_id)
				if f != null:
					color = color.lerp(f.color, 0.28)
			mm.set_instance_color(_cell_index(x, y), color)

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
		marker.position           = _grid_to_world(op.pos) + Vector3(0.0, 2.5, 0.0)
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

func get_player_grid_pos() -> Vector2i:
	if _player.has_method("get_grid_pos"):
		return _player.call("get_grid_pos") as Vector2i
	return Vector2i(int(round(_player.position.x)), int(round(_player.position.z)))

func get_player_visible_messages(count: int = 10) -> Array:
	if not player_active:
		return []
	var msgs := world_state.player_known_messages
	var n: int = msgs.size()
	var result: Array = []
	for i in range(max(0, n - count), n):
		var msg := msgs[i] as MessageSystem.MessageData
		result.append("[登T%d/獲T%d][%s] %s" % [
			msg.origin_turn, msg.received_turn, msg.type, msg.description])
	return result

func _try_start_battle() -> void:
	if battle_active or not player_active:
		return

	var nearest := _nearest_hostile_outpost(get_player_grid_pos())
	if nearest == null:
		return

	var op := nearest as WorldState.OutpostData
	var dist := world_state.hex_distance(get_player_grid_pos(), op.pos)
	if dist > 8:
		return

	var enemy_f := world_state.get_faction(op.faction_id)
	var enemy_hp := 70
	if enemy_f != null:
		enemy_hp = int(clamp(enemy_f.military * 2.0, 50.0, 140.0))

	battle_active = true
	battle_status_text = ""
	encounter_battle.start(player_hp, enemy_hp)
	battle_state_changed.emit(true, encounter_battle.get_status_text())

func _resolve_battle() -> void:
	battle_active = false
	battle_status_text = encounter_battle.get_status_text()
	battle_state_changed.emit(false, battle_status_text)

	if encounter_battle.winner == "player":
		player_hp = max(1, encounter_battle.player_hp)
		message_system.emit_message(
			"war",
			"玩家在遭遇戰中獲勝。",
			get_player_grid_pos(),
			player_faction_id
		)
	else:
		player_hp = 0
		_handle_player_death()

func _handle_player_death() -> void:
	player_lives_used += 1
	message_system.emit_message(
		"war",
		"玩家在戰鬥中陣亡，正在尋找可接管的隊友。",
		get_player_grid_pos(),
		player_faction_id
	)

	if player_faction_id >= 0:
		var faction := world_state.get_faction(player_faction_id)
		if faction != null and faction.population > 2.0:
			faction.population -= 1.0
			player_hp = player_max_hp
			var op := world_state.get_outpost_at(faction.outpost_pos)
			if op != null:
				var respawn_pos := op.pos + Vector2i(1, 0)
				if not world_state.is_valid_pos(respawn_pos):
					respawn_pos = op.pos
				if _player.has_method("set_grid_pos"):
					_player.call("set_grid_pos", respawn_pos)
				else:
					_player.position = _grid_to_world(respawn_pos) + Vector3(0.0, 0.5, 0.0)
				_last_player_grid_pos = respawn_pos
			player_active = true
			_player.visible = true
			if _has_property(_player, &"active"):
				_player.set("active", true)
			message_system.emit_message(
				"resource_found",
				"你接管了一名隊友，繼續生存。",
				faction.outpost_pos,
				faction.id
			)
			return

	player_active = false
	_player.visible = false
	if _has_property(_player, &"active"):
		_player.set("active", false)

func _nearest_hostile_outpost(from_pos: Vector2i) -> WorldState.OutpostData:
	var best: WorldState.OutpostData = null
	var best_dist := 999999
	for ovar in world_state.outposts:
		var op := ovar as WorldState.OutpostData
		if op.faction_id == player_faction_id:
			continue
		var d := world_state.hex_distance(from_pos, op.pos)
		if d < best_dist:
			best_dist = d
			best = op
	return best

func _toggle_time_system() -> void:
	if time_system == TimeSystem.SEMI_REALTIME:
		time_system = TimeSystem.TURN_BASED
		simulation_paused = true
	else:
		time_system = TimeSystem.SEMI_REALTIME
		simulation_paused = false
		_turn_accumulator = 0.0
	simulation_settings_changed.emit(simulation_paused, seconds_per_turn)

func get_time_system_name() -> String:
	if time_system == TimeSystem.SEMI_REALTIME:
		return "半即時制"
	return "回合制"

func _turn_to_tick() -> int:
	return max(1, int(GameConfig.TURN_TO_TICK))

func get_world_tick() -> int:
	return world_tick

func get_player_move_tick_cost() -> int:
	var safe_speed: float = max(0.2, player_speed_factor)
	var base: float = float(GameConfig.BASE_MOVE_TICK_COST)
	var raw_cost: int = int(round(base / safe_speed))
	return clamp(raw_cost, int(GameConfig.MIN_MOVE_TICK_COST), int(GameConfig.MAX_MOVE_TICK_COST))

func _cell_index(x: int, y: int) -> int:
	return y * world_state.map_width + x

func _grid_to_world(pos: Vector2i) -> Vector3:
	var wx := float(pos.x) + (0.5 if (pos.y % 2 != 0) else 0.0)
	var wz := float(pos.y) * HEX_ROW_STEP
	return Vector3(wx, 0.0, wz)

# ── Input action registration ─────────────────────────────────────────────────

func _ensure_key_binding(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for ev_var in InputMap.action_get_events(action_name):
		var ev := ev_var as InputEventKey
		if ev != null and ev.keycode == keycode:
			return

	var key_event := InputEventKey.new()
	key_event.keycode = keycode
	InputMap.action_add_event(action_name, key_event)

func _register_input_actions() -> void:
	var bindings := {
		"advance_turn": [KEY_SPACE],
		"time_mode_toggle": [KEY_T],
		"zoom_in": [KEY_PAGEUP],
		"zoom_out": [KEY_PAGEDOWN],
		"speed_up": [KEY_EQUAL],
		"speed_down": [KEY_MINUS],
		"pause_toggle": [KEY_P],
		"auto_speed_up": [KEY_BRACKETRIGHT],
		"auto_speed_down": [KEY_BRACKETLEFT],
		"battle_start": [KEY_B],
		"player_spawn": [KEY_ENTER],
		"interact": [KEY_E],

		# Numpad movement as primary, letter keys kept as compatibility fallback.
		"move_left": [KEY_KP_4, KEY_A],
		"move_right": [KEY_KP_6, KEY_D],
		"move_nw": [KEY_KP_7, KEY_Q],
		"move_ne": [KEY_KP_9, KEY_R],
		"move_sw": [KEY_KP_1, KEY_Z],
		"move_se": [KEY_KP_3, KEY_X],
	}

	for action_name: String in bindings:
		for keycode_var in bindings[action_name]:
			_ensure_key_binding(action_name, keycode_var as Key)
