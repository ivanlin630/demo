extends SceneTree
# ★★★market-known 快取的【stale 稽核】specimen（spec 2026-08-27 驗收 7 ＋ QA 2026-08-27 方法論訂正）。
#
# ★QA 的訂正（我照做）：
#   ①★單一 specimen【證不了】否定命題 ⇒ 只能報「樣本窗內未見不一致 ＋ 窗 = N tick／M 筆」，
#     ★★禁寫「NPC 從不拿過期資訊」。
#   ②★★★specimen 必須帶【NPC 當時用的值 vs 同 tick 真值】的【配對欄位】——
#     單純「牠做了什麼」的 log 天生答不了這題。
#
# ★★真值怎麼來（★不重寫一份比對邏輯）：
#   清掉該隊的快取鍵 → 呼叫【真正的 production 函式】重算 → 拿它當真值。
#   ★★★所以「真值」與「NPC 用的值」是【同一支 code】算出來的，差別只在有沒有吃快取。
#   ★若我自己抄一份掃描邏輯來當真值，抄錯時會得到假的不一致（或假的一致），兩個方向都糟。
#
# ★世界不變：重算只寫 `team_market_known` / `team_market_known_key`（快取本身），不動任何世界事實。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / SPECIMEN_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "10"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("SPECIMEN_OUT",
		"docs/measurements/2026-08-27-market-known-stale.specimen.jsonl")
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
	var fai := FactionAISystem.new()
	# ★★★消費當下比對（第一版在 tick 結束後比存著的值 —— 那把「沒人讀過的舊值」報成不一致）
	FactionAISystem._mk_verify = true
	FactionAISystem._mk_verify_rows = []
	var no_player := Vector2i(-1, -1)
	var rows: Array = []
	var n_pairs: int = 0
	var n_diff: int = 0
	var ticks: int = 0
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		ticks += 1
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	FactionAISystem._mk_verify = false
	var vr: Array = FactionAISystem._mk_verify_rows
	n_pairs = vr.size()
	for r0 in vr:
		if not bool(r0.get("same", true)):
			n_diff += 1
	# ★落地：全部不一致 ＋ 均勻抽樣的一致案例（★讓 QA 兩種都看得到，不是只看紅的）
	var idx: int = 0
	for r1 in vr:
		idx += 1
		if ((not bool(r1.get("same", true))) or idx % 97 == 0) and rows.size() < 400:
			rows.append(JSON.stringify(r1))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		for r in rows:
			f.store_string(String(r) + "\n")
		f.close()
	print("\n[%s seed %d] ★窗 = %d tick｜★★配對筆數 = %d｜★★★不一致 = %d" % [cfg, sd, ticks, n_pairs, n_diff])
	print("★措辭（QA 立的）：本床只能報【樣本窗內未見不一致】——★不是「NPC 從不拿過期資訊」。")
	print("   窗 = %d tick／%d 筆配對；落地 %d 列（全部不一致 ＋ 均勻抽樣的一致案例）→ %s" % [
		ticks, n_pairs, rows.size(), out_path])
	print("=== market_known_stale_specimen DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
