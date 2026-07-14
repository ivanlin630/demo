extends SceneTree

# SpecimenTracer RNG confound 修 TDD（slice: specimen-rng-confound-fix）
# spec: docs/superpowers/specs/2026-07-15-specimen-rng-confound-fix.md
#
# confound：tracer capture_options 的 to_task 迴圈每候選重呼 finder→estimate_catch_up→
#   observe_velocity→randf ＝ tracer **額外**消耗 global RNG → 「觀測誰」岔開 RNG 流 → 世界跟著變。
# 修：capture_options to_task 迴圈包 PathSystem.suppress_observe_noise（save/restore）→ 該段 RNG-neutral。
# 操作定義（不變量）：同 seed force_full_hd，specimen=A / =B / 無-specimen 三跑 →
#   除 SpecimenTracer entries 外世界狀態/所有隊軌跡 byte-identical。修前紅（岔）；修後綠（三組一致）。

var _fail: int = 0
const CFG := "res://config/warring_states.json"

func _initialize() -> void:
	_test_three_run_byte_identical()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# 世界簽章：全隊(sorted id) pos/pop/task/priority/food/coin → JSON（除 tracer entries 外的世界狀態）。
func _world_sig(state: WorldState) -> String:
	var ids: Array = state.teams.keys()
	ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = state.teams[tid]
		arr.append([tid, t.tile_pos.x, t.tile_pos.y, t.population,
			t.current_task, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01),
			snappedf(float(t.resources.get("coin", 0)), 0.01)])
	return JSON.stringify(arr)

func _run(seed_val: int, ticks: int, specimen: Array) -> String:
	seed(seed_val)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var cfg: Dictionary = GameSetup.load_config(CFG)
	cfg["seed"] = seed_val
	GameSetup.setup(state, cfg)
	SimRunner.force_full_hd = true
	state.specimen_team_ids.assign(specimen)
	SpecimenTracer.reset()
	SpecimenTracer.enabled = specimen.size() > 0
	var no_player := Vector2i(-1, -1)
	for _i in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	SpecimenTracer.enabled = false
	SimRunner.force_full_hd = false
	SpecimenTracer.reset()
	return _world_sig(state)

func _test_three_run_byte_identical() -> void:
	print("--- confound 修：三跑(specimen=A/B/無) byte-identical ---")
	var seed_val := 1337
	var ticks := 300
	var sig_a: String = _run(seed_val, ticks, [0])
	var sig_b: String = _run(seed_val, ticks, [3])
	var sig_none: String = _run(seed_val, ticks, [])
	_ok(sig_a == sig_none, "specimen=[0] vs 無-specimen 世界 byte-identical")
	_ok(sig_b == sig_none, "specimen=[3] vs 無-specimen 世界 byte-identical")
	_ok(sig_a == sig_b, "specimen=[0] vs [3] 世界 byte-identical")
	if sig_a != sig_none:
		print("    a  =%s" % sig_a.substr(0, 180))
		print("    none=%s" % sig_none.substr(0, 180))
