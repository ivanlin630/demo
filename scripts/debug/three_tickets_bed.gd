extends SceneTree
# @observe-pure
# ★★★三票解凍 re-measure（systems 2026-09-03）——★三票【同一輪、同一份跑】。
#   理由（systems）：三者的共同變數就是【備戰】⇒ ★★分開跑會讓「誰變了」變成猜。
#
# ★三票與各自母體（★systems 逐票指定，我不自己挑）：
#   #10 承諾再派：母體＝`current_task == IDLE` 且 `survival_committed_option != ""` 的隊 × tick
#   #5  flee 退化：母體＝【怕過門檻但無 believed 目的地】的隊 × tick
#   #12 乞食    ：★兩條 rank 路【分開報】（統一 rank ／ 絕境階梯）
#
# ★★母體與命中同印 —— ★★★「贏 0 次」與「沒有隊在候選」長得一樣。
# ★而第一問是【贏家贏得對不對】，不是【怎麼讓輸家贏】⇒ 本床只 dump，禁 crank。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var sd: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	print("=== 三票 re-measure｜config=%s seed=%d days=%d ===" % [cfg, sd, days])
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	seed(sd)
	print("[CONTROL] %s" % MeasureBedHelper.arm_order_report())
	print("[CONTROL] Probe.enabled=%s（★false ⇒ 下面整份都是儀器沒開）" % str(Probe.enabled))
	print("★換尺後的常數（直讀）：THREAT_BASE=%.4f｜CAUTION_SPAN=%.4f｜INFLATION=%.2f"
		% [ThreatAssessment.THREAT_BASE_THRESHOLD, ThreatAssessment.THREAT_CAUTION_SPAN,
		   ThreatAssessment.THREAT_INFLATION_MEASURED])
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		print("[CP] day=%d ｜#10 送回=%d 贏=%d ｜#5 退化=%d ｜#12 全pool候選=%d 贏=%d ｜備戰贏=%d" % [
			d + 1,
			int(Probe.counts.get("redispatch.candidate_sent", 0)), int(Probe.counts.get("redispatch.won", 0)),
			int(Probe.counts.get("flee.degrade.total", 0)),
			int(Probe.counts.get("begu.in_candidates", 0)), int(Probe.counts.get("begu.won", 0)),
			int(Probe.counts.get("prep.won", 0))])

	_sec_10()
	_sec_5()
	_sec_12()
	_sec_prepare()
	print("★誠實限：①單 config／單 seed／%d 日 ②★純觀測（fp 不該變；變了＝我動到行為）" % days)
	print("  ★★③三票【同一份跑】⇒ 彼此可比；★★★但與修前的舊值比時，那些舊值是【不同跑】的，")
	print("     而中間隔了換尺 —— 所以「修前 vs 修後」看的是【方向與量級】，不是逐位元對照。")

func _bucket_list(pfx: String) -> String:
	var out: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with(pfx):
			out.append("%s=%d" % [String(k).substr(pfx.length()), int(Probe.counts[k])])
	out.sort()
	return "｜".join(PackedStringArray(out)) if not out.is_empty() else "（空）"

func _sec_10() -> void:
	var sent: int = int(Probe.counts.get("redispatch.candidate_sent", 0))
	var nir: int = int(Probe.counts.get("redispatch.not_in_ranked", 0))
	var won: int = int(Probe.counts.get("redispatch.won", 0))
	var lost: int = int(Probe.counts.get("redispatch.lost", 0))
	print("═══ #10 承諾再派 ═══")
	print("  母體（IDLE 且 survival_committed_option != \"\"）= %d" % sent)
	if sent == 0:
		print("  ★★★母體 = 0 ⇒ 下面全是 0，而那【不是】「再派不管用」——是【沒有隊落進這個狀態】")
	print("  不在候選集 = %d（%.1f%%）｜贏 = %d｜輸 = %d" % [nir,
		100.0 * float(nir) / maxf(float(sent), 1.0), won, lost])
	print("  輸給誰：%s" % _bucket_list("redispatch.lost_to."))
	print("  ★舊值（30 日）：sent=3 not_in_ranked=0 won=0 lost=3 ⇒ ★★病是【總是輸】不是【送不回】")

func _sec_5() -> void:
	var tot: int = int(Probe.counts.get("flee.degrade.total", 0))
	print("═══ #5 flee 退化去向 ═══")
	print("  母體（怕過門檻但無 believed 目的地）= %d" % tot)
	if tot == 0:
		print("  ★★★母體 = 0 ⇒ 沒有隊落進退化路（不是「退化路壞了」）")
	print("  去向：%s" % _bucket_list("flee.degrade.top_"))
	print("  ★舊值（30 日）：total=2108，備戰 1569（74%%）⇒ ★★問的是【修後還是不是備戰一面倒】")
	print("  （參考）band（有座標未過門檻無目的地）=%d｜怕過門檻無目的地=%d" % [
		int(Probe.counts.get("flee.band_no_dest_below_threshold", 0)),
		int(Probe.counts.get("flee.no_dest_above_threshold", 0))])

