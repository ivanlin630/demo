extends SceneTree

var _bridge: SimBridge = null

# TCP fallback state (Windows — pipe://stdin unavailable)
var _tcp_server: TCPServer = null
var _tcp_client: StreamPeerTCP = null

func _initialize() -> void:
	_bridge = _setup_game({})

	# Try stdin (works on Linux/Mac)
	var stdin := FileAccess.open("pipe://stdin", FileAccess.READ)
	if stdin == null:
		stdin = FileAccess.open("/dev/stdin", FileAccess.READ)

	if stdin != null:
		_run_stdin_loop(stdin)
	else:
		_run_tcp_loop()

func _run_stdin_loop(stdin: FileAccess) -> void:
	print(JSON.stringify({"ok": true, "code": "ready", "mode": "stdin"}))
	while not stdin.eof_reached():
		var line := stdin.get_line().strip_edges()
		if line.is_empty():
			continue
		var cmd = JSON.parse_string(line)
		if cmd == null or not cmd is Dictionary or not cmd.has("cmd"):
			print(JSON.stringify({"ok": false, "code": "invalid_json",
				"error": "invalid JSON or missing 'cmd'"}))
			continue
		if cmd.get("cmd") == "quit":
			_handle_quit(cmd)
			return
		var resp := _dispatch(cmd)
		print(JSON.stringify(resp))
	quit(0)

func _run_tcp_loop() -> void:
	_tcp_server = TCPServer.new()
	var err := _tcp_server.listen(0)
	if err != OK:
		print(JSON.stringify({"ok": false, "code": "tcp_error",
			"error": "Cannot start TCP server (err=%d)" % err}))
		quit(1)
		return

	var port: int = _tcp_server.get_local_port()
	print(JSON.stringify({"ok": true, "code": "ready", "mode": "tcp", "port": port}))

	# Wait up to 15s for a connection
	var deadline: int = Time.get_ticks_msec() + 15000
	while not _tcp_server.is_connection_available():
		if Time.get_ticks_msec() > deadline:
			print(JSON.stringify({"ok": false, "code": "tcp_timeout",
				"error": "No TCP connection within 15s"}))
			quit(1)
			return
		OS.delay_msec(10)

	_tcp_client = _tcp_server.take_connection()
	var recv_buf: PackedByteArray = PackedByteArray()

	while true:
		_tcp_client.poll()
		var status: int = _tcp_client.get_status()
		if status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
			break

		var available: int = _tcp_client.get_available_bytes()
		if available > 0:
			recv_buf.append_array(_tcp_client.get_data(available)[1])
			# Process all complete lines
			while true:
				var nl: int = recv_buf.find(10)  # '\n'
				if nl == -1:
					break
				var raw: String = recv_buf.slice(0, nl).get_string_from_utf8().strip_edges()
				recv_buf = recv_buf.slice(nl + 1)
				if raw.is_empty():
					continue
				var cmd = JSON.parse_string(raw)
				if cmd == null or not cmd is Dictionary or not cmd.has("cmd"):
					_tcp_write({"ok": false, "code": "invalid_json",
						"error": "invalid JSON or missing 'cmd'"})
					continue
				if cmd.get("cmd") == "quit":
					var code: int = int(cmd.get("code", 0))
					_tcp_write({"ok": true, "code": "ok", "message": "bye"})
					quit(code)
					return
				var resp := _dispatch(cmd)
				_tcp_write(resp)
		else:
			OS.delay_msec(5)

	quit(0)

func _tcp_write(data: Dictionary) -> void:
	if _tcp_client and _tcp_client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var line: String = JSON.stringify(data) + "\n"
		_tcp_client.put_data(line.to_utf8_buffer())

func _dispatch(cmd: Dictionary) -> Dictionary:
	match cmd.get("cmd", ""):
		"reset":           return _handle_reset(cmd)
		"query":           return _handle_query(cmd)
		"command":         return _handle_command(cmd)
		"advance":         return _handle_advance(cmd)
		"encounter_query": return _handle_encounter_query(cmd)
		"encounter_step":  return _handle_encounter_step(cmd)
		_:
			return {"ok": false, "code": "unknown_command",
				"error": "unknown cmd: %s" % cmd.get("cmd", "")}

