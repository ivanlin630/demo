# scripts/ui/turn_controls.gd
extends HBoxContainer
var _bridge: SimBridge
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
