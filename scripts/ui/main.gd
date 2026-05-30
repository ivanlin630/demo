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
	_sidebar.open_members.connect(func(tid): _popups.show_members(tid))
	_sidebar.open_inventory.connect(func(): _popups.show_inventory())
	_sidebar.open_history.connect(func(tid): _popups.show_history(tid))
	_sidebar.set_move_target.connect(_on_set_move_target)
	_bottom.setup(_bridge)
	_popups.setup(_bridge)
	_encounter.setup(_bridge)
	print("[Main] UI ready")

func _on_tile_selected(pos: Vector2i) -> void:
	_sidebar.show_tile(pos)
	_bottom.show_tile_info(pos)

func _on_set_move_target(pos: Vector2i) -> void:
	var state: WorldState = _bridge.get_state()
	var ptid: int = _bridge.get_player_team_id()
	if ptid < 0: return
	var team: TeamData = state.teams.get(ptid)
	if team: team.move_target = pos

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