func _handle_quit(cmd: Dictionary) -> void:
	var code: int = int(cmd.get("code", 0))
	print(JSON.stringify({"ok": true, "code": "ok", "message": "bye"}))
	quit(code)

func _handle_reset(cmd: Dictionary) -> Dictionary:
	var cfg: Dictionary = {}

	if cmd.has("config_path"):
		var path: String = cmd["config_path"]
		if not FileAccess.file_exists(path):
			return {"ok": false, "code": "config_not_found",
				"error": "config_path 不存在: %s" % path}
		var loaded := GameSetup.load_config(path)
		if loaded.is_empty():
			return {"ok": false, "code": "config_not_found",
				"error": "config_path 載入失敗: %s" % path}
		_deep_merge(cfg, loaded)

	if cmd.has("config"):
		_deep_merge(cfg, cmd["config"])

	_bridge = _setup_game(cfg)
	return {"ok": true, "code": "ok",
		"message": "重置完成 tick=0",
		"data": {"current_tick": 0}}

func _handle_query(cmd: Dictionary) -> Dictionary:
	if _bridge == null:
		return {"ok": false, "code": "not_initialized", "error": "call reset first"}
	var request: Dictionary = cmd.get("request", {})
	return _bridge.query_player(request)

func _handle_command(cmd: Dictionary) -> Dictionary:
	if _bridge == null:
		return {"ok": false, "code": "not_initialized", "error": "call reset first"}
	if not cmd.has("name"):
		return {"ok": false, "code": "invalid_json", "error": "missing 'name'"}
	var name_str: String = cmd["name"]
	var args: Dictionary = cmd.get("args", {})
	return _bridge.command_player(name_str, args)

func _handle_advance(cmd: Dictionary) -> Dictionary:
	if _bridge == null:
		return {"ok": false, "code": "not_initialized", "error": "call reset first"}

	if _bridge.get_state().encounter_active:
		return {"ok": false, "code": "encounter_active",
			"error": "遭遇戰進行中，無法推進世界時間"}

	var n: int = int(cmd.get("ticks", 1))
	if n <= 0:
		return {"ok": false, "code": "invalid_param", "error": "ticks must be > 0"}

	var all_events: Array = []
	var tick_before: int = _bridge.get_state().world.current_tick
	var ticks_remaining: int = n

	while ticks_remaining > 0:
		if _bridge.get_state().encounter_active:
			break
		var batch: int = mini(WorldState.TICKS_PER_HOUR, ticks_remaining)
		var batch_tick_before: int = _bridge.get_state().world.current_tick
		var evts: Array = _bridge.advance_ticks(batch)
		var actually_advanced: int = _bridge.get_state().world.current_tick - batch_tick_before
		ticks_remaining -= actually_advanced
		all_events.append_array(evts)
		if evts.size() > 0:
			break

	var ticks_done: int = _bridge.get_state().world.current_tick - tick_before
	return {
		"ok": true,
		"code": "ok",
		"ticks_advanced": ticks_done,
		"current_tick": _bridge.get_state().world.current_tick,
		"events": all_events,
	}

func _encounter_snapshot() -> Dictionary:
	var state: WorldState = _bridge.get_state()
	var units_out: Array = []
	for i in range(state.encounter_units.size()):
		var unit: Dictionary = state.encounter_units[i]
		var pid: int = unit.get("person_id", -1)
		var is_player: bool = (pid == state.player_id)
		var bp_out: Dictionary = {}
		var bp: Dictionary = unit.get("body_parts", {})
		for part in bp:
			bp_out[part] = {
				"hp":     bp[part].get("hp", 0),
				"max_hp": bp[part].get("max_hp", 0),
				"status": bp[part].get("status", "healthy"),
			}
		units_out.append({
			"unit_idx":   i,
			"person_id":  pid,
			"team_id":    unit.get("team_id", -1),
			"is_player":  is_player,
			"pos":        {"x": unit.get("pos", Vector2i.ZERO).x,
			               "y": unit.get("pos", Vector2i.ZERO).y},
			"stamina":    unit.get("stamina", 1.0),
			"has_exited": unit.get("has_exited", false),
			"body_parts": bp_out,
		})

	var waiting_for_player: bool = false
	for unit in state.encounter_units:
		if unit.get("person_id", -1) == state.player_id:
			waiting_for_player = (unit.get("action_timer", 1) == 0)
			break

	return {
		"encounter_active":   state.encounter_active,
		"attacker_team_id":   state.encounter_attacker_id,
		"defender_team_id":   state.encounter_defender_id,
		"player_team_id":     _bridge.get_player_team_id(),
		"waiting_for_player": waiting_for_player,
		"units":              units_out,
	}

