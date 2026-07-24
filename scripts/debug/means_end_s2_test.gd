extends SceneTree

# means-end S2 資源型 resolver TDD（HOW spec §10 S2）。第一實質 slice:goal frontier 資源型接通。
# 組件 A(goal 生成)/B(registry 5 maintain)/C(resolver 資源型 walk)/E(need_keep 泛化)/G(util 護欄)。
# ★whole-system-first:S2 只 resource 前置「買」;定位/設施 stub。

var _fail: int = 0

func _initialize() -> void:
	_test_resource_candidate_appears()  # ①缺 res+有市場+籌碼→取得 candidate 真出現
	_test_needkeep_generalized()        # ②need_keep 泛化(非 material/tools 的 res 也算 need)
	_test_nonresource_prereq_stub()     # ③定位/設施前置 S2 回無 candidate(stub 邊界)
	_test_util_guardrail_range()        # ★★④must-fix① range 斷言(絕境 goal util<survival boost)
	_test_ensure_goals_idempotent()     # 組件 A:5 maintain goal 冪等生成
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

func _mk() -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 9):
		for y in range(3, 9):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)
	var l := PersonData.new(); l.id = 10; l.values = {"貪婪": 0.5, "慎重": 0.5, "野心": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team]

# 建一個「他隊 market outpost 有 food stock」+ 讓本隊 team_market_known 認得（belief-gate）
func _add_known_food_market(state: WorldState, team_id: int, pos: Vector2i) -> void:
	var tile: HexTileData = state.world.tiles[pos.x * 1000 + pos.y]
	tile.outpost_owner = 99; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.public_storage = {"food": 500.0}
	if not state.team_market_known.has(team_id):
		state.team_market_known[team_id] = {}
	state.team_market_known[team_id][pos.x * 1000 + pos.y] = true

# ① 缺 res + 有已知市場 + 有籌碼 → 取得 candidate 真出現（資源型 resolution 接通）
func _test_resource_candidate_appears() -> void:
	print("--- ①resource candidate 出現 ---")
	var w: Array = _mk()
	var state: WorldState = w[0]; var team: TeamData = w[1]
	team.resources["food"] = 0.0   # 缺 food（<need_keep）
	team.resources["coin"] = 100.0  # 有籌碼
	_add_known_food_market(state, 1, Vector2i(7, 5))
	GoalResolver.ensure_maintain_goals(state, team)   # 生 maintain goal
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	var found_food: bool = false
	for c in cands:
		if String(c.get("label", "")) == "maintain_food:resource":
			found_food = true
			_ok(c["to_task"]["task"] == TeamData.TASK_TRADE, "food candidate to_task=TASK_TRADE（買取得）")
	_ok(found_food, "缺 food+有市場+籌碼 → maintain_food:resource candidate 出現（資源型 resolution 接通，打破 byte-identical）")

# ② need_keep 泛化：非 material/tools 的 res（weapon）也算 need（組件 E 脫硬 scope）
func _test_needkeep_generalized() -> void:
	print("--- ②need_keep 泛化 ---")
	var w: Array = _mk()
	var lv: Dictionary = w[0].persons[10].values
	var nk_weapon: float = NeedOracle.need_keep(w[0], w[1], "weapon_melee_low", lv)
	_ok(nk_weapon > 0.0, "need_keep(weapon_melee_low)>0（非 material/tools 的 res 也算 need，泛化，got %.1f）" % nk_weapon)

# ③ 定位/設施前置 → S2 回無 candidate（stub 邊界）
func _test_nonresource_prereq_stub() -> void:
	print("--- ③定位/設施前置 stub ---")
	var w: Array = _mk()
	var state: WorldState = w[0]; var team: TeamData = w[1]
	# 注入一個帶 location 前置的臨時 goal（S2 應回無 candidate）
	GoalRegistry.REGISTRY["_test_loc_goal"] = {"prereqs": [{"kind": GoalRegistry.PREREQ_LOCATION, "cond": "forest"}], "payoff": 1.0}
	team.goal_state = [{"goal_type": "_test_loc_goal", "target": null, "created_tick": 0, "status": "active"}]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	GoalRegistry.REGISTRY.erase("_test_loc_goal")   # 清 test 注入
	_ok(cands.is_empty(), "location 前置 goal → S2 回無 candidate（定位=S3 stub 邊界，got %d）" % cands.size())

# ★★④ must-fix① range 斷言：絕境 food_days→0，任意 payoff 的 goal candidate util < survival-boosted static util
func _test_util_guardrail_range() -> void:
	print("--- ★★④must-fix① util 護欄 range 斷言 ---")
	var ctx_desp := DecisionContext.new()
	ctx_desp.food_days = 0.001   # 絕境 food→0
	# 任意巨 payoff → goal candidate util 仍 < SURVIVAL_BOOST_MAX（survival static option 絕境至少 +此 boost）
	# 硬護欄：任意巨 payoff → clamp 保 util < SURVIVAL_BOOST_MAX（survival static option 絕境至少 +此 boost）。
	var u_huge: float = GoalResolver._candidate_util(1.0e9, ctx_desp)
	_ok(u_huge < DecisionEngine.SURVIVAL_BOOST_MAX, "絕境 goal candidate util(payoff 1e9)=%.3f < SURVIVAL_BOOST_MAX %.1f（clamp 硬護欄:goal 永不蓋活命）" % [u_huge, DecisionEngine.SURVIVAL_BOOST_MAX])
	# dev_coeff press：中等 payoff → 絕境壓到趨零（遠慾望歸零讓 survival 奪 argmax）。
	var u_mod: float = GoalResolver._candidate_util(1.0, ctx_desp)
	_ok(u_mod < 0.01, "絕境 dev_coeff→0 → 中等 payoff goal util≈0（%.4f，遠慾望壓制）" % u_mod)
	# 食足 → dev_coeff=1 但仍 clamp GOAL_UTIL_CAP（不無界爆）
	var ctx_ok := DecisionContext.new(); ctx_ok.food_days = 100.0
	var u_ok: float = GoalResolver._candidate_util(1.0e9, ctx_ok)
	_ok(is_equal_approx(u_ok, GoalResolver.GOAL_UTIL_CAP), "食足巨 payoff → clamp GOAL_UTIL_CAP %.1f（有界不無限，got %.2f）" % [GoalResolver.GOAL_UTIL_CAP, u_ok])

# 組件 A：ensure_maintain_goals 冪等（5 goal，重複呼不增）
func _test_ensure_goals_idempotent() -> void:
	print("--- 組件A goal 冪等 ---")
	var w: Array = _mk()
	GoalResolver.ensure_maintain_goals(w[0], w[1])
	var n1: int = w[1].goal_state.size()
	GoalResolver.ensure_maintain_goals(w[0], w[1])   # 再呼
	var n2: int = w[1].goal_state.size()
	_ok(n1 == 5 and n2 == 5, "5 maintain goal 冪等生成（重複呼不增，%d==%d==5）" % [n1, n2])
