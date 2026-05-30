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
	var key: int = pos.x * 1000 + pos.y
	var tile: HexTileData = state.world.tiles.get(key)

	var lines: Array = []
	if tile == null:
		lines.append("(%d,%d) 未知圖塊" % [pos.x, pos.y])
	else:
		lines.append("(%d,%d) 地形: %s" % [pos.x, pos.y, tile.terrain])

	# 該格 team
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == pos:
			var faction_str: String = "獨立" if t.faction_id < 0 else "勢力%d" % t.faction_id
			lines.append("Team%d [%s] 人口:%d 任務:%s" % [
				tid, faction_str, t.population, t.current_task])

	_tile_label.text = "\n".join(lines)

func add_message(text: String) -> void:
	_messages.append(text)
	if _messages.size() > MAX_MESSAGES:
		_messages.pop_front()
	_msg_label.text = "\n".join(_messages.slice(-5))
