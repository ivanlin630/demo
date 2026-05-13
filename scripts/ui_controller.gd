extends CanvasLayer
## HUD overlay.
## _ready() builds the UI skeleton; initialize() connects live data.

# ── UI node references (populated in _build_ui) ───────────────────────────────
var _turn_lbl:         Label
var _seed_lbl:         Label
var _map_size_lbl:     Label
var _speed_lbl:        Label
var _mode_lbl:         Label
var _time_system_lbl:  Label
var _time_mode_lbl:    Label
var _outpost_panel:    PanelContainer
var _outpost_title:    Label
var _outpost_stats:    Label
var _outpost_msgs_lbl: Label
var _global_msgs_lbl:  Label
var _battle_lbl:       Label

# ── Debug overlay (toggle with backtick `) ───────────────────────────────────
var _debug_panel:       PanelContainer
var _debug_events_lbl:  Label
var _debug_pending_lbl: Label

# ── Live references (set by initialize) ──────────────────────────────────────
var _world: WorldState
var _main:  Node

func _has_property(obj: Object, property_name: StringName) -> bool:
	for p in obj.get_property_list():
		if p.name == property_name:
			return true
	return false

func _ready() -> void:
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not (event as InputEventKey).pressed:
		return
	var ke := event as InputEventKey
	if ke.keycode == KEY_QUOTELEFT:
		_debug_panel.visible = not _debug_panel.visible
		if _debug_panel.visible:
			_refresh_debug_panel()
		get_viewport().set_input_as_handled()

## Connect to game data.  Call after the WorldState has been created.
func initialize(ws: WorldState, main_node: Node) -> void:
	_world = ws
	_main  = main_node
	main_node.turn_advanced.connect(_on_turn_advanced)
	main_node.outpost_selected.connect(_on_outpost_selected)
	if main_node.has_signal("battle_state_changed"):
		main_node.battle_state_changed.connect(_on_battle_state_changed)
	if main_node.has_signal("simulation_settings_changed"):
		main_node.simulation_settings_changed.connect(_on_simulation_settings_changed)
	_refresh_static()

# ── Signal handlers ───────────────────────────────────────────────────────────

func _format_world_time(tick: int) -> String:
	var seconds_per_tick: int = max(1, int(GameConfig.WORLD_SECONDS_PER_TICK))
	var total_seconds: int = tick * seconds_per_tick
	var total_minutes: int = int(total_seconds / 60)
	var day: int = int(total_minutes / (24 * 60))
	var hour: int = int((total_minutes % (24 * 60)) / 60)
	var minute: int = int(total_minutes % 60)
	return "世界時間: Tk %d (D%d %02d:%02d)" % [tick, day, hour, minute]

func _current_world_tick() -> int:
	if _main != null and _main.has_method("get_world_tick"):
		return int(_main.call("get_world_tick"))
	return _world.current_turn * max(1, int(GameConfig.TURN_TO_TICK))

func _on_turn_advanced(_turn: int) -> void:
	_turn_lbl.text  = "回合: %d | %s" % [_world.current_turn, _format_world_time(_current_world_tick())]
	if _main != null and _main.has_method("get_time_system_name"):
		_time_system_lbl.text = "制度: %s" % str(_main.call("get_time_system_name"))
	if _has_property(_main, &"turns_per_advance"):
		_speed_lbl.text = "推進速度: %d 回合/次" % int(_main.get("turns_per_advance"))
	if _has_property(_main, &"player_active"):
		if bool(_main.get("player_active")):
			var hp_text := ""
			if _has_property(_main, &"player_hp") and _has_property(_main, &"player_lives_used"):
				hp_text = " (HP %d / 接管 %d)" % [
					int(_main.get("player_hp")),
					int(_main.get("player_lives_used"))
				]
			var move_text := ""
			if _main.has_method("get_player_move_tick_cost"):
				move_text = " / 移動 %dTk/格" % int(_main.call("get_player_move_tick_cost"))
			_mode_lbl.text  = "模式: 玩家" + hp_text + move_text
		else:
			_mode_lbl.text  = "模式: 觀察"
	if _has_property(_main, &"simulation_paused") and _has_property(_main, &"seconds_per_turn"):
		_on_simulation_settings_changed(
			bool(_main.get("simulation_paused")),
			float(_main.get("seconds_per_turn"))
		)
	_update_global_messages()
	if _debug_panel != null and _debug_panel.visible:
		_refresh_debug_panel()

