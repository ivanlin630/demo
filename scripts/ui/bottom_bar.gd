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
	var lines: Array = []
	var in_vision: bool = _bridge.is_tile_in_vision(pos.x, pos.y)
	var tile: Dictionary = _bridge.query_tile(pos.x, pos.y)

	if tile.is_empty():
		lines.append("(%d,%d) 地圖外" % [pos.x, pos.y])
		_tile_label.text = "\n".join(lines)
		return

	if in_vision:
		lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.get("terrain", "?")])

		const SPEED_MULT: Dictionary = {"plains": 1.0, "forest": 0.7, "mountain": 0.4}
		var spd: float = float(SPEED_MULT.get(tile.get("terrain", "plains"), 1.0))
		lines.append("速度: x%.1f" % spd)

		lines.append("農業效率: %.0f%%" % (tile.get("harvest_factor", 0) * 100.0))

		var res: Dictionary = tile.get("resources", {})
		var res_parts: Array = []
		for rk in ["food", "material", "ore_iron", "ore_gold", "ore_silver", "gem"]:
			var v: float = float(res.get(rk, 0))
			if v > 0:
				res_parts.append("%s:%d" % [rk, int(v)])
		if res_parts.size() > 0:
			lines.append("資源: " + ", ".join(res_parts))

		if tile.get("outpost_level", 0) > 0:
			lines.append("據點: %s Lv%d（Team%d）" % [
				tile.get("outpost_type", "?"),
				tile.get("outpost_level", 0),
				tile.get("outpost_owner", -1)])
		else:
			lines.append("無據點")

		var teams_here: Array = _bridge.get_teams_at_tile(pos.x, pos.y)
		for td in teams_here:
			var faction_str: String = "獨立" if td.get("faction_id", -1) < 0 else "勢力%d" % td["faction_id"]
			lines.append("Team%d [%s] 人口:%d 任務:%s" % [
				td["id"], faction_str, td.get("population", 0), td.get("current_task", "")])
	else:
		var player_pos: Vector2i = _bridge.get_player_tile_pos()
		var known_here: bool = _bridge.has_tile_intel(pos.x, pos.y)
		if known_here or player_pos == pos:
			lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.get("terrain", "?")])
			lines.append("（視野外，情報可能過時）")
		else:
			lines.append("(%d,%d) 未知區域" % [pos.x, pos.y])

	_tile_label.text = "\n".join(lines)

func add_message(text: String) -> void:
	_messages.append(text)
	if _messages.size() > MAX_MESSAGES:
		_messages.pop_front()
	_msg_label.text = "\n".join(_messages.slice(-5))
