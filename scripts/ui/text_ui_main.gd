# scripts/ui/text_ui_main.gd
extends Node

var _runner: SimRunner
var _bridge: SimBridge

var _cursor: Vector2i = Vector2i(4, 4)
var _selected: Vector2i = Vector2i(-1, -1)
var _player_tid: int = 0
var _events: Array = []

var _input_mode: bool   = false
var _input_buffer: String = ""
var _input_mode_type: String = "numeric"   # "numeric" | "string"
var _input_mode_callback: Callable         # (buffer: String) -> void
var _input_mode_prompt: String = ""
var _member_mode: bool  = false
var _inv_mode: bool     = false
var _inv_selection: int = -1

var _interact_mode:   bool = false
var _interact_target: int  = -1
# -1 = 目標/事件選擇階段；>= 0 = 已選 pending target，顯示行動清單

# ── 新 Panel Modes（互斥）────────────────────────────────────────────────────
var _faction_mode:  bool = false
var _outpost_mode:  bool = false
var _subteam_mode:  bool = false
var _advisor_mode:  bool = false
var _subteam_selection: int = -1   # 當前選中的子隊 team_id
var _advisor_selection: int = -1   # 當前選中的顧問 person_id

# ── gather_intel submode ─────────────────────────────────────────────────────
var _intel_mode: bool = false
var _intel_target_id: int = -1
var _intel_options: Array = []     # Array[Dictionary] 每項 {"label": String}

# ── Alert bar ────────────────────────────────────────────────────────────────
var _pending_alerts: Array = []    # Array[String] 待顯示的警報文字
var _alert_bar: Label              # 動態建立，置於 InputBar 上方

var _cached_snapshot: Dictionary = {}

# member_mode state machine
var _member_selection: int    = 0   # index into members_detail
# submode: 0=quick_card 1=health 2=equipment 3=stats
var _member_detail_submode: int = 0

@onready var _map_label:   RichTextLabel = $VBox/HBox/MapLabel
@onready var _state_label: Label         = $VBox/HBox/StateLabel
@onready var _event_label: Label         = $VBox/EventLabel
@onready var _debug_bar:   Label         = $VBox/DebugBar
@onready var _input_bar:   Label         = $VBox/InputBar

func _ready() -> void:
	var ws := WorldState.new()
	_runner = SimRunner.new()
	_bridge = SimBridge.new(_runner, ws)
	var config := GameSetup.load_config("res://config/default.json")
	GameSetup.setup(ws, config)
	_player_tid = _bridge.get_player_team_id()
	_cursor = _bridge.get_player_tile_pos()
	# 動態建立 alert bar（置於 InputBar 之前）
	_alert_bar = Label.new()
	_alert_bar.name = "AlertBar"
	_alert_bar.modulate = Color(1.0, 0.8, 0.0)   # 黃色警報
	var vbox: Node = _input_bar.get_parent()
	vbox.add_child(_alert_bar)
	vbox.move_child(_alert_bar, _input_bar.get_index())
	_refresh()

func _refresh_snapshot() -> void:
	var request: Dictionary = {}
	if _interact_target >= 0:
		request["focus_team_id"] = _interact_target
	if _selected != Vector2i(-1, -1):
		request["cursor_tile_q"] = _selected.x
		request["cursor_tile_r"] = _selected.y
	var _result := _bridge.query_player(request)
	_cached_snapshot = _result.get("data", {}).get("snapshot", {})

