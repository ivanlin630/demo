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
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	Probe.enabled = false
	print("=== join-accept 量測 DONE ===")
