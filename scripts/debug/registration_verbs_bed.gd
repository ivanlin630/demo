extends SceneTree
# @bed-kind: acceptance
# slice: ④b 登記動詞（收留／求居／據點滅→流離）
#
# ★★★這張票的成功判準【不是動詞能用】，是【跑完自然窗後世界裡真的有房客】。
#   ★母體必須來自**預設 config** —— 禁調參數／改初始佈局／加特製 config。
#   ★★跑不出來 ⇒ **就是紅**，而紅的意思是「動詞沒有真的接上世界」。
# env：RV_TICKS（預設 8640 ＝ 6 遊戲天）／RV_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("RV_TICKS")) if OS.has_environment("RV_TICKS") else 8640
	var cfg: String = OS.get_environment("RV_CONFIG") if OS.has_environment("RV_CONFIG") else "warring_states"
	print("=== ④b 登記動詞（%d tick ＝ %.1f 遊戲天，%s，seed=%s，★預設 config 未改）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg,
		OS.get_environment("RV_SEED") if OS.has_environment("RV_SEED") else "4242"])
	# ★★★窗長是這張票的前提之一：★昨天的普查（seed 1337、快照 day 10/20/30/45/60）量到
	#   PRODUCE 隊數 6 → 14 → 22 ⇒ **生產隊是【長出來的】** ⇒ 6 天的窗在它們出生【之前】。
	seed(int(OS.get_environment("RV_SEED")) if OS.has_environment("RV_SEED") else 4242)
	var st := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	# ★★★逐筆追蹤（systems 要兩張表，不要聚合）：每 tick 掃一次「誰在求居」
	#   ★成本：隊數×tick（~100×43200）＝ 純讀欄位，零寫入 ⇒ 觀測不改世界
	#   ★★結束狀態要逐字分類，而「**還在路上被窗切掉**」自成一類（★它不是失敗，是窗太短）
	var track: Dictionary = {}      # team_id → {start, last, host, host_pos}
	var rows: Array = []            # 表一：逐筆去向
	var arrivals: Array = []        # 表二：抵達時的狀態
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
		var seen: Dictionary = {}
		for tid0 in st.teams:
			var t0: TeamData = st.teams[tid0]
			if t0.current_task != TeamData.TASK_SEEK_HOME:
				continue
			seen[int(tid0)] = true
			if not track.has(int(tid0)):
				track[int(tid0)] = {"start": st.world.current_tick, "last": st.world.current_tick,
					"host": t0.order_target_id, "host_pos": t0.move_target}
			else:
				(track[int(tid0)] as Dictionary)["last"] = st.world.current_tick
				if t0.move_target != Vector2i(-1, -1):
					(track[int(tid0)] as Dictionary)["host_pos"] = t0.move_target
		# 離開求居狀態的 ⇒ 結案並逐字分類
		for tid1 in track.keys():
			if seen.has(int(tid1)):
				continue
			var rec: Dictionary = track[int(tid1)]
			var t1: TeamData = st.teams.get(int(tid1))
			var hp: Vector2i = rec.get("host_pos", Vector2i(-1, -1))
			var ht: HexTileData = st.world.tiles.get(hp.x * 1000 + hp.y) if hp != Vector2i(-1, -1) else null
			var why: String = ""
			if t1 == null:
				why = "隊沒了(滅團/合併)"
			elif ht == null or ht.outpost_level <= 0:
				why = "目標據點消失"
			elif t1.tile_pos == hp:
				why = "走到了"
				arrivals.append({"team": int(tid1), "tick": st.world.current_tick,
					"task_at_arrival": t1.current_task, "opt": t1.current_option,
					"registered": st.registered_at(t1, hp),
					"host_owner": ht.outpost_owner})
			else:
				why = "改去做別的:" + String(t1.current_task)
			rows.append({"team": int(tid1), "start": int(rec["start"]), "last": int(rec["last"]),
				"end": why})
			track.erase(int(tid1))
	# 窗結束時還在路上的 ⇒ 單獨一類（★不是失敗）
	for tid2 in track.keys():
		var rec2: Dictionary = track[int(tid2)]
		rows.append({"team": int(tid2), "start": int(rec2["start"]), "last": int(rec2["last"]),
			"end": "★還在路上被窗切掉"})

	# ①母體：登記在【別人村裡】的隊（★印數量與是哪幾隊）
	var lodgers: Array = []
	var residents: int = 0
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if not st.is_registered_resident(t):
			continue
		residents += 1
		var wt: HexTileData = st.world.tiles.get(t.work_outpost.x * 1000 + t.work_outpost.y)
		if wt != null and wt.outpost_owner != t.team_id:
			lodgers.append("Team%d@(%d,%d)owner=%d%s" % [t.team_id, t.work_outpost.x, t.work_outpost.y,
				wt.outpost_owner, "同faction" if wt.outpost_owner != -1 and st.teams.has(wt.outpost_owner) \
					and (st.teams[wt.outpost_owner] as TeamData).faction_id == t.faction_id and t.faction_id != -1 else "跨/無faction"])
	print("")
	print("★①母體：居民 %d 支／**房客 %d 支** %s" % [residents, lodgers.size(),
		"⇒ " + str(lodgers) if not lodgers.is_empty() else "⇒ ★★★紅：動詞沒有真的接上世界"])
	# ★★★房客是【怎麼】登記的（stub／動詞／遷移在結果上長得一樣 ⇒ 必須分開追）
	var stub_teams: Dictionary = {}
	for d in Probe.samples.get("registry.src.stub", []):
		stub_teams[int(d.get("team", -1))] = true
	var verb_teams: Dictionary = {}
	for d2 in Probe.samples.get("registry.verb.shelter", []):
		verb_teams[int(d2.get("guest", -1))] = true
	var src_lines: Array = []
	for tid5 in st.teams:
		var t5: TeamData = st.teams[tid5]
		if not st.is_registered_resident(t5):
			continue
		var src: String = "★來源不明（遷移或其他）"
		if verb_teams.has(int(tid5)):
			src = "收留動詞"
		elif stub_teams.has(int(tid5)):
			src = "stub"
		src_lines.append("Team%d←%s" % [int(tid5), src])
	print("★①-b 登記來源逐隊：%s" % str(src_lines))
	# ②stub 是否被真動詞接管
	print("★②stub %d 次／收留動詞 %d 次（同 faction %d／跨 faction %d）／流離 %d 次" % [
		int(Probe.counts.get("registry.auto_register_stub", 0)),
		int(Probe.counts.get("registry.verb.shelter", 0)),
		int(Probe.counts.get("registry.verb.shelter.same_faction", 0)),
		int(Probe.counts.get("registry.verb.shelter.cross_faction", 0)),
		int(Probe.counts.get("registry.verb.displaced", 0))])
	# ③秤在競爭池裡：收留／求居的候選與勝負（★不是只記 win）
	print("★③收留：候選 %d 次／贏 %d 次｜求居：候選 %d 次／贏 %d 次" % [
		int(Probe.counts.get("decision.opt_applicable.收留", 0)),
		int(Probe.counts.get("optpool.win.收留", 0)),
		int(Probe.counts.get("decision.opt_applicable.求居", 0)),
		int(Probe.counts.get("optpool.win.求居", 0))])
	# ★★★「候選了卻從不贏」的兩個成因（★總數答不出來）：(a) drive ≈0 (b) drive 不低但被壓過
	var comps: Array = Probe.samples.get("shelter.drive_components", [])
	if comps.is_empty():
		print("★③-b 收留 drive 成分：**不可判**（0 筆樣本 ⇒ 那一格根本沒被算過）")
	else:
		var zero_drive: int = 0
		var sum_drive: float = 0.0
		var max_drive: float = 0.0
		for cd in comps:
			var dv: float = float(cd.get("drive", 0.0))
			sum_drive += dv
			max_drive = maxf(max_drive, dv)
			if dv <= 0.001:
				zero_drive += 1
		print("★③-b 收留 drive 成分（樣本 %d 筆，first-N cap 100）：drive≈0 的 %d 筆（%.1f%%）／平均 %.3f／最大 %.3f" % [
			comps.size(), zero_drive, 100.0 * float(zero_drive) / float(comps.size()),
			sum_drive / float(comps.size()), max_drive])
		print("   ★前 3 筆：%s" % str(comps.slice(0, 3)))
	# ★★★兩半分開數：求居（流浪隊主動去問）vs 收留（領主答應）
	var seek_disp: int = int(Probe.counts.get("registry.verb.seek_dispatch", 0))
	var present: int = int(Probe.counts.get("shelter.seeker_present", 0))
	var tasks: Array = []
	for k7 in Probe.counts:
		var ks7: String = String(k7)
		if ks7.begins_with("shelter.seeker_task."):
			tasks.append("%s×%d" % [ks7.replace("shelter.seeker_task.", ""), int(Probe.counts[k7])])
	tasks.sort()
	print("★③-e 兩半：求居**真的被派出** %d 次｜領主看到有人上門 %d 次｜上門者當下的 task：%s" % [
		seek_disp, present, str(tasks) if not tasks.is_empty() else "（無）"])
	var pre: Array = []
	for k8 in Probe.counts:
		var ks8: String = String(k8)
		if ks8.begins_with("seek.preempt_attempt."):
			pre.append("%s×%d" % [ks8.replace("seek.preempt_attempt.", ""), int(Probe.counts[k8])])
	pre.sort()
	print("   ★③-f 求居的下場：**真的走到** %d 次｜半路被別的 task 搶（try_set 嘗試）：%s" % [
		int(Probe.counts.get("seek.arrived", 0)), str(pre) if not pre.is_empty() else "（無）"])
	print("   ★★★若求居 dispatch ＝ 0 ⇒ 「領主沒空收人」那個結論是在**錯的那一端**下的")
	# ★★★收留輸給誰（★同 tick 同隊並排；★★逐 option 統計，不是平均）
	var sbs: Array = Probe.samples.get("shelter.side_by_side", [])
	if sbs.is_empty():
		print("★③-c 收留輸給誰：**不可判**（0 筆並排樣本）")
	else:
		var lost: Array = []
		for k6 in Probe.counts:
			var ks6: String = String(k6)
			if ks6.begins_with("shelter.lost_to."):
				lost.append("%s×%d" % [ks6.replace("shelter.lost_to.", ""), int(Probe.counts[k6])])
		lost.sort()
		var ranks: Array = []
		for r6 in range(1, 10):
			var rc: int = int(Probe.counts.get("shelter.rank.%d" % r6, 0))
			if rc > 0:
				ranks.append("第%d名×%d" % [r6, rc])
		print("★③-c 收留：贏 %d 次｜名次分布 %s" % [int(Probe.counts.get("shelter.won", 0)), str(ranks)])
		print("   ★輸給誰：%s" % str(lost))
		print("   ★★並排樣本（前 3，同 tick 同隊）：%s" % str(sbs.slice(0, 3)))
	# ★★★組成：drive → weight → coeff → failure → 末端（★哪一步掉最多，答案就在那一步）
	var cmp_n: int = int(Probe.counts.get("shelter.cmp.n", 0))
	if cmp_n == 0:
		print("★③-d 收留 util 組成：**不可判**（0 筆 ⇒ 它連被算過都沒有）")
	elif cmp_n < 10:
		print("★③-d 收留 util 組成：★★樣本太小（%d 筆 < 10）—— ★而「它連被考慮的機會都很少」本身是另一種病" % cmp_n)
	else:
		var n_f: float = float(cmp_n)
		print("★③-d 收留 util 組成（母體 %d 筆，只在它 applicable 的時刻）：" % cmp_n)
		print("   drive %.3f → ×weight → %.3f → ×coeff → %.3f → ×failure → 末端 %.3f" % [
			Probe.amount("shelter.cmp.drive_sum") / n_f,
			Probe.amount("shelter.cmp.after_weight_sum") / n_f,
			Probe.amount("shelter.cmp.after_coeff_sum") / n_f,
			Probe.amount("shelter.cmp.final_sum") / n_f])
		print("   ★逐筆前 3：%s" % str(Probe.samples.get("shelter.composition", []).slice(0, 3)))
	# ⑥一隊一登記（動詞上線後重驗）
	var multi: int = 0
	for tid in st.teams:
		var t2: TeamData = st.teams[tid]
		if t2.work_outpost != Vector2i(-1, -1):
			var wt2: HexTileData = st.world.tiles.get(t2.work_outpost.x * 1000 + t2.work_outpost.y)
			if wt2 == null or wt2.outpost_level <= 0:
				multi += 1   # ★登記指向一個不存在的據點 ＝ 流離沒清乾淨
	print("★⑥一隊一登記：欄位是單值 ⇒ 結構上保證；★而【指向已消失據點】的殘留 = %d 支" % multi)
	# ★★★母體為 0 時要答的是【為什麼】—— 三個前置各自的數字（★不是只說「沒有發生」）
	var produce_n: int = 0
	var produce_homeless: int = 0
	var homeless_with_known_host: int = 0
	var outposts_n: int = 0
	for tid3 in st.world.tiles:
		var tl: HexTileData = st.world.tiles[tid3]
		if tl.outpost_level > 0 and tl.outpost_owner != -1:
			outposts_n += 1
	for tid4 in st.teams:
		var t4: TeamData = st.teams[tid4]
		if t4.beast_kind != "" or not t4.tags.has(TeamData.TAG_PRODUCE):
			continue
		produce_n += 1
		if st.own_outpost_tile(t4.team_id) != null:
			continue
		produce_homeless += 1
		var known: Dictionary = st.team_tile_known.get(t4.team_id, {})
		for ktid in known:
			var kt: HexTileData = st.world.tiles.get(int(ktid))
			if kt != null and kt.outpost_level > 0 and kt.outpost_owner != -1 and kt.outpost_owner != t4.team_id:
				homeless_with_known_host += 1
				break
	print("★★母體拆解：世界上有主據點 %d 個｜PRODUCE 隊 %d 支｜其中【無自家據點】%d 支｜其中【知道別人據點】%d 支" % [
		outposts_n, produce_n, produce_homeless, homeless_with_known_host])
	print("   ⇒ ★求居的前置鏈是：PRODUCE ∧ 無自家據點 ∧ 知道一個別人的據點 —— 上面四個數字說明它斷在哪一節")
	# ★★★漏斗（blueprint 要的形狀：逐站相減、每站印剩幾支）——★而它與逐筆表答的是不同問題：
	#   逐筆答「這一支發生了什麼」／漏斗答「在哪一站掉最多」（★★只有漏斗能跟本庫先前那幾條鏈比）
	#   ★★★單位不同不可相減（今天的常犯病）⇒ **分兩段印，並在每一段標單位**。
	var arrived_rows: int = 0
	var still_seeking_at_arrival: int = 0
	for a0 in arrivals:
		arrived_rows += 1
		if String(a0["task_at_arrival"]) == TeamData.TASK_SEEK_HOME:
			still_seeking_at_arrival += 1
	var st_produce: int = 0
	var st_homeless: int = 0
	var st_known: int = 0
	for tid7 in st.teams:
		var t7: TeamData = st.teams[tid7]
		if t7.beast_kind != "" or not t7.tags.has(TeamData.TAG_PRODUCE):
			continue
		st_produce += 1
		if st.own_outpost_tile(t7.team_id) != null:
			continue
		st_homeless += 1
		var kn: Dictionary = st.team_tile_known.get(t7.team_id, {})
		for kt0 in kn:
			var ktl: HexTileData = st.world.tiles.get(int(kt0))
			if ktl != null and ktl.outpost_level > 0 and ktl.outpost_owner != -1 and ktl.outpost_owner != t7.team_id:
				st_known += 1
				break
	print("")
	print("★漏斗Ａ【單位：支】—— 窗末快照（★不可與下面的『次』相減）")
	print("   ①PRODUCE 隊        %4d" % st_produce)
	print("   ②其中無自家據點     %4d   （−%d）" % [st_homeless, st_produce - st_homeless])
	print("   ③其中知道別人據點   %4d   （−%d）" % [st_known, st_homeless - st_known])
	var f_cand: int = int(Probe.counts.get("optpool.cand.求居", 0))
	var f_win: int = int(Probe.counts.get("optpool.win.求居", 0))
	var f_disp: int = int(Probe.counts.get("registry.verb.seek_dispatch", 0))
	var f_arr: int = int(Probe.counts.get("seek.arrived", 0))
	var f_seen: int = int(Probe.counts.get("shelter.seeker_task." + TeamData.TASK_SEEK_HOME, 0))
	var f_shwin: int = int(Probe.counts.get("shelter.won", 0))
	var f_reg: int = int(Probe.counts.get("registry.verb.shelter", 0))
	print("★★漏斗Ｂ【單位：次】—— 事件計數（★逐站相減）")
	print("   ①求居進候選        %5d" % f_cand)
	print("   ②求居贏 argmax     %5d   （−%d）" % [f_win, f_cand - f_win])
	var f_ok: int = int(Probe.counts.get("seek.try_set.ok", 0))
	var f_noop: int = int(Probe.counts.get("seek.try_set.noop", 0))
	var blocked: Array = []
	for kb in Probe.counts:
		var ksb: String = String(kb)
		if ksb.begins_with("seek.try_set.blocked_by."):
			blocked.append("%s×%d" % [ksb.replace("seek.try_set.blocked_by.", ""), int(Probe.counts[kb])])
	blocked.sort()
	print("   ③決策說要派出      %5d   （−%d）" % [f_disp, f_win - f_disp])
	print("   ③-b `try_set` 成功 %5d   （−%d ＝ noop %d；被誰擋：%s）★★這一站是逐筆表揭出來的" % [
		f_ok, f_noop, f_noop, str(blocked) if not blocked.is_empty() else "（無）"])
	print("   ④真的走到          %5d   （−%d）★★最大的一站" % [f_arr, f_disp - f_arr])
	print("   ⑤抵達時仍是求居者  %5d   （−%d，逐筆表二）" % [still_seeking_at_arrival, maxi(f_arr - still_seeking_at_arrival, 0)])
	print("   ⑥領主看到求居者    %5d   （−%d）" % [f_seen, maxi(still_seeking_at_arrival - f_seen, 0)])
	print("   ⑦收留贏 argmax     %5d   （−%d）" % [f_shwin, maxi(f_seen - f_shwin, 0)])
	print("   ⑧真的登記          %5d   （−%d）" % [f_reg, maxi(f_shwin - f_reg, 0)])
	# ★★★表一：那些求居的去向（逐筆）
	var by_end: Dictionary = {}
	for r in rows:
		var k9: String = String(r["end"]).split(":")[0]
		by_end[k9] = int(by_end.get(k9, 0)) + 1
	print("")
	print("★表一：求居【逐筆去向】共 %d 筆（窗 %d tick／%.1f 遊戲天／seed %s／%s）" % [
		rows.size(), ticks, float(ticks) / float(WorldState.TICKS_PER_DAY),
		OS.get_environment("RV_SEED") if OS.has_environment("RV_SEED") else "4242", cfg])
	print("   結束狀態彙總：%s" % str(by_end))
	for r2 in rows.slice(0, 12):
		print("   team=%d 出發 tick=%d 最後仍求居 tick=%d 結束＝%s" % [
			int(r2["team"]), int(r2["start"]), int(r2["last"]), String(r2["end"])])
	if rows.size() > 12:
		print("   …（其餘 %d 筆同格式，逐筆在 samples 裡）" % (rows.size() - 12))
	# ★★★表二：抵達時的狀態（★身分是在哪一步掉的）
	print("")
	print("★表二：抵達時的狀態 共 %d 筆" % arrivals.size())
	for a in arrivals:
		print("   team=%d 抵達 tick=%d task=%s option=%s 已登記=%s host_owner=%d" % [
			int(a["team"]), int(a["tick"]), String(a["task_at_arrival"]), String(a["opt"]),
			str(a["registered"]), int(a["host_owner"])])
	if arrivals.is_empty():
		print("   ★（0 筆 ⇒ 本窗沒有任何求居者走到 —— ★★而那與「走到了但沒被看見」是兩件事）")
	print("★⑧>2 秒的幀數 = **%d / %d**（★終線是這個計數歸零，不是平均變好）" % [
		SimRunner.frames_over_budget, SimRunner.frames_total])
	print("★⑦fp=%s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % (0 if not lodgers.is_empty() else 1))
	quit(0 if not lodgers.is_empty() else 1)
