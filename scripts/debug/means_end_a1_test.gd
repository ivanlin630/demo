extends SceneTree

# means-end A1 forest founding 修 TDD（spec 2026-07-25 §5，systems 二裁訂正版）。
# 根:goal_resolver 三處 {task:TASK_BUILD} 無 consumer=假閉環。裁後 scope:
#   ①S3 remote forest founding(異格)→delegate _dispatch_builder(子隊真移動→抵達→建)
#   ②S4 :178 facility(same-tile own outpost)→就地/派子隊分流(owner 在場=就地 _subteam_upgrade_facility)
#   ③S4 :171 same-tile founding→移除 candidate(無母隊就地 outpost-build 路;followup)
# ★★TDD execution-end 驅真 movement/arrival 非 teleport(首版 teleport 遮 same-tile-no-arrival bug)。

var _fail: int = 0

func _initialize() -> void:
	_test_remote_founding_candidate()   # ①S3 remote forest → founding candidate(delegate+build_type civilian)
	_test_remote_founding_real_move()   # ★★②驅真 movement:子隊真移動→抵達→forest outpost 真建成
	_test_facility_samesite_defers_infra()  # ③same-tile facility(owner 在場)→defer infra(不生 candidate,不壟斷 build slot)
	_test_facility_remote_execution()   # ★★③b remote facility(owner 遠離)→派子隊真移動→真建成
	_test_171_removed()                 # ④:171 same-tile founding candidate 移除(靜默)
	_test_util_guardrail()              # ⑤must-fix① range
	_test_no_task_build_emitted()       # ⑥三處 TASK_BUILD 全移除
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

func _set_own_outpost(state: WorldState, team_id: int, pos: Vector2i, otype: String) -> HexTileData:
	var t: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	t.outpost_owner = team_id; t.outpost_type = otype; t.outpost_level = 1; t.set("weaponsmith_level", 0)
	return t

func _find_sub(state: WorldState, parent_id: int) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id == parent_id:
			return t
	return null

