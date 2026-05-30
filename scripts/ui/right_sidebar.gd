# scripts/ui/right_sidebar.gd
extends VBoxContainer
var _bridge: SimBridge
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
func show_tile(pos: Vector2i) -> void:
	pass
