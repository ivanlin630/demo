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

var _exclusive: String = "unknown"
var _t_start_ms: int = 0

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var sd: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	# ★等價證明用（預設關）：CAMP_SHADOW=1 才開，★開了每次 own_camp 查詢都會多掃一次全圖
	OwnerCampIndex.shadow = OS.get_environment("CAMP_SHADOW") == "1"
	_t_start_ms = Time.get_ticks_msec()
	# ★#15 perf 那半：`PHASE_TIMING=1` 才開（★★時間類 ⇒ 必須獨佔機器跑，今天剛立的規則）
	SimRunner.phase_timing = OS.get_environment("PHASE_TIMING") == "1"
	# ★★★獨佔與否【由跑的人明示】：沒傳就是 unknown（★不自動偵測升級成 yes——自動偵測只能反駁）
	_exclusive = OS.get_environment("EXCLUSIVE") if OS.has_environment("EXCLUSIVE") else "unknown"
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
		# ★★★中途小結（systems 2026-09-04）：★長跑的結論不能全部堆在結尾——
		#   血證：90 日 pilot 被砍在 day 53，而免費補答三項【全在報告區】⇒ 一項都沒撈到。
		#   ★★而它與串流版 wrapper 是【同一條在不同層】：wrapper 治 stdout 緩衝，
		#     ★★★這條治【結論只在最後才存在】—— 而後者 wrapper 救不了。
		#   ★格式照既有：母體與命中同印、key 名自報。
		if (d + 1) % 10 == 0:
			_sec_interim(d + 1)

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
	_sec_donorladder()
	_sec_zerowin()
	_sec_goalutil()
	_sec_aftermath(state, cfg, days)
	_sec_unitoverlap()
	_sec_perf5()
	_sec_prepare()
	_sec_optpool()
	# ★★★`[PilotRun]`（systems pilot 票的第三格點名的那一行）：
	#   ★`completed` 【不是我判的】——這一行印在床的最後，★★所以【它存在】就等於跑完了；
	#   ★★★若被砍／撞 timeout，這一行【不會出現】，而那正是 run-reliability 的答案。
	#   ★而 wall_clock 從【床內】量（不是外部 shell 計時）：外部計時對一個被砍的跑【也會給出一個數】，
	#     ★★而那個數會被誤讀成「它跑了這麼久就完成了」。
	# ★★★#18 免費補答（pilot 順手撈）：★問的是【團滅到剩 1 人】這個【轉變】，
	#   ★★不是「現在 pop==1」——後者一直都有，拿它回答會恆為「有」。
	var _solo: int = int(Probe.counts.get("solo_survivor.transition", 0))
	var _solo_teams: int = 0
	for _k5 in Probe.counts.keys():
		if String(_k5).begins_with("solo_survivor.team."): _solo_teams += 1
	print("═══ ★#18 `solo_survivor.transition`（團滅到剩 1 人）═══")
	print("  轉變次數 = %d｜相異隊 = %d" % [_solo, _solo_teams])
	if _solo == 0:
		print("  ★★★母體 0 ⇒ 這個窗裡【沒有隊走到那一步】——★不是「症狀已消失」")
	else:
		var _ss: Array = Probe.samples.get("solo_survivor.sample", [])
		for _i6 in range(mini(5, _ss.size())):
			var _e6: Dictionary = _ss[_i6]
			print("     tick=%s team=%s prev_pop=%s 當下 task=%s intent=%s" % [
				str(_e6.get("tick", -1)), str(_e6.get("team", -1)), str(_e6.get("prev_pop", -1)),
				String(_e6.get("task", "?")), String(_e6.get("intent", "?"))])
	print("[PilotRun] wall_clock_s=%.1f ｜ completed=yes ｜ window_days=%d ｜ seed=%d ｜ exclusive=%s" % [
		float(Time.get_ticks_msec() - _t_start_ms) / 1000.0, days, sd, _exclusive])
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
	print("  ★★★不在候選集的隊【當下有沒有自己的營地】 `redispatch.nir_owncamp.*`：%s" % _bucket_list("redispatch.nir_owncamp."))
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
	var zm: int = int(Probe.counts.get("zhagen.mother", 0))
	# ★★★這一行的措辭 2026-09-04 訂正：它原本寫「同 #10」，而【那句話是錯的】。
	#   ★兩個桶的條件文字一樣（IDLE 且 committed==紮根），但【記在不同的呼叫點】：
	#     `cansettle.*` 記在 `DecisionContext.gather`，`zhagen.*` 記在 `rank_scored`
	#   ⇒ ★★gather 的呼叫次數比 rank_scored 多 ⇒ ★★★兩個母體【天生就不相等】。
	#   ★實測：同一份 90 日跑，cansettle 母體 22、zhagen 母體 4。
	#   ⇒ 所以【這一節的百分比不能拿去讀紮根那一節】—— 兩節的分母是兩群。
	#   ★★這正是「分母裡混了幾個世界」那一條；★★★而它先前是靠一句註解宣稱相同、沒有人印出來對帳。
	print("  母體（IDLE 且 committed==紮根，記在 `gather`）= %d" % m)
	print("  ★★★對帳：`zhagen.mother`（同條件但記在 `rank_scored`）= %d ⇒ 兩者%s" % [
		zm, "相等" if zm == m else "【不相等，本節百分比不可拿去讀紮根那一節】"])
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
	print("  ④`minor_exceeds_pop` 的隊×tick = %d｜相異隊 = %s" % [me, _bucket_list("minor_exceeds_pop.team.")])
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
		# ★★★覓食那一格（★三層，不合成一個百分比）
		var f_ap: int = int(Probe.counts.get("mseek.forage.applicable", 0))
		var f_pop: int = int(Probe.counts.get("mseek.forage.pop_block", 0))
		var f_land: int = int(Probe.counts.get("mseek.forage.land_block", 0))
		var f_tot: int = f_ap + f_pop + f_land
		print("     ── ★覓食在不在候選 `mseek.forage.*`（母體＝改做別的 %d，本節分母 %d）──" % [ms_gave, f_tot])
		print("        ①applicable（覓食在 ranked）= %d" % f_ap)
		print("        ★②pop > FORAGE_VIABLE_POP(%d) = %d ⇒ 常數擋（★而地那半在此【不可觀測】：同一常數先擋）"
			% [FactionAISystem.FORAGE_VIABLE_POP, f_pop])
		print("        ★★③pop ≤ 常數 而仍不 applicable = %d ⇒ 沒有獵物格（★★★純粹的世界層讀數）" % f_land)
		print("        ★判讀（systems 寫在數字之前）：②佔絕大多數 ⇒ 常數擋的（而它的理由已被證不存在）；")
		print("           ★★③佔絕大多數 ⇒ 世界層；①佔多數 ⇒ 它上場了而秤不過 ⇒ util 相對量級；混合 ⇒ 兩邊都報")
		var fs: Array = Probe.samples.get("mseek.forage_sample", [])
		for i in range(mini(5, fs.size())):
			var e4: Dictionary = fs[i]
			print("        team=%s pop=%s 覓食在候選=%s pop_ok=%s 改去做=%s" % [
				str(e4.get("team", -1)), str(e4.get("pop", -1)), str(e4.get("forage_in_ranked", false)),
				str(e4.get("pop_ok", false)), String(e4.get("went", "?"))])
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
	print("  #15 perf｜phase_timing=%s｜★備援分子 survival.eval_calls = %d"
		% [str(SimRunner.phase_timing), int(Probe.counts.get("survival.eval_calls", 0))])
	if SimRunner.phase_timing:
		var ph: Dictionary = FactionAISystem._fai_ph
		var tot_us: int = 0
		for k3 in ph: tot_us += int(ph[k3])
		var sv: int = int(ph.get("loop3.survival", 0))
		print("     ★`loop3.survival` = %d us｜★★分母＝`_fai_ph` 全部相位（含 loop1/loop2）= %d us｜佔比 %.2f%%"
			% [sv, tot_us, 100.0 * float(sv) / maxf(float(tot_us), 1.0)])
		# ★★★兩個標籤訂正（2026-09-04，實測打掉我自己寫的前一版）：
		#   ①舊版寫「loop3 群組總計」⇒ ★錯：我加總的是 `_fai_ph` 的【全部】key，含 loop1.*／loop2.*
		#     ⇒ 這個比例是【survival ÷ 全部 faction_ai 相位】，不是【÷ loop3】
		#   ②舊版寫「每 tick clear ⇒ 這是最後一個 tick 的快照」⇒ ★★也錯：
		#     `evaluate_all` 確實在開頭 clear（:827），★★★而實測總量到 ~1200 萬 us
		#     —— 一個 tick 不可能有 12 秒（同一份輸出裡 PhaseSpike 最大才 0.5 秒）
		#     ⇒ 所以累積窗【比一個 tick 長】，而【多長我沒有量】⇒ 標未知，不猜
		#   ★而【比例本身仍然有效】：分子與分母來自【同一個快照】，窗一樣長
		print("     ★★★誠實限：累積窗【未知】（不是一個 tick）——而分子分母同窗 ⇒ 比例有效、絕對值不可跨跑比")
	print("     ★exclusive=%s（★★由跑的人明示；沒傳就是 unknown；★★★自動偵測只能反駁不能確認）" % _exclusive)
	# ★★★格一／格二【獨立印】（2026-09-04）：它們原本寫在 `#3 母體 > 0` 的分支裡
	#   ⇒ ★#3 母體 0 的那一輪，這兩節【整段消失】—— 而它們有【自己的母體】，跟 #3 是否有樣本無關。
	#   ★★同型今天已經踩過一次（camp churn 掛在 `zhagen.mother == 0` 的 early-return 之後）
	#   ⇒ ★★★所以這裡無條件印。
	# ★★★格一：覓食 applicable 卻沒贏時的【餓深分帶】（★沿用既有 ge5／2to5／0.5to2／deep）
	var lb: Array = []
	var lb_tot: int = 0
	for b2 in ["ge5", "2to5", "0.5to2", "deep"]:
		var v2: int = int(Probe.counts.get("mseek.forage.lost.band." + b2, 0))
		lb_tot += v2
		lb.append("%s=%d" % [b2, v2])
	var lt_teams: int = 0
	for k4 in Probe.counts.keys():
		if String(k4).begins_with("mseek.forage.lost.team."): lt_teams += 1
	print("     ── ★格一 `mseek.forage.lost.band.*`：覓食 applicable 卻沒贏｜餓深分帶（母體 %d，相異隊 %d）──" % [lb_tot, lt_teams])
	print("        %s" % " ｜ ".join(PackedStringArray(lb)))
	print("        ★判讀：淺帶輸給義務 ⇒ genuine 戰時紀律；★★deep 仍輸 ⇒ 餓死邊緣還在操練＝病；")
	print("           ★★★deep 母體 0 ⇒ 那格【答不了】，不是「深帶沒問題」")
	# ★★★格二：輸掉之後【真的怎麼了】（★定義寫在 population_system 的註解裡）
	var oc: Array = []
	var oc_tot: int = 0
	for o2 in ["ate", "starved", "neither", "gone"]:
		var v3: int = int(Probe.counts.get("mseek.forage.outcome." + o2, 0))
		oc_tot += v3
		oc.append("%s=%d" % [o2, v3])
	print("     ── ★★格二 `mseek.forage.outcome.*`：輸掉之後的實際後果（母體 %d｜N＝DECISION_CADENCE %d tick）──"
		% [oc_tot, FactionAISystem.DECISION_CADENCE])
	print("        %s" % " ｜ ".join(PackedStringArray(oc)))
	print("        ★判讀：starved 多 ⇒ 輸掉【真的有代價】；★★ate 多 ⇒ 經 crisis 那條路吃到了 ⇒ 輸 rank 沒代價")


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

