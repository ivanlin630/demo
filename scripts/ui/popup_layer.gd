# scripts/ui/popup_layer.gd
extends CanvasLayer

var _bridge: SimBridge
var _current_popup: Control = null

func setup(bridge: SimBridge) -> void:
	_bridge = bridge

func _close_current() -> void:
	if _current_popup:
		_current_popup.queue_free()
		_current_popup = null

func show_members(team_id: int) -> void:
	_close_current()
	var state: WorldState = _bridge.get_state()
	var team: TeamData    = state.teams.get(team_id)
	if team == null: return

	var popup := _make_base_popup("成員 — Team%d" % team_id)
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	# Leader + named members
	var named_ids: Array = []
	if team.leader_id >= 0:
		named_ids.append(team.leader_id)
	for pid in team.named_members:
		if pid != team.leader_id:
			named_ids.append(pid)

	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var role_str: String = "隊長" if pid == team.leader_id else "成員"
		var health_str: String = _health_summary(p)
		var weapon_str: String = _weapon_summary(p)
		var lbl := Label.new()
		lbl.text = "[%s] %s  裝備:%s  狀態:%s" % [role_str, p.person_name if p.person_name != "" else "P%d" % pid, weapon_str, health_str]
		vbox.add_child(lbl)

	# Anonymous population
	var anon_lbl := Label.new()
	var armed: int = int(team.resources.get("weapon_melee_low", 0)) + int(team.resources.get("weapon_melee_high", 0)) + int(team.resources.get("weapon_ranged_low", 0)) + int(team.resources.get("weapon_ranged_high", 0))
	var ratio: float = float(armed) / maxf(float(team.population), 1.0)
	anon_lbl.text = "匿名人口: %d  武裝率: %.0f%%" % [team.population, ratio * 100]
	vbox.add_child(anon_lbl)

	_current_popup = popup
	add_child(popup)

func _health_summary(p: PersonData) -> String:
	var worst: String = "healthy"
	for part in p.body_parts:
		var s: String = p.body_parts[part].get("status", "healthy")
		if s == "severed" or s == "critical":
			return "重傷"
		if s == "wounded":
			worst = "wounded"
	return "輕傷" if worst == "wounded" else "正常"

func _weapon_summary(p: PersonData) -> String:
	var h: Dictionary = p.equipment.get("hand_1", {})
	if h.get("type", "none") != "none":
		return h.get("grade", "空")
	return "空"

func show_history(team_id: int) -> void:
	_close_current()
	var state: WorldState = _bridge.get_state()
	var popup := _make_base_popup("歷史 — Team%d" % team_id)
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	var count: int = 0
	for msg in state.global_messages:
		var m: MessageData = msg as MessageData
		if m == null: continue
		if m.origin_team_id != team_id: continue
		var lbl := Label.new()
		lbl.text = "[T%d] %s" % [m.origin_tick, m.description]
		vbox.add_child(lbl)
		count += 1
		if count >= 50: break

	if count == 0:
		var lbl := Label.new(); lbl.text = "（無記錄）"; vbox.add_child(lbl)

	_current_popup = popup
	add_child(popup)

