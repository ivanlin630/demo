extends SceneTree
# @bed-kind: diagnostic
# slice: DIAG 票 §4 第 0 步 —— ★量 `intel_arrived` 裡的【威脅佔比 f】
#
# ★★★我【不定義威脅】：定義是 systems 的欄。本床印【定義無關的交叉表】，
#   f ＝ systems 挑哪些格子加總 ÷ 全部。★若我自己先挑一組，f 就變成我選的數字。
# ★★感知鐵律（票 §3）：分類只讀【觀察者自己的】信念與位置 ——
#   判準句「如果這隊其實被騙了，這個分類會不會跟著錯？」⇒ **會**（它讀的是 belief，不是真值）。
#   ★而既有的 `ThreatAssessment.score()` 吃 `other: TeamData` ＝ god-view ⇒ 本 tap 沒有用它。
# ★★★母體對齊：emit 只在 `fields.has("tile_pos")` 且（首見 or 位置變）時發生
#   ⇒ **5386 次全部是位置情報** ⇒ 威脅不可能用「欄位型別」切，只能用距離／敵意切。
#
# env：IW_DAYS（預設 12）／IW_SEED（預設 1337）／IW_CONFIG（預設 warring_states）

func _initialize() -> void:
	var days: int = int(OS.get_environment("IW_DAYS")) if OS.has_environment("IW_DAYS") else 12
	var sd: int = int(OS.get_environment("IW_SEED")) if OS.has_environment("IW_SEED") else 1337
	var cfg: String = OS.get_environment("IW_CONFIG") if OS.has_environment("IW_CONFIG") else "warring_states"
	print("=== intel_arrived 的威脅佔比 f（days=%d seed=%d config=%s）===" % [days, sd, cfg])
	var fail: int = 0
	var cells: int = 0

	seed(sd)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))

	var all: int = int(Probe.counts.get("intelwake.f.all", 0))
	var emit_all: int = int(Probe.counts.get("t0.emit.intel_arrived", 0))
	print("\n[IW] ★母體：tap 記到 %d 次｜既有 `t0.emit.intel_arrived` ＝ %d 次" % [all, emit_all])
	print("[IW]   ★★兩個數字必須相等（同一個 emit 點）：tap=%d vs emit=%d ⇒ %s" % [all, emit_all, ("一致 ✔" if all == emit_all else "★不一致 ✘")])
	if all != emit_all:
		push_error("[IW][FAIL] tap 母體 %d ≠ emit 母體 %d ⇒ 我的 tap 與 emit 不是同一個母體" % [all, emit_all])
		fail += 1
	if all == 0:
		push_error("[IW][不可判] 母體 0 ⇒ tap 沒接上（不是世界沒有情報）")
		quit(2)
		return
	cells += 1

	_axis("距離帶（觀察者自己的位置 vs 剛學到的目標位置）", "intelwake.f.dist.",
		["d0", "d1", "d2_3", "d4_6", "d7p"], all)
	_axis("敵意（觀察者的 known_reputations，★belief 非真值）", "intelwake.f.rep.",
		["hostile", "nonhostile"], all)
	_axis("種類", "intelwake.f.kind.", ["first_seen", "moved"], all)
	cells += 1

	print("\n[IW] ★★★交叉表（敵意 × 距離）—— ★f 由 systems 挑格子加總，我不挑")
	print("[IW] %-12s %10s %10s %10s %10s %10s %10s" % ["敵意", "d0", "d1", "d2_3", "d4_6", "d7p", "小計"])
	for h in ["hostile", "nonhostile"]:
		var row: String = ""
		var sub: int = 0
		for d in ["d0", "d1", "d2_3", "d4_6", "d7p"]:
			var v: int = int(Probe.counts.get("intelwake.f.x." + h + "." + d, 0))
			sub += v
			row += "%10d " % v
		print("[IW] %-12s %s%10d" % [h, row, sub])
	cells += 1

	# ★把「f 若這樣定」的幾個候選值一次印出來 —— ★★它們是【候選】不是【我的選擇】
	var hostile_all: int = int(Probe.counts.get("intelwake.f.rep.hostile", 0))
	var near3: int = 0
	var host_near3: int = 0
	for d2 in ["d0", "d1", "d2_3"]:
		near3 += int(Probe.counts.get("intelwake.f.dist." + d2, 0))
		host_near3 += int(Probe.counts.get("intelwake.f.x.hostile." + d2, 0))
	# ★★★權威版 f（systems 裁）：用【既有的尺】`ThreatAssessment.score >= THREAT_BASE_THRESHOLD`
	#   ⇒ 零新常數,且門檻的血統寫在 threat_assessment.gd:6-20 的註解裡。
	var ta_t: int = int(Probe.counts.get("intelwake.f.ta.threat", 0))
	var ta_n: int = int(Probe.counts.get("intelwake.f.ta.nonthreat", 0))
	var ta_x: int = int(Probe.counts.get("intelwake.f.ta.no_target", 0))
	print("\n[IW] ★★★權威 f（ThreatAssessment 的既有尺,零新常數）")
	print("[IW]   門檻 THREAT_BASE_THRESHOLD = %.4f（＝ 0.3 ／ 實測膨脹係數 %.2f,血統見 threat_assessment.gd:6-20）" % [
		ThreatAssessment.THREAT_BASE_THRESHOLD, ThreatAssessment.THREAT_INFLATION_MEASURED])
	print("[IW]   威脅 %d ／ 非威脅 %d ／ 目標已不存在 %d ｜小計 %d（母體 %d）" % [
		ta_t, ta_n, ta_x, ta_t + ta_n + ta_x, all])
	if ta_t + ta_n + ta_x != all:
		push_error("[IW][FAIL] 權威 f 的小計 %d ≠ 母體 %d ⇒ 有 emit 沒被分類" % [ta_t + ta_n + ta_x, all])
		fail += 1
	print("[IW]   ★★★f = %.4f（%d／%d）⇒ 票 §4 門檻 0.6 ⇒ %s" % [
		float(ta_t) / float(maxi(all, 1)), ta_t, all,
		"★超過 ⇒ 回報不做" if float(ta_t) / float(maxi(all, 1)) > 0.6 else "未超過 ⇒ 票買得到"])

	print("\n[IW] ★候選 f（★★三個都印，★★★systems 挑哪一個是 systems 的事）：")
	print("[IW]   f(敵意)            = %.4f（%d／%d）" % [float(hostile_all) / float(all), hostile_all, all])
	print("[IW]   f(距離≤3)          = %.4f（%d／%d）" % [float(near3) / float(all), near3, all])
	print("[IW]   f(敵意 且 距離≤3)  = %.4f（%d／%d）" % [float(host_near3) / float(all), host_near3, all])
	print("[IW]   ★票 §4 的門檻：**f > 0.6 ⇒ 回報不做**（而哪個 f 才算數，是定義問題不是量測問題）")
	cells += 1

	# ── ★★★逐消費者的 woke 份額（systems addendum）──
	#   ★K 清單【現場從 Probe.counts 掃】,不抄 `s4b_wake_coverage.gd` 的 `SUPPORTS`：
	#     那是一份【手抄的 9 條】,而我裸掃到的生產端消費點是 **11 個**
	#     ⇒ ★★那份清單就是「第五條被漏掉」的機制本身 —— 清單保證會漏,而漏掉時它是綠的。
	#   ★★本輪我補了兩支進帳：`SOLO`（占 pass 時間 34.7% 卻不在帳上）與 `REEVAL`
	#     （`_should_reeval` 本來只有【無後綴】的 `reeval.event`）。
	var ks: Dictionary = {}
	for key3 in Probe.counts.keys():
		var s6: String = String(key3)
		for pre in ["reeval.event.", "reeval.both.", "reeval.cadence."]:
			if not s6.begins_with(pre): continue
			var kk2: String = s6.substr(pre.length())
			if not ks.has(kk2): ks[kk2] = {"event": 0, "both": 0, "cadence": 0}
			ks[kk2][pre.substr(7, pre.length() - 8)] = int(Probe.counts[key3])
	var kl: Array = ks.keys()
	var ev_tot: int = 0
	for k7 in ks: ev_tot += int(ks[k7]["event"]) + int(ks[k7]["both"])
	# ★攤平成單一鍵再排（GDScript lambda 不吃跨行運算式——同一個坑今天第二次）
	var kw: Dictionary = {}
	for k9 in ks: kw[k9] = int(ks[k9]["event"]) + int(ks[k9]["both"])
	kl.sort_custom(func(a7, b7): return int(kw[a7]) > int(kw[b7]))
	print("\n[IW] ★★★逐消費者 woke 份額（K 清單現場掃,不抄手抄清單 ⇒ %d 支）" % kl.size())
	print("[IW] %-16s %10s %10s %10s %12s %10s" % ["消費者 K", "event", "both", "cadence", "woke(e+b)", "份額"])
	for k8 in kl:
		var e8: int = int(ks[k8]["event"])
		var b8: int = int(ks[k8]["both"])
		print("[IW] %-16s %10d %10d %10d %12d %9.2f%%" % [String(k8), e8, b8,
			int(ks[k8]["cadence"]), e8 + b8, 100.0 * float(e8 + b8) / float(maxi(ev_tot, 1))])
	print("[IW]   ★合計 woke = %d｜★★舊的【無後綴】`reeval.event` = %d（不同母體,不可相加）" % [
		ev_tot, int(Probe.counts.get("reeval.event", 0))])
	if kl.is_empty():
		push_error("[IW][不可判] 一支 K 都沒掃到 ⇒ DecisionTier.tap_wake 沒接上")
		fail += 1
	cells += 1

	# ── ★★★方向守衛（systems 裁）：`wake=false ⟺ 非威脅` ──
	#   ★它擋的是【比較方向被反轉】(`>=` 改 `<`)：那種改動**仍然是變數、仍然由門檻導出**
	#     ⇒ B6 的文字檢查過得去,而語意整個反過來。
	#   ★★它問的是【語意】不是【文字】⇒ 改寫成 `not (x < T)` 仍然綠。
	#   ★★★而它只需要【一棵樹、一個短窗】⇒ 可以當 merge-gate（B1 不行）。
	var _tw: int = int(Probe.counts.get("intelwake.pair.T.wake", 0))
	var _tn: int = int(Probe.counts.get("intelwake.pair.T.nowake", 0))
	var _nw: int = int(Probe.counts.get("intelwake.pair.N.wake", 0))
	var _nn: int = int(Probe.counts.get("intelwake.pair.N.nowake", 0))
	print("\n[IW] ★★★方向守衛：威脅×喚醒 = %d｜威脅×不喚醒 = %d｜非威脅×喚醒 = %d｜非威脅×不喚醒 = %d" % [
		_tw, _tn, _nw, _nn])
	if _tw + _tn + _nw + _nn == 0:
		push_error("[IW][不可判] 方向守衛母體 0 ⇒ tap 沒接上（不是沒有情報）")
		fail += 1
	elif _tn != 0 or _nw != 0:
		push_error("[IW][FAIL] 方向守衛破：威脅×不喚醒=%d、非威脅×喚醒=%d（兩者都必須是 0）⇒ ★比較方向反了" % [_tn, _nw])
		fail += 1
	else:
		print("[IW]   ⇒ ✔ 威脅×不喚醒=%d 且 非威脅×喚醒=%d（母體 %d）⇒ wake=false ⟺ 非威脅" % [
			_tn, _nw, _tw + _tn + _nw + _nn])
	cells += 1

	print("\n[誠實限] ①本床不判威脅,只給維度；★定義換一個,f 就換一個")
	print("[誠實限] ②距離用【觀察者剛學到的位置】算 ⇒ 若情報是舊的/被扭曲的,這裡也跟著錯（★那是對的）")
	print("[誠實限] ③母體＝emit 次數,不是【被喚醒的隊數】（一次 emit 只一個 subject,但隊可能已在 pending）")
	print("=== intel_wake_threat_share DONE（fail=%d｜到場點名 %d／6）===" % [fail, cells])
	if cells != 6:
		push_error("[FAIL] 到場點名 %d／6 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _axis(title: String, prefix: String, keys: Array, total: int) -> void:
	print("\n[IW] %s" % title)
	var sum: int = 0
	for k in keys:
		var v: int = int(Probe.counts.get(prefix + String(k), 0))
		sum += v
		print("[IW]   %-12s %10d  %6.2f%%" % [String(k), v, 100.0 * float(v) / float(maxi(total, 1))])
	print("[IW]   %-12s %10d  ← ★軸小計必須等於母體 %d ⇒ %s" % [
		"小計", sum, total, "✔" if sum == total else "★✘（有值落在我列的格子之外）"])
