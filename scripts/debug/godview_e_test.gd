extends SceneTree

# god-view Slice E TDD（spec 2026-07-20-godview-slice-E）。
# 4 真 leak：E1 _commit_conquest_attack / E2 _try_join_target / E3 found_subjugate / E5 breakout。
# 修＝move_target/方向讀 BeliefSystem.belief_pos(last-seen) 非 live tile_pos；無 belief→不 dispatch。
# 感知鐵律：決策移動目標讀他隊當前位一律 belief last-seen；敵脫視野→照最後見位追=伏擊/佯動 intended。
# E3 深埋 _evaluate_independent_strategy（重 setup）→同 E1 belief_pos 範式 + grep-audit 驗（見 handback）。

var _fail: int = 0

func _initialize() -> void:
	_test_e1_attack_follows_belief()   # E1 征服攻擊 move_target 跟 belief 非 live
	_test_e2_join_follows_belief()     # E2 JOIN move_target 跟 belief 非 live
	_test_e2_join_no_belief()          # E2 無 belief→不 JOIN dispatch
	_test_e5_breakout_no_belief()      # E5 突圍無 belief 敵位→不設 assignment（不瞎算 live）
	_test_e5_escape_dir_uses_positions() # E5 _find_escape_dir 用傳入(belief)位算逃向
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

# obs 對 tgt 的 belief（跨-faction last-seen）：直設 team_intel（同 slice2 測範式）。
func _set_belief(state: WorldState, obs: int, tgt: int, bpos: Vector2i) -> void:
	if not state.team_intel.has(obs): state.team_intel[obs] = {}
	state.team_intel[obs][tgt] = {
		"tier": 2, "population_est": 5, "tile_pos": bpos,
		"last_tick": state.world.current_tick, "armed_est": 2,
	}

# E1：征服攻擊。prey live @(9,9)、belief @(3,3) → move_target 應跟 belief(3,3) 非 live(9,9)。
func _test_e1_attack_follows_belief() -> void:
	print("--- E1 征服攻擊 move_target 跟 belief 非 live ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var team := _mk_team(state, 1, 5, Vector2i(0, 0), 10)
	state.persons[10].values = {"慎重": 0.0}   # 莽者→confident_enough 恆過→走攻擊路（非 scout）
	var _prey := _mk_team(state, 2, 6, Vector2i(9, 9), -1)   # prey live @(9,9)
	state.team_discovered[1] = [2]
	_set_belief(state, 1, 2, Vector2i(3, 3))   # belief @(3,3)≠live
	var ok: bool = FactionAISystem.new()._commit_conquest_attack(state, team, 2)
	_ok(ok, "confident 攻擊 dispatch 成功")
	_ok(team.move_target == Vector2i(3, 3), "move_target=belief(3,3) 非 live(9,9)（got %s）" % str(team.move_target))
	_ok(team.move_target != Vector2i(9, 9), "★未讀 live god-view 位")

# E2：subteam JOIN。target live @(9,9)、belief @(5,5) → move_target 跟 belief。
func _test_e2_join_follows_belief() -> void:
	print("--- E2 JOIN move_target 跟 belief 非 live ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var sub := _mk_team(state, 1, 5, Vector2i(0, 0), 10)
	sub.parent_team_id = 99
	var _tgt := _mk_team(state, 2, 6, Vector2i(9, 9), -1)   # target live @(9,9)
	state.team_discovered[1] = [2]
	_set_belief(state, 1, 2, Vector2i(5, 5))   # belief @(5,5)≠live
	var ok: bool = FactionAISystem.new()._try_join_target(state, sub, 2)
	_ok(ok, "JOIN dispatch 成功")
	_ok(sub.move_target == Vector2i(5, 5), "move_target=belief(5,5) 非 live(9,9)（got %s）" % str(sub.move_target))
	_ok(sub.current_task == TeamData.TASK_JOIN, "task=JOIN")

# E2：無 belief → 不 JOIN dispatch（禁 fallback live）。
func _test_e2_join_no_belief() -> void:
	print("--- E2 無 belief→不 JOIN ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var sub := _mk_team(state, 1, 5, Vector2i(0, 0), 10)
	sub.parent_team_id = 99
	var _tgt := _mk_team(state, 2, 6, Vector2i(9, 9), -1)   # live 有位，但 obs 無 belief
	state.team_discovered[1] = [2]
	var ok: bool = FactionAISystem.new()._try_join_target(state, sub, 2)
	_ok(not ok, "無 belief target → _try_join_target 回 false（不瞎追 live）")
	_ok(sub.current_task != TeamData.TASK_JOIN, "無 belief → 未派 JOIN")

# E5：突圍無 belief 敵位 → 不設 breakout assignment（不瞎算 live 敵位）。
func _test_e5_breakout_no_belief() -> void:
	print("--- E5 突圍無 belief 敵位→不設 assignment ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var self_t := _mk_team(state, 1, 5, Vector2i(5, 5), 10)
	self_t.current_task = TeamData.TASK_IDLE
	var _e1 := _mk_team(state, 2, 6, Vector2i(6, 5), -1)   # 敵 live 逼近，但無 belief
	var _e2 := _mk_team(state, 3, 7, Vector2i(5, 6), -1)
	state.team_discovered[1] = [2, 3]
	# 無 team_intel → enemy_bpos 空 → size<2 → 不設 assignment
	StrategicAiSystem.new()._assign_breakout(state, self_t)
	_ok(not self_t.strategic_assignments.has(-1), "無 belief 敵位 → 無 breakout assignment（不讀 live god-view）")

# E5：_find_escape_dir 用傳入位置（belief）算逃向——敵在 +x → 逃向應遠離 +x。
func _test_e5_escape_dir_uses_positions() -> void:
	print("--- E5 _find_escape_dir 用傳入(belief)位算逃向 ---")
	var sai := StrategicAiSystem.new()
	var origin := Vector2i(5, 5)
	var enemy_positions: Array = [Vector2i(9, 5), Vector2i(8, 5)]   # 敵在東(+x)
	var dir: Vector2i = sai._find_escape_dir(origin, enemy_positions)
	_ok(dir.x <= 0, "敵在 +x → 逃向 x<=0（遠離敵，got %s）" % str(dir))
