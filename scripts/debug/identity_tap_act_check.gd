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
	# ★★★戲服假說的【是非題】(systems 2026-08-26)：同 tick 同 team 的多筆 candidate，
	#   判定用三鍵（target／k_task／k_build_type）是不是【全同】？
	#   ★全同 ⇒ 同一個行動穿多件戲服（坐實）；★★不全同 ⇒ 推翻假說，照原樣報，不美化。
	lines.append("--- ★戲服假說：同 tick 同 team 的多筆，判定三鍵是否全同 ---")
	var grp: Dictionary = {}
	for smp2 in samples:
		var gk: String = "%d|%d" % [int(smp2.get("tick", -1)), int(smp2.get("team", -1))]
		if not grp.has(gk): grp[gk] = []
		(grp[gk] as Array).append(smp2)
	var same_all: int = 0
	var diff_all: int = 0
	var multi_grp: int = 0
	var ex_same: Array = []
	var ex_diff: Array = []
	for gk2 in grp:
		var arr: Array = grp[gk2] as Array
		if arr.size() < 2: continue
		multi_grp += 1
		var k0: String = _kkey(arr[0])
		var all_same: bool = true
		for a in arr:
			if _kkey(a) != k0: all_same = false
		if all_same:
			same_all += 1
			if ex_same.is_empty(): ex_same = arr
		else:
			diff_all += 1
			if ex_diff.is_empty(): ex_diff = arr
	lines.append("  同 tick 同 team 且多筆的組數 = %d ⇒ 三鍵全同 %d 組／不全同 %d 組" % [multi_grp, same_all, diff_all])
	if multi_grp == 0:
		lines.append("  ★★零組 ⇒ 這三個鍵在本輪【回答不了】它們被加進來要回答的問題（照原樣報）")
	if not ex_same.is_empty():
		lines.append("  ★【三鍵全同】實例（原始樣本，未加工）：")
		for e2 in ex_same:
			lines.append("      %s" % str(e2))
	if not ex_diff.is_empty():
		lines.append("  ★★【三鍵不全同】實例 —— ★這一類會【推翻】戲服假說，照原樣列出：")
		for e3 in ex_diff:
			lines.append("      %s" % str(e3))
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


func _kkey(smp) -> String:
	return "%s|%s|%s" % [str(smp.get("target")), String(smp.get("k_task", "")), String(smp.get("k_build_type", ""))]