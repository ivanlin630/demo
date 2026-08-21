extends SceneTree
# 子隊求生尺【前提驗證】床（先驗證再實作）：在途子隊到底有沒有被問求生？階梯有幾階？
# env：PERF_SEED(1337)、ADHOC_DAYS(90)、LW_CONFIG(peaceful_economy)、PERF_OUT
func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 90
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== 子隊求生尺前提驗證：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd); Probe.enabled = true; Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new(); var runner := SimRunner.new()
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
	lines.append("[%s day %d] teams=%d" % [cfg, days, state.teams.size()])
	lines.append("★子隊【有沒有】被問求生：diag.sub_survival_rank = %d" % int(Probe.counts.get("diag.sub_survival_rank", 0)))
	lines.append("★階梯階數分佈（n = 該次 applicable 的 survival 候選數）：")
	var ks: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("diag.sub_ladder_n."): ks.append(String(k))
	ks.sort()
	for k in ks: lines.append("    %-28s = %d" % [k, int(Probe.counts[k])])
	if Probe.samples.has("diag.sub_ladder"):
		lines.append("★樣本（前 10）：")
		for smp in Probe.samples["diag.sub_ladder"].slice(0, 10):
			lines.append("    %s" % str(smp))
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null: f.store_string(text + "\n"); f.close()
	Probe.enabled = false
