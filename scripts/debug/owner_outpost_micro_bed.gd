extends SceneTree
# gate④ 補強：wall/day 全局窗被雜訊淹沒（本刀省的是全圖掃，佔比小）→ 直接量「被拿掉的工」。
# ①真實世界跑暖身 → ②同一批 team_id 上對照計時：舊全圖掃 vs 索引查表（per-call ns）
# ③真實 run 的查詢次數/日 + 索引重建次數/日（重建=一次全圖掃，是本設計的真成本）
# → 估算每日淨省 ms。純觀測、零 sim 改。
# env：ADHOC_DAYS（暖身/統計天數，預設 3）、PERF_SEED（1337）、PERF_CONFIG（warring_states）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 3
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var cfg_name: String = OS.get_environment("PERF_CONFIG") if OS.get_environment("PERF_CONFIG") != "" else "warring_states"
	print("=== owner_outpost micro bed：config=%s seed=%d days=%d ===" % [cfg_name, seed_v, days])

	seed(seed_v)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = seed_v
	GameSetup.setup(state, config)

	# ② 真實 run：統計查詢次數 + 重建次數（shadow 開＝每次查詢都會走一次舊掃，故 shadow_checks＝查詢次數）
	OwnerOutpostIndex.shadow_reset()
	OwnerOutpostIndex.shadow = true
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	OwnerOutpostIndex.shadow = false
	var queries: float = float(OwnerOutpostIndex.shadow_checks) / float(days)
	var avg_visits: float = float(OwnerOutpostIndex.legacy_visits) / maxf(float(OwnerOutpostIndex.shadow_checks), 1.0)
	var rebuilds: float = float(int(Probe.counts.get("owner_outpost.rebuild", 0))) / float(days)
	var tiles: int = state.world.tiles.size()
	print("[stat] tiles=%d｜查詢 %.0f 次/日｜索引重建 %.0f 次/日｜舊掃平均 %.0f tile-visits/查詢（滿掃=%d）｜shadow_fails=%d" % [
		tiles, queries, rebuilds, avg_visits, tiles, OwnerOutpostIndex.shadow_fails])

	# ① per-call 對照計時（同一批 team_id、同一世界；各跑 N 次取平均）
	var ids: Array = state.teams.keys()
	if ids.is_empty():
		print("[FAIL] 無隊可量"); Probe.enabled = false; return
	var N: int = 20000
	var sink: int = 0
	OwnerOutpostIndex.legacy_visits = 0
	var t0: int = Time.get_ticks_usec()
	for i in range(N):
		var v: Vector2i = FactionAISystem._scan_own_outpost_legacy(state, int(ids[i % ids.size()]))
		sink += v.x
	var legacy_us: int = Time.get_ticks_usec() - t0
	t0 = Time.get_ticks_usec()
	for i in range(N):
		var t = state.own_outpost_tile(int(ids[i % ids.size()]))
		sink += 1 if t != null else 0
	var index_us: int = Time.get_ticks_usec() - t0
	var per_visit: float = float(legacy_us) * 1000.0 / maxf(float(OwnerOutpostIndex.legacy_visits), 1.0)   # ns/tile-visit
	var per_legacy: float = float(legacy_us) * 1000.0 / float(N)   # ns/call
	var per_index: float = float(index_us) * 1000.0 / float(N)
	print("[micro] N=%d｜舊掃 %.0f ns/call（%.0f ns/tile-visit）｜索引 %.0f ns/call｜倍率 %.1fx（sink=%d 防最佳化）" % [
		N, per_legacy, per_visit, per_index, per_legacy / maxf(per_index, 0.001), sink])

	# ③ 淨估算：省下的查詢成本 − 重建成本（重建 ≈ 一次滿掃全圖，用 miss-case 上界近似）
	# ★用真實 run 的平均 visits（非 micro 迴圈的 team 分佈）換算舊掃真成本
	var real_legacy_ns: float = avg_visits * per_visit
	var saved_ms: float = queries * (real_legacy_ns - per_index) / 1e6
	var rebuild_ms: float = rebuilds * float(tiles) * per_visit / 1e6
	print("[est] 舊掃真成本 %.0f ns/查詢（%.0f visits × %.0f ns）→ 每日淨省 ≈ %.1f ms（查詢省 %.1f − 重建付 %.1f）" % [
		real_legacy_ns, avg_visits, per_visit, saved_ms - rebuild_ms, saved_ms, rebuild_ms])
	Probe.enabled = false
	print("=== micro bed DONE ===")
