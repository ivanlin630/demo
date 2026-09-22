extends SceneTree
# @bed-kind: diagnostic
# slice: 存活隊掉 11~18% —— 驗 systems 的「第一次評估被推遲」假說（★純函式，不建世界）
#
# ★★★票上寫的是「只動相位、不動頻率」。這一格就是去驗那句話。
#   `CadenceStagger.next_tick` 的候選 ＝ `(current/c + 1)*c + offset`
#   ⇒ 距離現在 ＝ `c − (current mod c) + offset`，而 r 與 offset 都在 [0,c)
#   ⇒ ★它不是 c，它是一個【分佈】—— 而分佈有沒有改變頻率，要量不要推。
# ★★兩個獨立的問題，分開量（★它們的答案可以相反）：
#   Q1 第一次評估：所有 *_next_tick 欄位初值 ＝ 0（team_data.gd:224/264/272/275/278/279/280、
#      tile_data.gd:34）⇒ 新生隊在【兩臂】都是「立刻到期」⇒ 第一次【沒有】被推遲。
#      ⇒ 本床把它做成可證偽的一格，而不是我口頭斷言。
#   Q2 之後的間隔：before ＝ 恆等於 c；after ＝ 一個分佈 ⇒ 量 min/median/max 與【12 天內的評估次數】。
#      ★★評估次數才是承重的那一欄 —— 隊活不活看它想了幾次，不看它相位在哪。
# ★★★誠實限：本床只模擬【排程層】，不模擬呼叫端的 gating ⇒ 是上界，只能 before vs after 互比。
#
# env：CI_TEAMS（預設 115）／CI_DAYS（預設 12）

