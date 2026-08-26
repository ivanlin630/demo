extends SceneTree
# ★市場撮合的【誰先誰後】dump（systems 派 2026-08-27 / slice perf-stagger-fairness）。
#   ★命題：「先被評估的一方是否較常勝出」⇒ ★★只記「誰參與」算不出勝率，
#     每筆必須帶【該 tick 內第幾個碰到這個 order_id】。
#   ★★★母體＝撮合被走到的總次數（mkfill.attempt.*）——★沒有它，「碰撞 12 次」分不出
#     是「很少發生」還是「幾乎每次」。
# ★本床只落地原始列與分桶，★★不判「先來的有沒有系統性優勢」——那是 measurer 的統計。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "10"))
	var sd: int = int(_env("PERF_SEED", "1337"))
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
	var att_b: int = int(Probe.counts.get("mkfill.attempt.buy", 0))
	var att_s: int = int(Probe.counts.get("mkfill.attempt.sell", 0))
	var arr: Array = (Probe.samples["mkfill.order"] as Array) if Probe.samples.has("mkfill.order") else []
	lines.append("[%s seed %d days %d]" % [cfg, sd, days])
	lines.append("★★母體：撮合被走到 %d 次（buy %d ＋ sell %d）｜★成交樣本 %d 筆（cap 20000）%s" % [
		att_b + att_s, att_b, att_s, arr.size(),
		"★★樣本已達 cap ⇒ 以下是下界" if arr.size() >= 20000 else ""])
	if att_b + att_s == 0:
		lines.append("★零撮合 —— ★★而「0」＋「一個聽起來合理的原因」是最危險的組合：")
		lines.append("   ★先確認 class 快取是新的（--import）再解讀，不要先找世界層的解釋。")
		_out(lines); return
	if arr.is_empty():
		lines.append("★有撮合但零成交樣本 ⇒ 每次都在成交前 bail —— ★★把原因印出來，「0」才不是一句空話：")
		var bl: Array = []
		for k0 in Probe.counts:
			var ks0: String = String(k0)
			if ks0.begins_with("trade.market_bail."):
				bl.append("      %-40s = %d" % [ks0.substr(18), int(Probe.counts[k0])])
		bl.sort()
		for b0 in bl:
			lines.append(String(b0))
		lines.append("   ★★★而 tap 本身是接上的（陽性對照：Probe.enabled=false 時 key 不存在、開了就有 %d 次）" % (att_b + att_s))
		lines.append("   ⇒ ★這張床上【市場撮合幾乎不發生】⇒ ★★「誰先誰後」在這裡答不了，要換一張真的有撮合的床。")
		_out(lines); return
	# ★同 tick 同 order_id 的碰撞：seq >= 2 就是有人搶在前面
	var by_seq: Dictionary = {}
	var collide_rows: Array = []
	var oid_tick: Dictionary = {}
	for s in arr:
		var sq: int = int(s.get("seq", 0))
		by_seq[sq] = int(by_seq.get(sq, 0)) + 1
		var k: String = "%d|%d" % [int(s.get("tick", -1)), int(s.get("order_id", -1))]
		var lst: Array = oid_tick.get(k, [])
		lst.append(s)
		oid_tick[k] = lst
	for k2 in oid_tick:
		if (oid_tick[k2] as Array).size() >= 2:
			collide_rows.append(k2)
	lines.append("")
	lines.append("★成交筆數依【同 tick 同 order_id 的第幾個】分桶：")
	var sk: Array = by_seq.keys(); sk.sort()
	for s2 in sk:
		lines.append("   seq %-3d = %d 筆" % [int(s2), int(by_seq[s2])])
	lines.append("★★同 tick 同 order_id 被 2 隊以上碰到的組數 = %d（★碰撞＝有先後可比的樣本）" % collide_rows.size())
	lines.append("")
	lines.append("★★★逐筆原始列（給 measurer 算勝率；★本床不判有沒有系統性優勢）：")
	var shown: int = 0
	for k3 in collide_rows:
		if shown >= 40: break
		shown += 1
		for s3 in (oid_tick[k3] as Array):
			lines.append("   tick %-6d order %-6d seq %-3d team %-4d qty %-5d %s" % [
				int(s3.get("tick", -1)), int(s3.get("order_id", -1)), int(s3.get("seq", 0)),
				int(s3.get("team", -1)), int(s3.get("qty", 0)), String(s3.get("kind", ""))])
	if collide_rows.size() > 40:
		lines.append("   （只印前 40 組碰撞；★母體見上，★★不是「只有這麼多」）")
	_out(lines)

func _out(lines: Array) -> void:
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	var out_path: String = OS.get_environment("PERF_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== market_fill_order_dump DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
