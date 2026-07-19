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
	# established=0 真根定位（blueprint 2026-07-12）：階段A gate funnel
	"indep.gate_ambitious", "indep.gate_fail_pop", "indep.gate_fail_food",
	"indep.gate_fail_busy", "indep.gate_fail_nopath", "indep.gate_path_ok",
	# 階段B（faction→established）gate funnel
	"establish.gate_b1_ok", "establish.gate_fail_b1_members",
	"establish.gate_fail_b2_command", "establish.gate_fail_b3_ambition",
	"establish.gate_fail_b4_readiness", "establish.gate_all_pass",
	# 死隊 forage 斷點定位（blueprint 2026-07-12）：餓死時 task 分類 × owner 狀態
	"extinct.starve_while_foraging_owner", "extinct.starve_while_foraging_nonowner",
	"extinct.starve_while_fleeing_owner", "extinct.starve_while_fleeing_nonowner",
	"extinct.starve_no_forage_owner", "extinct.starve_no_forage_nonowner",
	"g1.engine_survival",
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
	"rep.host_nonneutral",   # 名聲磁鐵：protector_rep 脫 0.5 差別數
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
	# 計畫層 S1：rung 事件驅動 churn（升/降次數；vs baseline 瞬時版比 rung 變更次數=抖動度）
	"g2.ambition_promote", "g2.ambition_demote",
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
	# world-gen variety：結構地板 pass/fail + build-outpost dispatch(靶B)
	"worldgen.floor_pass", "worldgen.floor_fail", "worldgen.build_outpost",
	# S1 追擊放血人格化：追擊次數（放血量/人格加權走 AMOUNT_KEYS）
	"pursuit.n",
	# ② 絕境階梯 stall-detection 健康指標（measurer 要，main 線之前漏收=tap-gap，此份重補）：換格觸發 + boost 觸發頻率
	"survival.stall_exclude", "survival.boost_fire",
	# crisis-override 健康指標（measurer 要）：OUTCOME-based 跨線危機安全網觸發頻率
	"crisis.override_release",
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
	var farming: Dictionary = _farming_snapshot(state)
	var result: Dictionary = {
		"seed": world_seed,
		"total_ticks": total_ticks,
		"farming_final": farming,
		"start_pop": start_pop,
		"end_pop": end_pop,
		"attrition_pct": 0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop),
		"curve": curve,
		"intent": _intent_histogram(state),
		"rung_dist": _rung_histogram(state),
		"decision_opt_dist": _decision_opt_snapshot(),
		"decision_diag": _decision_diag_snapshot(),
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
		"food_econ": _food_econ_snapshot(state),
	}

# 經濟長程診斷（blueprint 2026-07-12 新主線）：食物供需隨時間聚合。複用既有 TeamData.food_flow_avg
# （R2 日均淨食物流 EMA，income−consumption，非新機制）+ 現有 resources.food 存量，純讀不寫、零行為變。
static func _food_econ_snapshot(state: WorldState) -> Dictionary:
	var total_stock: float = 0.0
	var flow_sum: float = 0.0
	var n_flow: int = 0
	var n_negative: int = 0
	var min_flow: float = INF
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		total_stock += float(t.resources.get("food", 0.0))
		if t.food_flow_last >= 0.0:   # -1.0 sentinel＝未初始化取樣，排除
			flow_sum += t.food_flow_avg
			n_flow += 1
			if t.food_flow_avg < 0.0: n_negative += 1
			if t.food_flow_avg < min_flow: min_flow = t.food_flow_avg
	return {
		"total_food_stock": total_stock,
		"avg_food_flow": (flow_sum / float(n_flow)) if n_flow > 0 else 0.0,
		"n_teams_flow_sampled": n_flow,
		"n_teams_negative_flow": n_negative,
		"min_food_flow": min_flow if min_flow != INF else 0.0,
	}

# de-patch 死鎖 pre-build 實證（systems 2026-07-12）：獨立隊 vs faction隊 farming_level 分布 +
# crude camp civ/mil 比例 + farming×存活粗略對照。純讀 tile/team 既有欄位，零行為變。
static func _farming_snapshot(state: WorldState) -> Dictionary:
	var indep_farm_pos: int = 0; var indep_farm_zero: int = 0
	var indep_civ: int = 0; var indep_mil: int = 0
	var fac_farm_pos: int = 0; var fac_farm_zero: int = 0
	var farm_pos_pop: int = 0; var farm_pos_teams: int = 0
	var farm_zero_pop: int = 0; var farm_zero_teams: int = 0
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner == -1: continue
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null: continue
		var is_indep: bool = owner.faction_id == -1
		var has_farm: bool = int(tile.farming_level) > 0
		if is_indep:
			if tile.outpost_type == "civilian": indep_civ += 1
			elif tile.outpost_type == "military": indep_mil += 1
			if has_farm: indep_farm_pos += 1
			else: indep_farm_zero += 1
		else:
			if has_farm: fac_farm_pos += 1
			else: fac_farm_zero += 1
		if has_farm:
			farm_pos_pop += owner.population; farm_pos_teams += 1
		else:
			farm_zero_pop += owner.population; farm_zero_teams += 1
	return {
		"indep_farm_pos": indep_farm_pos, "indep_farm_zero": indep_farm_zero,
		"indep_civ": indep_civ, "indep_mil": indep_mil,
		"faction_farm_pos": fac_farm_pos, "faction_farm_zero": fac_farm_zero,
		"farm_pos_avg_pop": (float(farm_pos_pop) / float(farm_pos_teams)) if farm_pos_teams > 0 else 0.0,
		"farm_zero_avg_pop": (float(farm_zero_pop) / float(farm_zero_teams)) if farm_zero_teams > 0 else 0.0,
		"farm_pos_teams": farm_pos_teams, "farm_zero_teams": farm_zero_teams,
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

# 計畫層 S1：per-rung 分布快照（rung 0-4 各幾隊）——驗階分布不再全卡瞬時抖動。
# per-option 決策 probe 分布（chosen/applicable/coeff_pressed × 23 option）——dynamic key 前綴掃
# Probe.counts（固定 PROBE_KEYS 掃不到 suffix key）。sort key 保 determinism。①全覆蓋/④不死鎖用。
static func _decision_opt_snapshot() -> Dictionary:
	var out: Dictionary = {}
	var keys: Array = Probe.counts.keys()
	keys.sort()
	for k in keys:
		if String(k).begins_with("decision.opt_"):
			out[k] = int(Probe.counts[k])
	return out

# 診斷(裁A) zero-option 三類分流：掃 Probe.counts(appl_n/coeff_pressed)+amounts(*_sum)的 diag.* key。
# sort 保 determinism。measurer 按 coeff_sum/appl_n + mainurg_sum/appl_n + win/own util 分三類。
static func _decision_diag_snapshot() -> Dictionary:
	var out: Dictionary = {}
	var ck: Array = Probe.counts.keys(); ck.sort()
	for k in ck:
		if String(k).begins_with("diag."):
			out[k] = int(Probe.counts[k])
	var ak: Array = Probe.amounts.keys(); ak.sort()
	for k in ak:
		if String(k).begins_with("diag."):
			out[k] = Probe.amounts[k]
	return out

static func _rung_histogram(state: WorldState) -> Dictionary:
	var h: Dictionary = {"r0": 0, "r1": 0, "r2": 0, "r3": 0, "r4": 0}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != -1: continue   # 子隊無獨立 rung 計畫
		var r: int = clampi(t.ambition_rung, 0, 4)
		h["r%d" % r] += 1
	return h

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
