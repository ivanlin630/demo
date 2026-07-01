class_name SimRunner

const LOD_NEAR_RADIUS: int = 3
const FAR_ZONE_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時 = 100 ticks
const NEAR_CADENCE: int = WorldState.TICKS_PER_HOUR   # TEST VALUE — 近區更新頻率（1h，可調）

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
var _training_system: TrainingSystem
var _player_cmd: PlayerCommandSystem
var _ambush_system: AmbushSystem

# #3 tick 計時 instrument：累積本 day 的 tick wall-time，日邊界 flush（無 per-tick spam）
var _perf_accum_us: int = 0
var _perf_count: int = 0
var _perf_max_us: int = 0

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
	_training_system     = TrainingSystem.new()
	_player_cmd          = PlayerCommandSystem.new()
	_ambush_system       = AmbushSystem.new()

func advance_tick(state: WorldState, player_pos: Vector2i) -> String:
	# H: game_over / 等待選繼承人 → 凍結世界，不推進 tick（不計時，非真 tick）
	if state.game_over:
		return "game_over"
	if state.player_forced_event.get("action", "") == "choose_heir":
		return "awaiting_heir"
	# #3 tick 計時：包真 tick 工作的 wall-time（含 encounter / ambush / 常規三路徑）
	var _perf_t0: int = Time.get_ticks_usec()
	var _perf_result: String = _advance_tick_body(state, player_pos)
	_record_tick_perf(state, Time.get_ticks_usec() - _perf_t0)
	return _perf_result

# #3 tick 計時：本 tick wall-time 累積 + 日邊界 flush（`[TickPerf] avg/max us, teams/factions`）
func _record_tick_perf(state: WorldState, dt_us: int) -> void:
	_perf_accum_us += dt_us
	_perf_count += 1
	if dt_us > _perf_max_us:
		_perf_max_us = dt_us
	if state.world.current_tick % WorldState.TICKS_PER_DAY == 0 and _perf_count > 0:
		var avg_us: int = _perf_accum_us / _perf_count
		print("[TickPerf] day=%d avg=%d us max=%d us ticks=%d teams=%d factions=%d" % [
			state.world.current_tick / WorldState.TICKS_PER_DAY, avg_us, _perf_max_us,
			_perf_count, state.teams.size(), state.factions.size()])
		_perf_accum_us = 0
		_perf_count = 0
		_perf_max_us = 0

