extends SceneTree

# god-view Slice F F1 TDD（spec 2026-07-19-godview-slice-F）。
# F1：缺 belief tile_pos → sentinel (-1,-1) + per-site guard（不默認 live 真位=god-view 回潮；不瞎追 live）。
# 3 site 直測：scout(_commit_conquest_attack)/envoy(_dispatch_envoy)/encircle(_assign_encirclement)。
# （envoy tracking:1368 guard 由 determinism + no-crash + 鏡射覆蓋。）

var _fail: int = 0

func _initialize() -> void:
	_test_scout_no_belief()
	_test_envoy_no_belief()
	_test_encircle_no_belief()
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

func _mk_team(state: WorldState, tid: int, fid: int, pos: Vector2i, lid: int) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.faction_id = fid; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[tid] = t
	if lid != -1:
		var l := PersonData.new(); l.id = lid; state.persons[lid] = l; t.leader_id = lid
	return t

func _test_scout_no_belief() -> void:
	print("--- F1 scout：無 belief prey 位 → 不 scout（return false）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var team := _mk_team(state, 1, 5, Vector2i(0, 0), 10)
	state.persons[10].values = {"慎重": 0.9}
	var prey := _mk_team(state, 2, 6, Vector2i(9, 9), -1)   # prey live @(9,9)，但 obs 無 belief
	state.team_discovered[1] = [2]
	# 無 team_intel → best_estimate 無 tile_pos → scout_pos sentinel (-1,-1) → guard return false
	var ok: bool = FactionAISystem.new()._commit_conquest_attack(state, team, 2)
	_ok(not ok, "無 belief prey → _commit_conquest_attack 回 false（不 scout）")
	_ok(team.current_task != TeamData.TASK_SCOUT, "無 belief → 未派 TASK_SCOUT（不瞎追 live 9,9）")

func _test_envoy_no_belief() -> void:
	print("--- F1 envoy dispatch：無 belief target 位 → 不派 envoy（return false）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var mother := _mk_team(state, 1, 5, Vector2i(0, 0), 10)
	var target := _mk_team(state, 2, 6, Vector2i(9, 9), -1)   # target live @(9,9)，obs 無 belief
	state.team_discovered[1] = [2]
	var ok: bool = FactionAISystem.new()._dispatch_envoy(state, mother, 2, "found")
	_ok(not ok, "無 belief target → _dispatch_envoy 回 false（無位不派）")

func _test_encircle_no_belief() -> void:
	print("--- F1 encircle：無 belief target 位 → 不設 strategic_assignments ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var f := FactionData.new(); f.faction_id = 5; f.leader_team_id = 1; f.member_team_ids = [1, 2]; state.factions[5] = f
	var leader_t := _mk_team(state, 1, 5, Vector2i(0, 0), 10)
	var member := _mk_team(state, 2, 5, Vector2i(1, 0), 20)
	var target := _mk_team(state, 3, 6, Vector2i(9, 9), -1)   # 敵 live @(9,9)，leader 無 belief
	state.team_discovered[1] = [3]
	StrategicAiSystem.new()._assign_encirclement(state, f, 3)
	_ok(member.strategic_assignments.is_empty(), "無 belief target → member 無 encircle assignment（不瞎算座標）")
	_ok(leader_t.strategic_assignments.is_empty(), "無 belief target → leader 無 encircle assignment")
