extends SceneTree

# ② 重評頻率歸因：381次/90天(Team7 seed1337)由 _should_reeval 哪條件貢獻。
# Probe 分支計數(reeval.idle/stuck/crisis/directive/cadence)。純量測，不改邏輯。
# 也順帶記 established 數(①佐證)。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_val: int = 1337
	print("=== reeval attribution: default.json seed=%d 3mo ===" % seed_val)
	Probe.enabled = true; Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/default.json")
	if config.is_empty(): print("[FAIL] config"); return
	config["seed"] = seed_val
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = TimeScale.TICK_PER_DAY * 90
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	# established 數
	var est: int = 0
	for fid in state.factions:
		if state.factions[fid].is_established: est += 1
	print("--- established = %d / %d factions ---" % [est, state.factions.size()])
	# reeval 分支計數
	print("--- _should_reeval 分支計數(全隊合計 %d 天) ---" % 90)
	var total: int = 0
	for k in ["reeval.idle", "reeval.stuck", "reeval.crisis", "reeval.directive", "reeval.cadence"]:
		var c: int = int(Probe.counts.get(k, 0))
		total += c
		print("  %-18s = %d" % [k, c])
	print("  %-18s = %d" % ["TOTAL true", total])
	Probe.enabled = false
	print("=== DONE ===")
