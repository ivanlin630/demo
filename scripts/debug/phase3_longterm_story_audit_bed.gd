extends SceneTree

# [measurer持久fixture 2026-08-12] ③長期故事驗證 first-pass story-audit(整系統believability)。
# ticket:docs/superpowers/handbacks/2026-08-12-systems-to-measurer-phase3-longterm-story-audit.md
#        docs/superpowers/handbacks/2026-08-12-systems-to-measurer-phase3-root-diagnose.md
# ★中性觀察禁預設,產中性長局敘事+top incoherences ranked。
# vehicle:複製WarringHarness.run()同款tick迴圈+config(seed1337,warring_states.json),疊加近期系統
# (promote/migrant/invest/relocate/mobilize)逐月delta,既有欄位(teams/factions/established/pop/intent/
# food_econ)沿用WarringHarness._snapshot同款靜態helper直呼(避免碰established infra、零sim邏輯變)。
#
# ★★★危險已坐實(2026-08-12 isolation A/B)：state.specimen_team_ids 若直設成非
# SpecimenDumpHelper.setup_from_env()(strided)的自訂清單(如本檔一度試過的『8個faction leader』)，
# 會真的改變同 seed 的世界演化(teams 130→148/pop 299→298，非只 specimen 內容不同，是世界本身分岔)。
# 純9個Probe.bump temp diag tap(已revert)本身經隔離確認中性、非分岔原因。
# 見 handback:2026-08-12-measurer-to-systems-phase3-root-diagnose-verdict.md。
# → 這個 bed 之後永遠只用 SpecimenDumpHelper.setup_from_env()（下方），別手動改 specimen_team_ids。
#
# #3①/#4/#5 root-diagnose 用的 _leader_diag()(逐月讀 8 faction leader 立國gate/anon tier/faction intent)
# 已獨立驗證中性(隔離跑數字與無此函式的原始跑逐位元一致)，可安心保留常駐。
# 若要重跑 #3②③ 的 spawn 來源分布/migrant-invest evaluated-vs-fired，需重新短暫加回以下 9 個
# temp Probe.bump(已revert,不在目前 production)：
#   faction_ai_system.gd migrant.mini_util/invest.roi 旁各加一行 evaluated 計數、
#   subteam_system.gd dispatch()/dispatch_anon_migrants()/dispatch_anon_messenger() 三處 create_team 後
#   加 spawn.dispatch_<task>/spawn.migrant/spawn.messenger、
#   reaction_system.gd/population_system.gd/manpower_system.gd/event_unrest_split.gd 四處
#   create_team 後各加 spawn.solo_exile/spawn.overflow_split/spawn.captive_breakaway/spawn.unrest_split。

const WORLD_SEED: int = 1337
const CONFIG_PATH := "res://config/warring_states.json"

