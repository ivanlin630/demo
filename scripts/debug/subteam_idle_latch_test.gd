extends SceneTree

# subteam-idle-latch TDD（spec 2026-07-19-subteam-idle-latch，手不聽腦第 3 種）。
# root：_evaluate_subteam(faction_ai:1727) blanket「抵達(move_target=-1)非-IDLE→歸建 merge_queue」
#       把覓食 subteam 抵達 forage 目的地誤當歸建抵家 → thrash(ARRIVE↔RELEASE 1:1)、覓食不執行坐死。
# 修：1727 加 `and sub.current_task not in SURVIVAL_TASKS`（=RETURN_HOME/BEG/JOIN/FORAGE/CAMP，
#     execute-at-destination 非歸建）→ survival subteam 抵達留 tile 執行覓食，非被召回。

var _fail: int = 0

func _initialize() -> void:
	_test_forage_arrive_no_merge()      # ① 覓食 subteam 抵達不歸建
	_test_survival_siblings_no_merge()  # ★sibling：CAMP/BEG/JOIN/RETURN_HOME 抵達不歸建
	_test_mission_task_still_merges()   # ② mission(TRADE)抵達仍歸建（lifecycle 不破）
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

# subteam 抵達目的地（move_target=-1）、無 leader（_check_discipline 短路回 false → 達 1727 判斷）
func _mk_sub(task: String) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var sub := TeamData.new()
	sub.team_id = 73; sub.parent_team_id = 1        # 子隊
	sub.current_task = task
	sub.move_target = Vector2i(-1, -1)              # 已抵達目的地
	sub.leader_id = -1                              # 無 leader → _check_discipline 回 false
	sub.tile_pos = Vector2i(26, 9)
	state.teams[73] = sub
	return [state, sub]

func _eval(w: Array) -> Array:
	var mq: Array = []
	FactionAISystem.new()._evaluate_subteam(w[0], w[1], mq)
	return mq

# ① 覓食 subteam 抵達 forage tile → 不進 merge_queue（留 tile 覓食，非歸建召回）
func _test_forage_arrive_no_merge() -> void:
	print("--- ①覓食 subteam 抵達不歸建 ---")
	var w: Array = _mk_sub(TeamData.TASK_FORAGE)
	var mq: Array = _eval(w)
	_ok(mq.is_empty(), "FORAGE subteam 抵達 → 不進 merge_queue（留 tile 覓食，got mq=%s）" % str(mq))
	_ok((w[1] as TeamData).current_task == TeamData.TASK_FORAGE, "current_task 仍 FORAGE（未被召回改態）")

# ★sibling：其餘 SURVIVAL_TASKS 抵達皆不歸建
func _test_survival_siblings_no_merge() -> void:
	print("--- ★sibling survival-task 抵達不歸建 ---")
	for task in [TeamData.TASK_CAMP, TeamData.TASK_BEG, TeamData.TASK_JOIN, TeamData.TASK_RETURN_HOME]:
		var w: Array = _mk_sub(task)
		var mq: Array = _eval(w)
		_ok(mq.is_empty(), "%s subteam 抵達 → 不進 merge_queue（execute-at-destination，got mq=%s）" % [task, str(mq)])

# ② mission task（TRADE，非 SURVIVAL_TASKS）抵達 → 仍歸建（lifecycle 完工返家不破）
func _test_mission_task_still_merges() -> void:
	print("--- ②mission(TRADE)抵達仍歸建 ---")
	var w: Array = _mk_sub(TeamData.TASK_TRADE)
	var mq: Array = _eval(w)
	_ok(mq.has(73), "TRADE subteam 抵達 → 進 merge_queue（mission lifecycle 不破，got mq=%s）" % str(mq))
