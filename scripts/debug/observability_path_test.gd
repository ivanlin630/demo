extends SceneTree

# 觀測路徑維補齊 TDD（slice: observability-path-completion）
# Fix1 reaction tap / Fix2 unified 挪位+solo 早退 / Fix3 threat tap / Fix4 盲點閘。
var _fail: int = 0
const CFG := "res://config/warring_states.json"

func _initialize() -> void:
	_test_reaction_tap()
	_test_reaction_via_evaluate_person()
	_test_tracer_onoff_byte_identical()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _test_reaction_tap() -> void:
	print("--- Fix 1：capture_reaction → phase:reaction entry ---")
	SpecimenTracer.reset(); SpecimenTracer.enabled = true
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var t := TeamData.new(); t.team_id = 1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[1] = t
	state.specimen_team_ids = [1]
	var p := PersonData.new(); p.id = 50; p.loyalty = 0.2; p.stress = 0.8
	SpecimenTracer.capture_reaction(state, p, t, "N3_defect", {"loyalty": 0.2, "stress": 0.8})
	var a: Array = SpecimenTracer._archive
	_ok(a.size() == 1 and a[0].get("phase") == "reaction", "reaction entry（phase:reaction）")
	_ok(int(a[0].get("person_id", -1)) == 50 and a[0].get("reaction") == "N3_defect", "記誰/哪個 reaction")
	_ok(a[0].get("why", {}).get("loyalty") == 0.2, "why driver 快照（loyalty）")
	SpecimenTracer.reset()

func _test_reaction_via_evaluate_person() -> void:
	print("--- Fix 1 整合：_evaluate_person specimen → reaction tap fire ---")
	SpecimenTracer.reset(); SpecimenTracer.enabled = true
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var t := TeamData.new(); t.team_id = 1; t.faction_id = -1
	var p := PersonData.new(); p.id = 50; p.team_id = 1; p.loyalty = 0.3; p.stress = 0.5
	p.values = {"忠誠": 0.3, "野心": 0.5}
	state.persons[50] = p; t.leader_id = 50
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[1] = t
	state.specimen_team_ids = [1]
	var _r: String = ReactionSystem.new()._evaluate_person(state, p, t)
	var has_reaction := false
	for e in SpecimenTracer._archive:
		if e.get("phase") == "reaction" and int(e.get("person_id", -1)) == 50: has_reaction = true
	_ok(has_reaction, "_evaluate_person(specimen) → reaction entry 進 archive（內政不再盲）")
	SpecimenTracer.reset()

func _world_sig(state: WorldState) -> String:
	var ids: Array = state.teams.keys(); ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = state.teams[tid]
		arr.append([tid, t.tile_pos.x, t.tile_pos.y, t.population, t.current_task, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01)])
	return JSON.stringify(arr)

# 回 world sig + ★Probe aggregate（含 counter：驗 tracer re-query 不污染 Probe）。
func _run_warring(seed_val: int, ticks: int, specimen: Array, tracer_on: bool) -> String:
	seed(seed_val)
	var state := WorldState.new(); var runner := SimRunner.new()
	var cfg: Dictionary = GameSetup.load_config(CFG); cfg["seed"] = seed_val
	GameSetup.setup(state, cfg)
	SimRunner.force_full_hd = true
	Probe.enabled = true; Probe.reset()   # ★啟 Probe：驗 tracer re-query 不 bump 污染
	SpecimenTracer.reset()
	if tracer_on:
		state.specimen_team_ids.assign(specimen); SpecimenTracer.enabled = true
	var np := Vector2i(-1, -1)
	for _i in range(ticks):
		runner.advance_tick(state, np)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	# Probe aggregate 簽名（sorted key→count；tracer 若污染則 on/off 不同）
	var pk: Array = Probe.counts.keys(); pk.sort()
	var parr: Array = []
	for k in pk: parr.append([k, int(Probe.counts[k])])
	var sig := _world_sig(state) + "|PROBE|" + JSON.stringify(parr)
	SpecimenTracer.enabled = false; SimRunner.force_full_hd = false; Probe.enabled = false
	SpecimenTracer.reset()
	return sig

func _test_tracer_onoff_byte_identical() -> void:
	print("--- ★核心：tracer on/off 世界+Probe byte-identical（觀測禁改世界+禁污染 counter）---")
	var on := _run_warring(1337, 300, [7], true)
	var off := _run_warring(1337, 300, [], false)
	_ok(on == off, "tracer on vs off → 世界+Probe aggregate byte-identical（re-query 包 suppress 不污染）")
	if on != off:
		var oi: int = 0
		while oi < mini(on.length(), off.length()) and on[oi] == off[oi]: oi += 1
		print("    首異 @%d：on=…%s / off=…%s" % [oi, on.substr(maxi(0, oi - 20), 60), off.substr(maxi(0, oi - 20), 60)])
