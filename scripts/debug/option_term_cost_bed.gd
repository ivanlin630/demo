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
	var _w0: int = Time.get_ticks_usec()
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	var _wall_us: float = float(Time.get_ticks_usec() - _w0)

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
	AcquisitionPaths._ap_flush()   # ★最後一個 tick 也要結清
	GoalResolver._rep_flush()      # ★同上（★最後一個 tick 的重複統計不能靜默消失）（★否則最後那一 tick 靜默消失）
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
	# ★★★拆歧義：查表 vs 計算（systems 2026-09-10）
	if GoalResolver.scan_n == 0 or GoalResolver.rbf_n == 0:
		print("★★★查表 vs 計算：**不可判** —— 查表 %d 次／resolver %d 次（母體地板在算式之前）" % [
			GoalResolver.scan_n, GoalResolver.rbf_n])
	else:
		print("★★★拆歧義：①查表（_facility_of_level_key ＋ REGISTRY 線性掃）%d 次／%.3f s／%.1f us；②計算（_resolve_build_facility 身體）%d 次／%.3f s／%.1f us ⇒ 查表佔 %.2f%%" % [
			GoalResolver.scan_n, GoalResolver.scan_us / 1e6,
			GoalResolver.scan_us / float(GoalResolver.scan_n),
			GoalResolver.rbf_n, GoalResolver.rbf_us / 1e6,
			GoalResolver.rbf_us / float(GoalResolver.rbf_n),
			100.0 * GoalResolver.scan_us / maxf(1.0, GoalResolver.scan_us + GoalResolver.rbf_us)])
		print("★守恆④：①+② = %.3f s vs facility 段 %.3f s（差 %.3f s）" % [
			(GoalResolver.scan_us + GoalResolver.rbf_us) / 1e6, GoalResolver.pb_fac_us / 1e6,
			(GoalResolver.pb_fac_us - GoalResolver.scan_us - GoalResolver.rbf_us) / 1e6])
	# ★★★_resolve_build_facility 身體四段（★母體地板在算式之前）
	print("")
	print("★_resolve_build_facility 身體四段")
	print("%-40s %10s %12s %14s" % ["段", "次數", "總計(s)", "us/次"])
	var rb: Array = [
		["①derived_payoff", GoalResolver.rb_payoff_n, GoalResolver.rb_payoff_us],
		["②FactionAISystem.new()._find_own_outpost", GoalResolver.rb_own_n, GoalResolver.rb_own_us],
		["③material/tools 遞迴 _resolve_resource_prereq", GoalResolver.rb_res_n, GoalResolver.rb_res_us],
		["④尾段（判斷＋_mk_delegate_candidate）", GoalResolver.rb_tail_n, GoalResolver.rb_tail_us]]
	var rb_sum: float = 0.0
	for row in rb:
		rb_sum += float(row[2])
		if int(row[1]) == 0:
			print("%-40s %10s %12.3f %14s" % [row[0], "★0 次", float(row[2]) / 1e6, "不可判"])
		else:
			print("%-40s %10d %12.3f %14.1f" % [row[0], int(row[1]), float(row[2]) / 1e6,
				float(row[2]) / float(row[1])])
	# ★★★四段要跟【整支的碼表】比（涵蓋全部呼叫端），不是跟只涵蓋 path 迴圈那 1116 次的 `rbf_*` 比
	# ★★★一次子問題展開（`_resolve_resource_prereq`）切四段
	print("")
	print("★一次子問題展開四段")
	print("%-44s %10s %12s %14s" % ["段", "次數", "總計(s)", "us/次"])
	var rp: Array = [
		["①前置滿檢查（effective_holding+need_keep）", GoalResolver.rp_need_n, GoalResolver.rp_need_us],
		["②市場（_nearest_market_outpost_with）", GoalResolver.mkt_n, GoalResolver.mkt_us],
		["③地形候選段（含逐地形找最近格）", GoalResolver.rp_terr_n, GoalResolver.rp_terr_us],
		["　└其中 find_nearest_terrain_tile", GoalResolver.rp_find_n, GoalResolver.rp_find_us],
		["④尾段（折現比較＋_mk_candidate）", GoalResolver.rp_tail_n, GoalResolver.rp_tail_us]]
	for row in rp:
		if int(row[1]) == 0:
			print("%-44s %10s %12.3f %14s" % [row[0], "★0 次", float(row[2]) / 1e6, "不可判"])
		else:
			print("%-44s %10d %12.3f %14.1f" % [row[0], int(row[1]), float(row[2]) / 1e6,
				float(row[2]) / float(row[1])])
	var rp_sum: float = GoalResolver.rp_need_us + GoalResolver.mkt_us + GoalResolver.rp_terr_us + GoalResolver.rp_tail_us
	print("")
	print("★★★「我夠不夠」那句再拆（★母體地板在算式之前）")
	print("%-40s %10s %12s %14s" % ["段", "次數", "總計(s)", "us/次"])
	var nk: Array = [
		["①-a effective_holding", GoalResolver.rp_hold_n, GoalResolver.rp_hold_us],
		["①-b need_keep（＝下面三個加數）", GoalResolver.rp_nk_n, GoalResolver.rp_nk_us],
		["　├ _self_use", NeedOracle.nk_self_n, NeedOracle.nk_self_us],
		["　├ _supply_chain", NeedOracle.nk_supply_n, NeedOracle.nk_supply_us],
		["　└ _construction_facility_need", NeedOracle.nk_constr_n, NeedOracle.nk_constr_us]]
	for row in nk:
		if int(row[1]) == 0:
			print("%-40s %10s %12.3f %14s" % [row[0], "★0 次", float(row[2]) / 1e6, "不可判"])
		else:
			print("%-40s %10d %12.3f %14.1f" % [row[0], int(row[1]), float(row[2]) / 1e6,
				float(row[2]) / float(row[1])])
	if NeedOracle.nk_top_n == 0:
		print("★★★need_keep 扇出：**不可判**（頂層 0 次）")
	else:
		var _nh: Array = []
		var _nhk: Array = NeedOracle.nk_depth_hist.keys()
		_nhk.sort()
		for k3 in _nhk:
			_nh.append("深度%s=%d" % [k3, int(NeedOracle.nk_depth_hist[k3])])
		print("★★★need_keep 扇出：頂層 %d 次／全部 %d 次 ⇒ **每次查詢展開 %.1f 次**；最深 %d 層；%s" % [
			NeedOracle.nk_top_n, NeedOracle.nk_all_n,
			float(NeedOracle.nk_all_n) / float(NeedOracle.nk_top_n), NeedOracle.nk_maxdepth,
			"、".join(_nh)])
	# ★★★self ／ total（★只有頂層 elapsed 能跟牆鐘比；只有 self 能排序；★★不准「總次數 × total 單價」）
	if NeedOracle.nk_top_n == 0:
		print("★★★need_keep self/total：**不可判**（頂層 0 次）")
	else:
		print("★★★need_keep：total %.3f s／**self %.3f s**／頂層 elapsed %.3f s｜頂層 %d 次／總 %d 次" % [
			NeedOracle.nk_tot_us / 1e6, NeedOracle.nk_selft_us / 1e6, NeedOracle.nk_topt_us / 1e6,
			NeedOracle.nk_top_n, NeedOracle.nk_all_n])
		print("   ⇒ ★頂層 elapsed／頂層次數 ＝ %.1f us（★★這一個才可以乘頂層次數）；self／總次數 ＝ %.1f us" % [
			NeedOracle.nk_topt_us / float(NeedOracle.nk_top_n),
			NeedOracle.nk_selft_us / maxf(1.0, float(NeedOracle.nk_all_n))])
	if NeedOracle.sc_n == 0:
		print("★★★_supply_chain self/total：**不可判**（0 次）")
	else:
		print("★★★_supply_chain：total %.3f s／**self %.3f s**／%d 次 ⇒ total %.1f us、self %.1f us per call（self 佔 %.1f%%）" % [
			NeedOracle.sc_tot_us / 1e6, NeedOracle.sc_selft_us / 1e6, NeedOracle.sc_n,
			NeedOracle.sc_tot_us / float(NeedOracle.sc_n), NeedOracle.sc_selft_us / float(NeedOracle.sc_n),
			100.0 * NeedOracle.sc_selft_us / maxf(1.0, NeedOracle.sc_tot_us)])
	# ★★★葉子的兩半
	if NeedOracle.sc_gate_n == 0:
		print("★★★_supply_chain 兩半：**不可判**（gating 0 次）")
	else:
		print("★★★_supply_chain 兩半：①設施 gating（全圖掃）%d 次／%.3f s／%.1f us per call／平均掃 %.0f 格；②配方比對 %.3f s；③gap 迴圈（★含巢狀 need_keep）%d 次／%.3f s" % [
			NeedOracle.sc_gate_n, NeedOracle.sc_gate_us / 1e6,
			NeedOracle.sc_gate_us / float(NeedOracle.sc_gate_n),
			NeedOracle.sc_gate_tiles / float(NeedOracle.sc_gate_n),
			NeedOracle.sc_match_us / 1e6, NeedOracle.sc_gap_n, NeedOracle.sc_gap_us / 1e6])
		print("   ★守恆⑧：①+②+③ = %.3f s vs `_supply_chain` total %.3f s（差 %.3f s）；★★提早返回（out_maxcoef 空）%d 次" % [
			(NeedOracle.sc_gate_us + NeedOracle.sc_match_us + NeedOracle.sc_gap_us) / 1e6,
			NeedOracle.sc_tot_us / 1e6,
			(NeedOracle.sc_tot_us - NeedOracle.sc_gate_us - NeedOracle.sc_match_us - NeedOracle.sc_gap_us) / 1e6,
			NeedOracle.sc_empty_n])
	var nk3: float = NeedOracle.nk_self_us + NeedOracle.nk_supply_us + NeedOracle.nk_constr_us
	print("★守恆⑦：三個加數和 %.3f s vs need_keep %.3f s（差 %.3f s）；①-a+①-b %.3f s vs 前置滿檢查 %.3f s（差 %.3f s）" % [
		nk3 / 1e6, GoalResolver.rp_nk_us / 1e6, (GoalResolver.rp_nk_us - nk3) / 1e6,
		(GoalResolver.rp_hold_us + GoalResolver.rp_nk_us) / 1e6, GoalResolver.rp_need_us / 1e6,
		(GoalResolver.rp_need_us - GoalResolver.rp_hold_us - GoalResolver.rp_nk_us) / 1e6])
	print("★守恆⑥：①+②+③+④ = %.3f s（母體 %d 次）vs **整支** %.3f s（母體 %d 次）⇒ 差 %.3f s" % [
		rp_sum / 1e6, GoalResolver.rp_all_n, GoalResolver.rp_all_us / 1e6, GoalResolver.rp_all_n,
		(GoalResolver.rp_all_us - rp_sum) / 1e6])
	print("   ★而 `rrp_*`（只涵蓋外層呼叫端）%.3f s／%d 次 —— ★★母體不同的量不可相減（今天第二次）" % [
		GoalResolver.rrp_us / 1e6, GoalResolver.rrp_n])
	# ★★★遞迴：一次頂層呼叫【之內】的展開與重複（★兩個原始數都印，母體不足印不可判）
	if GoalResolver.rec_top_n == 0:
		print("★★★遞迴展開：**不可判**（頂層呼叫 0 次）")
	else:
		var _dh: Array = []
		var _dk2: Array = GoalResolver.rec_depth_hist.keys()
		_dk2.sort()
		for k2 in _dk2:
			_dh.append("深度%s=%d" % [k2, int(GoalResolver.rec_depth_hist[k2])])
		print("★★★遞迴（一次頂層呼叫之內）：頂層 %d 次／子問題總展開 %d 次／相異 %d 個" % [
			GoalResolver.rec_top_n, GoalResolver.rec_calls_sum, GoalResolver.rec_distinct_sum])
		print("   ⇒ 每次頂層展開 %.2f 次；相異 %.2f 個；%s" % [
			float(GoalResolver.rec_calls_sum) / float(GoalResolver.rec_top_n),
			float(GoalResolver.rec_distinct_sum) / float(GoalResolver.rec_top_n),
			("★重複率 %.1f%%" % (100.0 * (1.0 - float(GoalResolver.rec_distinct_sum) / float(GoalResolver.rec_calls_sum)))) if GoalResolver.rec_calls_sum > 0 else "★不可判（展開 0 次）"])
		print("   ★深度分佈：%s" % "、".join(_dh))
	print("★守恆⑤：四段和 %.3f s（母體 %d 次）vs 整支 %.3f s（母體 %d 次）⇒ 差 %.3f s" % [
		rb_sum / 1e6, GoalResolver.rb_payoff_n, GoalResolver.rb_all_us / 1e6, GoalResolver.rb_all_n,
		(GoalResolver.rb_all_us - rb_sum) / 1e6])
	print("   ★而 `rbf_*`（只涵蓋 path 迴圈進來的）%.3f s／%d 次 —— ★★母體不同的量【不可相減】" % [
		GoalResolver.rbf_us / 1e6, GoalResolver.rbf_n])
	# ★★同一 tick 內【同一組輸入】重複算幾次（★母體 0 ⇒ 明寫不可判，不印比率）
	if GoalResolver.rep_rrp_calls_sum == 0:
		print("★★★同 tick 重複（_resolve_resource_prereq，鍵＝隊+res）：**不可判**（母體 0 次）")
	else:
		print("★★★同 tick 重複（_resolve_resource_prereq，鍵＝隊+res）：%d 個 tick／呼叫 %d 次／相異 %d 個 ⇒ 重複率 %.1f%%（同一組輸入平均算 %.2f 次）" % [
			GoalResolver.rep_rrp_ticks, GoalResolver.rep_rrp_calls_sum, GoalResolver.rep_rrp_distinct_sum,
			100.0 * (1.0 - float(GoalResolver.rep_rrp_distinct_sum) / float(GoalResolver.rep_rrp_calls_sum)),
			float(GoalResolver.rep_rrp_calls_sum) / maxf(1.0, float(GoalResolver.rep_rrp_distinct_sum))])
	if GoalResolver.rep_rbf_calls_sum == 0:
		print("★★★同 tick 重複（_resolve_build_facility，鍵＝隊+facility）：**不可判**（母體 0 次）")
	else:
		print("★★★同 tick 重複（_resolve_build_facility，鍵＝隊+facility）：呼叫 %d 次／相異 %d 個 ⇒ 重複率 %.1f%%（同一組輸入平均算 %.2f 次）" % [
			GoalResolver.rep_rbf_calls_sum, GoalResolver.rep_rbf_distinct_sum,
			100.0 * (1.0 - float(GoalResolver.rep_rbf_distinct_sum) / float(GoalResolver.rep_rbf_calls_sum)),
			float(GoalResolver.rep_rbf_calls_sum) / maxf(1.0, float(GoalResolver.rep_rbf_distinct_sum))])
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
	# ★★★這一輪唯一要的數字（systems）：子樹佔【整個世界跑一遍】的幾成
	#   ★分子分母必須同一個母體：兩者都涵蓋【這一窗的全部 tick】（不是 spike 母體）
	print("")
	print("★★★子樹佔比：frontier 總 %.3f s ÷ 牆鐘總 %.3f s ＝ **%.2f%%**（%d tick ＝ %.1f 遊戲天，%d 隊）" % [
		DecisionEngine.frontier_us_total / 1e6, _wall_us / 1e6,
		100.0 * DecisionEngine.frontier_us_total / maxf(1.0, _wall_us),
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), st.teams.size()])
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
