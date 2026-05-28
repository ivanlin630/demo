class_name SimRunner

const LOD_NEAR_RADIUS: int = 3
const FAR_ZONE_INTERVAL: int = 10

var _resource_system: ResourceSystem
var _reaction_system: ReactionSystem
var _skill_system: Object
var _movement_system: Object
var _message_system: SimMessageSystem
var _event_system: Object
var _interaction_system: Object
var _faction_ai_system: Object
var _outpost_system: OutpostSystem
var _harvest_system: HarvestSystem
var _manufacturing_system: ManufacturingSystem
var _vision_system: VisionSystem
var _equipment_system: EquipmentSystem
var _population_system: PopulationSystem
var _day_night_system: DayNightSystem

func _init() -> void:
	_resource_system      = ResourceSystem.new()
	_reaction_system      = ReactionSystem.new()
	_skill_system         = load("res://scripts/simulation/skill_system.gd").new()
	_movement_system      = load("res://scripts/simulation/movement_system.gd").new()
	_message_system       = SimMessageSystem.new()
	_event_system         = load("res://scripts/simulation/event_system.gd").new()
	_interaction_system   = load("res://scripts/simulation/interaction_system.gd").new()
	_faction_ai_system    = load("res://scripts/simulation/faction_ai_system.gd").new()
	_outpost_system       = OutpostSystem.new()
	_harvest_system       = HarvestSystem.new()
	_manufacturing_system = ManufacturingSystem.new()
	_vision_system        = VisionSystem.new()
	_equipment_system    = EquipmentSystem.new()
	_population_system   = PopulationSystem.new()
	_day_night_system    = DayNightSystem.new()

func advance_tick(state: WorldState, player_pos: Vector2i) -> void:
	_step1_advance_time(state)
	if state.world.current_tick % state.ticks_per_day == 0:
		print("[DayNight] Day %d 開始" % (state.world.current_tick / state.ticks_per_day))
	if state.world.current_tick % PopulationSystem.OVERFLOW_CHECK_INTERVAL == 0:
		_step1d_overflow(state)

	var time_speed_mult: float = _day_night_system.get_speed_mult(state)
	var time_vision_mult: float = _day_night_system.get_vision_mult(state)

	var near_teams := _get_near_teams(state, player_pos)
	var far_teams := _get_far_teams(state, player_pos)

	_step1b_update_vision(state, near_teams, time_vision_mult)
	_step1c_update_equipment(state, near_teams)
	var arrived_near := _step2_move_teams(state, near_teams, time_speed_mult)
	_step3_propagate_messages(state, arrived_near, near_teams)
	_step4_resolve_interactions(state, arrived_near, near_teams)
	_step4b_outpost_tick(state)
	_step4c_harvest_tick(state)
	_step5_collect_resources(state, near_teams)
	_step5a_regenerate_tiles(state)
	_step5b_manufacture(state, near_teams)
	_step6_resolve_consumption(state, near_teams)
	_step6b_faction_ai(state, near_teams)
	_step7_person_reactions(state, near_teams)
	_step8_generate_events(state, near_teams)
	_step9_emit_messages(state)

	# 遠區：每 FAR_ZONE_INTERVAL Tick 跑一次，跳過人物反應
	if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
		_step1b_update_vision(state, far_teams, time_vision_mult)
		_step1c_update_equipment(state, far_teams)
		var arrived_far := _step2_move_teams(state, far_teams, time_speed_mult)
		_step3_propagate_messages(state, arrived_far, far_teams)
		_step4_resolve_interactions(state, arrived_far, far_teams)
		_step5_collect_resources(state, far_teams)
		_step5a_regenerate_tiles(state)
		_step5b_manufacture(state, far_teams)
		_step6_resolve_consumption(state, far_teams)
		_step6b_faction_ai(state, far_teams)
		_step8_generate_events(state, far_teams)
		_step9_emit_messages(state)

func _step1d_overflow(state: WorldState) -> void:
	_population_system.check_overflow(state)

func _step1b_update_vision(state: WorldState, team_ids: Array,
		time_vision_mult: float = 1.0) -> void:
	_vision_system.tick_discovery(state, team_ids)  # time_mult passed in Task 4

func _step1c_update_equipment(state: WorldState, team_ids: Array) -> void:
	_equipment_system.tick_all(state, team_ids)

func _step1_advance_time(state: WorldState) -> void:
	state.world.current_tick += 1
	if state.world.current_tick % 6 == 0:
		state.world.current_turn += 1

func _step2_move_teams(state: WorldState, team_ids: Array,
		time_speed_mult: float = 1.0) -> Array:
	return _movement_system.process(state, team_ids)  # time_mult passed in Task 3

func _get_time_fatigue_mult(state: WorldState) -> float:
	return _day_night_system.get_fatigue_mult(state)

func _step3_propagate_messages(state: WorldState, arrived_ids: Array, all_ids: Array) -> void:
	_message_system.propagate_on_arrival(state, arrived_ids, all_ids)

func _step4_resolve_interactions(state: WorldState, arrived_ids: Array, all_ids: Array) -> void:
	_interaction_system.process_on_arrival(state, arrived_ids, all_ids)

func _step4b_outpost_tick(state: WorldState) -> void:
	_outpost_system.tick_all(state)

func _step4c_harvest_tick(state: WorldState) -> void:
	if state.world.current_tick % 6 == 0:
		_harvest_system.tick_all(state)

func _step5_collect_resources(state: WorldState, team_ids: Array) -> void:
	_resource_system.collect_resources(state, team_ids)

func _step5a_regenerate_tiles(state: WorldState) -> void:
	_resource_system.regenerate_tiles(state)

func _step5b_manufacture(state: WorldState, team_ids: Array) -> void:
	_manufacturing_system.tick_all(state, team_ids)

func _step6_resolve_consumption(state: WorldState, team_ids: Array) -> void:
	_resource_system.resolve_consumption(state, team_ids)

func _step6b_faction_ai(state: WorldState, team_ids: Array) -> void:
	_faction_ai_system.evaluate_all(state, team_ids)

func _step7_person_reactions(state: WorldState, team_ids: Array) -> void:
	_reaction_system.evaluate_all(state, team_ids, _skill_system)

func _step8_generate_events(state: WorldState, team_ids: Array) -> void:
	_event_system.process_events(state, team_ids)

func _step9_emit_messages(state: WorldState) -> void:
	_message_system.process_pending(state)

func _get_near_teams(state: WorldState, player_pos: Vector2i) -> Array:
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if _hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS:
			result.append(tid)
	return result

func _get_far_teams(state: WorldState, player_pos: Vector2i) -> Array:
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if _hex_distance(team.tile_pos, player_pos) > LOD_NEAR_RADIUS:
			result.append(tid)
	return result

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
