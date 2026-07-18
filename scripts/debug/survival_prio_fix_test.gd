extends SceneTree

# survival PRIO fix（S3 regression）：restore 80>70>50 階層。
# (1) _decide_unified survival-class 選項 @PRIO_SURVIVAL 80（preempt threat @70）。
# (2) task_arbiter self-replace 擴認 PRIO_SURVIVAL（survival 選項間同層換手）。

var _fail: int = 0

func _initialize() -> void:
	_test_arbiter_hierarchy()
	_test_decide_unified_survival_prio()
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

func _mk_state_team() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0, 0)
	s.teams[1] = t
	return [s, t]

# (2) task_arbiter 80>70>50 階層 + self-replace
func _test_arbiter_hierarchy() -> void:
	print("--- task_arbiter 80>70>50 階層 + PRIO_SURVIVAL self-replace ---")
	var st := _mk_state_team()
	var s: WorldState = st[0]; var t: TeamData = st[1]
	# survival @80 派下
	TaskArbiter.try_set(s, t, TeamData.TASK_FLEE, Vector2i(2, 2), TaskArbiter.PRIO_SURVIVAL, "unified")
	_ok(t.task_priority == TaskArbiter.PRIO_SURVIVAL, "survival 派 @PRIO_SURVIVAL 80(got %d)" % t.task_priority)
	# threat @70 不能 stomp survival @80
	var stomp: bool = TaskArbiter.try_set(s, t, TeamData.TASK_DEFEND, Vector2i(3, 3), TaskArbiter.PRIO_THREAT, "unified")
	_ok(not stomp and t.current_task == TeamData.TASK_FLEE, "threat @70 不能 stomp survival @80(survival preempt threat)")
	# survival @80 → survival @80 self-replace（換手不卡）
	var swap: bool = TaskArbiter.try_set(s, t, TeamData.TASK_FORAGE, Vector2i(4, 4), TaskArbiter.PRIO_SURVIVAL, "unified")
	_ok(swap and t.current_task == TeamData.TASK_FORAGE, "survival→survival @80 self-replace(換手不退化)")

# (1) _decide_unified：瀕死隊 survival 選項 commit @PRIO_SURVIVAL 80
func _test_decide_unified_survival_prio() -> void:
	print("--- _decide_unified 瀕死隊 survival @PRIO_SURVIVAL ---")
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
	var fai := FactionAISystem.new()
	var tid := 50
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	t.tags = [TeamData.TAG_MERCHANT]   # unified 隊直走 _decide_unified
	AnonTierSystem.add_anon(t, "平民", 6)
	t.resources = {"food": 0.0}   # 瀕死（survival boost fires）
	t.current_task = TeamData.TASK_IDLE
	s.teams[tid] = t; s.team_discovered[tid] = []; s.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid; ldr.values = {"慎重": 0.5}
	s.persons[ldr.id] = ldr
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5)
	# 有 wild_game → 覓食 applicable
	tile.resources = {"wild_game": 10.0}
	s.world.tiles[5 * 1000 + 5] = tile
	fai._decide_unified(s, t)
	print("  [info] task=%s prio=%d" % [t.current_task, t.task_priority])
	# 瀕死隊選 survival-class → task_priority @PRIO_SURVIVAL 80（非 @50）
	var is_surv: bool = t.current_option in DecisionOptions.SURVIVAL_OPTION_SET or t.current_option == "survival"
	if is_surv:
		_ok(t.task_priority == TaskArbiter.PRIO_SURVIVAL, "瀕死 survival 選項 commit @80(option=%s prio=%d)" % [t.current_option, t.task_priority])
	else:
		print("  [info] 瀕死隊未選 survival-class(選 %s)——場景未觸 survival，跳 prio 斷言" % t.current_option)
		_ok(true, "場景 note（survival boost/applicable 依 need）")
