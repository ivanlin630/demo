extends SceneTree

# famine crisis-override TDD（spec 2026-07-19-task-flee-stall-detection，泛化 ②）。
# OUTCOME-based：committed 任何 task 深餓(food<CRISIS_FLOOR)未緩(committed N 天 food 沒回升≥RELIEF_MIN)
# → crisis fire → release → re-rank → survival @80 preempt。baseline lazy 蓋(task_start_tick 變→重置)。
# 純 detection 直測 _famine_crisis。

var _fail: int = 0
const TPD := 240   # WorldState.TICKS_PER_DAY

func _initialize() -> void:
	_test_crisis_fires_stuck_famine()
	_test_no_fire_recovered()
	_test_no_fire_not_deep()
	_test_no_fire_before_ndays()
	_test_no_fire_idle()
	_test_lazy_baseline_reset()
	_test_five_stuck_tasks()
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

# 構隊：food_days = food/(pop*0.8)。委 committed task + baseline 已蓋(crisis_committed_tick==task_start_tick)。
func _mk(task: String, food: float, pop: int, task_start: int, now: int, baseline_food: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = now
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0, 0)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	t.resources["food"] = food
	t.current_task = task
	t.task_start_tick = task_start
	t.crisis_committed_tick = task_start   # baseline 已蓋（同 task episode）
	t.crisis_committed_food = baseline_food
	state.teams[1] = t
	return [state, t]

func _test_crisis_fires_stuck_famine() -> void:
	print("--- crisis fire：committed build 深餓 N 天未緩 ---")
	# food=2 → food_days=2/(5*0.8)=0.5 < CRISIS_FLOOR;committed 8 天(>N);baseline 0.5 未緩(Δ0)
	var w: Array = _mk(TeamData.TASK_BUILD, 2.0, 5, 0, 8 * TPD, 0.5)
	_ok(FactionAISystem.new()._famine_crisis(w[0], w[1]), "committed build 深餓(0.5)N天未緩 → crisis TRUE")

func _test_no_fire_recovered() -> void:
	print("--- 不 fire：food 回升(緩解) ---")
	# food=12 → food_days=3.0 > CRISIS_FLOOR;baseline 0.5 → Δ2.5≥RELIEF → 緩解
	var w: Array = _mk(TeamData.TASK_BUILD, 12.0, 5, 0, 8 * TPD, 0.5)
	_ok(not FactionAISystem.new()._famine_crisis(w[0], w[1]), "food 回升(3.0>FLOOR,Δ2.5緩) → 不 fire")

func _test_no_fire_not_deep() -> void:
	print("--- 不 fire：非深餓(食>CRISIS_FLOOR) ---")
	# food=8 → food_days=2.0 > CRISIS_FLOOR 1.5（未達深餓）
	var w: Array = _mk(TeamData.TASK_BUILD, 8.0, 5, 0, 8 * TPD, 2.0)
	_ok(not FactionAISystem.new()._famine_crisis(w[0], w[1]), "food_days 2.0 > CRISIS_FLOOR → 不 fire（淺餓 boost 域）")

func _test_no_fire_before_ndays() -> void:
	print("--- 不 fire：committed 未到 N 天 ---")
	# 深餓未緩但只 committed 2 天(<N)
	var w: Array = _mk(TeamData.TASK_BUILD, 2.0, 5, 0, 2 * TPD, 0.5)
	_ok(not FactionAISystem.new()._famine_crisis(w[0], w[1]), "committed 2 天<N → 不 fire（給時間工作）")

func _test_no_fire_idle() -> void:
	print("--- 不 fire：IDLE（無 committed task，自然 re-rank）---")
	var w: Array = _mk(TeamData.TASK_IDLE, 2.0, 5, 0, 8 * TPD, 0.5)
	_ok(not FactionAISystem.new()._famine_crisis(w[0], w[1]), "IDLE → 不 fire（無 task 可 release）")

func _test_lazy_baseline_reset() -> void:
	print("--- baseline lazy 蓋 + task change 重置 ---")
	# crisis_committed_tick != task_start_tick（新 task episode）→ 首呼蓋 baseline 回 false
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 8 * TPD
	var t := TeamData.new(); t.team_id = 1; AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5)
	t.resources["food"] = 2.0; t.current_task = TeamData.TASK_BUILD
	t.task_start_tick = 8 * TPD; t.crisis_committed_tick = -1   # 未蓋
	state.teams[1] = t
	var fa := FactionAISystem.new()
	_ok(not fa._famine_crisis(state, t), "新 task episode 首呼 → 蓋 baseline 回 false（還沒到 N 天）")
	_ok(t.crisis_committed_tick == t.task_start_tick, "首呼蓋 crisis_committed_tick=task_start_tick")
	_ok(is_equal_approx(t.crisis_committed_food, 0.5), "首呼蓋 baseline food_days=0.5")

func _test_five_stuck_tasks() -> void:
	print("--- 5 種 stuck-task 皆可 crisis（OUTCOME 非 task-type）---")
	for task in [TeamData.TASK_FLEE, TeamData.TASK_BUILD, TeamData.TASK_DIPLOMACY, TeamData.TASK_JOIN, TeamData.TASK_GOVERN]:
		var w: Array = _mk(task, 2.0, 5, 0, 8 * TPD, 0.5)
		_ok(FactionAISystem.new()._famine_crisis(w[0], w[1]), "stuck task=%s 深餓未緩 → crisis TRUE（OUTCOME-based）" % task)
