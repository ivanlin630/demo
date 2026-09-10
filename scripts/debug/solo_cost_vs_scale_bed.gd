extends SceneTree
# ★★★作廢公告（2026-09-10）：本床讀的 `solo.engine`／`solo.cheap`／`loop2.solo_*` 四個量，
#   在 `faction_ai_system.gd` 的非 unified solo 路【設旗修正】之前**一直是錯的**：
#   那條路真的跑了引擎卻被歸進 cheap 桶 ⇒ ★本床在該修正之前產出的任何
#   「每隊 X us／早退 vs 跑引擎」結論**全部作廢**，必須重跑。
#   ⇒ ★★而這行留在這裡的理由：作廢公告要貼在【產出它的工具】上，
#     ★★★否則下一個人會拿舊結論當基準，而舊結論看起來完全正常。
# @bed-kind: diagnostic
# slice: solo 思考的【每隊成本 × 規模】三個點（systems 2026-09-10 要的那三格）
#
# ★問題：我 N=17 的量測說 solo 每隊 0.031 ms；量測員在 N=135 的世界說 loop2.solo 佔 spike 52.7%。
#   ⇒ ★★兩份數據不矛盾 —— 它們量的是兩個規模。而處置取決於【成本怎麼隨 N 長】：
#      常數／線性 ⇒ solo 不是 26 秒的成因；★★★超線性（例如逐隊掃 discovered）⇒ 它就是。
# ⇒ 本床用【既有的 phase timing】(_fai_ph["loop2.solo"]) 量，★不另外呼叫 _evaluate_solo
#   （★★那會改變世界 —— 觀測不得改變被觀測物）。
# env：SCB_TICKS（預設 20000 ＝ 13.9 遊戲天）／SCB_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("SCB_TICKS")) if OS.has_environment("SCB_TICKS") else 20000
	var cfg: String = OS.get_environment("SCB_CONFIG") if OS.has_environment("SCB_CONFIG") else "warring_states"
	print("=== solo 成本 × 規模（%d tick ＝ %.1f 遊戲天，%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	SimRunner.phase_timing = true
	var runner := SimRunner.new()
	# N 分桶 → [每隊 us…]
	var buckets: Dictionary = {}
	var eng_bucket: Dictionary = {}
	var chp_bucket: Dictionary = {}
	var _prev_eng: int = 0
	var _prev_chp: int = 0
	var _tot_eng: int = 0
	var _tot_chp: int = 0
	var _eng_per_tick: Array = []
	var _cad_hist: Dictionary = {}
	Probe.arm()
	for i in range(ticks):
		FactionAISystem._fai_ph.clear()
		var before: Dictionary = {}
		for tid in st.teams:
			before[tid] = (st.teams[tid] as TeamData).solo_think_last_tick
		runner.advance_tick(st, Vector2i(-1, -1))
		var x: int = 0
		var n_elig: int = 0
		for tid2 in st.teams:
			var t: TeamData = st.teams[tid2]
			if t.beast_kind == "" and t.parent_team_id == -1 and t.faction_id == -1:
				n_elig += 1
			if t.solo_think_last_tick != int(before.get(tid2, 0)):
				x += 1
		var us: int = int(FactionAISystem._fai_ph.get("loop2.solo", 0))
		# ★★★兩群分開（systems 2026-09-10）：平均值把【早退】與【真的跑引擎】混成一個數
		#   ⇒ 「每隊 21 us」誰都不是。這裡分別取：跑引擎那群的每次成本／早退那群的每次成本。
		var eng_us: int = int(FactionAISystem._fai_ph.get("loop2.solo_engine", 0))
		var chp_us: int = int(FactionAISystem._fai_ph.get("loop2.solo_cheap", 0))
		var eng_n: int = int(Probe.counts.get("solo.engine", 0)) - _prev_eng
		var chp_n: int = int(Probe.counts.get("solo.cheap", 0)) - _prev_chp
		_prev_eng = int(Probe.counts.get("solo.engine", 0))
		_prev_chp = int(Probe.counts.get("solo.cheap", 0))
		if eng_n > 0:
			if not eng_bucket.has((n_elig / 10) * 10):
				eng_bucket[(n_elig / 10) * 10] = []
			(eng_bucket[(n_elig / 10) * 10] as Array).append(float(eng_us) / float(eng_n))
		if chp_n > 0:
			if not chp_bucket.has((n_elig / 10) * 10):
				chp_bucket[(n_elig / 10) * 10] = []
			(chp_bucket[(n_elig / 10) * 10] as Array).append(float(chp_us) / float(chp_n))
		_tot_eng += eng_n
		_tot_chp += chp_n
		# ★★★③到期時刻分布：真的跑進引擎的隊，落在 DECISION_CADENCE 週期的哪一段？
		#   ⇒ 若【每 3 天一大批同時到期】，主詞就找到了（而修法與錯開票同形）。
		if eng_n > 0:
			_eng_per_tick.append(eng_n)
			var phase_b: int = int((st.world.current_tick % 4320) / 432)   # 3 遊戲日切 10 段
			_cad_hist[phase_b] = int(_cad_hist.get(phase_b, 0)) + eng_n
		if x <= 0 or us <= 0:
			continue
		var bucket: int = (n_elig / 10) * 10   # N 以 10 為一桶
		if not buckets.has(bucket):
			buckets[bucket] = []
		(buckets[bucket] as Array).append(float(us) / float(x))
	var ks: Array = buckets.keys()
	ks.sort()
	print("N 桶      樣本   每隊 solo 成本中位(us)")
	var pts: Array = []
	for k in ks:
		var arr: Array = buckets[k]
		arr.sort()
		var med: float = float(arr[arr.size() / 2])
		pts.append([int(k), med, arr.size()])
		print("  %3d-%3d  %5d   %8.1f" % [int(k), int(k) + 9, arr.size(), med])
	# ★★兩群各自的成本（systems 要的那一格）
	print("")
	print("★★兩群分開：進入 _evaluate_solo 共 %d 次｜其中【真的跑引擎】%d 次（%.1f%%）｜早退 %d 次" % [
		_tot_eng + _tot_chp, _tot_eng,
		100.0 * float(_tot_eng) / maxf(1.0, float(_tot_eng + _tot_chp)), _tot_chp])
	print("★早退卡在哪一關：player=%d｜交戰中=%d｜無領袖=%d｜cadence(3 遊戲日)=%d" % [
		int(Probe.counts.get("solo.exit.player", 0)), int(Probe.counts.get("solo.exit.in_combat", 0)),
		int(Probe.counts.get("solo.exit.no_leader", 0)), int(Probe.counts.get("solo.exit.cadence", 0))])
	var _acc: int = int(Probe.counts.get("solo.exit.player", 0)) + int(Probe.counts.get("solo.exit.in_combat", 0)) 		+ int(Probe.counts.get("solo.exit.no_leader", 0)) + int(Probe.counts.get("solo.exit.cadence", 0))
	print("★★未歸類 %d 次（進入 %d − 已具名早退 %d − 跑引擎 %d）—— ★我的 tap 沒蓋到的 return，說出來不遮" % [
		_tot_eng + _tot_chp - _acc - _tot_eng, _tot_eng + _tot_chp, _acc, _tot_eng])
	# ③ 到期時刻分布
	if not _eng_per_tick.is_empty():
		_eng_per_tick.sort()
		var _sum: int = 0
		for v in _eng_per_tick:
			_sum += int(v)
		print("★③跑進引擎的 tick 數 %d｜單 tick 最多 %d 隊｜中位 %d 隊｜總計 %d 隊次" % [
			_eng_per_tick.size(), int(_eng_per_tick[-1]), int(_eng_per_tick[_eng_per_tick.size() / 2]), _sum])
		var hb: Array = []
		for b in range(10):
			hb.append("%d:%d" % [b, int(_cad_hist.get(b, 0))])
		print("★★③到期時刻分布（3 遊戲日切 10 段，值＝隊次）：%s" % " ".join(PackedStringArray(hb)))
		print("   ⇒ ★若集中在一兩段 ⇒【每 3 天一大批同時到期】＝ 主詞找到了；平均散開 ⇒ 不是它")
	else:
		print("★③【沒有任何隊跑進引擎】⇒ 這一格不可判（★窗是否 ≥3 個 cadence 週期？）")
	print("N 桶      跑引擎那群 每次 us（中位）   早退那群 每次 us（中位）")
	var eks: Array = eng_bucket.keys()
	eks.sort()
	for k in eks:
		var ea: Array = eng_bucket[k]
		ea.sort()
		var ca: Array = chp_bucket.get(k, [])
		ca.sort()
		print("  %3d-%3d   %10.1f (n=%d)        %8.1f (n=%d)" % [int(k), int(k) + 9,
			float(ea[ea.size() / 2]), ea.size(),
			float(ca[ca.size() / 2]) if not ca.is_empty() else -1.0, ca.size()])
	print("")
	if pts.size() >= 2:
		var a = pts[0]
		var b = pts[-1]
		var ratio_n: float = float(int(b[0]) + 5) / maxf(1.0, float(int(a[0]) + 5))
		var ratio_c: float = float(b[1]) / maxf(0.001, float(a[1]))
		print("★N 成長 %.1f× ⇒ 每隊成本 %.2f×" % [ratio_n, ratio_c])
		if ratio_c < 1.3:
			print("★★判讀：【常數】—— solo 每隊成本不隨規模長 ⇒ 它【不是】26 秒的成因")
		elif ratio_c < ratio_n * 0.7:
			print("★★判讀：介於常數與線性之間 ⇒ 仍不足以解釋 26 秒")
		else:
			print("★★★判讀：【超線性】—— 每隊成本隨 N 長 ⇒ ★它就是 26 秒的形狀")
	else:
		print("★樣本只有 %d 個 N 桶 ⇒ 【不可判】（窗不夠長，N 沒長起來）" % pts.size())
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	quit()
