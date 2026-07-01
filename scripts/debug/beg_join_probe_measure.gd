extends SceneTree

# BEG/JOIN 死路探針量測（F-I3, measure-first）。
# warring config（8 faction 絕境多）但 max_ticks 上限以配合 wrapper 360s timeout。
# 純 NPC 觀測（no player）。讀 beg/join dispatch vs resolve → 死路 runtime 影響量化。
# max_ticks 可經 env BEG_PROBE_TICKS 覆寫（default 6 月）。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	Probe.enabled = true; Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	GameSetup.setup(state, config)
	var env_ticks: String = OS.get_environment("BEG_PROBE_TICKS")
	# default 1 月 (~285s wall @ radius14) 以配合 wrapper GODOT_TIMEOUT 360s；長跑經 env 覆寫。
	var max_ticks: int = int(env_ticks) if env_ticks != "" else 7200
	print("[begprobe] max_ticks=%d (%.1f 月) teams=%d factions=%d" % [
		max_ticks, max_ticks / 7200.0, state.teams.size(), state.factions.size()])
	var no_player := Vector2i(-1, -1)
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % 7200 == 0:
			print("[begprobe] 月%d teams=%d beg.dispatch=%d beg.early197=%d beg.resolve=%d join.dispatch=%d join.nohandler=%d" % [
				(tick + 1) / 7200, state.teams.size(),
				int(Probe.counts.get("beg.dispatch", 0)),
				int(Probe.counts.get("beg.early_return_197", 0)),
				int(Probe.counts.get("beg.resolve", 0)),
				int(Probe.counts.get("join.dispatch", 0)),
				int(Probe.counts.get("join.arrived_no_handler", 0))])
		if state.teams.is_empty():
			print("[begprobe] 全滅 @ tick=%d" % (tick + 1)); break
	print("\n[begprobe] === 死路探針最終 ===")
	print("[begprobe] 最終 teams=%d" % state.teams.size())
	for k in ["beg.dispatch", "beg.early_return_197", "beg.resolve",
			"join.dispatch", "join.arrived_no_handler", "join.resolve"]:
		print("[begprobe] %s=%d" % [k, int(Probe.counts.get(k, 0))])
	Probe.enabled = false
	print("=== beg_join_probe_measure DONE ===")
