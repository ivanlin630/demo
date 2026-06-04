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

@onready var _map_label:   RichTextLabel = $VBox/HBox/MapLabel
@onready var _state_label: Label         = $VBox/HBox/StateLabel
@onready var _event_label: Label         = $VBox/EventLabel
@onready var _debug_bar:   Label         = $VBox/DebugBar
@onready var _input_bar:   Label         = $VBox/InputBar

func _ready() -> void:
	_state  = WorldState.new()
	_runner = SimRunner.new()
	_bridge = SimBridge.new(_runner, _state)
	var config := GameSetup.load_config("res://config/default.json")
	GameSetup.setup(_state, config)

	_player_tid = _state.persons[_state.player_id].team_id
	var pt: TeamData = _state.teams[_player_tid]
	_cursor = pt.tile_pos
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

	# 移動完成偵測（move_target=-1,-1 表示到達或取消）
	var pt: TeamData = _state.teams.get(_player_tid)
	if pt and pt.move_target == Vector2i(-1, -1) \
			and _input_bar.text.begins_with("移動中"):
		_bridge.cancel_advance()
		_input_bar.text = ""
		_log_event("Team%d 到達 (%d,%d)" %
			[_player_tid, pt.tile_pos.x, pt.tile_pos.y])

	if result.get("done", false):
		# If interrupted during movement (event stopped advance, not arrival),
		# resume advancing so player reaches destination
		var _pt2: TeamData = _state.teams.get(_player_tid)
		if _input_bar.text.begins_with("移動中") and _pt2 != null \
				and _pt2.move_target != Vector2i(-1, -1):
			_bridge.request_advance(99999)
		else:
			_input_bar.text = ""
	elif not _input_bar.text.begins_with("移動中"):
		_input_bar.text = "推進中 Tick:%d [Esc]停止" % _state.world.current_tick
	_refresh()
	if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
		_bridge.cancel_advance()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return
	if _input_mode:
		_handle_input_mode(event.keycode)
		return
	if _inv_mode:
		_handle_inv_mode(event.keycode)
		return
	if _interact_mode:
		_handle_interact_mode(event.keycode)
		return
	if _faction_mode:
		_handle_faction_mode(event.keycode)
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
	var pt: TeamData       = _state.teams.get(_player_tid)
	var team_items: Array  = _get_team_takeable_items(pt)

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
	var key: int = new_pos.x * 1000 + new_pos.y
	if _state.world.tiles.has(key):
		_cursor = new_pos
	_refresh()

func _refresh() -> void:
	_refresh_snapshot()
	_map_label.text  = TextMapRenderer.render(_state, _player_tid, _cursor)
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
	else:
		var log_lines: Array = []
		var show_count: int = mini(_events.size(), 6)
		for i in range(_events.size() - show_count, _events.size()):
			var e = _events[i]
			log_lines.append("[T%d] %s" % [_state.world.current_tick, str(e)])
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
		var sel_key: int = _selected.x * 1000 + _selected.y
		var sel_tile = _state.world.tiles.get(sel_key)
		lines.append("────────────────")
		if sel_tile:
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.terrain])
			lines.append("  農:%.0f%%  食:%d" % [sel_tile.productivity * 100, int(sel_tile.resources.get("food", 0))])
			# 查 location_context occupants（需已在 _refresh_snapshot 傳 cursor_tile_q/r）
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
		_state.world.current_tick,
		_state.world.current_tick / WorldState.TICKS_PER_DAY])
	var _pending_n: int = _cached_snapshot.get("pending_targets", []).size()
	var _forced_n:  int = 0 if _cached_snapshot.get("forced_interaction", {}).get("interaction_id", "").is_empty() else 1
	if _pending_n > 0 or _forced_n > 0:
		var _hint: String = "[T] 互動"
		if _pending_n > 0: _hint += ": 同格%d隊" % _pending_n
		if _forced_n > 0:  _hint += "  ⚠強制事件"
		lines.append(_hint)
	return "\n".join(lines)

