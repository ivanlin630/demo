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
	# 相位計時（opt-in）：spike tick 立即 dump 相位拆解（cadence spike 歸因用）
	if phase_timing and dt_us > PHASE_SPIKE_US:
		var parts: Array = []
		for ph in _ph:
			parts.append({"n": ph, "us": int(_ph[ph])})
		parts.sort_custom(func(a, b): return int(a["us"]) > int(b["us"]))
		var top: String = ""
		for i in range(mini(6, parts.size())):
			top += "%s=%dus " % [parts[i]["n"], parts[i]["us"]]
		print("[PhaseSpike] tick=%d dt=%d us teams=%d | %s" % [
			state.world.current_tick, dt_us, state.teams.size(), top])
	if state.world.current_tick % WorldState.TICKS_PER_DAY == 0 and _perf_count > 0:
		var avg_us: int = _perf_accum_us / _perf_count
		print("[TickPerf] day=%d avg=%d us max=%d us ticks=%d teams=%d factions=%d" % [
			state.world.current_tick / WorldState.TICKS_PER_DAY, avg_us, _perf_max_us,
			_perf_count, state.teams.size(), state.factions.size()])
		_perf_accum_us = 0
		_perf_count = 0
		_perf_max_us = 0

# ── 全高清 perf toggle（opt-in，預設 off = 零行為變；LOD 拿掉 vs 重定義裁決量測）──
# on：_get_near_teams 回全隊、_get_far_teams 回空 → 全隊每 near-cadence 走完整 pipeline（無 far 批次降頻）。
# 僅供 lod_perf_bed tick-time 對照；勿在正式跑開（會改世界節奏=移速/思考頻率恢復全速，需配 gen 重校）。
static var force_full_hd: bool = false

# ── 相位計時儀器（opt-in，預設 off = 零成本零行為變；cadence spike 歸因量測）──
static var phase_timing: bool = false
const PHASE_SPIKE_US: int = 100_000   # TEST VALUE：spike 門檻（>此值 dump 相位拆解）
var _ph: Dictionary = {}              # 本 tick 相位 → 累積 us

# 標記一段相位結束：累積 (now - t0) 到 name，回傳 now（鏈式計時下一段）
func _pht(name: String, t0: int) -> int:
	var now: int = Time.get_ticks_usec()
	_ph[name] = int(_ph.get(name, 0)) + (now - t0)
	return now

