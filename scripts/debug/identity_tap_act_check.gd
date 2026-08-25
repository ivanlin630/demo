extends SceneTree
# ★驗那顆 identity tap 的 `act` 欄真的裝到東西（systems 2026-08-26：舊 `task` 欄 114/224 是空字串，
#   而空的那一類正好是【真的要去蓋東西】的那一類）。
#   ★判準：空字串筆數【顯著下降】；★★若仍有空的，把那些的 `to_task` 鍵名原樣印出來——不猜第四個鍵。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== identity tap `act` 欄檢查：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	var samples: Array = Probe.samples.get("means_end.candidate_identity", [])
	lines.append("[%s day %d seed %d] identity 樣本數 = %d（★cap 500；母體 = %d 次 bump）" % [
		cfg, days, sd, samples.size(), int(Probe.counts.get("means_end.unique_no_existing", 0))])
	var blank: int = 0
	var act_hist: Dictionary = {}
	var keys_hist: Dictionary = {}
	for smp in samples:
		var a: String = String(smp.get("act", ""))
		act_hist[a] = int(act_hist.get(a, 0)) + 1
		if a == "":
			blank += 1
			var kk: String = String(smp.get("to_task_keys", "?"))
			keys_hist[kk] = int(keys_hist.get(kk, 0)) + 1
	lines.append("★`act` 空字串 = %d / %d（%.1f%%）★對照：修前是 114/224 ＝ 50.9%%" % [
		blank, samples.size(), 100.0 * blank / maxf(samples.size(), 1)])
	lines.append("★`act` 分佈：")
	for k in act_hist:
		lines.append("    %-24s = %d" % [("（空）" if String(k) == "" else String(k)), int(act_hist[k])])
	if blank > 0:
		lines.append("★★仍為空者的 `to_task` 鍵名（★原樣列出，不猜）：")
		for k2 in keys_hist:
			lines.append("    %-40s = %d" % [String(k2), int(keys_hist[k2])])
	else:
		lines.append("★零空字串 ⇒ 三分量身分完整（fname / target / act）")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== identity tap `act` 欄檢查 DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
