extends SceneTree

# B idle-labor→建設 real-sim execution-verify（[[feedback_verify_execution_end]]：驗機制真在全 sim fire、非只 unit ctx）。
# 跑經濟世界（GameSetup default config）N 月、Probe 開 → dump idle_employ.* tap counts。
# 用法：IBV_SEEDS（default 1337,4201）IBV_MONTHS（default 6）。純觀測不改 sim（Probe-gated tap 零 RNG）。

func _initialize() -> void:
	var seeds_raw: String = OS.get_environment("IBV_SEEDS") if OS.has_environment("IBV_SEEDS") else "1337,4201"
	var months: int = int(OS.get_environment("IBV_MONTHS")) if OS.has_environment("IBV_MONTHS") else 6
	var seeds: Array = []
	for tok in seeds_raw.split(","):
		if tok.strip_edges().is_valid_int(): seeds.append(int(tok.strip_edges()))
	print("=== idle_build_sim_verify: seeds=%s months=%d ===" % [str(seeds), months])
	for ws in seeds:
		_run_one(ws, months)
	print("=== DONE ===")

func _run_one(world_seed: int, months: int) -> void:
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.teams.is_empty(): break
	var build_chosen: int = int(Probe.counts.get("decision.opt_chosen.建設", 0))
	var idle_pos: int = int(Probe.counts.get("idle_employ.value_positive", 0))
	var idle_build: int = int(Probe.counts.get("idle_employ.build_chosen_with_idle", 0))
	print("[seed %d] teams=%d | 建設 chosen=%d | idle_employ.value_positive=%d | build_chosen_with_idle=%d" \
		% [world_seed, state.teams.size(), build_chosen, idle_pos, idle_build])
	if idle_pos > 0:
		print("  ✓ idle→build 機制真 fire（閒勞力有 genuine 建產能價值 %d 次；其中選建 %d 次）" % [idle_pos, idle_build])
	else:
		print("  ⚠ idle_employ_value 全程未 >0（此 seed 無大隊 idle+可建有需求 mfg；§8 領導軸經濟場景由 measurer 驗）")
	SimRunner.force_full_hd = false
	Probe.enabled = false
