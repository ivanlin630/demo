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
	"indep.found_ally", "indep.found_subjugate", "indep.found_timeout",
	# ②a 信使外交結局分佈（藍圖要的「怎麼沒結盟」fail 分佈）
	"envoy.dispatched", "envoy.delivered", "envoy.accept", "envoy.reject",
	"envoy.timeout", "envoy.target_dead",
	"envoy.gift_sent", "envoy.gift_delivered",
	"conq.intent", "conq.prosperity_reached",
	"p1.assimilate", "p1.revolt", "p1.flee",
	"beg.dispatch", "beg.resolve", "join.dispatch", "join.resolve",
	# A2c-1 full_probe：求生整併(consolidation)維度——merge 實派 + merge-applicable 隊 option 去向(該併卻選別的)
	"merge.consolidate_dispatch", "merge_appl.total", "merge_appl.chose_整併", "merge_appl.chose_other",
	# S-A 併決策統一：雙邊握手 accept-util 收/拒 + 餵養 gate#1 事件數
	"accept.join_accept", "accept.join_reject", "accept.merge_accept", "accept.merge_reject", "consol.accept_n",
	"merge.pair_seen", "merge.branch_reached", "merge.try_entered", "merge.guard_fail_ordertgt",
	"merge.set_ok", "merge.set_fail",
	"merge.mv_reached", "merge.mv_block_combat", "merge.mv_no_target", "merge.mv_moving",
	"merge_appl.food_lt3", "merge_appl.food_3to6", "merge_appl.food_ge6",
	"merge.surv_ok", "merge.surv_fail",
	"mergein.dissolve", "mergein.subteam",   # §HOW-6 分流兩端（對稱空窗守衛：任一=0→INCONCLUSIVE）
	"absorb.dispatch", "absorb.target_found", "absorb.util_n", "absorb.slack_pos", "absorb.yield_pos",   # §HOW-7/8 診斷
	# A2c-2 D0：戰略移動 overlay(FA6)characterization——overlay 生效頻率 + 包圍/突圍指派 + 到達
	"strat.sa_move_dispatch", "strat.encircle_assigned", "strat.breakout_assigned", "strat.expand_reached",
	# R1 驗收（三帶+logistics）：絕境仍搏 / ③管住獨立隊攻屬村 / 貿易量（guard ④）
	"surv.loot_dispatch", "conq.indep_atk_believed_owned", "g1.arb_hit",
	# 征服 winner funnel（引擎實選：loot vs 攻擊=直接看階梯；bump 點多已存在 code，此擴收）
	"conq.declared", "conq.winner_loot", "conq.winner_prosperity", "conq.winner_other", "conq.winner_none",
	"conq.member_atk_eligible", "conq.member_atk_dispatch",
	"conq.combat_entered", "conq.combat_decisive", "conq.win_absorbed", "conq.win_no_absorb",
	# 死因分解（Task1：餓/戰/叛離縮編/滅團分類）
	"death.starve_minor", "death.starve_anon", "death.combat_pop", "death.combat_named", "death.defect_leave",
	"extinct.starve", "extinct.combat", "extinct.other",
	# 反應計數（Task2：9 反應 apply winner）
	"reaction.P1_comply", "reaction.P2_produce", "reaction.P4_expand", "reaction.N1_flee",
	"reaction.N2_riot", "reaction.N3_defect", "reaction.N4_shirk", "reaction.N5_extort", "reaction.breed",
	# 照妖鏡#1：潰退門檻膽量化——總潰退 + courage 三桶潰退數（readiness 均值走 probe_amounts）
	"rout.total", "rout.n_high", "rout.n_mid", "rout.n_low",
	# combat-defeat characterization：結束原因分布 + race（敗方 readiness 距門檻）+ 小隊
	"combat.end_annihilation", "combat.end_rout", "combat.end_retreat", "combat.ended_n",
	"combat.end_readiness_above_thr", "combat.pop_start_le3",
	# 敗北出路前置：絕境逃（膽量秤，殲滅線前）分開標籤 + str_ratio 樣本數 + courage 桶（照妖鏡#1 啟動證）
	"combat.end_mortal_flee", "mortal_flee.n", "combat.str_ratio_annih_n",
	"mortal_flee.n_high", "mortal_flee.n_mid", "mortal_flee.n_low",
	"annih.n_high", "annih.n_mid", "annih.n_low",
	# 潰逃俘虜（真俘虜端信號，capture.total 不含此路）：控地俘殘部 vs 沒俘
	"conq.combat_retreat", "conq.retreat_captured", "conq.retreat_no_capture",
	# S1 追擊放血人格化：追擊次數（放血量/人格加權走 AMOUNT_KEYS）
	"pursuit.n",
]

# 跑固定 seed warring 世界 total_ticks tick → 回結構化 metric（逐點可對照）。
# 回傳 dict：seed / start_pop / curve[月快照] / intent[final histogram] / final / probe[counts 子集]。
static func run(world_seed: int, total_ticks: int,
		config_path: String = "res://config/warring_states.json") -> Dictionary:
	seed(world_seed)   # 播 global RNG（runtime 72 處 bare randf/randi）→ 每跑重置流、逐 tick 確定
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()   # A2b 守衛 B ledger 每 run 重置（防跨 run 污染）
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
		"probe_amounts": _probe_amounts_subset(),
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

# 浮點累計 subset（照妖鏡#1：courage 桶 readiness-at-retreat 總和 → 均值=sum/n_bucket）
const AMOUNT_KEYS: Array = ["rout.ready_sum_high", "rout.ready_sum_mid", "rout.ready_sum_low",
	"combat.rounds_sum", "combat.pop_start_sum", "combat.loser_readiness_end_sum", "combat.loser_wnd_end_sum",
	"mortal_flee.readiness_sum", "combat.str_ratio_annih_sum", "combat.pop_ratio_annih_sum",
	"pursuit.loss_sum", "pursuit.cruelty_sum", "pursuit.greed_sum",
	# S-A gate#1（餵養真解非搬餓）：併前 absorber/joiner 餘命 + 併後合隊餘命 + 隊規模分布
	"consol.combined_days_sum", "consol.absorber_days_sum", "consol.joiner_days_sum", "consol.absorber_pop_sum",
	"absorb.slack_sum", "absorb.yield_sum"]
static func _probe_amounts_subset() -> Dictionary:
	var d: Dictionary = {}
	for k in AMOUNT_KEYS:
		d[k] = Probe.amount(k)
	return d
