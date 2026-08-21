extends SceneTree
# ★systems票C-3(2026-08-21 estimator-audit)：投靠估的收容機率(join_drive term，只秤host名聲)
# vs 實際被收容率(_absorber_accepts，秤真food)。純觀測，零sim改(interaction_system.gd加join.accept_check
# sample tap另計L3聲明)。env：LW_CONFIG(peaceful_economy)、ADHOC_DAYS(90)、PERF_SEED(1337)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== join-accept 量測：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	var acc: int = int(Probe.counts.get("accept.join_accept", 0))
	var rej: int = int(Probe.counts.get("accept.join_reject", 0))
	var tot: int = acc + rej
	lines.append("★★accept.join_accept=%d｜accept.join_reject=%d｜合計=%d｜實際收容率=%.1f%%" % [
		acc, rej, tot, (100.0 * acc / maxf(tot, 1))])
	lines.append("★join_drive term只讀host_rep(名聲)不讀food——逐筆對照(host_rep vs feed_ok vs accepted)：")
	if Probe.samples.has("join.accept_check"):
		var rep_high_but_rejected: int = 0
		var rep_low_but_accepted: int = 0
		for smp in (Probe.samples["join.accept_check"] as Array):
			lines.append("    %s" % str(smp))
			var accepted: bool = bool(smp.get("accepted", false))
			var rep: float = float(smp.get("host_rep", 0.5))
			var feed: float = float(smp.get("feed_ok", 0.0))
			if rep > 0.6 and not accepted: rep_high_but_rejected += 1
			if rep <= 0.5 and feed >= 0.9 and accepted: rep_low_but_accepted += 1
		lines.append("  ★估錯方向1(高名聲卻被拒,估算器過度樂觀的案例)=%d" % rep_high_but_rejected)
		lines.append("  ★估錯方向2(低/中性名聲但食力夠也是收的,估算器可能低估的案例)=%d" % rep_low_but_accepted)
	else:
		lines.append("    (無sample,本輪join嘗試次數=0或都在threshold之外未觸發)")
	# ★systems票T1(blueprint開)：28次建材dispatch_fail逐次分類短缺資源種類+周邊生產中性trace
	lines.append("★★T1建材depletion逐筆(資源種類/需求/庫存/私產/腳下manufacturing_level)：")
	var mat_tally: Dictionary = {}
	if Probe.samples.has("dispatch_fail.material_detail"):
		for smp2 in (Probe.samples["dispatch_fail.material_detail"] as Array):
			lines.append("    %s" % str(smp2))
			var rk: String = String(smp2.get("resource", "?"))
			mat_tally[rk] = int(mat_tally.get(rk, 0)) + 1
	lines.append("  ★短缺資源種類分佈=%s" % str(mat_tally))
	# ★追查infra.entry=0異常：先確認_evaluate_all_body本身是否有跑
	lines.append("★★追查：_evaluate_all_body本身呼叫次數(判斷faction迴圈整體死活)：")
	lines.append("  evaluate_all_body.entry              = %d" % int(Probe.counts.get("evaluate_all_body.entry", 0)))
	lines.append("  evaluate_all_body.factions_size_sum   = %.0f" % float(Probe.counts.get("evaluate_all_body.factions_size_sum", 0.0)))
	lines.append("  evaluate_all_body.last_tick(最後一次呼叫時的tick) = %s" % str(Probe.peaks.get("evaluate_all_body.last_tick", "無")))
	if Probe.samples.has("evaluate_all_body.tick_sample"):
		lines.append("  前5筆tick樣本：")
		for smp3 in (Probe.samples["evaluate_all_body.tick_sample"] as Array):
			lines.append("    %s" % str(smp3))
	# ★systems票T3：_evaluate_infrastructure entry次數 + 四格停駐分佈(定案，非猜)
	lines.append("★★T3 infra entry四格停駐分佈：")
	var entry: int = int(Probe.counts.get("infra.entry", 0))
	var g: int = int(Probe.counts.get("infra.stop.guard", 0))
	var s1: int = int(Probe.counts.get("infra.stop.1_upgrade", 0))
	var s2: int = int(Probe.counts.get("infra.stop.2_facility", 0))
	var s3e: int = int(Probe.counts.get("infra.stop.3_loc_empty", 0))
	var s3r: int = int(Probe.counts.get("infra.stop.3_reached_dispatch_builder", 0))
	lines.append("  infra.entry(呼叫總次數)                    = %d" % entry)
	lines.append("  infra.stop.guard(guard早退,非決策閘)         = %d" % g)
	lines.append("  infra.stop.1_upgrade(段1升級return)         = %d (%.1f%%)" % [s1, 100.0*s1/maxf(entry-g,1)])
	lines.append("  infra.stop.2_facility(段2擴建return)        = %d (%.1f%%)" % [s2, 100.0*s2/maxf(entry-g,1)])
	lines.append("  infra.stop.3_loc_empty(段3 loc.is_empty return) = %d (%.1f%%)" % [s3e, 100.0*s3e/maxf(entry-g,1)])
	lines.append("  infra.stop.3_reached_dispatch_builder(真呼叫到) = %d (%.1f%%)" % [s3r, 100.0*s3r/maxf(entry-g,1)])
	lines.append("  ★驗算：guard+四格總和(%d) 應等於 entry(%d)" % [g+s1+s2+s3e+s3r, entry])
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	Probe.enabled = false
	print("=== join-accept 量測 DONE ===")
