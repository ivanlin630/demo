extends SceneTree
# gate②：每隊每 tick EWMA 推進次數 ≤1（advance 判定表的安全網、尤其 faction_ai:921 那條）。
# 逐 tick 記 need.ewma_advance 增量 vs 當時隊數 → 若增量 > 隊數＝必有隊被推進 >1 次。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var ticks: int = int(OS.get_environment("PERF_DAYS")) if OS.get_environment("PERF_DAYS") != "" else 600
	print("=== EWMA advance ≤1/隊/tick bed：seed=%d ticks=%d ===" % [seed_v, ticks])
	seed(seed_v)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = seed_v
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var prev: int = 0
	var worst_ratio: float = 0.0
	var worst_tick: int = -1
	var violations: int = 0
	for t in range(ticks):
		runner.advance_tick(state, no_player)
		var now: int = int(Probe.counts.get("need.ewma_advance", 0))
		var delta: int = now - prev
		prev = now
		var teams_n: int = state.teams.size()
		if teams_n > 0:
			var ratio: float = float(delta) / float(teams_n)
			if delta > teams_n:
				violations += 1
			if ratio > worst_ratio:
				worst_ratio = ratio; worst_tick = t
	print("[bed] 總推進=%d 唯讀=%d" % [prev, int(Probe.counts.get("need.gather_readonly", 0))])
	print("[bed] 超額 tick 數（delta > 隊數）=%d、最差 tick=%d 比值=%.2f" % [violations, worst_tick, worst_ratio])
	if violations == 0:
		print("[bed] ★PASS 每 tick 推進總數 ≤ 隊數（必要條件：無隊被推進 >1 次的上界證據）")
	else:
		print("[bed] ✗FAIL 有 tick 推進總數 > 隊數 → 必有隊同 tick 被推進 >1 次")
	Probe.enabled = false
	print("=== bed DONE ===")
