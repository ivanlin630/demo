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
	_sidebar.open_interaction.connect(_on_open_interaction)
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
	if not state.world.tiles.has(pos.x * 1000 + pos.y):
		print("[Main] 移動目標 %s 不在地圖內，忽略" % str(pos))
		return
	var result: Dictionary = _bridge.command_player("move_to", {"tile_q": pos.x, "tile_r": pos.y})
	if result.get("ok"):
		print("[Main] move_target set → (%d,%d)" % [pos.x, pos.y])
	else:
		print("[Main] move_target failed: %s" % result.get("message", ""))
	_debug.refresh()

func _on_open_interaction() -> void:
	_bridge.refresh_interaction_targets()
	var snap: Dictionary = _bridge.query_player().get("data", {}).get("snapshot", {})
	var pending: Array = snap.get("pending_targets", [])
	var forced: Dictionary = snap.get("forced_interaction", {})

	# Forced interaction takes priority
	if not forced.get("responses", []).is_empty():
		_popups.show_forced_event(forced,
			func(cmd_args: Dictionary) -> void:
				var r = _bridge.command_player("respond_to_forced", cmd_args)
				_bottom.add_message("[強制] %s" % r.get("message", ""))
				_sidebar.refresh_player(); _debug.refresh())
		return

	if pending.is_empty():
		_bottom.add_message("[互動] 附近無可互動目標")
		return

	_popups.show_interaction(pending,
		func(tid: int) -> void:
			var actions_result := _bridge.query_player_actions({
				"team_id": tid, "member_id": -1, "tile_q": -1, "tile_r": -1
			})
			var acts: Array = actions_result.get("data", {}).get("actions", [])
			_popups.show_action_menu(tid, acts, _on_interact_execute))

func _on_interact_execute(cmd_name: String, cmd_args: Dictionary) -> void:
	var result: Dictionary = _bridge.command_player(cmd_name, cmd_args)
	_sidebar.refresh_player(); _debug.refresh()
	var action_id: String = cmd_args.get("action_id", "")

	if action_id == "attack" and result.get("ok"):
		_map.visible = false; _encounter.show_encounter(); return

	if action_id == "trade" and result.get("ok") and result.get("payload", {}).get("requires_preview"):
		var tid: int = result.get("payload", {}).get("preview_target_id", -1)
		var pr := _bridge.query_player({"focus_team_id": tid})
		# trade preview handled by trade plan
		return

	if action_id == "recruit" and result.get("ok"):
		var payload: Dictionary = result.get("payload", {})
		if payload.get("has_willing_named", false):
			# recruit panel handled by recruit plan
			return

	_bottom.add_message("[互動] %s" % result.get("message", "完成"))

func _on_tick_advanced(_events: Array) -> void:
	var state: WorldState = _bridge.get_state()
	if state.player_id >= 0 and not state.persons.has(state.player_id):
		_bottom.add_message("[!] 玩家 P%d 已陣亡，模擬暫停" % state.player_id)
		_controls.set_process(false)
		return

	_map.refresh()
	_debug.refresh()
	_sidebar.refresh_player()
	for evt in _events:
		_bottom.add_message("[T%d] %s" % [_bridge.get_state().world.current_tick, str(evt.get("type", "?"))])

	if _bridge.get_state().encounter_active:
		_encounter.show_encounter()
		_map.visible = false
		return

	# Poll forced interaction
	var snap: Dictionary = _bridge.query_player().get("data", {}).get("snapshot", {})
	var forced: Dictionary = snap.get("forced_interaction", {})
	if not forced.get("responses", []).is_empty():
		_popups.show_forced_event(forced,
			func(cmd_args: Dictionary) -> void:
				var r = _bridge.command_player("respond_to_forced", cmd_args)
				_bottom.add_message("[強制] %s" % r.get("message", ""))
				_sidebar.refresh_player(); _debug.refresh())

func _on_encounter_ended() -> void:
	_map.visible = true
	_map.refresh()
	_sidebar.refresh_player(); _debug.refresh()

	# Check for loot
	var snap: Dictionary = _bridge.query_player().get("data", {}).get("snapshot", {})
	var actions: Array = snap.get("available_actions", [])
	var take_act: Dictionary = {}
	for act in actions:
		if act.get("action_id", "") == "take_loot":
			take_act = act
			break

	if not take_act.is_empty():
		var loot_preview: Dictionary = take_act.get("command_args", {}).get("loot_preview", {})
		_popups.show_loot_panel(
			loot_preview,
			func() -> void:
				var r = _bridge.command_player("execute_action", {
					"action_id": "take_loot",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
				})
				_bottom.add_message("[戰鬥] %s" % r.get("message", ""))
				_sidebar.refresh_player(); _debug.refresh(),
			func() -> void:
				_bridge.command_player("execute_action", {
					"action_id": "leave_loot",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
				})
				_bottom.add_message("[戰鬥] 放棄戰利品"))