# ★中途小結（每 10 日一次）：★★只印【被砍就會全損】的那幾格，不重印每日 [CP] 已有的
func _sec_interim(day: int) -> void:
	var zm: int = int(Probe.counts.get("zhagen.mother", 0))
	var zw: int = int(Probe.counts.get("zhagen.appl_won", 0))
	var zl: int = int(Probe.counts.get("zhagen.appl_lost", 0))
	var solo: int = int(Probe.counts.get("solo_survivor.transition", 0))
	print("[INTERIM day=%d] `zhagen.mother`=%d `zhagen.appl_won`=%d `zhagen.appl_lost`=%d"
		% [day, zm, zw, zl])
	print("[INTERIM day=%d] `camp.built`=%d `camp.built.has_home`=%d `camp.abandoned`=%d `outpost.l0_to_l1`=%d"
		% [day, int(Probe.counts.get("camp.built", 0)), int(Probe.counts.get("camp.built.has_home", 0)),
			int(Probe.counts.get("camp.abandoned", 0)), int(Probe.counts.get("outpost.l0_to_l1", 0))])
	print("[INTERIM day=%d] `solo_survivor.transition`=%d `crisis.abs_hunger`=%d `minor_exceeds_pop`=%d"
		% [day, solo, int(Probe.counts.get("crisis.abs_hunger", 0)),
			int(Probe.counts.get("minor_exceeds_pop", 0))])
	print("[INTERIM day=%d] `mseek.gave_up`=%d `mseek.forage.applicable`=%d `mseek.forage.pop_block`=%d `mseek.forage.land_block`=%d"
		% [day, int(Probe.counts.get("mseek.gave_up", 0)),
			int(Probe.counts.get("mseek.forage.applicable", 0)),
			int(Probe.counts.get("mseek.forage.pop_block", 0)),
			int(Probe.counts.get("mseek.forage.land_block", 0))])

