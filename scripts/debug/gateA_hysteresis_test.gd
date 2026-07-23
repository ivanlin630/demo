extends SceneTree

# GATE-A 二刀 返家閉環 hysteresis TDD（spec 2026-07-23-gateA-2nd-cut-return-hysteresis）。
# 根:返家補給 applicable food_days<DESPERATION(3)→隊返家途中 food 過 3→option 消失→漂回 idle/trade→
# 震盪(days_left 卡 1.6-3.0 never 爬升=never 到家補飽)=committed-not-executed。
# 2 touch:①touch0 c.current_task=team.current_task ②返家補給 applicable +returning hysteresis band[3,5]。

var _fail: int = 0

func _initialize() -> void:
	_test_returning_hysteresis()   # ①returning+food 3-5→applicable true(原 false)
	_test_nonreturning_no_hyst()   # ②非 returning+food 3-5→false(不變)
	_test_released_above_band()    # ③food≥5→false(釋放出門)
	_test_trigger_below_desp()     # ④food<3→true(trigger 不變)
	_test_productive_restock()     # ⑤productive returning→restock_need 1.0
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

# ctx：has_home_outpost + productive(過 home gate)，變 current_task + food_days。
func _ctx(task: String, food_days: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.has_home_outpost = true
	c.home_food_productive = true   # 過 home gate（home_food>=RESTOCK_MIN or productive）
	c.home_food = 0.0
	c.current_task = task
	c.food_days = food_days
	c.is_merchant = false
	return c

# ① returning（current_task=RETURN_HOME）+ food 3-5 → 返家補給 applicable=true（hysteresis，原 false）
func _test_returning_hysteresis() -> void:
	print("--- ①returning+food 3-5→applicable ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_RETURN_HOME, 4.0)   # band[3,5) 中
	_ok(appl.call(c), "returning+food 4(band[3,5))→返家補給 applicable（撐返家不漂回，破 oscillation）")

# ② 非 returning + food 3-5 → false（不變，非 returning 不受 hysteresis）
func _test_nonreturning_no_hyst() -> void:
	print("--- ②非 returning+food 3-5→false ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_IDLE, 4.0)
	_ok(not appl.call(c), "非 returning(idle)+food 4→返家補給 not applicable（hysteresis 只對 returning，不亂拉正常隊）")

# ③ food≥5 → false（釋放出門，不過鎖）
func _test_released_above_band() -> void:
	print("--- ③food≥5→釋放 ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_RETURN_HOME, 6.0)   # ≥5 釋放
	_ok(not appl.call(c), "returning+food 6(≥5)→返家補給 not applicable（補飽釋放出門，不過鎖）")

# ④ food<3 → true（trigger 不變；非 returning 也 fire）
func _test_trigger_below_desp() -> void:
	print("--- ④food<3→trigger ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_IDLE, 2.0)   # <DESPERATION 3
	_ok(appl.call(c), "非 returning+food 2(<3)→返家補給 applicable（原 trigger 不變）")

# ⑤ productive-home returning → restock_need 仍 1.0（drive 撐 rank）
func _test_productive_restock() -> void:
	print("--- ⑤productive returning restock_need 1.0 ---")
	var c: DecisionContext = _ctx(TeamData.TASK_RETURN_HOME, 4.0)   # productive=true
	_ok(is_equal_approx(DecisionTerms.eval("restock_need", c, "返家補給"), 1.0), "productive returning → restock_need=1.0（drive 撐 rank 撐住返家）")
