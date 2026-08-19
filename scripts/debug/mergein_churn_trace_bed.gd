extends SceneTree

# T1 runtime-trace bed（mergein churn (b)arrival-never pin·systems dispatch 2026-08-19）。
# seeded warring 短局跑 → churn 溫度計：commit(merge.consolidate_dispatch) vs 真 resolve(join.resolve)
# 比例 + arrival-fail 兩出路(join.timeout / join.abort_ghost) + host 拒(accept.join_reject) + 分流。
# T1 pin 用的 jt.* temp tap 已於 T2 移除；本床改讀 production probe（長期可用）。
# 純觀測、零 sim 邏輯改。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	# ★args 走 cmdline user args（`-- <config> <seed> <months>`）——WMI detach 不繼承 env（血證同 --path）。
	# ★參數走 godot-detach.ps1 白名單 env（LW_CONFIG/LW_MONTHS/PERF_SEED）——WMI detach 只轉發白名單，
	#   非白名單 env 與 `--` user-args 都到不了（launcher 把 `--` 也加引號）。cmdline user args 為 fallback。
	var ua: PackedStringArray = OS.get_cmdline_user_args()
	var cfg_name: String = OS.get_environment("LW_CONFIG")
	if cfg_name == "": cfg_name = String(ua[0]) if ua.size() > 0 else "warring_states"
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else (int(ua[1]) if ua.size() > 1 else 1337)
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.get_environment("LW_MONTHS") != "" else (int(ua[2]) if ua.size() > 2 else 2)
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== mergein-churn T1 trace：seed=%d months=%d (ticks=%d) ===" % [seed_v, months, ticks])

	seed(seed_v)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	print("[bed] config=%s" % cfg_name)
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = seed_v
	GameSetup.setup(state, config)

	var side_path: String = "A:/GDS/demo/.worktrees/mergein-churn-fix/t1_%s_temp.txt" % cfg_name
	var no_player := Vector2i(-1, -1)
	var dump_every: int = WorldState.TICKS_PER_DAY * 5   # 每 5 日 sidecar（reap 存活：partial 也可讀）
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % dump_every == 0:
			_dump_sidecar(side_path, int((tick + 1) / WorldState.TICKS_PER_DAY), state.teams.size())
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break
	_dump_sidecar(side_path, int(ticks / WorldState.TICKS_PER_DAY), state.teams.size())

	print("\n--- churn 溫度計（commit/resolve + arrival-fail 出路）---")
	var keys: Array = [
		"merge.consolidate_dispatch", "join.resolve", "join.arrived_no_handler",
		"join.timeout", "join.abort_ghost", "accept.join_reject", "mergein.dissolve", "mergein.subteam",
	]
	for k in keys:
		print("  %-32s = %d" % [k, int(Probe.counts.get(k, 0))])

	var commit: int = int(Probe.counts.get("merge.consolidate_dispatch", 0))
	var resolve: int = int(Probe.counts.get("join.resolve", 0))
	print("\n[ratio] join.resolve/commit = %d/%d = %.1f%%" % [resolve, commit, 100.0 * resolve / maxf(commit, 1)])

	Probe.enabled = false
	print("\n=== mergein-churn trace DONE ===")

# sidecar dump（reap 存活：長跑被殺也有 partial 溫度計可讀；純寫檔零 sim 影響）。
func _dump_sidecar(path: String, day: int, teams: int) -> void:
	if path == "":
		return
	var f := FileAccess.open(path, FileAccess.WRITE)   # 覆寫=最新快照
	if f == null:
		return
	var keys: Array = [
		"merge.consolidate_dispatch", "join.resolve", "join.arrived_no_handler",
		"join.timeout", "join.abort_ghost", "accept.join_reject", "mergein.dissolve", "mergein.subteam",
	]
	f.store_string("[day %d] teams=%d\n" % [day, teams])
	for k in keys:
		f.store_string("%-32s = %d\n" % [k, int(Probe.counts.get(k, 0))])
	var commit: int = int(Probe.counts.get("merge.consolidate_dispatch", 0))
	var resolve: int = int(Probe.counts.get("join.resolve", 0))
	f.store_string("ratio resolve/commit = %d/%d = %.1f%%\n" % [resolve, commit, 100.0 * resolve / maxf(commit, 1)])
	f.close()
