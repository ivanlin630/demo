extends SceneTree

# [measurer持久fixture 2026-08-11] iii④順序emergent硬gate+TEST VALUE校準+flag(B)逐隊判。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-iii-calibrate-emergent.md
# seed8181 dispersed 45天,逐隊(非aggregate)追蹤:herald mini_util首次轉正日 vs defect_util首次轉正日,
# 判順序emergent gate(可救隊herald是否真的先於defect fire)。附specimen送QA故事稽核。
# 純觀測:inline SimRunner、既有help.mini_util/hedge tap(fix branch permanent)+temp
# help.mini_util_terms/cohesion.defect_terms(env DESPAIR_TAP=1,測完git checkout --revert)。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const SEED: int = 8181
const DAYS: int = 45
const ORIG_TIDS: Array = [0, 1, 2, 3]

func _initialize() -> void:
	print("=== iii④順序emergent gate+校準(seed=%d %d天,逐隊) ===" % [SEED, DAYS])
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
	var start_pop: int = 0
	for tid in state.teams: start_pop += state.teams[tid].population

	state.specimen_team_ids = [0, 1, 2, 3]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var team_daily: Dictionary = {}   # tid → array of {day,faction_id,pop,food_days,unrest}
	for tid in ORIG_TIDS: team_daily[tid] = []
	var prev_letter: int = 0
	var letter_days: Array = []   # 全域 help.letter_dispatched fire 日

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
			var cur_letter: int = int(Probe.counts.get("help.letter_dispatched", 0))
			if cur_letter > prev_letter: letter_days.append(day)
			prev_letter = cur_letter
			for tid in ORIG_TIDS:
				if not state.teams.has(tid):
					if team_daily[tid].is_empty() or team_daily[tid][-1].get("pop", -1) != -99:
						team_daily[tid].append({"day": day, "faction_id": null, "pop": -99, "food_days": -1, "unrest": -1})
					continue
				var t: TeamData = state.teams[tid]
				var food_days: float = ResourceSystem.effective_food(state, t) / maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
				team_daily[tid].append({"day": day, "faction_id": t.faction_id, "pop": t.population,
					"food_days": snappedf(food_days, 0.01), "unrest": t.unrest_turns})

	print("\n───── 逐隊逐日摘要(faction_id/pop/food_days/unrest) ─────")
	for tid in ORIG_TIDS:
		print("Team%d:" % tid)
		for e in team_daily[tid]:
			print("  day%d: faction=%s pop=%s food_days=%s unrest=%s" % [
				int(e["day"]), str(e["faction_id"]), str(e["pop"]), str(e["food_days"]), str(e["unrest"])])

	print("\n───── help.letter_dispatched 全域fire日 ─────")
	print("  %s" % str(letter_days))

	print("\n───── help.mini_util_terms 逐隊首次轉正日 ─────")
	var help_terms: Array = Probe.samples.get("help.mini_util_terms", [])
	var first_positive_help: Dictionary = {}
	for s in help_terms:
		var tid: int = int(s.get("team", -1))
		var tick: int = int(s.get("tick", -1))
		var day: int = tick / WorldState.TICKS_PER_DAY
		if float(s.get("mini", -999)) > 0.0 and not first_positive_help.has(tid):
			first_positive_help[tid] = day
	print("  %s" % str(first_positive_help))

	print("\n───── cohesion.defect_terms 逐隊首次轉正日(=defect真fire日) ─────")
	var defect_terms: Array = Probe.samples.get("cohesion.defect_terms", [])
	var first_positive_defect: Dictionary = {}
	for s in defect_terms:
		var tid2: int = int(s.get("team", -1))
		var tick2: int = int(s.get("tick", -1))
		var day2: int = tick2 / WorldState.TICKS_PER_DAY
		if float(s.get("defect_util", -999)) > 0.0 and not first_positive_defect.has(tid2):
			first_positive_defect[tid2] = day2
	print("  %s" % str(first_positive_defect))

	print("\n───── ★④順序判定(herald轉正 vs defect轉正,逐隊) ─────")
	for tid in ORIG_TIDS:
		var hday = first_positive_help.get(tid, null)
		var dday = first_positive_defect.get(tid, null)
		var verdict: String = "N/A"
		if hday != null and dday != null:
			verdict = "herald先(day%s<day%s)★可能救到" % [str(hday), str(dday)] if int(hday) < int(dday) else "defect先或同天(day%s>=day%s)" % [str(hday), str(dday)]
		elif hday != null: verdict = "只herald轉正(day%s),defect未fire" % str(hday)
		elif dday != null: verdict = "只defect轉正(day%s),herald未轉正" % str(dday)
		print("  Team%d: herald_day=%s defect_day=%s → %s" % [tid, str(hday), str(dday), verdict])

	var end_pop: int = 0
	for tid in state.teams: end_pop += state.teams[tid].population
	print("\n───── 總結 ─────")
	print("  start_pop=%d end_pop=%d attrition=%.1f%%" % [start_pop, end_pop, 0.0 if start_pop==0 else 100.0*(start_pop-end_pop)/float(start_pop)])
	print("  cohesion.defect_fire total=%d" % int(Probe.counts.get("cohesion.defect_fire", 0)))
	print("  help.letter_dispatched total=%d" % int(Probe.counts.get("help.letter_dispatched", 0)))

	SpecimenTracer.flush()
	SpecimenDumpHelper.dump(state, "docs/measurements/2026-08-11-scale-econ-iii-calibrate-seed8181.specimen.jsonl")
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "start_pop": start_pop, "end_pop": end_pop,
		"team_daily": team_daily, "letter_days": letter_days,
		"first_positive_help": first_positive_help, "first_positive_defect": first_positive_defect,
		"defect_fire_total": int(Probe.counts.get("cohesion.defect_fire", 0)),
		"letter_dispatched_total": int(Probe.counts.get("help.letter_dispatched", 0)),
		"help_terms_all": help_terms, "defect_terms_all": defect_terms}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-scale-econ-iii-calibrate-seed8181.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-scale-econ-iii-calibrate-seed8181.json")
	print("=== DONE ===")
	quit()
