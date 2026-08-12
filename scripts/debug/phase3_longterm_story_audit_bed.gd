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
		# #3② merge 執行 funnel（既有 production tap，非新加，systems 結構列舉的塌點鏈）：
		"merge.pair_seen", "merge.try_entered", "merge.guard_fail_ordertgt",
		"accept.merge_reject", "accept.merge_accept",
		# #3③ migrant/invest 決策層 precondition vs 傳播層 dead-end 三段 funnel（本輪新加 5 個 temp tap，回報後revert）：
		"migrant.reached_eval_entry", "migrant.precond_block_pop", "migrant.util_evaluated",
		"invest.reached_eval_entry", "invest.precond_block_pop", "invest.precond_block_food", "invest.roi_evaluated"]
	var prev_new: Dictionary = {}
	for k in new_keys: prev_new[k] = 0
	var mobilize_peak_prev: float = 0.0

	var curve: Array = []
	var start_pop: int = _total_pop(state)
	var no_player := Vector2i(-1, -1)
	var extinct_tick: int = -1

	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
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

	var dump: Dictionary = {"seed": WORLD_SEED, "months": months, "curve": curve,
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
		})
	return out
