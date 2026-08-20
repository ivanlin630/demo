extends SceneTree
# gate④ 量化床：wall/day 對照（main vs 本刀）。純計時、Probe 關（量測純度）、零 sim 改。
# ★量測紀律：同 config / 同 seed / 同天數 / 序列跑（禁並行搶 CPU）/ 每趟全新輸出檔名。
# env：ADHOC_DAYS（預設 7）、PERF_SEED（預設 1337）、PERF_CONFIG（預設 warring_states）、
#      PERF_OUT（sidecar 絕對路徑，reap 存活）。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 7
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var cfg_name: String = OS.get_environment("PERF_CONFIG") if OS.get_environment("PERF_CONFIG") != "" else "warring_states"
	var out_path: String = OS.get_environment("PERF_OUT")
	print("=== owner_outpost perf bed：config=%s seed=%d days=%d ===" % [cfg_name, seed_v, days])

	seed(seed_v)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = seed_v
	GameSetup.setup(state, config)

	# ★in-situ 對照模式（LW_CONFIG 以外的白名單 env 用 ADHOC_TICKS 位置）：
	# ADHOC_TICKS=1 → 開 shadow＝每次查詢多跑一次「舊全圖掃」→ 與 shadow=off 的差＝舊掃在真實 run 的成本。
	# 同一 binary、同 seed、同世界軌跡（shadow 純觀測不改行為）→ 免跨 branch 比較的雜訊。
	var legacy_mode: bool = OS.get_environment("ADHOC_TICKS") == "1"
	if legacy_mode:
		OwnerOutpostIndex.shadow_reset()
		OwnerOutpostIndex.shadow = true
	print("[mode] legacy_shadow=%s" % str(legacy_mode))

	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)
	var t0: int = Time.get_ticks_msec()
	var done_days: int = 0
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			done_days += 1
			_dump(out_path, done_days, Time.get_ticks_msec() - t0, state.teams.size())
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break
	OwnerOutpostIndex.shadow = false
	var wall: int = Time.get_ticks_msec() - t0
	var d: int = maxi(done_days, 1)
	print("[perf] days=%d wall=%dms → %.1f ms/day｜teams=%d" % [d, wall, float(wall) / float(d), state.teams.size()])
	_dump(out_path, done_days, wall, state.teams.size())
	print("=== perf bed DONE ===")

func _dump(path: String, day: int, wall_ms: int, teams: int) -> void:
	if path == "": return
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null: return
	var d: int = maxi(day, 1)
	f.store_string("day=%d wall=%dms ms/day=%.1f teams=%d\n" % [d, wall_ms, float(wall_ms) / float(d), teams])
	f.close()
