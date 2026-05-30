# scripts/ui/world_map_view.gd
extends Node2D
var _bridge: SimBridge
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
