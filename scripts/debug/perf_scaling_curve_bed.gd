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
#   PERF_TICKS    每趟(每regime)跑幾 tick（default 720＝3天；不用月級，O(N^2)在大隊數階梯會爆時間）
#   PERF_OUT      落地路徑

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var ladder_raw: String = OS.get_environment("PERF_LADDER") if OS.has_environment("PERF_LADDER") else "perf_scale_r1,perf_scale_r2,perf_scale_r3,perf_scale,perf_scale_r5"
	var world_seed: int = int(OS.get_environment("PERF_SEED")) if OS.has_environment("PERF_SEED") else 1337
	var ticks: int = int(OS.get_environment("PERF_TICKS")) if OS.has_environment("PERF_TICKS") else 720
	var out_path: String = OS.get_environment("PERF_OUT") if OS.has_environment("PERF_OUT") else ""
	var configs: Array = []
	for c in ladder_raw.split(",", false):
		configs.append(c.strip_edges())

	var lines: Array = []
	lines.append("=== perf_scaling_curve_bed：seed=%d ticks/regime=%d ladder=%s ===" % [world_seed, ticks, str(configs)])
	print(lines[-1])

	lines.append("%-16s %-8s %6s %8s %10s %10s %10s %8s" % [
		"config", "regime", "teams", "teams_cfg", "mean_us", "p99_us", "max_us", "tps"])
	var rows: Array = []
	for cfg in configs:
		var lod: Dictionary = _run_one(cfg, world_seed, ticks, false, false)
		if lod.is_empty(): continue
		var hd: Dictionary = _run_one(cfg, world_seed, ticks, true, true)   # 全高清那趟才拆phase(★零LOD目標regime)
		if hd.is_empty(): continue
		_print_row(lines, cfg, "LOD", lod)
		_print_row(lines, cfg, "full-HD", hd)
		rows.append({"config": cfg, "lod": lod, "hd": hd})

	lines.append("\n────────── ①scaling 曲線摘要（full-HD＝零LOD目標regime的成本；mean=攤銷吞吐） ──────────")
	lines.append("%-16s %6s %6s %13s %13s %9s %10s %10s" % [
		"config", "teams", "cfg期望", "LOD_mean_us", "HD_mean_us", "HD/LOD", "HD_tps", "HD_max_us"])
	for r in rows:
		var lm: int = int(r["lod"]["mean"])
		var hm: int = int(r["hd"]["mean"])
		var tps: float = 1_000_000.0 / maxf(float(hm), 1.0)
		lines.append("%-16s %6d %6s %13d %13d %8.1fx %10.0f %10d" % [
			r["config"], int(r["hd"]["teams"]), str(r["hd"]["teams_expect"]), lm, hm,
			float(hm) / maxf(float(lm), 1.0), tps, int(r["hd"]["max"])])
	lines.append("注：★母體=實際生成隊數(teams)，非config期望值(cfg期望)——兩者會差，逐行標出。")

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


func _run_one(cfg_name: String, world_seed: int, ticks: int, force_hd: bool, want_phase: bool) -> Dictionary:
	var path: String = "res://config/%s.json" % cfg_name
	if not FileAccess.file_exists(path):
		print("[FAIL] config 不存在：%s" % path)
		return {}
	seed(world_seed)
	SimRunner.force_full_hd = force_hd
	SimRunner.phase_timing = want_phase
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
	var teams_expect: String = "%d~%d" % [
		int(config.get("factions", {}).get("count", 0)) * int(config.get("factions", {}).get("teams_per_faction_range", [0,0])[0]) \
			+ int(config.get("independent_teams", {}).get("roving_count_range", [0,0])[0]),
		int(config.get("factions", {}).get("count", 0)) * int(config.get("factions", {}).get("teams_per_faction_range", [0,0])[1]) \
			+ int(config.get("independent_teams", {}).get("roving_count_range", [0,0])[1])]
	var teams_start: int = state.teams.size()

	var no_player := Vector2i(-1, -1)
	var dts: Array = []
	var phase_sum: Dictionary = {}
	var phase_count: Dictionary = {}
	var wall_t0: int = Time.get_ticks_usec()
	var n_ticks_ran: int = 0
	for tick in range(ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		dts.append(Time.get_ticks_usec() - t0)
		n_ticks_ran += 1
		if want_phase:
			for ph in runner._ph:
				phase_sum[ph] = int(phase_sum.get(ph, 0)) + int(runner._ph[ph])
				phase_count[ph] = int(phase_count.get(ph, 0)) + 1
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			break
	var wall_total: int = Time.get_ticks_usec() - wall_t0
	SimRunner.force_full_hd = false
	SimRunner.phase_timing = false
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
	var tps: float = 1_000_000.0 / maxf(float(r["mean"]), 1.0)
	lines.append("%-16s %-8s %6d %8s %10d %10d %10d %8.0f" % [
		cfg, regime, int(r["teams"]), str(r["teams_expect"]), int(r["mean"]), int(r["p99"]), int(r["max"]), tps])