# ★seam#3 S1：per-team 系統 registry（near+far 統一 loop，byte-identical 純重構 dispatch 結構）。
# 加 per-team 系統 = 加 SYSTEMS 1 entry（非改 near+far 兩分支）。lod=BOTH(near+far 都跑)/NEAR(僅 near)。
# ★near/far 共同步序本就相同（逐 code 核）→ 單 registry 順序可同時 byte-identical 兩分支。
# ★非平坦（R②②）：move entry 後顯式 checkpoint(rebuild_index=BOTH R②修正 + moved/arrived 抽取
#   + near player-clear)；phase_timing label 掛群組最後 entry(near 才 fire)；near-only glue(player_old
#   capture / encounter-return / RecruitTutorial)以 is_near+entry-name hook。tick 級單次步保 explicit。
# args_shape(R② 補第4型 time_mult)：vision(state,teams,vmult)/teams/teams_cadence/moved(state,moved,teams)
#   /arrived(state,arrived)/state/regen(state,cadence)/move(state,teams,smult,cadence→Dict special)。
const LOD_NEAR: int = 0
const LOD_BOTH: int = 1
static var SYSTEMS: Array = [
	{"name": "vision",           "fn": "_step1b_update_vision",     "lod": LOD_BOTH, "shape": "vision",        "tl": "near.vision"},
	{"name": "equip",            "fn": "_step1c_update_equipment",  "lod": LOD_BOTH, "shape": "teams",         "tl": "near.equip"},
	{"name": "strategic_move",   "fn": "_step2a_strategic_move",    "lod": LOD_BOTH, "shape": "teams",         "tl": ""},
	{"name": "move",             "fn": "_step2_move_teams",         "lod": LOD_BOTH, "shape": "move",          "tl": "near.move"},
	{"name": "propagate",        "fn": "_step3_propagate_messages", "lod": LOD_BOTH, "shape": "moved",         "tl": ""},
	{"name": "intel",            "fn": "_step3b_exchange_intel",    "lod": LOD_BOTH, "shape": "moved",         "tl": ""},
	{"name": "market",           "fn": "_step3c_read_market_board", "lod": LOD_BOTH, "shape": "arrived",       "tl": "near.messages"},
	{"name": "interactions",     "fn": "_step4_resolve_interactions","lod": LOD_BOTH,"shape": "moved",         "tl": "near.interact"},
	{"name": "outpost_tick",     "fn": "_step4b_outpost_tick",      "lod": LOD_NEAR, "shape": "state",         "tl": ""},
	{"name": "faction_snapshot", "fn": "_step4e_faction_snapshot",  "lod": LOD_BOTH, "shape": "teams",         "tl": ""},
	{"name": "ambush",           "fn": "_step_ambush_check",        "lod": LOD_BOTH, "shape": "teams",         "tl": "near.outpost_ambush"},
	{"name": "collect",          "fn": "_step5_collect_resources",  "lod": LOD_BOTH, "shape": "teams_cadence", "tl": ""},
	{"name": "regen",            "fn": "_step5a_regenerate_tiles",  "lod": LOD_NEAR, "shape": "regen",         "tl": ""},
	{"name": "manufacture",      "fn": "_step5b_manufacture",       "lod": LOD_BOTH, "shape": "teams",         "tl": "near.economy"},
	{"name": "consumption",      "fn": "_step6_resolve_consumption","lod": LOD_BOTH, "shape": "teams_cadence", "tl": ""},
	{"name": "salary",           "fn": "_step6c_salary",            "lod": LOD_BOTH, "shape": "teams",         "tl": ""},
	{"name": "fatigue",          "fn": "_step6d_fatigue",           "lod": LOD_BOTH, "shape": "teams_cadence", "tl": "near.consume"},
	{"name": "faction_ai",       "fn": "_step6b_faction_ai",        "lod": LOD_BOTH, "shape": "teams",         "tl": "near.faction_ai"},
	{"name": "info_dispatch",    "fn": "_step6b2_info_dispatch",    "lod": LOD_BOTH, "shape": "teams",         "tl": "near.faction_ai"},
	{"name": "training",         "fn": "_step6f_training",          "lod": LOD_BOTH, "shape": "teams",         "tl": ""},
	{"name": "strategic_ai",     "fn": "_step6e_strategic_ai",      "lod": LOD_BOTH, "shape": "state",         "tl": "near.strategic_ai"},
	{"name": "reactions",        "fn": "_step7_person_reactions",   "lod": LOD_NEAR, "shape": "teams",         "tl": ""},
	{"name": "cleanup",          "fn": "_step7b_npc_goal_cleanup",  "lod": LOD_NEAR, "shape": "teams",         "tl": "near.reactions"},
	{"name": "events",           "fn": "_step8_generate_events",    "lod": LOD_BOTH, "shape": "teams",         "tl": ""},
	{"name": "emit",             "fn": "_step9_emit_messages",      "lod": LOD_BOTH, "shape": "state",         "tl": "near.events_emit"},
]

# 統一 near/far 系統 loop。is_near=true 跑 NEAR+BOTH（+near-only glue+分組 _pht）；false 僅 BOTH（無 _pht）。
# 回 {"result": String, "t": int}——result="player_turn"=near 伏擊起 encounter 早退；t=更新後 timing 鏈點。
func _run_systems(state: WorldState, teams: Array, cadence: int, vmult: float, smult: float,
		is_near: bool, t_in: int) -> Dictionary:
	var _t: int = t_in
	var moved: Array = []
	var arrived: Array = []
	var player_old: Vector2i = Vector2i.ZERO
	for sys in SYSTEMS:
		if int(sys["lod"]) == LOD_NEAR and not is_near:
			continue
		var sname: String = sys["name"]
		var fn: String = sys["fn"]
		# near-only pre-hook：move 前擷取 player 舊位（供 move 後偵測玩家移動清 pending target）。
		if is_near and sname == "strategic_move":
			player_old = _get_player_tile_pos(state)
		match String(sys["shape"]):
			"vision":        call(fn, state, teams, vmult)
			"teams":         call(fn, state, teams)
			"teams_cadence": call(fn, state, teams, cadence)
			"moved":         call(fn, state, moved, teams)
			"arrived":       call(fn, state, arrived)
			"state":         call(fn, state)
			"regen":         call(fn, state, cadence)
			"move":
				var mv: Dictionary = call(fn, state, teams, smult, cadence)
				state.rebuild_team_tile_index()   # ★BOTH post-move rebuild（near+far 各一次；下游 co-location/hostile 查 post-move 位）
				arrived = mv["arrived"]
				moved = mv["moved"]
				if is_near and _get_player_tile_pos(state) != player_old:
					_player_cmd.clear_pending_targets(state)
		# near-only post-hook：emit 後、near.events_emit _pht 前送 tutorial 投奔者。
		if is_near and sname == "emit":
			RecruitTutorial.new().check(state)
		# phase_timing 群組邊界（near 才 fire；label 掛該組最後 entry）。
		var tl: String = sys["tl"]
		if is_near and phase_timing and tl != "":
			_t = _pht(tl, _t)
		# near-only：伏擊起 encounter（near.outpost_ambush 後）→ 交還 bridge。
		if is_near and sname == "ambush" and state.encounter_active:
			return {"result": "player_turn", "t": _t}
	return {"result": "", "t": _t}