func show_inventory() -> void:
	_close_current()
	var state: WorldState = _bridge.get_state()
	if state.player_id < 0: return
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return
	var ptid: int = _bridge.get_player_team_id()
	var team: TeamData = state.teams.get(ptid)

	var popup := _make_base_popup("物品欄 + 裝備")
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	# Equipment section
	var eq_lbl := Label.new(); eq_lbl.text = "── 裝備欄 ──"; vbox.add_child(eq_lbl)
	var slots: Array = ["head","torso","right_arm","left_arm","right_leg","left_leg","hand_1","hand_2"]
	for slot in slots:
		var item: Dictionary = p.equipment.get(slot, {})
		var grade: String = item.get("grade", "")
		var display: String = grade if grade != "" else "空"
		var row := HBoxContainer.new()
		var name_lbl := Label.new()
		name_lbl.text = "%s: %s" % [slot, display]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)
		if grade != "":
			var unequip_btn := Button.new(); unequip_btn.text = "卸下"
			var s: String = slot
			unequip_btn.pressed.connect(func(): _do_unequip(s))
			row.add_child(unequip_btn)
		vbox.add_child(row)

	# Backpack section
	var inv: Array = state.player_state.get("inventory", [])
	var inv_lbl := Label.new()
	inv_lbl.text = "── 背包 (%d 格) ──" % inv.size()
	vbox.add_child(inv_lbl)
	for item in inv:
		var grade: String = item.get("grade", "")
		var qty: int = item.get("qty", 1)
		var row := HBoxContainer.new()
		var name_lbl := Label.new()
		name_lbl.text = "%s × %d" % [grade, qty]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)
		_add_item_action_buttons(row, grade, team)
		vbox.add_child(row)

	# Take from team section
	if team != null:
		var take_lbl := Label.new(); take_lbl.text = "── 從 Team 取出 ──"; vbox.add_child(take_lbl)
		var takeable: Array = ["weapon_melee_low","weapon_melee_high","weapon_ranged_low","weapon_ranged_high",
							   "armor_low","armor_high","food","medicine","tools","arrows"]
		for grade in takeable:
			var avail: int = int(team.resources.get(grade, 0))
			if avail <= 0: continue
			var row := HBoxContainer.new()
			var name_lbl := Label.new()
			name_lbl.text = "%s: %d" % [grade, avail]
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(name_lbl)
			var take_btn := Button.new(); take_btn.text = "取1"
			var g: String = grade
			take_btn.pressed.connect(func(): _do_take_from_team(g, 1))
			row.add_child(take_btn)
			vbox.add_child(row)

	_current_popup = popup
	add_child(popup)

# pending_targets: Array of {target_type, target_id, display_name, is_valid}
# on_select: Callable(team_id: int)
func show_interaction(pending_targets: Array, on_select: Callable) -> void:
	_close_current()
	var popup := _make_base_popup("互動目標")
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	for tgt in pending_targets:
		if not tgt.get("is_valid", false): continue
		var tid: int = tgt.get("target_id", -1)
		var btn := Button.new()
		btn.text = tgt.get("display_name", "Team%d" % tid)
		var cap_tid: int = tid
		btn.pressed.connect(func():
			_close_current()
			on_select.call(cap_tid))
		vbox.add_child(btn)

	if vbox.get_child_count() == 0:
		var lbl := Label.new(); lbl.text = "（無可用目標）"; vbox.add_child(lbl)

	_current_popup = popup; add_child(popup)

# actions: Array of available_action DTOs from player_query_api
# on_execute: Callable(cmd_name: String, cmd_args: Dictionary)
func show_action_menu(target_team_id: int, actions: Array, on_execute: Callable) -> void:
	_close_current()
	var popup := _make_base_popup("對 Team%d 的行動" % target_team_id)
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	for act in actions:
		# Skip forced_* actions here (handled by show_forced_event)
		if str(act.get("action_id", "")).begins_with("forced_"): continue
		var btn := Button.new()
		btn.text = act.get("label", act.get("action_id", "?"))
		btn.disabled = not act.get("enabled", true)
		var tooltip: String = act.get("disabled_reason", "")
		if tooltip != "": btn.tooltip_text = tooltip
		var cmd_name: String = act.get("command_name", "")
		var cmd_args: Dictionary = act.get("command_args", {})
		btn.pressed.connect(func():
			_close_current()
			on_execute.call(cmd_name, cmd_args))
		vbox.add_child(btn)

	var cancel_btn := Button.new(); cancel_btn.text = "取消"
	cancel_btn.pressed.connect(_close_current)
	vbox.add_child(cancel_btn)

	_current_popup = popup; add_child(popup)

