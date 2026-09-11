extends SceneTree
# @bed-kind: diagnostic
# 信使旅程切段（HOW spec 2026-09-11-herald-journey-segments）：★這一票【只量不修】。
#
# ★為什麼只量：同卷已證「尺可信」（fp 逐字相同、紮營 0% → 79.2%）⇒ 2.2% 是世界的事實
#   ⇒ 要問的是【那 44 趟從哪幾個門出去】，不是「送達判定對不對」。
# ★★母體：一段 `TASK_HERALD` episode（commit 成立 → 換 task／窗末）。★窗末未完【單獨一類、不進分母】。
# ★★★門鈴格（spec §③）：送達的唯一入口是 pairwise 相遇（interaction_system:390-393 同派系內／
#   :421-425 envoy_proposal）⇒ **抵達目標格 ≠ 送達**，要與那支目標隊【本身】相遇。
#   ⇒ 本床把「抵達目標格」與「與目標同格（相遇）」分成兩格量，★因為它們正是求居案同族的兩件事。
# ★而 spec §③(ii) 那個【負斷言】（跨派系且 task_reason != envoy_proposal 的信使可能沒有送達分支）
#   —— ★★本床用逐筆資料證實或推翻它：每段都記 same_faction 與 task_reason，並與送達交叉。
# ★★★限（systems 2026-09-12 要求寫進檔頭）：`analysis.hostile.*` 量到的是
#   **「每一支隊【自己認為】的敵意」**，★**不是**「世界上真的敵對關係」。
#   ⇒ ★★若有人拿這張表說「世界上敵對關係只有 X%」——**本表答不了那句話**。
#   ⇒ ★★★而兩者的差**本身是一個發現**：若「自己認為的敵意」遠少於「真實的敵對」，
#     那是**資訊網的病**（大家不知道誰是敵人）—— 這一格本卷不做，但限先寫在這裡。
# env：HJ_TICKS（預設 43200 ＝ 30 天）／HJ_SEED（預設 1337）／HJ_CONFIG（預設 warring_states）

func _initialize() -> void:
	_run(); quit(0)