func _advance_tick_body(state: WorldState, player_pos: Vector2i) -> String:
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
		SpecimenTracer.flush()   # specimen 日邊界 flush（enabled 才印，一般 no-op；防 entries 膨脹）
		# 飢餓致死鏈：日邊界結算 blood<=0 死亡（leader 死交既有繼承/玩家 forced event）
		HealthSystem.check_starvation_deaths(state)
		# 覓食 episode 日彙整：歸零各隊 forage_today，玩家隊產訊息（防 per-tick spam）
		var forage_msgs: Array = _resource_system.flush_forage_episodes(state, state.teams.keys())
		for fm in forage_msgs:
			print("[ForageEpisode] %s" % fm)
	if state.world.current_tick % PopulationSystem.OVERFLOW_CHECK_INTERVAL == 0:
		_step1d_overflow(state)

	var time_speed_mult: float = _day_night_system.get_speed_mult(state)
	var time_vision_mult: float = _day_night_system.get_vision_mult(state)

	var near_teams := _get_near_teams(state, player_pos)
	var far_teams := _get_far_teams(state, player_pos)

	# 近區：每小時執行
	if state.world.current_tick % NEAR_CADENCE == 0:
		# forced_event 超時自動拒絕（上一 hour-tick 寫入，本 tick 未回應即清除）
		# H: choose_heir 不超時（advance_tick 開頭已凍結，此處為防禦）
		if not state.player_forced_event.is_empty() \
				and state.player_forced_event.get("action", "") != "choose_heir":
			var fe_timeout: Dictionary = state.player_forced_event
			if fe_timeout.get("action", "") == "aid_request":
				var beggar_id_t: int = int(fe_timeout.get("from_id", -1))
				var beggar_t: TeamData = state.teams.get(beggar_id_t)
				if beggar_t != null:
					var b_leader_t: PersonData = state.persons.get(beggar_t.leader_id)
					var pt_t: TeamData = _get_player_team_sr(state)
					if pt_t != null and b_leader_t != null:
						_message_system.emit_message(state, "aid_refused",
							"玩家未回應，視同拒絕援助 Team%d" % beggar_id_t, pt_t,
							{ "origin": str(pt_t.team_id), "target": str(beggar_id_t) })
						var cur_rep: float = float(beggar_t.known_reputations.get(pt_t.team_id, 0.5))
						beggar_t.known_reputations[pt_t.team_id] = clampf(cur_rep - 0.1, 0.0, 1.0)
						NpcAiSystem.new().write_memory(b_leader_t, "rejected_aid",
							pt_t.team_id, state.world.current_tick, 0.5)
					state.clear_social_target(beggar_t)   # BEG 現走 social_target（非 combat_target）
					if beggar_t.previous_task != "" and beggar_t.previous_task != TeamData.TASK_IDLE:
						TaskArbiter.transition(beggar_t, beggar_t.previous_task,
							TaskArbiter.PRIO_DISPATCH)
					else:
						TaskArbiter.release(beggar_t)
					beggar_t.previous_task = ""
			print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
			state.player_forced_event = {}
			state.player_forced_event_id = ""
		_step1b_update_vision(state, near_teams, time_vision_mult)
		_step1c_update_equipment(state, near_teams)
		var _player_old_pos: Vector2i = _get_player_tile_pos(state)
		var move_near: Dictionary = _step2_move_teams(state, near_teams, time_speed_mult)
		state.rebuild_team_tile_index()   # post-move rebuild → 下游 co-location/hostile 查見 post-move 位置
		var arrived_near: Array = move_near["arrived"]
		var moved_near: Array = move_near["moved"]
		if _get_player_tile_pos(state) != _player_old_pos:
			_player_cmd.clear_pending_targets(state)
		_step3_propagate_messages(state, moved_near, near_teams)
		_step3b_exchange_intel(state, moved_near, near_teams)
		_step3c_read_market_board(state, arrived_near)
		_step4_resolve_interactions(state, moved_near, near_teams)
		_step4b_outpost_tick(state)
		_step4e_faction_snapshot(state, near_teams)
		_step_ambush_check(state, near_teams)
		if state.encounter_active: return "player_turn"   # 伏擊起 encounter → 交還 bridge
		_step5_collect_resources(state, near_teams, NEAR_CADENCE)
		_step5a_regenerate_tiles(state, NEAR_CADENCE)   # 全 tile 全域再生（每小時）→ 覆蓋 far 區 tile
		_step5b_manufacture(state, near_teams)
		_step6_resolve_consumption(state, near_teams, NEAR_CADENCE)
		_step6c_salary(state, near_teams)
		_step6d_fatigue(state, near_teams, NEAR_CADENCE)
		_step6b_faction_ai(state, near_teams)
		_step6f_training(state, near_teams)
		_step6e_strategic_ai(state)
		_step7_person_reactions(state, near_teams)
		_step7b_npc_goal_cleanup(state, near_teams)
		_step8_generate_events(state, near_teams)
		_step9_emit_messages(state)
		# 階段2 tutorial onboarding：玩家食物盈餘 → 一次性送投奔者小隊（check 內守 forced_event 非空跳過）
		RecruitTutorial.new().check(state)

	# Harvest：每 6 小時（TICKS_PER_DAY / 4）
	if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:
		_step4c_harvest_tick(state)

	# 遠區：每 FAR_ZONE_INTERVAL Tick 跑一次，跳過人物反應
	if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
		_step1b_update_vision(state, far_teams, time_vision_mult)
		_step1c_update_equipment(state, far_teams)
		var move_far: Dictionary = _step2_move_teams(state, far_teams, time_speed_mult)
		state.rebuild_team_tile_index()   # post-move rebuild（far 隊移動後刷新，near 隊位置本 tick 不再變）
		var arrived_far: Array = move_far["arrived"]
		var moved_far: Array = move_far["moved"]
		_step3_propagate_messages(state, moved_far, far_teams)
		_step3b_exchange_intel(state, moved_far, far_teams)
		_step3c_read_market_board(state, arrived_far)
		_step4_resolve_interactions(state, moved_far, far_teams)
		_step4e_faction_snapshot(state, far_teams)
		_step_ambush_check(state, far_teams)
		_step5_collect_resources(state, far_teams, FAR_ZONE_INTERVAL)
		# R1：tile 再生已由 near 分支每小時全域跑（覆蓋 far tile）→ 此處不重複再生（原為 24× 雙記元凶之一）
		_step5b_manufacture(state, far_teams)
		_step6_resolve_consumption(state, far_teams, FAR_ZONE_INTERVAL)
		_step6c_salary(state, far_teams)
		_step6d_fatigue(state, far_teams, FAR_ZONE_INTERVAL)
		_step6b_faction_ai(state, far_teams)
		_step6f_training(state, far_teams)
		_step6e_strategic_ai(state)
		_step8_generate_events(state, far_teams)
		_step9_emit_messages(state)
	_step_captives(state)
	_step_cleanup_extinct_teams(state)
	return ""   # non-encounter tick

# 受控人力 P1：captive 待遇決策 + 軌跡（cadence 內部 gate，全域；同化/暴動/逃 守恆）
func _step_captives(state: WorldState) -> void:
	ManpowerSystem.tick_all(state)

func _step_ambush_check(state: WorldState, team_ids: Array) -> void:
	_ambush_system.check_ambush(state, team_ids)

func _step1d_overflow(state: WorldState) -> void:
	_population_system.check_overflow(state)

