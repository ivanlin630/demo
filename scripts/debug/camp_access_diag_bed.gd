extends SceneTree
# 接入 arc §3 三分流診斷床（★診斷先行、只產分流證據）。
# 報：零採集總數（母/子）、三分流計數、★逐隊歸格（不得只給總數）、camp.applicable_but_idle、
#     pop=1 村數、紮營/L0→L1/L0 廢棄 相關 tap（供後續 gate3 對照）。
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== camp-access 三分流診斷：config=%s days=%d seed=%d ===" % [cfg, days, sd])
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
	lines.append("--- 零採集（病） ---")
	for k in ["collect.no_outpost_no_camp_zero_food", "collect.no_outpost_no_camp_zero_food.parent",
			"collect.no_outpost_no_camp_zero_food.subteam", "collect.l0_forage_ran"]:
		lines.append("  %-46s = %d" % [k, int(Probe.counts.get(k, 0))])
	# ★三分流的 tap 是 temp（逐 cadence 掃可耕地太貴），證據已入 handback；此處保留欄位讓重跑時看得出「已撤」。
	lines.append("--- 三分流（temp tap 已撤；證據見 2026-08-21 交件） ---")
	var tot: int = 0
	for k in ["camp.diag.i_above_desperation", "camp.diag.ii_no_farmable",
			"camp.diag.iii_applicable_but_not_chosen", "camp.diag.has_outpost_already"]:
		var v: int = int(Probe.counts.get(k, 0)); tot += v
		lines.append("  %-46s = %d" % [k, v])
	for k in ["camp.applicable_but_idle"]:
		lines.append("  %-46s = %d" % [k, int(Probe.counts.get(k, 0))])
	lines.append("--- ★逐隊歸格（不得只給總數） ---")
	var per: Dictionary = {}
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("camp.diag.team"):
			var rest: String = ks.substr("camp.diag.team".length())
			var parts: PackedStringArray = rest.split(".")
			if parts.size() == 2:
				var tid: String = parts[0]
				var d: Dictionary = per.get(tid, {})
				d[parts[1]] = int(Probe.counts[k])
				per[tid] = d
	var tids: Array = per.keys(); tids.sort()
	for tid in tids:
		lines.append("    team=%s %s" % [tid, str(per[tid])])
	lines.append("--- ★分流(iii) 輸給誰 ---")
	var lost: Array = []
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("camp.lost_to."):
			lost.append("  %-46s = %d" % [ks, int(Probe.counts[k])])
	lost.sort()
	for l in lost: lines.append(l)
	lines.append("  %-46s = %d" % ["camp.won_argmax", int(Probe.counts.get("camp.won_argmax", 0))])
	lines.append("--- ★紮根 funnel（驗收#1 的解釋層）---")
	lines.append("  %-46s = %d" % ["root.won_argmax", int(Probe.counts.get("root.won_argmax", 0))])
	var rl: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("root.lost_to."): rl.append("  %-46s = %d" % [String(k), int(Probe.counts[k])])
	rl.sort()
	for l in rl: lines.append(l)
	if rl.is_empty() and int(Probe.counts.get("root.won_argmax", 0)) == 0:
		lines.append("  ★紮根從未進入候選（applicable 都沒過）")
	if Probe.samples.has("camp.lost"):
		for smp in Probe.samples["camp.lost"].slice(0, 10):
			lines.append("    [camp.lost] %s" % str(smp))
	if Probe.samples.has("camp.drive_parts"):
		lines.append("--- ★camp_drive 零件（分流 iii 第三層） ---")
		for smp in Probe.samples["camp.drive_parts"].slice(0, 10):
			lines.append("    %s" % str(smp))
	for k in Probe.counts.keys():
		var kr: String = String(k)
		if kr.begins_with("root.commit_drop.") or kr.begins_with("settlement.l0_to_l1") or kr.begins_with("construct.complete"):
			lines.append("  %-46s = %d" % [kr, int(Probe.counts[k])])
	lines.append("--- 世界狀態（gate1/6 用） ---")
	var pop1: int = 0
	var pop_total: int = 0
	for t2 in state.teams:
		var t: TeamData = state.teams[t2]
		if t.beast_kind != "" or t.parent_team_id != -1: continue
		pop_total += t.population
		if t.population <= 1: pop1 += 1
	lines.append("  pop=1 村數 = %d｜母隊人口合計 = %d" % [pop1, pop_total])
	for k in ["breed.born", "camp.built", "outpost.l0_to_l1", "camp.abandoned"]:
		if Probe.counts.has(k): lines.append("  %-46s = %d" % [k, int(Probe.counts[k])])
	if Probe.samples.has("camp.diag"):
		lines.append("--- 樣本（前 12） ---")
		for smp in Probe.samples["camp.diag"].slice(0, 12):
			lines.append("    %s" % str(smp))
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	Probe.enabled = false