# ★★★全 option 勝負池（systems 2026-09-04：「把變動最大的三個 option 勝負列出來」）。
#   ★這一節【不判斷】任何事 —— 它只把兩個量並排印出來，讓【兩份跑】可以逐行相減。
#   ★★cand 與 win 都印：只印 win 分不出「它變常勝」與「它變常在場」，
#      而兩份 config 對照時那兩件事的結論相反。
#   ★★★母體同印；★沒有母體的比率不可比（今天已經咬過一次：4 vs 22 兩個母體都自稱同一群）。
func _sec_optpool() -> void:
	print("═══ ★全 option 勝負池（`optpool.*`；★兩份跑逐行相減用）═══")
	var m: int = int(Probe.counts.get("optpool.mother", 0))
	print("  母體 `optpool.mother`（rank_scored 呼叫次數）= %d" % m)
	if m == 0:
		print("  ★★★母體 0 ⇒ 這一節【答不了】，不是「沒有 option 贏過」")
		return
	var names: Dictionary = {}
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("optpool.cand."): names[ks.substr(13)] = true
		elif ks.begins_with("optpool.win."): names[ks.substr(12)] = true
	var arr: Array = names.keys()
	arr.sort_custom(func(a, b): return int(Probe.counts.get("optpool.cand." + String(a), 0)) > int(Probe.counts.get("optpool.cand." + String(b), 0)))
	print("  %-24s %8s %8s %8s" % ["option", "cand", "win", "win/cand"])
	for n in arr:
		var c: int = int(Probe.counts.get("optpool.cand." + String(n), 0))
		var w: int = int(Probe.counts.get("optpool.win." + String(n), 0))
		print("  %-24s %8d %8d %7.1f%%" % [String(n), c, w, (100.0 * float(w) / float(c)) if c > 0 else 0.0])
	print("  ★誠實限：這一節【是這一刀才加的】⇒ 它沒有修前基準；")
	print("     ★★所以它只能拿【同一版 code、兩份 config】互相比，不能拿去比任何舊跑。")

