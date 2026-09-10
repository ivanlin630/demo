extends SceneTree
# @bed-kind: diagnostic
# slice: ★切開「評一個 option」—— 目標已被釘死：14.6 ms/option
#
# ★兩個數字（同一個除法再用一次）：①每個 option 的 us（分佈＋點名最貴三個）②每個 term 的 us
#   ⇒ ★★成本集中在一兩個 term ⇒ 那就是標的；平均攤在所有 term ⇒ 標的是【框架本身】（另一張票）
# ★★★分佈用直方圖桶，不用 first-N 取樣（後者長跑時會被開局的便宜呼叫佔滿）
# env：OT_TICKS（預設 3000）／OT_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("OT_TICKS")) if OS.has_environment("OT_TICKS") else 3000
	var cfg: String = OS.get_environment("OT_CONFIG") if OS.has_environment("OT_CONFIG") else "warring_states"
	print("=== 逐 option／逐 term 成本（%d tick ＝ %.1f 遊戲天，%s，Probe=ON）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	seed(4242)
	# ★★★Probe ON/OFF 同窗對照（OT_PROBE=0 ⇒ 關）：`frontier_candidates` 裡有只在 Probe 開著時才跑的
	#   量測工作 ⇒ ★用 Probe-gated 碼表量不到它自己；下面那支碼表走 `phase_timing`，兩趟都在。
	var probe_on: bool = OS.get_environment("OT_PROBE") != "0"
	# ★★★兩趟必須走【同一條建世界的路】（第一版我在 OFF 那趟自己 new WorldState ⇒ 世界不同 ⇒ fp 當然不同，
	#   而那會被誤讀成「儀器在改世界」）⇒ 兩趟都走 helper，只有【建完之後】才關 Probe。
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	if not probe_on:
		Probe.enabled = false
	SimRunner.phase_timing = true
	var runner := SimRunner.new()
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))

	# ★★★frontier 內部三段（★碼表走 phase_timing，與 Probe 正交 —— 界限 43）
	#   ★單價一律【量】不准【除】：每段自己的碼表 ÷ 它自己的迴圈次數。
	var frc: float = maxf(1.0, float(GoalResolver.fr_calls))
	print("")
	print("★frontier 內部（%d 次呼叫）" % GoalResolver.fr_calls)
	print("%-26s %14s %12s %14s %14s" % ["段", "總計(s)", "us/call", "迴圈次數", "us/迴圈次"])
	print("%-26s %14.3f %12.1f %14d %14.1f" % ["①goal 迴圈（含②）", GoalResolver.fr_goalloop_us / 1e6,
		GoalResolver.fr_goalloop_us / frc, GoalResolver.fr_goals_n,
		GoalResolver.fr_goalloop_us / maxf(1.0, float(GoalResolver.fr_goals_n))])
	print("%-26s %14.3f %12.1f %14d %14.1f" % ["②resource_prereq（巢狀）", GoalResolver.fr_res_us / 1e6,
		GoalResolver.fr_res_us / frc, GoalResolver.fr_res_n,
		GoalResolver.fr_res_us / maxf(1.0, float(GoalResolver.fr_res_n))])
	print("%-26s %14.3f %12.1f %14d %14.1f" % ["③delegate 迴圈", GoalResolver.fr_deleg_us / 1e6,
		GoalResolver.fr_deleg_us / frc, GoalResolver.fr_deleg_n,
		GoalResolver.fr_deleg_us / maxf(1.0, float(GoalResolver.fr_deleg_n))])
	print("%-26s %14.3f %12.1f %14s %14s" % ["④deliver_candidates", GoalResolver.fr_deliver_us / 1e6,
		GoalResolver.fr_deliver_us / frc, "—", "—"])
	var seg_sum: float = GoalResolver.fr_goalloop_us + GoalResolver.fr_deleg_us + GoalResolver.fr_deliver_us
	print("★守恆：①+③+④ = %.3f s vs frontier 總計 %.3f s（差 %.3f s ＝ %.2f%%；★②巢狀在①內不另計）" % [
		seg_sum / 1e6, DecisionEngine.frontier_us_total / 1e6,
		(DecisionEngine.frontier_us_total - seg_sum) / 1e6,
		100.0 * (DecisionEngine.frontier_us_total - seg_sum) / maxf(1.0, DecisionEngine.frontier_us_total)])
	print("★★母體地板：goal 迴圈 %d 次／resource_prereq %d 次／delegate %d 次／產出 candidate %d 個（★0 ⇒ 明寫是 0）" % [
		GoalResolver.fr_goals_n, GoalResolver.fr_res_n, GoalResolver.fr_deleg_n, GoalResolver.fr_out_n])
	print("★★★frontier 碼表（不依賴 Probe）：%d 次／總計 %.2f s／**%.1f us per call**（Probe=%s）" % [
		DecisionEngine.frontier_calls, DecisionEngine.frontier_us_total / 1e6,
		DecisionEngine.frontier_us_total / maxf(1.0, float(DecisionEngine.frontier_calls)),
		"ON" if probe_on else "OFF"])
	if not probe_on:
		print("★fp=%s" % StateFingerprint.compute(st))
		print("=== DONE === SECTIONS=1/1 FAILS=0（★Probe 關 ⇒ 只有這一支碼表有數字）")
		quit()
	var calls: int = int(Probe.counts.get("optterm.calls", 0))
	var opt_rows: Array = []
	var tot_opt_us: float = 0.0
	var tot_opt_n: int = 0
	for k in Probe.counts:
		var ks: String = String(k)
		if not ks.begins_with("optterm.opt_n."):
			continue
		var opt: String = ks.replace("optterm.opt_n.", "")
		var n: int = int(Probe.counts[k])
		var us: float = Probe.amount("optterm.opt_us." + opt)
		tot_opt_us += us
		tot_opt_n += n
		opt_rows.append({"n": opt, "cnt": n, "us": us, "avg": us / maxf(1.0, float(n)),
			"max": float(Probe.peaks.get("optterm.opt_max." + opt, 0.0))})
	opt_rows.sort_custom(func(a, b): return float(a["us"]) > float(b["us"]))

	print("")
	print("★母體：rank_scored_ctx 呼叫 %d 次｜逐 option 樣本 %d 個｜總計 %.2f s（★0 ⇒ 不可判）" % [
		calls, tot_opt_n, tot_opt_us / 1e6])
	print("★★us/option 平均 = %.1f us（★而平均會把「一個 option 特別貴」藏起來 ⇒ 看下面的桶）" % [
		tot_opt_us / maxf(1.0, float(tot_opt_n))])
	var buckets: Array = ["lt100us", "lt1ms", "lt5ms", "lt20ms", "lt100ms", "ge100ms"]
	var parts: Array = []
	for b in buckets:
		var c: int = int(Probe.counts.get("optterm.opt_hist." + b, 0))
		parts.append("%s=%d(%.1f%%)" % [b, c, 100.0 * float(c) / maxf(1.0, float(tot_opt_n))])
	print("★分佈（直方圖桶）：%s" % "、".join(parts))

	print("")
	print("★★最貴的 option（依總計 us 排序，前 8）")
	print("%-22s %8s %12s %12s %12s" % ["option", "次數", "總計(s)", "us/次", "單次max(ms)"])
	for i in range(mini(8, opt_rows.size())):
		var r = opt_rows[i]
		print("%-22s %8d %12.3f %12.1f %12.1f" % [r["n"], r["cnt"], float(r["us"]) / 1e6, r["avg"], float(r["max"]) / 1000.0])

	var term_rows: Array = []
	var tot_term_us: float = 0.0
	for k in Probe.counts:
		var ks2: String = String(k)
		if not ks2.begins_with("optterm.term_n."):
			continue
		var t: String = ks2.replace("optterm.term_n.", "")
		var n2: int = int(Probe.counts[k])
		var us2: float = Probe.amount("optterm.term_us." + t)
		tot_term_us += us2
		term_rows.append({"n": t, "cnt": n2, "us": us2, "avg": us2 / maxf(1.0, float(n2)),
			"max": float(Probe.peaks.get("optterm.term_max." + t, 0.0))})
	term_rows.sort_custom(func(a, b): return float(a["us"]) > float(b["us"]))
	print("")
	print("★★★最貴的 term（依總計 us 排序，前 12；★成本集中 ⇒ 標的是那幾個 term／攤平 ⇒ 標的是框架）")
	print("%-26s %8s %12s %12s %12s %8s" % ["term", "次數", "總計(s)", "us/次", "單次max(ms)", "佔比"])
	for i in range(mini(12, term_rows.size())):
		var r2 = term_rows[i]
		print("%-26s %8d %12.3f %12.1f %12.1f %7.1f%%" % [r2["n"], r2["cnt"], float(r2["us"]) / 1e6,
			r2["avg"], float(r2["max"]) / 1000.0, 100.0 * float(r2["us"]) / maxf(1.0, tot_term_us)])
	print("")
	print("★term 總計 %.2f s vs option 總計 %.2f s（差 %.2f s ＝ option 迴圈裡【term 以外】的部分：coeff／failure-memory／boost／probe）" % [
		tot_term_us / 1e6, tot_opt_us / 1e6, (tot_opt_us - tot_term_us) / 1e6])
	print("★★各呼叫端的 option 成本：")
	for k in Probe.counts:
		var ks3: String = String(k)
		if ks3.begins_with("optterm.src_n."):
			var sname: String = ks3.replace("optterm.src_n.", "")
			var sn: int = int(Probe.counts[k])
			print("   %-12s option 樣本 %6d ／總計 %8.2f s ／ us/option %8.1f" % [
				sname, sn, Probe.amount("optterm.src_us." + sname) / 1e6,
				Probe.amount("optterm.src_us." + sname) / maxf(1.0, float(sn))])
	# ★★★rank_scored_ctx 自己的四段（★逐 option 只有 ~27us ⇒ 錢在別的地方，這裡把它找出來）
	print("")
	print("★★★rank_scored_ctx 四段（每次呼叫的平均 us）")
	print("%-12s %8s %12s %12s %12s %12s %10s" % ["呼叫端", "次數", "applicable", "option迴圈", "frontier", "sort", "options/次"])
	for k in Probe.counts:
		var ks4: String = String(k)
		if not ks4.begins_with("ctxseg.calls."):
			continue
		var sn2: String = ks4.replace("ctxseg.calls.", "")
		var n3: float = maxf(1.0, float(int(Probe.counts[k])))
		print("%-12s %8d %12.1f %12.1f %12.1f %12.1f %10.2f" % [sn2, int(n3),
			Probe.amount("ctxseg.applicable." + sn2) / n3,
			Probe.amount("ctxseg.optloop." + sn2) / n3,
			Probe.amount("ctxseg.frontier." + sn2) / n3,
			Probe.amount("ctxseg.sort." + sn2) / n3,
			Probe.amount("ctxseg.options." + sn2) / n3])
	print("★★★fp=%s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	quit()
