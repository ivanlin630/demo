extends SceneTree
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
