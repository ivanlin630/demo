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
	# ★等價證明用（預設關）：CAMP_SHADOW=1 才開，★開了每次 own_camp 查詢都會多掃一次全圖
	OwnerCampIndex.shadow = OS.get_environment("CAMP_SHADOW") == "1"
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
	_sec_aid()
	_sec_aid_bands()
	_sec_zhagen()
	_sec_churn()
	_sec_abs_hunger()
	_sec_b_grade()
	_sec_cansettle()
	_sec_ladder()
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
	print("  ★★★不在候選集的【是哪個 option】：%s" % _bucket_list("redispatch.not_in_ranked.opt."))
	print("  ★★★不在候選集的隊【當下有沒有自己的營地】：%s" % _bucket_list("redispatch.nir_owncamp."))
	print("     ★判讀（systems 寫在數字之前）：幾乎都 yes ⇒ 承諾比 applicable 活得久（假說成立）；")
	print("        ★★幾乎都 no ⇒ 假說死，那是另一回事；★★★混合 ⇒ 原樣報不歸類")
	print("    其中 stall cooldown 排除=%d｜條件本身不成立=%d（★兩者在「不在候選集」上同形）" % [
		int(Probe.counts.get("redispatch.nir_stall_cooldown", 0)),
		int(Probe.counts.get("redispatch.nir_not_applicable", 0))])
	print("    ★注：【條件名】這一步我做不到 —— `applicable` 是閉包，不會告訴你它為何回 false；")
	print("      ★★知道是哪個 option 之後，才能在那一個的 applicable 裡接條件級 tap。")
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

# ★★★施主可及性：逐道濾網的拒絕次數（systems 2026-09-03）
#   ★「沒人可乞」有五種意思，而它們在回值 -1 上完全同形。
func _sec_aid() -> void:
	var calls: int = int(Probe.counts.get("aid.calls", 0))
	print("═══ ★施主可及性：_find_aid_target 五道濾網 ═══")
	print("  呼叫次數（母體）= %d" % calls)
	if calls == 0:
		print("  ★★★母體 0 ⇒ 這支函式沒被呼叫過（儀器沒跑到），不是「沒施主」")
		return
	print("  平均掃到的 discovered 隊數 = %.2f" % (Probe.amount("aid.discovered_sum") / float(calls)))
	print("  ①母體空（沒發現過任何隊）      = %d" % int(Probe.counts.get("aid.reject.1_no_discovered", 0)))
	print("  ②沒 belief                     = %d" % int(Probe.counts.get("aid.reject.2_no_belief", 0)))
	print("  ③★有 belief 但沒 food_est      = %d   ← systems 最懷疑的那一道" % int(Probe.counts.get("aid.reject.3_no_food_est", 0)))
	print("  ④有糧但不夠分               = %d" % int(Probe.counts.get("aid.reject.4_not_enough", 0)))
	print("  ⑤夠分但到不了               = %d" % int(Probe.counts.get("aid.reject.5_unreachable", 0)))
	print("  ★找到施主 = %d｜找不到 = %d" % [
		int(Probe.counts.get("aid.found", 0)), int(Probe.counts.get("aid.none", 0))])
	var n2: int = 0
	var n3: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with("aid.pass2.tgt."): n2 += 1
		elif String(k).begins_with("aid.pass3.tgt."): n3 += 1
	print("  ── ★★★可證偽那一格（【集合大小】不是【次數】）──")
	print("     ②has_belief 通過的相異 target 數 = %d" % n2)
	print("     ③food_est 通過的相異 target 數 = %d" % n3)
	print("     ★判讀（先寫死，免得數字回來才挑解釋）：")
	print("       ③ ≪ ② 且③小到個位數  ⇒ ★支持假說（認得一堆人、只知道少數幾個的存糧）")
	print("       ③ ≈ ②                ⇒ ★★假說死 ⇒ 擋人的是④⑤，別再往資訊層修")
	print("       ② 本身 ≈ 0        ⇒ ★★★兩個假說都不成立，真根在更上游（根本沒發現別人）")
	print("  ★★讀法：③占大多數 ⇒ 【資訊門檻】（要互動過才知道對方存糧）；")
	print("     ★★★①占大多數 ⇒ 世界太薄；⑤占大多數 ⇒ 地理；④ ⇒ 真的沒人有餘糧。")

