# scripts/ui/right_sidebar.gd
extends VBoxContainer

var _bridge: SimBridge
var _current_tile: Vector2i = Vector2i(-1, -1)

# player info labels
var _lbl_player_team:  Label
var _lbl_player_task:  Label
var _lbl_player_pop:   Label
var _lbl_player_res:   Label

signal open_members(team_id: int)
signal open_inventory()
signal open_history(team_id: int)
signal set_move_target(pos: Vector2i)

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_build_ui()
	refresh_player()

func _build_ui() -> void:
	# ── 玩家隊固定資訊 ────────────────────────
	var hdr := Label.new()
	hdr.text = "── 玩家隊 ──"
	add_child(hdr)

	_lbl_player_team = Label.new()
	_lbl_player_team.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_lbl_player_team)

	_lbl_player_task = Label.new()
	add_child(_lbl_player_task)

	_lbl_player_pop = Label.new()
	add_child(_lbl_player_pop)

	_lbl_player_res = Label.new()
	_lbl_player_res.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(_lbl_player_res)

	# ── 行動按鈕 ─────────────────────────────
	var sep := HSeparator.new()
	add_child(sep)

	var row1 := HBoxContainer.new()
	add_child(row1)
	_make_btn("移動", row1).pressed.connect(_on_move)
	_make_btn("命令", row1)
	_make_btn("互動", row1)

	var row2 := HBoxContainer.new()
	add_child(row2)
	_make_btn("成員", row2).pressed.connect(_on_members)
	_make_btn("物品", row2).pressed.connect(_on_items)
	_make_btn("歷史", row2).pressed.connect(_on_history)

func _make_btn(label: String, parent: Node) -> Button:
	var b := Button.new()
	b.text = label
	parent.add_child(b)
	return b

func refresh_player() -> void:
	if _bridge == null or _lbl_player_team == null: return
	var state: WorldState = _bridge.get_state()
	var ptid: int = _bridge.get_player_team_id()
	var team: TeamData = state.teams.get(ptid)
	if team == null:
		_lbl_player_team.text = "（無玩家隊）"
		return

	var faction_str: String = "獨立"
	if team.faction_id >= 0:
		var f = state.factions.get(team.faction_id)
		faction_str = "勢力%d" % team.faction_id if f else "勢力?"

	_lbl_player_team.text = "Team%d [%s]" % [team.team_id, faction_str]
	_lbl_player_task.text = "任務: %s" % team.current_task
	_lbl_player_pop.text  = "人口: %d | 受傷: %d" % [team.population, team.wounded]

	var res_parts: Array = []
	for key in ["food", "coin", "material", "weapon_melee_low", "armor_low"]:
		var v = team.resources.get(key, 0)
		if float(v) > 0:
			res_parts.append("%s:%s" % [key, str(v)])
	_lbl_player_res.text = "\n".join(res_parts) if res_parts.size() > 0 else "（無資源）"

func show_tile(pos: Vector2i) -> void:
	_current_tile = pos

func _find_team_at(pos: Vector2i, state: WorldState) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == pos: return t
	return null

func _on_move() -> void:
	if _current_tile.x >= 0:
		set_move_target.emit(_current_tile)

func _on_members() -> void:
	var ptid: int = _bridge.get_player_team_id()
	if ptid >= 0: open_members.emit(ptid)

func _on_items() -> void:
	open_inventory.emit()

func _on_history() -> void:
	var ptid: int = _bridge.get_player_team_id()
	if ptid >= 0: open_history.emit(ptid)
