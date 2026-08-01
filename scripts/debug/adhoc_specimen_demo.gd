extends SceneTree

# ★demo/smoke-test：SpecimenDumpHelper 用法示範（systems 2026-07-19 tooling ask 驗收）——
# 無 seed 的 ad-hoc 探索跑也能出 QA 可讀 specimen.jsonl。任何角色可複製此模式接自己的探索跑。
# 用法：SPECIMEN_SAMPLE_N=5（或 SPECIMEN_TEAM_ID="1,2,3"）+ 可選 ADHOC_TICKS(default 2400=10天)
#   .\tools\godot.ps1 --headless --script scripts/debug/adhoc_specimen_demo.gd

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	# ★無 seed：不呼 seed()，展示「無 seed 也吐」（QA 故事審不需可重現）。
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	GameSetup.setup(state, config)

	SpecimenDumpHelper.setup_from_env(state)

	var ticks: int = int(OS.get_environment("ADHOC_TICKS")) if OS.has_environment("ADHOC_TICKS") else 2400
	var no_player := Vector2i(-1, -1)
	print("[adhoc_specimen_demo] 無 seed 跑 %d ticks，teams=%d" % [ticks, state.teams.size()])
	for _t in range(ticks):
		runner.advance_tick(state, no_player)
		if state.teams.is_empty(): break

	SpecimenDumpHelper.dump(state, "docs/measurements/adhoc-demo.specimen.jsonl")
	print("=== DONE ===")
