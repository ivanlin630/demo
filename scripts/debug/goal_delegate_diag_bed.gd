extends SceneTree
# 第二半診斷床：★`_dispatch_goal_delegate` 之後為什麼不再產生 build 委派。
# ★只報分佈，不開藥（systems 指定）。三層分開，因為「0」在每一層的意思都不同：
#   ①上游有沒有【產生】build 候選     goal.cand_build_emitted
#   ②候選有沒有【贏 argmax 走到委派】 delegate.entry / delegate.branch.*
#   ③走到了有沒有【派成功】           delegate.build_ok / build_fail + dispatch_fail.*
# env：LW_CONFIG(peaceful_economy)、ADHOC_DAYS(90)、PERF_SEED(1337)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	_dump(cfg, days, sd, state, out_path)
	Probe.enabled = false
	print("=== goal-delegate diag DONE ===")

func _dump(cfg: String, days: int, sd: int, state: WorldState, out_path: String) -> void:
	var lines: Array = []
	lines.append("[%s day %d/%d seed %d] teams=%d   ★窗尾標記（讀之前先確認這行）" % [cfg, days, days, sd, state.teams.size()])
	lines.append("--- ①上游：有沒有【產生】build 委派候選 ---")
	lines.append("  goal.cand_build_emitted = %d" % _c("goal.cand_build_emitted"))
	if Probe.samples.has("goal.cand_build_emitted"):
		var arr: Array = Probe.samples["goal.cand_build_emitted"] as Array
		lines.append("  ★樣本是 first-N（不是均勻取樣）—— 只能看【最早那批】，不能拿來推分佈")
		for e in arr.slice(0, 12):
			lines.append("    " + JSON.stringify(e))
	else:
		lines.append("  （★一筆都沒有 ⇒ 上游【從未產生】build 候選 —— 那 dispatch 端的 0 就不是 dispatch 的問題）")
	for km in ["goal.frontier_calls", "goal.frontier_empty", "goal.cand_total_batches"]:
		lines.append("  %-32s = %d" % [km, _c(km)])
	lines.append("  ★逐日分佈（這才能回答「是不是只在早期」，樣本不行）：")
	var days_hit: Array = []
	for kd in Probe.counts.keys():
		if String(kd).begins_with("goal.cand_build_day."):
			days_hit.append("day%s=%d" % [String(kd).substr(20), _c(String(kd))])
	days_hit.sort()
	lines.append("    " + (str(days_hit) if not days_hit.is_empty() else "（無）"))
	lines.append("  ★按資源分：哪些真的產出了候選 / 哪些地形本來就不產（B 型）")
	var em: Array = []
	var nb: Array = []
	for ke in Probe.counts.keys():
		var kes: String = String(ke)
		if kes.begins_with("goal.harvest.emitted."):
			em.append("%s=%d" % [kes.substr(21), _c(kes)])
		elif kes.begins_with("goal.harvest.not_terrain_produced."):
			nb.append("%s=%d" % [kes.substr(33), _c(kes)])
	em.sort(); nb.sort()
	lines.append("    ★產出候選的（A 修後應該多出 food）：" + str(em))
	lines.append("    地形不產（B 型，本票不處理）：" + str(nb))
	lines.append("  ★更上游：資源前置的出口表（採@地形只是取得手段 2）")
	for kr in ["goal.res_prereq.entry", "goal.res_prereq.satisfied", "goal.res_prereq.no_specie",
			"goal.res_prereq.buy_wins", "goal.res_prereq.no_market"]:
		lines.append("    %-38s = %d" % [kr, _c(kr)])
	lines.append("  ★落到【取得手段 2】時缺的是哪種資源（分類維度）")
	var fall: Array = []
	var nonh: Array = []
	for kf in Probe.counts.keys():
		var kfs: String = String(kf)
		if kfs.begins_with("goal.res_fall."):
			fall.append("%s=%d" % [kfs.substr(14), _c(kfs)])
		elif kfs.begins_with("goal.res_nonharvest."):
			nonh.append("%s=%d" % [kfs.substr(20), _c(kfs)])
	fall.sort(); nonh.sort()
	lines.append("    落下來的：" + str(fall))
	lines.append("    其中【不可採】：" + str(nonh))
	lines.append("  ★build 候選的【真正產地】：採@地形分支的三個出口（意思完全不同）")
	for kh in ["goal.harvest.emitted", "goal.harvest.satisfied_own_terrain",
			"goal.harvest.no_reachable_site", "goal.deleg.pop_gate_block"]:
		lines.append("    %-38s = %d" % [kh, _c(kh)])
	lines.append("--- ②委派入口：有沒有【贏】並走到委派 ---")
	for k in ["delegate.entry", "delegate.branch.convoy", "delegate.branch.build",
			"delegate.branch.facility", "delegate.branch.generic", "delegate.generic_no_advisor"]:
		lines.append("  %-32s = %d" % [k, _c(k)])
	if Probe.samples.has("delegate.entry"):
		for e2 in (Probe.samples["delegate.entry"] as Array).slice(0, 12):
			lines.append("    " + JSON.stringify(e2))
	lines.append("--- ③派遣結果：走到了有沒有派成功 ---")
	for k2 in ["delegate.build_ok", "delegate.build_fail"]:
		lines.append("  %-32s = %d" % [k2, _c(k2)])
	for k3 in Probe.counts.keys():
		if String(k3).begins_with("dispatch_fail."):
			lines.append("  %-32s = %d" % [String(k3), _c(String(k3))])
	lines.append("--- ★對照：紮根有沒有真的完成 ---")
	for k4 in ["outpost.l0_to_l1", "construct.start", "construct.complete"]:
		lines.append("  %-32s = %d" % [k4, _c(k4)])
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
