# scripts/ui/main.gd
extends Control

var _bridge: SimBridge
var _runner: SimRunner
var _state: WorldState

@onready var _map:       Node2D        = $WorldMapView
@onready var _debug:     PanelContainer = $DebugBar
@onready var _controls:  HBoxContainer = $TurnControls
@onready var _sidebar:   VBoxContainer = $RightSidebar
@onready var _bottom:    HBoxContainer = $BottomBar
@onready var _popups:    CanvasLayer   = $PopupLayer
@onready var _encounter: Control       = $EncounterView

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # 讓點擊穿透到地圖
	_runner = SimRunner.new()
	_state  = WorldState.new()

	# Generate world
	var _gen = load("res://scripts/simulation/world_generator.gd").new()
	_gen.generate(_state, { "radius": 4, "seed": 42 })

	# Create 3 teams with persons
	for t in range(3):
		var team := TeamData.new()
		team.team_id    = t
		team.population = 10
		team.tile_pos   = Vector2i(t, 0)
		team.resources  = {
			"food": 5000.0, "material": 100, "coin": 200, "goods": 0, "gem": 0,
			"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
			"weapon_melee_low": 5, "weapon_melee_high": 0,
			"weapon_ranged_low": 0, "weapon_ranged_high": 0,
			"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 5, "tools": 5,
			"armor_low": 2, "armor_high": 0,
		}
		team.tags = ["統領"]
		_state.teams[t]           = team
		_state.team_known[t]      = []
		_state.team_discovered[t] = []
		for p in range(3):
			var person := PersonData.new()
			person.id          = t * 3 + p
			person.person_name = "P%d_%d" % [t, p]
			person.role        = "leader" if p == 0 else "civilian"
			person.team_id     = t
			person.age         = 25
			person.loyalty     = 0.8
			person.skills["統領"] = 0.5
			person.skills["生產"] = 0.3
			person.skills["戰鬥"] = 0.2
			_state.persons[person.id] = person
			if p == 0:
				team.leader_id = person.id
			else:
				team.named_members.append(person.id)

	# Set player to Team 0 leader
	PlayerSystem.new().init_player(_state, 0, 0)

	_bridge = SimBridge.new(_runner, _state)
	_debug.setup(_bridge)
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
	_encounter.encounter_ended.connect(_on_encounter_ended)
	print("[Main] UI ready — world generated, player=P0 Team0")

func _on_tile_selected(pos: Vector2i) -> void:
	_sidebar.show_tile(pos)
	_bottom.show_tile_info(pos)

func _on_set_move_target(pos: Vector2i) -> void:
	var state: WorldState = _bridge.get_state()
	var ptid: int = _bridge.get_player_team_id()
	if ptid < 0: return
	var team: TeamData = state.teams.get(ptid)
	if team:
		team.move_target = pos
		print("[Main] move_target set Team%d → (%d,%d)" % [ptid, pos.x, pos.y])
	_debug.refresh()

func _on_tick_advanced(_events: Array) -> void:
	_map.refresh()
	_debug.refresh()
	_sidebar.refresh_player()
	for evt in _events:
		_bottom.add_message("[T%d] %s" % [_bridge.get_state().world.current_tick, str(evt.get("type", "?"))])
	if _bridge.get_state().encounter_active:
		_encounter.show_encounter()
		_map.visible = false

func _on_encounter_ended() -> void:
	_map.visible = true
	_map.refresh()