# ★★★`[DonorLadder]` 逐階歸因（systems 2026-09-04 票）。
#   ★三格：自變數＝config／母體＝`entry`（階梯被評估的總次數，不是命中）／印在 `[DonorLadder]` 這一行。
#   ★★逐階印【條件名】不印序號 —— 有人插一階時序號整排錯位，名字不會。
#   ★★★對帳必印：`Σ各階 + hit == entry` 不平就在下一行印 ❌ —— ★沒有對帳的分桶等於沒有分桶。
func _sec_donorladder() -> void:
	var entry: int = int(Probe.counts.get("donorladder.entry", 0))
	var hit: int = int(Probe.counts.get("donorladder.hit", 0))
	var stages: Array = []
	var ssum: int = 0
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("donorladder.first."):
			var n: int = int(Probe.counts[k])
			stages.append([ks.substr(18), n])
			ssum += n
	stages.sort_custom(func(a, b): return int(a[1]) > int(b[1]))
	var parts: Array = ["entry=%d" % entry]
	for st in stages:
		parts.append("stage.%s=%d" % [String(st[0]), int(st[1])])
	parts.append("hit=%d" % hit)
	print("[DonorLadder] " + "  ".join(PackedStringArray(parts)))
	print("[DonorLadder] 對帳：Σ各階(%d) + hit(%d) = %d ｜ entry = %d %s" % [
		ssum, hit, ssum + hit, entry,
		("✅" if ssum + hit == entry else "❌ 不平 ⇒ 分桶不互斥或不窮盡，這一節的數字不可用")])
	print("[DonorLadder] 交集對帳（與既有守衛）：`ladder.deep.intersect`=%d ｜ `donorladder.hit`=%d %s" % [
		int(Probe.counts.get("ladder.deep.intersect", 0)), hit,
		("✅ 兩個定義等價" if int(Probe.counts.get("ladder.deep.intersect", 0)) == hit
			else "★★★不等 ⇒ 兩個定義不等價，先解釋差在哪再讀下面")])
	if entry == 0:
		print("[DonorLadder] ★★★entry = 0 ⇒ 這條階梯【從沒被評估過】—— 母體塌陷，不是「每一階都通」")
		return
	if hit == 0:
		print("[DonorLadder] ★hit = 0 ⇒ 本跑【不可重現】那 2 筆（★★而這不等於「沒事」，見票的判讀表第三列）")
		return
	print("[DonorLadder] ── ★命中逐筆（cap 50；★印當下 `scored` 全名單，才看得出它是不是真的無路）──")
	for r in Probe.samples.get("donorladder.hit_table", []):
		var d: Dictionary = r
		print("[DonorLadder]    tick=%s team=%s food_days=%s has_aid_target=%s｜scored=%s" % [
			str(d.get("tick", -1)), str(d.get("team", -1)), str(d.get("food_days", -1.0)),
			str(d.get("has_aid_target", false)), str(d.get("scored", []))])

# ★★★零勝 option 的 util dump（systems 2026-09-04 票）。
#   ★同家族的贏家（maintain_weapons/tools/food）一起印 —— ★★沒有它們，「輸家低」與
#     「大家都低」分不開；★★★而 systems 的假說（贏家＝團自己消耗的、輸家＝資本財＋原料）
#     只有在兩邊【並排】時才可能被推翻。
func _sec_zerowin() -> void:
	print("═══ ★零勝 option util dump（★同家族贏家並排；★★禁 crank：先問它是不是【就該低】）═══")
	print("  %-30s %6s %6s %9s %9s %9s" % ["option", "n", "won", "均 util", "均贏家 u", "均差距"])
	for opt in DecisionEngine.ZEROWIN_WATCH:
		var o: String = String(opt)
		var n: int = int(Probe.counts.get("zerowin." + o + ".n", 0))
		if n == 0:
			print("  %-30s %6d %6s %9s %9s %9s ← ★母體 0：這一列【答不了】" % [o, 0, "-", "-", "-", "-"])
			continue
		var won: int = int(Probe.counts.get("zerowin." + o + ".won", 0))
		var us: float = Probe.amount("zerowin." + o + ".u_sum")
		var ws: float = Probe.amount("zerowin." + o + ".winu_sum")
		print("  %-30s %6d %6d %9.4f %9.4f %9.4f" % [o, n, won, us / float(n), ws / float(n), (ws - us) / float(n)])
	print("  ★★★exact-tie（util 與贏家【完全相等】⇒ 它不是輸在分數，是輸在 tie-break 的 `i` 序）：")
	for opt in DecisionEngine.ZEROWIN_WATCH:
		var ot: String = String(opt)
		var nt: int = int(Probe.counts.get("zerowin." + ot + ".n", 0))
		var te: int = int(Probe.counts.get("zerowin." + ot + ".tie_exact", 0))
		print("     %-30s tie_exact=%d / n=%d %s" % [ot, te, nt,
			("← ★★★它從來沒有輸在分數上" if nt > 0 and te == nt else "")])
	print("  ★★差距分桶（贏家 − 該 option；★只在它沒贏的那些 tick）：")
	for opt in DecisionEngine.ZEROWIN_WATCH:
		var o2: String = String(opt)
		var parts: Array = []
		for b in ["lt0.1", "0.1to0.5", "0.5to1", "1to2", "ge2"]:
			parts.append("%s=%d" % [b, int(Probe.counts.get("zerowin." + o2 + ".gap." + b, 0))])
		print("     %-30s %s" % [o2, "｜".join(PackedStringArray(parts))])
	print("  ★★★逐筆（cap 20／option；★first-N 不是 reservoir）：")
	for opt in DecisionEngine.ZEROWIN_WATCH:
		var o3: String = String(opt)
		var rows: Array = Probe.samples.get("zerowin." + o3 + ".lost_table", [])
		if rows.is_empty():
			continue
		var r: Dictionary = rows[0]
		var tbl: Array = r.get("table", [])
		var top: Array = []
		for i in range(mini(5, tbl.size())):
			top.append("%s=%.4f" % [String((tbl[i] as Dictionary)["opt"]), float((tbl[i] as Dictionary)["u"])])
		var mine: String = "(不在前 5)"
		for e in tbl:
			if String((e as Dictionary)["opt"]) == o3:
				mine = "%s=%.4f" % [o3, float((e as Dictionary)["u"])]
				break
		print("     %-30s tick=%s team=%s 贏家=%s｜前5: %s｜本身: %s" % [
			o3, str(r.get("tick", -1)), str(r.get("team", -1)), str(r.get("winner", "")),
			"  ".join(PackedStringArray(top)), mine])

