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

var _interact_mode:   bool = false
var _interact_target: int  = -1
# -1 = 目標/事件選擇階段；>= 0 = 已選 pending target，顯示行動清單
var _player_cmd: PlayerCommandSystem = PlayerCommandSystem.new()
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
	_player_cmd = PlayerCommandSystem.new()

	var config := GameSetup.load_config("res://config/default.json")
	GameSetup.setup(_state, config)

	_player_tid = _state.persons[_state.player_id].team_id
	var pt: TeamData = _state.teams[_player_tid]
	_cursor = pt.tile_pos
	_refresh()

func _refresh_snapshot() -> void:
	_cached_snapshot = _bridge.query_player()

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
		KEY_T:
			_interact_mode = not _interact_mode
			if _interact_mode:
				if _inv_mode: _inv_mode = false
				if _member_mode: _member_mode = false
				_interact_target = -1
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
				_bridge.request_advance(n)
				_refresh()
		KEY_ESCAPE:
			_input_mode = false
			_input_buffer = ""
			_input_bar.text = ""
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
	_debug_bar.text  = _build_debug_str()

	if _interact_mode:
		_event_label.text = _build_interact_str()
	elif _member_mode:
		_event_label.text = _build_member_str()
	elif _inv_mode:
		_event_label.text = _build_inv_str()
	else:
		var log_lines: Array = []
		var show_count: int = mini(_events.size(), 6)
		for i in range(_events.size() - show_count, _events.size()):
			var e = _events[i]
			log_lines.append("[T%d] %s" % [_state.world.current_tick, str(e)])
		_event_label.text = "\n".join(log_lines)

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
	var discovered: Array = _state.team_discovered.get(_player_tid, [])
	for tid in _state.teams:
		if tid == _player_tid: continue
		var t: TeamData = _state.teams[tid]
		if t.tile_pos.x * 1000 + t.tile_pos.y == tile_key and discovered.has(tid):
			return tid
	return -1

func _build_state_str() -> String:
	var pt: TeamData = _state.teams.get(_player_tid)
	if pt == null: return "（無玩家 team）"
	var lines: Array = []

	var faction_name: String = "獨立"
	if pt.faction_id >= 0 and _state.factions.has(pt.faction_id):
		faction_name = "勢力%d" % pt.faction_id
	lines.append("Team%d @ (%d,%d) [%s]" % [_player_tid, pt.tile_pos.x, pt.tile_pos.y, faction_name])
	lines.append("任務: %s  疲勞: %d%%" % [pt.current_task, int(pt.fatigue * 100)])
	lines.append("人口: %d | 未成年: %d" % [pt.population, pt.minor_population])

	var player: PersonData = _state.persons.get(_state.player_id)
	if player:
		lines.append("────────────────")
		lines.append("玩家: %s  HP:%s" % [player.person_name, _get_hp_status(player)])
		var skill_parts: Array = []
		for sk in player.skills:
			var sv: float = float(player.skills[sk])
			if sv > 0.01:
				skill_parts.append("%s:%.2f" % [sk, sv])
		if not skill_parts.is_empty():
			lines.append("  " + " ".join(skill_parts))

	var res: Dictionary = pt.resources
	lines.append("────────────────")
	lines.append("資源:")
	lines.append("  食:%d 幣:%d 材:%d" % [int(res.get("food", 0)), int(res.get("coin", 0)), int(res.get("material", 0))])
	lines.append("  低武:%d 高武:%d" % [int(res.get("weapon_melee_low", 0)), int(res.get("weapon_melee_high", 0))])
	lines.append("  低甲:%d 高甲:%d" % [int(res.get("armor_low", 0)), int(res.get("armor_high", 0))])
	lines.append("  藥:%d 工:%d" % [int(res.get("medicine", 0)), int(res.get("tools", 0))])

	if _selected != Vector2i(-1, -1):
		var sel_key: int = _selected.x * 1000 + _selected.y
		var sel_tile = _state.world.tiles.get(sel_key)
		lines.append("────────────────")
		if sel_tile:
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.terrain])
			lines.append("  農:%.0f%%  食:%d" % [sel_tile.productivity * 100, int(sel_tile.resources.get("food", 0))])
			var sel_tid: int = _visible_team_at(sel_key)
			if sel_tid >= 0:
				var sel_t: TeamData = _state.teams[sel_tid]
				var sel_f: String   = "獨立" if sel_t.faction_id < 0 else "勢力%d" % sel_t.faction_id
				lines.append("  Team%d [%s] 人口:%d" % [sel_tid, sel_f, sel_t.population])
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
	var pt: TeamData = _state.teams.get(_player_tid)
	if pt == null: return "（無玩家 team）"
	var lines: Array = []
	lines.append("── 成員 Team%d ──" % _player_tid)

	var leader: PersonData = _state.persons.get(pt.leader_id)
	if leader:
		var hand1: String = leader.equipment.get("hand_1", {}).get("grade", "")
		if hand1.is_empty(): hand1 = "空"
		lines.append("[隊長] %s  裝備:%s  HP:%s" % [leader.person_name, hand1, _get_hp_status(leader)])

	for pid in pt.named_members:
		var p: PersonData = _state.persons.get(pid)
		if p == null: continue
		var hand1: String = p.equipment.get("hand_1", {}).get("grade", "")
		if hand1.is_empty(): hand1 = "空"
		lines.append("[成員] %s  裝備:%s  HP:%s" % [p.person_name, hand1, _get_hp_status(p)])

	var named_count: int = (1 if pt.leader_id >= 0 else 0) + pt.named_members.size()
	var anon: int = maxi(0, pt.population - named_count)
	var weapons: int = (int(pt.resources.get("weapon_melee_low",   0))
		+ int(pt.resources.get("weapon_melee_high",  0))
		+ int(pt.resources.get("weapon_ranged_low",  0))
		+ int(pt.resources.get("weapon_ranged_high", 0)))
	var armed_rate: float = float(weapons) / maxf(float(pt.population), 1.0)
	lines.append("匿名人口: %d  武裝率: %d%%" % [anon, int(armed_rate * 100)])
	lines.append("── [P/Esc] 關閉 ──")
	return "\n".join(lines)

