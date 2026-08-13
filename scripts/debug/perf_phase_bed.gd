extends SceneTree

# 相位計時 profile 床（純 debug/infra，零 production 侵入）。
# 藍圖/用戶題「運算卡哪」：短窗跑 + 累積相位表 → 哪個 phase 吃大頭。
#
# 機制：force_full_hd=true → 全隊走 near 完整 pipeline（分組 _pht label fire）；phase_timing=true。
#   每 tick advance 後讀 runner._ph（該 tick 相位→us、下 tick 才 clear）→ bed 端累積 phase_total。
#   ∴免動 sim_runner，純觀測。相位 label = SYSTEMS registry 分組（near.vision/near.move[含
#   strategic decision+尋路 estimate_catch_up]/near.messages[belief]/near.interact/near.economy/
#   near.consume/near.faction_ai/near.strategic_ai）+ harvest/day_boundary/captives_cleanup。
#
# ★誠實 caveat：force_full_hd 改行為（移速/思考頻率全速、far 批次降頻拿掉）→ 量的是「LOD-off
#   全高清 regime 下各相位成本分佈」（=拿掉 LOD 的 worst-case），非現行 LOD 世界節奏。profile
#   「哪個 phase 貴」用途成立；絕對 tick-time 見 lod_perf_bed 的 LOD-vs-HD 對照。
#
# 用法（env）：
#   PERF_SEED    world seed（default 1337）
#   PERF_DAYS    跑幾天（default 5；1 天=240 tick，短窗幾分鐘完事不被 GODOT_TIMEOUT 砍）
#   PERF_CONFIG  config 名（default warring_states，= die-off perf 情境）
# print A/B（print 佔比）：本 bed 跑兩趟由 caller 控 stdout（console vs 2>/dev/null 或 >/dev/null）
#   對比 wall-time；bed 自身 per-tick 不 print（只結尾報表）→ print 佔比 = sim 內部 print() 的 OS 成本。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var world_seed: int = int(OS.get_environment("PERF_SEED")) if OS.has_environment("PERF_SEED") else 1337
	var days: int = int(OS.get_environment("PERF_DAYS")) if OS.has_environment("PERF_DAYS") else 5
	var cfg_name: String = OS.get_environment("PERF_CONFIG") if OS.has_environment("PERF_CONFIG") else "warring_states"
	var total_ticks: int = maxi(days, 1) * WorldState.TICKS_PER_DAY

	print("=== perf_phase_bed：seed=%d days=%d (ticks=%d) config=%s ===" % [
		world_seed, days, total_ticks, cfg_name])

	seed(world_seed)
	SimRunner.force_full_hd = true    # 全隊 near → 分組相位計時
	SimRunner.phase_timing = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗：%s" % cfg_name)
		SimRunner.force_full_hd = false
		return
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	state.player_id = -1   # 自然世界（無玩家 forced_event）

	var no_player := Vector2i(-1, -1)
	var phase_total: Dictionary = {}   # 相位名 → 累積 us（全窗）
	var dts: Array = []                # 每 tick wall-time us
	var teams_start: int = state.teams.size()
	var wall_t0: int = Time.get_ticks_usec()

	for tick in range(total_ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		dts.append(Time.get_ticks_usec() - t0)
		# ★該 tick 相位拆解累積（runner._ph 下 tick 才 clear，此刻讀 = 剛跑完那 tick）
		for ph in runner._ph:
			phase_total[ph] = int(phase_total.get(ph, 0)) + int(runner._ph[ph])
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			print("[bed] tick=%d 全滅提早結束" % tick)
			break

	var wall_total: int = Time.get_ticks_usec() - wall_t0
	SimRunner.force_full_hd = false
	SimRunner.phase_timing = false
	_report(dts, phase_total, wall_total, teams_start, state.teams.size())
	print("=== perf_phase_bed DONE ===")

func _report(dts: Array, phase_total: Dictionary, wall_total: int, teams_start: int, teams_end: int) -> void:
	if dts.is_empty():
		print("[FAIL] 無 tick 資料"); return
	var sum: int = 0
	for d in dts: sum += int(d)
	var mean: int = sum / dts.size()
	var sd: Array = dts.duplicate(); sd.sort()
	var n: int = sd.size()
	print("\n[perf] teams %d→%d | ticks=%d wall=%.2fs mean=%d us/tick p99=%d us max=%d us tps=%.0f" % [
		teams_start, teams_end, n, float(wall_total) / 1e6, mean,
		int(sd[mini(int(n * 0.99), n - 1)]), int(sd[n - 1]), 1_000_000.0 / maxf(float(mean), 1.0)])

	# 相位表（降序 % 佔比）
	var phase_sum: int = 0
	for k in phase_total: phase_sum += int(phase_total[k])
	var rows: Array = []
	for k in phase_total:
		rows.append({"name": k, "us": int(phase_total[k])})
	rows.sort_custom(func(a, b): return int(a["us"]) > int(b["us"]))
	print("\n[phase] 累積相位表（%d 相、總計時 %.2fs=%.0f%% of wall；餘為未計時膠水/loop 開銷）：" % [
		rows.size(), float(phase_sum) / 1e6, 100.0 * float(phase_sum) / maxf(float(wall_total), 1.0)])
	print("   %-24s %12s %8s %12s" % ["phase", "total_us", "%phase", "us/tick"])
	for r in rows:
		var pct: float = 100.0 * float(r["us"]) / maxf(float(phase_sum), 1.0)
		print("   %-24s %12d %7.1f%% %12.1f" % [
			r["name"], int(r["us"]), pct, float(r["us"]) / maxf(float(dts.size()), 1.0)])
