class_name SimRunner

const LOD_NEAR_RADIUS: int = 3
const FAR_ZONE_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時 = 100 ticks

const FATIGUE_PER_DAY: float          = 0.048   # TEST VALUE — 約 20.8 天疲勞滿（原 0.002×24）
const FATIGUE_RECOVERY_PER_DAY: float = 0.24    # TEST VALUE — 約 4.2 天回滿（原 0.01×24）
const FATIGUE_LOYALTY_PENALTY: float = 0.005   # TEST VALUE

const TERRAIN_FATIGUE_MULT: Dictionary = {
	"plains": 1.0, "forest": 1.2, "mountain": 1.4
}

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
var _npc_ai_system: NpcAiSystem
var _salary_system: SalarySystem
var _day_night_system: DayNightSystem
var _diplomatic_ai_system: DiplomaticAiSystem
var _strategic_ai_system: StrategicAiSystem
var _encounter_system: EncounterSystem
var _player_cmd: PlayerCommandSystem

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
	_npc_ai_system       = NpcAiSystem.new()
	_salary_system       = SalarySystem.new()
	_day_night_system    = DayNightSystem.new()
	_diplomatic_ai_system = DiplomaticAiSystem.new()
	_strategic_ai_system = StrategicAiSystem.new()
	_encounter_system    = EncounterSystem.new()
	_player_cmd          = PlayerCommandSystem.new()

func advance_tick(state: WorldState, player_pos: Vector2i) -> String:
	if state.encounter_active:
		var result: String = _encounter_system.advance_encounter_tick(state)
		if result not in ["ongoing", "player_turn"]:
			_encounter_system.resolve_encounter_end(state, result)
		_step1_advance_time(state)
		return result    # propagate to bridge
	_step1_advance_time(state)
	if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
		print("[DayNight] Day %d 開始" % (state.world.current_tick / WorldState.TICKS_PER_DAY))
		_message_system.prune_old_messages(state, state.world.current_tick)
	if state.world.current_tick % PopulationSystem.OVERFLOW_CHECK_INTERVAL == 0:
		_step1d_overflow(state)

	var time_speed_mult: float = _day_night_system.get_speed_mult(state)
	var time_vision_mult: float = _day_night_system.get_vision_mult(state)

	var near_teams := _get_near_teams(state, player_pos)
	var far_teams := _get_far_teams(state, player_pos)

	# 近區：每小時執行
	if state.world.current_tick % WorldState.TICKS_PER_HOUR == 0:
		# forced_event 超時自動拒絕（上一 hour-tick 寫入，本 tick 未回應即清除）
		if not state.player_forced_event.is_empty():
			print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
			state.player_forced_event = {}
			state.player_forced_event_id = ""
		_step1b_update_vision(state, near_teams, time_vision_mult)
		_step1c_update_equipment(state, near_teams)
		var _player_old_pos: Vector2i = _get_player_tile_pos(state)
		var arrived_near := _step2_move_teams(state, near_teams, time_speed_mult)
		if _get_player_tile_pos(state) != _player_old_pos:
			_player_cmd.clear_pending_targets(state)
		_step3_propagate_messages(state, arrived_near, near_teams)
		_step3b_exchange_intel(state, arrived_near, near_teams)
		_step4_resolve_interactions(state, arrived_near, near_teams)
		_step4b_outpost_tick(state)
		_step4e_faction_snapshot(state, near_teams)
		_step5_collect_resources(state, near_teams)
		_step5a_regenerate_tiles(state)
		_step5b_manufacture(state, near_teams)
		_step6_resolve_consumption(state, near_teams)
		_step6c_salary(state, near_teams)
		_step6d_fatigue(state, near_teams)
		_step6b_faction_ai(state, near_teams)
		_step6e_strategic_ai(state)
		_step7_person_reactions(state, near_teams)
		_step7b_npc_goal_cleanup(state, near_teams)
		_step8_generate_events(state, near_teams)
		_step9_emit_messages(state)

	# Harvest：每 6 小時（TICKS_PER_DAY / 4）
	if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:
		_step4c_harvest_tick(state)

	# 遠區：每 FAR_ZONE_INTERVAL Tick 跑一次，跳過人物反應
	if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
		_step1b_update_vision(state, far_teams, time_vision_mult)
		_step1c_update_equipment(state, far_teams)
		var arrived_far := _step2_move_teams(state, far_teams, time_speed_mult)
		_step3_propagate_messages(state, arrived_far, far_teams)
		_step3b_exchange_intel(state, arrived_far, far_teams)
		_step4_resolve_interactions(state, arrived_far, far_teams)
		_step4e_faction_snapshot(state, far_teams)
		_step5_collect_resources(state, far_teams)
		_step5a_regenerate_tiles(state)
		_step5b_manufacture(state, far_teams)
		_step6_resolve_consumption(state, far_teams)
		_step6c_salary(state, far_teams)
		_step6d_fatigue(state, far_teams)
		_step6b_faction_ai(state, far_teams)
		_step6e_strategic_ai(state)
		_step8_generate_events(state, far_teams)
		_step9_emit_messages(state)
	return ""   # non-encounter tick

func _step1d_overflow(state: WorldState) -> void:
	_population_system.check_overflow(state)