# seam#3 擴充 proof 用 test-support no-op（僅測試 append dummy entry 時觸發；一般 sim 無此 entry）。
func _seam3_dummy_step(_state: WorldState) -> void:
	Probe.bump("seam3.dummy")

func _advance_tick_body(state: WorldState, player_pos: Vector2i) -> String:
	if phase_timing: _ph.clear()   # 相位計時：每 tick 重置
	if state.encounter_active:
		var _te: int = Time.get_ticks_usec() if phase_timing else 0
		var result: String = _encounter_system.advance_encounter_tick(state)
		if result not in ["ongoing", "player_turn"]:
			_encounter_system.resolve_encounter_end(state, result)
		_step1_advance_time(state)
		if phase_timing: _pht("encounter", _te)
		return result    # propagate to bridge
	_step1_advance_time(state)
	var _t: int = Time.get_ticks_usec() if phase_timing else 0   # 相位計時鏈起點
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
	if phase_timing: _t = _pht("day_boundary", _t)

	var time_speed_mult: float = _day_night_system.get_speed_mult(state)
	var time_vision_mult: float = _day_night_system.get_vision_mult(state)

	# 近區：每小時執行
	if state.world.current_tick % NEAR_CADENCE == 0:
		var near_teams := _get_near_teams(state, player_pos)
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
						beggar_t.update_reputation(pt_t.team_id, -0.1)   # S12 chokepoint（等價 clampf(cur-0.1,0,1)）
						NpcAiSystem.new().write_memory(b_leader_t, "rejected_aid",
							pt_t.team_id, state.world.current_tick, 0.5)
					state.clear_social_target(beggar_t)   # BEG 現走 social_target（非 combat_target）
					if beggar_t.previous_task != "" and beggar_t.previous_task != TeamData.TASK_IDLE:
						# release-first + move_target 存/還（同 _clear_aid_task；release 清 -1，resume 需原目的地）。
						var saved_mt: Vector2i = beggar_t.move_target
						TaskArbiter.release(beggar_t)
						TaskArbiter.try_set(state, beggar_t, beggar_t.previous_task, saved_mt,
							TaskArbiter.PRIO_DISPATCH, "beggar_restore")
					else:
						TaskArbiter.release(beggar_t)
					beggar_t.previous_task = ""
			print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
			state.player_forced_event = {}
			state.player_forced_event_id = ""
		if phase_timing: _t = _pht("near.forced_event", _t)
		# ★seam#3 S1：near 塊改 SYSTEMS registry 統一 loop（NEAR+BOTH，含分組 _pht + near-only glue）。
		var near_r: Dictionary = _run_systems(state, near_teams, NEAR_CADENCE,
			time_vision_mult, time_speed_mult, true, _t)
		_t = near_r["t"]
		if near_r["result"] == "player_turn": return "player_turn"   # 伏擊起 encounter → 交還 bridge

	# Harvest：每 6 小時（TICKS_PER_DAY / 4）
	if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:
		_step4c_harvest_tick(state)
	if phase_timing: _t = _pht("harvest", _t)

	# 遠區：每 FAR_ZONE_INTERVAL Tick 跑一次，跳過人物反應
	if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
		var far_teams := _get_far_teams(state, player_pos)
		# ★seam#3 S1：far 塊改 SYSTEMS registry 統一 loop（僅 BOTH，無分組 _pht；跳 near-only:reactions/
		# cleanup/tile-regen/outpost_tick/tutorial）。tile 再生已由 near 每小時全域跑覆蓋 far tile（不重複=原 24× 雙記元凶）。
		_run_systems(state, far_teams, FAR_ZONE_INTERVAL,
			time_vision_mult, time_speed_mult, false, _t)
	if phase_timing: _t = _pht("far.total", _t)
	_step_captives(state)
	_step_cleanup_extinct_teams(state)
	if phase_timing: _t = _pht("captives_cleanup", _t)
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
		time_speed_mult: float = 1.0, elapsed_ticks: int = WorldState.TICKS_PER_HOUR) -> Dictionary:
	return _movement_system.process(state, team_ids, time_speed_mult, elapsed_ticks)

