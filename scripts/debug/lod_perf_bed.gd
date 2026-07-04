extends SceneTree

# LOD perf 對照床（純 debug/infra，零 production 侵入）。
# 藍圖裁定「LOD 拿掉 vs 重定義」需 perf 數據：目標規模下全高清 vs LOD 的 tick-time。
# 每個 config（規模階梯）跑兩趟同世界：
#   pass A = LOD（force_full_hd=false，現行 near≤3hex/far 批次 100tick；無玩家世界→全隊 far）
#   pass B = 全高清（force_full_hd=true，全隊 near，無 far 批次降頻）
# 逐 tick wall-time → mean(amortized 吞吐,決定 tps)/p99/max(hitch) + 可達 tps（1e6/mean us）。
# ★指標選擇：median 被 cadence 間隙 idle tick 主導=誤導;真成本=mean(每 tick 攤銷,=throughput 倒數)
#   + max/p99(worst-tick hitch,per-tick 有界不變量關切)。
#
# ★誠實 caveat：full-hd 改行為（移速/思考頻率恢復全速）→ 兩趟世界 tick1 後發散,
#   per-tick 非同狀態對照。量的是「~N 隊規模下,該 regime 一個 tick 值多少」的分佈envelope,
#   非同一世界狀態雙跑。短窗（2月）限發散,報 teams 數讓 N 漂移可見。
#
# 用法（env）：
#   LOD_PERF_LADDER   config 逗號集（default "default,warring,perf_scale"）
#   LOD_PERF_SEED     world seed（default 1337）
#   LOD_PERF_MONTHS   每趟跑幾月（default 2；×2趟×階梯，GODOT_TIMEOUT 拉大+背景跑）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var ladder_raw: String = OS.get_environment("LOD_PERF_LADDER") if OS.has_environment("LOD_PERF_LADDER") else "default,warring_states,perf_scale"
	var world_seed: int = int(OS.get_environment("LOD_PERF_SEED")) if OS.has_environment("LOD_PERF_SEED") else 1337
	var months: int = int(OS.get_environment("LOD_PERF_MONTHS")) if OS.has_environment("LOD_PERF_MONTHS") else 2
	var total_ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	var configs: Array = []
	for c in ladder_raw.split(",", false):
		configs.append(c.strip_edges())

	print("=== lod_perf_bed：seed=%d months=%d (ticks=%d) ladder=%s ===" % [
		world_seed, months, total_ticks, str(configs)])
	print("%-12s %-8s %6s %10s %10s %10s %8s" % [
		"config", "regime", "teams", "mean_us", "p99_us", "max_us", "tps"])

	var rows: Array = []
	for cfg in configs:
		var lod: Dictionary = _run_one(cfg, world_seed, total_ticks, false)
		if lod.is_empty(): continue
		var hd: Dictionary = _run_one(cfg, world_seed, total_ticks, true)
		if hd.is_empty(): continue
		_print_row(cfg, "LOD", lod)
		_print_row(cfg, "full-HD", hd)
		rows.append({"config": cfg, "lod": lod, "hd": hd})

	# 對照摘要：full-HD median / LOD median 倍率 + full-HD 可達 tps（拿掉 LOD 的 playability）
	print("\n────────── 對照摘要（full-HD = 拿掉 LOD 後的成本；mean=攤銷吞吐） ──────────")
	print("%-12s %6s %13s %13s %9s %10s %10s" % [
		"config", "teams", "LOD_mean_us", "HD_mean_us", "HD/LOD", "HD_tps", "HD_max_us"])
	for r in rows:
		var lm: int = int(r["lod"]["mean"])
		var hm: int = int(r["hd"]["mean"])
		var tps: float = 1_000_000.0 / maxf(float(hm), 1.0)
		print("%-12s %6d %13d %13d %8.1fx %10.0f %10d" % [
			r["config"], int(r["hd"]["teams"]), lm, hm, float(hm) / maxf(float(lm), 1.0), tps, int(r["hd"]["max"])])
	print("\n注:HD_tps=full-HD 攤銷可達每秒 tick(1e6/mean)。playback 參考:1×=240tps/4×=960tps。HD_max=最壞單tick(hitch)。")
	print("=== lod_perf_bed DONE ===")

func _run_one(cfg_name: String, world_seed: int, total_ticks: int, full_hd: bool) -> Dictionary:
	seed(world_seed)
	SimRunner.force_full_hd = full_hd
	SimRunner.phase_timing = (OS.get_environment("LOD_PERF_PHASE") == "1")   # spike tick 印相位拆解=點名 O(N^2) 熱點
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗：%s" % cfg_name)
		SimRunner.force_full_hd = false
		return {}
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	state.player_id = -1   # 自然世界（無玩家 forced_event 卡死）
	var no_player := Vector2i(-1, -1)
	var dts: Array = []
	var teams_start: int = state.teams.size()
	for tick in range(total_ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		dts.append(Time.get_ticks_usec() - t0)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			break
	SimRunner.force_full_hd = false   # 復位（防洩到別 config pass）
	if dts.is_empty():
		return {}
	var sum: int = 0
	for d in dts: sum += int(d)
	var mean: int = sum / dts.size()
	dts.sort()
	var n: int = dts.size()
	return {
		"teams": teams_start,
		"teams_end": state.teams.size(),
		"mean": mean,
		"p99": int(dts[mini(int(n * 0.99), n - 1)]),
		"max": int(dts[n - 1]),
	}

func _print_row(cfg: String, regime: String, r: Dictionary) -> void:
	var tps: float = 1_000_000.0 / maxf(float(r["mean"]), 1.0)
	print("%-12s %-8s %6d %10d %10d %10d %8.0f" % [
		cfg, regime, int(r["teams"]), int(r["mean"]), int(r["p99"]), int(r["max"]), tps])
