extends SceneTree

# 求生層統一 3-fix 單元測試（TDD）：
#   Fix2 crisis edge-trigger（進 crisis fire 一次→latch→持續期落 cadence→離開解 latch）
#   Fix3 esteem food_ready 參考線 5→3（脫困即近滿→esteem urgency 起得來）
# Fix1（override 退役）行為在 integration bed 驗（seed1337 Team10 thrash），此處驗 gate 邏輯不引 famine。

var _fail: int = 0

func _initialize() -> void:
	_test_fix2_crisis_edge()
	_test_fix3_food_ready_ref()
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

func _mk_team() -> TeamData:
	var t := TeamData.new()
	t.team_id = 1
	t.faction_id = -1          # 無 faction → directive_fresh=false，belonging/actual 走 solo 分支
	t.parent_team_id = -1
	t.current_task = TeamData.TASK_PRODUCE   # 非 IDLE、非 STUCK(ATTACK/LOOT)、非 survival
	t.move_target = Vector2i(0, 0)
	t.population = 10
	t.crisis_latched = false
	t.decision_eval_next_tick = 999999       # cadence 遠期 → 不干擾 crisis edge 判定
	t.rung_pop_last = 0                       # 不觸發 pop-drop crisis 分支
	return t

func _test_fix2_crisis_edge() -> void:
	print("--- Fix2 crisis edge-trigger ---")
	var ai := FactionAISystem.new()
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 0
	var t := _mk_team()

	# 進入 crisis（food_flow 深負 < RUNG_CRASH_FOOD_DEEP=-2.0）
	t.food_flow_avg = -999.0
	_ok(ai._should_reeval(state, t) == true, "進 crisis 首次 → fire(edge)")
	_ok(t.crisis_latched == true, "首次 fire 後 crisis_latched=true")
	# 持續 crisis、cadence 未到 → 不再每 tick fire
	_ok(ai._should_reeval(state, t) == false, "持續 crisis + cadence 遠期 → 不 fire(落 cadence 閘)")
	_ok(ai._should_reeval(state, t) == false, "持續 crisis 再 tick → 仍不 fire")
	# 離開 crisis → 解 latch
	t.food_flow_avg = 10.0
	_ok(ai._should_reeval(state, t) == false, "離開 crisis + 無其他觸發 → 不 fire")
	_ok(t.crisis_latched == false, "離開 crisis → latch 解除")
	# 再進 crisis → edge 再 fire（證明 latch 可重置）
	t.food_flow_avg = -999.0
	_ok(ai._should_reeval(state, t) == true, "再進 crisis → edge 再 fire")

func _test_fix3_food_ready_ref() -> void:
	print("--- Fix3 esteem food_ready 參考線 5→3 ---")
	var state := WorldState.new()
	var t := TeamData.new()
	t.team_id = 2
	t.faction_id = -1
	t.population = 10
	t.ambition_cap = 2
	t.ambition_rung = 0        # ambition_gap = 1.0
	t.food_flow_avg = 0.0
	# 剛脫困：food_days=3（=DESPERATION）→ 新映射 food_ready=3/3=1.0（舊=3/5=0.6）
	var raw3 := NeedHierarchy.compute_raw(state, t, 3.0, 0.0)
	var esteem3: float = raw3[NeedHierarchy.L_ESTEEM]
	# esteem = food_ready × safe_ready(1) × ambition_gap(1) = food_ready
	_ok(esteem3 >= 0.99, "food_days=3(脫困)→ esteem readiness 近滿 (%.2f，舊式僅 0.6)" % esteem3)
	# food_days=1.5（仍絕境）→ food_ready=0.5，esteem 仍中低
	var raw15 := NeedHierarchy.compute_raw(state, t, 1.5, 0.0)
	_ok(raw15[NeedHierarchy.L_ESTEEM] < esteem3, "food_days=1.5(絕境)→ esteem 低於脫困態(單調)")