# ★★★band × filter 交叉：整體找得到施主、而最深帶找不到 —— 兩個數字都對，
#   ★而「是哪一道擋住最餓的那群」只有交叉答得出來。
#   ★★每列附【相異 target 集合大小】—— ★★★上一輪就是它跟次數說相反的話。
func _sec_aid_bands() -> void:
	print("═══ ★band × filter 交叉 ═══")
	print("  帶｜呼叫｜①母體空｜②無belief｜③無food_est｜④不夠分｜⑤到不了｜找到｜②集合｜③集合")
	for b in ["ge5", "2to5", "0.5to2", "deep"]:
		var k: String = "aid.b." + b + "."
		var n2: int = 0
		var n3: int = 0
		for kk in Probe.counts.keys():
			if String(kk).begins_with(k + "pass2.tgt."): n2 += 1
			elif String(kk).begins_with(k + "pass3.tgt."): n3 += 1
		var calls: int = int(Probe.counts.get(k + "calls", 0))
		print("  %-7s|%7d|%6d|%6d|%8d|%7d|%7d|%6d|%5d|%5d" % [b, calls,
			int(Probe.counts.get(k + "reject.1_no_discovered", 0)),
			int(Probe.counts.get(k + "reject.2_no_belief", 0)),
			int(Probe.counts.get(k + "reject.3_no_food_est", 0)),
			int(Probe.counts.get(k + "reject.4_not_enough", 0)),
			int(Probe.counts.get(k + "reject.5_unreachable", 0)),
			int(Probe.counts.get(k + "found", 0)), n2, n3])
		if calls == 0:
			print("        ★呼叫 0 ⇒ 這一帶沒有隊去找過施主（不是「找不到」）")
	print("  ★★★判讀（上一封先寫死的）：深帶④主導⇒真的沒餘糧（分配／產量）；")
	print("     ⑤主導⇒走不到（可及性）；③主導⇒資訊門檻只咬最餓的（★仍要看集合不看次數）；")
	print("     ①主導⇒真根在 discovery，不在乞食這條路。")

