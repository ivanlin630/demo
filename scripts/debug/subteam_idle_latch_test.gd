extends SceneTree

# subteam-idle-latch TDD v2（spec 2026-07-19-subteam-idle-latch，手不聽腦第 3 種 + 供給環閉合）。
# root：_evaluate_subteam(faction_ai:1727) blanket「抵達(move_target=-1)非-IDLE→歸建 merge」把覓食
#       subteam 抵達 forage 目的地誤當歸建 → thrash 覓食不執行坐死。
# v1（全排除 survival merge）治 thrash-死但引入 terminal-sticky：forager 永久囤糧不交母團→破供給環→
#       seed42 famine 0→10。
# v2（供給環）：survival-work 抵達 → 未食足 且 母團不缺 → 留 tile 覓食；食足 or 母團缺糧 → 歸建交糧。
#   _forager_sated = food_days(sub) >= FORAGE_SATED_DAYS(10)；_parent_needs_food = food_days(parent) < PARENT_LOW_DAYS(3)。
# food_days = effective_food / (pop × FPPD 0.8)。

var _fail: int = 0

func _initialize() -> void:
	_test_unsated_no_parent_stays()      # ①未食足+母團不缺→留 tile 覓食（不 merge，不 thrash）
	_test_survival_siblings_stay()       # ★sibling：CAMP/BEG/JOIN/RETURN_HOME 未食足亦留
	_test_sated_forager_merges()         # ②食足→歸建交糧（merge，供給環閉合）
	_test_parent_low_merges()            # ③母團缺糧→即使未食足也歸建交糧
	_test_mission_task_still_merges()    # mission(TRADE 非-survival)抵達仍 merge（lifecycle 不破）
	_test_intransit_parent_low_recalls() # v3①旅途中(move_target set)母團垂危→掉頭交糧（v2 漏的結構洞）
	_test_orphan_parent_dead()           # v3②母團死/缺席→orphan 轉獨立（不囤糧）
	_test_monitor_no_harm_build()        # v3③監看不誤傷 BUILD（早退不被召回，施工不中斷）
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

