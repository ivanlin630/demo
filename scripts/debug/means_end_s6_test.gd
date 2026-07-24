extends SceneTree

# means-end S6 折現 TDD（HOW spec §10 S6+§7）。遠慾望「看得遠」:投資型 candidate util 按 delay×人格折現率折,
# 絕境隊折趨零不走遠路 forest（WHAT §6）。util=payoff×dev_coeff×discount(delay,rate)。
# ★must-fix① 護欄:折現乘法(≤1)只變小非變大→護欄不破(reviewer S6 回歸點)。

var _fail: int = 0

func _initialize() -> void:
	_test_far_discounted()       # ①遠 candidate(delay 大)util 低於近
	_test_near_not_discounted()  # ②近/即時(delay 小)幾乎不折 discount≈1
	_test_persona_rate()         # ③人格折現率(慎重遠視 vs 衝動短視同 delay 不同 discount)
	_test_desperate_far_zero()   # ★④絕境→rate 高→遠 candidate 趨零(不走遠路)
	_test_guardrail_after_discount()# ★★⑤must-fix① range 斷言 regression(折現後絕境 goal<survival)
	_test_delay_estimate()       # delay 估(移動+build 天數有界)
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

func _ctx(food_days: float, caution: float) -> DecisionContext:
	var c := DecisionContext.new(); c.food_days = food_days
	c.leader_values = {"慎重": caution}
	return c

# ① 遠 candidate（delay 大）util 低於近（delay 0）——折現壓遠端
func _test_far_discounted() -> void:
	print("--- ①遠 candidate 折現 ---")
	var c: DecisionContext = _ctx(100.0, 0.5)   # food 足
	var u_near: float = GoalResolver._candidate_util(1.0, c, 0.0)
	var u_far: float = GoalResolver._candidate_util(1.0, c, 20.0)
	_ok(u_far < u_near, "遠 candidate(delay 20)util %.3f < 近(delay 0)%.3f（折現壓遠端，投資型延遲折）" % [u_far, u_near])

# ② 近/即時（delay 0）幾乎不折 discount≈1
func _test_near_not_discounted() -> void:
	print("--- ②近/即時不折 ---")
	var c: DecisionContext = _ctx(100.0, 0.5)
	var u0: float = GoalResolver._candidate_util(1.0, c, 0.0)
	_ok(is_equal_approx(u0, 1.0), "delay 0 → discount≈1，util≈payoff×dev_coeff(食足 1.0)=%.3f（即時不折）" % u0)

# ③ 人格折現率：慎重(遠視)vs 衝動(短視)同 delay 不同 discount
func _test_persona_rate() -> void:
	print("--- ③人格折現率 ---")
	var c_caut: DecisionContext = _ctx(100.0, 0.9)   # 慎重 遠視 rate 低
	var c_imp: DecisionContext = _ctx(100.0, 0.1)    # 衝動 短視 rate 高
	var u_caut: float = GoalResolver._candidate_util(1.0, c_caut, 10.0)
	var u_imp: float = GoalResolver._candidate_util(1.0, c_imp, 10.0)
	_ok(u_caut > u_imp, "同 delay 10：慎重遠視 util %.3f > 衝動短視 %.3f（人格=折現率，肯投遠利 vs 短視）" % [u_caut, u_imp])

# ★④ 絕境（food_days 低）→ rate 高 → 遠 candidate 趨零（不走遠路 forest）
func _test_desperate_far_zero() -> void:
	print("--- ★④絕境遠 candidate 趨零 ---")
	var c_desp: DecisionContext = _ctx(0.3, 0.5)   # 絕境 food_days 0.3
	var u_desp_far: float = GoalResolver._candidate_util(1.0, c_desp, 20.0)
	var c_ok: DecisionContext = _ctx(100.0, 0.5)
	var u_ok_far: float = GoalResolver._candidate_util(1.0, c_ok, 20.0)
	_ok(u_desp_far < u_ok_far and u_desp_far < 0.05, "絕境遠 candidate util %.4f 趨零（dev_coeff 壓+rate 高折→不走遠路輸眼前糧危，WHAT §6）" % u_desp_far)

# ★★⑤ must-fix① range 斷言 regression：折現後絕境 goal candidate util 仍 < survival-boosted static
func _test_guardrail_after_discount() -> void:
	print("--- ★★⑤must-fix① range regression(折現後) ---")
	var c_desp: DecisionContext = _ctx(0.001, 0.5)
	var u: float = GoalResolver._candidate_util(1.0e9, c_desp, 20.0)   # 巨 payoff+遠 delay+絕境
	_ok(u < DecisionEngine.SURVIVAL_BOOST_MAX, "折現後絕境 goal util(%.3f) < SURVIVAL_BOOST_MAX %.1f（護欄乘法只變小=不破，reviewer S6 回歸）" % [u, DecisionEngine.SURVIVAL_BOOST_MAX])

# delay 估：移動天數 + build 天數有界
func _test_delay_estimate() -> void:
	print("--- delay 估 ---")
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0, 0)
	var d_near: float = GoalResolver._estimate_delay_days(t, {"task": TeamData.TASK_TRADE, "target": Vector2i(0, 0)})
	_ok(is_equal_approx(d_near, 0.0), "自己 tile+非 build → delay 0（即時）")
	var d_build: float = GoalResolver._estimate_delay_days(t, {"task": TeamData.TASK_BUILD, "target": Vector2i(0, 0)})
	_ok(d_build > 0.0, "build action → delay 含工期(%.1f>0)" % d_build)
