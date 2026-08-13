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
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = WORLD_SEED
	GameSetup.setup(state, config)

	SpecimenDumpHelper.setup_from_env(state)   # ★別改成手動 specimen_team_ids，見上方危險註記

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
		# production funnel①佔據路徑(camp本輪新加2個temp+既有spawn.dispatch_安頓+settle本輪新加1個temp)。
		"camp.fire", "camp.tile_found", "camp.no_unowned_tile", "settle.convert_to_resident",
		# production funnel④流通率(全既有production trade.market_bail.* tap,零新改)。
		"trade.market_bail.buy_no_stock", "trade.market_bail.buy_no_want", "trade.market_bail.buy_cant_afford",
		"trade.market_bail.buy_carry_full", "trade.market_bail.buy_withdraw_empty",
		"trade.market_bail.sell_no_surplus", "trade.market_bail.sell_ownerless", "trade.market_bail.sell_owner_no_coin",
		"trade.market_bail.sell_no_price", "trade.market_bail.sell_owner_cant_afford", "trade.market_bail.sell_zero_qty",
		"trade.market_bail.sell_storage_full", "trade.peer_deal"]
	var prev_new: Dictionary = {}
	for k in new_keys: prev_new[k] = 0
	var mobilize_peak_prev: float = 0.0

	var curve: Array = []
	var daily_curve: Array = []   # ★饑荒genuine-vs-bug診斷:逐日全域census(fragment vs 主隊food_days對照)+8 leader逐日food/task
	var start_pop: int = _total_pop(state)
	var no_player := Vector2i(-1, -1)
	var extinct_tick: int = -1
	var prev_starve: int = 0

	var watchdog_hits: int = 0
	var encounter_ever_active: bool = false
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
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

	var dump: Dictionary = {"seed": WORLD_SEED, "months": months, "curve": curve, "daily_curve": daily_curve,
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
	var nonresident_n: int = 0; var nonresident_pop: int = 0; var nonresident_food_days_sum: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var fd: float = ResourceSystem.effective_food(state, t) / maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		total_food += ResourceSystem.effective_food(state, t)
		if t.parent_team_id != -1:
			sub_n += 1; sub_food_days_sum += fd; sub_pop += t.population
		else:
			main_n += 1; main_food_days_sum += fd; main_pop += t.population
		if FactionAISystem.is_resident_static(state, t):
			resident_n += 1; resident_pop += t.population; resident_food_days_sum += fd
			if t.current_task == TeamData.TASK_PRODUCE: resident_producing_n += 1
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
		"resident_producing_n": resident_producing_n,
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
