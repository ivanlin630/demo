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
	print("★resource_prereq 內部：`_resolve_resource_prereq` %d 次／%.3f s／%.1f us per call" % [
		GoalResolver.rrp_n, GoalResolver.rrp_us / 1e6,
		GoalResolver.rrp_us / maxf(1.0, float(GoalResolver.rrp_n))])
	print("★★其中 `_nearest_market_outpost_with`（★含每次 `FactionAISystem.new()`，**不在 Probe 內**）：%d 次／%.3f s／%.1f us per call ＝ 前者的 %.1f%%" % [
		GoalResolver.mkt_n, GoalResolver.mkt_us / 1e6,
		GoalResolver.mkt_us / maxf(1.0, float(GoalResolver.mkt_n)),
		100.0 * GoalResolver.mkt_us / maxf(1.0, GoalResolver.rrp_us)])
	# ★★★全圖掃的重複率（systems 派：memo 的價值全在這個數字上）
	AcquisitionPaths._ap_flush()   # ★最後一個 tick 也要結清（★否則最後那一 tick 靜默消失）
	var ap_t: float = maxf(1.0, float(AcquisitionPaths.ap_ticks_n))
	print("")
	# ★★★迴圈身體四段（★母體地板在算式之前：次數 0 ⇒ 明寫 0，不印任何以 0 為分母的比率）
	print("")
	print("★逐 path 迴圈身體四段")
	print("%-34s %10s %12s %14s" % ["段", "次數", "總計(s)", "us/次"])
	var pb: Array = [
		["①facility(REGISTRY掃+_resolve_build_facility)", GoalResolver.pb_fac_n, GoalResolver.pb_fac_us],
		["②facility 的 Probe 區塊（儀器）", GoalResolver.pb_probe_n, GoalResolver.pb_probe_us],
		["③material 遞迴 _resolve_resource_prereq", GoalResolver.pb_sub_n, GoalResolver.pb_sub_us],
		["④ready/stock 的 _mk_candidate", GoalResolver.pb_ready_n, GoalResolver.pb_ready_us]]
	var pb_sum: float = 0.0
	for row in pb:
		pb_sum += float(row[2])
		if int(row[1]) == 0:
			print("%-34s %10s %12.3f %14s" % [row[0], "★0 次", float(row[2]) / 1e6, "不可判"])
		else:
			print("%-34s %10d %12.3f %14.1f" % [row[0], int(row[1]), float(row[2]) / 1e6,
				float(row[2]) / float(row[1])])
	print("★守恆③：四段和 %.3f s vs 迴圈身體 %.3f s（差 %.3f s）" % [
		pb_sum / 1e6, GoalResolver.path_us / 1e6, (GoalResolver.path_us - pb_sum) / 1e6])
	var ph_parts: Array = []
	for k in ["0", "1", "2to3", "4to7", "8to15", "ge16"]:
		ph_parts.append("%s=%d" % [k, int(GoalResolver.paths_hist.get(k, 0))])
	print("★★paths/call 分佈（桶）：%s" % "、".join(ph_parts))
	print("★★★`for_resource` 本身 %d 次／%.3f s／%.1f us；★逐 path 迴圈身體 %d 個 path／%.3f s／%.1f us per path" % [
		GoalResolver.acq_n, GoalResolver.acq_us / 1e6, GoalResolver.acq_us / maxf(1.0, float(GoalResolver.acq_n)),
		GoalResolver.path_n, GoalResolver.path_us / 1e6,
		GoalResolver.path_us / maxf(1.0, float(GoalResolver.path_n))])
	print("★守恆②：rrp %.3f + for_resource %.3f + path 身體 %.3f = %.3f vs resource_prereq 段 %.3f s" % [
		GoalResolver.rrp_us / 1e6, GoalResolver.acq_us / 1e6, GoalResolver.path_us / 1e6,
		(GoalResolver.rrp_us + GoalResolver.acq_us + GoalResolver.path_us) / 1e6,
		GoalResolver.fr_res_us / 1e6])
	print("★★stock_sources（全圖掃）：%d 次／總計 %.3f s／%.1f us per call／平均每次掃 %.1f 格" % [
		AcquisitionPaths.ap_stock_n, AcquisitionPaths.ap_stock_us / 1e6,
		AcquisitionPaths.ap_stock_us / maxf(1.0, float(AcquisitionPaths.ap_stock_n)),
		AcquisitionPaths.ap_tiles_scanned / maxf(1.0, float(AcquisitionPaths.ap_stock_n))])
	print("★★producers_of 那一段（分開計時）：%d 次／總計 %.3f s／%.1f us per call" % [
		AcquisitionPaths.ap_prod_n, AcquisitionPaths.ap_prod_us / 1e6,
		AcquisitionPaths.ap_prod_us / maxf(1.0, float(AcquisitionPaths.ap_prod_n))])
	# ★★★母體 0 時【不准印比率】：`1 − 0/0` 會印成「重複率 100%」——
	#   而那是一個【看起來很有結論的假綠】。★母體地板要在算式之前，不是之後。
	if AcquisitionPaths.ap_calls_sum == 0:
		print("★★★同一 tick 內的重複率：**不可判** —— `stock_sources` 在本窗被呼叫 0 次（母體塌陷，不是重複率 100%）")
	else:
		print("★★★同一 tick 內的重複率：有查詢的 tick %d 個／平均每 tick 查 %.2f 次／相異 res %.2f 種 ⇒ 重複率 %.1f%%" % [
			AcquisitionPaths.ap_ticks_n, float(AcquisitionPaths.ap_calls_sum) / ap_t,
			float(AcquisitionPaths.ap_distinct_sum) / ap_t,
			100.0 * (1.0 - float(AcquisitionPaths.ap_distinct_sum) / maxf(1.0, float(AcquisitionPaths.ap_calls_sum)))])
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