# ★★★紮根條件級：`can_settle_here or settle_resume_site != (-1,-1)`（互斥且窮盡）
func _sec_zhagen() -> void:
	var m: int = int(Probe.counts.get("zhagen.mother", 0))
	print("═══ ★【紮根】applicable 條件級 ═══")
	print("  母體（IDLE 且 committed==紮根）= %d" % m)
	if m == 0:
		print("  ★★★母體 0 ⇒ 這個窗裡沒有隊落進來（儀器沒跑到／母體塌陷），不是「條件都成立」")
		return
	print("  can_settle_here 為 false = %d（%.1f%%）" % [
		int(Probe.counts.get("zhagen.false.can_settle_here", 0)),
		100.0 * float(Probe.counts.get("zhagen.false.can_settle_here", 0)) / float(m)])
	print("  settle_resume_site 為空 = %d（%.1f%%）" % [
		int(Probe.counts.get("zhagen.false.no_resume_site", 0)),
		100.0 * float(Probe.counts.get("zhagen.false.no_resume_site", 0)) / float(m)])
	print("  ★兩者皆 false（即 not applicable）= %d｜applicable = %d" % [
		int(Probe.counts.get("zhagen.not_applicable", 0)), int(Probe.counts.get("zhagen.applicable", 0))])
	print("  ★★★applicable 的那幾次，紮根贏了嗎：贏=%d｜輸=%d" % [
		int(Probe.counts.get("zhagen.appl_won", 0)), int(Probe.counts.get("zhagen.appl_lost", 0))])
	print("     輸給誰：%s" % _bucket_list("zhagen.appl_lost_to."))
	# ★★★own-camp（2026-09-03）：applicable 從兩支變三支 ⇒ 第三支也要印，否則這一節讀起來像少一半。
	print("  第三支 no_own_camp（沒有自己的營地）為 false = %d" % int(Probe.counts.get("zhagen.false.no_own_camp", 0)))
	# ★★★22 敗的 per-option util（blueprint 加派 2026-09-03）：★第一問是【輸得對不對】不是【為什麼輸】。
	#   ★★資料來源是既有的 `zhagen.lost_table`（own-camp 那一刀就在記了）——★★★不新建格式，只是先前沒人印它。
	#   ★差距分桶沿用既有那套：<0.1／0.1-0.5／0.5-1／1-2／≥2。
	var zlt: Array = Probe.samples.get("zhagen.lost_table", [])
	print("  ── ★紮根 applicable 卻輸掉：per-option util（樣本 %d／cap 200）──" % zlt.size())
	if zlt.is_empty():
		print("     （空）★★空有兩種讀法：真的沒有輸掉的次數／★★★樣本沒被寫進來——對照上面 appl_lost 的數字")
	else:
		var gb: Dictionary = {"<0.1": 0, "0.1-0.5": 0, "0.5-1": 0, "1-2": 0, ">=2": 0}
		for e in zlt:
			var tbl: Array = e.get("table", [])
			var wu: float = 0.0
			var zu: float = 0.0
			var wname: String = String(e.get("winner", "?"))
			for r in tbl:
				if String(r["opt"]) == wname: wu = float(r["u"])
				if String(r["opt"]) == "紮根": zu = float(r["u"])
			var gap: float = wu - zu
			if gap < 0.1: gb["<0.1"] += 1
			elif gap < 0.5: gb["0.1-0.5"] += 1
			elif gap < 1.0: gb["0.5-1"] += 1
			elif gap < 2.0: gb["1-2"] += 1
			else: gb[">=2"] += 1
		var gk: Array = ["<0.1", "0.1-0.5", "0.5-1", "1-2", ">=2"]
		var gs: Array = []
		for k in gk: gs.append("%s=%d" % [k, int(gb[k])])
		print("     ★差距（贏家 − 紮根）分桶：%s" % " ".join(PackedStringArray(gs)))
		print("     ★★逐筆（最多 8 筆）：")
		for i in range(mini(8, zlt.size())):
			var e2: Dictionary = zlt[i]
			var t2: Array = e2.get("table", [])
			var top: Array = []
			for j in range(mini(5, t2.size())):
				top.append("%s=%.4f" % [String(t2[j]["opt"]), float(t2[j]["u"])])
			print("        tick=%s team=%s 經[%s]支 贏家=%s｜%s" % [
				str(e2.get("tick", -1)), str(e2.get("team", -1)), String(e2.get("branch", "?")),
				String(e2.get("winner", "?")), " ".join(PackedStringArray(top))])
		print("     ★★★判讀（systems 寫在數字之前）：贏家高且差距大 ⇒【輸得對】；")
		print("        ★<0.1 佔多數 ⇒ 勢均力敵的【邊緣輸】，與「完全不是對手」意思完全不同；")
		print("        ★★紮根 util 異常低/恆定 ⇒ 那才是 util 有問題；★★★以上皆非 ⇒ 原樣報不歸類")
	print("     ★這一格是 systems 寫在數字之前的門檻：要往【util 太低】修，先拿這個數字來。")
	print("  ★★讀法：兩行都接近 100%% ⇒ 兩個分支都幾乎不成立；")
	print("     ★★★若其中一行明顯低 ⇒ 那一分支【有時成立】，而掉在另一邊。")

