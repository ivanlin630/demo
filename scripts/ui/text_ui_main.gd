# scripts/ui/text_ui_main.gd
extends Node

var _state: WorldState
var _runner: SimRunner
var _bridge: SimBridge

var _cursor: Vector2i = Vector2i(4, 4)
var _selected: Vector2i = Vector2i(-1, -1)
var _player_tid: int = 0
var _events: Array = []

var _input_mode: bool   = false
var _input_buffer: String = ""
var _member_mode: bool  = false
var _inv_mode: bool     = false
var _inv_selection: int = -1

@onready var _map_label:   RichTextLabel = $VBox/HBox/MapLabel
@onready var _state_label: Label         = $VBox/HBox/StateLabel
@onready var _event_label: Label         = $VBox/EventLabel
@onready var _debug_bar:   Label         = $VBox/DebugBar
@onready var _input_bar:   Label         = $VBox/InputBar

func _ready() -> void:
	_state  = WorldState.new()
	_runner = SimRunner.new()
	_bridge = SimBridge.new(_runner, _state)

	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(_state, { "radius": 4, "seed": 42 })

	# 初始化測試 team（玩家 team）
	var team := TeamData.new()
	team.team_id    = _player_tid
	team.population = 10
	team.tile_pos   = Vector2i(4, 4)
	team.tags       = ["統領"]
	team.resources  = {
		"food": 500.0, "material": 50.0, "coin": 50, "goods": 0,
		"gem": 0, "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": 5, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
		"armor_low": 0, "armor_high": 0,
	}
	_state.teams[_player_tid] = team
	_state.team_known[_player_tid] = []
	_state.team_discovered[_player_tid] = []

	var leader := PersonData.new()
	leader.id = 0; leader.person_name = "玩家"; leader.role = "leader"
	leader.team_id = _player_tid; leader.age = 30; leader.loyalty = 1.0
	_state.persons[0] = leader
	team.leader_id = 0
	_state.player_id = 0

	_cursor = team.tile_pos
	_refresh()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return
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
			_do_move_auto()
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

func _move_cursor(delta: Vector2i) -> void:
	var new_pos := _cursor + delta
	var key: int = new_pos.x * 1000 + new_pos.y
	if _state.world.tiles.has(key):
		_cursor = new_pos
	_refresh()

func _refresh() -> void:
	# 更新地圖
	_map_label.text = TextMapRenderer.render(_state, _player_tid, _cursor)

	# 更新狀態區
	_state_label.text = _build_state_str()

	# 更新事件 log
	var log_lines: Array = []
	var show_count: int = mini(_events.size(), 6)
	for i in range(_events.size() - show_count, _events.size()):
		var e = _events[i]
		log_lines.append("[T%d] %s" % [_state.world.current_tick, str(e)])
	_event_label.text = "\n".join(log_lines)

func _build_state_str() -> String:
	var pt: TeamData = _state.teams.get(_player_tid)
	if pt == null: return "（無玩家 team）"
	var lines: Array = []
	var faction_name: String = "獨立"
	if pt.faction_id >= 0 and _state.factions.has(pt.faction_id):
		faction_name = "勢力%d" % pt.faction_id
	lines.append("Team%d @ (%d,%d) [%s]" % [_player_tid, pt.tile_pos.x, pt.tile_pos.y, faction_name])
	lines.append("任務: %s  疲勞: %d%%" % [pt.current_task, int(pt.fatigue * 100)])
	lines.append("人口: %d | 受傷: %d | 未成年: %d" % [pt.population, 0, pt.minor_population])
	var res: Dictionary = pt.resources
	lines.append("────────────────")
	lines.append("食: %d  幣: %d  材: %d" % [
		int(res.get("food", 0)), int(res.get("coin", 0)), int(res.get("material", 0))])
	if _selected != Vector2i(-1, -1):
		var sel_key: int = _selected.x * 1000 + _selected.y
		var sel_tile = _state.world.tiles.get(sel_key)
		lines.append("────────────────")
		if sel_tile:
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.terrain])
			lines.append("  農:%.0f%%  資源: 食:%d" % [
				sel_tile.productivity * 100, int(sel_tile.resources.get("food", 0))])
		else:
			lines.append("選中: (%d,%d) [無效格]" % [_selected.x, _selected.y])
	lines.append("────────────────")
	lines.append("Tick: %d  (Day %d)" % [
		_state.world.current_tick,
		_state.world.current_tick / WorldState.TICKS_PER_DAY])
	return "\n".join(lines)

func _log_event(msg: String) -> void:
	_events.append({ "type": "ui", "msg": msg })
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)
