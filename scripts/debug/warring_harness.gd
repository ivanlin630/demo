class_name WarringHarness

# Seeded warring 回歸 harness 共用 runner（純 debug/infra，零 sim 邏輯變）。
# seed() 播 global RNG（runtime randf/randi） + config.seed 播 setup RNG（map/team/person gen）
# → 同 world_seed 逐 tick 逐隊完全重現。warring_states_seed / seeded_warring_bed / headless 重現性測共用。
#
# RNG 盤點（2026-07-02）：
#   - setup（game_setup/world_generator/person_generator）用 local RandomNumberGenerator，seed 自 config.seed → 已確定
#   - runtime 72 處 bare global randf()/randi() → seed() 播 global RNG 全納
#   - world_generator.gd:36 rng.randomize() 僅 config.seed==-1 時走；本 harness 覆寫 config.seed → 不走
#   - Time.get_ticks_usec() 僅 perf 計時（不入 sim state/metric）→ 不影響確定性
#   - scaling_bed.gd 自有 RNG = 獨立 debug 床，非 warring harness → 不納

const _INTENT_ASCII: Dictionary = {"征服": "CONQUER", "致富": "RICH", "防衛": "DEFEND",
	"守成": "HOLD", "擴張": "EXPAND", "建國": "FOUND"}

# emergent probe key（commander 協同 + 信息域 + 受控人力 + 死路量化）
const PROBE_KEYS: Array = [
	"capture.total", "capture.by_attack",
	"g2.faction_found", "g2.feud_formed", "g2.vendetta_trigger",
	"g3.scout_dispatch", "g3.betrayal", "g3.trust_up", "g3.trust_down",
	"indep.found_ally", "indep.found_subjugate",
	"conq.intent", "conq.prosperity_reached",
	"p1.assimilate", "p1.revolt", "p1.flee",
	"beg.dispatch", "beg.resolve", "join.dispatch", "join.resolve",
	# R1 驗收（三帶+logistics）：絕境仍搏 / ③管住獨立隊攻屬村 / 貿易量（guard ④）
	"surv.loot_dispatch", "conq.indep_atk_believed_owned", "g1.arb_hit",
]

# 跑固定 seed warring 世界 total_ticks tick → 回結構化 metric（逐點可對照）。
# 回傳 dict：seed / start_pop / curve[月快照] / intent[final histogram] / final / probe[counts 子集]。
static func run(world_seed: int, total_ticks: int,
		config_path: String = "res://config/warring_states.json") -> Dictionary:
	seed(world_seed)   # 播 global RNG（runtime 72 處 bare randf/randi）→ 每跑重置流、逐 tick 確定
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(config_path)
	if config.is_empty():
		Probe.enabled = false
		return {}
	config["seed"] = world_seed   # 播 setup RNG（map/team/person gen local rng）→ 同 seed 同世界
	GameSetup.setup(state, config)

	var start_pop: int = _total_pop(state)
	var no_player := Vector2i(-1, -1)
	var curve: Array = []
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			curve.append(_snapshot((tick + 1) / WorldState.TICKS_PER_MONTH, state))
		if state.teams.is_empty():
			curve.append(_snapshot(-1, state))   # 全滅哨兵
			break

	var end_pop: int = _total_pop(state)
	var result: Dictionary = {
		"seed": world_seed,
		"total_ticks": total_ticks,
		"start_pop": start_pop,
		"end_pop": end_pop,
		"attrition_pct": 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop),
		"curve": curve,
		"intent": _intent_histogram(state),
		"final": {
			"teams": state.teams.size(), "factions": state.factions.size(),
			"established": _established_count(state), "pop": end_pop,
		},
		"probe": _probe_subset(),
	}
	Probe.enabled = false
	return result

static func _snapshot(month: int, state: WorldState) -> Dictionary:
	return {
		"month": month,
		"teams": state.teams.size(),
		"factions": state.factions.size(),
		"established": _established_count(state),
		"pop": _total_pop(state),
		"intent": _intent_histogram(state),
	}

static func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams:
		n += state.teams[tid].population
	return n

static func _established_count(state: WorldState) -> int:
	var n: int = 0
	for fid in state.factions:
		if state.factions[fid].is_established: n += 1
	return n

# 統一 intent 分布 = faction commander(f.intent) + 獨立隊(solo_intent)。跨實體型一套菜單。
static func _intent_histogram(state: WorldState) -> Dictionary:
	var h: Dictionary = {"CONQUER": 0, "RICH": 0, "DEFEND": 0, "HOLD": 0, "EXPAND": 0, "FOUND": 0, "NONE": 0}
	for fid in state.factions:
		var f = state.factions[fid]
		var it: String = f.intent.get("type", "") if f.intent is Dictionary else ""
		h[_INTENT_ASCII.get(it, "NONE")] += 1
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.parent_team_id != -1: continue   # 只獨立隊（非子隊）
		var si: String = String(t.solo_intent.get("type", "")) if t.solo_intent is Dictionary else ""
		h[_INTENT_ASCII.get(si, "NONE")] += 1
	return h

static func _probe_subset() -> Dictionary:
	var d: Dictionary = {}
	for k in PROBE_KEYS:
		d[k] = int(Probe.counts.get(k, 0))
	return d