func _run() -> void:
	var ticks: int = int(OS.get_environment("HJ_TICKS")) if OS.has_environment("HJ_TICKS") else 43200
	var seed_val: int = int(OS.get_environment("HJ_SEED")) if OS.has_environment("HJ_SEED") else 1337
	var cfg: String = OS.get_environment("HJ_CONFIG") if OS.has_environment("HJ_CONFIG") else "warring_states"
	print("=== 信使旅程切段（%d tick ＝ %.1f 遊戲天，%s，seed=%d，★預設 config 未改）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, seed_val])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var enc_per_tick: Array = []     # ★一個 tick 幾次相遇（p50／p95／max ＝ 喚醒風暴的形狀）
	var _enc_prev: int = 0
	var rank_prev: Dictionary = {}   # team_id → 上一 tick 結束時的逐隊 rank 計數（★答「那一 tick 有沒有想」）
	var live: Dictionary = {}     # team_id → 進行中的 episode
	var dlive: Dictionary = {}    # 迎戰 episode（同上，但目標是【威脅隊】）
	var drows: Array = []
	var rows: Array = []          # 逐筆（★全收，母體是數十不是數千）
	for tick in range(ticks):
		runner.advance_tick(st, no_player)
		var _enc_now: int = int(Probe.counts.get("encounter.pair_calls", 0))
		enc_per_tick.append(_enc_now - _enc_prev)
		_enc_prev = _enc_now
		# ★上一 tick 結束時的逐隊決策計數（★下一輪用它算「那一 tick 的增量」）
		#   ⇒ 放在掃描【之前】更新 ⇒ 掃描當下 rank_prev 仍是【上一 tick 末】的值
		var _rank_snapshot: Dictionary = {}
		for tidp in st.teams:
			_rank_snapshot[tidp] = int(Probe.counts.get("engine.rank.t%d" % tidp, 0))
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			# ★★★相遇機器（blueprint 併案 2026-09-11）：迎戰照【互斥且窮盡、可對帳】的既有形狀加三格
			#   ①迎戰姿態起算 ②同格相遇（★這一格才是門鈴）③轉換成開打
			#   ⇒ ★三個數字才分得出兩種世界：**沒碰到**（相遇機制的病）vs **碰到了但沒打**（決策的病）
			if t.current_task == TeamData.TASK_DEFEND:
				# ★★★切段鍵【只認 task 的連續段】（systems 2026-09-11 的質疑：同一個缺陷會不會也在這張表裡）
				#   ★第一版用 `prosperity_target_id` 當鍵 ⇒ 目標被清成 -1 再回填就會切一刀
				#     ⇒ **母體灌大、而「沒有目標」那一格會吃到切段的碎片**（與信使那個 `move_target` 同族）
				#   ★★這一版：一段 ＝ 連續持有 `TASK_DEFEND` 的那一段；
				#     目標／相遇／開打都改成【這一段裡曾經發生過】⇒ **鍵不可能因為欄位抖動而切段**。
				if not dlive.has(tid):
					dlive[tid] = {"team": tid, "oid": -1, "start": st.world.current_tick, "met": false,
						"target_switches": 0, "last_oid": -1,
						"rank_at_met": -1, "rank_same_tick": -1, "met_tick": -1, "rank_hour": -1,
						"fight0": int(Probe.counts.get("combat.entered.t%d" % tid, 0))}
				var _ep: Dictionary = dlive[tid]
				var _dk: int = t.prosperity_target_id
				if _dk != -1:
					if int(_ep["oid"]) == -1:
						_ep["oid"] = _dk            # ★「這一段曾經有過目標」
					if _dk != int(_ep["last_oid"]) and int(_ep["last_oid"]) != -1:
						_ep["target_switches"] = int(_ep["target_switches"]) + 1
					_ep["last_oid"] = _dk
					if int(_ep.get("met_tick", -1)) >= 0 and int(_ep.get("rank_hour", -1)) < 0:
						if st.world.current_tick - int(_ep["met_tick"]) >= WorldState.TICKS_PER_HOUR:
							_ep["rank_hour"] = int(Probe.counts.get("engine.rank.t%d" % tid, 0)) - int(_ep["rank_at_met"])
					var _dt: TeamData = st.teams.get(_dk)
					if _dt != null and _dt.tile_pos == t.tile_pos:
						if not bool(_ep["met"]):
							# ★systems 要【兩個數】不是一個：
							#   ①碰到面的那一 tick 有沒有跑決策（＝本 tick 的增量）
							#   ②之後一個遊戲小時內跑過幾次
							var _rk_now: int = int(Probe.counts.get("engine.rank.t%d" % tid, 0))
							_ep["rank_same_tick"] = _rk_now - int(rank_prev.get(tid, 0))
							_ep["rank_at_met"] = _rk_now
							_ep["met_tick"] = st.world.current_tick
						_ep["met"] = true
			elif dlive.has(tid):
				_close_defend(dlive[tid], st, drows)
				dlive.erase(tid)
			if t.current_task == TeamData.TASK_HERALD:
				if not live.has(tid) or int(live[tid]["oid"]) != t.order_target_id:
					if live.has(tid):
						_close(live[tid], st, rows, false)
					var tgt: TeamData = st.teams.get(t.order_target_id)
					live[tid] = {
						"team": tid, "start": st.world.current_tick, "oid": t.order_target_id,
						"reason": t.task_reason, "opt": t.current_option,
						"same_faction": tgt != null and tgt.faction_id == t.faction_id and t.faction_id != -1,
						"dist0": FactionAISystem._hex_dist(t.tile_pos, t.move_target) if t.move_target != Vector2i(-1, -1) else -1,
						"at_cell": false, "met": false,
						"done0": int(Probe.counts.get("task.done.t%d.%s" % [tid, TeamData.TASK_HERALD], 0)),
						"lost0": _lost_of(tid),
					}
				var ep: Dictionary = live[tid]
				if t.move_target != Vector2i(-1, -1) and t.tile_pos == t.move_target:
					ep["at_cell"] = true              # ★①抵達目標【格】
				var tg: TeamData = st.teams.get(t.order_target_id)
				if tg != null and tg.tile_pos == t.tile_pos:
					ep["met"] = true                  # ★②與目標隊【本身】相遇（門鈴按得到）
			elif live.has(tid):
				_close(live[tid], st, rows, false)
				live.erase(tid)
		rank_prev = _rank_snapshot
	for tid2 in live:
		_close(live[tid2], st, rows, true)
	for tid3 in dlive:
		_close_defend(dlive[tid3], st, drows)

	# ── 逐站分桶 ──
	var n: int = rows.size()
	# ★★★母體紀律（★我第一版在這裡犯了今天一直在抓的那個錯）：
	#   逐站計數要與【它自己的分母】同一批 —— 第一版用「全部 145 段」數到場／送達，
	#   卻除以「完整結束 23 段」⇒ 132 > 23 ⇒ ★**比率大於 1 的表，是母體錯配的指紋**。
	#   ⇒ 這一版：**closed（完整結束）與 all（含窗末未完）兩組各自印，並各自標分母**。
	# ★★而還要再切一刀：**起算距離 0** 與 **起算距離 > 0** 是兩群完全不同的信使
	#   （前者生成時就站在目標身上 ⇒ 當場送達；後者才是「旅程」）——
	#   ★★★把它們混在一個平均裡，會把「遠的送不到」洗成「大部分送到了」。
	var groups: Dictionary = {"closed_far": [], "closed_mid": [], "closed_near": [],
		"open_far": [], "open_mid": [], "open_near": []}
	for r in rows:
		# ★三段而不是兩段：0 格（生成時就站在目標身上）／1-2 格（一步到）／≥3 格（★真的遠行，與別卷同母體）
		var _d: int = int(r["dist0"])
		var _seg: String = "near" if _d <= 0 else ("mid" if _d < 3 else "far")
		var kk: String = ("open_" if bool(r["cut"]) else "closed_") + _seg
		(groups[kk] as Array).append(r)
	print("")
	print("★①母體：信使 episode 共 %d 段（完整結束 %d／窗末未完 %d）" % [
		n, n - _open_n(groups), _open_n(groups)])
	print("   ★分四群：起算距離 >0 ＝【真的有旅程】／起算距離 0 ＝【生成時就站在目標身上】")
	for gk in ["closed_far", "closed_mid", "closed_near", "open_far", "open_mid", "open_near"]:
		var g: Array = groups[gk]
		var at_c: int = 0; var mt: int = 0; var dl: int = 0
		for r2 in g:
			if bool(r2["at_cell"]): at_c += 1
			if bool(r2["met"]): mt += 1
			if bool(r2["delivered"]): dl += 1
		var rate: String = "不可判(母體0)" if g.is_empty() else ("%.1f%%" % (100.0 * float(dl) / float(g.size())))
		print("   %-12s 母體 %3d ｜到格 %3d｜相遇 %3d｜送達 %3d ｜送達率 %s" % [gk, g.size(), at_c, mt, dl, rate])
	print("   ★『抵達了但沒相遇』只在【有旅程】那一群有意義 —— ★★而那正是求居案的同族（到了但沒見到人）")
	var by_exit: Dictionary = {}
	var cross_no_envoy: int = 0
	var cross_no_envoy_delivered: int = 0
	for r3 in rows:
		var ex: String = String(r3["exit"])
		by_exit[ex] = int(by_exit.get(ex, 0)) + 1
		if not bool(r3["same_faction"]) and String(r3["reason"]) != "envoy_proposal":
			cross_no_envoy += 1
			if bool(r3["delivered"]): cross_no_envoy_delivered += 1
	print("★③出口分桶（★加總必須 ＝ 母體；沒有「其他」這一桶）：%s" % str(by_exit))
	var tot: int = 0
	for k in by_exit: tot += int(by_exit[k])
	print("   守恆：分桶加總 %d vs 母體 %d ⇒ %s" % [tot, n, "OK" if tot == n else "★不符，要查"])
	print("★④送達入口分流：同派系 order %d 次｜envoy_proposal %d 次" % [
		int(Probe.counts.get("herald.delivered.order", 0)),
		int(Probe.counts.get("herald.delivered.envoy", 0))])
	print("★★★⑤spec §③(ii) 那個負斷言（跨派系 ＋ task_reason != envoy_proposal）：")
	print("   母體 %d 段；其中送達 %d 段" % [cross_no_envoy, cross_no_envoy_delivered])
	if cross_no_envoy == 0:
		print("   ★母體 0 ⇒ **不可判**（★★而那與「它們都送不到」是兩個結論）")
	elif cross_no_envoy_delivered == 0:
		print("   ★★★母體非 0 而送達 0 ⇒ **與負斷言一致**（★仍是觀測、不是證明）")
	else:
		print("   ★★★**負斷言被推翻**：這一類有送達 ⇒ 存在第三條路，要找出它")
	# ── ★迎戰：三格（互斥且窮盡 ⇒ 相加 ＝ 起算，可對帳）──
	var d_met_fight: int = 0
	var d_met_nofight: int = 0
	var d_nomeet: int = 0
	var d_notarget: int = 0
	for dr in drows:
		if int(dr["oid"]) == -1:
			d_notarget += 1          # ★連目標都沒有（★★它既不是「沒碰到」也不是「碰到沒打」，自成一格）
		elif not bool(dr["met"]):
			d_nomeet += 1
		elif bool(dr["fought"]):
			d_met_fight += 1
		else:
			d_met_nofight += 1
	var d_tot: int = drows.size()
	print("")
	print("★★★迎戰三格（母體＝迎戰 episode %d 段；★互斥且窮盡 ⇒ 相加必須等於母體）：" % d_tot)
	print("   ①沒有目標        %5d" % d_notarget)
	print("   ②沒有碰到面      %5d   ★這是【相遇機制】的那一側" % d_nomeet)
	print("   ③碰到了但沒開打  %5d   ★★這是【決策】的那一側" % d_met_nofight)
	print("   ④碰到且開打      %5d" % d_met_fight)
	print("   對帳：%d + %d + %d + %d = %d vs 母體 %d ⇒ %s" % [
		d_notarget, d_nomeet, d_met_nofight, d_met_fight,
		d_notarget + d_nomeet + d_met_nofight + d_met_fight, d_tot,
		"OK" if d_notarget + d_nomeet + d_met_nofight + d_met_fight == d_tot else "★不符"])
	var _sw: int = 0
	for dr2 in drows: _sw += int(dr2.get("switches", 0))
	# ★★★systems 的第四種可能：**碰到了、但那一刻根本沒有人在做決策** ⇒ 開門也用不到
	var _met_n: int = 0
	var _met_zero_rank: int = 0
	for dr3 in drows:
		if not bool(dr3["met"]): continue
		_met_n += 1
		if int(dr3.get("ranks_after_met", -1)) <= 0: _met_zero_rank += 1
	print("   ★★★★碰到面之後【有沒有人在思考】：碰到面 %d 段，其中**碰面後一次決策都沒跑 %d 段**（%.1f%%）" % [
		_met_n, _met_zero_rank, 100.0 * float(_met_zero_rank) / maxf(float(_met_n), 1.0)])
	var _same_tick_yes: int = 0
	var _hour_zero: int = 0
	var _hour_n: int = 0
	for dr4 in drows:
		if not bool(dr4["met"]): continue
		if int(dr4.get("rank_same_tick", -1)) > 0: _same_tick_yes += 1
		var _rh: int = int(dr4.get("rank_hour", -1))
		if _rh >= 0:
			_hour_n += 1
			if _rh == 0: _hour_zero += 1
	print("      ★★兩個數（systems 要的）：①碰到面的【那一 tick】有跑決策 %d／%d 段" % [_same_tick_yes, _met_n])
	print("         ②碰面後【一個遊戲小時】內一次都沒跑：%d／%d 段（★母體＝活過那一小時的段）" % [
		_hour_zero, _hour_n])
	print("         ★★★相遇【一天幾次】：總 %d 對·tick（★同一對連續 tick 會重複計 ＝ 喚醒風暴的分子）" % int(Probe.counts.get("encounter.pair_calls", 0)))
	var ept: Array = enc_per_tick.duplicate()
	ept.sort()
	if not ept.is_empty():
		print("            一個 tick 幾次：p50=%d p95=%d max=%d（母體＝%d tick）" % [
			int(ept[ept.size() / 2]), int(ept[int(float(ept.size()) * 0.95)]),
			int(ept[ept.size() - 1]), ept.size()])
	var _buck: Dictionary = {}
	for kb2 in Probe.counts:
		var ksb2: String = String(kb2)
		if ksb2.begins_with("encounter.armed.") or ksb2.begins_with("encounter.sizegap.") 				or ksb2.begins_with("encounter.approach.") or ksb2.begins_with("encounter.analysis."):
			_buck[ksb2.replace("encounter.", "")] = int(Probe.counts[kb2])
	print("            ★分桶（★★外觀層三欄 ＝ 過濾器【可以】用的；`analysis.*` ＝ 只給我們看的分析欄，")
	print("              ★★★過濾器【不准】用它，因為它要讀關係／意圖）：%s" % str(_buck))
	print("            ★★★`analysis.hostile.*` 有三格（both／one_way／neither）—— ★而【單向敵意】那一格")
	print("              只有在逐向記的時候才會出現：**敵對不是對稱事實，是每一支隊各自的判斷**")
	print("            ★而過濾器的形狀是【預設醒、具名靜】⇒ 上面的桶讀作『這種相遇【可以被靜音】』，")
	print("              **不是**『這種才喚醒』—— 兩者在 code 上差一個 not，在世界上差很多")
	var _days: float = float(ticks) / float(WorldState.TICKS_PER_DAY)
	print("            ⇒ 每日 %.1f 對·tick（母體＝%.0f 天）" % [
		float(Probe.counts.get("encounter.pair_calls", 0)) / maxf(_days, 1.0), _days])
	print("      ★這一格答 systems 的第四種可能：**開門也用不到，因為沒人有機會用那個提名**")
	print("      ★★而『相遇不發事件』是窮盡 grep 查的：`WorldEvents.emit(` 全庫 16 個呼叫點，無一是相遇")
	print("   ★★★『736 → 1』分不出的兩種世界，就是②與③ —— 而它們的處置完全不同")
	print("   ★切段鍵 ＝【連續持有 TASK_DEFEND 的一段】（不是目標 id）⇒ 欄位抖動不會切段")
	print("   ★★段內【目標換人】次數合計 %d —— ★★★若它很大，表示一段裡其實追過好幾個對象" % _sw)
	# ── ★面對面卻沒人動手：逐筆 per-option util（systems 2026-09-12）──
	var fo: Array = Probe.samples.get("faceoff", [])
	var fo_win: Dictionary = {}
	for kf in Probe.counts:
		var ksf: String = String(kf)
		if ksf.begins_with("faceoff.winner."):
			fo_win[ksf.replace("faceoff.winner.", "")] = int(Probe.counts[kf])
	print("")
	print("★★★面對面現場（母體＝迎戰姿態 ＋ 目標還活著 ＋ 同格的【決策時刻】共 %d 次；樣本上限 150，實收 %d）" % [
		int(Probe.counts.get("faceoff.total", 0)), fo.size()])
	print("   贏家分佈：%s" % str(fo_win))
	# ★★★三個桶（互斥且窮盡、對帳；★沒有「其他」桶）
	var _b3: int = int(Probe.counts.get("faceoff.atk_absent", 0))      # ③攻擊根本不可選
	var _listed: int = int(Probe.counts.get("faceoff.atk_listed", 0))
	var _b2: int = int(Probe.counts.get("faceoff.winner.攻擊", 0))     # ②秤選了攻擊（沒開打由上游四格接）
	var _b1: int = _listed - _b2                                       # ①可選而秤選了別的
	var _tot3: int = _b1 + _b2 + _b3
	print("   ★★★三個桶：①攻擊可選而秤選別的 %d｜②秤選了攻擊 %d｜③攻擊根本不可選 %d" % [_b1, _b2, _b3])
	print("      對帳：%d + %d + %d = %d vs 母體 %d ⇒ %s" % [_b1, _b2, _b3, _tot3,
		int(Probe.counts.get("faceoff.total", 0)),
		"OK" if _tot3 == int(Probe.counts.get("faceoff.total", 0)) else "★不符"])
	var _gates: Dictionary = {}
	for kg in Probe.counts:
		var ksg: String = String(kg)
		if ksg.begins_with("faceoff.gate."):
			_gates[ksg.replace("faceoff.gate.", "")] = int(Probe.counts[kg])
	print("   ★③那一桶的三道門（可讀的那一半）：%s" % str(_gates))
	print("      ★★門的另一半（target 存不存在）本卷【沒有評】—— 它要 gather，而那會岔 RNG")
	print("   ★★三種世界：**贏的是攻擊/迎戰卻沒打成**（派不出去）／**贏的是別的**（壓根沒在想打）／")
	print("     **打不贏所以不打**（util 低）—— ★贏家分佈先把第二種分出來")
	for rf in fo.slice(0, 25):
		print("   tick=%d team=%d(pop%d rdy%.2f) vs %d(pop%d rdy%.2f) 贏=%s ｜ top5=%s" % [
			int(rf["tick"]), int(rf["team"]), int(rf["my_pop"]), float(rf["my_ready"]),
			int(rf["target"]), int(rf["their_pop"]), float(rf["their_ready"]),
			String(rf["winner"]), str(rf["top5"])])
	if fo.is_empty():
		print("   ★（0 筆 ⇒ 本窗沒有任何【同格對峙的決策時刻】—— ★★而那與「有對峙但沒打」是兩件事）")
	print("")
	print("★逐筆（全收）：")
	for r2 in rows:
		print("   team=%d 起 tick=%d 目標=%d 同派系=%s reason=%s 起算距離=%d｜到格=%s 相遇=%s 送達=%s 出口=%s%s" % [
			int(r2["team"]), int(r2["start"]), int(r2["oid"]), str(r2["same_faction"]),
			String(r2["reason"]), int(r2["dist0"]), str(r2["at_cell"]), str(r2["met"]),
			str(r2["delivered"]), String(r2["exit"]), "　★窗末未完" if bool(r2["cut"]) else ""])
	print("")
	print("★誠實限：①出口桶取自 arbiter 自己的分支計數（same_level／higher／defy／release／transition），")
	print("   ★★『個位數不判方向』——本卷只報數、不報趨勢；②窗末未完單獨一類；")
	print("   ★★★③負斷言只能被逐筆【推翻】，一致不等於證明（可能只是本窗沒發生）")
	print("★>2 秒幀數 = %d / %d" % [SimRunner.frames_over_budget, SimRunner.frames_total])
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	print("[TEST-SUITE-COMPLETE]")

func _close_defend(ep: Dictionary, st: WorldState, drows: Array) -> void:
	var tid: int = int(ep["team"])
	var fought: bool = int(Probe.counts.get("combat.entered.t%d" % tid, 0)) > int(ep["fight0"])
	if fought:
		ep["met"] = true   # ★開打必經相遇（同信使那條：門鈴只有一條路）⇒ 取樣看不到最後一刻
	var _ranks_after_met: int = -1
	if int(ep.get("rank_at_met", -1)) >= 0:
		_ranks_after_met = int(Probe.counts.get("engine.rank.t%d" % tid, 0)) - int(ep["rank_at_met"])
	drows.append({"team": tid, "oid": int(ep["oid"]), "start": int(ep["start"]),
		"met": bool(ep["met"]), "fought": fought, "switches": int(ep.get("target_switches", 0)),
		"ranks_after_met": _ranks_after_met, "rank_same_tick": int(ep.get("rank_same_tick", -1)),
		"rank_hour": int(ep.get("rank_hour", -1))})

func _open_n(groups: Dictionary) -> int:
	return (groups["open_far"] as Array).size() + (groups["open_mid"] as Array).size() 		+ (groups["open_near"] as Array).size()

func _lost_of(tid: int) -> Dictionary:
	var out: Dictionary = {}
	for b in ["same_level", "higher", "defy", "release", "transition"]:
		out[b] = int(Probe.counts.get("lost.t%d.%s.%s" % [tid, TeamData.TASK_HERALD, b], 0))
	return out

func _close(ep: Dictionary, st: WorldState, rows: Array, cut: bool) -> void:
	var tid: int = int(ep["team"])
	var delivered: bool = int(Probe.counts.get("task.done.t%d.%s" % [tid, TeamData.TASK_HERALD], 0)) > int(ep["done0"])
	# ★出口＝這一段結束時，arbiter 的哪一個分支動了（★由 arbiter 自己的計數決定，不是我判的）
	var exit_kind: String = "窗末未完" if cut else "未知"
	if not cut:
		var before: Dictionary = ep["lost0"]
		var now: Dictionary = _lost_of(tid)
		for b in ["same_level", "higher", "defy", "release", "transition"]:
			if int(now[b]) > int(before[b]):
				exit_kind = b if exit_kind == "未知" else exit_kind + "+" + b
	if delivered and not cut:
		exit_kind = "送達後" + ("（" + exit_kind + "）" if exit_kind != "未知" else "")
	# ★★★儀器限（本輪自己抓到）：第一版量到【送達 9 而相遇只有 2】—— ★送達必經相遇（門鈴只有那一條路）
	#   ⇒ 差額不是世界，是**我的取樣看不到最後那一刻**：送達當下任務被 release ⇒ 下一次掃描時它已經不是信使
	#   ⇒ ★★與求居案「抵達即失去身分」同族 ⇒ **送達 ⇒ 相遇必為真**（由機制推得，不是我補洞）。
	if delivered:
		ep["met"] = true
	rows.append({"team": tid, "start": int(ep["start"]), "oid": int(ep["oid"]),
		"same_faction": bool(ep["same_faction"]), "reason": String(ep["reason"]),
		"dist0": int(ep["dist0"]), "at_cell": bool(ep["at_cell"]), "met": bool(ep["met"]),
		"delivered": delivered, "exit": exit_kind, "cut": cut})
