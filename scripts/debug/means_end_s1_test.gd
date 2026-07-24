extends SceneTree

# means-end S1 骨架 TDD（HOW spec 2026-07-24 §10 S1）。byte-identical no-op proof:
# 接線骨架就位(組件 A goal_state / B GoalRegistry / C GoalResolver / G rank hook)但零行為變(candidate 空)。
# ★whole-system-first:S1 只骨架,resolver stub 回 []。

var _fail: int = 0

func _initialize() -> void:
	_test_goal_state_field()      # ①TeamData.goal_state 欄存在+空初始
	_test_resolver_stub_empty()   # ②GoalResolver.frontier_candidates 回 []
	_test_registry_skeleton()     # 組件 B:GoalRegistry 5 kind 常數+空 REGISTRY
	_test_rank_hook_noop()        # ③rank hook 存在但 no-op（goal_state 空/非空皆 []→rank 只 static option）
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

# ① goal_state 欄存在 + 空初始（組件 A）
func _test_goal_state_field() -> void:
	print("--- ①goal_state 欄 ---")
	var t := TeamData.new()
	_ok(t.goal_state is Array and t.goal_state.is_empty(), "TeamData.goal_state 存在 + 空初始 []（組件 A，跨 tick 持久遠慾望列表）")

# ② GoalResolver.frontier_candidates 回 []（組件 C stub）
func _test_resolver_stub_empty() -> void:
	print("--- ②GoalResolver stub ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 1
	var ctx := DecisionContext.new()
	var cands: Array = GoalResolver.frontier_candidates(state, team, ctx)
	_ok(cands is Array and cands.is_empty(), "frontier_candidates 回 []（S1 stub，byte-identical no-op 根）")
	# null state/team（harness 情境）亦不崩
	_ok(GoalResolver.frontier_candidates(null, null, ctx).is_empty(), "null state/team → 亦 []（harness 安全）")

# 組件 B：GoalRegistry 5 前置 kind 常數 + 空 REGISTRY
func _test_registry_skeleton() -> void:
	print("--- 組件B GoalRegistry ---")
	var kinds: Array = [GoalRegistry.PREREQ_RESOURCE, GoalRegistry.PREREQ_LOCATION, \
		GoalRegistry.PREREQ_MANPOWER, GoalRegistry.PREREQ_FACILITY, GoalRegistry.PREREQ_SUBGOAL]
	_ok(kinds == ["resource", "location", "manpower", "facility", "subgoal"], "5 前置 kind 常數就位（WHAT §5 固定五種）")
	_ok(GoalRegistry.REGISTRY is Dictionary and GoalRegistry.REGISTRY.is_empty(), "REGISTRY 空表結構（S1 空 data，S2+ 填 goal 定義）")

# ③ rank hook no-op：goal_state 空或非空，frontier stub 回 []→rank 池只含 static option（無 goal candidate）
func _test_rank_hook_noop() -> void:
	print("--- ③rank hook no-op ---")
	var ctx := DecisionContext.new()
	ctx.leader_values = {"貪婪": 0.5}
	ctx.need_urgency = PackedFloat32Array()
	# rank_scored_ctx 帶 state/team null（harness）→ hook skip；帶非 null 但 frontier stub []→hook no-op。
	var scored_nohook: Array = DecisionEngine.rank_scored_ctx(ctx, "")   # 無 state/team
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 1
	team.goal_state = [{"goal_type": "build_weaponsmith", "target": null, "created_tick": 0, "status": "active"}]   # 即使掛 goal
	var scored_hook: Array = DecisionEngine.rank_scored_ctx(ctx, "", state, team)
	# 兩者無 goal candidate（無 "cand" key entry）——hook 存在但 stub []→no-op。
	var has_cand: bool = false
	for e in scored_hook:
		if e.has("cand"): has_cand = true
	_ok(not has_cand, "rank 池無 goal candidate（frontier stub []→hook no-op，即使 goal_state 掛 goal）")
	_ok(scored_hook.size() == scored_nohook.size(), "帶 state/team 與否 rank 池 size 同（no-op，size %d==%d）" % [scored_hook.size(), scored_nohook.size()])