func _process(_delta: float) -> void:
	if not _bridge.is_advancing(): return
	var result := _bridge.tick_step()
	_events.append_array(result.get("events", []))
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)

	var move_target: Vector2i = _bridge.get_player_move_target()
	if move_target == Vector2i(-1, -1) and _input_bar.text.begins_with("移動中"):
		_bridge.cancel_advance()
		_input_bar.text = ""
		var pos: Vector2i = _bridge.get_player_tile_pos()
		_log_event("Team%d 到達 (%d,%d)" % [_player_tid, pos.x, pos.y])

	if result.get("done", false):
		var mt2: Vector2i = _bridge.get_player_move_target()
		if _input_bar.text.begins_with("移動中") and mt2 != Vector2i(-1, -1):
			_bridge.request_advance(99999)
		else:
			_input_bar.text = ""
	elif not _input_bar.text.begins_with("移動中"):
		_input_bar.text = "推進中 Tick:%d [Esc]停止" % _bridge.get_current_tick()
	_refresh()
	if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
		_bridge.cancel_advance()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return
	if _input_mode:
		_handle_input_mode(event.keycode)
		return
	if _intel_mode:
		_handle_intel_mode(event.keycode)
		return
	if _inv_mode:
		_handle_inv_mode(event.keycode)
		return
	if _interact_mode:
		_handle_interact_mode(event.keycode)
		return
	if _member_mode:
		_handle_member_mode(event.keycode)
		return
	if _faction_mode:
		_handle_faction_mode(event.keycode)
		return
	if _outpost_mode:
		_handle_outpost_mode(event.keycode)
		return
	if _subteam_mode:
		_handle_subteam_mode(event.keycode)
		return
	if _advisor_mode:
		_handle_advisor_mode(event.keycode)
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
			var r: Dictionary = _bridge.command_player("move_to", {"tile_q": _cursor.x, "tile_r": _cursor.y})
			if r.get("ok"):
				_log_event(r.get("message", ""))
				_bridge.request_advance(99999)
				_input_bar.text = "移動中 [Esc]停止"
			else:
				_log_event(r.get("message", "移動失敗"))
			_refresh()
		KEY_SPACE:
			_bridge.request_advance(WorldState.TICKS_PER_DAY)
		KEY_G:
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "跳過 tick 數: "
			_input_buffer = ""
			_input_mode_callback = Callable()   # 無 callback → 使用舊有行為
			_input_bar.text = "跳過 tick 數: _"
		KEY_H:
			_cursor = _bridge.get_player_tile_pos()
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
		KEY_T:
			_interact_mode = not _interact_mode
			if _interact_mode:
				if _inv_mode: _inv_mode = false
				if _member_mode: _member_mode = false
				_interact_target = -1
				_bridge.refresh_interaction_targets()  # 掃描同格 NPC，讓 ignore 後仍可再次互動
			_refresh()
		KEY_F:
			_faction_mode = not _faction_mode
			if _faction_mode: _close_all_modes("faction")
			_refresh()
		KEY_O:
			_outpost_mode = not _outpost_mode
			if _outpost_mode: _close_all_modes("outpost")
			_refresh()
		KEY_U:
			_subteam_mode = not _subteam_mode
			if _subteam_mode: _close_all_modes("subteam")
			_subteam_selection = -1
			_refresh()
		KEY_V:
			_advisor_mode = not _advisor_mode
			if _advisor_mode: _close_all_modes("advisor")
			_advisor_selection = -1
			_refresh()
		KEY_ESCAPE:
			if _bridge.is_advancing():
				_bridge.cancel_advance()
				_input_bar.text = ""
				_refresh()
			elif _interact_mode:
				if _interact_target >= 0:
					_interact_target = -1   # 退回目標清單
				else:
					_interact_mode = false   # 關閉
				_refresh()
			elif _member_mode:
				_member_mode = false
				_refresh()
			elif _inv_mode:
				_inv_mode = false
				_inv_selection = -1
				_refresh()
			elif _faction_mode:
				_faction_mode = false
				_refresh()
			elif _outpost_mode:
				_outpost_mode = false
				_refresh()
			elif _subteam_mode:
				if _subteam_selection >= 0:
					_subteam_selection = -1
				else:
					_subteam_mode = false
				_refresh()
		KEY_Q:
			get_tree().quit()
		KEY_Z:
			if not _pending_alerts.is_empty():
				_pending_alerts.pop_front()
			_check_alerts()

func _handle_input_mode(keycode: int) -> void:
	if _input_mode_type == "string":
		# 接受 A-Z 字元
		if keycode >= KEY_A and keycode <= KEY_Z:
			if _input_buffer.length() < 30:
				_input_buffer += char(keycode).to_lower()
			_input_bar.text = "%s%s_" % [_input_mode_prompt, _input_buffer]
			return
		match keycode:
			KEY_BACKSPACE:
				if _input_buffer.length() > 0:
					_input_buffer = _input_buffer.left(_input_buffer.length() - 1)
				_input_bar.text = "%s%s_" % [_input_mode_prompt, _input_buffer]
			KEY_ENTER:
				if _input_buffer.length() > 0:
					_input_mode = false
					_input_bar.text = ""
					if _input_mode_callback.is_valid():
						_input_mode_callback.call(_input_buffer)
					_input_buffer = ""
					_refresh()
			KEY_ESCAPE:
				_input_mode = false
				_input_buffer = ""
				_input_bar.text = ""
				_input_mode_callback = Callable()
				_refresh()
		return

	# 原有 numeric 模式
	if keycode >= KEY_0 and keycode <= KEY_9:
		if _input_buffer.length() < 6:
			_input_buffer += str(keycode - KEY_0)
		_input_bar.text = "%s%s_" % [_input_mode_prompt if not _input_mode_prompt.is_empty() else "跳過 tick 數: ", _input_buffer]
		return
	match keycode:
		KEY_BACKSPACE:
			if _input_buffer.length() > 0:
				_input_buffer = _input_buffer.left(_input_buffer.length() - 1)
			_input_bar.text = "%s%s_" % [_input_mode_prompt if not _input_mode_prompt.is_empty() else "跳過 tick 數: ", _input_buffer]
		KEY_ENTER:
			if _input_buffer.length() > 0:
				if _input_mode_callback.is_valid():
					_input_mode = false
					_input_bar.text = ""
					_input_mode_callback.call(_input_buffer)
					_input_buffer = ""
					_input_mode_callback = Callable()
					_refresh()
				elif int(_input_buffer) > 0:
					# 舊有行為：跳過 N tick
					var n: int = mini(int(_input_buffer), 99999)
					_input_mode = false
					_input_bar.text = ""
					_bridge.request_advance(n)
					_input_buffer = ""
					_refresh()
		KEY_ESCAPE:
			_input_mode = false
			_input_buffer = ""
			_input_bar.text = ""
			_input_mode_callback = Callable()
			_refresh()

