# scripts/ui/main.gd
extends Control

var _bridge: SimBridge
var _runner: SimRunner
var _state: WorldState

@onready var _map:       Node2D        = $WorldMapView
@onready var _controls:  HBoxContainer = $TurnControls
@onready var _sidebar:   VBoxContainer = $RightSidebar
@onready var _bottom:    HBoxContainer = $BottomBar
@onready var _popups:    CanvasLayer   = $PopupLayer
@onready var _encounter: Control       = $EncounterView

func _ready() -> void:
	_runner = SimRunner.new()
	_state  = WorldState.new()
	_bridge = SimBridge.new(_runner, _state)
	_map.setup(_bridge)
	_map.tile_selected.connect(_on_tile_selected)
	_controls.setup(_bridge)
	_controls.tick_advanced.connect(_on_tick_advanced)
	_sidebar.setup(_bridge)
	_bottom.setup(_bridge)
	_popups.setup(_bridge)
	_encounter.setup(_bridge)
	print("[Main] UI ready")

func _on_tile_selected(pos: Vector2i) -> void:
	_sidebar.show_tile(pos)
	_bottom.show_tile_info(pos)

func _on_tick_advanced(_events: Array) -> void:
	_map.refresh()
	for evt in _events:
		_bottom.add_message("[T%d] %s" % [_bridge.get_state().world.current_tick, str(evt.get("type", "?"))])
	if _bridge.get_state().encounter_active:
		_encounter.show_encounter()
		_map.visible = false
	elif not _bridge.get_state().encounter_active and _encounter.visible:
		_encounter.hide_encounter()
		_map.visible = true
		_map.refresh()
