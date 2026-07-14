extends SceneTree

# 位置感知 belief 化 TDD（slice: position-belief）
# spec: docs/superpowers/specs/2026-07-15-position-belief.md
#
# belief_pos 通道分流：跨-faction→BeliefSystem last-seen / 同-faction→known_member_states；皆 staleness gate。
# ★fallback 鐵則：無 belief/過期 → (-1,-1)（禁退自身）。to_task/movement 用 belief_pos→撲空逃脫。

var _fail: int = 0

func _initialize() -> void:
	_test_belief_pos_channels()
	_test_belief_pos_staleness()
	_test_belief_pos_fallback_not_self()
	_test_movement_fallback_not_self()
	_test_to_task_stale_puffs()
	_test_fixF_pursuit_vision_gate()
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

# obs(1,faction5)@(0,0) / 跨-faction tgt(2,faction6)@真(9,9) belief last-seen(7,7) /
# 同-faction tgt(3,faction5)@真(9,9) known_member_states(4,4)。
func _mk_world(belief_tick: int) -> WorldState:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var f5 := FactionData.new(); f5.faction_id = 5; state.factions[5] = f5
	var f6 := FactionData.new(); f6.faction_id = 6; state.factions[6] = f6
	var obs := TeamData.new(); obs.team_id = 1; obs.faction_id = 5; obs.tile_pos = Vector2i(0, 0); state.teams[1] = obs
	var tx := TeamData.new(); tx.team_id = 2; tx.faction_id = 6; tx.tile_pos = Vector2i(9, 9); state.teams[2] = tx
	var ts := TeamData.new(); ts.team_id = 3; ts.faction_id = 5; ts.tile_pos = Vector2i(9, 9); state.teams[3] = ts
	# 跨-faction belief（team_intel）：last-seen (7,7)
	state.team_discovered[1] = [2, 3]
	state.team_intel[1] = { 2: {"population_est": 5.0, "tile_pos": Vector2i(7, 7), "last_tick": belief_tick} }
	# 同-faction known_member_states：(4,4)
	f5.known_member_states[3] = {"tile_pos": Vector2i(4, 4), "last_tick": belief_tick, "population": 5}
	return state

func _test_belief_pos_channels() -> void:
	print("--- belief_pos 通道分流（跨→belief / 同→known_member_states）---")
	var state := _mk_world(100000)   # fresh
	var px := BeliefSystem.belief_pos(state, 1, 2)
	_ok(px == Vector2i(7, 7), "跨-faction → belief last-seen (7,7)（非真值 9,9），實際=%s" % str(px))
	var ps := BeliefSystem.belief_pos(state, 1, 3)
	_ok(ps == Vector2i(4, 4), "同-faction → known_member_states (4,4)（非真值 9,9/非 belief），實際=%s" % str(ps))

func _test_belief_pos_staleness() -> void:
	print("--- belief_pos staleness gate（過期視同未知）---")
	var state := _mk_world(100000 - BeliefSystem.BELIEF_STALE_TICKS - 10)   # 過期
	_ok(BeliefSystem.belief_pos(state, 1, 2) == Vector2i(-1, -1), "跨-faction belief 過期 → (-1,-1)")
	_ok(BeliefSystem.belief_pos(state, 1, 3) == Vector2i(-1, -1), "同-faction known_member_states 過期 → (-1,-1)")

func _test_belief_pos_fallback_not_self() -> void:
	print("--- belief_pos fallback 禁退自身 ---")
	var state := _mk_world(100000)
	# 無 belief 的 target（4，obs 沒情報）→ (-1,-1)，★非 obs 自身位置(0,0)
	var p := BeliefSystem.belief_pos(state, 1, 999)
	_ok(p == Vector2i(-1, -1), "無 belief target → (-1,-1)（★非退自身 0,0），實際=%s" % str(p))

func _test_movement_fallback_not_self() -> void:
	print("--- movement fallback：belief (-1,-1) → move_target 不退自身 ---")
	var state := _mk_world(100000 - BeliefSystem.BELIEF_STALE_TICKS - 10)   # belief 過期
	var mover: TeamData = state.teams[1]
	mover.current_task = TeamData.TASK_JOIN
	mover.social_target = 2               # 追跨-faction target 2（belief 過期）
	mover.move_target = Vector2i(7, 7)    # 原 last-seen
	MovementSystem.new().process(state, [1], 1.0, 1)
	# belief 過期→belief_pos (-1,-1)→保持原 move_target(7,7)，★不退自身(0,0)
	_ok(mover.move_target != Vector2i(0, 0), "belief 過期 → move_target 未退自身(0,0)，實際=%s" % str(mover.move_target))
	_ok(mover.move_target == Vector2i(7, 7), "belief 過期 → 保持原 move_target(7,7)撲空逃脫，實際=%s" % str(mover.move_target))