func _handle_inv_mode(keycode: int) -> void:
	var inv: Array         = _cached_snapshot.get("inventory_state", {}).get("inventory_items", [])
	var team_items: Array  = _get_team_takeable_items(null)

	if keycode >= KEY_1 and keycode <= KEY_9:
		var num: int  = keycode - KEY_1
		var total: int = inv.size() + team_items.size()
		if num < total:
			_inv_selection = num
		_refresh()
		return

	match keycode:
		KEY_E:
			if _inv_selection >= 0 and _inv_selection < inv.size():
				var grade: String = inv[_inv_selection].get("grade", "")
				var slot: String  = "torso" if grade.begins_with("armor") else "hand_1"
				_bridge.command_player("equip_item", {"slot_id": slot, "item_grade": grade})
				_inv_selection = -1
		KEY_S:
			if _inv_selection >= 0 and _inv_selection < inv.size():
				var grade: String = inv[_inv_selection].get("grade", "")
				var qty: int      = inv[_inv_selection].get("qty", 0)
				_bridge.command_player("deposit_item", {"item_grade": grade, "qty": qty})
				_inv_selection = -1
		KEY_G:
			var team_idx: int = _inv_selection - inv.size()
			if team_idx >= 0 and team_idx < team_items.size():
				_bridge.command_player("take_team_item", {"item_grade": team_items[team_idx], "qty": 1})
				_inv_selection = -1
		KEY_I, KEY_ESCAPE:
			_inv_mode = false
			_inv_selection = -1
	_refresh()

func _move_cursor(delta: Vector2i) -> void:
	var new_pos := _cursor + delta
	if _bridge.is_valid_tile(new_pos.x, new_pos.y):
		_cursor = new_pos
	_refresh()

func _refresh() -> void:
	_refresh_snapshot()
	_map_label.text  = _bridge.render_text_map(_player_tid, _cursor)
	_state_label.text = _build_state_str()
	_debug_bar.text  = "" if (_interact_mode or _member_mode or _inv_mode) else _build_debug_str()

	if _interact_mode:
		_event_label.text = _build_interact_str()
	elif _member_mode:
		_event_label.text = _build_member_str()
	elif _inv_mode:
		_event_label.text = _build_inv_str()
	elif _faction_mode:
		_event_label.text = _build_faction_str()
	elif _outpost_mode:
		_event_label.text = _build_outpost_str()
	elif _subteam_mode:
		_event_label.text = _build_subteam_str()
	elif _advisor_mode:
		_event_label.text = _build_advisor_str()
	elif _intel_mode:
		_event_label.text = _build_intel_str()
	else:
		var log_lines: Array = []
		var show_count: int = mini(_events.size(), 6)
		for i in range(_events.size() - show_count, _events.size()):
			var e = _events[i]
			log_lines.append("[T%d] %s" % [_bridge.get_current_tick(), str(e)])
		_event_label.text = "\n".join(log_lines)
	_check_alerts()

func _get_hp_status(person: PersonData) -> String:
	var has_severe: bool = false
	var has_wound: bool  = false
	for part in person.body_parts.values():
		var status: String = part.get("status", "healthy")
		if status == "severed" or status == "critical":
			has_severe = true
		elif status == "wounded":
			has_wound = true
	if has_severe: return "重傷"
	if has_wound:  return "輕傷"
	return "正常"

func _visible_team_at(tile_key: int) -> int:
	var q: int = tile_key / 1000
	var r: int = tile_key % 1000
	for vt in _cached_snapshot.get("visible_teams", []):
		var pos: Dictionary = vt.get("position", {})
		if pos.get("q", -999) == q and pos.get("r", -999) == r:
			return vt.get("id", -1)
	return -1

