extends SceneTree
# gate5/6 量測床：★症狀（order.abandoned）與抑制量（failure.suppressed.*）【同一份報告並排】。
# 理由（spec §2b + R² 加固）：折價會降低嘗試頻率，頻率下降本身就會把症狀數字沖淡——
# 只看 order.abandoned 變少會把「大家都放棄了」誤讀成「病治好了」。
# env：LW_CONFIG（peaceful_economy）、ADHOC_DAYS(30)、PERF_SEED(1337)、PERF_OUT(sidecar)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg_name: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 30
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== failure-feedback measure：config=%s days=%d seed=%d ===" % [cfg_name, days, seed_v])

	seed(seed_v)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = seed_v
	GameSetup.setup(state, config)

	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % (WorldState.TICKS_PER_DAY * 10) == 0:
			_report(cfg_name, state, int((tick + 1) / WorldState.TICKS_PER_DAY), out_path)
		if state.teams.is_empty(): break
	_report(cfg_name, state, days, out_path)
	Probe.enabled = false
	print("=== measure DONE ===")

func _report(cfg: String, state: WorldState, day: int, out_path: String) -> void:
	var lines: Array = []
	lines.append("[%s day %d] teams=%d" % [cfg, day, state.teams.size()])
	lines.append("--- 症狀（別單看這欄）---")
	for k in ["order.placed", "order.filled", "order.abandoned", "order.replaced"]:
		lines.append("  %-30s = %d" % [k, int(Probe.counts.get(k, 0))])
	lines.append("--- ★抑制量（並排看：症狀降但這裡飆＝大家都放棄了，不是病好了）---")
	var any_sup: bool = false
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("failure."):
			lines.append("  %-30s = %d" % [ks, int(Probe.counts[k])])
			if ks.begins_with("failure.suppressed"): any_sup = true
	if not any_sup:
		lines.append("  （無 failure.suppressed.* ＝ 折價從未生效）")
	if Probe.peaks.has("failure.suppressed_depth"):
		lines.append("  最深折價 = %.3f（1.0 − 乘數）" % float(Probe.peaks["failure.suppressed_depth"]))
	lines.append("--- 被折價的那兩個 option 的行為 ---")
	for k in ["decision.opt_chosen.買糧", "decision.opt_chosen.買料",
			"decision.opt_applicable.買糧", "decision.opt_applicable.買料"]:
		lines.append("  %-30s = %d" % [k, int(Probe.counts.get(k, 0))])
	# ★★磚的三面 acceptance（systems 裁：閘綠 ≠ 這一版達標）。
	#   ★每一面都要能區分【沒達標】與【沒進料】——那是兩種完全不同的結果，
	#   混在一起報就是把「量不到」當成「沒發生」。
	lines.append("--- ★★三面 acceptance ---")
	var root_done: int = int(Probe.counts.get("outpost.l0_to_l1", 0))
	lines.append("  ①文明化恢復 outpost.l0_to_l1 = %d" % root_done)
	lines.append("     ★這一面【要同床 main baseline 才可判】：絕對值不告訴你有沒有恢復。")
	var bite: int = int(Probe.counts.get("failure.suppressed.買糧", 0))
	lines.append("  ②買糧 339 型仍咬 failure.suppressed.買糧 = %d" % bite)
	if bite == 0:
		lines.append("     ⚠ 0 ＝ 折價對買糧【從未生效】——不是「不咬了」，是【沒發生】，兩者不可互換。")
	var rec_root: int = 0
	var rec_keys: Array = []
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("failure.recorded."):
			rec_keys.append("%s=%d" % [ks.substr(17), int(Probe.counts[k])])
			if ks.find("root") >= 0 or ks.find("紮根") >= 0 or ks.find("construction") >= 0:
				rec_root += int(Probe.counts[k])
	lines.append("  ③紮根執行型失敗進記憶 = %d　(全部 recorded 分佈: %s)" % [rec_root, str(rec_keys)])
	if rec_root == 0:
		lines.append("     ⚠ 0 有兩種可能，★這份報告分不出來，要看 ③b：")
		lines.append("       (a) 接線斷（記錄側沒接到擲出點） (b) 這輪世界【真的沒有】紮根執行型失敗")
	lines.append("  ③b 前提型 failure.blocked_total = %d　(★>0 表示紮根【有在嘗試】只是被擋)" % int(Probe.counts.get("failure.blocked_total", 0)))
	for k2 in Probe.counts.keys():
		if String(k2).begins_with("failure.blocked."):
			lines.append("       %-34s = %d" % [String(k2), int(Probe.counts[k2])])
	lines.append("  ③c ★這支函式【有沒有被呼叫】—— 沒有這欄，③b 的 0 分不出「接線斷」與「根本沒走到」")
	for k3 in ["dispatch.builder_entry", "dispatch.builder_skip_busy"]:
		lines.append("       %-34s = %d" % [k3, int(Probe.counts.get(k3, 0))])
	for k4 in Probe.counts.keys():
		if String(k4).begins_with("dispatch_fail."):
			lines.append("       %-34s = %d" % [String(k4), int(Probe.counts[k4])])
	lines.append("       %-34s = %d" % ["failure.blocked_no_identity", int(Probe.counts.get("failure.blocked_no_identity", 0))])
	lines.append("         ★>0 ＝ 走到了記錄站但【身分是空的】⇒ 接線斷（不是世界沒發生）")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
