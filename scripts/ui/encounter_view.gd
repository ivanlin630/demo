# scripts/ui/encounter_view.gd
extends Control
var _bridge: SimBridge
func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	visible = false

func show_encounter() -> void:
	visible = true

func hide_encounter() -> void:
	visible = false
