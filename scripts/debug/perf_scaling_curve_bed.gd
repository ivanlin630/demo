extends SceneTree
# perf-arc slice0：scaling 曲線 + 熱點分解（systems 派 2026-08-26，零 production code 改動）。
# ★用途=分母，不是刀：在切任何優化刀之前，先知道「現況幾隊會爆、爆在哪一段」，
#   否則「50+ 隊到了沒」答不了(=不可達驗收)、每一刀的效果也歸因不了。
#
# 結構：借用既有 lod_perf_bed(雙regime LOD/全高清) + perf_phase_bed(phase_timing累積) 兩支床的手法，
#   合成一支：對隊數階梯的每一階，跑 LOD 與 全高清 兩趟，各自報 per-tick 分佈 + 全高清那趟額外拆
#   phase_timing，且★每個 phase 額外記【被走到幾個 tick】(denominator)——分不出「單次慢」vs「被走很多次」。
#
# env:
#   PERF_LADDER   config 逗號集（default "perf_scale_r1,perf_scale_r2,perf_scale_r3,perf_scale,perf_scale_r5"）
#   PERF_SEED     world seed（default 1337，全階梯固定）
#   PERF_TICKS    每趟(每regime)跑幾 tick（default 200；不用月級，O(N^2)疑似熱點在大隊數階梯會爆時間；
#                 ★smoke test 實測：35隊/20tick/full-HD 就吃了 33.8s 真牆鐘，其中單一 tick(tick10)
#                 燒了 32.4M us=32.4s——判準用 median 才不被這種尖峰污染，見下 median 欄）
#   PERF_OUT      落地路徑

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var ladder_raw: String = OS.get_environment("PERF_LADDER") if OS.has_environment("PERF_LADDER") else "perf_scale_r1,perf_scale_r2,perf_scale_r3,perf_scale,perf_scale_r5"
	var world_seed: int = int(OS.get_environment("PERF_SEED")) if OS.has_environment("PERF_SEED") else 1337
	var ticks: int = int(OS.get_environment("PERF_TICKS")) if OS.has_environment("PERF_TICKS") else 200
	var out_path: String = OS.get_environment("PERF_OUT") if OS.has_environment("PERF_OUT") else ""
	var hd_only: bool = OS.get_environment("PERF_HD_ONLY") == "1"   # systems授權長窗票：省LOD那趟，長窗risk已夠高
	var configs: Array = []
	for c in ladder_raw.split(",", false):
		configs.append(c.strip_edges())

	var lines: Array = []
	lines.append("=== perf_scaling_curve_bed：seed=%d ticks/regime=%d ladder=%s ===" % [world_seed, ticks, str(configs)])
	print(lines[-1])

	lines.append("%-16s %-8s %6s %20s %10s %10s %10s %10s %8s" % [
		"config", "regime", "teams", "teams_cfg_knobs", "median_us", "mean_us", "p99_us", "max_us", "tps@median"])
	var rows: Array = []
	for cfg in configs:
		var cp_path: String = (out_path + ".checkpoint.%s.txt" % cfg) if out_path != "" else ""
		var lod: Dictionary = {} if hd_only else _run_one(cfg, world_seed, ticks, false, false)
		if not hd_only and lod.is_empty(): continue
		var hd: Dictionary = _run_one(cfg, world_seed, ticks, true, true, cp_path)   # 全高清那趟才拆phase(★零LOD目標regime)+checkpoint
		if hd.is_empty(): continue
		if not hd_only: _print_row(lines, cfg, "LOD", lod)
		_print_row(lines, cfg, "full-HD", hd)
		rows.append({"config": cfg, "lod": lod, "hd": hd})

	if hd_only:
		lines.append("\n────────── ①scaling 曲線摘要（★PERF_HD_ONLY=1，跳過LOD那趟，只有full-HD） ──────────")
	else:
		lines.append("\n────────── ①scaling 曲線摘要（判準用 median，沿用 reference_hob_perf_protocol，比 per-tick 不撞絕對門檻） ──────────")
	lines.append("%-16s %6s %20s %13s %13s %8s %10s" % [
		"config", "teams", "teams_cfg_knobs", "LOD_median_us", "HD_median_us", "HD/LOD", "HD_tps"])
	for r in rows:
		var lmed: int = -1 if (r["lod"] as Dictionary).is_empty() else int(r["lod"]["median"])
		var hmed: int = int(r["hd"]["median"])
		var tps: float = 1_000_000.0 / maxf(float(hmed), 1.0)
		if lmed < 0:
			lines.append("%-16s %6d %20s %13s %13d %8s %10.0f" % [
				r["config"], int(r["hd"]["teams"]), str(r["hd"]["teams_expect"]), "n/a(skip)", hmed, "n/a", tps])
		else:
			lines.append("%-16s %6d %20s %13d %13d %7.1fx %10.0f" % [
				r["config"], int(r["hd"]["teams"]), str(r["hd"]["teams_expect"]), lmed, hmed,
				float(hmed) / maxf(float(lmed), 1.0), tps])
	lines.append("注：★母體=實際生成隊數(teams)，非config期望值(teams_cfg_knobs，只是原樣列出config輸入旋鈕，非我推導的期望值)——兩者常有落差，逐行標出、不自己解釋差多少。")

	lines.append("\n────────── ②熱點分解（每階full-HD那趟，phase 累積us + 分母=被走到幾個tick） ──────────")
	for r in rows:
		var hd2: Dictionary = r["hd"]
		var ph_sum: Dictionary = hd2.get("phase_sum", {})
		var ph_cnt: Dictionary = hd2.get("phase_count", {})
		var n_ticks: int = int(hd2.get("n_ticks", 0))
		lines.append("  --- %s（teams=%d, n_ticks=%d）---" % [r["config"], int(hd2["teams"]), n_ticks])
		var total_ph: int = 0
		for k in ph_sum: total_ph += int(ph_sum[k])
		var prows: Array = []
		for k in ph_sum:
			prows.append({"name": k, "us": int(ph_sum[k]), "cnt": int(ph_cnt.get(k, 0))})
		prows.sort_custom(func(a, b): return int(a["us"]) > int(b["us"]))
		lines.append("     %-22s %10s %8s %10s %12s %10s" % [
			"phase", "total_us", "%phase", "被走幾tick", "us/次", "us/tick(全窗)"])
		for pr in prows:
			var pct: float = 100.0 * float(pr["us"]) / maxf(float(total_ph), 1.0)
			var per_occ: float = float(pr["us"]) / maxf(float(pr["cnt"]), 1.0)
			var per_tick_all: float = float(pr["us"]) / maxf(float(n_ticks), 1.0)
			lines.append("     %-22s %10d %7.1f%% %10d %12.1f %10.1f" % [
				pr["name"], pr["us"], pct, pr["cnt"], per_occ, per_tick_all])
		lines.append("     總計時 %.2fs = %.0f%% of wall（餘為未計時膠水/loop開銷）" % [
			float(total_ph) / 1e6, 100.0 * float(total_ph) / maxf(float(hd2["wall"]), 1.0)])

	lines.append("\n────────── ③team_discovered 讀者粒度回報（systems想知道,不強求）──────────")
	lines.append("  現有 phase_timing 只分到 SYSTEMS registry 分組粒度（如 near.vision/near.messages/near.faction_ai…），")
	lines.append("  讀不到『48個讀者裡哪幾個實際吃時間』這麼細——那需要函式級或呼叫點級 tap，本床零production code改動做不到。")
	lines.append("  ★如實回報：分解不到那個粒度，是本輪的有效答案，不是我沒查。")

	var text: String = "\n".join(PackedStringArray(lines))
	print(text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== perf_scaling_curve_bed DONE ===")


func _run_one(cfg_name: String, world_seed: int, ticks: int, force_hd: bool, want_phase: bool, checkpoint_path: String = "") -> Dictionary:
	var path: String = "res://config/%s.json" % cfg_name
	if not FileAccess.file_exists(path):
		print("[FAIL] config 不存在：%s" % path)
		return {}
	seed(world_seed)
	SimRunner.force_full_hd = force_hd
	SimRunner.phase_timing = want_phase
	Probe.enabled = true; Probe.reset()   # systems票2026-08-26(perf-spike-denominator)：unified.rank.calls真呼叫次數tap需要這個開關
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(path)
	if config.is_empty():
		print("[FAIL] config 載入失敗：%s" % cfg_name)
		SimRunner.force_full_hd = false; SimRunner.phase_timing = false
		return {}
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	state.player_id = -1
	# ★不自推「期望隊數」公式（factions×tpf+roving 漏算 outposts 也會播種隊，公式本身可能就是錯的）——
	#   原樣列 config 輸入旋鈕，讓讀者自己跟 teams(實際生成) 對照，不幫他們算一個可能是錯的期望值。
	var teams_expect: String = "fac=%d×[%d,%d]+rov=[%d,%d]" % [
		int(config.get("factions", {}).get("count", 0)),
		int(config.get("factions", {}).get("teams_per_faction_range", [0,0])[0]),
		int(config.get("factions", {}).get("teams_per_faction_range", [0,0])[1]),
		int(config.get("independent_teams", {}).get("roving_count_range", [0,0])[0]),
		int(config.get("independent_teams", {}).get("roving_count_range", [0,0])[1])]
	var teams_start: int = state.teams.size()

	var no_player := Vector2i(-1, -1)
	var dts: Array = []
	var noop_dts: Array = []   # systems票2026-08-27(time-reanchor-S0)
	var nonop_dts: Array = []
	var phase_sum: Dictionary = {}
	var phase_count: Dictionary = {}
	var wall_t0: int = Time.get_ticks_usec()
	var n_ticks_ran: int = 0
	# ★checkpoint：長窗會被外部timeout砍掉、砍掉時只在跑完才寫檔的東西會整批丟失(已踩兩次)。
	#   有尖峰(>1s)或每500tick，當場append一行+flush()——就算被砍，磁碟上已經有東西。
	var cp: FileAccess = null
	if checkpoint_path != "":
		cp = FileAccess.open(checkpoint_path, FileAccess.WRITE)
		if cp != null:
			cp.store_line("=== checkpoint start：config跑法見PERF_LADDER/PERF_TICKS env，teams=%d ===" % teams_start)
			cp.flush()
	var last_rank_calls: int = 0   # systems票(perf-spike-denominator)：unified.rank.calls是累計counter,取逐tick delta
	# systems票2026-08-27(perf-gather-cacheability)：每隊上次『真的呼叫gather()』時的team_market_known指紋
	var last_market_fp: Dictionary = {}   # team_id -> fingerprint String
	var pair_same: int = 0
	var pair_diff: int = 0
	var pair_same_burst: int = 0   # burst tick(ambition/order_fired>50)子群
	var pair_diff_burst: int = 0
	var pair_same_nonburst: int = 0
	var pair_diff_nonburst: int = 0
	for tick in range(ticks):
		# ★systems票2026-08-27(perf-spike-coverage②)：對齊假說——比對tick前後ambition/order_eval_next_tick
		#   有沒有被推進，即知道『真的執行了』幾次(非headcount/非eligible)，讀WorldState非新tap。
		var pre_ambition: Dictionary = {}
		var pre_order: Dictionary = {}
		var pre_decision: Dictionary = {}   # systems票2026-08-27(perf-gather-cacheability)：decision_eval_next_tick pre/post=真的呼叫gather()的隊(經unified.rank那條路)
		for tid0 in state.teams:
			var t0team: TeamData = state.teams[tid0]
			pre_ambition[tid0] = t0team.ambition_eval_next_tick
			pre_order[tid0] = t0team.order_eval_next_tick
			pre_decision[tid0] = t0team.decision_eval_next_tick
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		dts.append(dt)
		n_ticks_ran += 1
		# ★systems票2026-08-27(time-reanchor-S0)：no-op tick=該tick runner._ph完全空(沒有任何cadence命中)。
		#   _ph每tick在advance_tick開頭清空(sim_runner.gd:223)、只在near/harvest/day/far真的執行時才寫入。
		if want_phase:
			if (runner._ph as Dictionary).is_empty():
				noop_dts.append(dt)
			else:
				nonop_dts.append(dt)
		# systems票2026-08-27(perf-gather-cacheability)：每tick(非只spike)掃一次——team_market_known
		#   只被_harvest_market_known(faction_ai_system.gd:3485)寫,只在該隊gather()真的跑時才變。
		#   用decision_eval_next_tick pre/post抓『這隊這tick真的呼叫了gather()』(經unified.rank/rank_scored那條路)，
		#   跟上次抓到的同隊指紋比對，配對數=連續兩次真呼叫的樣本數(不是隊數不是tick數)。
		var _burst_this_tick: bool = false
		for tid2 in state.teams:
			var t2team: TeamData = state.teams[tid2]
			if pre_ambition.get(tid2, -1) != t2team.ambition_eval_next_tick \
					or pre_order.get(tid2, -1) != t2team.order_eval_next_tick:
				_burst_this_tick = true; break
		for tid3 in state.teams:
			if not pre_decision.has(tid3): continue
			var t3team: TeamData = state.teams[tid3]
			if t3team.decision_eval_next_tick == int(pre_decision[tid3]): continue   # 這隊這tick沒真呼叫
			var known3: Dictionary = state.team_market_known.get(tid3, {})
			var keys3: Array = known3.keys(); keys3.sort()
			var fp: String = str(keys3)
			if last_market_fp.has(tid3):
				if last_market_fp[tid3] == fp:
					pair_same += 1
					if _burst_this_tick: pair_same_burst += 1
					else: pair_same_nonburst += 1
				else:
					pair_diff += 1
					if _burst_this_tick: pair_diff_burst += 1
					else: pair_diff_nonburst += 1
			last_market_fp[tid3] = fp
		if want_phase:
			for ph in runner._ph:
				phase_sum[ph] = int(phase_sum.get(ph, 0)) + int(runner._ph[ph])
				phase_count[ph] = int(phase_count.get(ph, 0)) + 1
		if cp != null and (dt > 1_000_000 or tick % 500 == 0):
			var wall_so_far: float = float(Time.get_ticks_usec() - wall_t0) / 1e6
			# systems票2026-08-26(perf-spike-denominator)：Σ(1+members)決策者headcount，讀WorldState非新tap
			#   ★_decide_unified 呼叫點有4處(faction_ai_system.gd:437/2489/2511-2514/3142)——
			#   本欄只覆蓋faction leader+members(:2489/2511-2514)那條，:437(threat force-reeval)
			#   跳cadence、:3142(獨立隊solo路)不在faction_id內——分開算，別混一欄假裝完整。
			# ★修正：_assign_member_tasks(:2497)對member_team_ids裡==leader_team_id的做skip——
			#   代表member_team_ids本身已含leader，不是「leader外加members」，+1會重複計。
			var faction_deciders: int = 0
			for fid in state.factions:
				var f = state.factions[fid]
				faction_deciders += f.member_team_ids.size()
			var solo_candidates: int = 0   # faction_id==-1 且非subteam＝走_evaluate_solo那條，可能call _decide_unified(:3142)
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if t.faction_id == -1 and t.parent_team_id == -1:
					solo_candidates += 1
			var rank_calls_total: int = int(Probe.counts.get("unified.rank.calls", 0))
			var rank_calls_delta: int = rank_calls_total - last_rank_calls
			last_rank_calls = rank_calls_total
			# ★systems訂正(2026-08-26)：分子分母同母體——用FactionAISystem._fai_ph(該tick的unified.rank自己計時,
			#   每次evaluate_all呼叫時clear重填,非累計)，不是整tick dt(dt含gather.*/loop1.factions等其他一切)。
			var rank_us_this_tick: int = int(FactionAISystem._fai_ph.get("unified.rank", 0))
			# ★systems票2026-08-27：真的執行次數＝eval_next_tick被推進的隊數(非headcount非eligible)
			var ambition_fired: int = 0
			var order_fired: int = 0
			for tid1 in state.teams:
				if not pre_ambition.has(tid1): continue   # 本tick新增的隊(founding等)無pre值,略過
				var t1team: TeamData = state.teams[tid1]
				if t1team.ambition_eval_next_tick != int(pre_ambition[tid1]): ambition_fired += 1
				if t1team.order_eval_next_tick != int(pre_order[tid1]): order_fired += 1
			cp.store_line("tick=%d dt_us=%d wall_so_far=%.1fs teams=%d tiles=%d faction_deciders=%d solo_candidates=%d rank_calls=%d rank_us=%d dt_per_call_true=%.1f ambition_fired=%d order_fired=%d ★MARKETFP_cumulative_same=%d diff=%d(burst same=%d diff=%d/nonburst same=%d diff=%d)" % [
				tick, dt, wall_so_far, state.teams.size(), state.world.tiles.size(), faction_deciders, solo_candidates,
				rank_calls_delta, rank_us_this_tick, (float(rank_us_this_tick) / maxf(float(rank_calls_delta), 1.0)),
				ambition_fired, order_fired, pair_same, pair_diff, pair_same_burst, pair_diff_burst, pair_same_nonburst, pair_diff_nonburst])
			# ★systems票2026-08-26(perf-spike-coverage)：dump完整_fai_ph字典(非[FaiPhase]那個只印top-8)，
			#   用來算Σ(頂層label) vs dt做覆蓋率驗證。只在真spike(dt>1s)dump，避免每個tick%500都寫一坨。
			if dt > 1_000_000:
				var all_ph: Array = []
				for k in FactionAISystem._fai_ph:
					all_ph.append({"n": k, "us": int(FactionAISystem._fai_ph[k])})
				all_ph.sort_custom(func(a, b): return int(a["us"]) > int(b["us"]))
				cp.store_line("  fai_ph_full(%d labels)=%s" % [all_ph.size(), JSON.stringify(all_ph)])
				# ★systems票2026-08-27(perf-spike-site-distribution)：unified.rank.call_us逐次樣本(implementer已加tap,cap=200全域非per-tick)。
				#   ★每次spike checkpoint都重印目前累積的全量(截至此刻)——被砍也保得住,cap有沒有滿本行看得出來。
				var call_us_samples: Array = Probe.samples.get("unified.rank.call_us", []) as Array
				cp.store_line("  rank_call_us_samples(累積至今%d筆,cap=200,%s)=%s" % [
					call_us_samples.size(), ("★已滿cap截斷" if call_us_samples.size() >= 200 else "未截斷"),
					JSON.stringify(call_us_samples)])
			cp.flush()
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			break
	var wall_total: int = Time.get_ticks_usec() - wall_t0
	SimRunner.force_full_hd = false
	SimRunner.phase_timing = false
	# ★systems票2026-08-27(time-reanchor-S0)：no-op tick統計(母體占比+dt分布,不只中位數)
	if noop_dts.size() > 0 or nonop_dts.size() > 0:
		var _nd: Array = noop_dts.duplicate(); _nd.sort()
		var _od: Array = nonop_dts.duplicate(); _od.sort()
		var _total: int = noop_dts.size() + nonop_dts.size()
		var _noop_sum: int = 0
		for v in noop_dts: _noop_sum += int(v)
		var _nonop_sum: int = 0
		for v in nonop_dts: _nonop_sum += int(v)
		print("[S0] no-op tick=%d/%d(%.1f%%) median=%d mean=%.1f min/max=%d/%d sum=%d us | non-noop=%d median=%d sum=%d us | 現制每遊戲日wall(以本窗按比例推算,若窗=1天則直接是)=%d us" % [
			noop_dts.size(), _total, 100.0*noop_dts.size()/_total,
			(int(_nd[_nd.size()/2]) if not _nd.is_empty() else 0),
			(float(_noop_sum)/maxf(float(noop_dts.size()),1.0)),
			(int(_nd[0]) if not _nd.is_empty() else 0), (int(_nd[-1]) if not _nd.is_empty() else 0), _noop_sum,
			nonop_dts.size(), (int(_od[_od.size()/2]) if not _od.is_empty() else 0), _nonop_sum,
			_noop_sum + _nonop_sum])
	# ★systems票2026-08-27(perf-stagger-fairness)：mkfill母體/成交,找有沒有任何床真的會成交
	var mk_buy: int = int(Probe.counts.get("mkfill.attempt.buy", 0))
	var mk_sell: int = int(Probe.counts.get("mkfill.attempt.sell", 0))
	var mk_orders: Array = Probe.samples.get("mkfill.order", []) as Array
	print("[mkfill] attempt.buy=%d attempt.sell=%d 成交樣本數=%d" % [mk_buy, mk_sell, mk_orders.size()])
	if cp != null:
		cp.store_line("=== checkpoint end：n_ticks_ran=%d wall_total=%.1fs mkfill_attempt_buy=%d mkfill_attempt_sell=%d mkfill_orders=%d ===" % [
			n_ticks_ran, float(wall_total) / 1e6, mk_buy, mk_sell, mk_orders.size()])
		if mk_orders.size() > 0:
			cp.store_line("  mkfill_order_samples=%s" % JSON.stringify(mk_orders))
		cp.close()
	if dts.is_empty():
		return {}
	var sum: int = 0
	for d in dts: sum += int(d)
	var mean: int = sum / dts.size()
	var sd: Array = dts.duplicate(); sd.sort()
	var n: int = sd.size()
	return {
		"teams": teams_start, "teams_start": teams_start, "teams_expect": teams_expect,
		"mean": mean, "median": int(sd[int(n / 2)]),
		"p99": int(sd[mini(int(n * 0.99), n - 1)]), "max": int(sd[n - 1]),
		"wall": wall_total, "n_ticks": n_ticks_ran,
		"phase_sum": phase_sum, "phase_count": phase_count,
	}


func _print_row(lines: Array, cfg: String, regime: String, r: Dictionary) -> void:
	var tps: float = 1_000_000.0 / maxf(float(r["median"]), 1.0)
	lines.append("%-16s %-8s %6d %20s %10d %10d %10d %10d %8.0f" % [
		cfg, regime, int(r["teams"]), str(r["teams_expect"]), int(r["median"]), int(r["mean"]),
		int(r["p99"]), int(r["max"]), tps])
