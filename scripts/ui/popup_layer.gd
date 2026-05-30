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
	PlayerSystem.new().equip_item(_bridge.get_state(), slot, grade)
	_close_current(); show_inventory()

func _do_unequip(slot: String) -> void:
	PlayerSystem.new().unequip_item(_bridge.get_state(), slot)
	_close_current(); show_inventory()

func _do_take_from_team(grade: String, qty: int) -> void:
	PlayerSystem.new().take_from_team(_bridge.get_state(), grade, qty)
	_close_current(); show_inventory()

func _do_store_to_team(grade: String, qty: int) -> void:
	PlayerSystem.new().deposit_to_team(_bridge.get_state(), grade, qty)
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
