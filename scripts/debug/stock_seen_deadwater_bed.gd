extends SceneTree
# ★接線【前】的死水兩欄（systems 指定 2026-08-26）：`means_end.stock_seen.<res>` 這顆 counter
#   在 code 裡已經存在，但 `docs/measurements/` 全目錄一次都沒出現過 ＝【儀器裝了沒開】。
#   ⇒ 本床只做一件事：把它讀出來，★逐 res 印不印總數
#     （總數非零但集中在 1 個成員，跟 4 個都有，是完全不同的兩件事）。
# 零 production 改、純讀 Probe。env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

const STOCK_MEMBERS: Array = ["ore_iron", "ore_gold", "ore_silver", "gem"]   # ★＝ AcquisitionPaths.SHAPE_TABLE 的 stock 成員（靜態，非 runtime）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== stock_seen 死水兩欄：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("--- ★means_end.stock_seen.<res>（逐成員，★靜態 SHAPE_TABLE 的 4 個 stock 成員）---")
	var total: int = 0
	for res in STOCK_MEMBERS:
		var n: int = int(Probe.counts.get("means_end.stock_seen." + String(res), 0))
		total += n
		lines.append("  %-12s = %d" % [String(res), n])
	# ★其餘出現過的 stock_seen（若有成員不在靜態表 ⇒ 表與世界不一致，也要看得見）
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("means_end.stock_seen."):
			var r: String = ks.substr("means_end.stock_seen.".length())
			if not (r in STOCK_MEMBERS):
				lines.append("  ★表外成員 %-12s = %d（SHAPE_TABLE 沒列它，但世界走到了）" % [r, int(Probe.counts[k])])
	lines.append("  合計 = %d" % total)
	# ★對照欄：means-end 這條路本身有沒有在跑（分母）——沒有它，0 分不出「沒走到這個分支」與「整條 means-end 沒跑」
	lines.append("--- 對照（分母）---")
	for k2 in ["means_end.candidates_emitted", "means_end.no_means", "means_end.cycle_detected"]:
		lines.append("  %-32s = %d" % [k2, int(Probe.counts.get(k2, 0))])
	for k3 in Probe.counts.keys():
		if String(k3).begins_with("means_end.no_means."):
			lines.append("  %-32s = %d" % [String(k3), int(Probe.counts[k3])])
	lines.append("--- 判讀 ---")
	if total == 0:
		lines.append("  ★全 0 ＝ 這張床上【沒有任何隊】為 stock 資源走到定價分支")
		lines.append("     ⇒ 接線會是【活的但沒被走到】＝ 驗收③ 從未被行使（母體塌陷）")
		lines.append("     ⇒ ★照原樣回報，不補床、不改床逼它 fire")
	else:
		lines.append("  ★非零 ＝ 有隊走到過 ⇒ 接線後 candidate 會真的生出來 ⇒ ★fp 必須變")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== stock_seen 死水兩欄 DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
