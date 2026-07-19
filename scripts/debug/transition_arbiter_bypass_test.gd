extends SceneTree

# transition-arbiter-bypass TDD（spec 2026-07-19-transition-arbiter-bypass）。
# root：TaskArbiter.transition 舊為無條件 raw 覆寫繞 arbiter=手不聽腦後門（team16 defection stomp survival→凍死）。
# 修兩部：①transition 加 3 guard（combat/crisis-免疫/emergency-respect）擋外部 in-place stomp；
#         ②resolution caller 改 release-first（先 release→IDLE@0 過 guard 再 set）＝emergency 正當退場，
#            beggar-restore ★存/還 move_target（release 清 -1，resume 原工需原目的地）。
# guard 只擋 (a) 外部 stomp、不誤傷 (b) emergency 自身退場（後者現任已 release 成 IDLE@0）。

var _fail: int = 0

func _initialize() -> void:
	_test_defection_stomp_blocked()      # ② team16 主靶
	_test_non_emergency_passes()         # ⑤ 合法非-emergency 不破
	_test_combat_lock_blocks()           # ⑥
	_test_crisis_immunity_blocks()       # ⑦
	_test_release_first_from_emergency() # ③④ core：emergency release→IDLE→轉換過
	_test_beggar_restore_move_target()   # ① reviewer R²v2 抓的 move_target 還原
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

func _mk_team(task: String, prio: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var t := TeamData.new(); t.team_id = 16; t.tile_pos = Vector2i(3, 3)
	t.current_task = task; t.task_priority = prio; t.task_start_tick = 500
	state.teams[16] = t
	return [state, t]

# ② 外部低 prio in-place stomp active survival@80 → 被擋（team16 defection「等待新領主」@AMBIENT）
func _test_defection_stomp_blocked() -> void:
	print("--- ②defection stomp survival@80 被擋（team16）---")
	var w: Array = _mk_team(TeamData.TASK_FORAGE, TaskArbiter.PRIO_SURVIVAL)   # 引擎剛派 survival@80
	TaskArbiter.transition(w[0], w[1], "等待新領主", TaskArbiter.PRIO_AMBIENT)          # defection 外部 stomp
	var t: TeamData = w[1]
	_ok(t.current_task == TeamData.TASK_FORAGE, "survival task 留（未被 AMBIENT stomp，got '%s')" % t.current_task)
	_ok(t.task_priority == TaskArbiter.PRIO_SURVIVAL, "priority 留 80（got %d）" % t.task_priority)
	_ok(t.task_start_tick == 500, "task_start_tick 未被重置（crisis baseline 不塌，got %d）" % t.task_start_tick)

# ⑤ 合法非-emergency 轉換不破（現任<70 → guard 不 fire → 照過）
func _test_non_emergency_passes() -> void:
	print("--- ⑤非-emergency 轉換照過（現任<70）---")
	var w: Array = _mk_team(TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)   # 現任 DISPATCH 50 <70
	TaskArbiter.transition(w[0], w[1], "生產", TaskArbiter.PRIO_AMBIENT)
	_ok((w[1] as TeamData).current_task == "生產", "現任<70 → AMBIENT 轉換過（got '%s')" % (w[1] as TeamData).current_task)

# ⑥ combat lock：combat_target≠-1 → 擋
func _test_combat_lock_blocks() -> void:
	print("--- ⑥combat lock 擋 ---")
	var w: Array = _mk_team(TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	var t: TeamData = w[1]; t.combat_target = 99
	TaskArbiter.transition(w[0], t, "生產", TaskArbiter.PRIO_AMBIENT)
	_ok(t.current_task == TeamData.TASK_BUILD, "combat 中 transition 被擋（task 留 '%s')" % t.current_task)

# ⑦ crisis-免疫：crisis_released task 窗內重鎖 → 擋
func _test_crisis_immunity_blocks() -> void:
	print("--- ⑦crisis-免疫窗內擋 ---")
	var w: Array = _mk_team(TeamData.TASK_FORAGE, TaskArbiter.PRIO_SURVIVAL)
	var t: TeamData = w[1]
	t.crisis_released_task = "建設"; t.crisis_released_until = 2000   # 窗到 tick2000，現 tick1000
	TaskArbiter.transition(w[0], t, "建設", TaskArbiter.PRIO_DISPATCH)   # 試重鎖剛 released 的建設
	_ok(t.current_task == TeamData.TASK_FORAGE, "免疫窗內 transition 重鎖被擋（task 留 '%s')" % t.current_task)

# ③④ core：emergency task 自身退場走 release-first → 現任=IDLE@0 → 後續轉換過（不誤傷）
func _test_release_first_from_emergency() -> void:
	print("--- ③④release-first：emergency→release→IDLE→轉換過 ---")
	# settle 型：流亡 survival@80 → release → transition 生產@AMBIENT
	var w: Array = _mk_team(TeamData.TASK_RETURN_HOME, TaskArbiter.PRIO_SURVIVAL)
	var t: TeamData = w[1]
	TaskArbiter.release(t)   # resolution caller 先 release
	_ok(t.current_task == TeamData.TASK_IDLE and t.task_priority == 0, "release → IDLE@0")
	TaskArbiter.transition(w[0], t, "生產", TaskArbiter.PRIO_AMBIENT)   # 現任 IDLE@0 → guard 不 fire → 過
	_ok(t.current_task == "生產" and t.task_priority == TaskArbiter.PRIO_AMBIENT, "release 後 AMBIENT 轉換過（got '%s'@%d）" % [t.current_task, t.task_priority])
	# zombie 型：RETURN_HOME@80 → release → BUILD@DISPATCH（同 pattern，換高 prio 亦過）
	var w2: Array = _mk_team(TeamData.TASK_RETURN_HOME, TaskArbiter.PRIO_SURVIVAL)
	var t2: TeamData = w2[1]
	TaskArbiter.release(t2)
	TaskArbiter.transition(w2[0], t2, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	_ok(t2.current_task == TeamData.TASK_BUILD, "zombie release-first → BUILD set（got '%s')" % t2.current_task)

# ① beggar-restore：BEG resolution → release-first → previous_task 恢復 + ★move_target 還原（非 -1）
func _test_beggar_restore_move_target() -> void:
	print("--- ①beggar-restore move_target 還原（reviewer R²v2）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var beggar := TeamData.new(); beggar.team_id = 7; beggar.tile_pos = Vector2i(1, 1)
	# BEG@80 active、原工 previous_task=覓食、目的地 move_target=(9,9)、social_target=某地
	beggar.current_task = TeamData.TASK_BEG; beggar.task_priority = TaskArbiter.PRIO_SURVIVAL
	beggar.previous_task = TeamData.TASK_FORAGE
	beggar.move_target = Vector2i(9, 9)
	beggar.social_target = 3
	state.teams[7] = beggar
	InteractionSystem.new()._clear_aid_task(state, beggar)
	_ok(beggar.current_task == TeamData.TASK_FORAGE, "previous_task 恢復成 current_task（got '%s')" % beggar.current_task)
	_ok(beggar.move_target == Vector2i(9, 9), "★move_target 還原到原目的地 (9,9)（非 -1；reviewer R²v2 抓，got %s）" % str(beggar.move_target))
	_ok(beggar.previous_task == "", "previous_task 清空（消費完）")
