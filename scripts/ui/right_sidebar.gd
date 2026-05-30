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
		_lbl_player_task.text = ""
		_lbl_player_pop.text  = ""
		_lbl_player_res.text  = ""
		return

	var faction_str: String = "獨立"
	if team.faction_id >= 0:
		faction_str = "勢力%d" % team.faction_id
	_lbl_player_team.text = "Team%d [%s] 位置:(%d,%d)" % [
		team.team_id, faction_str, team.tile_pos.x, team.tile_pos.y]
	_lbl_player_task.text = "任務: %s  疲勞: %.0f%%" % [
		team.current_task, team.fatigue * 100.0]
	_lbl_player_pop.text  = "人口: %d | 受傷: %d | 未成年: %d" % [
		team.population, team.wounded, team.minor_population]

	var player_person: PersonData = state.persons.get(state.player_id)
	var person_lines: Array = []
	if player_person:
		var worst: int = 0
		for part in player_person.body_parts:
			var s: String = player_person.body_parts[part].get("status", "healthy")
			if s == "severed" or s == "critical": worst = 2
			elif s == "wounded" and worst < 1: worst = 1
		var hp_str: String = ["正常", "輕傷", "重傷"][worst]
		person_lines.append("HP: %s  忠誠: %.0f%%  壓力: %.0f%%" % [
			hp_str, player_person.loyalty * 100.0, player_person.stress * 100.0])
		var sk_parts: Array = []
		for sk in player_person.skills:
			var v: float = float(player_person.skills[sk])
			if v > 0.01:
				sk_parts.append("%s:%.2f" % [sk, v])
		if sk_parts.size() > 0:
			person_lines.append("技能: " + ", ".join(sk_parts))

	var res_parts: Array = []
	for rk in team.resources:
		var v: float = float(team.resources.get(rk, 0))
		if v > 0:
			res_parts.append("%s:%s" % [rk, str(int(v)) if float(v) == int(v) else "%.1f" % v])

	var all_lines: Array = person_lines
	all_lines.append("─ 資源 ─")
	all_lines.append_array(res_parts if res_parts.size() <= 8 else res_parts.slice(0, 8))
	_lbl_player_res.text = "\n".join(all_lines)

func show_tile(pos: Vector2i) -> void:
	_current_tile = pos

func _find_team_at(pos: Vector2i, state: WorldState) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == pos: return t
	return null

func _on_move() -> void:
	if _current_tile != Vector2i(-1, -1):
		set_move_target.emit(_current_tile)

func _on_members() -> void:
	var ptid: int = _bridge.get_player_team_id()
	if ptid >= 0: open_members.emit(ptid)

func _on_items() -> void:
	open_inventory.emit()

func _on_history() -> void:
	var ptid: int = _bridge.get_player_team_id()
	if ptid >= 0: open_history.emit(ptid)