# A2c-2 折入（候選 C）：戰略移動 move_target 設值——從舊 movement:66-77 直讀 bypass 搬來，
# 於 movement 前跑（byte-identical：同 read-point、同 gate、同突圍優先 tie-break、同 sa_pos 值）。
# arbiter-owned write（set_strategic_move 內建戰鬥鎖+FLEE guard）；居民鎖 guard 留 call-site（需 _is_resident_team）。
# task 完全不動（保 IDLE→interaction:253 自發併隊）。STRAT_OVERLAY_OFF 續 stub（characterization 對照）。
func _step2a_strategic_move(state: WorldState, team_ids: Array) -> void:
	if OS.has_environment("STRAT_OVERLAY_OFF"):
		return
	var fai := FactionAISystem.new()
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# 居民鎖 guard（原 movement:58-63，call-site；防駐守居民被拉去戰略位）
		if team.tags.has(TeamData.TAG_PRODUCE):
			if fai._is_resident_team(state, team) \
					and team.current_task not in [TeamData.TASK_FLEE, TeamData.TASK_JOIN, TeamData.TASK_REVOLT, TeamData.TASK_MIGRATE, TeamData.TASK_PREPARE]:
				continue
		if team.strategic_assignments.size() == 0:
			continue
		# 突圍優先 tie-break（-1 key=突圍位；否則正整數 key=包圍位），鏡射舊 movement:67-70
		var sa_pos: Vector2i
		if team.strategic_assignments.has(-1):
			sa_pos = team.strategic_assignments[-1]
		else:
			sa_pos = team.strategic_assignments.values()[0]
		TaskArbiter.set_strategic_move(team, sa_pos)   # 內建戰鬥鎖+FLEE guard

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
		# 漏斗站5探針（純觀測）：TRADE 隊走到 move_target（arrived = 本 tick 到點）
		var _t: TeamData = state.teams[tid]
		if Probe.enabled and _t.current_task == TeamData.TASK_TRADE:
			Probe.bump("trade.arrive")
		os.read_market_board(state, _t)
		# unified-commerce M2：TRADE 隊到市集 outpost → market-as-place 到場 resolver（owner-mediated，免賣方在場）。
		if _t.current_task == TeamData.TASK_TRADE:
			var _mt: HexTileData = state.world.tiles.get(_t.tile_pos.x * 1000 + _t.tile_pos.y)
			if _mt != null and _mt.outpost_level > 0 and _mt.outpost_owner != _t.team_id:
				_interaction_system._resolve_market_at_outpost(state, _t, _mt)
				# 到市場（arrived＝到 dest）→ 交易畢 release 重評（避免 TASK_TRADE latch 卡死市集不再 fire）。
				# 續有需求→下輪 re-dispatch 再赴市場＝連續交易循環（非一次凍結）。
				if _t.move_target == Vector2i(-1, -1) or _t.tile_pos == _t.move_target:
					Probe.bump("trade.release_at_dest")
					TaskArbiter.release(_t)

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

func _step6b2_info_dispatch(state: WorldState, team_ids: Array) -> void:
	# ★資訊網 Part2 (a) side-action：求援/偵察 平行 side-dispatch（脫主 argmax、每 team 評 mini-util cost-benefit）。
	_faction_ai_system.info_side_dispatch_all(state, team_ids)

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
	if force_full_hd:
		return state.teams.keys()   # perf 對照：全隊 near（無 LOD 分區）
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		# 觀測非侵入：移除 specimen LOD-exempt（原強制 specimen 升 near → 岔 RNG → 改世界=Heisenberg 侵入）。
		# specimen trace 改走 force_full_hd 全-HD acceptance（judged-world）；normal LOD 下 specimen 不再特殊待遇。
		if _hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS:
			result.append(tid)
	return result

func _get_far_teams(state: WorldState, player_pos: Vector2i) -> Array:
	if force_full_hd:
		return []                   # perf 對照：無 far 批次
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		# 觀測非侵入：移除 specimen far 豁免（原 specimen 跳 far 降級 → 岔 RNG）。specimen 正常參與 LOD 分區。
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
