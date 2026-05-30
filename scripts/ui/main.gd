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
	_controls.setup(_bridge)
	_sidebar.setup(_bridge)
	_bottom.setup(_bridge)
	_popups.setup(_bridge)
	_encounter.setup(_bridge)
	print("[Main] UI ready")
