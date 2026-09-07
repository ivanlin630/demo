extends SceneTree
# a4_taint_test2：決定性測試②——A4床邏輯(含_snap_witnesses/DecisionContext.gather高頻呼叫)
# 但印StateFingerprint而非threat_react統計，用ARM_PROBE env開關比對有無Probe.arm()的差異。
# 用法：ARM_PROBE=1|0 FP_TICKS=15000 godot --headless --script scripts/debug/a4_taint_test2.gd

func _snap_witnesses(state: WorldState, center: Vector2i, exclude_tid: int) -> void:
	for tid in state.teams:
		if tid == exclude_tid: continue
		var t: TeamData = state.teams[tid]
		var dist: float = Vector2(t.tile_pos.x - center.x, t.tile_pos.y - center.y).length()
		if dist <= 3.0:
			DecisionContext.gather(state, t)   # 呼叫但丟棄結果——只測有沒有side-effect

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("FP_TICKS")) if OS.has_environment("FP_TICKS") else 15000
	var arm_probe: bool = (OS.get_environment("ARM_PROBE") if OS.has_environment("ARM_PROBE") else "1") == "1"
	seed(1337)
	if arm_probe:
		Probe.arm()
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/warring_states.json"))
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 500 == 0:
			var any_combat: bool = false
			for tid3 in state.teams:
				if state.teams[tid3].combat_target != -1:
					any_combat = true; break
			if not any_combat and state.teams.size() > 0:
				var ids: Array = state.teams.keys()
				var pick_tid: int = ids[tick % ids.size()]
				var center: Vector2i = state.teams[pick_tid].tile_pos
				_snap_witnesses(state, center, pick_tid)
	var fp: String = StateFingerprint.compute(state)
	print("=== a4_taint_test2 DONE === arm_probe=%s ticks=%d fp=%s" % [str(arm_probe), ticks, fp])
	quit()