func _build_state_str() -> String:
	var ct: Dictionary  = _cached_snapshot.get("controlled_team", {})
	var ps: Dictionary  = _cached_snapshot.get("player_summary", {})
	var lc: Dictionary  = _cached_snapshot.get("location_context", {})
	if ct.is_empty(): return "（無玩家 team）"
	var lines: Array = []

	var pos: Dictionary = ct.get("position", {})
	lines.append("Team%d @ (%d,%d) [%s]" % [
		ct.get("id", _player_tid),
		pos.get("q", 0), pos.get("r", 0),
		ct.get("faction_display", "?")])
	lines.append("任務: %s  疲勞: %d%%" % [ct.get("task_summary", ""), ct.get("fatigue_pct", 0)])
	lines.append("人口: %d | 未成年: %d" % [ct.get("population", 0), ct.get("minor_population", 0)])

	if ps.get("player_exists", false):
		lines.append("────────────────")
		lines.append("玩家: %s  HP:%s" % [ps.get("player_name", ""), ps.get("hp_status", "")])
		var skill_parts: Array = []
		for sk in ps.get("skills", {}):
			skill_parts.append("%s:%.2f" % [sk, float(ps["skills"][sk])])
		if not skill_parts.is_empty():
			lines.append("  " + " ".join(skill_parts))

	var res: Dictionary = ct.get("resources", {})
	lines.append("────────────────")
	lines.append("資源:")
	lines.append("  食:%d 幣:%d 材:%d" % [res.get("food", 0), res.get("coin", 0), res.get("material", 0)])
	lines.append("  低武:%d 高武:%d" % [res.get("weapon_melee_low", 0), res.get("weapon_melee_high", 0)])
	lines.append("  低甲:%d 高甲:%d" % [res.get("armor_low", 0), res.get("armor_high", 0)])
	lines.append("  藥:%d 工:%d" % [res.get("medicine", 0), res.get("tools", 0)])

	if _selected != Vector2i(-1, -1):
		var sel_tile: Dictionary = _bridge.query_tile(_selected.x, _selected.y)
		lines.append("────────────────")
		if not sel_tile.is_empty():
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.get("terrain", "?")])
			lines.append("  農:%.0f%%  食:%d" % [
				sel_tile.get("productivity", 0) * 100,
				int(sel_tile.get("resources", {}).get("food", 0))])
			var occ: Array = lc.get("occupants", [])
			if not occ.is_empty():
				var vts: Array = _cached_snapshot.get("visible_teams", [])
				for o in occ:
					var oid: int = o.get("team_id", -1)
					var f_display: String = "?"
					var pop: int = 0
					for vt in vts:
						if vt.get("id", -1) == oid:
							f_display = vt.get("faction_display", "?")
							pop = vt.get("population", 0)
							break
					lines.append("  %s [%s] 人口:%d" % [o.get("team_name", "Team?"), f_display, pop])
		else:
			lines.append("選中: (%d,%d) [無效格]" % [_selected.x, _selected.y])

	lines.append("────────────────")
	lines.append("Tick: %d  (Day %d)" % [
		_bridge.get_current_tick(),
		_bridge.get_current_tick() / WorldState.TICKS_PER_DAY])
	var _pending_n: int = _cached_snapshot.get("pending_targets", []).size()
	var _forced_n:  int = 0 if _cached_snapshot.get("forced_interaction", {}).get("interaction_id", "").is_empty() else 1
	if _pending_n > 0 or _forced_n > 0:
		var _hint: String = "[T] 互動"
		if _pending_n > 0: _hint += ": 同格%d隊" % _pending_n
		if _forced_n > 0:  _hint += "  ⚠強制事件"
		lines.append(_hint)
	return "\n".join(lines)

func _build_debug_str() -> String:
	var tick: int  = _bridge.get_current_tick()
	var hour: int  = (tick / WorldState.TICKS_PER_HOUR) % 24
	var day: int   = (tick / WorldState.TICKS_PER_DAY) % 30 + 1
	var month: int = (tick / WorldState.TICKS_PER_MONTH) % 12
	var season_names: Array = ["春","春","春","夏","夏","夏","秋","秋","秋","冬","冬","冬"]
	var season: String = season_names[month]
	var lines: Array = []
	lines.append("[DEBUG] Tick:%d Hour:%d Day:%d Month:%d Season:%s" % [tick, hour, day, month + 1, season])

	var teams_debug: Array = _bridge.get_all_teams_debug()
	var team_strs: Array = []
	for td in teams_debug:
		var pos: Vector2i = td.get("pos", Vector2i.ZERO)
		team_strs.append("T%d@(%d,%d)pop=%d %s" % [td["id"], pos.x, pos.y, td["pop"], td["task"]])
	lines.append("Teams: " + " | ".join(team_strs))

	var evt_strs: Array = []
	for i in range(maxi(0, _events.size() - 10), _events.size()):
		var e = _events[i]
		evt_strs.append("[%s]%s" % [str(e.get("type","?")), str(e.get("msg",""))])
	lines.append("Events(last10): " + " | ".join(evt_strs))

	var msgs: Array = _bridge.query_global_messages(10)
	lines.append("Msgs(last10): " + " | ".join(msgs))

	return "\n".join(lines)

func _handle_member_mode(keycode: int) -> void:
	var members: Array = _cached_snapshot.get("members_detail", [])
	match keycode:
		KEY_W:
			if members.size() > 0:
				_member_selection = posmod(_member_selection - 1, members.size())
		KEY_S:
			if members.size() > 0:
				_member_selection = posmod(_member_selection + 1, members.size())
		KEY_1:
			_member_detail_submode = 0
		KEY_2:
			_member_detail_submode = 1
		KEY_3:
			_member_detail_submode = 2
		KEY_4:
			_member_detail_submode = 3
		KEY_P, KEY_ESCAPE:
			_member_mode = false
	_refresh()

func _build_member_str() -> String:
	var members: Array    = _cached_snapshot.get("members_detail", [])
	var team_stats: Dictionary = _cached_snapshot.get("team_stats", {})
	var ct: Dictionary    = _cached_snapshot.get("controlled_team", {})
	if members.is_empty() and ct.is_empty():
		return "（無玩家 team）"

	# Clamp selection to valid range
	if members.size() > 0:
		_member_selection = clampi(_member_selection, 0, members.size() - 1)

	var selected_member: Dictionary = members[_member_selection] if members.size() > 0 else {}

	var detail_lines: Array = []
	match _member_detail_submode:
		0: detail_lines = TeamUiHelper.render_quick_card(selected_member)
		1: detail_lines = TeamUiHelper.render_health_detail(selected_member)
		2: detail_lines = TeamUiHelper.render_equipment_detail(selected_member)
		3: detail_lines = TeamUiHelper.render_stats_detail(selected_member)

	var team_name: String = ct.get("name", "Team?")
	return TeamUiHelper.render_three_columns(
		members,
		_member_selection,
		detail_lines,
		team_stats,
		team_name,
		_bridge.get_current_tick()
	)

