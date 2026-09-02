extends SceneTree
# @observe-pure
# ★★★備戰 root-check（藍圖裁：先於 #10／#5 退化／#12 三票）——★純觀測，fp 必須不變。
#
# ★為什麼先查它：三份【獨立】量測、三個不同的病、【同一個贏家】
#   ①#10 承諾再派：贏家都是備戰　②#5 flee 退化 → 備戰 30 日 2108 次　③#12 乞食 28 次輸給備戰
#   ⇒ ★★若它的 util 被高估，一次解釋三個病。
#
# ★★而藍圖加的對照腿（本床的核心）：三份量測【全來自 warring】——那裡備戰本來就該重要。
#   ★peaceful 也橫掃 ⇒ ★★★強 (b) 證據（util 高估／applicable 太鬆）
#   ★★只在 warring 贏 ⇒ 偏 (a)（它真的該贏）
#   ⇒ ★兩種結果都有用 ⇒ 這一查不會白做。
#
# ★★★母體與命中同印：「備戰贏 0 次」與「沒有隊在候選裡」長得一樣。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 12
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var sd: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	print("=== 備戰 root-check｜config=%s seed=%d days=%d ===" % [cfg, sd, days])
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	seed(sd)
	print("[CONTROL] Probe.enabled=%s（★false ⇒ 下面整張表都是儀器沒開）" % str(Probe.enabled))
	print("★秤的常數（直讀 code，非手抄）：THREAT_BASE_THRESHOLD=%.2f｜REPUTATION_NEUTRAL=%.2f"
		% [ThreatAssessment.THREAT_BASE_THRESHOLD, ThreatAssessment.REPUTATION_NEUTRAL])
	print("★★門檻 = BASE + 慎重×0.3 ⇒ 落在 [%.2f, %.2f]"
		% [ThreatAssessment.THREAT_BASE_THRESHOLD, ThreatAssessment.THREAT_BASE_THRESHOLD + 0.3])
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		print("[CP] day=%d 母體=%d 過門檻=%d 候選中=%d 贏=%d" % [
			d + 1, int(Probe.counts.get("prep.rank_calls", 0)),
			int(Probe.counts.get("prep.gate_pass", 0)),
			int(Probe.counts.get("prep.in_candidates", 0)),
			int(Probe.counts.get("prep.won", 0))])

	var calls: int = int(Probe.counts.get("prep.rank_calls", 0))
	var pass_n: int = int(Probe.counts.get("prep.gate_pass", 0))
	var inc: int = int(Probe.counts.get("prep.in_candidates", 0))
	var won: int = int(Probe.counts.get("prep.won", 0))
	var sn: int = int(Probe.counts.get("threat.score_n", 0))

	print("── ★①threat_react 的逐項組成（★平均值；母體＝score() 被呼叫次數）──")
	print("  score() 呼叫 = %d" % sn)
	if sn > 0:
		print("  approach 平均 = %.4f" % (Probe.amount("threat.comp.approach") / float(sn)))
		print("  hostility 平均 = %.4f（★★底 = 1 − REPUTATION_NEUTRAL = %.2f）"
			% [Probe.amount("threat.comp.hostility") / float(sn), 1.0 - ThreatAssessment.REPUTATION_NEUTRAL])
		print("  power 項 平均 = %.4f（(power_ratio−1)×0.5；★無 belief → 0＝中性）"
			% (Probe.amount("threat.comp.power_term") / float(sn)))
		print("  dist_factor 平均 = %.4f｜★最終分 平均 = %.4f"
			% [Probe.amount("threat.comp.dist_factor") / float(sn),
			   Probe.amount("threat.comp.final") / float(sn)])
	var so_n: int = int(Probe.counts.get("threat.stranger_only_n", 0))
	print("  ★★★【什麼都沒做過的陌生隊】（名聲＝NEUTRAL 且 approach<=0）＝ %d 次（%.1f%%），平均分 = %.4f"
		% [so_n, 100.0 * float(so_n) / maxf(float(sn), 1.0),
		   Probe.amount("threat.stranger_only_score") / maxf(float(so_n), 1.0)])
	print("     ★這一格是【高估】的核心候選：它們的分數完全來自陌生人底分，而不是任何敵意行為。")

	print("── ★★②applicable 命中率（★門檻那一格；母體＝rank 呼叫）──")
	print("  rank 呼叫 = %d｜過門檻 = %d（%.1f%%）｜未過 = %d"
		% [calls, pass_n, 100.0 * float(pass_n) / maxf(float(calls), 1.0),
		   int(Probe.counts.get("prep.gate_fail", 0))])
	if calls > 0:
		print("  平均 threat_react = %.4f｜平均門檻 = %.4f"
			% [Probe.amount("prep.threat_react_sum") / float(calls),
			   Probe.amount("prep.threat_threshold_sum") / float(calls)])

	print("── ★★★③贏率（★母體與命中同印）──")
	print("  在候選 = %d（%.1f%%）｜不在候選 = %d" % [inc,
		100.0 * float(inc) / maxf(float(calls), 1.0), int(Probe.counts.get("prep.not_in_candidates", 0))])
	if inc == 0:
		print("  ★★★在候選 = 0 ⇒ 下面的「贏 0 次」是【母體空】，不是【它不贏】")
	print("  贏 = %d（在候選裡的 %.1f%%）｜輸 = %d"
		% [won, 100.0 * float(won) / maxf(float(inc), 1.0), inc - won])
	if inc > 0:
		print("  平均 util（在候選時）= %.4f" % (Probe.amount("prep.util_sum") / float(inc)))
	var mn: int = int(Probe.counts.get("prep.win_margin_n", 0))
	if mn > 0:
		print("  ★贏的時候平均贏第二名 %.4f（★★贏很多 vs 贏一點點是兩種不同的病）"
			% (Probe.amount("prep.win_margin_sum") / float(mn)))
	var losers: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("prep.lost_to."):
			losers.append("%s=%d" % [String(k).substr(13), int(Probe.counts[k])])
	losers.sort()
	print("  輸給誰：%s" % ("｜".join(PackedStringArray(losers)) if not losers.is_empty() else "（無）"))
	print("★誠實限：①單 seed／%d 日；★★本床【只有一條腿】—— warring 與 peaceful 必須各跑一次再對照，"
		% days)
	print("  ★★★單獨看一邊【證不了任何事】：備戰在 warring 贏本來就可能是對的。")