func _build_debug_str() -> String:
	var tick: int  = _state.world.current_tick
	var hour: int  = (tick / WorldState.TICKS_PER_HOUR) % 24
	var day: int   = (tick / WorldState.TICKS_PER_DAY) % 30 + 1
	var month: int = (tick / WorldState.TICKS_PER_MONTH) % 12
	var season_names: Array = ["春","春","春","夏","夏","夏","秋","秋","秋","冬","冬","冬"]
	var season: String = season_names[month]
	var lines: Array = []
	lines.append("[DEBUG] Tick:%d Hour:%d Day:%d Month:%d Season:%s" % [tick, hour, day, month + 1, season])

	var team_strs: Array = []
	for tid in _state.teams:
		var t: TeamData = _state.teams[tid]
		team_strs.append("T%d@(%d,%d)pop=%d %s" % [tid, t.tile_pos.x, t.tile_pos.y, t.population, t.current_task])
	lines.append("Teams: " + " | ".join(team_strs))

	var evt_strs: Array = []
	for i in range(maxi(0, _events.size() - 10), _events.size()):
		var e = _events[i]
		evt_strs.append("[%s]%s" % [str(e.get("type","?")), str(e.get("msg",""))])
	lines.append("Events(last10): " + " | ".join(evt_strs))

	var msg_strs: Array = []
	for i in range(maxi(0, _state.global_messages.size() - 10), _state.global_messages.size()):
		msg_strs.append(str(_state.global_messages[i]))
	lines.append("Msgs(last10): " + " | ".join(msg_strs))

	return "\n".join(lines)

func _build_member_str() -> String:
	var ct: Dictionary = _cached_snapshot.get("controlled_team", {})
	if ct.is_empty(): return "（無玩家 team）"
	var lines: Array = []
	lines.append("── 成員 %s ──" % ct.get("name", "Team?"))

	for m in ct.get("members", []):
		var role_tag: String = "[隊長]" if m.get("role", "") == "leader" else "[成員]"
		var hand1: String = m.get("equipment", {}).get("hand_1", "")
		if hand1.is_empty(): hand1 = "空"
		lines.append("%s %s  裝備:%s  HP:%s" % [role_tag, m.get("name", "?"), hand1, m.get("hp_status", "?")])

	var named_count: int = ct.get("members", []).size()
	var pop: int = ct.get("population", 0)
	var anon: int = maxi(0, pop - named_count)
	var res: Dictionary = ct.get("resources", {})
	var weapons: int = (res.get("weapon_melee_low",   0)
		+ res.get("weapon_melee_high",  0)
		+ res.get("weapon_ranged_low",  0)
		+ res.get("weapon_ranged_high", 0))
	var armed_rate: float = float(weapons) / maxf(float(pop), 1.0)
	lines.append("匿名人口: %d  武裝率: %d%%" % [anon, int(armed_rate * 100)])
	lines.append("── [P/Esc] 關閉 ──")
	return "\n".join(lines)

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
	lines.append("  右手:%s  左手:%s" % [h1 if not h1.is_empty() else "空", h2 if not h2.is_empty() else "空"])
	# body_slots 目前 mapper 未 expose，仍直讀 _state.persons
	var player: PersonData = _state.persons.get(_state.player_id)
	var body_slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var body_names: Array = ["頭", "胸", "右臂", "左臂", "右腿", "左腿"]
	var body_strs: Array = []
	for i in range(body_slots.size()):
		var g: String = player.equipment.get(body_slots[i], {}).get("grade", "") if player else ""
		body_strs.append("%s:%s" % [body_names[i], g if not g.is_empty() else "空"])
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
			var result: Dictionary = _bridge.command_player(act.get("command_name", "execute_action"), act.get("command_args", {}))
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
		var tgt: TeamData = _state.teams.get(_interact_target)
		var tgt_name: String = "Team%d" % _interact_target if tgt else "未知"
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
		var t: TeamData = _state.teams.get(tid)
		if t == null: continue
		var faction_str: String = "獨立" if t.faction_id < 0 else "勢力%d" % t.faction_id
		lines.append("[%d] Team%d @(%d,%d) %s pop:%d" % [
			idx, tid, t.tile_pos.x, t.tile_pos.y, faction_str, t.population])
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
		var pos_v: Vector2i = pos if pos is Vector2i else Vector2i(pos.get("x", 0), pos.get("y", 0))
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
