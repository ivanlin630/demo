extends SceneTree

# die-off erase spike 量測床（純 debug/infra，零 production 侵入）。
# seeded warring 長跑，每 tick 記 wall-time + 該 tick 被 erase 的 team 數
# （tick 前後 teams key-set 差集 = 精確 erase 數；teams_pending_erase 在 tick 內已被 cleanup 清空，
#  harness 只能事後觀測 key-set，差集同時分離「新建」與「移除」不互相遮蔽）。
# 產出：中位 tick-time / p90 / p99 / max spike、top spike ticks（含 K 值）、K 分桶相關表
# → 證 spike↔die-off 相關（baseline）；修後同 seed 重量對照 spike 收斂。
#
# 用法（env）：
#   DIEOFF_SEED    world seed（default 1337）
#   DIEOFF_MONTHS  跑幾月（default 12；GODOT_TIMEOUT 拉大 + 背景跑）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var world_seed: int = int(OS.get_environment("DIEOFF_SEED")) if OS.has_environment("DIEOFF_SEED") else 1337
	var months: int = int(OS.get_environment("DIEOFF_MONTHS")) if OS.has_environment("DIEOFF_MONTHS") else 12
	var total_ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== dieoff_perf_bed：seed=%d months=%d (ticks=%d) ===" % [world_seed, months, total_ticks])

	seed(world_seed)   # 同 WarringHarness：播 global RNG（runtime bare randf/randi）
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = world_seed
	GameSetup.setup(state, config)

	var no_player := Vector2i(-1, -1)
	var dts: Array = []          # 每 tick wall-time (us)
	var erased_per_tick: Array = []   # 每 tick erase K
	var spikes: Array = []       # {tick, dt, erased, teams}
	var prev_keys: Dictionary = {}
	for tid in state.teams:
		prev_keys[tid] = true

	for tick in range(total_ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		# key-set 差集：erased = prev 有 cur 無（精確，不被同 tick 新建遮蔽）
		var erased: int = 0
		for tid in prev_keys:
			if not state.teams.has(tid):
				erased += 1
		prev_keys.clear()
		for tid in state.teams:
			prev_keys[tid] = true
		dts.append(dt)
		erased_per_tick.append(erased)
		spikes.append({"tick": tick, "dt": dt, "erased": erased, "teams": state.teams.size()})
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			# 月線累積 perf（防 GODOT_TIMEOUT 砍尾：部分輸出仍可用）
			var sd: Array = dts.duplicate(); sd.sort()
			var k1: int = 0
			for e in erased_per_tick:
				if int(e) >= 1: k1 += 1
			print("[bed] 月%d teams=%d pop=%d | median=%d us max=%d us K>=1 ticks=%d" % [
				(tick + 1) / WorldState.TICKS_PER_MONTH, state.teams.size(), _total_pop(state),
				sd[sd.size() / 2], sd[sd.size() - 1], k1])
		if state.teams.is_empty():
			print("[bed] tick=%d 全滅，提早結束" % tick)
			break

	_report(dts, erased_per_tick, spikes)
	print("=== dieoff_perf_bed DONE ===")

func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams:
		n += state.teams[tid].population
	return n

func _report(dts: Array, erased: Array, spikes: Array) -> void:
	if dts.is_empty():
		print("[FAIL] 無 tick 資料"); return
	var sorted_dts: Array = dts.duplicate()
	sorted_dts.sort()
	var n: int = sorted_dts.size()
	var median: int = sorted_dts[n / 2]
	var p90: int = sorted_dts[mini(int(n * 0.90), n - 1)]
	var p99: int = sorted_dts[mini(int(n * 0.99), n - 1)]
	var max_dt: int = sorted_dts[n - 1]
	print("\n[perf] ticks=%d median=%d us p90=%d us p99=%d us max=%d us (max/median=%.1fx)" % [
		n, median, p90, p99, max_dt, float(max_dt) / maxf(float(median), 1.0)])

	# top spike ticks（含該 tick erase K → 證 spike↔die-off 相關）
	var by_dt: Array = spikes.duplicate()
	by_dt.sort_custom(func(a, b): return int(a["dt"]) > int(b["dt"]))
	print("[perf] top spike ticks:")
	for i in range(mini(15, by_dt.size())):
		var s: Dictionary = by_dt[i]
		print("   tick=%6d dt=%7d us erased_K=%2d teams=%d" % [
			int(s["tick"]), int(s["dt"]), int(s["erased"]), int(s["teams"])])

	# K 分桶：erase 數 vs tick-time（相關表）
	var buckets: Dictionary = {}   # K字串 → {count, sum_dt, max_dt}
	for i in range(erased.size()):
		var k: int = int(erased[i])
		var bk: String = "0" if k == 0 else ("1" if k == 1 else ("2-4" if k <= 4 else "5+"))
		if not buckets.has(bk):
			buckets[bk] = {"count": 0, "sum_dt": 0, "max_dt": 0}
		var b: Dictionary = buckets[bk]
		b["count"] = int(b["count"]) + 1
		b["sum_dt"] = int(b["sum_dt"]) + int(dts[i])
		b["max_dt"] = maxi(int(b["max_dt"]), int(dts[i]))
	print("[perf] erase-K 分桶（K → ticks / avg us / max us）:")
	for bk in ["0", "1", "2-4", "5+"]:
		if not buckets.has(bk):
			continue
		var b: Dictionary = buckets[bk]
		print("   K=%-3s ticks=%6d avg=%7d us max=%7d us" % [
			bk, int(b["count"]), int(b["sum_dt"]) / maxi(int(b["count"]), 1), int(b["max_dt"])])