# 造 subteam（抵達=move_target -1、無 leader→_check_discipline 短路 false→達 1727）+ pop + food。
# parent_food<0 = 不建 parent（parent=null→_parent_needs_food false）；>=0 = 建 parent team 1 帶該 food。
func _mk(task: String, food: float, pop: int, parent_food: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var sub := TeamData.new()
	sub.team_id = 73; sub.parent_team_id = 1
	sub.current_task = task
	sub.move_target = Vector2i(-1, -1)
	sub.leader_id = -1
	sub.tile_pos = Vector2i(26, 9)
	AnonCohort.add(sub.anon_cohorts, AnonCohort.TIER_PLEB, "healthy", pop)
	sub.resources["food"] = food
	state.teams[73] = sub
	if parent_food >= 0.0:
		var parent := TeamData.new()
		parent.team_id = 1; parent.tile_pos = Vector2i(25, 6)
		AnonCohort.add(parent.anon_cohorts, AnonCohort.TIER_PLEB, "healthy", 5)
		parent.resources["food"] = parent_food
		state.teams[1] = parent
	return [state, sub]

func _eval(w: Array) -> Array:
	var mq: Array = []
	FactionAISystem.new()._evaluate_subteam(w[0], w[1], mq)
	return mq

# ① 未食足（food_days<10）+ 母團不缺（food_days>=3）→ 留 tile 覓食（不 merge）
func _test_unsated_no_parent_stays() -> void:
	print("--- ①未食足+母團不缺→留 tile 覓食 ---")
	# pop5 food8 → 8/(5*0.8)=2 天 <10 未食足；parent pop5 food20 → 20/4=5 天 >=3 不缺
	var w: Array = _mk(TeamData.TASK_FORAGE, 8.0, 5, 20.0)
	var mq: Array = _eval(w)
	_ok(mq.is_empty(), "FORAGE 未食足+母團不缺 → 不 merge，留 tile（got mq=%s）" % str(mq))
	_ok((w[1] as TeamData).current_task == TeamData.TASK_FORAGE, "current_task 仍 FORAGE")

# ★sibling：CAMP/BEG/JOIN/RETURN_HOME 未食足亦留 tile
func _test_survival_siblings_stay() -> void:
	print("--- ★sibling survival-task 未食足留 tile ---")
	for task in [TeamData.TASK_CAMP, TeamData.TASK_BEG, TeamData.TASK_JOIN, TeamData.TASK_RETURN_HOME]:
		var w: Array = _mk(task, 8.0, 5, 20.0)   # 未食足 + 母團不缺
		var mq: Array = _eval(w)
		_ok(mq.is_empty(), "%s 未食足+母團不缺 → 留 tile 不 merge（got mq=%s）" % [task, str(mq)])

# ② 食足（food_days>=10）→ 歸建交糧（merge，供給環閉合）
func _test_sated_forager_merges() -> void:
	print("--- ②食足→歸建交糧 ---")
	# pop5 food50 → 50/4=12.5 天 >=10 食足；母團不缺（food20→5天）→ 仍應 merge（食足優先歸建交糧）
	var w: Array = _mk(TeamData.TASK_FORAGE, 50.0, 5, 20.0)
	var mq: Array = _eval(w)
	_ok(mq.has(73), "FORAGE 食足 → 進 merge_queue（歸建交糧，供給環閉合，got mq=%s）" % str(mq))

# ③ 母團缺糧（food_days<3）→ 即使 forager 未食足也歸建交糧
func _test_parent_low_merges() -> void:
	print("--- ③母團缺糧→未食足也歸建交糧 ---")
	# forager pop5 food8→2天 未食足；parent pop5 food8→2天 <3 缺糧 → 應 merge（回交救母團）
	var w: Array = _mk(TeamData.TASK_FORAGE, 8.0, 5, 8.0)
	var mq: Array = _eval(w)
	_ok(mq.has(73), "FORAGE 未食足但母團缺糧 → 進 merge_queue（回交救母團，got mq=%s）" % str(mq))

# mission task（TRADE，非 SURVIVAL_TASKS）抵達 → 仍 merge（lifecycle 不破，無關 sated）
func _test_mission_task_still_merges() -> void:
	print("--- mission(TRADE)抵達仍歸建 ---")
	var w: Array = _mk(TeamData.TASK_TRADE, 8.0, 5, 20.0)   # 即使「未食足+母團不缺」，非-survival 照 merge
	var mq: Array = _eval(w)
	_ok(mq.has(73), "TRADE 抵達 → 進 merge_queue（mission lifecycle 不破，got mq=%s）" % str(mq))

# v3① 旅途中（move_target≠-1，非駐點）母團垂危 → 連續監看掉頭交糧（v2 只駐點查漏此結構洞）
func _test_intransit_parent_low_recalls() -> void:
	print("--- v3①旅途中母團垂危→掉頭交糧 ---")
	# forager 未食足(food8→2天)、仍在旅途(move_target set 非 -1)；母團缺糧(food8→2天<3)
	var w: Array = _mk(TeamData.TASK_FORAGE, 8.0, 5, 8.0)
	(w[1] as TeamData).move_target = Vector2i(10, 10)   # ★旅途中（v2 position-branch 不會 fire）
	var mq: Array = _eval(w)
	_ok(mq.has(73), "旅途中(move_target set)母團垂危 → 連續監看召回交糧（v2 漏此，got mq=%s）" % str(mq))

# v3② 母團死/缺席 → orphan 轉獨立（detach + 去 TAG_SUBTEAM + release，不無限囤糧）
func _test_orphan_parent_dead() -> void:
	print("--- v3②母團死→orphan 轉獨立 ---")
	var w: Array = _mk(TeamData.TASK_FORAGE, 8.0, 5, -1.0)   # parent_food<0 → 不建 parent → parent==null
	var sub: TeamData = w[1]
	w[0].add_tag(sub, TeamData.TAG_SUBTEAM, "test_setup")
	var mq: Array = _eval(w)
	_ok(not mq.has(73), "orphan 不進 merge_queue（無母團可歸，got mq=%s）" % str(mq))
	_ok(not sub.tags.has(TeamData.TAG_SUBTEAM), "orphan 去 TAG_SUBTEAM（轉獨立）")
	_ok(sub.parent_team_id == -1, "orphan detach（parent_team_id=-1，got %d）" % sub.parent_team_id)
	_ok(sub.current_task == TeamData.TASK_IDLE, "orphan release→IDLE（下 tick 跑獨立決策，got '%s')" % sub.current_task)

# v3③ 監看不誤傷 BUILD（BUILD 早退於監看前，施工不被母團監看中斷/召回）
func _test_monitor_no_harm_build() -> void:
	print("--- v3③監看不誤傷 BUILD ---")
	var w: Array = _mk(TeamData.TASK_BUILD, 8.0, 5, 8.0)   # 母團缺糧 but BUILD 施工中不該被召回
	var mq: Array = _eval(w)
	_ok(mq.is_empty(), "BUILD 不被母團監看召回（施工不中斷，got mq=%s）" % str(mq))
	_ok((w[1] as TeamData).current_task == TeamData.TASK_BUILD, "current_task 仍 BUILD")
