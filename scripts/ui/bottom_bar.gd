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
	tile_panel.custom_minimum_size = Vector2(200, 85)
	_tile_label = Label.new()
	_tile_label.text = "圖塊資訊"
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
	if tile == null:
		_tile_label.text = "(%d,%d)\n未知" % [pos.x, pos.y]
		return
	_tile_label.text = "(%d,%d)\n地形: %s" % [pos.x, pos.y, tile.terrain]

func add_message(text: String) -> void:
	_messages.append(text)
	if _messages.size() > MAX_MESSAGES:
		_messages.pop_front()
	_msg_label.text = "\n".join(_messages.slice(-5))