func _sec_12() -> void:
	for pair in [["begu.", "統一 rank（rank_scored）"], ["beg.", "絕境階梯（rank_survival）"]]:
		var pfx: String = pair[0]
		var calls: int = int(Probe.counts.get(pfx + "rank_calls", 0))
		var inc: int = int(Probe.counts.get(pfx + "in_candidates", 0))
		var won: int = int(Probe.counts.get(pfx + "won", 0))
		print("═══ #12 乞食｜%s ═══" % pair[1])
		print("  母體（該路呼叫）= %d" % calls)
		print("  在候選 = %d（%.1f%%）｜不在候選 = %d" % [inc,
			100.0 * float(inc) / maxf(float(calls), 1.0),
			int(Probe.counts.get(pfx + "not_in_candidates", 0))])
		print("    擋住它的閘：食物門檻=%d｜沒有援助對象=%d" % [
			int(Probe.counts.get(pfx + "gate.blocked_by_food_threshold", 0)),
			int(Probe.counts.get(pfx + "gate.blocked_by_no_aid", 0))])
		if inc == 0:
			print("  ★★★在候選 = 0 ⇒ 「贏 0」是【母體空】不是【它不贏】")
		print("  贏 = %d｜輸 = %d｜輸給誰：%s" % [won, inc - won, _bucket_list(pfx + "lost_to.")])
		if inc > 0:
			print("  平均 util：乞食 %.3f ／ 贏家 %.3f" % [
				Probe.amount(pfx + "util_sum") / float(inc),
				Probe.amount(pfx + "winner_util_sum") / float(inc)])
	_sec_bands("begu.", "統一 rank")
	_sec_bands("beg.", "絕境階梯")
	print("  ★舊值（30 日，統一 rank）：候選 90、贏 6、食物門檻擋 4341、沒援助 178、輸給備戰 28")

func _sec_prepare() -> void:
	var calls: int = int(Probe.counts.get("prep.rank_calls", 0))
	var inc: int = int(Probe.counts.get("prep.in_candidates", 0))
	var won: int = int(Probe.counts.get("prep.won", 0))
	print("═══ ★共同變數：備戰 ═══")
	print("  母體（rank 呼叫）= %d｜過門檻 = %d（%.1f%%）" % [calls,
		int(Probe.counts.get("prep.gate_pass", 0)),
		100.0 * float(Probe.counts.get("prep.gate_pass", 0)) / maxf(float(calls), 1.0)])
	print("  在候選 = %d｜贏 = %d（母體的 %.1f%%、候選的 %.1f%%）" % [inc, won,
		100.0 * float(won) / maxf(float(calls), 1.0),
		100.0 * float(won) / maxf(float(inc), 1.0)])
	if calls > 0:
		print("  平均 threat_react = %.4f｜平均門檻 = %.4f" % [
			Probe.amount("prep.threat_react_sum") / float(calls),
			Probe.amount("prep.threat_threshold_sum") / float(calls)])
	print("  ★舊值（12 日 warring，換尺【前】）：過門檻 82.5%%、贏/母體 37.7%%")
	print("  ★★★三票的「輸給備戰」要跟這一格對讀 —— 備戰贏得多【本身不是病】，")
	print("     ★而它若在【和平世界也一面倒】才是 util 高估的證據（那條腿另跑）")

# ★★★按餓深分帶（blueprint 定刀型）—— ★判準寫死：
#   【最深帶（food_days → 0）且施主可及】時，乞食贏不贏。
#   ★★贏 ⇒ 引擎沒問題，低 util 是【對的】（它只在該乞食時才該贏）
#   ★★★不贏 ⇒ 那才是病，而【那時才談要不要動它的 util】。
# ★而【施主可及率】是「贏得 genuine」的另一半：
#   ★★若最深帶的可及率也很低 ⇒ 「乞食不贏」不是決策病，是【世界裡沒有施主】。
func _sec_bands(pfx: String, title: String) -> void:
	print("═══ #12 按餓深分帶｜%s ═══" % title)
	print("  帶界（印出來不手抄）：food_days ≥ 5 ／ 2–5 ／ 0.5–2 ／ ★< 0.5（最深帶）")
	print("  帶｜母體｜施主可及｜applicable｜贏｜輸｜乞食 util｜贏家 util｜差距｜輸給誰")
	for b in ["ge5", "2to5", "0.5to2", "deep"]:
		var k: String = pfx + "band." + b + "."
		var pop: int = int(Probe.counts.get(k + "pop", 0))
		var don: int = int(Probe.counts.get(k + "donor_ok", 0))
		var app: int = int(Probe.counts.get(k + "applicable", 0))
		var won: int = int(Probe.counts.get(k + "won", 0))
		var lost: int = int(Probe.counts.get(k + "lost", 0))
		var bu: float = Probe.amount(k + "util_sum") / maxf(float(app), 1.0)
		var wu: float = Probe.amount(k + "winner_util_sum") / maxf(float(app), 1.0)
		var los: Array = []
		for kk in Probe.counts.keys():
			if String(kk).begins_with(k + "lost_to."):
				los.append("%s=%d" % [String(kk).substr((k + "lost_to.").length()), int(Probe.counts[kk])])
		los.sort()
		print("  %-7s|%6d|%5d(%4.1f%%)|%5d|%4d|%4d|%7.3f|%7.3f|%7.3f| %s" % [b, pop, don,
			100.0 * float(don) / maxf(float(pop), 1.0), app, won, lost, bu, wu, wu - bu,
			"｜".join(PackedStringArray(los)) if not los.is_empty() else "-"])
		if pop == 0:
			print("        ★母體 0 ⇒ 這一帶【沒有隊落進來】，不是【乞食在這帶不贏】")
		elif app == 0:
			print("        ★★有隊但乞食【連候選都不是】⇒ 看施主可及率：低 ⇒ 世界沒施主；高 ⇒ 食物門檻擋的")
	print("  ★★★判準：看【deep】那一列 —— 施主可及而乞食不贏，才是病；")
	print("     ★施主可及率低 ⇒ 那是【世界太薄】，修法在關係密度不在秤。")
