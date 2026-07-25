extends SceneTree

# means-end S4 設施發展 TDD（HOW spec §10 S4）。8 座設施 goal + 設施/人力型前置。
# build_F walk:resource(build-cost)→facility(outpost-type)→manpower(pop)→全滿 build_F action。
# ★whole-system-first:S4 只設施+人力型;子目標遞迴/折現/委派=S5-S6。

var _fail: int = 0

func _initialize() -> void:
	_test_registry_8_facilities()   # ①8 座 build_F goal registry 對 FACILITY_DEF
	_test_facility_action_candidate()# ②設施型前置全滿→build_F action candidate
	_test_manpower_silent()         # ③人力前置 pop<N→靜默(無假 candidate)
	_test_resource_recurse()        # ④build_F 缺 material→接 S2/S3 資源鏈(非 build action)
	_test_util_guardrail_regression()# ⑤must-fix① range 斷言 regression
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

func _mk(outpost_type: String, pop: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 9):
		for y in range(3, 9):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", pop); team.armed_anon_ratio = 0.0
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.5, "貪婪": 0.5, "慎重": 0.5, "野心": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	if outpost_type != "":
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = outpost_type; tile.outpost_level = 1
	return [state, team]

# ① 8 座 build_F goal registry 對 FACILITY_DEF
func _test_registry_8_facilities() -> void:
	print("--- ①8 座 build_F registry ---")
	_ok(GoalRegistry.BUILD_FACILITY_GOALS.size() == 8, "8 座 build_F goal（got %d）" % GoalRegistry.BUILD_FACILITY_GOALS.size())
	var all_valid: bool = true
	for gt in GoalRegistry.BUILD_FACILITY_GOALS:
		var f: String = GoalRegistry.BUILD_FACILITY_GOALS[gt]
		if not OutpostSystem.FACILITY_DEF.has(f) or not GoalRegistry.REGISTRY.has(gt): all_valid = false
	_ok(all_valid, "每 build_F 對應真 FACILITY_DEF facility + REGISTRY 有 entry")

# ② 設施型前置全滿（civ outpost+資源夠+pop 夠+未建）→ build_F action candidate
func _test_facility_action_candidate() -> void:
	print("--- ②build_F action candidate ---")
	var w: Array = _mk("civilian", 10); var state: WorldState = w[0]; var team: TeamData = w[1]
	var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
	tile.set("manufacturing_level", 0)   # workshop 未建
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0   # 資源遠夠
	team.goal_state = [{"goal_type": "build_workshop", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	var action: Dictionary = {}
	for c in cands:
		if String(c.get("label", "")) == "build_workshop:facility:delegate" and c["to_task"].get("facility", "") == "workshop":
			action = c
	_ok(not action.is_empty(), "civ outpost+資源夠+pop 10+未建 → build_workshop facility candidate（前置全滿）")
	if not action.is_empty():
		_ok(action["to_task"].get("delegate", false) == true and not action["to_task"].has("build_type"),
			"to_task=facility delegate（★A1:複用 _dispatch_facility_builder 真建成,非發無 consumer TASK_BUILD）")

# ③ 人力前置 pop<N → 靜默（無 build/假 candidate）
func _test_manpower_silent() -> void:
	print("--- ③人力 pop<N 靜默 ---")
	var w: Array = _mk("civilian", 3); var state: WorldState = w[0]; var team: TeamData = w[1]   # pop 3 < 6
	state.world.tiles[5 * 1000 + 5].set("manufacturing_level", 0)
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0
	team.goal_state = [{"goal_type": "build_workshop", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	var has_action: bool = false
	for c in cands:
		if String(c.get("label", "")).begins_with("build_workshop"): has_action = true
	_ok(not has_action, "pop 3<6 → 無 build_workshop candidate（人力前置靜默，無假 candidate，等 passive）")

# ④ build_F 缺 material → 接 S2/S3 資源鏈（resource frontier 非 build action）
func _test_resource_recurse() -> void:
	print("--- ④build_F 缺 material 遞迴資源鏈 ---")
	var w: Array = _mk("military", 10); var state: WorldState = w[0]; var team: TeamData = w[1]
	state.world.tiles[5 * 1000 + 5].set("weaponsmith_level", 0)
	team.resources["material"] = 0.0; team.resources["coin"] = 100.0   # 缺 material
	# forest 近處供採@（S3 資源鏈）
	state.world.tiles[8 * 1000 + 5].terrain = "forest"
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	var res_frontier: bool = false
	var build_action: bool = false
	for c in cands:
		var lbl: String = String(c.get("label", ""))
		if lbl.begins_with("build_weaponsmith:resource") or lbl.begins_with("build_weaponsmith:location"): res_frontier = true
		if c["to_task"].get("facility", "") == "weaponsmith": build_action = true
	_ok(res_frontier and not build_action, "缺 material → 資源鏈 frontier（買/採），非 build action（first-unsatisfied 前置遞迴 S2/S3）")

# ⑤ must-fix① range 斷言 regression：絕境設施 goal util < survival boost
func _test_util_guardrail_regression() -> void:
	print("--- ⑤must-fix① range regression ---")
	var ctx_desp := DecisionContext.new(); ctx_desp.food_days = 0.001
	var u: float = GoalResolver._candidate_util(1.0e9, ctx_desp)
	_ok(u < DecisionEngine.SURVIVAL_BOOST_MAX, "絕境設施 goal util(%.2f) < SURVIVAL_BOOST_MAX %.1f（護欄沿用 S2，設施 goal 亦不蓋活命）" % [u, DecisionEngine.SURVIVAL_BOOST_MAX])
