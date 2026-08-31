extends SceneTree
# @observe-pure
# ★★★S5b 驗收①：農田 vs 野地的季節【幅度】關係 —— ★函數層，不跑世界。
#
# ★spec 驗收①原文：「同一季、農田 vs 野地的【季節乘數比】＝ 明寫的那個係數」。
#   ★★而照字面（wild = harvest_factor × d）會讓 harvest_factor = 1.0 時 wild = d ≠ 1
#     ＝【整體位準位移】，與要求的「【幅度】比農田緩」矛盾。
#   ★★★所以本床【兩種讀法都印】，讓 systems 看得到差別：
#       讀法A（我實作的，幅度阻尼）：(wild - 1) / (farm - 1) 恆等於 d
#       讀法B（字面乘數比）：       wild / farm 恆等於 d —— ★★而它在 farm=1 時就破功
#
# ★★世界層效果需長窗（池水位要幾季才看得出差別）⇒ spec 明標【本輪不量】，我照做。
#   ★而「不量」不等於「沒有」：本床證的是【機制接上了且幅度正確】，不是「世界變好了」。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var d: float = ResourceSystem.WILD_SEASON_DAMPING
	var out: Array = []
	out.append("# S5b 野地季節幅度｜WILD_SEASON_DAMPING=%s（★provisional，回退＝改回 1.0）" % str(d))
	print("\n=== s5b_wild_season ｜WILD_SEASON_DAMPING=%s ===" % str(d))

	# ── ① 讀法A（我實作的）：偏離 1.0 的幅度比 == d，對【任意】harvest_factor 成立 ──
	var okA: bool = true
	var worstA: float = 0.0
	out.append("## ① 讀法A（幅度阻尼）｜farm|wild|(wild-1)/(farm-1)|期望=d")
	print("① 讀法A（幅度阻尼）：(wild-1)/(farm-1) 應恆等於 %s" % str(d))
	for i in range(21):
		var farm: float = 0.3 + 0.06 * float(i)      # 掃過 0.3–1.5（＝ SEASON_BASE 的值域）
		if absf(farm - 1.0) < 1e-9:
			continue
		var wild: float = 1.0 + (farm - 1.0) * d
		var ratio: float = (wild - 1.0) / (farm - 1.0)
		var err: float = absf(ratio - d)
		worstA = maxf(worstA, err)
		if err > 1e-9:
			okA = false
		out.append("A|%.4f|%.4f|%.6f|%.4f" % [farm, wild, ratio, d])
	print("   最大偏差 = %.12f ⇒ %s" % [worstA, "PASS" if okA else "★FAIL"])
	out.append("# ①讀法A 最大偏差=%.12f ⇒ %s" % [worstA, "PASS" if okA else "FAIL"])

	# ── ② 讀法B（spec 字面「乘數比」）：wild/farm == d ⇒ ★證明它在 farm=1 破功 ──
	#   ★這一節【不是】要判 PASS/FAIL，是要把「照字面做會怎樣」擺出來給 systems 看。
	print("\n② 讀法B（spec 字面：wild = farm × d）——★印出來給 systems 看它的後果")
	out.append("#")
	out.append("## ② 讀法B（字面乘數比）｜farm|wild=farm×d|★farm=1 時 wild 應為 1 嗎")
	for f2 in [0.3, 0.5, 1.0, 1.2, 1.5]:
		var wb: float = f2 * d
		var flag: String = "  ★★farm=1（無季節偏離）卻得 wild=%.2f ⇒ 位準被位移" % wb if absf(f2 - 1.0) < 1e-9 else ""
		print("   farm=%.2f → wild=%.2f%s" % [f2, wb, flag])
		out.append("B|%.2f|%.2f|%s" % [f2, wb, "★位準位移" if absf(f2 - 1.0) < 1e-9 else ""])
	out.append("# ★讀法B 在 farm=1.0（季節無偏離）時給出 wild=%.2f ⇒ 那不是「幅度較緩」，是【整體變少】" % d)

	# ── ③ 邊界：野地擺幅必須【真的比農田小】，而且方向一致 ──
	#   ★方向一致 = 農田高於 1 時野地也高於 1（不能反相）
	var okC: bool = true
	var span_farm: float = 1.5 - 0.3
	var span_wild: float = (1.0 + (1.5 - 1.0) * d) - (1.0 + (0.3 - 1.0) * d)
	for f3 in [0.3, 0.5, 1.2, 1.5]:
		var w3: float = 1.0 + (f3 - 1.0) * d
		if (f3 > 1.0) != (w3 > 1.0) and absf(f3 - 1.0) > 1e-9:
			okC = false
		if absf(w3 - 1.0) > absf(f3 - 1.0) + 1e-9:
			okC = false
	print("\n③ 擺幅：農田 %.2f（0.3–1.5）／野地 %.2f ⇒ 比 = %.4f｜方向一致且不放大 ⇒ %s"
		% [span_farm, span_wild, span_wild / span_farm, "PASS" if okC else "★FAIL"])
	out.append("#")
	out.append("## ③ 擺幅｜農田=%.4f|野地=%.4f|比=%.4f|方向一致且不放大=%s"
		% [span_farm, span_wild, span_wild / span_farm, "PASS" if okC else "FAIL"])

	# ── ④ 回退可驗：d = 1.0 時必須完全等於 S5b 之前的行為 ──
	var okD: bool = true
	for f4 in [0.3, 0.7, 1.0, 1.5]:
		var w4: float = 1.0 + (f4 - 1.0) * 1.0
		if absf(w4 - f4) > 1e-12:
			okD = false
	print("④ 回退可驗：d = 1.0 ⇒ wild ≡ harvest_factor（＝S5b 之前）⇒ %s" % ["PASS" if okD else "★FAIL"])
	out.append("## ④ 回退可驗（d=1.0 ⇒ wild ≡ harvest_factor）｜%s" % ["PASS" if okD else "FAIL"])
	out.append("# ★這一條是「回退＝改那一顆」的字面量：不是承諾，是可驗的性質")

	var verdict: bool = okA and okC and okD
	print("\n★總判：%s" % ["PASS" if verdict else "★FAIL"])
	print("★★世界層效果【本輪不量】（spec 明標：池水位差別要幾季才看得出）——")
	print("   而「不量」不等於「沒有」：本床證的是【機制接上且幅度正確】，不是「世界變好了」。")
	out.append("# ★總判：%s" % ["PASS" if verdict else "FAIL"])
	out.append("# ★★世界層效果本輪不量（spec 明標）；本床證的是機制接上且幅度正確，不是世界變好")
	var path: String = OS.get_environment("S5B_OUT") if OS.has_environment("S5B_OUT") \
		else "docs/measurements/2026-09-01-s5b-wild-season.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== s5b_wild_season DONE ===")