# ★★★goal candidate payoff 的上限探針（systems 2026-09-04 核可）。
#   ★它回答的是【那幾個 exact-tie 是不是 clamp 造成的】——
#     ★★而那兩個可能性在【只印 post 值】時長得一模一樣。
#   ★★★判讀先寫死（systems 的三列），不等數字出來再訂。
func _sec_goalutil() -> void:
	# ★★★這一節換過一次儀器，而【換掉的理由要留著】：
	#   ★第一版掛在 `goal_resolver.gd:285`／`:372` 兩個 `clampf` 上 ⇒ 母體只有 64，
	#     而那七個 option 光 30 日就各出現 46 次 ⇒ ★★儀器根本沒蓋到產它們的那條路。
	#   ★★★所以第一版的 `clamped=0` 【不是證據】—— 它是「沒量到」。舊探針已移除，
	#     ★不留兩把覆蓋率不同的尺並排印（那會讓人挑一把來讀）。
	_gu2()
func _gu2() -> void:
	var m: int = int(Probe.counts.get("gu2.mother", 0))
	print("  ── ★覆蓋率訂正版 `gu2.*`（掛在 `_candidate_util` 單一收斂點）──")
	print("     母體 = %d｜clamped = %d｜unclamped = %d" % [
		m, int(Probe.counts.get("gu2.clamped", 0)), int(Probe.counts.get("gu2.unclamped", 0))])
	if m == 0:
		print("     ★★★母體 0 ⇒ 這一節答不了")
		return
	print("     均 payoff = %.4f｜均 x = %.4f｜均 u = %.4f" % [
		Probe.amount("gu2.payoff_sum") / float(m),
		Probe.amount("gu2.x_sum") / float(m),
		Probe.amount("gu2.u_sum") / float(m)])
	# ★★★驗收 #4／#10 的機械斷言：★不是「數學上不會」，是【量到它沒有】。
	var _viol: int = int(Probe.counts.get("gu2.cap_violation", 0))
	var _xneg: int = int(Probe.counts.get("gu2.x_negative", 0))
	print("     ★#4 `u >= GOAL_UTIL_CAP` 反例 = %d %s" % [_viol, ("✅" if _viol == 0 else "❌ 保證被侵蝕")])
	print("     ★#10 `x < 0` 次數 = %d %s" % [_xneg, ("✅" if _xneg == 0 else "❌ 上游有人繞過 maxf(w,0)")])
	for pfx in ["gu2.payoff_val.", "gu2.devcoef_val.", "gu2.discount_val."]:
		var rows: Array = []
		for k in Probe.counts.keys():
			var ks: String = String(k)
			if ks.begins_with(pfx): rows.append([ks.substr(pfx.length()), int(Probe.counts[k])])
		rows.sort_custom(func(a, b): return int(a[1]) > int(b[1]))
		var parts: Array = []
		for i in range(mini(8, rows.size())):
			parts.append("%s×%d" % [String(rows[i][0]), int(rows[i][1])])
		print("     %-22s %s（相異值 %d 個）" % [pfx.substr(4), "｜".join(PackedStringArray(parts)), rows.size()])

