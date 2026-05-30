# scripts/ui/bottom_bar.gd
extends HBoxContainer
var _bridge: SimBridge
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
func show_tile_info(pos: Vector2i) -> void:
	pass
func add_message(text: String) -> void:
	pass