# ①缺料+無 forest outpost+無市場 → founding candidate(delegate+build_type civilian+target=remote forest)
func _test_remote_founding_candidate() -> void:
	print("--- ①remote founding candidate ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_own_outpost(state, 1, Vector2i(5, 5), "military")   # own plains military → own.terrain != forest
	team.resources["material"] = 0.0; team.resources["coin"] = 0.0
	_set_forest(state, Vector2i(8, 5))   # remote forest dist 3
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var found: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		if String(c.get("label", "")) == "maintain_material:location:delegate":
			found = c
	_ok(not found.is_empty(), "缺料+無 forest outpost → remote founding candidate")
	if not found.is_empty():
		var td: Dictionary = found["to_task"]
		_ok(td.get("delegate", false) and String(td.get("build_type", "")) == "civilian" \
				and td.get("target") == Vector2i(8, 5) and not td.has("task"),
			"delegate+build_type civilian+target=remote forest(8,5)+無 task 欄")

# ★★②驅真 movement:_dispatch_goal_delegate→子隊真移動(5,5)→(8,5)→arrival 觸發 begin_subteam_construction→建成
func _test_remote_founding_real_move() -> void:
	print("--- ★★②remote founding 驅真 movement ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_own_outpost(state, 1, Vector2i(5, 5), "military")
	team.resources["material"] = 90.0; team.resources["coin"] = 0.0   # gap 保留(90<100)+可 fund(≥75)
	_set_forest(state, Vector2i(8, 5))
	GoalResolver.ensure_maintain_goals(state, team)
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cand: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		if String(c.get("label", "")) == "maintain_material:location:delegate":
			cand = c
	if cand.is_empty():
		_ok(false, "founding candidate 出現"); return
	var fai := FactionAISystem.new()
	_ok(fai._dispatch_goal_delegate(state, team, cand["to_task"]), "_dispatch_goal_delegate(build_type 分支)→派子隊")
	var sub: TeamData = _find_sub(state, 1)
	if sub == null:
		_ok(false, "子隊建立"); return
	_ok(sub.tile_pos == Vector2i(5, 5) and sub.move_target == Vector2i(8, 5),
		"子隊生於母隊格(5,5)、move_target=遠地(8,5)(異格→真移動非同格)")
	# ★驅真 movement + construction（非 teleport）：MovementSystem 逐 tick 移動→抵達 arrival→begin_subteam_construction
	var mv := MovementSystem.new(); var os := OutpostSystem.new()
	var ftile: HexTileData = state.world.tiles[8 * 1000 + 5]
	var arrived_tick: int = -1
	for i in range(600):
		mv.process(state, [sub.team_id], 1.0, WorldState.TICKS_PER_HOUR)
		if arrived_tick == -1 and sub.tile_pos == Vector2i(8, 5):
			arrived_tick = i
		if ftile.construction_ticks_left > 0:
			os._tick_construction(state, ftile)
		state.world.current_tick += WorldState.TICKS_PER_HOUR
		if ftile.outpost_level > 0:
			break
	_ok(arrived_tick >= 0, "子隊真移動抵達(8,5)(tick %d，非 teleport)" % arrived_tick)
	_ok(ftile.outpost_level > 0, "★★arrival→begin_subteam_construction→forest outpost 真建成(level=%d>0)" % ftile.outpost_level)
	_ok(ftile.terrain == "forest", "建成地=forest(採 material 閉環)")

# ★③same-tile facility(owner 在場 own outpost)→ defer infra path(不生 goal candidate)。
# 二裁意圖「接 infra path 非另立子隊路」:infra desire-based _pick_facility 就地建(較 goal REGISTRY-order 聰明+不撞 build slot)。
# 真建成由 infra path 負責=whole headless 15360 礦村鑄幣覆蓋(此處驗 goal 不生同格 candidate=不壟斷 build slot)。
func _test_facility_samesite_defers_infra() -> void:
	print("--- ③same-tile facility defer infra ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	var own: HexTileData = _set_own_outpost(state, 1, Vector2i(5, 5), "military")   # team 站 (5,5)=own outpost=owner 在場
	own.public_storage = {"material": 100000.0, "tools": 100000.0}
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0; team.resources["coin"] = 0.0
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var has_facility_cand: bool = false
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		if String(c.get("to_task", {}).get("facility", "")) != "":
			has_facility_cand = true
	_ok(not has_facility_cand, "★owner 在場 same-tile facility → 無 goal candidate(defer infra path 就地建,不壟斷 build slot=修 15360)")

# ★③b remote facility(owner 遠離 own outpost)→ 派子隊真移動→抵達→facility 真建成
func _test_facility_remote_execution() -> void:
	print("--- ★★③b remote facility 派子隊真建成 ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	var own: HexTileData = _set_own_outpost(state, 1, Vector2i(5, 5), "military")   # own outpost (5,5)
	own.public_storage = {"material": 100000.0, "tools": 100000.0}
	team.tile_pos = Vector2i(9, 5)   # ★owner 遠離 own outpost(dist 4)→remote→派子隊
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0; team.resources["coin"] = 0.0
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cand: Dictionary = {}
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		var td: Dictionary = c.get("to_task", {})
		if td.get("delegate", false) and String(td.get("facility", "")) == "weaponsmith":
			cand = c
	if cand.is_empty():
		_ok(false, "remote facility candidate 出現(owner 遠離)"); return
	_ok(cand["to_task"].get("target") == Vector2i(5, 5), "target=own outpost(5,5)(非母隊格→remote 子隊)")
	var fai := FactionAISystem.new()
	_ok(fai._dispatch_goal_delegate(state, team, cand["to_task"]), "_dispatch_goal_delegate(facility remote)→派子隊")
	var sub: TeamData = _find_sub(state, 1)
	if sub == null:
		_ok(false, "子隊建立"); return
	# 驅真 movement:子隊 (9,5)→(5,5) own outpost → arrival → begin_subteam_construction(TASK_EXPAND)
	var mv := MovementSystem.new(); var os := OutpostSystem.new()
	for i in range(600):
		mv.process(state, [sub.team_id], 1.0, WorldState.TICKS_PER_HOUR)
		if own.construction_ticks_left > 0:
			os._tick_construction(state, own)
		state.world.current_tick += WorldState.TICKS_PER_HOUR
		if int(own.get("weaponsmith_level")) > 0:
			break
	_ok(int(own.get("weaponsmith_level")) > 0, "★★remote 子隊真移動抵達→weaponsmith 真建成(level=%d>0)" % int(own.get("weaponsmith_level")))

# ④:171 same-tile founding candidate 移除:own type 不符+隊站空 tile → 無 build_type candidate(靜默)
func _test_171_removed() -> void:
	print("--- ④:171 same-tile founding 移除 ---")
	var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
	_set_own_outpost(state, 1, Vector2i(5, 5), "civilian")   # civilian own,但 weaponsmith 需 military
	team.tile_pos = Vector2i(6, 6)   # 站空格
	team.resources["material"] = 100000.0; team.resources["tools"] = 100000.0; team.resources["coin"] = 0.0
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var has_founding: bool = false
	for c in GoalResolver.frontier_candidates(state, team, ctx):
		if String(c.get("to_task", {}).get("build_type", "")) != "":
			has_founding = true
	_ok(not has_founding, "★型別不符+站空 tile → 無 same-tile founding candidate(移除=靜默,followup)")

# ⑤must-fix① range:candidate util ≤ GOAL_UTIL_CAP < survival
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
			"candidate util %.3f ≤ GOAL_UTIL_CAP %.2f" % [float(c.get("util", 0)), GoalResolver.GOAL_UTIL_CAP])
	_ok(GoalResolver.GOAL_UTIL_CAP < 2.0, "GOAL_UTIL_CAP < survival floor(2.0)")

# ⑥三處 TASK_BUILD 全移除
func _test_no_task_build_emitted() -> void:
	print("--- ⑥無 TASK_BUILD emit ---")
	var scenarios: Array = [
		["military", Vector2i(5, 5), Vector2i(5, 5), 0.0],
		["civilian", Vector2i(5, 5), Vector2i(6, 6), 100000.0],
		["military", Vector2i(5, 5), Vector2i(5, 5), 100000.0],
	]
	var any_build: bool = false
	for sc in scenarios:
		var w: Array = _mk(20); var state: WorldState = w[0]; var team: TeamData = w[1]
		var own: HexTileData = _set_own_outpost(state, 1, Vector2i(5, 5), String(sc[0]))
		own.public_storage = {"material": 100000.0, "tools": 100000.0}
		team.tile_pos = sc[2]
		team.resources["material"] = float(sc[3]); team.resources["tools"] = 100000.0; team.resources["coin"] = 0.0
		team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]
		_set_forest(state, Vector2i(8, 5))
		GoalResolver.ensure_maintain_goals(state, team)
		var ctx: DecisionContext = DecisionContext.gather(state, team)
		for c in GoalResolver.frontier_candidates(state, team, ctx):
			if String(c.get("to_task", {}).get("task", "")) == TeamData.TASK_BUILD:
				any_build = true
	_ok(not any_build, "★frontier_candidates 不生任何 {task:TASK_BUILD}")