# ★★★`[DonorAftermath]`（systems 2026-09-04 票）——★這一節的重點【不是命中隊】，是【對照組】。
#   ★「命中隊 39 天後還活著」沒有刻度：也許那個世界所有隊都活著。
#   ★★所以沒命中的隊要印【同樣的欄位】，一行一隊，讓兩邊可以逐欄比。
#   ★★★量【轉變】不量【狀態】：團滅＝`extinct` 那一刻（有 day），不是「跑完當下 pop==0」。
#   ★誠實限印在最後（peaceful 本來就少死 ⇒ 「沒死」解釋力弱、「死了」解釋力強，不對稱）。
func _sec_aftermath(state: WorldState, cfg: String, days: int) -> void:
	print("═══ ★`[DonorAftermath]`（★命中隊 ＋ ★★對照組同欄位）═══")
	# 命中隊：從 hit_table 取【第一次】命中
	var first_hit: Dictionary = {}   # team → {tick, pop}
	for r in Probe.samples.get("donorladder.hit_table", []):
		var d: Dictionary = r
		var tid: int = int(d.get("team", -1))
		if not first_hit.has(tid):
			first_hit[tid] = {"tick": int(d.get("tick", -1)), "pop": int(d.get("pop", -1))}
	# 名冊：活著的（state.teams）＋ 死掉的（extinct 桶）＋ 被 crisis 評估過的
	var roster: Dictionary = {}
	for tid in state.teams.keys():
		roster[int(tid)] = true
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("extinct.team."):
			roster[int(ks.substr(13))] = true
		elif ks.begins_with("crisis.entry.team."):
			roster[int(ks.substr(18))] = true
	var ids: Array = roster.keys()
	ids.sort()
	var n_hit_dead: int = 0
	var n_hit: int = 0
	var n_ctl_dead: int = 0
	var n_ctl: int = 0
	var n_hit_shell: int = 0
	var n_ctl_shell: int = 0
	for tid in ids:
		var t: int = int(tid)
		var is_hit: bool = first_hit.has(t)
		var dead: bool = int(Probe.counts.get("extinct.team.%d" % t, 0)) > 0
		var dday: String = _first_day_suffix("extinct.day.team.%d.d" % t)
		var ffd: String = _first_day_suffix("crisis.firstfire.team.%d.d" % t)
		var pop_end: int = int(state.teams[t].population) if state.teams.has(t) else 0
		var fh: Dictionary = first_hit.get(t, {})
		var fh_day: String = ("%.1f" % (float(int(fh.get("tick", -1))) / float(WorldState.TICKS_PER_DAY))) if is_hit else "-"
		print("[DonorAftermath] cfg=%s team=%d hit=%s first_hit_day=%s end=%s death_day=%s pop_first_hit=%s pop_end=%d crisis_entry=%d crisis_fired=%d crisis_first_fire_day=%s" % [
			cfg, t, ("yes" if is_hit else "no"), fh_day,
			("團滅" if dead else "存活"), dday,
			(str(int(fh.get("pop", -1))) if is_hit else "-"), pop_end,
			int(Probe.counts.get("crisis.entry.team.%d" % t, 0)),
			int(Probe.counts.get("crisis.abs_hunger.team.%d" % t, 0)), ffd])
		# ★★★8 日 smoke 撞到的第三種狀態：`pop_end=0` 而【沒有】`extinct` 桶 ⇒ 隊還在名冊裡但沒人。
		#   ★「存活」與「團滅」兩個字裝不下它，而它會被讀成「存活」⇒ 直接把它標出來。
		if pop_end == 0 and not dead:
			print("[DonorAftermath]    ↑ ★★★team=%d 是【空殼】：pop_end=0 而未 extinct ⇒ 別讀成「存活」" % t)
		# ★★★三分類（systems 2026-09-04）：★「存活／團滅」兩格會把【空殼】算進存活，
		#   而實測新 config 的空殼（6）比團滅（4）還多 ⇒ ★★兩格版本【低估】了非存活比例。
		var shell: bool = (pop_end == 0 and not dead)
		if is_hit:
			n_hit += 1
			if dead: n_hit_dead += 1
			elif shell: n_hit_shell += 1
		else:
			n_ctl += 1
			if dead: n_ctl_dead += 1
			elif shell: n_ctl_shell += 1
	print("[DonorAftermath] ── ★兩組並排（★這一行才是判讀表要讀的）──")
	print("[DonorAftermath] cfg=%s window_days=%d ★三分類（存活／團滅／空殼）" % [cfg, days])
	print("[DonorAftermath]   命中隊 n=%d：存活 %d｜團滅 %d｜★空殼 %d｜★★團滅+空殼 %d（%s）" % [
		n_hit, n_hit - n_hit_dead - n_hit_shell, n_hit_dead, n_hit_shell, n_hit_dead + n_hit_shell,
		("%.1f%%" % (100.0 * float(n_hit_dead + n_hit_shell) / float(n_hit))) if n_hit > 0 else "母體 0"])
	print("[DonorAftermath]   對照組 n=%d：存活 %d｜團滅 %d｜★空殼 %d｜★★團滅+空殼 %d（%s）" % [
		n_ctl, n_ctl - n_ctl_dead - n_ctl_shell, n_ctl_dead, n_ctl_shell, n_ctl_dead + n_ctl_shell,
		("%.1f%%" % (100.0 * float(n_ctl_dead + n_ctl_shell) / float(n_ctl))) if n_ctl > 0 else "母體 0"])
	print("[DonorAftermath]   ★★★只看『團滅』會低估：實測新 config 空殼 6 支 > 團滅 4 支")
	print("[DonorAftermath] ★★誠實限：①peaceful 本來就少死 ⇒「沒死」解釋力弱、「死了」解釋力強（不對稱）")
	print("[DonorAftermath]    ②命中母體很小 ⇒ ★★★這是【個案】不是【樣本】：只能寫「這一隊發生了什麼」")
	print("[DonorAftermath]    ③名冊＝跑完仍在 `state.teams` ＋ 有 `extinct` 桶 ＋ 被 crisis 評估過的聯集")
	print("[DonorAftermath]       ⇒ ★一支【從沒被 crisis 評估過而且活到最後】的隊仍在名冊裡；★★而【中途生中途死且從沒被評估】的隊不在")

# 取「第一個出現的日期後綴」（key 形如 `<prefix><4 位日>`）；沒有就回 `-`。
func _first_day_suffix(prefix: String) -> String:
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with(prefix):
			return str(int(ks.substr(prefix.length())))
	return "-"

