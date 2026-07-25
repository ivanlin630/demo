extends SceneTree

# means-end A1 forest founding 修 TDD（spec 2026-07-25-means-end-A1-forest-founding-fix §5）。
# 根:goal_resolver 三處發 {task:TASK_BUILD} 但無 consumer(begin_subteam_construction 只認
# TASK_CONSTRUCT/UPGRADE/EXPAND)→建不成=假閉環。修=改發 founding/facility delegate candidate,
# 複用既有 working builder(_dispatch_builder / _dispatch_facility_builder)。
# ★★must-fix②:執行端硬驗真管線(非抄近似)——從真 goal→frontier_candidates→_dispatch_goal_delegate
# (測型別判斷分支本身,非繞過直呼)→子隊 TASK_CONSTRUCT/EXPAND→抵達→begin_subteam_construction
# →_tick_construction→outpost/facility 真建成(level>0)。

var _fail: int = 0

func _initialize() -> void:
	_test_founding_candidate()        # ①缺料+無 forest outpost → founding candidate(delegate+build_type civilian)
	_test_founding_execution_end()    # ★★②執行端硬驗:真管線→forest outpost 真建成(outpost_level>0)
	_test_s4_new_outpost_execution()  # ★★③S4 :171 型別不符→建 new outpost 真建成
	_test_s4_facility_execution()     # ★★④S4 :178 → facility 真建成(weaponsmith_level>0)
	_test_util_guardrail()            # ⑤must-fix① range:founding/facility util < survival
	_test_no_task_build_emitted()     # ⑥三處 TASK_BUILD 全移除(frontier 不再生任何 {task:TASK_BUILD})
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

# 大 pop + 充足 leader 的隊（真派子隊需 pop*2≥12 + advisor 可拔擢）。
func _mk(pop: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(0, 20):
		for y in range(0, 20):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", pop); team.armed_anon_ratio = 0.0
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.5, "貪婪": 0.5, "慎重": 0.5, "野心": 0.5}
	l.skills = {"統領": 0.5}
	state.persons[10] = l; team.leader_id = 10; team.named_members = [10]
	state.teams[1] = team
	return [state, team]

func _set_forest(state: WorldState, pos: Vector2i) -> void:
	state.world.tiles[pos.x * 1000 + pos.y].terrain = "forest"

# own outpost（軍/民）在 pos，weaponsmith_level 0 → maintain_material need>0。
func _set_own_outpost(state: WorldState, team_id: int, pos: Vector2i, otype: String) -> HexTileData:
	var t: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	t.outpost_owner = team_id; t.outpost_type = otype; t.outpost_level = 1; t.set("weaponsmith_level", 0)
	return t

# 找隊剛派出的建造/擴建子隊。
func _find_sub(state: WorldState, parent_id: int) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id == parent_id:
			return t
	return null

# 驅動子隊 construction 到完工（決定性,無 RNG）：teleport 抵達 → begin_subteam_construction → tick 到 level>0。
func _drive_construction(state: WorldState, sub: TeamData, target: Vector2i) -> HexTileData:
	sub.tile_pos = target
	var tile: HexTileData = state.world.tiles[target.x * 1000 + target.y]
	var os := OutpostSystem.new()
	var began: bool = os.begin_subteam_construction(state, sub)
	_ok(began, "  begin_subteam_construction → start_build 成功(%s)" % sub.current_task)
	if not began:
		return tile
	var guard: int = 0
	while tile.construction_ticks_left > 0 and guard < 2000:
		os._tick_construction(state, tile)
		guard += 1
	return tile

