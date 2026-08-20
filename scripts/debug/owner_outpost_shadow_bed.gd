extends SceneTree
# ★gate①（本 slice 核心證據）：影子對照 —— 真實 run 中每一次 owner→outpost 查詢都同時跑
# 「舊全圖掃」與「新索引」並 assert 相等（含 -1 情況），任一不等即印 team/tile 並判 FAIL。
# 覆蓋 warring_states + peaceful_economy 各一段。純觀測（shadow 路徑不改任何世界狀態、零 RNG）。
#
# 參數走白名單 env：ADHOC_DAYS（每段天數，預設 15）、PERF_SEED（預設 1337）。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 15
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var side: String = "A:/GDS/demo/.worktrees/owner-outpost-index/shadow_temp.txt"
	print("=== owner→outpost shadow bed：days=%d seed=%d ===" % [days, seed_v])

	var total_checks: int = 0
	var total_fails: int = 0
	for cfg_name in ["warring_states", "peaceful_economy"]:
		var r: Array = _segment(cfg_name, seed_v, days, side)
		total_checks += int(r[0]); total_fails += int(r[1])

	print("\n[shadow] 總計 checks=%d fails=%d" % [total_checks, total_fails])
	print("=== %s ===" % ("SHADOW PASS（索引與舊全圖掃逐次相等）" if total_fails == 0 and total_checks > 0
		else "SHADOW FAIL / 無查詢樣本"))

func _segment(cfg_name: String, seed_v: int, days: int, side: String) -> Array:
	seed(seed_v)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗 %s" % cfg_name); return [0, 1]
	config["seed"] = seed_v
	GameSetup.setup(state, config)

	OwnerOutpostIndex.shadow_reset()
	OwnerOutpostIndex.shadow = true
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % (WorldState.TICKS_PER_DAY * 3) == 0:
			_dump(side, cfg_name, int((tick + 1) / WorldState.TICKS_PER_DAY))
		if state.teams.is_empty():
			print("[bed] %s 全滅 @tick=%d" % [cfg_name, tick]); break
	OwnerOutpostIndex.shadow = false
	var c: int = OwnerOutpostIndex.shadow_checks
	var f: int = OwnerOutpostIndex.shadow_fails
	print("[shadow] %-18s checks=%d fails=%d" % [cfg_name, c, f])
	_dump(side, cfg_name, days)
	return [c, f]

func _dump(path: String, cfg: String, day: int) -> void:
	var fh := FileAccess.open(path, FileAccess.WRITE)
	if fh == null: return
	fh.store_string("[%s day %d] checks=%d fails=%d\n" % [
		cfg, day, OwnerOutpostIndex.shadow_checks, OwnerOutpostIndex.shadow_fails])
	fh.close()