func _get_team_takeable_items(_pt: TeamData) -> Array:
	return ["weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high",
		"armor_low", "armor_high", "medicine", "tools"]

func _build_inv_str() -> String:
	var player: PersonData = _state.persons.get(_state.player_id)
	var pt: TeamData       = _state.teams.get(_player_tid)
	if player == null or pt == null: return "（無資料）"
	var lines: Array = []

	lines.append("── 裝備 ──")
	var h1: String = player.equipment.get("hand_1", {}).get("grade", "")
	var h2: String = player.equipment.get("hand_2", {}).get("grade", "")
	lines.append("  右手:%s  左手:%s" % [h1 if not h1.is_empty() else "空", h2 if not h2.is_empty() else "空"])
	var body_slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var body_names: Array = ["頭", "胸", "右臂", "左臂", "右腿", "左腿"]
	var body_strs: Array = []
	for i in range(body_slots.size()):
		var g: String = player.equipment.get(body_slots[i], {}).get("grade", "")
		body_strs.append("%s:%s" % [body_names[i], g if not g.is_empty() else "空"])
	lines.append("  " + " ".join(body_strs))

	var inv: Array = _cached_snapshot.get("inventory_state", {}).get("inventory_items", [])
	lines.append("── 背包 (%d/%d) ──" % [inv.size(), PlayerSystem.PLAYER_INVENTORY_MAX_SLOTS])
	for i in range(inv.size()):
		var item = inv[i]
		var prefix: String = "[%d]*" % (i + 1) if _inv_selection == i else "[%d]" % (i + 1)
		lines.append("  %s %s × %d" % [prefix, item.get("grade", "?"), item.get("qty", 0)])

	var team_items: Array = _get_team_takeable_items(pt)
	lines.append("── 從 Team 取出 ──")
	for i in range(team_items.size()):
		var idx: int = inv.size() + i
		var prefix: String = "[T%d]*" % (i + 1) if _inv_selection == idx else "[T%d]" % (i + 1)
		var qty: int = int(pt.resources.get(team_items[i], 0))
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
		var actions: Array[String] = _player_cmd.get_available_actions(_state, _interact_target)
		if num < actions.size():
			var result: Dictionary = _bridge.command_player("execute_action", {"target_id": _interact_target, "action_id": actions[num]})
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
		var actions: Array[String] = _player_cmd.get_available_actions(_state, _interact_target)
		var row: String = ""
		for i in range(actions.size()):
			row += "[%d]%s  " % [i + 1, actions[i]]
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
