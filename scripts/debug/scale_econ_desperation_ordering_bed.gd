extends SceneTree

# [measurer持久fixture 2026-08-11] iii絕境排序底查:死亡螺旋(seed8181 dispersed Team2)
# 求援mini-util軌跡+叛離defect_util軌跡+per-option橫排,day18-28 race窗口focus。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-desperation-ordering-baseline.md
# 附SpecimenDumpHelper(motive→action→outcome)送QA故事稽核。
# 純觀測:inline SimRunner、既有help.mini_util tap+temp cohesion.defect_util/terms tap
# (event_faction_defect.gd/faction_ai_system.gd,env DESPAIR_TAP=1,測完git checkout --revert)。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const SEED: int = 8181
const DAYS: int = 35
const T2: int = 2

func _initialize() -> void:
	print("=== iii絕境排序底查(seed=%d %d天,Team2 death-spiral focus) ===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var daily_log: Array = []
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			for tid in state.teams:
				var t: TeamData = state.teams[tid]
				if (t.current_task == TeamData.TASK_SCOUT or t.current_task == TeamData.TASK_CONVOY) and not int(tid) in state.specimen_team_ids:
					state.specimen_team_ids.append(int(tid))
			var day: int = state.world.current_tick / WorldState.TICKS_PER_DAY
			var entry: Dictionary = {"day": day}
			if state.teams.has(T2):
				var t2: TeamData = state.teams[T2]
				entry["t2_faction_id"] = t2.faction_id
				entry["t2_pop"] = t2.population
				entry["t2_task"] = t2.current_task
				entry["t2_unrest"] = t2.unrest_turns
			daily_log.append(entry)
			if day >= 15 and day <= 30:
				print("  day%d: t2_faction=%s pop=%s task=%s unrest=%s" % [
					day, str(entry.get("t2_faction_id")), str(entry.get("t2_pop")), str(entry.get("t2_task")), str(entry.get("t2_unrest"))])

	print("\n───── help.mini_util_terms (Team2 相關樣本) ─────")
	var help_terms: Array = Probe.samples.get("help.mini_util_terms", [])
	for s in help_terms:
		if int(s.get("team", -1)) == T2:
			print("  %s" % str(s))

	print("\n───── cohesion.defect_terms (Team2 相關樣本) ─────")
	var defect_terms: Array = Probe.samples.get("cohesion.defect_terms", [])
	for s in defect_terms:
		if int(s.get("team", -1)) == T2:
			print("  %s" % str(s))

	SpecimenTracer.flush()
	SpecimenDumpHelper.dump(state, "docs/measurements/2026-08-11-scale-econ-desperation-ordering-seed8181.specimen.jsonl")
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "daily_log": daily_log,
		"help_mini_util_terms_t2": help_terms.filter(func(s): return int(s.get("team", -1)) == T2),
		"defect_terms_t2": defect_terms.filter(func(s): return int(s.get("team", -1)) == T2)}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-scale-econ-desperation-ordering-seed8181.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-scale-econ-desperation-ordering-seed8181.json")
	print("=== DONE ===")
	quit()