func _on_battle_state_changed(active: bool, text: String) -> void:
	if active:
		_battle_lbl.text = text
	else:
		_battle_lbl.text = "（無進行中遭遇戰）"

func _on_simulation_settings_changed(paused: bool, sec_per_turn: float) -> void:
	_time_mode_lbl.text = "時間: %s (%.2fs/回合)" % [
		"暫停" if paused else "運行", sec_per_turn
	]

func _on_outpost_selected(outpost) -> void:
	if outpost == null:
		_outpost_panel.visible = false
		return

	var op := outpost as WorldState.OutpostData
	var f  := _world.get_faction(op.faction_id)
	if f == null:
		return

	_outpost_panel.visible = true
	_outpost_title.text    = "⚑  %s" % f.name

	# Armed group indicator
	var group_type := "武裝型" if f.is_armed_group else "生產型"
	var unrest_note := ""
	if f.unrest_turns > 0:
		unrest_note = "\n⚠ 動盪中（%d 回合）" % f.unrest_turns

	var march_cost := clampi(
		roundi(float(GameConfig.BASE_MOVE_TICK_COST) / f.speed_factor),
		GameConfig.MIN_MOVE_TICK_COST, GameConfig.MAX_MOVE_TICK_COST)

	_outpost_stats.text = (
		"👥 人口: %d\n"
		+ "🍞 食物: %d\n"
		+ "🪵 木材: %d\n"
		+ "⛏  礦石: %d\n"
		+ "⚔  武力: %d\n"
		+ "🛡  安全: %d\n"
		+ "🔨 勞力: %d\n"
		+ "🏘  類型: %s\n"
		+ "💨 行軍速: %.1f（%d tick/格）\n"
		+ "🗺  領地: %d 格%s"
	) % [
		int(f.population), int(f.food),
		int(f.wood),       int(f.ore),
		int(f.military),   int(f.safety),
		int(f.labor),      group_type,
		f.speed_factor,    march_cost,
		f.territory.size(), unrest_note,
	]

	# NPC profiles at this outpost
	var npc_lines: Array = []
	if _main != null and _has_property(_main, &"npc_memory"):
		var nms: NpcMemorySystem = _main.get("npc_memory") as NpcMemorySystem
		if nms != null:
			var profiles: Array = nms.get_faction_profiles(op.faction_id)
			if profiles.size() > 0:
				npc_lines.append("\n── 已知人物 ──")
				for pvar in profiles.slice(0, min(profiles.size(), 4)):
					var p: NpcMemorySystem.NpcProfile = pvar as NpcMemorySystem.NpcProfile
					var mem_count: int = p.memories.size()
					npc_lines.append("• %s (記憶:%d)" % [p.summary(), mem_count])

	var stats_with_npc: String = _outpost_stats.text
	if not npc_lines.is_empty():
		stats_with_npc += "\n" + "\n".join(npc_lines)
	_outpost_stats.text = stats_with_npc

	if op.known_messages.is_empty():
		_outpost_msgs_lbl.text = "已知訊息：（無）"
	else:
		var lines: Array = ["已知訊息："]
		var msgs: Array  = op.known_messages.slice(
			max(0, op.known_messages.size() - 5)
		)
		for m in msgs:
			var msg := m as MessageSystem.MessageData
			lines.append("• [%s] %s (強度 %.2f)" % [msg.type, msg.description, msg.strength])
		_outpost_msgs_lbl.text = "\n".join(lines)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _refresh_static() -> void:
	if _world == null:
		return
	_seed_lbl.text     = "Seed: %d" % _world.seed_value
	_map_size_lbl.text = "地圖: %dx%d" % [_world.map_width, _world.map_height]
	_turn_lbl.text     = "回合: 0 | %s" % _format_world_time(_current_world_tick())
	_mode_lbl.text     = "模式: 觀察"
	if _main != null and _main.has_method("get_time_system_name"):
		_time_system_lbl.text = "制度: %s" % str(_main.call("get_time_system_name"))
	else:
		_time_system_lbl.text = "制度: 半即時制"
	if _main != null and _has_property(_main, &"simulation_paused") and _has_property(_main, &"seconds_per_turn"):
		_on_simulation_settings_changed(
			bool(_main.get("simulation_paused")),
			float(_main.get("seconds_per_turn"))
		)
	else:
		_time_mode_lbl.text = "時間: 運行 (0.35s/回合)"