func _initialize() -> void:
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.has_environment("LW_MONTHS") else 12
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== ③長期故事驗證(seed=%d %d月 ticks=%d) ===" % [WORLD_SEED, months, total_ticks])

	seed(WORLD_SEED)
	Probe.enabled = true
	Probe.reset()
	# ★嚴格食物守恆帳(2026-08-13)：開既有driver-ledger(WorldState.record_driver,ResourceBank/TileBank
	# 全部8個banker函式已呼叫,零新production tap,只是平常off省成本)——逐tick drain(避4096 ring cap
	# 被非food寫入擠掉)進自家per-reason累加器,只留field=="food"的entry。
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var food_flow: Dictionary = {}   # reason -> Σdelta（全程累加,月底才印,零reset）
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = WORLD_SEED
	GameSetup.setup(state, config)

	SpecimenDumpHelper.setup_from_env(state)   # ★別改成手動 specimen_team_ids，見上方危險註記

	# ★守恆帳close-check真正t0快照(2026-08-13追加,修正版):必須在tick loop開始前(setup剛完成後)拍,
	# 否則day1快照(原pool_curve[0])已經吃掉day1當天的flow,跟food_flow(從setup起算全累加)重複計入
	# day1那段→diff偏差≈gen_seed+init_preset量級(已跑一次驗證坐實此偏差來源非漏tap)。
	var pool_true_t0: Dictionary = _pool_census(state, 0)
	WorldState.clear_driver_ledger()   # ★丟setup期間(gen_seed/init_preset)已排隊的entry——已烤進pool_true_t0快照,
	# 不丟會被下面tick loop第一次drain重複算(state已變+driver又算一次=雙計)。

	var new_keys: Array = ["promote.fired", "promote.field_desperate",
		"migrant.dispatched", "migrant.arrived", "invest.dispatched",
		"relocate.ordered", "relocate.comply", "relocate.resist", "relocate.started",
		"relocate.abandoned", "relocate.arrived", "relocate.resettled",
		"cohesion.defect_fire", "cohesion.uprising_stay_faction", "g2.ambition_promote", "g2.ambition_demote",
		"g2.faction_found", "death.combat_pop", "death.starve_anon",
		"merge.consolidate_dispatch", "merge.set_ok", "mergein.dissolve", "mergein.subteam",
		# #3② 真 funnel=JOIN（併入→TASK_JOIN，非 TASK_MERGE，systems 2026-08-13 更正）：
		# to_task 三分流(本輪新加 temp tap)+既有 production tap(join.dispatch/arrived_no_handler/accept.join_accept)。
		"join.to_task_no_host", "join.to_task_belief_gap", "join.to_task_ok",
		"join.dispatch", "join.arrived_no_handler", "accept.join_accept", "accept.join_reject",
		# #3③ target-resolution 分野（本輪新加 temp tap）：belief-不知(est_null) vs 真無正值(marg/roi_nonpositive)。
		"migrant.holding_seen", "migrant.est_null", "migrant.marg_nonpositive", "migrant.util_evaluated",
		"invest.holding_seen", "invest.est_null", "invest.already_farming", "invest.roi_nonpositive",
		"invest.roi_evaluated",
		# #新A 零戰死 pin：真 NPC combat 走 npc_combat_system.gd(interaction_system.gd:323-342 start_combat)，
		# 非 encounter_system.gd(僅player/beast-ambush 用，headless 無player 理論上 encounter_active 恆false，
		# 下方 watchdog_hits/encounter_ever_active 實測驗證此假設非只code-read猜)。全部既有 production tap，零新改。
		"conq.combat_entered", "conq.combat_decisive", "conq.combat_retreat",
		"death.combat_pop", "death.combat_named", "combat.ended_n",
		"atk.reached", "atk.blocked_ct_197",
		# 零戰死 root REFINE：_find_weakest_prey 內部逐段 breakdown（本輪新加 6 個 temp tap）+
		# faction 攻擊 directive 兩段(本輪新加 2 個 temp tap)。
		"prey.call_count", "prey.call_empty_pool", "prey.candidates_seen", "prey.no_belief",
		"prey.unreachable", "prey.not_weak_enough", "prey.found",
		"prey.faction_attack_stake", "prey.faction_attack_target_found",
		# 零戰死 CLEAN combat funnel（supersede attack-gate）：攻擊/掠奪無條件fire計數(本輪新加2個temp)+
		# 既有production tap(raid.*/combatopt無新改)。
		"combatopt.fire_攻擊", "combatopt.fire_掠奪",
		"raid.resolve", "raid.extort", "raid.combat_at_outpost", "raid.combat_open_field", "raid.loot_noresolve",
		# 證據包A⑥ 第三路resident化=佔村(全既有production tap,零新改,上輪camp/settle已確認雙0這輪不重複tap)。
		"occupy.applicable", "occupy.ctx_hastarget", "occupy.appl_kill_pop", "occupy.appl_kill_hasbase",
		"occupy.dispatch", "occupy.dispatch_survival", "occupy.scan_outpost_target", "occupy.scan_kill_nobel",
		"occupy.scan_kill_unreach", "occupy.scan_kill_notweak", "occupy.scan_kill_margin", "occupy.scan_passed",
		"occupy.capture_flip",
		# production funnel④流通率(全既有production trade.market_bail.* tap,零新改)。
		"trade.market_bail.buy_no_stock", "trade.market_bail.buy_no_want", "trade.market_bail.buy_cant_afford",
		"trade.market_bail.buy_carry_full", "trade.market_bail.buy_withdraw_empty",
		"trade.market_bail.sell_no_surplus", "trade.market_bail.sell_ownerless", "trade.market_bail.sell_owner_no_coin",
		"trade.market_bail.sell_no_price", "trade.market_bail.sell_owner_cant_afford", "trade.market_bail.sell_zero_qty",
		"trade.market_bail.sell_storage_full", "trade.peer_deal",
		# A2 diagnostic-first(2026-08-13,measurer):settle-into-existing per-gate funnel pin(全新temp tap,用完revert)。
		"a2.evaluate_team_tick", "a2.own_empty_outpost_seen", "a2.no_resident_pass", "a2.reach_dispatch_or_invite",
		"a2.pop_ge8_pass", "a2.pop_ge8_fail", "a2.dispatch_score_wins", "a2.invite_score_wins",
		"a2.route_dispatch", "a2.route_invite", "a2.route_military_dead_end",
		"a2.dispatch_pop_after_gate_pass", "a2.dispatch_pop_after_gate_fail",
		"a2.dispatch_no_sub_leader", "a2.dispatch_subteam_create_fail", "a2.dispatch_task_settle_set",
		"a2.invite_call", "a2.invite_candidate_exile_tag", "a2.invite_candidate_pass_filter", "a2.invite_belief_null", "a2.invite_out_of_range",
		"a2.invite_range_pass", "a2.invite_accept", "a2.invite_reject", "a2.invite_task_settle_set",
		"a2.convert_via_subteam_arrival", "a2.convert_via_pair_interaction",
		"worldgen.build_outpost"]
	var prev_new: Dictionary = {}
	for k in new_keys: prev_new[k] = 0
	var mobilize_peak_prev: float = 0.0

	var curve: Array = []
	var daily_curve: Array = []   # ★饑荒genuine-vs-bug診斷:逐日全域census(fragment vs 主隊food_days對照)+8 leader逐日food/task
	var pool_curve: Array = []   # ★嚴格守恆帳:逐日四pool(Σteam.food/Σgranary/Σtile-regen-pool/GRAND)
	var start_pop: int = _total_pop(state)
	var no_player := Vector2i(-1, -1)
	var extinct_tick: int = -1
	var prev_starve: int = 0

	var watchdog_hits: int = 0
	var encounter_ever_active: bool = false
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if not WorldState.driver_ledger.is_empty():   # 每tick drain,避非food寫入把food entry擠出ring cap
			for _e in WorldState.driver_ledger:
				if String(_e.get("field", "")) == "food":
					var _r: String = String(_e.get("reason", ""))
					food_flow[_r] = float(food_flow.get(_r, 0.0)) + float(_e.get("delta", 0.0))
			WorldState.clear_driver_ledger()
		if state.encounter_active:
			encounter_ever_active = true
			if state.encounter_tick > 800:
				watchdog_hits += 1
				runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var day: int = (tick + 1) / WorldState.TICKS_PER_DAY
			var cur_starve: int = int(Probe.counts.get("death.starve_anon", 0))
			daily_curve.append(_daily_census(state, day, cur_starve - prev_starve))
			prev_starve = cur_starve
			pool_curve.append(_pool_census(state, day))
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var month: int = (tick + 1) / WorldState.TICKS_PER_MONTH
			var snap: Dictionary = {
				"month": month, "teams": state.teams.size(), "factions": state.factions.size(),
				"established": WarringHarness._established_count(state), "pop": _total_pop(state),
				"intent": WarringHarness._intent_histogram(state)}
			var new_delta: Dictionary = {}
			for k in new_keys:
				var cur: int = int(Probe.counts.get(k, 0))
				new_delta[k] = cur - int(prev_new[k])
				prev_new[k] = cur
			snap["new_delta"] = new_delta
			snap["mobilize_fraction_peak"] = float(Probe.peaks.get("mobilize.fraction", 0.0))
			snap["leaders"] = _leader_diag(state)
			curve.append(snap)
			print("[月%d] team=%d faction=%d established=%d pop=%d intent=%s newdelta=%s mobilize_peak=%.3f" % [
				month, snap["teams"], snap["factions"], snap["established"], snap["pop"],
				str(snap["intent"]), str(new_delta), snap["mobilize_fraction_peak"]])
		if state.teams.is_empty():
			extinct_tick = tick
			print("[EXTINCT] 全滅於 tick=%d" % tick)
			break

	var end_pop: int = _total_pop(state)
	print("\n───── 終態總結 ─────")
	print("  start_pop=%d end_pop=%d attrition=%.1f%% extinct_tick=%d" % [
		start_pop, end_pop, (0.0 if start_pop == 0 else 100.0 * (start_pop - end_pop) / float(start_pop)), extinct_tick])
	print("  final: teams=%d factions=%d established=%d" % [
		state.teams.size(), state.factions.size(), WarringHarness._established_count(state)])
	print("  final intent histogram: %s" % str(WarringHarness._intent_histogram(state)))
	for k in new_keys:
		print("  %s 累計=%d" % [k, int(Probe.counts.get(k, 0))])
	print("  mobilize.fraction 全程峰值=%.3f" % float(Probe.peaks.get("mobilize.fraction", 0.0)))

	# ★嚴格守恆帳收口:merge erase-evaporation(走Probe.add_amount,獨立累加器)進food_flow同一份、印close-check。
	food_flow["erase_evaporation"] = Probe.amount("food_flow.erase_evaporation")
	var pool_t0: Dictionary = pool_true_t0   # ★真t0(setup後、tick loop前),非pool_curve[0](day1後,已被drain重複計入)
	var pool_tN: Dictionary = pool_curve[-1] if pool_curve.size() > 0 else {}
	var delta_grand: float = float(pool_tN.get("grand", 0.0)) - float(pool_t0.get("grand", 0.0))
	var sum_flow: float = 0.0
	for k in food_flow: sum_flow += food_flow[k]
	print("\n───── 嚴格食物守恆帳 ─────")
	print("  t0 pool: team_food=%.1f granary=%.1f tile_pool=%.1f GRAND=%.1f" % [
		pool_t0.get("team_food", 0.0), pool_t0.get("granary_food", 0.0), pool_t0.get("tile_pool_food", 0.0), pool_t0.get("grand", 0.0)])
	print("  tN pool: team_food=%.1f granary=%.1f tile_pool=%.1f GRAND=%.1f" % [
		pool_tN.get("team_food", 0.0), pool_tN.get("granary_food", 0.0), pool_tN.get("tile_pool_food", 0.0), pool_tN.get("grand", 0.0)])
	print("  ΔGRAND=%.1f  Σfood_flow(全reason加總)=%.1f  close-check diff=%.3f" % [delta_grand, sum_flow, delta_grand - sum_flow])
	print("  food_flow by reason:")
	var flow_keys: Array = food_flow.keys()
	flow_keys.sort_custom(func(a, b): return absf(food_flow[a]) > absf(food_flow[b]))
	for k in flow_keys:
		print("    %s = %.1f" % [k, food_flow[k]])

	var dump: Dictionary = {"seed": WORLD_SEED, "months": months, "curve": curve, "daily_curve": daily_curve,
		"pool_curve": pool_curve, "pool_true_t0": pool_true_t0, "food_flow": food_flow,
		"conservation_close_check": {"delta_grand": delta_grand, "sum_flow": sum_flow, "diff": delta_grand - sum_flow},
		"start_pop": start_pop, "end_pop": end_pop, "extinct_tick": extinct_tick,
		"final": {"teams": state.teams.size(), "factions": state.factions.size(),
			"established": WarringHarness._established_count(state)},
		"final_intent": WarringHarness._intent_histogram(state),
		"new_keys_total": {}, "mobilize_fraction_peak_final": float(Probe.peaks.get("mobilize.fraction", 0.0))}
	for k in new_keys: dump["new_keys_total"][k] = int(Probe.counts.get(k, 0))
	dump["final_leaders"] = _leader_diag(state)
	var spawn_dispatch_breakdown: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("spawn.dispatch_"):
			spawn_dispatch_breakdown[k] = int(Probe.counts[k])
	dump["spawn_dispatch_breakdown"] = spawn_dispatch_breakdown
	print("  spawn.dispatch_* 分布=%s" % str(spawn_dispatch_breakdown))
	dump["join_order_set_samples"] = Probe.samples.get("join.order_set", [])
	dump["join_reached_pair_samples"] = Probe.samples.get("join.reached_pair", [])
	dump["combatopt_fire_samples"] = Probe.samples.get("combatopt.fire_sample", [])
	dump["income_harvest_vault_samples"] = Probe.samples.get("income.harvest_vault", [])
	dump["income_harvest_team_samples"] = Probe.samples.get("income.harvest_team", [])
	dump["income_hunt_samples"] = Probe.samples.get("income.hunt", [])
	dump["gather_factor_trace_samples"] = Probe.samples.get("gather.factor_trace", [])
	dump["erase_food_snapshot_samples"] = Probe.samples.get("erase.food_snapshot", [])
	print("  join.order_set samples=%d join.reached_pair samples=%d" % [
		dump["join_order_set_samples"].size(), dump["join_reached_pair_samples"].size()])
	dump["watchdog_hits"] = watchdog_hits
	dump["encounter_ever_active"] = encounter_ever_active
	var combat_end_breakdown: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("combat.end_"):
			combat_end_breakdown[k] = int(Probe.counts[k])
	dump["combat_end_breakdown"] = combat_end_breakdown
	print("  watchdog_hits=%d encounter_ever_active=%s combat.end_*=%s" % [
		watchdog_hits, str(encounter_ever_active), str(combat_end_breakdown)])
	Probe.enabled = false
	var f := FileAccess.open("res://docs/measurements/2026-08-12-phase3-story-audit-seed%d-%dmo.json" % [WORLD_SEED, months], FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-12-phase3-story-audit-seed%d-%dmo.json" % [WORLD_SEED, months])
	SpecimenDumpHelper.dump(state, "res://docs/measurements/2026-08-12-phase3-story-audit-seed%d-%dmo.specimen.jsonl" % [WORLD_SEED, months])
	print("=== DONE ===")
	quit()

# ★嚴格守恆帳(2026-08-13):四pool逐日分解。Σteam.food(團私產)/Σgranary(全tile public_storage.food,
# 據點糧倉)/Σtile_pool(全tile resources.food,自然regen池,先前total_food從未算過這塊!)/GRAND=三者和。
func _pool_census(state: WorldState, day: int) -> Dictionary:
	var team_food: float = 0.0
	for tid in state.teams:
		team_food += float(state.teams[tid].resources.get("food", 0))
	var granary_food: float = 0.0
	var tile_pool_food: float = 0.0
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		granary_food += float(tile.public_storage.get("food", 0))
		tile_pool_food += float(tile.resources.get("food", 0))
	return {
		"day": day, "team_food": team_food, "granary_food": granary_food,
		"tile_pool_food": tile_pool_food, "grand": team_food + granary_food + tile_pool_food,
	}

func _total_pop(state: WorldState) -> int:
	var total: int = 0
	for tid in state.teams: total += state.teams[tid].population
	return total

# 饑荒genuine-vs-bug診斷:逐日全域census。fragment(parent_team_id!=-1,即scout/convoy/migrant等
# 派出的subteam)vs主隊(parent_team_id==-1)的food_days對照——若fragment系統性比主隊餓得快
# 又持續存在(未merge_back)=支持『碎片不回歸→獨立餓死』假說;若差異不大=偏genuine(全域同樣缺糧)。
func _daily_census(state: WorldState, day: int, starve_delta: int) -> Dictionary:
	var sub_n: int = 0; var sub_food_days_sum: float = 0.0; var sub_pop: int = 0
	var main_n: int = 0; var main_food_days_sum: float = 0.0; var main_pop: int = 0
	var total_food: float = 0.0
	# production funnel①②③(2026-08-13 追加,純讀零新tap)：resident(is_resident_static)vs非resident
	# food_days對照+resident裡真跑TASK_PRODUCE比例。
	var resident_n: int = 0; var resident_pop: int = 0; var resident_food_days_sum: float = 0.0
	var resident_producing_n: int = 0
	var resident_detail: Array = []
	var nonresident_n: int = 0; var nonresident_pop: int = 0; var nonresident_food_days_sum: float = 0.0
	# ★A2 diagnostic-first(2026-08-13):直讀TASK_SETTLE在途團數,拆subteam(dispatch路)vs非subteam(invite路)——
	# 測『邀請流亡抵達空outpost後是否卡在TASK_SETTLE走不出去』假說(純讀零新tap)。
	var settle_inflight_subteam: int = 0; var settle_inflight_nonsubteam: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.current_task == TeamData.TASK_SETTLE:
			if t.parent_team_id != -1: settle_inflight_subteam += 1
			else: settle_inflight_nonsubteam += 1
		var fd: float = ResourceSystem.effective_food(state, t) / maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		total_food += ResourceSystem.effective_food(state, t)
		if t.parent_team_id != -1:
			sub_n += 1; sub_food_days_sum += fd; sub_pop += t.population
		else:
			main_n += 1; main_food_days_sum += fd; main_pop += t.population
		if FactionAISystem.is_resident_static(state, t):
			resident_n += 1; resident_pop += t.population; resident_food_days_sum += fd
			if t.current_task == TeamData.TASK_PRODUCE: resident_producing_n += 1
			# ★證據包A(2026-08-13):逐 resident team 詳細trace(純讀零新tap,呼既有static函式)。
			# ★systems澄清後追加(2026-08-13):糧倉(granary tile public_storage) vs team.resources food拆分——
			# 驗證effective_food()是否已含granary(own_granary_tile同一tile=harvest deposit dst_tile,理論上已含)。
			var _granary: HexTileData = ResourceSystem.own_granary_tile(state, t)
			resident_detail.append({
				"team_id": tid, "day": day, "current_task": t.current_task,
				"has_own_outpost": _granary != null,
				"has_manufacturing_facility": FactionAISystem.has_manufacturing_facility(state, t),
				"has_tag_produce": t.tags.has(TeamData.TAG_PRODUCE),
				"is_subteam": t.parent_team_id != -1, "pop": t.population, "food_days": fd,
				"granary_food": float(_granary.public_storage.get("food", 0)) if _granary != null else -1.0,
				"team_food": float(t.resources.get("food", 0)),
				# ★安家報酬對照面板(2026-08-13):terrain(承載力對照,純讀零新tap)。
				"terrain": String(_granary.terrain) if _granary != null else "",
				"outpost_level": int(_granary.outpost_level) if _granary != null else -1,
				# ★netgain回推假象質疑回應(2026-08-13):famine_days(團級斷糧累積,純讀零新tap)+leader hunger(個人級)。
				"famine_days": t.famine_days,
				"leader_hunger": float(state.persons[t.leader_id].hunger) if t.leader_id != -1 and state.persons.has(t.leader_id) else -1.0,
			})
		else:
			nonresident_n += 1; nonresident_pop += t.population; nonresident_food_days_sum += fd
	return {
		"day": day, "teams": state.teams.size(), "pop": _total_pop(state), "total_food": total_food,
		"starve_anon_delta": starve_delta,
		"subteam_n": sub_n, "subteam_pop": sub_pop,
		"subteam_food_days_avg": (sub_food_days_sum / sub_n) if sub_n > 0 else -1.0,
		"main_n": main_n, "main_pop": main_pop,
		"main_food_days_avg": (main_food_days_sum / main_n) if main_n > 0 else -1.0,
		"resident_n": resident_n, "resident_pop": resident_pop,
		"resident_food_days_avg": (resident_food_days_sum / resident_n) if resident_n > 0 else -1.0,
		"resident_producing_n": resident_producing_n, "resident_detail": resident_detail,
		"settle_inflight_subteam": settle_inflight_subteam, "settle_inflight_nonsubteam": settle_inflight_nonsubteam,
		"nonresident_n": nonresident_n, "nonresident_pop": nonresident_pop,
		"nonresident_food_days_avg": (nonresident_food_days_sum / nonresident_n) if nonresident_n > 0 else -1.0,
		"leaders": _leader_diag(state),
	}

# #3①立國gate(cmd/野心/readiness三連AND，公式抄faction_ai_system.gd:1039-1044原樣，純讀零改) +
# #4 anon_cohorts tier分布。逐 faction leader 每月記一筆。
func _leader_diag(state: WorldState) -> Array:
	var out: Array = []
	for fid in state.factions:
		var f = state.factions[fid]
		var lid: int = int(f.leader_team_id)
		var leader_team: TeamData = state.teams.get(lid)
		if leader_team == null:
			out.append({"faction_id": fid, "leader_team_id": lid, "dead": true})
			continue
		var leader_p = state.persons.get(leader_team.leader_id)
		var cmd: float = float(leader_p.skills.get("統領", 0.0)) if leader_p else 0.0
		var ambition: float = float(leader_p.values.get("野心", 0.5)) if leader_p else 0.5
		var ambition_discount: float = (ambition - 0.5) * 0.2
		var readiness: float = leader_team.readiness
		var member_n: int = f.member_team_ids.size()
		var gate_cmd: bool = cmd >= (FactionAISystem.ESTABLISH_COMMAND - ambition_discount)
		var gate_ambition: bool = ambition >= (FactionAISystem.ESTABLISH_AMBITION - 0.1)
		var gate_readiness: bool = readiness >= FactionAISystem.ESTABLISH_READINESS
		var gate_member: bool = member_n >= 2
		out.append({
			"faction_id": fid, "leader_team_id": lid,
			"cmd": cmd, "ambition": ambition, "readiness": readiness, "member_n": member_n,
			"is_established": f.is_established,
			"goal_founding_pending": f.goals.has("立國"),
			"gate_cmd_pass": gate_cmd, "gate_ambition_pass": gate_ambition,
			"gate_readiness_pass": gate_readiness, "gate_member_pass": gate_member,
			"gate_all_pass": gate_cmd and gate_ambition and gate_readiness and gate_member,
			"anon_cohorts": leader_team.anon_cohorts.duplicate(),
			"pop": leader_team.population, "faction_intent": String(f.intent.get("type", "")) if f.intent is Dictionary else "",
			"faction_intent_target_id": int(f.intent.get("target_id", -1)) if f.intent is Dictionary else -1,
			"food_days": ResourceSystem.effective_food(state, leader_team) / maxf(float(leader_team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001),
			"current_task": leader_team.current_task, "is_subteam": leader_team.parent_team_id != -1,
		})
	return out
