extends SceneTree
# gate⑥（R² 加固）：長跑後 plan_phase 五層分佈——與 base main 比對，重心大幅位移＝原病（多推進）
# 在餵養某被依賴的行為模式，需回報而非自行 crank alpha。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var ticks: int = int(OS.get_environment("PERF_DAYS")) if OS.get_environment("PERF_DAYS") != "" else 600
	seed(seed_v)
	Probe.enabled = true; Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = seed_v
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(ticks):
		runner.advance_tick(state, no_player)
	var dist: Dictionary = {}
	for tid in state.teams:
		var ph: String = String(state.teams[tid].plan_phase)
		dist[ph] = int(dist.get(ph, 0)) + 1
	var keys: Array = dist.keys(); keys.sort()
	print("=== plan_phase 分佈（seed=%d ticks=%d teams=%d）===" % [seed_v, ticks, state.teams.size()])
	for k in keys:
		print("  %-12s %d (%.1f%%)" % [k, int(dist[k]), 100.0 * float(dist[k]) / maxf(float(state.teams.size()), 1.0)])
	print("[dist] advance=%d readonly=%d" % [
		int(Probe.counts.get("need.ewma_advance", 0)), int(Probe.counts.get("need.gather_readonly", 0))])
	Probe.enabled = false
	print("=== dist bed DONE ===")