# ★★★拆 `can_settle_here`（decision_context.gd:378）—— 六個子條件的 AND。
#   ★AND 可多個同時 false ⇒ ★★百分比加起來可以超過 100%，這不是錯。
func _sec_cansettle() -> void:
	var m: int = int(Probe.counts.get("cansettle.mother", 0))
	print("═══ ★拆 can_settle_here（六個子條件的 AND）═══")
	print("  母體（同 #10：IDLE 且 committed==紮根）= %d" % m)
	if m == 0:
		print("  ★★★母體 0 ⇒ 這個窗沒有隊落進來（儀器沒跑到／母體塌陷），不是「子條件都成立」")
		return
	for row in [["1_is_player", "是玩家隊"], ["2_no_leader", "沒領袖"], ["3_no_tile", "腳下無 tile"],
			["4_camp_level_not_1", "★不是站在自家 L0 營地（camp_level != 1）"],
			["5_already_outpost", "該格已有據點"], ["6_busy_construction", "該格有人在施工"]]:
		var n: int = int(Probe.counts.get("cansettle.false." + String(row[0]), 0))
		print("  %-34s false = %4d（%.1f%%）" % [String(row[1]), n, 100.0 * float(n) / float(m)])
	print("  ★can_settle_here 成立 = %d｜不成立 = %d" % [
		int(Probe.counts.get("cansettle.true", 0)), int(Probe.counts.get("cansettle.false_any", 0))])
	print("  ★★讀法：AND 可多個同時 false ⇒ 百分比加起來可超過 100%%（不是錯）；")
	print("     ★★★看【哪一行接近 100%%】—— 那一個就是真正卡住的；若多行都高，則是多重條件同時不成。")

# ★★★階梯交集守衛（systems 2026-09-03）—— ★這張票只要【一個數】。
func _sec_ladder() -> void:
	var m: int = int(Probe.counts.get("ladder.deep.calls", 0))
	var inter: int = int(Probe.counts.get("ladder.deep.intersect", 0))
	var teams_n: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with("ladder.deep.intersect.team."): teams_n += 1
	print("═══ ★★★階梯交集守衛（最深帶）═══")
	print("  母體（deep 帶 × tick）= %d" % m)
	if m == 0:
		print("  ★★★母體 0 ⇒ 【沒有隊進到最深帶】，這是母體塌陷不是答案")
		return
	print("  無施主 = %d｜其他階一個都不 applicable = %d" % [
		int(Probe.counts.get("ladder.deep.no_donor", 0)),
		int(Probe.counts.get("ladder.deep.no_other_step", 0))])
	print("  ★★★交集（無施主 ∧ 無其他階）= %d（分母 %d）｜相異隊數 = %d" % [inter, m, teams_n])
	if inter == 0:
		print("  ⇒ ★交集 ＝ 0 ⇒ 階梯沒斷：沒施主的時候【總有別階可用】⇒ 這條線可以收")
	else:
		print("  ⇒ ★★交集 > 0 ⇒ 階梯真的斷過 ⇒ ★★★重開的是【階梯有沒有斷】不是【乞食該不該保證施主】")