func _handle_encounter_query(_cmd: Dictionary) -> Dictionary:
	if _bridge == null:
		return {"ok": false, "code": "not_initialized", "error": "call reset first"}
	if not _bridge.get_state().encounter_active:
		return {"ok": false, "code": "no_encounter", "error": "目前無遭遇戰"}
	return {"ok": true, "code": "ok", "data": _encounter_snapshot()}

func _handle_encounter_step(cmd: Dictionary) -> Dictionary:
	if _bridge == null:
		return {"ok": false, "code": "not_initialized", "error": "call reset first"}
	var state: WorldState = _bridge.get_state()
	if not state.encounter_active:
		return {"ok": false, "code": "no_encounter", "error": "目前無遭遇戰"}

	var player_unit: Dictionary = {}
	for unit in state.encounter_units:
		if unit.get("person_id", -1) == state.player_id:
			player_unit = unit
			break
	if player_unit.is_empty():
		return {"ok": false, "code": "no_encounter", "error": "找不到玩家 unit"}

	if cmd.has("action") and cmd["action"] != null:
		if player_unit.get("action_timer", 1) != 0:
			return {"ok": false, "code": "not_your_turn",
				"error": "尚未輪到玩家行動（action_timer=%d）" % player_unit.get("action_timer", -1)}

		var action: Dictionary = cmd["action"]
		var action_type: String = action.get("type", "wait")

		match action_type:
			"wait":
				player_unit["pending_action"] = {"type": "wait"}
			"attack":
				if not action.has("target_idx"):
					return {"ok": false, "code": "invalid_target", "error": "attack 需要 target_idx"}
				var tidx: int = int(action["target_idx"])
				if tidx < 0 or tidx >= state.encounter_units.size():
					return {"ok": false, "code": "invalid_target",
						"error": "target_idx %d 超出範圍" % tidx}
				var target: Dictionary = state.encounter_units[tidx]
				var torso: Dictionary = target.get("body_parts", {}).get("torso", {})
				var target_dead: bool = torso.get("status", "healthy") == "severed"
				if target.get("has_exited", false) or target_dead:
					return {"ok": false, "code": "invalid_target", "error": "目標已死亡或離場"}
				player_unit["pending_action"] = {"type": "attack", "target_idx": tidx}
			_:
				return {"ok": false, "code": "unknown_action",
					"error": "未知 action type: %s" % action_type}

		player_unit["action_timer"] = player_unit.get("_max_timer",
			EncounterSystem.BASE_ACTION_TICKS)

	var result_code: String = "ongoing"
	for _i in range(500):
		result_code = _bridge.advance_encounter_tick()
		if result_code == "player_turn" or result_code == "encounter_ended":
			break

	if result_code == "ongoing":
		result_code = "encounter_ended" if not state.encounter_active else "player_turn"

	return {
		"ok": true,
		"code": result_code,
		"data": _encounter_snapshot(),
	}

func _setup_game(config_override: Dictionary) -> SimBridge:
	var base_cfg := GameSetup.load_config("res://config/default.json")
	if base_cfg.is_empty():
		base_cfg = {}
	_deep_merge(base_cfg, config_override)
	var state := WorldState.new()
	var runner := SimRunner.new()
	GameSetup.setup(state, base_cfg)
	return SimBridge.new(runner, state)

func _deep_merge(base: Dictionary, override: Dictionary) -> void:
	for key in override:
		if key in base and base[key] is Dictionary and override[key] is Dictionary:
			_deep_merge(base[key], override[key])
		else:
			base[key] = override[key]
