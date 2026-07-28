extends SceneTree

# 持守統一 Slice 3 TDD（HOW spec 2026-07-28 §6）：try_set 持守-aware 門檻式。
# 非危機 committed(persist>THRESHOLD)擋搶班；危機 tier 原封守命；玩家 authority 不擋；同 task 不擋；不凍世界。

var _fail: int = 0
const PT := TaskArbiter.PERSIST_HOLD_THRESHOLD

func _initialize() -> void:
	_test_noncrisis_high_persist_blocks()   # 非危機+persist 高 → 擋搶班
	_test_low_persist_passes()              # persist 低 → 照常搶班(易轉)
	_test_crisis_tier_always_passes()       # 危機(≥PRIO_THREAT)一律過(守命/背水一戰)
	_test_player_authority_passes()         # 玩家命令 authority 不被 persist 擋
	_test_same_task_passes()                # 同 task(target 更新非搶班)不擋
	_test_not_frozen_committed_completes()  # ★committed 隊自己完成/release→persist 歸 0→可再派(非硬鎖凍)
	_test_ongoing_task_not_blocked()        # ★ongoing task(PRODUCE)高 persist 不硬擋(防 attrition 0 過度壓制向凍)
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
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var team := TeamData.new(); team.team_id = 1
	var l := PersonData.new(); l.id = 10; state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team]

# committed 建設(DISPATCH)+persist 高 → 外交(DISPATCH)搶 → 擋
func _test_noncrisis_high_persist_blocks() -> void:
	print("--- ①非危機 persist 高擋搶班 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_BUILD; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.persist_strength = PT + 0.05   # > THRESHOLD
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_DIPLOMACY, Vector2i(1,1), TaskArbiter.PRIO_DISPATCH, "unified")
	_ok(not ok and team.current_task == TeamData.TASK_BUILD,
		"非危機外交搶建設(persist %.2f>%.2f)→擋(return false,守 committed)" % [team.persist_strength, PT])

func _test_low_persist_passes() -> void:
	print("--- ②persist 低照常搶班 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_BUILD; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.persist_strength = PT - 0.05   # < THRESHOLD（務實/剛開工）
	# 同層 self-replace 需 engine source + 現任 reason 也 engine；用 higher-prio 簡化驗門檻不擋
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_DIPLOMACY, Vector2i(1,1), TaskArbiter.PRIO_VENDETTA, "unified")
	_ok(ok and team.current_task == TeamData.TASK_DIPLOMACY,
		"persist %.2f<%.2f→不擋,照 tier 搶(易轉靈活)" % [team.persist_strength, PT])

func _test_crisis_tier_always_passes() -> void:
	print("--- ③危機 tier 一律過(守命) ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_BUILD; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.persist_strength = PT + 0.1   # persist 高
	# survival(80≥THREAT) 搶 → 危機 axis 過(persist 不介入)
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_FORAGE, Vector2i(1,1), TaskArbiter.PRIO_SURVIVAL, "survival")
	_ok(ok and team.current_task == TeamData.TASK_FORAGE,
		"survival(危機 80≥THREAT)搶建設→過(守命,persist 高也擋不住危機=背水一戰保)")

func _test_player_authority_passes() -> void:
	print("--- ④玩家 authority 不被擋 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_BUILD; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.persist_strength = PT + 0.1
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_PATROL, Vector2i(1,1), TaskArbiter.PRIO_PLAYER, "player")
	_ok(ok and team.current_task == TeamData.TASK_PATROL,
		"玩家命令(PRIO_PLAYER)→過(authority 不被 persist 擋)")

func _test_same_task_passes() -> void:
	print("--- ⑤同 task 不擋(target 更新) ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_BUILD; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.task_reason = "unified"; team.persist_strength = PT + 0.1
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_BUILD, Vector2i(2,2), TaskArbiter.PRIO_DISPATCH, "unified")
	_ok(ok and team.move_target == Vector2i(2,2),
		"同 task 建設(new==current)→過(target 更新非搶班,persist 不擋)")

# ★不凍：persist 擋是單點 return false,committed 隊完成/release→persist 歸 0→可再派新 task
func _test_not_frozen_committed_completes() -> void:
	print("--- ⑥不凍(release→persist 歸0→可再派) ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_BUILD; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.persist_strength = PT + 0.1
	# 完工/取消 → release（persist 由決策層下次算會歸 0,此處模擬完成後 IDLE）
	TaskArbiter.release(team)
	team.persist_strength = 0.0   # 決策層 progressive-only:IDLE→persist=0(非施工)
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_TRADE, Vector2i(1,1), TaskArbiter.PRIO_DISPATCH, "unified")
	_ok(ok and team.current_task == TeamData.TASK_TRADE,
		"release 後 persist=0(IDLE)→新 task 可派(非硬鎖凍;committed 完成即釋放)")

# ★ongoing 開放式 task(PRODUCE)高 persist 也不硬擋——只 completable progressive(BUILD 族)受門檻保護。
# 防：長 PRODUCE 隊被硬鎖不轉攻擊/防衛→戰鬥趨零 attrition 0 向凍(execution-verified 抓)。
func _test_ongoing_task_not_blocked() -> void:
	print("--- ⑦ongoing task(PRODUCE)不硬擋 ---")
	var w: Array = _mk(); var state: WorldState = w[0]; var team: TeamData = w[1]
	team.current_task = TeamData.TASK_PRODUCE; team.task_priority = TaskArbiter.PRIO_DISPATCH
	team.persist_strength = PT + 0.1   # persist 高（長 committed proxy）
	# 非危機 vendetta 搶 → PRODUCE 非 PROGRESSIVE_HOLD_TASKS → 不硬擋（照 tier 搶）
	var ok: bool = TaskArbiter.try_set(state, team, TeamData.TASK_LOOT, Vector2i(1,1), TaskArbiter.PRIO_VENDETTA, "unified")
	_ok(ok and team.current_task == TeamData.TASK_LOOT,
		"PRODUCE(ongoing 非 BUILD 族)高 persist→不硬擋,照 tier 搶(避 attrition 0 過度壓制;只 completable 受保護)")