func _get_team_takeable_items(_pt: TeamData) -> Array:
	return ["weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high",
		"armor_low", "armor_high", "medicine", "tools"]

func _build_inv_str() -> String:
	var ct: Dictionary        = _cached_snapshot.get("controlled_team", {})
	var inv_state: Dictionary = _cached_snapshot.get("inventory_state", {})
	if ct.is_empty() or inv_state.is_empty(): return "（無資料）"
	var equipped: Dictionary = inv_state.get("equipped_items", {})
	var lines: Array = []

	lines.append("── 裝備 ──")
	var h1: String = equipped.get("hand_1", "")
	var h2: String = equipped.get("hand_2", "")
	lines.append("  右手:%s  左手:%s" % [
		h1 if not h1.is_empty() else "空",
		h2 if not h2.is_empty() else "空"])
	var body_slots_data: Dictionary = _bridge.query_body_slots()
	const BODY_NAMES: Dictionary = {
		"head": "頭", "torso": "胸", "right_arm": "右臂",
		"left_arm": "左臂", "right_leg": "右腿", "left_leg": "左腿"
	}
	var body_strs: Array = []
	for slot in ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]:
		var g: String = body_slots_data.get(slot, "")
		body_strs.append("%s:%s" % [BODY_NAMES[slot], g if not g.is_empty() else "空"])
	lines.append("  " + " ".join(body_strs))

	var inv: Array = inv_state.get("inventory_items", [])
	lines.append("── 背包 (%d/%d) ──" % [inv.size(), PlayerSystem.PLAYER_INVENTORY_MAX_SLOTS])
	for i in range(inv.size()):
		var item = inv[i]
		var prefix: String = "[%d]*" % (i + 1) if _inv_selection == i else "[%d]" % (i + 1)
		lines.append("  %s %s × %d" % [prefix, item.get("grade", "?"), item.get("qty", 0)])

	var team_items: Array = _get_team_takeable_items(null)
	lines.append("── 從 Team 取出 ──")
	for i in range(team_items.size()):
		var idx: int = inv.size() + i
		var prefix: String = "[T%d]*" % (i + 1) if _inv_selection == idx else "[T%d]" % (i + 1)
		var qty: int = ct.get("resources", {}).get(team_items[i], 0)
		lines.append("  %s %s: %d%s" % [prefix, team_items[i], qty, "" if qty > 0 else "（灰）"])

	lines.append("── [數字]選取 [E]裝備 [S]存入 [G]取出 [I/Esc]關閉 ──")
	return "\n".join(lines)

func _log_event(msg: String) -> void:
	_events.append({ "type": "ui", "msg": msg })
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)

func _handle_interact_mode(keycode: int) -> void:
	# ESC 處理
	if keycode == KEY_ESCAPE:
		if _interact_target >= 0:
			_interact_target = -1
		else:
			_interact_mode = false
		_refresh()
		return

	# 數字鍵 1–9
	if keycode < KEY_1 or keycode > KEY_9:
		return
	var num: int = keycode - KEY_1   # 0-based

	# ── 已選目標：顯示行動清單 ──
	if _interact_target >= 0:
		var actions: Array = _cached_snapshot.get("available_actions", [])
		if num < actions.size():
			var act: Dictionary = actions[num]
			var action_id: String = act.get("action_id", "")
			if action_id == "gather_intel":
				# 進入 gather_intel 子模式
				_intel_target_id = _interact_target
				_bridge.set_player_input("pending_intel_target", _intel_target_id)
				var ir: Dictionary = _bridge.command_player(
					act.get("command_name", "execute_action"), act.get("command_args", {}))
				_intel_options = ir.get("payload", {}).get("inquiry_options", [])
				if _intel_options.is_empty():
					_log_event("[打聽] 無可用問題")
				else:
					_intel_mode = true
					_interact_mode = false
			else:
				var result: Dictionary = _bridge.command_player(
					act.get("command_name", "execute_action"), act.get("command_args", {}))
				_log_event("[互動] %s" % result.get("message", ""))
			_interact_target = -1   # 回到目標清單
			# 若行動觸發遭遇戰，關閉 interact_mode
			_refresh_snapshot()
			if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
				_interact_mode = false
		_refresh()
		return

	# ── 目標選擇階段 ──
	var fi: Dictionary = _cached_snapshot.get("forced_interaction", {})
	var fi_responses: Array = fi.get("responses", [])
	var fe_count: int = fi_responses.size()

	# forced_event 回應
	if not fi.get("interaction_id", "").is_empty() and num < fe_count:
		var resp_args: Dictionary = fi_responses[num].get("command_args", {})
		var result: Dictionary = _bridge.command_player("respond_to_forced", resp_args)
		_log_event("[強制互動] %s" % result.get("message", ""))
		_refresh()
		return

	# pending_targets 選擇
	var pending_idx: int = num - fe_count
	var pending_tgts: Array = _cached_snapshot.get("pending_targets", [])
	if pending_idx >= 0 and pending_idx < pending_tgts.size():
		_interact_target = pending_tgts[pending_idx].get("target_id", -1)
		_refresh()