func _refresh_debug_panel() -> void:
	if _world == null:
		return
	# Column 1: global event log (newest last, up to 20)
	var events := _world.global_messages
	var ev_lines: Array = []
	for i in range(max(0, events.size() - 20), events.size()):
		var msg := events[i] as MessageSystem.MessageData
		ev_lines.append("[T%d][%s] %s (%.2f)" % [
			msg.origin_turn, msg.type, msg.description, msg.strength])
	_debug_events_lbl.text = "\n".join(ev_lines) if not ev_lines.is_empty() else "（無）"

	# Column 2: pending deliveries
	if _main == null or not _has_property(_main, &"message_system"):
		_debug_pending_lbl.text = "（無法存取）"
		return
	var ms := _main.get("message_system") as MessageSystem
	if ms == null:
		_debug_pending_lbl.text = "（無法存取）"
		return
	var pending: Array = ms.get_pending_deliveries()
	var pend_lines: Array = []
	for dvar in pending:
		var d := dvar as MessageSystem.PendingDelivery
		var dest := "outpost#%d" % d.target_outpost_idx
		if d.target_outpost_idx >= 0 and d.target_outpost_idx < _world.outposts.size():
			var op := _world.outposts[d.target_outpost_idx] as WorldState.OutpostData
			var f  := _world.get_faction(op.faction_id)
			if f != null:
				dest = f.name
		pend_lines.append("[到T%d][%s→%s] %s" % [
			d.arrive_turn, d.carrier, dest,
			d.payload.description.substr(0, 24)])
	_debug_pending_lbl.text = "\n".join(pend_lines) if not pend_lines.is_empty() else "（無傳遞中）"

func _update_global_messages() -> void:
	if _world == null:
		return
	if _main != null and _has_property(_main, &"player_active") and bool(_main.get("player_active")):
		if _main.has_method("get_player_visible_messages"):
			var known := _main.call("get_player_visible_messages", 10) as Array
			if known.is_empty():
				_global_msgs_lbl.text = "(尚未從 NPC 獲取任何情報\n進入據點按 E 互動)"
				return
			_global_msgs_lbl.text = "\n".join(known)
			return
	# Observer mode: show recent global events
	var events := _world.global_messages
	if events.is_empty():
		_global_msgs_lbl.text = "（無事件）"
		return
	var n: int = events.size()
	var lines: Array = []
	for i in range(max(0, n - 10), n):
		var msg := events[i] as MessageSystem.MessageData
		lines.append("[T%d][%s] %s" % [msg.origin_turn, msg.type, msg.description])
	_global_msgs_lbl.text = "\n".join(lines)

# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left",   10)
	root.add_theme_constant_override("margin_top",    10)
	root.add_theme_constant_override("margin_right",  10)
	root.add_theme_constant_override("margin_bottom", 10)
	add_child(root)

	var hbox := HBoxContainer.new()
	root.add_child(hbox)

	# ── Left panel (game info + controls) ─────────────────────────────────
	var left := PanelContainer.new()
	left.custom_minimum_size = Vector2(220, 0)
	hbox.add_child(left)

	var lv := VBoxContainer.new()
	left.add_child(lv)

	_turn_lbl     = _lbl("回合: 0")
	_seed_lbl     = _lbl("Seed: ?")
	_map_size_lbl = _lbl("地圖: ?")
	_speed_lbl    = _lbl("推進速度: 1 回合/次")
	_mode_lbl     = _lbl("模式: 觀察")
	_time_system_lbl = _lbl("制度: 半即時制")
	_time_mode_lbl = _lbl("時間: 運行 (0.35s/回合)")
	lv.add_child(_turn_lbl)
	lv.add_child(_seed_lbl)
	lv.add_child(_map_size_lbl)
	lv.add_child(_speed_lbl)
	lv.add_child(_mode_lbl)
	lv.add_child(_time_system_lbl)
	lv.add_child(_time_mode_lbl)

	var hint := Label.new()
	hint.text = (
		"\n[操作說明]\n"
		+ "T       切換半即時/回合制\n"
		+ "PgUp/Dn 或 滑鼠滾輪 縮放\n"
		+ "Space   推進回合\n"
		+ "+/-     調整速度\n"
		+ "P       暫停/繼續時間\n"
		+ "[/]     調整時間流速\n"
		+ "B       嘗試觸發遭遇戰\n"
		+ "Enter   生成玩家\n"
		+ "數字鍵盤 7/9/4/6/1/3 六角移動\n"
		+ "(相容) A/D + Q/R/Z/X 也可移動\n"
		+ "(回合制) 每移動一格會推進世界時間\n"
		+ "E       互動/查看據點\n"
		+ "`       訊息 Debug 視窗"
	)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(hint)

	# ── Spacer ─────────────────────────────────────────────────────────────
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(sp)

	# ── Right panels ───────────────────────────────────────────────────────
	var rv := VBoxContainer.new()
	hbox.add_child(rv)

	# Outpost info panel (hidden until an outpost is selected)
	_outpost_panel                  = PanelContainer.new()
	_outpost_panel.custom_minimum_size = Vector2(280, 0)
	_outpost_panel.visible          = false
	rv.add_child(_outpost_panel)

	var ov := VBoxContainer.new()
	_outpost_panel.add_child(ov)

	_outpost_title    = _lbl("據點資訊")
	_outpost_stats    = _lbl("")
	_outpost_msgs_lbl = _lbl("")
	_outpost_stats.autowrap_mode    = TextServer.AUTOWRAP_WORD_SMART
	_outpost_msgs_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ov.add_child(_outpost_title)
	ov.add_child(_outpost_stats)
	ov.add_child(_outpost_msgs_lbl)

	# Global recent messages panel
	var mp := PanelContainer.new()
	mp.custom_minimum_size = Vector2(280, 0)
	rv.add_child(mp)

	var mv := VBoxContainer.new()
	mp.add_child(mv)

	mv.add_child(_lbl("玩家情報日誌（E鍵接觸 NPC 獲取）"))
	_global_msgs_lbl                = _lbl("（無訊息）")
	_global_msgs_lbl.autowrap_mode  = TextServer.AUTOWRAP_WORD_SMART
	mv.add_child(_global_msgs_lbl)

	var bp := PanelContainer.new()
	bp.custom_minimum_size = Vector2(280, 0)
	rv.add_child(bp)

	var bv := VBoxContainer.new()
	bp.add_child(bv)
	bv.add_child(_lbl("遭遇戰狀態"))
	_battle_lbl = _lbl("（無進行中遭遇戰）")
	_battle_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bv.add_child(_battle_lbl)
	# ── Debug overlay (hidden; toggle with ` backtick) ───────────────────────
	_debug_panel               = PanelContainer.new()
	_debug_panel.anchor_left   = 0.0
	_debug_panel.anchor_top    = 0.5
	_debug_panel.anchor_right  = 1.0
	_debug_panel.anchor_bottom = 1.0
	_debug_panel.visible       = false
	add_child(_debug_panel)

	var dbv := VBoxContainer.new()
	_debug_panel.add_child(dbv)
	dbv.add_child(_lbl("═══ 訊息系統 Debug（` 鍵切換） ═══"))

	var dbh := HBoxContainer.new()
	dbh.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dbv.add_child(dbh)

	var db_col1 := VBoxContainer.new()
	db_col1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dbh.add_child(db_col1)
	db_col1.add_child(_lbl("【全域事件（最近 20 條）】"))
	_debug_events_lbl              = _lbl("")
	_debug_events_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	db_col1.add_child(_debug_events_lbl)

	var db_col2 := VBoxContainer.new()
	db_col2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dbh.add_child(db_col2)
	db_col2.add_child(_lbl("【傳遞中 Pending】"))
	_debug_pending_lbl              = _lbl("")
	_debug_pending_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	db_col2.add_child(_debug_pending_lbl)

static func _lbl(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l
