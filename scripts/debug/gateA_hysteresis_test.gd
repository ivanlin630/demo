extends SceneTree
# @bed-kind: acceptance
# slice: GATE-A hysteresis（返家途中撐到 food≥N 才釋放，破 oscillation）
#   ★同上，未接電。

# GATE-A 二刀 返家閉環 hysteresis TDD（spec 2026-07-23-gateA-2nd-cut-return-hysteresis）。
# 根:返家補給 applicable food_days<DESPERATION(3)→隊返家途中 food 過 3→option 消失→漂回 idle/trade→
# 震盪(days_left 卡 1.6-3.0 never 爬升=never 到家補飽)=committed-not-executed。
# 2 touch:①touch0 c.current_task=team.current_task ②返家補給 applicable +returning hysteresis band[3,5]。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["_test_returning_hysteresis", "_test_nonreturning_no_hyst", "_test_released_above_band", "_test_trigger_below_desp", "_test_productive_restock"]

# ★★★【到場點名 ＋ 陽性對照】（systems 派工；樣板同 `constitution_gate` 第一批）——
#   ★病：GDScript 的執行期錯誤**只中止那一支 func**（coroutine 也一樣，`await` 不保護）⇒
#     床照樣跑到最後、照樣印通過橫幅，而 runner 只看 exit code 與 expect ⇒ **兩者都通過**。
#   ★★修法：每一格【自己的最後一行】打卡，末尾對名單，**少一格就把橫幅變成 FAIL**。
#   ★★★用法必須是 `_selftest_gate("格名").noop()` —— 死亡要發生在【那一格自己的 frame】裡
#     （★血證：放進被呼叫的 helper 裡 ⇒ 中止的是 helper、那一格照樣跑完 ⇒ 會誤判成「這裡沒有洞」）。
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing

func _initialize() -> void:
	_test_returning_hysteresis()   # ①returning+food 3-5→applicable true(原 false)
	_test_nonreturning_no_hyst()   # ②非 returning+food 3-5→false(不變)
	_test_released_above_band()    # ③food≥5→false(釋放出門)
	_test_trigger_below_desp()     # ④food<3→true(trigger 不變)
	_test_productive_restock()     # ⑤productive returning→restock_need 1.0
	var _miss: Array = _roll_call_missing()
	var _suffix: String = "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]
	if _fail == 0 and _miss.is_empty():
		print("=== DONE === ALL PASS%s" % _suffix)
	else:
		print("=== DONE === %d FAIL%s" % [_fail + _miss.size(), _suffix])
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
	c.home_food_productive = true   # 過 home gate（home_food>=home_restock_min or productive）
	c.home_food = 0.0
	c.current_task = task
	c.food_days = food_days
	c.is_merchant = false
	return c

# ① returning（current_task=RETURN_HOME）+ food 3-5 → 返家補給 applicable=true（hysteresis，原 false）
func _test_returning_hysteresis() -> void:
	_selftest_gate("_test_returning_hysteresis").noop()
	print("--- ①returning+food 3-5→applicable ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_RETURN_HOME, 4.0)   # band[3,5) 中
	_ok(appl.call(c), "returning+food 4(band[3,5))→返家補給 applicable（撐返家不漂回，破 oscillation）")

# ② 非 returning + food 3-5 → false（不變，非 returning 不受 hysteresis）
	_cell("_test_returning_hysteresis")
func _test_nonreturning_no_hyst() -> void:
	_selftest_gate("_test_nonreturning_no_hyst").noop()
	print("--- ②非 returning+food 3-5→false ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_IDLE, 4.0)
	_ok(not appl.call(c), "非 returning(idle)+food 4→返家補給 not applicable（hysteresis 只對 returning，不亂拉正常隊）")

# ③ food≥5 → false（釋放出門，不過鎖）
	_cell("_test_nonreturning_no_hyst")
func _test_released_above_band() -> void:
	_selftest_gate("_test_released_above_band").noop()
	print("--- ③food≥5→釋放 ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_RETURN_HOME, 6.0)   # ≥5 釋放
	_ok(not appl.call(c), "returning+food 6(≥5)→返家補給 not applicable（補飽釋放出門，不過鎖）")

# ④ food<3 → true（trigger 不變；非 returning 也 fire）
	_cell("_test_released_above_band")
func _test_trigger_below_desp() -> void:
	_selftest_gate("_test_trigger_below_desp").noop()
	print("--- ④food<3→trigger ---")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	var c: DecisionContext = _ctx(TeamData.TASK_IDLE, 2.0)   # <DESPERATION 3
	_ok(appl.call(c), "非 returning+food 2(<3)→返家補給 applicable（原 trigger 不變）")

# ⑤ productive-home returning → restock_need 仍 1.0（drive 撐 rank）
	_cell("_test_trigger_below_desp")
func _test_productive_restock() -> void:
	_selftest_gate("_test_productive_restock").noop()
	print("--- ⑤productive returning restock_need 1.0 ---")
	var c: DecisionContext = _ctx(TeamData.TASK_RETURN_HOME, 4.0)   # productive=true
	_ok(is_equal_approx(DecisionTerms.eval("restock_need", c, "返家補給"), 1.0), "productive returning → restock_need=1.0（drive 撐 rank 撐住返家）")
	_cell("_test_productive_restock")