# ★★★camp churn 獨立成節（2026-09-03 血證）：它原本掛在 `_sec_zhagen` 裡，
#   而那支在 `zhagen.mother == 0` 時【早退】⇒ ★peaceful 世界（母體 0）跑完，churn 那幾行【整段消失】。
#   ★★而 churn 跟 zhagen 母體【毫無關係】—— 我把一個量測掛在一個不相干的守衛底下，
#   ★★★於是它正好在我最需要它的那個世界裡靜默失蹤（而輸出看起來完全正常）。
#   ⇒ 修法＝獨立成節、無條件印。
# ★★★#2 絕對餓：blueprint 要的是【逐隊 dump】不是總數
#   （「更常 fire 不是平衡問題，是真相問題；怕多 fire ＝ 怕真相」）
func _sec_abs_hunger() -> void:
	var n: int = int(Probe.counts.get("crisis.abs_hunger", 0))
	print("═══ ★#2 crisis 絕對餓（新判準）═══")
	print("  fire 次數 = %d" % n)
	if n == 0:
		print("  ★★★母體 0 ⇒ 這個窗裡沒有隊【存量歸零】——不是「判準沒接上」，兩者要分開：")
		print("     ★接上與否看 code；有沒有隊落進來看世界。而這一行只答後者。")
		return
	var sm: Array = Probe.samples.get("crisis.abs_hunger.sample", [])
	var new_only: int = 0
	for e in sm:
		if not bool(e.get("would_fire_by_old", false)): new_only += 1
	print("  取樣 %d 筆（cap 500，★first-N 不是 reservoir）｜其中舊三判準都不成立 = %d" % [sm.size(), new_only])
	# ★★★計數版（不受 first-N 限制）——★取樣只能講「最早那 N 筆」，計數才講得出全部
	print("  ★全部 %d 次裡：新抓到的 = %d｜舊判準也會抓的 = %d" % [n,
		int(Probe.counts.get("crisis.abs_hunger.new_only", 0)),
		int(Probe.counts.get("crisis.abs_hunger.old_too", 0))])
	# ★★per-team 桶（無 cap）——★★★2010 次是【3 隊各 670】還是【60 隊各 33】是兩個世界
	var pt: Dictionary = {}
	for k in Probe.counts.keys():
		var ks2: String = String(k)
		if ks2.begins_with("crisis.abs_hunger.team."): pt[ks2.substr(23)] = int(Probe.counts[k])
	var keys2: Array = pt.keys(); keys2.sort_custom(func(a, b): return int(pt[a]) > int(pt[b]))
	var top: Array = []
	for i2 in range(mini(8, keys2.size())):
		top.append("team%s=%d" % [String(keys2[i2]), int(pt[keys2[i2]])])
	print("  ★相異隊數 = %d｜前 8 名：%s" % [keys2.size(), " ".join(PackedStringArray(top))])
	print("  ── 逐隊（最多 10 筆）★raw 私產與 effective 並排：兩者都印才分得出「真的沒有」與「讀錯了」──")
	for i in range(mini(10, sm.size())):
		var e2: Dictionary = sm[i]
		print("     tick=%s team=%s pop=%s raw_food=%s eff_food=%s flow=%s 舊判準也會 fire=%s" % [
			str(e2.get("tick", -1)), str(e2.get("team", -1)), str(e2.get("pop", -1)),
			str(e2.get("raw_food", -1)), str(e2.get("eff_food", -1)),
			str(e2.get("flow_avg", -1)), str(e2.get("would_fire_by_old", false))])

