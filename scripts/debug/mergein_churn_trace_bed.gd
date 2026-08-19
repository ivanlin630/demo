extends SceneTree

# T1 runtime-trace bed（mergein churn (b)arrival-never pin·systems dispatch 2026-08-19）。
# seeded warring 短局跑 → 讀 jt.* 溫度計 pin sub-cause i/ii/iii：
#   (i)  movement 不執行 → jt.in_transit / jt.mv_seen 低、jt.at_target_host_absent 低
#   (ii) cadence 重委派 reset → jt.recommit_same 遠超 jt.fresh_commit（在途反覆委派）
#   (iii) 移動 host chase / belief-stale ghost → jt.belief_lag / jt.host_mobile / jt.at_target_host_absent / jt.belief_stale 高
# 純觀測、零 sim 邏輯改（trace tap 已 inline movement/faction_ai，T2 移）。

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

	print("\n--- churn 溫度計（jt.* + commit/resolve）---")
	var keys: Array = [
		"merge.consolidate_dispatch", "join.resolve", "join.arrived_no_handler",
		"jt.fresh_commit", "jt.recommit_same",
		"jt.mv_seen", "jt.in_transit", "jt.at_target_host_absent", "jt.colocated",
		"jt.belief_fresh", "jt.belief_stale", "jt.belief_lag", "jt.host_mobile",
		"jt.dist_le1", "jt.dist_2_4", "jt.dist_ge5",
		"jt.age_lt1d", "jt.age_1_3d", "jt.age_ge3d",
	]
	for k in keys:
		print("  %-32s = %d" % [k, int(Probe.counts.get(k, 0))])

	var commit: int = int(Probe.counts.get("merge.consolidate_dispatch", 0))
	var resolve: int = int(Probe.counts.get("join.resolve", 0))
	print("\n[ratio] join.resolve/commit = %d/%d = %.1f%%" % [resolve, commit, 100.0 * resolve / maxf(commit, 1)])
	var mv: int = int(Probe.counts.get("jt.mv_seen", 0))
	if mv > 0:
		print("[mv breakdown] in_transit=%.0f%% at_target_host_absent=%.0f%% colocated=%.0f%%" % [
			100.0 * int(Probe.counts.get("jt.in_transit", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.at_target_host_absent", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.colocated", 0)) / mv])
		print("[belief] fresh=%.0f%% stale=%.0f%% lag(host移動)=%.0f%% host_mobile=%.0f%%" % [
			100.0 * int(Probe.counts.get("jt.belief_fresh", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.belief_stale", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.belief_lag", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.host_mobile", 0)) / mv])
	var recommit: int = int(Probe.counts.get("jt.recommit_same", 0))
	var fresh: int = int(Probe.counts.get("jt.fresh_commit", 0))
	print("[commit-mix] recommit_same=%d fresh_commit=%d → recommit 占 %.0f%%" % [
		recommit, fresh, 100.0 * recommit / maxf(recommit + fresh, 1)])

	Probe.enabled = false
	print("\n=== mergein-churn T1 trace DONE ===")

# sidecar dump（reap 存活：長跑被殺也有 partial 溫度計可讀；純寫檔零 sim 影響）。
func _dump_sidecar(path: String, day: int, teams: int) -> void:
	if path == "":
		return
	var f := FileAccess.open(path, FileAccess.WRITE)   # 覆寫=最新快照
	if f == null:
		return
	var keys: Array = [
		"merge.consolidate_dispatch", "join.resolve", "join.arrived_no_handler",
		"jt.fresh_commit", "jt.recommit_same",
		"jt.mv_seen", "jt.in_transit", "jt.at_target_host_absent", "jt.colocated",
		"jt.belief_fresh", "jt.belief_stale", "jt.belief_lag", "jt.host_mobile",
		"jt.dist_le1", "jt.dist_2_4", "jt.dist_ge5",
		"jt.age_lt1d", "jt.age_1_3d", "jt.age_ge3d",
	]
	f.store_string("[day %d] teams=%d\n" % [day, teams])
	for k in keys:
		f.store_string("%-32s = %d\n" % [k, int(Probe.counts.get(k, 0))])
	var mv: int = int(Probe.counts.get("jt.mv_seen", 0))
	var commit: int = int(Probe.counts.get("merge.consolidate_dispatch", 0))
	var resolve: int = int(Probe.counts.get("join.resolve", 0))
	f.store_string("ratio resolve/commit = %d/%d = %.1f%%\n" % [resolve, commit, 100.0 * resolve / maxf(commit, 1)])
	if mv > 0:
		f.store_string("mv%%: in_transit=%.0f at_target_host_absent=%.0f colocated=%.0f | belief fresh=%.0f stale=%.0f lag=%.0f host_mobile=%.0f\n" % [
			100.0 * int(Probe.counts.get("jt.in_transit", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.at_target_host_absent", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.colocated", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.belief_fresh", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.belief_stale", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.belief_lag", 0)) / mv,
			100.0 * int(Probe.counts.get("jt.host_mobile", 0)) / mv])
	var rc: int = int(Probe.counts.get("jt.recommit_same", 0))
	var fc: int = int(Probe.counts.get("jt.fresh_commit", 0))
	f.store_string("commit-mix: recommit_same=%d fresh=%d → recommit %.0f%%\n" % [rc, fc, 100.0 * rc / maxf(rc + fc, 1)])
	f.close()
