extends SceneTree
# @bed-kind: diagnostic
# slice: A0 —— 驗「錯開真的均勻」（★systems 的 A2 門檻是從這個【推論】推出來的）
#
# ★★★這一格的價值不是「它會紅」，是它把一個【讀註解讀來的前提】變成【被驗過的前提】。
#   systems 原話：A2 的 20% 門檻是從「均勻」推出來的，而那沒驗過。
# ★純函式檢查：不建世界、不跑 tick ⇒ 秒級。
# ★★預註冊判準（systems 寫在派工信裡，我不改）：
#   cadence=60、~115 個 team_id ⇒ **max 格 ≤ 6**（期望 115/60 ≈ 1.9，放寬 3 倍）**且空格 ≤ 30**
#
# env：A0_TEAMS（預設 115）／A0_CADENCE（預設 60）／A0_CYCLES（預設 200）

func _initialize() -> void:
	var n_teams: int = int(OS.get_environment("A0_TEAMS")) if OS.has_environment("A0_TEAMS") else 115
	var cadence: int = int(OS.get_environment("A0_CADENCE")) if OS.has_environment("A0_CADENCE") else 60
	var cycles: int = int(OS.get_environment("A0_CYCLES")) if OS.has_environment("A0_CYCLES") else 200
	print("=== A0：CadenceStagger 錯開均勻性（teams=%d cadence=%d cycles=%d）===" % [
		n_teams, cadence, cycles])

	var fail: int = 0
	var worst_max: int = 0
	var worst_empty: int = 0
	var worst_cycle: int = -1
	# ★逐 cycle 檢查：★★「某一個 cycle 均勻」不等於「每個 cycle 都均勻」——
	#   而尖峰只需要【一個】壞 cycle 就會發生。
	for cyc in range(cycles):
		var hist: Array = []
		for _i in range(cadence): hist.append(0)
		for tid in range(n_teams):
			var off: int = CadenceStagger._mix(tid, cyc) % cadence
			hist[off] = int(hist[off]) + 1
		var mx: int = 0
		var empty: int = 0
		for v in hist:
			if int(v) > mx: mx = int(v)
			if int(v) == 0: empty += 1
		if mx > worst_max:
			worst_max = mx
			worst_cycle = cyc
		if empty > worst_empty: worst_empty = empty

	var expect: float = float(n_teams) / float(cadence)
	print("[A0] 期望每格 = %.2f｜★最壞 cycle 的 max 格 = %d（cycle %d）｜★最壞空格數 = %d／%d" % [
		expect, worst_max, worst_cycle, worst_empty, cadence])
	print("[A0] ★預註冊判準（systems 寫的，我沒改）：max ≤ 6 且 空格 ≤ 30")
	if worst_max > 6:
		push_error("[A0][FAIL] 最壞 max 格 = %d > 6 ⇒ ★錯開【不夠均勻】⇒ A2 的 20%% 門檻失去依據" % worst_max)
		fail += 1
	if worst_empty > 30:
		push_error("[A0][FAIL] 最壞空格 = %d > 30 ⇒ ★偏移沒有鋪滿週期 ⇒ 同上" % worst_empty)
		fail += 1

	# ★陽性對照：把「錯開」換成【沒有錯開】（offset 恆 0）⇒ 這個檢查必須紅
	#   ★★沒有它，A0 綠了也不知道它是不是永遠綠。
	var hist0: Array = []
	for _i in range(cadence): hist0.append(0)
	for tid in range(n_teams): hist0[0] = int(hist0[0]) + 1
	var mx0: int = int(hist0[0])
	var empty0: int = cadence - 1
	var ctrl_ok: bool = (mx0 > 6 and empty0 > 30)
	print("[A0] ★陽性對照（offset 恆 0 ＝ 完全沒錯開）：max=%d 空格=%d ⇒ 判準%s" % [
		mx0, empty0, "會紅 ✔" if ctrl_ok else "★不會紅 ✘"])
	if not ctrl_ok:
		push_error("[A0][FAIL] 陽性對照沒有點火 ⇒ 這個判準對【完全沒錯開】都不會紅")
		fail += 1

	# ── ★★A2c：相位會不會被【永遠保留】（systems §8.3；★不靠任何均勻性假設）──
	#   同一 team 在【連續兩個 cycle】拿到同一個 offset 的比率。
	#   ★純加法 ⇒ offset 恆定 ⇒ 100%（那就是陽性對照本身）；★★錯開 ⇒ 期望 1/cadence。
	var same: int = 0
	var pairs: int = 0
	for tid2 in range(n_teams):
		for cyc2 in range(cycles - 1):
			pairs += 1
			if (CadenceStagger._mix(tid2, cyc2) % cadence) == (CadenceStagger._mix(tid2, cyc2 + 1) % cadence):
				same += 1
	var rate: float = 100.0 * float(same) / float(maxi(pairs, 1))
	print("[A2c] 相位保留率 = %.2f%%（%d／%d）｜期望 1/cadence ≈ %.2f%%｜門檻 <10%%" % [
		rate, same, pairs, 100.0 / float(cadence)])
	print("[A2c] ★純加法的對照值 ＝ 100%（offset 恆定）⇒ 0% 與 100% 之間沒有刀鋒")
	if rate >= 10.0:
		push_error("[A2c][FAIL] 相位保留率 %.2f%% ≥ 10%% ⇒ 相位仍被保留" % rate)
		fail += 1
	# ── ★★★A0b：多層疊加（10 個【真實常數】，★引用常數本身不手抄數值）──
	var cads: Array = [
		["THREAT", FactionAISystem.THREAT_CADENCE], ["RESIDENCY", FactionAISystem.RESIDENCY_CADENCE],
		["INFO_DISPATCH", FactionAISystem.INFO_DISPATCH_CADENCE], ["SUBTEAM", FactionAISystem.SUBTEAM_CADENCE],
		["DECISION", FactionAISystem.DECISION_CADENCE], ["LABOR", LaborSystem.LABOR_CADENCE],
		["INFRA_INTERVAL", FactionAISystem.INFRA_INTERVAL], ["CONSOLIDATE", FactionAISystem.CONSOLIDATE_CADENCE],
		["GOAL_EVAL", GoalResolver.GOAL_EVAL_CADENCE],
	]
	print("\n[A0b] ★用到的 cadence 常數（原樣印，不手抄）：")
	for c in cads: print("[A0b]   %-16s = %d" % [String(c[0]), int(c[1])])
	var horizon: int = 4320
	for mode in ["before(純加法)", "after(錯開)"]:
		var union: Array = []
		for _t in range(horizon): union.append({})
		for c2 in cads:
			var cd: int = int(c2[1])
			if cd <= 0: continue
			for tid3 in range(n_teams):
				# ★★★不要從 t=0 開始標記：所有隊在 t=0 都「到期」是【我的初始條件】,
				#   而它會讓 before 與 after 的 max 都變成 115（＝假象,兩邊一樣就看不出差別）。
				#   ⇒ 先算出【第一次真正到期】的 tick,再開始標。
				var t3: int = cd if mode.begins_with("before") else (cd + (CadenceStagger._mix(tid3, 0) % cd))
				while t3 < horizon:
					union[t3][tid3] = true
					if mode.begins_with("before"): t3 += cd
					else: t3 = (t3 / cd + 1) * cd + (CadenceStagger._mix(tid3, t3 / cd) % cd)
		var us: Array = []
		for d in union: us.append(d.size())
		us.sort()
		print("[A0b] %-14s union 每 tick 到期隊數：median=%d p90=%d p99=%d ★max=%d（%.1f%% of %d 隊）" % [
			mode, _q(us, 0.5), _q(us, 0.9), _q(us, 0.99), int(us[us.size() - 1]),
			100.0 * float(us[us.size() - 1]) / float(n_teams), n_teams])
	print("[A0b] ★★誠實限：本床【只模擬排程，不模擬 gating】⇒ 是排程層的【上界】")
	print("[A0b]   ⇒ ★★★只能 before vs after 互比，★不可拿去跟世界量到的 61.5% 比")
	print("=== cadence_stagger_uniformity DONE（fail=%d｜到場點名 5／5）===" % fail)
	quit(1 if fail > 0 else 0)

func _q(sorted_arr: Array, q: float) -> int:
	var idx: int = int(floor(q * float(sorted_arr.size() - 1)))
	return int(sorted_arr[clampi(idx, 0, sorted_arr.size() - 1)])