func _step1b_update_vision(state: WorldState, team_ids: Array,
		time_vision_mult: float = 1.0) -> void:
	_vision_system.tick_discovery(state, team_ids, time_vision_mult)

func _step1c_update_equipment(state: WorldState, team_ids: Array) -> void:
	_equipment_system.tick_all(state, team_ids)

func _step1_advance_time(state: WorldState) -> void:
	state.world.current_tick += 1
	if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:  # 每 6 小時
		state.world.current_turn += 1

func _step2_move_teams(state: WorldState, team_ids: Array,
		time_speed_mult: float = 1.0) -> Array:
	return _movement_system.process(state, team_ids, time_speed_mult)

func _get_time_fatigue_mult(state: WorldState) -> float:
	return _day_night_system.get_fatigue_mult(state)

func _step3_propagate_messages(state: WorldState, arrived_ids: Array, all_ids: Array) -> void:
	_message_system.propagate_on_arrival(state, arrived_ids, all_ids)

func _step3b_exchange_intel(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	_message_system.exchange_intel_on_arrival(state, arrived_ids, all_team_ids)

func _step4_resolve_interactions(state: WorldState, arrived_ids: Array, all_ids: Array) -> void:
	_interaction_system.process_on_arrival(state, arrived_ids, all_ids)

func _step4b_outpost_tick(state: WorldState) -> void:
	_outpost_system.tick_all(state)

func _step4e_faction_snapshot(state: WorldState, team_ids: Array) -> void:
	# T-02 快照B：同格同勢力 → 互相更新快照（模擬面對面情報交換）
	var pos_map: Dictionary = {}  # tile_id → Array[int] team_ids
	for tid in team_ids:
		var t: TeamData = state.teams.get(tid)
		if t == null or t.faction_id == -1: continue
		var tile_id: int = t.tile_pos.x * 1000 + t.tile_pos.y
		if not pos_map.has(tile_id): pos_map[tile_id] = []
		pos_map[tile_id].append(tid)
	for tile_id in pos_map:
		var same_tile: Array = pos_map[tile_id]
		if same_tile.size() < 2: continue
		for tid in same_tile:
			var t: TeamData = state.teams[tid]
			for other_tid in same_tile:
				if other_tid == tid: continue
				var other: TeamData = state.teams[other_tid]
				if other.faction_id == t.faction_id:
					state.snapshot_faction_member(tid, state.world.current_tick)
					break

func _step4c_harvest_tick(state: WorldState) -> void:
	_harvest_system.tick_all(state)   # 外層已做頻率判斷

func _step5_collect_resources(state: WorldState, team_ids: Array) -> void:
	_resource_system.collect_resources(state, team_ids)

func _step5a_regenerate_tiles(state: WorldState) -> void:
	_resource_system.regenerate_tiles(state)

func _step5b_manufacture(state: WorldState, team_ids: Array) -> void:
	_manufacturing_system.tick_all(state, team_ids)

func _step6_resolve_consumption(state: WorldState, team_ids: Array) -> void:
	_resource_system.resolve_consumption(state, team_ids)

func _step6c_salary(state: WorldState, team_ids: Array) -> void:
	_salary_system.tick(state, team_ids)

func _step6d_fatigue(state: WorldState, team_ids: Array) -> void:
	var time_mult: float = _get_time_fatigue_mult(state)
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		if team.current_task == "rest":
			# 紮營休息
			var rest_mult: float = 1.0 - team.guard_ratio * 0.5
			team.fatigue -= FATIGUE_RECOVERY_PER_DAY / float(WorldState.TICKS_PER_DAY) * rest_mult
			team.fatigue = maxf(team.fatigue, 0.0)
		else:
			var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
			var tile = state.world.tiles.get(tile_id)
			var terrain: String = tile.terrain if tile else "plains"
			var terrain_mult: float = TERRAIN_FATIGUE_MULT.get(terrain, 1.0)
			team.fatigue += FATIGUE_PER_DAY / float(WorldState.TICKS_PER_DAY) * terrain_mult * time_mult
			team.fatigue = minf(team.fatigue, 1.0)
		if team.fatigue >= 1.0:
			for pid in team.named_members:
				var p: PersonData = state.persons.get(pid)
				if p: p.loyalty -= FATIGUE_LOYALTY_PENALTY


func _step6b_faction_ai(state: WorldState, team_ids: Array) -> void:
	_faction_ai_system.evaluate_all(state, team_ids)

func _step6e_strategic_ai(state: WorldState) -> void:
	for fid in state.factions:
		_strategic_ai_system.tick(state, state.factions[fid])

func _step7_person_reactions(state: WorldState, team_ids: Array) -> void:
	_reaction_system.evaluate_all(state, team_ids, _skill_system)

func _step7b_npc_goal_cleanup(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		for pid in ([team.leader_id] as Array) + team.named_members:
			var p: PersonData = state.persons.get(pid)
			if p: _npc_ai_system.cleanup_goals(state, p)

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

func _get_player_tile_pos(state: WorldState) -> Vector2i:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return Vector2i(-1, -1)
	var t: TeamData = state.teams.get(p.team_id)
	return t.tile_pos if t != null else Vector2i(-1, -1)