# fi_dto: forced_interaction dict from snapshot
# on_respond: Callable(cmd_args: Dictionary)
func show_forced_event(fi_dto: Dictionary, on_respond: Callable) -> void:
	_close_current()
	var popup := _make_base_popup("強制事件")
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	var msg_lbl := Label.new()
	msg_lbl.text = fi_dto.get("message", "")
	msg_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(msg_lbl)

	vbox.add_child(HSeparator.new())

	for resp in fi_dto.get("responses", []):
		var btn := Button.new()
		btn.text = resp.get("label", resp.get("response_id", "?"))
		var cap_args: Dictionary = resp.get("command_args", {})
		btn.pressed.connect(func():
			_close_current()
			on_respond.call(cap_args))
		vbox.add_child(btn)

	_current_popup = popup; add_child(popup)

func show_loot_panel(loot_preview: Dictionary, take_fn: Callable, leave_fn: Callable) -> void:
	_close_current()
	var popup := _make_base_popup("戰利品")
	var vbox: VBoxContainer = popup.get_node("VBox/Scroll/Content")

	if loot_preview.is_empty():
		var lbl := Label.new(); lbl.text = "（無戰利品）"; vbox.add_child(lbl)
	else:
		for rk in loot_preview:
			var lbl := Label.new()
			lbl.text = "%s: %.0f" % [rk, float(loot_preview[rk])]
			vbox.add_child(lbl)

	vbox.add_child(HSeparator.new())

	var take_btn := Button.new(); take_btn.text = "✓ 收取戰利品"
	take_btn.pressed.connect(func(): _close_current(); take_fn.call())
	vbox.add_child(take_btn)

	var leave_btn := Button.new(); leave_btn.text = "✗ 放棄"
	leave_btn.pressed.connect(func(): _close_current(); leave_fn.call())
	vbox.add_child(leave_btn)

	_current_popup = popup; add_child(popup)

func _add_item_action_buttons(row: Node, grade: String, team: TeamData) -> void:
	if grade.begins_with("weapon_"):
		var b1 := Button.new(); b1.text = "裝→右手"; row.add_child(b1)
		var b2 := Button.new(); b2.text = "裝→左手"; row.add_child(b2)
		b1.pressed.connect(func(): _do_equip(grade, "hand_1"))
		b2.pressed.connect(func(): _do_equip(grade, "hand_2"))
	elif grade.begins_with("armor_"):
		var b1 := Button.new(); b1.text = "裝→護甲"; row.add_child(b1)
		b1.pressed.connect(func(): _do_equip(grade, "torso"))
	var store_btn := Button.new(); store_btn.text = "存入"
	var g: String = grade
	store_btn.pressed.connect(func(): _do_store_to_team(g, 1))
	row.add_child(store_btn)

func _do_equip(grade: String, slot: String) -> void:
	_bridge.command_player("equip_item", {"slot_id": slot, "item_grade": grade})
	_close_current(); show_inventory()

func _do_unequip(slot: String) -> void:
	_bridge.command_player("unequip_item", {"slot_id": slot})
	_close_current(); show_inventory()

func _do_take_from_team(grade: String, qty: int) -> void:
	_bridge.command_player("take_team_item", {"item_grade": grade, "qty": qty})
	_close_current(); show_inventory()

func _do_store_to_team(grade: String, qty: int) -> void:
	_bridge.command_player("deposit_item", {"item_grade": grade, "qty": qty})
	_close_current(); show_inventory()

# ── base popup builder ─────────────────────────────────────

func _make_base_popup(title: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 500)
	panel.size     = Vector2(400, 500)   # explicit: CanvasLayer child won't auto-layout
	panel.position = Vector2(200, 100)

	var vbox := VBoxContainer.new(); vbox.name = "VBox"; panel.add_child(vbox)

	var title_row := HBoxContainer.new(); vbox.add_child(title_row)
	var title_lbl := Label.new(); title_lbl.text = title
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_lbl)
	var close_btn := Button.new(); close_btn.text = "X"
	close_btn.pressed.connect(_close_current)
	title_row.add_child(close_btn)

	var scroll := ScrollContainer.new(); scroll.name = "Scroll"
	scroll.custom_minimum_size = Vector2(380, 420)
	vbox.add_child(scroll)
	var content := VBoxContainer.new(); content.name = "Content"; scroll.add_child(content)

	return panel