func _initialize() -> void:
	var n_teams: int = int(OS.get_environment("CI_TEAMS")) if OS.has_environment("CI_TEAMS") else 115
	var days: int = int(OS.get_environment("CI_DAYS")) if OS.has_environment("CI_DAYS") else 12
	var horizon: int = days * WorldState.TICKS_PER_DAY
	print("=== cadence 間隔分佈（teams=%d days=%d horizon=%d tick）===" % [n_teams, days, horizon])
	var fail: int = 0
	var cells: int = 0

	# ★常數原樣引用，不手抄數值（與 A0b 同一份來源）
	var cads: Array = [
		["THREAT", FactionAISystem.THREAT_CADENCE], ["RESIDENCY", FactionAISystem.RESIDENCY_CADENCE],
		["INFO_DISPATCH", FactionAISystem.INFO_DISPATCH_CADENCE], ["SUBTEAM", FactionAISystem.SUBTEAM_CADENCE],
		["DECISION", FactionAISystem.DECISION_CADENCE], ["LABOR", LaborSystem.LABOR_CADENCE],
		["INFRA_INTERVAL", FactionAISystem.INFRA_INTERVAL], ["CONSOLIDATE", FactionAISystem.CONSOLIDATE_CADENCE],
		["GOAL_EVAL", GoalResolver.GOAL_EVAL_CADENCE],
	]

	# ── Q1：第一次評估到底有沒有被推遲 ──
	#   欄位初值 0 ⇒ 任何 `current_tick >= next_tick` 形狀的閘在第一次檢查就放行。
	#   ★這一格【讀初值】而不是【讀我的印象】：初值由 TeamData 新實例現場取。
	var td := TeamData.new()
	var inits: Array = [
		["expand", td.expand_eval_next_tick], ["threat", td.threat_eval_next_tick],
		["decision", td.decision_eval_next_tick], ["subteam", td.subteam_eval_next_tick],
		["consolidate", td.consolidate_eval_next_tick], ["residency", td.residency_eval_next_tick],
		["goal", td.goal_eval_next_tick],
	]
	var nonzero: int = 0
	var shown: String = ""
	for row in inits:
		if int(row[1]) != 0: nonzero += 1
		shown += "%s=%d " % [String(row[0]), int(row[1])]
	print("\n[Q1] 新生隊欄位初值（現場從 TeamData.new() 讀）：%s" % shown)
	print("[Q1] ★非零的欄位數 = %d／%d" % [nonzero, inits.size()])
	if nonzero == 0:
		print("[Q1] ⇒ ★★全部為 0 ⇒ 新生隊在【兩臂都】第一次檢查就到期 ⇒ **第一次評估沒有被推遲**")
		print("[Q1] ⇒ ★★★所以「第一次被推遲最多一個 cadence」這個假說，在【新生隊】這一格【不成立】")
	else:
		print("[Q1] ⇒ ★有非零初值 ⇒ 假說在那些欄位上【可能成立】，需逐欄看寫入點")
	cells += 1

	# ── Q2：間隔分佈 ＋ 12 天內的評估次數 ──
	print("\n[Q2] 逐 cadence（after ＝ CadenceStagger.next_tick 真函式；before ＝ 純加法，構造上恆 = c）")
	print("[Q2] %-16s %7s %7s %8s %8s %8s %8s %9s %9s" % [
		"常數", "c", "min", "median", "p90", "max", ">c佔比", "評估次數before", "after"])
	var worst_ratio: float = 1.0
	var worst_name: String = ""
	for c2 in cads:
		var c: int = int(c2[1])
		if c <= 0: continue
		var gaps: Array = []
		var ev_after: int = 0
		for tid in range(n_teams):
			var t: int = 0
			while true:
				var nxt: int = CadenceStagger.next_tick(t, t, tid, c)
				if nxt >= horizon: break
				gaps.append(nxt - t)
				ev_after += 1
				t = nxt
		if gaps.size() < 30:
			print("[Q2] %-16s %7d ← ★不可判（間隔樣本 %d < 30）" % [String(c2[0]), c, gaps.size()])
			continue
		gaps.sort()
		var over: int = 0
		for g in gaps:
			if int(g) > c: over += 1
		# ★★★before 的次數必須用【同一個迴圈、同一個收斂條件】數出來 ——
		#   我第一版寫 `n_teams * int(horizon / c)`，它把落在 horizon 【上】的那次也數進去，
		#   而 after 那條鏈的條件是 `nxt < horizon` ⇒ 兩邊數的不是同一件事,
		#   造出一個 0.75 的假比值。★這是分母不同源,不是世界的事。
		var ev_before: int = 0
		for tid_b in range(n_teams):
			var tb: int = 0
			while true:
				var nb: int = tb + c
				if nb >= horizon: break
				ev_before += 1
				tb = nb
		print("[Q2] %-16s %7d %7d %8d %8d %8d %7.1f%% %9d %9d" % [
			String(c2[0]), c, int(gaps[0]), _q(gaps, 0.5), _q(gaps, 0.9), int(gaps[gaps.size() - 1]),
			100.0 * float(over) / float(gaps.size()), ev_before, ev_after])
		if ev_before > 0:
			var r: float = float(ev_after) / float(ev_before)
			if r < worst_ratio:
				worst_ratio = r
				worst_name = String(c2[0])
	cells += 1

	# ★★★Q3：次數為什麼一樣 —— 是【構造保證】還是巧合
	#   候選 ＝ (cycle+1)*c + offset，offset < c ⇒ 落點的 cycle_index 恆 ＝ cycle+1
	#   ⇒ 每個週期【恰好一次】。★但那是我的推導 —— 這一格把它量出來。
	#   ★★而「每週期恰好一次」與「兩次之間相距多遠」是兩件事：前者不變、後者變了。
	print("
[Q3] 每週期評估次數（after 臂，逐 team 逐 cycle 實際數）")
	for c3 in cads:
		var cv: int = int(c3[1])
		if cv <= 0: continue
		var per: Dictionary = {}
		for tid4 in range(n_teams):
			var t4: int = 0
			while true:
				var n4: int = CadenceStagger.next_tick(t4, t4, tid4, cv)
				if n4 >= horizon: break
				var key: String = "%d:%d" % [tid4, n4 / cv]
				per[key] = int(per.get(key, 0)) + 1
				t4 = n4
		var mx: int = 0
		var mn: int = 999
		for v in per.values():
			mx = maxi(mx, int(v))
			mn = mini(mn, int(v))
		print("[Q3]   %-16s c=%-6d 相異(team,cycle) %5d 格｜每格次數 min=%d max=%d ⇒ %s" % [
			String(c3[0]), cv, per.size(), mn, mx,
			"★恰好一次（構造保證）" if (mn == 1 and mx == 1) else "★★不是恰好一次"])
	cells += 1

	print("\n[Q2] ★★承重欄：12 天內【評估次數】after／before 最低 = %.4f（%s）" % [worst_ratio, worst_name])
	print("[Q2]   ★「只動相位不動頻率」＝ 這個比值應該 ≈ 1.000；★★偏離多少才算病由 systems 定，我不判")

	# ── ★陽性對照：把排程換成【純加法】餵同一套量法 ⇒ max 必須恆等於 c ──
	#   ★★沒有它，上面那張表綠了也不知道這個量法分不分得出兩臂。
	var cc: int = int(cads[0][1])
	var g0: Array = []
	for tid2 in range(n_teams):
		var t2: int = 0
		while t2 + cc < horizon:
			g0.append(cc)
			t2 += cc
	g0.sort()
	var ctrl_ok: bool = (g0.size() >= 30 and int(g0[0]) == cc and int(g0[g0.size() - 1]) == cc)
	print("\n[對照] 純加法餵同一套量法：min=%d max=%d（c=%d，n=%d）⇒ %s" % [
		int(g0[0]) if g0.size() > 0 else -1, int(g0[g0.size() - 1]) if g0.size() > 0 else -1,
		cc, g0.size(), "★量法分得出來 ✔" if ctrl_ok else "★量法分不出來 ✘"])
	if not ctrl_ok:
		push_error("[對照][FAIL] 純加法沒有量出 min=max=c ⇒ 這套量法對【兩臂】給一樣的答案")
		fail += 1
	cells += 1

	print("\n[誠實限] 本床只模擬排程層、不含呼叫端 gating ⇒ 只能 before vs after 互比，不可拿去跟世界的率比")
	print("=== cadence_interval_distribution DONE（fail=%d｜到場點名 %d／4）===" % [fail, cells])
	if cells != 4:
		push_error("[FAIL] 到場點名 %d／4 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _q(sorted_arr: Array, q: float) -> int:
	var idx: int = int(floor(q * float(sorted_arr.size() - 1)))
	return int(sorted_arr[clampi(idx, 0, sorted_arr.size() - 1)])