# ★★★`[UnitOverlap]`（systems 2026-09-04 前置量測票）——★這一節的用途是【否決】不是【確認】。
#   ★若兩家族值域系統性分離（overlap_frac ≈ 0）⇒ 「改用同單位」那個設計不成立，systems 重畫。
#   ★★A 類與 C 類 build 分開印：它們不同源，混在一起會讓 build 家族的值域讀起來假寬。
#   ★★★`overlap_frac` 的定義印在輸出裡（★不印定義的比例數字沒有意義）。
func _sec_unitoverlap() -> void:
	print("═══ ★`[UnitOverlap]`（★前置量測：兩家族值域並排；★★用途是【否決】設計）═══")
	var fams: Dictionary = {"maintain": [], "buildA": [], "buildC": []}
	for k in Probe.samples.keys():
		var ks: String = String(k)
		if not ks.begins_with("unitoverlap."): continue
		var rest: String = ks.substr(12)
		var dot: int = rest.find(".")
		if dot < 0: continue
		var fam: String = rest.substr(0, dot)
		if not fams.has(fam): continue
		var gt: String = rest.substr(dot + 1)
		var vals: Array = []
		var wals: Array = []
		var xals: Array = []
		var uals: Array = []
		var rows_raw: Array = []
		for r in Probe.samples[k]:
			vals.append(float((r as Dictionary).get("v", 0.0)))
			# ★可用性走獨立旗標，不靠值域判 —— ★★`w` 本來就可以是負的（有餘）
			if bool((r as Dictionary).get("w_ok", false)):
				wals.append(float((r as Dictionary).get("w", 0.0)))
			xals.append(float((r as Dictionary).get("x", 0.0)))
			uals.append(float((r as Dictionary).get("u", 0.0)))
			rows_raw.append(r)
		vals.sort()
		wals.sort()
		if vals.is_empty(): continue
		xals.sort()
		uals.sort()
		fams[fam].append([gt, vals, wals, xals, uals, rows_raw])
	for fam in ["maintain", "buildA", "buildC"]:
		for row in fams[fam]:
			var gt2: String = String(row[0])
			var v: Array = row[1]
			print("[UnitOverlap] fam=%s goal=%s n=%d min=%.4f p25=%.4f med=%.4f p75=%.4f max=%.4f" % [
				fam, gt2, v.size(), float(v[0]), _pct(v, 0.25), _pct(v, 0.50), _pct(v, 0.75), float(v[v.size() - 1])])
	# ★★★不飽和候選 `w`（systems 2026-09-04）：★問的只有一件事 —— 【它會不會變】。
	#   ★★與 `v` 逐筆對齊 ⇒ 「v 釘在 1.0 的那些筆，w 有沒有動」直接看得出來。
	#   ★★★C 類沒有 outputs ⇒ 記 −1 ⇒ 印成「答不了」，不硬湊近似值。
	print("[UnitOverlap] ── ★不飽和候選 `w` ＝（target − stock）× BASE_PRICE ──")
	for fam2 in ["maintain", "buildA", "buildC"]:
		for row2 in fams[fam2]:
			var gt3: String = String(row2[0])
			var ws: Array = row2[2]
			if ws.is_empty():
				print("[UnitOverlap] w fam=%s goal=%s ★答不了（此類無 outputs ⇒ 沒有可用的絕對量）" % [fam2, gt3])
				continue
			var uniq: Dictionary = {}
			for wv in ws: uniq[wv] = true
			print("[UnitOverlap] w fam=%s goal=%s n=%d min=%.4f med=%.4f max=%.4f ★相異值=%d %s" % [
				fam2, gt3, ws.size(), float(ws[0]), _pct(ws, 0.50), float(ws[ws.size() - 1]), uniq.size(),
				("← ★★★常數，這個方向也死" if uniq.size() == 1 else "← ★會變")])
	# ★★★驗收 #6：`w`／`x`／`u` 三欄並排（★組成項與結果一起看，才知道 u 為什麼是那個值）
	print("[UnitOverlap] ── ★三欄 `w`／`x`／`u`（★x = payoff/UNIT，UNIT ＝ 該隊一天生計的價值）──")
	print("[UnitOverlap]    ★★這裡的 `u` ＝ 壓縮輸出本身（`CAP × x/(1+x)`）——★★★【不含】 dev_coeff 與 discount，")
	print("[UnitOverlap]       而 `_candidate_util` 的最終 util 還要再乘那兩個 ⇒ 兩者不可互相引用",)
	for fam3 in ["maintain", "buildA", "buildC"]:
		for row3 in fams[fam3]:
			var g3: String = String(row3[0])
			var xs: Array = row3[3]
			var us2: Array = row3[4]
			var ws2: Array = row3[2]
			if xs.is_empty(): continue
			print("[UnitOverlap] %-10s %-20s n=%-4d w_med=%-10s x: min=%.4f med=%.4f max=%.4f ｜ u: min=%.4f med=%.4f max=%.4f" % [
				fam3, g3, xs.size(),
				("%.2f" % _pct(ws2, 0.50)) if not ws2.is_empty() else "-",
				float(xs[0]), _pct(xs, 0.50), float(xs[xs.size() - 1]),
				float(us2[0]), _pct(us2, 0.50), float(us2[us2.size() - 1])])
	# ★★★驗收 #9：build 那半【依隊規模分層】—— pop 殘留要可觀測，不要靜默存在
	print("[UnitOverlap] ── ★★build 依隊規模分層（★pop 殘留可觀測：建設成本固定而 UNIT ∝ pop）──")
	for fam4 in ["buildA", "buildC"]:
		for row4 in fams[fam4]:
			var g4: String = String(row4[0])
			var raw: Array = row4[5]
			var band: Dictionary = {"小(pop<=3)": [], "中(4-8)": [], "大(>=9)": []}
			for r4 in raw:
				var pp: int = int((r4 as Dictionary).get("pop", 0))
				var key: String = ("小(pop<=3)" if pp <= 3 else ("中(4-8)" if pp <= 8 else "大(>=9)"))
				band[key].append([float((r4 as Dictionary).get("x", 0.0)), float((r4 as Dictionary).get("u", 0.0))])
			var parts4: Array = []
			for bk in ["小(pop<=3)", "中(4-8)", "大(>=9)"]:
				var arr: Array = band[bk]
				if arr.is_empty():
					parts4.append("%s n=0" % bk)
					continue
				var sx: float = 0.0
				var su: float = 0.0
				for e4 in arr:
					sx += float(e4[0])
					su += float(e4[1])
				parts4.append("%s n=%d x̄=%.4f ū=%.4f" % [bk, arr.size(), sx / float(arr.size()), su / float(arr.size())])
			print("[UnitOverlap]    %-20s %s" % [g4, "｜".join(PackedStringArray(parts4))])
	print("[UnitOverlap]    ★★★讀法：`x̄` 隨 pop 【下降】＝ 大隊覺得蓋東西比較不急 ——")
	print("[UnitOverlap]       ★而那個方向【對齊 size_matter_arc 的設計意圖】（同一筆固定成本對大隊相對負擔更輕）")
	print("[UnitOverlap]       ⇒ ★★不是新 bug；★★★但它現在是【被印出來的】而不是靜默存在的")
	var mm: Array = _fam_range(fams["maintain"])
	var ba: Array = _fam_range(fams["buildA"])
	var bc: Array = _fam_range(fams["buildC"])
	var all_build: Array = fams["buildA"] + fams["buildC"]
	var bb: Array = _fam_range(all_build)
	print("[UnitOverlap] SUMMARY maintain=[%.4f..%.4f] build=[%.4f..%.4f] overlap_frac=%.2f" % [
		mm[0], mm[1], bb[0], bb[1], _overlap(mm, bb)])
	print("[UnitOverlap]   ★分開看：buildA=[%.4f..%.4f]（n=%d）｜buildC=[%.4f..%.4f]（n=%d）" % [
		ba[0], ba[1], int(ba[2]), bc[0], bc[1], int(bc[2])])
	print("[UnitOverlap]   ★★`overlap_frac` 定義 ＝ 兩家族區間【交集長度 ÷ 聯集長度】（0 ＝ 完全不相交、1 ＝ 完全重合）")
	# ★★★單一個 overlap_frac 會被【離群值】主宰：maintain 的 shortage 可以是負的（有餘），
	#   而 build 的 deficit 被 clamp 在 0 以上 ⇒ 聯集被一條長尾拉開，比值就變得很小，
	#   ★而那【不是】「兩家族分離」，是【一個家族的定義域比較寬】。
	#   ⇒ ★★所以同時印【包含率】：build 的區間有多少落在 maintain 的區間裡。
	#   ★★★兩個數字一起看才判得動 —— 只看比值會把「被包住」誤讀成「分離」。
	var _inter: float = minf(mm[1], bb[1]) - maxf(mm[0], bb[0])
	var _blen: float = bb[1] - bb[0]
	print("[UnitOverlap]   ★★★包含率 ＝ build 區間落在 maintain 區間內的比例 = %.2f（1.00 ＝ build 完全被 maintain 包住 ⇒ 不是分離）" % [
		(maxf(_inter, 0.0) / _blen) if _blen > 0.0 else 0.0])
	print("[UnitOverlap]   ★★★誠實限：30 日窗、單 seed、單世界 ⇒ 這是【這個世界這段時間】的值域，")
	print("[UnitOverlap]      不是機制的定義域 ⇒ 只能做【系統性分離 vs 明顯重疊】的粗判，")
	print("[UnitOverlap]      ★不得拿它算任何比例常數（算了就變成手填常數）")
	print("[UnitOverlap]   ★母體漏掉的：no_otile=%d｜no_prereq=%d｜no_res=%d（★這三種沒有值可取）" % [
		int(Probe.counts.get("unitoverlap.skip.no_otile", 0)),
		int(Probe.counts.get("unitoverlap.skip.no_prereq", 0)),
		int(Probe.counts.get("unitoverlap.skip.no_res", 0))])