func _test_to_task_stale_puffs() -> void:
	print("--- to_task 攻擊 belief 過期 → 撲空 IDLE（不移向真值/自身）---")
	var state := _mk_world(100000 - BeliefSystem.BELIEF_STALE_TICKS - 10)   # belief 過期
	# 直測 belief_pos 過期→(-1,-1)（to_task 攻擊據此回 IDLE，不追真值 9,9 或自身）
	_ok(BeliefSystem.belief_pos(state, 1, 2) == Vector2i(-1, -1),
		"攻擊 target belief 過期 → belief_pos (-1,-1) → to_task 撲空 IDLE（不追真值/自身）")

# ── Fix F：_refresh_attack_pursuit 三態 vision-gate ──
func _mk_pursuit(belief_tick: int, with_tile_pos: bool) -> Array:   # → [state, team, prey]
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	for x in range(-1, 12):
		for y in range(-1, 12):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.faction_id = -1; team.tile_pos = Vector2i(0, 0)
	team.current_task = TeamData.TASK_ATTACK; team.combat_target = -1; team.prosperity_target_id = 2
	var ldr := PersonData.new(); ldr.id = 10; state.persons[10] = ldr; team.leader_id = 10
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5); state.teams[1] = team
	var prey := TeamData.new(); prey.team_id = 2; prey.faction_id = -1; prey.tile_pos = Vector2i(9, 9)
	AnonCohort.add(prey.anon_cohorts, "平民", "healthy", 3); state.teams[2] = prey
	state.team_discovered[1] = [2]
	var val: Dictionary = {"population_est": 3, "last_tick": belief_tick}
	if with_tile_pos: val["tile_pos"] = Vector2i(7, 7)
	state.team_intel[1] = {2: val}
	return [state, team, prey]

func _test_fixF_pursuit_vision_gate() -> void:
	print("--- Fix F：_refresh_attack_pursuit 三態 vision-gate ---")
	var fa := FactionAISystem.new()
	# ① 本 tick 可見（last_tick==current）→ live 攔截；不 release
	var w1: Array = _mk_pursuit(100000, true)
	fa._refresh_attack_pursuit(w1[0], w1[1])
	_ok(w1[1].prosperity_target_id == 2, "①可見→不放棄追擊(prosperity 保留)")
	_ok(w1[1].move_target != Vector2i(-1, -1), "①可見→move_target 設(live 攔截)")
	# ② 斷視線+belief 新（5 tick 前<stale）→ move_target = belief last-seen(7,7)，非 prey 活值(9,9)
	var w2: Array = _mk_pursuit(100000 - 5, true)
	fa._refresh_attack_pursuit(w2[0], w2[1])
	_ok(w2[1].move_target == Vector2i(7, 7), "②斷視線→去 last-seen(7,7)撲空，實際=%s" % str(w2[1].move_target))
	_ok(w2[1].move_target != Vector2i(9, 9), "②斷視線→非 prey 活值現址(9,9)")
	_ok(w2[1].prosperity_target_id == 2, "②belief 新→續追擊(不放棄)")
	# ③ 斷視線+過期（超 BELIEF_STALE_TICKS）→ 放棄追擊 re-eval
	var w3: Array = _mk_pursuit(100000 - BeliefSystem.BELIEF_STALE_TICKS - 10, true)
	fa._refresh_attack_pursuit(w3[0], w3[1])
	_ok(w3[1].prosperity_target_id == -1, "③過期→放棄追擊(prosperity_target_id=-1)")
	_ok(w3[1].current_task == TeamData.TASK_IDLE, "③過期→task released(re-eval)")
	# ④ 斷視線(非本 tick)+無 belief 位置（snap 無 tile_pos）→ 同③ release，★不移向 prey 活值(9,9)/自身
	# （註：last_tick==current 時無 tile_pos 仍走態①可見 live 攔截，合法；此案測「不可見+無位」）
	var w4: Array = _mk_pursuit(100000 - 5, false)
	fa._refresh_attack_pursuit(w4[0], w4[1])
	_ok(w4[1].prosperity_target_id == -1, "④無 belief 位置→放棄追擊")
	_ok(w4[1].move_target != Vector2i(9, 9), "④無 belief→★不退 prey 活值(9,9)")