# ★★★B 級三格＋順手一格（systems 派工 2026-09-04）。★每一格都【母體與命中同印】。
func _sec_b_grade() -> void:
	print("═══ ★B 級量測（#3 market-seeker／#15 普遍度＋perf／④minor>pop）═══")
	# ── ④minor_population > population ──
	var me: int = int(Probe.counts.get("minor_exceeds_pop", 0))
	print("  ④minor>pop 的隊×tick = %d｜相異隊 = %s" % [me, _bucket_list("minor_exceeds_pop.team.")])
	print("     ★恆 0 ⇒ 那條銷案；★★非 0 ⇒ 上面那串就是隊 id（systems 判是哪條路造成的）")
	# ── #3 market-seeker ──
	var ms_same: int = int(Probe.counts.get("mseek.same", 0))
	var ms_other: int = int(Probe.counts.get("mseek.other", 0))
	var ms_gave: int = int(Probe.counts.get("mseek.gave_up", 0))
	var ms_tot: int = ms_same + ms_other + ms_gave
	print("  #3 母體（撲空後 %d tick 內有再派的）= %d" % [FactionAISystem.DECISION_CADENCE, ms_tot])
	if ms_tot == 0:
		print("     ★★★母體 0 ⇒ 這輪【沒人在窗內再派】——不是「不會再去」（0 三讀法）")
	else:
		print("     ★再去【同一格】= %d（%.1f%%）｜換一格 = %d｜改做別的 = %d"
			% [ms_same, 100.0 * float(ms_same) / float(ms_tot), ms_other, ms_gave])
		print("     改做什麼：%s" % _bucket_list("mseek.gave_up.task."))
		var mss: Array = Probe.samples.get("mseek.sample", [])
		for i in range(mini(5, mss.size())):
			var e: Dictionary = mss[i]
			print("        team=%s opt=%s bail=%s new=%s same=%s" % [
				str(e.get("team", -1)), String(e.get("opt", "?")),
				String(e.get("bail_pos", "?")), String(e.get("new_pos", "?")), str(e.get("same", false))])
	# ── #15 普遍度（★佔比不是最大值）──
	var day_teams: Dictionary = {}
	var sw_teams: Dictionary = {}
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("churn.day_team."): day_teams[ks.substr(15)] = true
		elif ks.begins_with("churn.switch."): sw_teams[ks.substr(13)] = int(Probe.counts[k])
	var hit: int = 0
	for k2 in sw_teams:
		if int(sw_teams[k2]) >= 2: hit += 1
	print("  #15 普遍度｜母體（該日有決策的 隊×日）= %d｜命中（當日切換 ≥2 次）= %d（%.1f%%）"
		% [day_teams.size(), hit, 100.0 * float(hit) / maxf(float(day_teams.size()), 1.0)])
	print("     ★★★問的是【普遍嗎】不是【最大幾次】——「一隊 88 次」與「半數隊各 3 次」平均值可能一樣")
	# ── #15 perf ＋ 備援分子 ──
	print("  #15 perf｜`loop3.survival` 佔比需 phase_timing 開（本輪 %s）｜★備援分子 survival.eval_calls = %d"
		% [str(SimRunner.phase_timing), int(Probe.counts.get("survival.eval_calls", 0))])
	print("     ★exclusive=unknown（★★除非跑的人明示；★★★自動偵測只能反駁不能確認）")

func _sec_churn() -> void:
	print("═══ ★camp churn（觀察項，非驗收）═══")
	print("  ── ★camp churn（★用既有的桶，不為此新開定義；★★列【觀察項】不列驗收）──")
	print("     camp.built=%d｜camp.abandoned=%d｜settlement.camp_l0=%d｜outpost.l0_to_l1=%d｜walk_to_own_camp=%d｜own_camp_lost_release=%d"
		% [int(Probe.counts.get("camp.built", 0)), int(Probe.counts.get("camp.abandoned", 0)),
			int(Probe.counts.get("settlement.camp_l0", 0)), int(Probe.counts.get("outpost.l0_to_l1", 0)),
			int(Probe.counts.get("settlement.walk_to_own_camp", 0)),
			int(Probe.counts.get("survival.own_camp_lost_release", 0))])
	print("     ★camp.built 分桶（有家再蓋 vs 無家初次）：has_home=%d｜no_home=%d"
		% [int(Probe.counts.get("camp.built.has_home", 0)), int(Probe.counts.get("camp.built.no_home", 0))])
	# ★★★等價證明（只在 `CAMP_SHADOW=1` 開）：索引版 vs 掃描版逐數比對＋索引查詢層的 shadow 對帳。
	#   ★三條驗收（寫在數字之前）：`shadow_fails=0` 且 `shadow_checks>0` 且兩版分桶逐數相同。
	if OwnerCampIndex.shadow:
		print("     ★★等價證明｜掃描版：scan_has_home=%d｜scan_no_home=%d｜★mismatch=%d"
			% [int(Probe.counts.get("camp.built.scan_has_home", 0)),
				int(Probe.counts.get("camp.built.scan_no_home", 0)),
				int(Probe.counts.get("camp.built.scan_mismatch", 0))])
		print("     ★★★own_camp_tile 影子對帳：checks=%d｜fails=%d（★checks=0 ⇒ 「沒失敗」是因為沒跑）"
			% [OwnerCampIndex.shadow_checks, OwnerCampIndex.shadow_fails])
	print("     ★★★誠實限：churn 這一行【是這一刀才加的】⇒ 它【沒有修前基準】")
	print("        ⇒ ★單看修後數字說不出「降了」——★★那正是「拿一個數字去比一個不存在的數字」")

