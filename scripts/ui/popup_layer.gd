# scripts/ui/popup_layer.gd
extends CanvasLayer
var _bridge: SimBridge
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
func show_members(team_id: int) -> void:
	pass
func show_inventory() -> void:
	pass
func show_history(team_id: int) -> void:
	pass
