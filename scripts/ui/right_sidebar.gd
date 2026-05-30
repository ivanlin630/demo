# scripts/ui/right_sidebar.gd
extends VBoxContainer

var _bridge: SimBridge
var _current_tile: Vector2i = Vector2i(-1, -1)

var _lbl_name:      Label
var _lbl_faction:   Label
var _lbl_pos:       Label
var _lbl_resources: Label
var _btn_move:      Button

signal open_members(team_id: int)
signal open_inventory()
signal open_history(team_id: int)
signal set_move_target(pos: Vector2i)

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_build_ui()

func _build_ui() -> void:
	_lbl_name = Label.new(); _lbl_name.name = "TeamName"; add_child(_lbl_name)
	_lbl_faction = Label.new(); _lbl_faction.name = "FactionLabel"; add_child(_lbl_faction)
	_lbl_pos = Label.new(); _lbl_pos.name = "PosLabel"; add_child(_lbl_pos)
	_lbl_resources = Label.new(); _lbl_resources.name = "ResourcesLabel"
	_lbl_resources.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_lbl_resources)

	var row1 := HBoxContainer.new(); row1.name = "BtnRow"; add_child(row1)
	_btn_move = _make_btn("移動", row1); _btn_move.pressed.connect(_on_move)
	_make_btn("命令", row1)
	_make_btn("互動", row1)

	var row2 := HBoxContainer.new(); row2.name = "BtnRow2"; add_child(row2)
	var btn_members := _make_btn("成員", row2); btn_members.pressed.connect(_on_members)
	var btn_items   := _make_btn("物品", row2); btn_items.pressed.connect(_on_items)
	var btn_history := _make_btn("歷史", row2); btn_history.pressed.connect(_on_history)

func _make_btn(label: String, parent: Node) -> Button:
	var b := Button.new(); b.text = label; parent.add_child(b); return b

func show_tile(pos: Vector2i) -> void:
	_current_tile = pos
	var state: WorldState = _bridge.get_state()
	var team: TeamData = _find_team_at(pos, state)
	if team == null:
		_lbl_name.text     = "（無隊伍）"
		_lbl_faction.text  = ""
		_lbl_pos.text      = "(%d, %d)" % [pos.x, pos.y]
		_lbl_resources.text = ""
		return
	_lbl_name.text = "Team%d" % team.team_id
	var faction_str: String = "獨立"
	if team.faction_id >= 0:
		var f = state.factions.get(team.faction_id)
		faction_str = "勢力%d" % team.faction_id if f else "勢力?"
	_lbl_faction.text = faction_str
	_lbl_pos.text = "(%d, %d)" % [pos.x, pos.y]
	var res_parts: Array = []
	for key in team.resources:
		var v = team.resources[key]
		if float(v) > 0:
			res_parts.append("%s: %s" % [key, str(v)])
	_lbl_resources.text = "\n".join(res_parts)

func _find_team_at(pos: Vector2i, state: WorldState) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == pos: return t
	return null

func _on_move() -> void:
	if _current_tile.x >= 0:
		set_move_target.emit(_current_tile)

func _on_members() -> void:
	var state: WorldState = _bridge.get_state()
	var team: TeamData = _find_team_at(_current_tile, state)
	if team: open_members.emit(team.team_id)

func _on_items() -> void:
	open_inventory.emit()

func _on_history() -> void:
	var state: WorldState = _bridge.get_state()
	var team: TeamData = _find_team_at(_current_tile, state)
	if team: open_history.emit(team.team_id)
