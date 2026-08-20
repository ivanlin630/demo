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
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
