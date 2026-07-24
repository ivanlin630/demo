extends SceneTree

# means-end S7 收尾 TDD（HOW spec §10 S7）。①perf cadence-gate(goal 生成非每 decide)②goal 掛退 lifecycle
# (build_F 建成/desire 掉→退,免 goal_state 累積;maintain 冪等留)。★S7 merge=means-end whole-done。

var _fail: int = 0

func _initialize() -> void:
	_test_cadence_gate()          # ①cadence-gate:goal 生成非每 decide,cadence tick 一次
	_test_build_goal_retire()     # ②build_F 建成→退(移除,不累積)
	_test_maintain_idempotent()   # ③maintain goal 冪等持久(不誤退)
	_test_util_guardrail()        # ④must-fix① range regression
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

func _mk(outpost_type: String) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 9):
		for y in range(3, 9):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10); team.armed_anon_ratio = 0.0
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.5, "貪婪": 0.5, "慎重": 0.5, "野心": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	if outpost_type != "":
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = outpost_type; tile.outpost_level = 1
	return [state, team]

# ① cadence-gate：cadence 內二次呼不重跑（perf）；過 cadence 才重跑
func _test_cadence_gate() -> void:
	print("--- ①cadence-gate ---")
	var w: Array = _mk(""); var state: WorldState = w[0]; var team: TeamData = w[1]
	GoalResolver.ensure_maintain_goals(state, team)   # tick 1000 → 生 5 maintain + goal_eval_next_tick 設
	var n1: int = team.goal_state.size()
	team.goal_state = []   # 手動清空
	GoalResolver.ensure_maintain_goals(state, team)   # 同 tick 1000 → gate 早退,不重生
	_ok(team.goal_state.is_empty(), "cadence 內二次呼 → gate 早退不重生（%d，perf 節流非每 decide）" % team.goal_state.size())
	state.world.current_tick = 1000 + GoalResolver.GOAL_EVAL_CADENCE   # 過 cadence
	GoalResolver.ensure_maintain_goals(state, team)
	_ok(team.goal_state.size() == n1 and n1 == 5, "過 cadence → 重生 5 maintain（%d==%d==5）" % [team.goal_state.size(), n1])

# ② build_F 建成 → 退（移除，不無限累積）
func _test_build_goal_retire() -> void:
	print("--- ②build_F 建成退 ---")
	var w: Array = _mk("civilian"); var state: WorldState = w[0]; var team: TeamData = w[1]
	# 掛一個 build_workshop goal + workshop 已建成
	team.goal_state = [{"goal_type": "build_workshop", "target": null, "created_tick": 0, "status": "active"}]
	state.world.tiles[5 * 1000 + 5].set("manufacturing_level", 2)   # 已建成
	team.goal_eval_next_tick = 0   # 確保過 cadence
	GoalResolver.ensure_maintain_goals(state, team)
	var has_workshop_goal: bool = false
	for g in team.goal_state:
		if String(g.get("goal_type", "")) == "build_workshop": has_workshop_goal = true
	_ok(not has_workshop_goal, "build_workshop 建成 → 退（goal_state 移除，免無限累積 satisfied goal leak）")

# ③ maintain goal 冪等持久（不誤退）
func _test_maintain_idempotent() -> void:
	print("--- ③maintain 冪等持久 ---")
	var w: Array = _mk(""); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.goal_eval_next_tick = 0
	GoalResolver.ensure_maintain_goals(state, team)
	var maintain_n: int = 0
	for g in team.goal_state:
		if GoalRegistry.MAINTAIN_GOAL_RES.has(String(g.get("goal_type", ""))): maintain_n += 1
	# 再跑（過 cadence）→ maintain 仍 5（不誤退）
	state.world.current_tick += GoalResolver.GOAL_EVAL_CADENCE
	GoalResolver.ensure_maintain_goals(state, team)
	var maintain_n2: int = 0
	for g in team.goal_state:
		if GoalRegistry.MAINTAIN_GOAL_RES.has(String(g.get("goal_type", ""))): maintain_n2 += 1
	_ok(maintain_n == 5 and maintain_n2 == 5, "maintain 5 goal 冪等持久（%d→%d，退 lifecycle 不誤退 maintain）" % [maintain_n, maintain_n2])

# ④ must-fix① range 斷言 regression（護欄不動）
func _test_util_guardrail() -> void:
	print("--- ④must-fix① regression ---")
	var c := DecisionContext.new(); c.food_days = 0.001; c.leader_values = {"慎重": 0.5}
	var u: float = GoalResolver._candidate_util(1.0e9, c, 20.0)
	_ok(u < DecisionEngine.SURVIVAL_BOOST_MAX, "絕境 goal util(%.2f) < SURVIVAL_BOOST_MAX %.1f（護欄 S7 不動仍守）" % [u, DecisionEngine.SURVIVAL_BOOST_MAX])
