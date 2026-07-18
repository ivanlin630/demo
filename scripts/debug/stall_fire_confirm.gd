extends SceneTree

# ② 絕境階梯 fire 確認（REDO 根=stall_exclude=0 從沒 fire；此 bed 證掛全 5 路後真 fire）。
# seed1337 warring，跑 ~2 月，dump survival.stall_exclude / survival.boost_fire。

func _initialize() -> void:
	seed(1337)
	Probe.enabled = true; Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] config"); quit(); return
	GameSetup.setup(state, config)
	var max_ticks: int = 14400   # ~2 月
	var no_player := Vector2i(-1, -1)
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % 7200 == 0:
			print("[stall] 月%d teams=%d boost_fire=%d stall_exclude=%d" % [
				(tick + 1) / 7200, state.teams.size(),
				int(Probe.counts.get("survival.boost_fire", 0)),
				int(Probe.counts.get("survival.stall_exclude", 0))])
		if state.teams.is_empty():
			print("[stall] 全滅 @ %d" % (tick + 1)); break
	print("[stall] === FINAL boost_fire=%d stall_exclude=%d ===" % [
		int(Probe.counts.get("survival.boost_fire", 0)),
		int(Probe.counts.get("survival.stall_exclude", 0))])
	Probe.enabled = false
	print("=== stall_fire_confirm DONE ===")
	quit()