# ①缺料+無 forest outpost+無市場(coin 0)→ founding candidate(delegate:true+build_type:civilian+target=forest)
func _test_founding_candidate() -> void:
	print("--- ①founding candidate ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_own_outpost(state, 1, Vector2i(5, 5), "military")   # own=plains military → own.terrain != forest
	team.resources["material"] = 0.0; team.resources["coin"] = 0.0   # 無 specie → 買不到 → 走採@地形
	_set_forest(state, Vector2i(8, 5))   # 近 forest dist 3
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var found: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		if String(c.get("label", "")) == "maintain_material:location:delegate":
			found = c
	_ok(not found.is_empty(), "缺料+無 forest outpost → founding candidate(maintain_material:location:delegate)")
	if not found.is_empty():
		var td: Dictionary = found["to_task"]
		_ok(td.get("delegate", false) == true, "  to_task.delegate=true(派子隊建)")
		_ok(String(td.get("build_type", "")) == "civilian", "  to_task.build_type=civilian")
		_ok(td.get("target", Vector2i(-1, -1)) == Vector2i(8, 5), "  target=最近 forest tile(8,5)")
		_ok(not td.has("task"), "  ★無 task 欄(不發無 consumer 的 TASK_BUILD)")

# ★★②執行端硬驗真管線:真 material 缺口→frontier_candidates→_dispatch_goal_delegate(型別分支)
#   →子隊 TASK_CONSTRUCT→抵達→begin_subteam_construction→_tick_construction→forest outpost 真建成
func _test_founding_execution_end() -> void:
	print("--- ★★②founding 執行端(真管線→outpost_level>0) ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_own_outpost(state, 1, Vector2i(5, 5), "military")
	# material=90:need_keep(material)=100 → gap 保留(90<100);funding gate 1.5×50=75 → 90≥75 可建。
	team.resources["material"] = 90.0; team.resources["coin"] = 0.0
	_set_forest(state, Vector2i(8, 5))
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cand: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		if String(c.get("label", "")) == "maintain_material:location:delegate":
			cand = c
	_ok(not cand.is_empty(), "真 material 缺口 → founding candidate 出現")
	if cand.is_empty():
		return
	# ★餵真 _dispatch_goal_delegate(測型別判斷分支,非繞過直呼 _dispatch_builder)
	var fai := FactionAISystem.new()
	var dispatched: bool = fai._dispatch_goal_delegate(state, team, cand["to_task"])
	_ok(dispatched, "  _dispatch_goal_delegate(build_type 分支) → 派子隊成功")
	var sub: TeamData = _find_sub(state, 1)
	_ok(sub != null, "  子隊建立")
	if sub == null:
		return
	_ok(sub.current_task == TeamData.TASK_CONSTRUCT, "  子隊 current_task=TASK_CONSTRUCT")
	_ok(String(sub.task_extra_data.get("build_type", "")) == "civilian", "  子隊 build_type=civilian")
	var tile: HexTileData = _drive_construction(state, sub, Vector2i(8, 5))
	_ok(tile.outpost_level > 0, "  ★★forest outpost 真建成(outpost_level=%d>0)=真閉環非假" % tile.outpost_level)
	_ok(tile.terrain == "forest", "  建成地=forest(採 material 閉環)")

# ★★③S4 :171 型別不符→派子隊建 new outpost 真建成
func _test_s4_new_outpost_execution() -> void:
	print("--- ★★③S4 new outpost 執行端(:171) ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	# own outpost=civilian(5,5),但 weaponsmith 需 military → 型別不符 → 建 new military outpost
	_set_own_outpost(state, 1, Vector2i(5, 5), "civilian")
	team.tile_pos = Vector2i(6, 6)   # 站空格(未建)→ :171 cur.outpost_level==0
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0; team.resources["coin"] = 0.0
	# ★手設 build_F goal(civ own→weaponsmith 型別不符,ensure 會退它;mirror s4 test 直設)。
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cand: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		var td: Dictionary = c.get("to_task", {})
		if td.get("delegate", false) and String(td.get("build_type", "")) == "military":
			cand = c
	_ok(not cand.is_empty(), "型別不符 → founding candidate(build_type=military)")
	if cand.is_empty():
		return
	var fai := FactionAISystem.new()
	var dispatched: bool = fai._dispatch_goal_delegate(state, team, cand["to_task"])
	_ok(dispatched, "  _dispatch_goal_delegate → 派子隊")
	var sub: TeamData = _find_sub(state, 1)
	if sub == null:
		_ok(false, "  子隊建立")
		return
	var tile: HexTileData = _drive_construction(state, sub, Vector2i(6, 6))
	_ok(tile.outpost_level > 0 and tile.outpost_type == "military",
		"  ★★new military outpost 真建成(level=%d,type=%s)" % [tile.outpost_level, tile.outpost_type])

# ★★④S4 :178 → facility candidate → weaponsmith 真建成(level>0)
func _test_s4_facility_execution() -> void:
	print("--- ★★④S4 facility 執行端(:178) ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	# own=military(5,5) lv1(allowed for weaponsmith),weaponsmith_level 0,料足,pop 足 → facility candidate
	var own: HexTileData = _set_own_outpost(state, 1, Vector2i(5, 5), "military")
	own.public_storage = {"material": 100000.0, "tools": 100000.0}   # 擴建走公庫+私產合併池
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0; team.resources["coin"] = 0.0
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cand: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		var td: Dictionary = c.get("to_task", {})
		if td.get("delegate", false) and String(td.get("facility", "")) == "weaponsmith":
			cand = c
	_ok(not cand.is_empty(), "料足+own military outpost → facility candidate(facility=weaponsmith)")
	if cand.is_empty():
		return
	var td2: Dictionary = cand["to_task"]
	_ok(not td2.has("build_type"), "  facility candidate 無 build_type(≠founding)")
	var fai := FactionAISystem.new()
	var dispatched: bool = fai._dispatch_goal_delegate(state, team, td2)
	_ok(dispatched, "  _dispatch_goal_delegate(facility 分支) → 派擴建子隊")
	var sub: TeamData = _find_sub(state, 1)
	if sub == null:
		_ok(false, "  子隊建立")
		return
	_ok(sub.current_task == TeamData.TASK_EXPAND, "  子隊 current_task=TASK_EXPAND")
	var tile: HexTileData = _drive_construction(state, sub, Vector2i(5, 5))
	_ok(int(tile.get("weaponsmith_level")) > 0,
		"  ★★weaponsmith 真建成(weaponsmith_level=%d>0)" % int(tile.get("weaponsmith_level")))

# ⑤must-fix① range:founding/facility candidate util ≤ GOAL_UTIL_CAP < survival boost
func _test_util_guardrail() -> void:
	print("--- ⑤must-fix① range ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_own_outpost(state, 1, Vector2i(5, 5), "military")
	team.resources["material"] = 0.0; team.resources["coin"] = 0.0
	_set_forest(state, Vector2i(8, 5))
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		_ok(float(c.get("util", 99.0)) <= GoalResolver.GOAL_UTIL_CAP + 0.001,
			"  candidate util %.3f ≤ GOAL_UTIL_CAP %.2f" % [float(c.get("util", 0)), GoalResolver.GOAL_UTIL_CAP])
	_ok(GoalResolver.GOAL_UTIL_CAP < 2.0, "  GOAL_UTIL_CAP < survival floor(2.0)=goal 恆不奪 survival argmax")

# ⑥三處 TASK_BUILD 全移除:frontier_candidates 任何 candidate 都不帶 {task:TASK_BUILD}
func _test_no_task_build_emitted() -> void:
	print("--- ⑥無 TASK_BUILD emit ---")
	var scenarios: Array = [
		["military", Vector2i(5, 5), Vector2i(5, 5), 0.0],    # founding forest
		["civilian", Vector2i(5, 5), Vector2i(6, 6), 400.0],  # new outpost mismatch
		["military", Vector2i(5, 5), Vector2i(5, 5), 400.0],  # facility
	]
	var any_build: bool = false
	for sc in scenarios:
		var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
		var own: HexTileData = _set_own_outpost(state, 1, Vector2i(5, 5), String(sc[0]))
		own.public_storage = {"material": 400.0, "tools": 20.0}
		team.tile_pos = sc[2]
		team.resources["material"] = float(sc[3]); team.resources["tools"] = 20.0; team.resources["coin"] = 0.0
		_set_forest(state, Vector2i(8, 5))
		GoalResolver.ensure_maintain_goals(state, team)
		var ctx: DecisionContext = DecisionContext.gather(state, team)
		for c in GoalResolver.frontier_candidates(state, team, ctx):
			if String(c.get("to_task", {}).get("task", "")) == TeamData.TASK_BUILD:
				any_build = true
	_ok(not any_build, "★frontier_candidates 不再生任何 {task:TASK_BUILD}(死路全清)")