# 滅團延遲清除：tick 末單點 route+erase（中途 erase 不安全 — 多系統持 team_ids 快照）
func _step_cleanup_extinct_teams(state: WorldState) -> void:
	_faction_ai_system.cleanup_extinct_teams(state)

func _step1b_update_vision(state: WorldState, team_ids: Array,
		time_vision_mult: float = 1.0) -> void:
	_vision_system.tick_discovery(state, team_ids, time_vision_mult)

func _step1c_update_equipment(state: WorldState, team_ids: Array) -> void:
	_equipment_system.tick_all(state, team_ids)

func _step1_advance_time(state: WorldState) -> void:
	state.world.current_tick += 1
	# driver-ledger tick 溯源：開 ledger 時填當前 tick（off 跳，避 hot path 每 tick 寫）
	if WorldState.driver_ledger_enabled:
		WorldState.driver_tick_hint = state.world.current_tick
	if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:  # 每 6 小時
		state.world.current_turn += 1

func _step2_move_teams(state: WorldState, team_ids: Array,
		time_speed_mult: float = 1.0) -> Dictionary:
	return _movement_system.process(state, team_ids, time_speed_mult)

func _get_time_fatigue_mult(state: WorldState) -> float:
	return _day_night_system.get_fatigue_mult(state)

func _step3_propagate_messages(state: WorldState, arrived_ids: Array, all_ids: Array) -> void:
	_message_system.propagate_on_arrival(state, arrived_ids, all_ids)

func _step3b_exchange_intel(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	_message_system.exchange_intel_on_arrival(state, arrived_ids, all_team_ids)

# WS-2b：抵達某 tile 的隊，若該 tile 是市集 outpost → 親讀看板（firsthand honest，破訂單可見性死鎖）。
# 站在市集才讀得到（read_market_board 內守 outpost_level>0 = 無在場可見）；轉述他隊仍走既有 propagate。
func _step3c_read_market_board(state: WorldState, arrived_ids: Array) -> void:
	var os := OrderSystem.new()
	for tid in arrived_ids:
		if not state.teams.has(tid):
			continue
		os.read_market_board(state, state.teams[tid])

func _step4_resolve_interactions(state: WorldState, moved_ids: Array, all_ids: Array) -> void:
	_interaction_system.process_on_move(state, moved_ids, all_ids)

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

func _step5_collect_resources(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	_resource_system.collect_resources(state, team_ids, cadence_ticks)

func _step5a_regenerate_tiles(state: WorldState, cadence_ticks: int) -> void:
	_resource_system.regenerate_tiles(state, cadence_ticks)

func _step5b_manufacture(state: WorldState, team_ids: Array) -> void:
	_manufacturing_system.tick_all(state, team_ids)

func _step6_resolve_consumption(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	_resource_system.resolve_consumption(state, team_ids, cadence_ticks)

func _step6c_salary(state: WorldState, team_ids: Array) -> void:
	_salary_system.tick(state, team_ids)

func _step6d_fatigue(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	var time_mult: float = _get_time_fatigue_mult(state)
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		if team.current_task == TeamData.TASK_REST:
			# 紮營休息
			var rest_mult: float = 1.0 - team.guard_ratio * 0.5
			team.fatigue -= FATIGUE_RECOVERY_PER_DAY * day_fraction * rest_mult
			team.fatigue = maxf(team.fatigue, 0.0)
		else:
			var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
			var tile = state.world.tiles.get(tile_id)
			var terrain: String = tile.terrain if tile else "plains"
			var terrain_mult: float = TERRAIN_FATIGUE_MULT.get(terrain, 1.0)
			team.fatigue += FATIGUE_PER_DAY * day_fraction * terrain_mult * time_mult
			team.fatigue = minf(team.fatigue, 1.0)
		if team.fatigue >= 1.0:
			for pid in team.named_members:
				var p: PersonData = state.persons.get(pid)
				if p: LoyaltyBank.adjust(p, -FATIGUE_LOYALTY_PENALTY, "fatigue")


func _step6b_faction_ai(state: WorldState, team_ids: Array) -> void:
	_faction_ai_system.evaluate_all(state, team_ids)

func _step6f_training(state: WorldState, team_ids: Array) -> void:
	_training_system.process(state, team_ids)

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

func _get_player_team_sr(state: WorldState) -> TeamData:
	if state.player_id == -1: return null
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return null
	return state.teams.get(p.team_id)

func _get_near_teams(state: WorldState, player_pos: Vector2i) -> Array:
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		# specimen LOD-exempt：一律納 near（每 near-cadence 全 pipeline，完整 trace），mirror player 豁免
		if tid in state.specimen_team_ids \
				or _hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS:
			result.append(tid)
	return result

func _get_far_teams(state: WorldState, player_pos: Vector2i) -> Array:
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		# specimen 已納 near → 不入 far（避免雙跑）
		if tid in state.specimen_team_ids:
			continue
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