func _pct(sorted_vals: Array, q: float) -> float:
	var i: int = int(floor(q * float(sorted_vals.size() - 1)))
	return float(sorted_vals[clampi(i, 0, sorted_vals.size() - 1)])

func _fam_range(rows: Array) -> Array:
	var lo: float = INF
	var hi: float = -INF
	var n: int = 0
	for row in rows:
		var v: Array = row[1]
		lo = minf(lo, float(v[0]))
		hi = maxf(hi, float(v[v.size() - 1]))
		n += v.size()
	if n == 0: return [0.0, 0.0, 0]
	return [lo, hi, n]

func _overlap(a: Array, b: Array) -> float:
	var inter: float = minf(float(a[1]), float(b[1])) - maxf(float(a[0]), float(b[0]))
	var uni: float = maxf(float(a[1]), float(b[1])) - minf(float(a[0]), float(b[0]))
	if uni <= 0.0: return 0.0
	return maxf(inter, 0.0) / uni

# ★★★perf（`payoff-derive-bridge` 驗收 #5）。★計數與時間【分開報】：
#   ★★計數是決定性的（並跑不影響），時間必須獨佔才有意義 —— 混在同一行會讓人以為兩者都獨佔過。
#   ★★★分母用 `optpool.mother`（rank_scored 呼叫次數）⇒ 印【每決策幾次】不是總次數。
func _sec_perf5() -> void:
	var m: int = int(Probe.counts.get("optpool.mother", 0))
	print("═══ ★perf #5（`need_keep`／`_facility_deficit`）═══")
	print("  分母 `optpool.mother`（rank_scored 呼叫次數）= %d｜exclusive=%s" % [m, _exclusive])
	if m == 0:
		print("  ★★★分母 0 ⇒ 這一節答不了")
		return
	for row in [["need_keep", "perf.need_keep"], ["_facility_deficit", "perf.facility_deficit"]]:
		var nm: String = String(row[0])
		var k: String = String(row[1])
		var c: int = int(Probe.counts.get(k + ".calls", 0))
		var us: float = Probe.amount(k + ".us")
		print("  ★計數 %-18s calls=%-8d 每決策=%.2f 次" % [nm, c, float(c) / float(m)])
		# ★★★這兩個函式【互相遞迴】：`need_keep`(need_oracle.gd:19) → `_construction_facility_need`
		#   → `_facility_deficit`(faction_ai_system.gd:5704/5717) → `need_keep`
		#   ⇒ ★計時是【巢狀重複計算】的：內層的時間被外層再算一次
		#   ⇒ ★★所以這兩個 us 數字【不是成本】，不管獨不獨佔都不可引用
		#   ⇒ ★★★段級成本要用 `PHASE_TIMING=1` 的 phase 計時（不巢狀），另跑且必須獨佔
		print("     ★★時間 us_total=%.0f ← ★★★【不可引用】：兩函式互相遞迴 ⇒ 巢狀重複計算" % us)
		print("        （exclusive=%s；★段級成本請看 `PHASE_TIMING=1` 的 phase 計時，不是這一行）" % _exclusive)
	print("  ★★★誠實限：`need_keep` 在導出【之前】的呼叫次數就不是 0（A 類 evaluator 本來就呼叫它）")
	print("     ⇒ ★要看的是【導出前後的差】，而不是「導出引入了這些呼叫」")
