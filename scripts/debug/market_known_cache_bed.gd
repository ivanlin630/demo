extends SceneTree
# ★market-known 快取命中率（spec 2026-08-27 驗收 3）。
#   ★分母＝【真呼叫】次數（mk.cache_hit + mk.cache_miss），★不是隊數／tick 數。
#   ★★兩條路徑【分開報】：rank_scored（94.3% 那條）與 rank_survival（沒驗過的那條）
#     —— 它們共用同一支 `_harvest_market_known`，正確性沒有商量餘地，而命中率可能不同。
# ★★★驗收 5 的形狀：不要求 fp 不變、不要求命中率最大化 ——
#   只要求【每一次差異都能對應到清單上的一個具體事件源】。★它懲罰的是【沉默】不是【變動】。
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
	SimRunner.phase_timing = true
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	# ★★★相位必須【逐 tick 累加】：`FactionAISystem.evaluate_all` 開頭會 `_fai_ph.clear()`
	#   ⇒ 跑完後直接讀 `_fai_ph` 只看得到【最後一次】的殘留。
	#   ★我第一版就是這樣，印出「gather 佔 0.0%」—— ★★而那不是量測結果，是【讀錯位置】。
	var ph_sum: Dictionary = {}
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		for pk3 in FactionAISystem._fai_ph:
			ph_sum[pk3] = int(ph_sum.get(pk3, 0)) + int(FactionAISystem._fai_ph[pk3])
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break

	# ★★兩條路徑分開報（counter 帶路徑後綴）
	var by_path: Dictionary = {}
	var hit: int = 0
	var miss: int = 0
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("mk.cache_hit."):
			var pth: String = ks.substr(13)
			var e: Array = by_path.get(pth, [0, 0]); e[0] += int(Probe.counts[k]); by_path[pth] = e
			hit += int(Probe.counts[k])
		elif ks.begins_with("mk.cache_miss."):
			var pth2: String = ks.substr(14)
			var e2: Array = by_path.get(pth2, [0, 0]); e2[1] += int(Probe.counts[k]); by_path[pth2] = e2
			miss += int(Probe.counts[k])
	var tot: int = hit + miss
	var lines: Array = []
	lines.append("[%s seed %d days %d]" % [cfg, sd, days])
	lines.append("★分母＝真呼叫次數 = %d（hit %d + miss %d）★不是隊數／tick 數" % [tot, hit, miss])
	if tot == 0:
		lines.append("★零呼叫 —— 分不出「沒發生」與「tap 沒接上」；★Probe.enabled 本床已開，所以是前者。")
		_out(lines); return
	lines.append("★★命中率 = %.1f%%（%d / %d）" % [100.0 * hit / tot, hit, tot])
	lines.append("")
	lines.append("★★★兩條路徑分開報（★分辨點在【上游呼叫堆疊】不在 helper：`DecisionContext.gather` 兩條都走，")
	lines.append("   ⇒ 在 helper 加參數答不了這題；改在兩個 rank 入口設純觀測標記）：")
	var pk: Array = by_path.keys(); pk.sort()
	for p2 in pk:
		var e3: Array = by_path[p2]
		var t3: int = int(e3[0]) + int(e3[1])
		lines.append("   %-14s hit %6d｜miss %6d｜合計 %6d｜命中率 %.1f%%" % [
			String(p2), int(e3[0]), int(e3[1]), t3, 100.0 * float(e3[0]) / maxf(float(t3), 1.0)])
	if not by_path.has("rank_survival"):
		lines.append("   ★★rank_survival 一次都沒出現 —— ★分不出「那條路沒被走過」還是「標記沒設到」，")
		lines.append("      而 `_evaluate_survival` 每 tick 每隊都會被呼叫 ⇒ 若這裡是空的，先查標記。")
	lines.append("")
	lines.append("★gather.* 佔相位合計：%s" % _phase_share(ph_sum, "gather"))
	lines.append("")
	lines.append("★★★而【gather.* 不是這顆快取該影響的相位】—— 這是查出來的，不是猜的：")
	lines.append("   `decision_context.gd:453/458`（在 gather.market 裡）兩處都傳 `skip_refresh = true`")
	lines.append("   ⇒ ★它們【根本不呼叫】`_harvest_market_known`。")
	lines.append("   真正的 refresh 在 `_merchant_trade_target` / `options.gd` / `goal_resolver.gd` ——")
	lines.append("   ⇒ ★★省下來的時間落在 `unified.rank`，不在 `gather.*`。")
	lines.append("★unified.rank 佔相位合計：%s" % _phase_share(ph_sum, "unified.rank"))
	_out(lines)

func _phase_share(ph: Dictionary, prefix: String) -> String:
	var g: int = 0
	var all: int = 0
	for k in ph:
		var v: int = int(ph[k])
		all += v
		if String(k).begins_with(prefix): g += v
	if all <= 0:
		return "（phase_timing 無資料）"
	return "%.1f%%（%s %d μs / 全相位合計 %d μs）★這是相位佔比，不是 wall-clock 加速宣稱" % [
		100.0 * g / all, prefix, g, all]

func _out(lines: Array) -> void:
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	var out_path: String = OS.get_environment("PERF_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== market_known_cache_bed DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