func _build_interact_str() -> String:
	var lines: Array = []

	# 已選目標：顯示行動清單
	if _interact_target >= 0:
		var tgt_name: String = "Team%d" % _interact_target
		lines.append("── %s 行動 ──" % tgt_name)
		var actions: Array = _cached_snapshot.get("available_actions", [])
		var row: String = ""
		for i in range(actions.size()):
			row += "[%d]%s  " % [i + 1, actions[i].get("label", actions[i].get("action_id", ""))]
			if (i + 1) % 4 == 0:
				lines.append(row.strip_edges())
				row = ""
		if not row.strip_edges().is_empty():
			lines.append(row.strip_edges())
		lines.append("── [Esc]返回 ──")
		return "\n".join(lines)

	# 目標選擇階段
	lines.append("── 互動 ──")
	var fi: Dictionary = _cached_snapshot.get("forced_interaction", {})
	var fi_has_event: bool = not fi.get("interaction_id", "").is_empty()
	var fe_count: int = 0

	if fi_has_event:
		var responses: Array = fi.get("responses", [])
		var opts_str: String = ""
		for i in range(responses.size()):
			opts_str += " [%d]%s" % [i + 1, responses[i].get("label", "?")]
			fe_count += 1
		lines.append("[!] %s →%s" % [fi.get("message", "強制事件"), opts_str])

	var pending_tgts: Array = _cached_snapshot.get("pending_targets", [])
	var idx: int = fe_count + 1
	if pending_tgts.is_empty() and not fi_has_event:
		lines.append("（無可互動目標）")
	for target_info in pending_tgts:
		var tid: int = target_info.get("target_id", -1)
		var vts: Array = _cached_snapshot.get("visible_teams", [])
		var vt: Dictionary = {}
		for v in vts:
			if v.get("id", -1) == tid: vt = v; break
		if vt.is_empty(): continue
		var pos: Dictionary = vt.get("position", {})
		var faction_str: String = vt.get("faction_display", "?")
		lines.append("[%d] Team%d @(%d,%d) %s pop:%d" % [
			idx, tid, pos.get("q", 0), pos.get("r", 0), faction_str, vt.get("population", 0)])
		idx += 1

	lines.append("── [T/Esc]關閉 ──")
	return "\n".join(lines)

