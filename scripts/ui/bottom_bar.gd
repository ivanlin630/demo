# scripts/ui/bottom_bar.gd
extends HBoxContainer

const MAX_MESSAGES: int = 50

var _bridge: SimBridge
var _tile_label:  Label
var _msg_label:   Label
var _messages:    Array = []

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_build_ui()

func _build_ui() -> void:
	var tile_panel := PanelContainer.new()
	tile_panel.custom_minimum_size = Vector2(220, 85)
	_tile_label = Label.new()
	_tile_label.text = "（點選圖塊查看資訊）"
	_tile_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	tile_panel.add_child(_tile_label)
	add_child(tile_panel)

	var msg_panel := PanelContainer.new()
	msg_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_msg_label = Label.new()
	_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_msg_label.text = "訊息欄"
	msg_panel.add_child(_msg_label)
	add_child(msg_panel)

func show_tile_info(pos: Vector2i) -> void:
	if _bridge == null: return
	var state: WorldState = _bridge.get_state()
	var player_tid: int = _bridge.get_player_team_id()
	var lines: Array = []

	var dist: int = 999
	var player_team: TeamData = state.teams.get(player_tid) if player_tid >= 0 else null
	if player_team:
		var dx: int = pos.x - player_team.tile_pos.x
		var dy: int = pos.y - player_team.tile_pos.y
		dist = (abs(dx) + abs(dx + dy) + abs(dy)) / 2

	const VISION_RADIUS: int = 3
	var in_vision: bool = dist <= VISION_RADIUS
	var key: int = pos.x * 1000 + pos.y
	var tile: HexTileData = state.world.tiles.get(key)
	var discovered: Array = state.team_discovered.get(player_tid, []) if player_tid >= 0 else []

	if tile == null:
		lines.append("(%d,%d) 地圖外" % [pos.x, pos.y])
		_tile_label.text = "\n".join(lines)
		return

	if in_vision:
		lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.terrain])

		const SPEED_MULT: Dictionary = {"plains": 1.0, "forest": 0.7, "mountain": 0.4}
		var spd: float = float(SPEED_MULT.get(tile.terrain, 1.0))
		lines.append("速度: x%.1f" % spd)

		lines.append("農業效率: %.0f%%" % (tile.harvest_factor * 100.0))

		var res_parts: Array = []
		for rk in ["food", "material", "ore_iron", "ore_gold", "ore_silver", "gem"]:
			var v: float = float(tile.resources.get(rk, 0))
			if v > 0:
				res_parts.append("%s:%d" % [rk, int(v)])
		if res_parts.size() > 0:
			lines.append("資源: " + ", ".join(res_parts))

		if tile.outpost_level > 0:
			lines.append("據點: %s Lv%d（Team%d）" % [
				tile.outpost_type, tile.outpost_level, tile.outpost_owner])
		else:
			lines.append("無據點")

		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.tile_pos == pos:
				var faction_str: String = "獨立" if t.faction_id < 0 else "勢力%d" % t.faction_id
				lines.append("Team%d [%s] 人口:%d 任務:%s" % [
					tid, faction_str, t.population, t.current_task])
	else:
		var known_here: bool = false
		for tid in discovered:
			var intel: Dictionary = state.team_intel.get(player_tid, {}).get(tid, {})
			if intel.get("tile_pos", Vector2i(-999, -999)) == pos:
				known_here = true
				break

		if known_here or (player_team and player_team.tile_pos == pos):
			lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.terrain])
			lines.append("（視野外，情報可能過時）")
		else:
			lines.append("(%d,%d) 未知區域" % [pos.x, pos.y])

	_tile_label.text = "\n".join(lines)

func add_message(text: String) -> void:
	_messages.append(text)
	if _messages.size() > MAX_MESSAGES:
		_messages.pop_front()
	_msg_label.text = "\n".join(_messages.slice(-5))