func _handle_faction_mode(keycode: int) -> void:
	if keycode == KEY_F or keycode == KEY_ESCAPE:
		_faction_mode = false
		_refresh()
		return
	var fp: Dictionary = _bridge.query_faction_panel().get("data", {})
	if not fp.get("in_faction", false):
		_faction_mode = false
		_refresh()
		return
	var member_orders: Array = fp.get("member_orders", [])

	match keycode:
		KEY_A:   # 設定目標
			_input_mode = true
			_input_mode_type = "string"
			_input_mode_prompt = "設定勢力目標: "
			_input_buffer = ""
			_input_mode_callback = func(buf: String):
				_bridge.set_player_input("faction_goal_input", buf)
				var r := _bridge.command_player("execute_action",
					{"action_id": "set_faction_goal", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % r.get("message", ""))
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_B:   # 調整徵收率
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "徵收率 (0-100): "
			_input_buffer = ""
			_input_mode_callback = func(buf: String):
				var rate: float = clampf(float(buf) / 100.0, 0.0, 1.0)
				_bridge.set_player_input("tribute_rate_input", rate)
				var r := _bridge.command_player("execute_action",
					{"action_id": "set_tribute_rate", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % r.get("message", ""))
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_C:   # 離開勢力
			var r := _bridge.command_player("execute_action",
				{"action_id": "leave_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
		KEY_D:   # 背叛勢力
			var r := _bridge.command_player("execute_action",
				{"action_id": "betray_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
		KEY_E:   # 解散勢力（僅 leader）
			var r := _bridge.command_player("execute_action",
				{"action_id": "disband_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
		_:
			# [1~9] 下令成員
			if keycode >= KEY_1 and keycode <= KEY_9:
				var idx: int = keycode - KEY_1
				if idx < member_orders.size():
					var mo: Dictionary = member_orders[idx]
					var member_tid: int = mo.get("team_id", -1)
					_input_mode = true
					_input_mode_type = "string"
					_input_mode_prompt = "下令 Team%d 任務: " % member_tid
					_input_buffer = ""
					_input_mode_callback = func(buf: String):
						_bridge.set_player_input("order_member_id", member_tid)
						_bridge.set_player_input("member_task", buf)
						var r := _bridge.command_player("execute_action",
							{"action_id": "order_faction_member", "target": {"kind": "none", "team_id": member_tid, "member_id": -1, "tile_q": -1, "tile_r": -1}})
						_log_event("[勢力] %s" % r.get("message", ""))
					_input_bar.text = "%s_" % _input_mode_prompt
	_refresh()

func _build_faction_str() -> String:
	var fp: Dictionary = _bridge.query_faction_panel().get("data", {})
	if not fp.get("in_faction", false):
		return "── 勢力面板 ──\n（玩家不在任何勢力）\n[F/Esc]關閉"
	var lines: Array = []
	var role_str: String = "Leader" if fp.get("is_leader", false) else "成員"
	lines.append("── 勢力%d [%s] ──" % [fp.get("faction_id", -1), role_str])
	lines.append("AI 目標: %s   玩家目標: %s" % [
		fp.get("faction_goal", "（無）"),
		fp.get("player_goal_override", "（跟隨 AI）") if not fp.get("player_goal_override", "").is_empty() else "（跟隨 AI）"])
	lines.append("徵收率: %.0f%%" % (fp.get("tribute_rate", 0.0) * 100))
	lines.append("")
	lines.append("── 成員指令 ──")
	var member_orders: Array = fp.get("member_orders", [])
	for i in range(member_orders.size()):
		var mo: Dictionary = member_orders[i]
		var pos: Dictionary = mo.get("tile_pos", {})
		var task_str: String
		if mo.get("pending_task", "") != "":
			task_str = "傳達中（%s）" % mo.get("pending_task", "")
		elif mo.get("commanded_task", "") != "":
			task_str = mo.get("commanded_task", "")
		else:
			task_str = "無"
		var pos_v: Vector2i = mo.get("tile_pos", Vector2i.ZERO) as Vector2i
		lines.append("[%d] Team%d @(%d,%d)  指令: %s" % [
			i + 1, mo.get("team_id", -1), pos_v.x, pos_v.y, task_str])
	lines.append("")
	lines.append("── 行動 ──")
	lines.append("[A]設定目標  [B]調整徵收率  [C]離開勢力")
	if fp.get("is_leader", false):
		lines.append("[D]背叛勢力  [E]解散勢力（Leader）")
	else:
		lines.append("[D]背叛勢力")
	lines.append("[F/Esc]關閉")
	return "\n".join(lines)

func _handle_outpost_mode(keycode: int) -> void:
	if keycode == KEY_O or keycode == KEY_ESCAPE:
		_outpost_mode = false
		_refresh()
		return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var op: Dictionary = _bridge.query_outpost_panel().get("data", {})
		var actions: Array = op.get("actions", [])
		var idx: int = keycode - KEY_1
		if idx < actions.size():
			var action_id: String = actions[idx]
			var r := _bridge.command_player("execute_action",
				{"action_id": action_id, "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[前哨] %s" % r.get("message", ""))
	_refresh()

func _build_outpost_str() -> String:
	var op: Dictionary = _bridge.query_outpost_panel().get("data", {})
	var lines: Array = []
	var pos: Vector2i = op.get("tile_pos", Vector2i.ZERO) as Vector2i
	lines.append("── 前哨站 @(%d,%d) ──" % [pos.x, pos.y])
	lines.append("類型: %s  等級: %d" % [
		op.get("outpost_type", "無") if op.get("outpost_type", "") != "" else "無",
		op.get("outpost_level", 0)])
	var owner: int = op.get("outpost_owner", -1)
	lines.append("擁有者: %s  支配權: %s" % [
		"Team%d" % owner if owner >= 0 else "無",
		"是" if op.get("has_control", false) else "否"])
	if op.get("construction_in_progress", false):
		lines.append("施工中：剩餘 %d Tick" % op.get("ticks_left", 0))
	lines.append("")
	lines.append("── 可用行動 ──")
	const ACTION_LABELS: Dictionary = {
		"build_outpost":          "建設前哨站",
		"upgrade_outpost":        "升級等級",
		"upgrade_farming":        "升級農作",
		"upgrade_manufacturing":  "升級製造",
		"demolish_outpost":       "拆除",
	}
	var actions: Array = op.get("actions", [])
	if actions.is_empty():
		lines.append("（無可用行動）")
	for i in range(actions.size()):
		lines.append("[%d]%s" % [i + 1, ACTION_LABELS.get(actions[i], actions[i])])
	lines.append("[O/Esc]關閉")
	return "\n".join(lines)

func _handle_subteam_mode(keycode: int) -> void:
	if keycode == KEY_U or keycode == KEY_ESCAPE:
		_subteam_mode = false
		_subteam_selection = -1
		_refresh()
		return
	var sp: Dictionary = _bridge.query_subteam_panel().get("data", {})
	var subteams: Array = sp.get("subteams", [])

	if _subteam_selection == -1:
		# 選子隊
		if keycode >= KEY_1 and keycode <= KEY_9:
			var idx: int = keycode - KEY_1
			if idx < subteams.size():
				_subteam_selection = subteams[idx].get("team_id", -1)
		_refresh()
		return

	# 已選子隊：[A] 下令移動, [B] 召回
	match keycode:
		KEY_A:
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "目標 q（按 Enter 繼續）: "
			_input_buffer = ""
			var sub_id_cap: int = _subteam_selection
			_input_mode_callback = func(buf_q: String):
				var q_val: int = int(buf_q)
				_input_mode = true
				_input_mode_type = "numeric"
				_input_mode_prompt = "目標 r: "
				_input_buffer = ""
				_input_mode_callback = func(buf_r: String):
					var r_val: int = int(buf_r)
					_bridge.set_player_input("order_sub_id", sub_id_cap)
					_bridge.set_player_input("order_sub_q", q_val)
					_bridge.set_player_input("order_sub_r", r_val)
					_bridge.set_player_input("order_sub_task", "移動")
					var res := _bridge.command_player("execute_action",
						{"action_id": "order_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
					_log_event("[子隊] %s" % res.get("message", ""))
					_subteam_selection = -1
				_input_bar.text = "%s_" % _input_mode_prompt
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_B:
			_bridge.set_player_input("recall_sub_id", _subteam_selection)
			var r := _bridge.command_player("execute_action",
				{"action_id": "recall_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[子隊] %s" % r.get("message", ""))
			_subteam_selection = -1
	_refresh()

func _build_subteam_str() -> String:
	var sp: Dictionary = _bridge.query_subteam_panel().get("data", {})
	var subteams: Array = sp.get("subteams", [])
	var lines: Array = []
	lines.append("── 子隊 ──")
	if subteams.is_empty():
		lines.append("（無子隊）")
	for i in range(subteams.size()):
		var st: Dictionary = subteams[i]
		var pos_v: Vector2i = st.get("tile_pos", Vector2i.ZERO) as Vector2i
		var task_str: String = st.get("player_commanded_task", st.get("current_task", "?"))
		var selected_mark: String = "* " if st.get("team_id", -1) == _subteam_selection else "  "
		lines.append("[%d]%sTeam%d @(%d,%d)  %s  人口:%d" % [
			i + 1, selected_mark, st.get("team_id", -1), pos_v.x, pos_v.y,
			task_str, st.get("population", 0)])
		if st.get("team_id", -1) == _subteam_selection:
			lines.append("    [A]下令移動  [B]召回")
	lines.append("[U/Esc]關閉")
	return "\n".join(lines)

func _handle_advisor_mode(keycode: int) -> void:
	if keycode == KEY_V or keycode == KEY_ESCAPE:
		_advisor_mode = false
		_advisor_selection = -1
		_refresh()
		return
	var members: Array = _cached_snapshot.get("members_detail", [])
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx: int = keycode - KEY_1
		if idx < members.size():
			_advisor_selection = members[idx].get("id", -1)
			if _advisor_selection >= 0:
				_input_mode = true
				_input_mode_type = "string"
				_input_mode_prompt = "情境關鍵字 (attack/diplomacy/resource): "
				_input_buffer = ""
				var advisor_pid_cap: int = _advisor_selection
				_input_mode_callback = func(buf: String):
					var advice: String = _bridge.query_advisor_advice(advisor_pid_cap, buf)
					_log_event("[Advisor] 建議：%s" % advice)
				_input_bar.text = "%s_" % _input_mode_prompt
	_refresh()

func _build_advisor_str() -> String:
	var members: Array = _cached_snapshot.get("members_detail", [])
	var lines: Array = []
	lines.append("── 顧問 ──")
	if members.is_empty():
		lines.append("（無可用顧問）")
	for i in range(members.size()):
		var m: Dictionary = members[i]
		var skills: Dictionary = m.get("skills", {})
		lines.append("[%d] %s  計謀:%.1f 交涉:%.1f 戰術:%.1f" % [
			i + 1, m.get("name", "?"),
			float(skills.get("計謀", 0)),
			float(skills.get("交涉", 0)),
			float(skills.get("戰術", 0))])
	lines.append("選顧問後輸入情境關鍵字 (attack/diplomacy/resource)")
	lines.append("[V/Esc]關閉")
	return "\n".join(lines)

func _handle_intel_mode(keycode: int) -> void:
	if keycode == KEY_ESCAPE:
		_intel_mode = false
		_intel_options = []
		_refresh()
		return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx: int = keycode - KEY_1
		if idx < _intel_options.size():
			var choice: String = _intel_options[idx].get("label", "")
			_bridge.set_player_input("gather_intel_npc_id", _intel_target_id)
			_bridge.set_player_input("gather_intel_choice", choice)
			var r := _bridge.command_player("execute_action",
				{"action_id": "confirm_gather_intel",
				 "target": {"kind": "none", "team_id": _intel_target_id, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[Inquiry] %s" % r.get("message", ""))
			_intel_mode = false
			_intel_options = []
	_refresh()

func _build_intel_str() -> String:
	var lines: Array = []
	lines.append("── 打聽 Team%d ──" % _intel_target_id)
	if _intel_options.is_empty():
		lines.append("（無可用問題）")
	for i in range(_intel_options.size()):
		lines.append("[%d] %s" % [i + 1, _intel_options[i].get("label", "?")])
	lines.append("[1~5]選題  [Esc]取消")
	return "\n".join(lines)

func _close_all_modes(keep: String = "") -> void:
	if keep != "interact": _interact_mode = false; _interact_target = -1
	if keep != "member":   _member_mode   = false
	if keep != "inv":      _inv_mode      = false; _inv_selection   = -1
	if keep != "faction":  _faction_mode  = false
	if keep != "outpost":  _outpost_mode  = false
	if keep != "subteam":  _subteam_mode  = false
	if keep != "advisor":  _advisor_mode  = false
	_intel_mode = false

func _check_alerts() -> void:
	var new_alerts: Array = _bridge.get_and_clear_alerts()
	for a in new_alerts:
		var atype: String = a.get("type", "")
		var text: String
		match atype:
			"food_critical":            text = "警告：糧食危急"
			"faction_member_betrayed":  text = "警告：勢力成員叛離"
			_:                          text = "警告：%s" % a.get("description", atype)
		_pending_alerts.append(text)
	if not _pending_alerts.is_empty():
		_alert_bar.text = "[!] %s  [Z 確認]" % _pending_alerts[0]
	else:
		_alert_bar.text = ""
