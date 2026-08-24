extends SceneTree
# 工期單一真相源 TDD（spec `2026-08-21-build-eta-single-source-HOW.md`）。
#
# ★判準【零手抄物理】：不寫 `24`、不寫 `240`。
#   唯一權威是 `_tick_construction` 那行 `ticks_left -= maxi(pop, 1)`，
#   一天執行 `TICKS_PER_DAY / NEAR_CADENCE` 次。
#   ⇒ 測試把那個迴圈【真的跑一遍】，看 accessor 的預測對不對 —— 這是結構斷言，不是抄來的數字。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

# 真值模擬：照 `outpost_system.gd` 那行逐窗扣，回傳「扣到 0 要幾天」
func _simulate_days(ticks_left: int, pop: int) -> float:
	var per_day: int = int(WorldState.TICKS_PER_DAY / SimRunner.NEAR_CADENCE)
	var windows: int = 0
	var left: int = ticks_left
	while left > 0:
		left -= maxi(pop, 1)
		windows += 1
	return float(windows) / float(per_day)

func _run() -> void:
	print("=== build-eta single source test ===")

	# gate1 與【真的跑一遍那個迴圈】一致（誤差 < 1 個窗口的量級）
	for case in [[720, 1], [720, 5], [1200, 8], [72, 3], [2400, 12]]:
		var ticks: int = int(case[0])
		var pop: int = int(case[1])
		var predicted: float = OutpostSystem.build_eta_days(ticks, pop)
		var actual: float = _simulate_days(ticks, pop)
		var one_window_days: float = 1.0 / float(WorldState.TICKS_PER_DAY / SimRunner.NEAR_CADENCE)
		_ok(abs(predicted - actual) <= one_window_days,
			"gate1 ticks=%d pop=%d：預測 %.4f 天 vs 真跑 %.4f 天（差 < 1 窗 %.4f）"
				% [ticks, pop, predicted, actual, one_window_days])

	# gate2 分母【由 cadence 推導】：拿 SimRunner 的兩顆常數自己算一次，必須相等
	var derived: float = float(WorldState.TICKS_PER_DAY) / float(SimRunner.NEAR_CADENCE)
	_ok(is_equal_approx(OutpostSystem.build_ticks_per_day(), derived),
		"gate2 每日推進次數 ＝ TICKS_PER_DAY / NEAR_CADENCE（%.1f）" % derived)

	# gate3 registry 假設仍成立（outpost_tick 還在 near pass）
	_ok(OutpostSystem._outpost_tick_runs_in_near_pass(),
		"gate3 `outpost_tick` 仍掛在 near pass（假設成立；不成立時 accessor 會 bump 告警）")

	# gate4 單調性與邊界（人多→快、料多→慢、完工→0、pop 0 視同 1）
	_ok(OutpostSystem.build_eta_days(720, 10) < OutpostSystem.build_eta_days(720, 2), "gate4 人多 → 工期短")
	_ok(OutpostSystem.build_eta_days(1440, 5) > OutpostSystem.build_eta_days(720, 5), "gate4 剩得多 → 工期長")
	_ok(OutpostSystem.build_eta_days(0, 5) == 0.0, "gate4 已完工 → 0")
	_ok(is_equal_approx(OutpostSystem.build_eta_days(720, 0), OutpostSystem.build_eta_days(720, 1)),
		"gate4 pop=0 夾到 1（同真值那行的 maxi(pop,1)）")

	# ★gate5 舊公式的錯有多大——把「修法是改接線」講成可驗證的數字（不寫死倍數，現算）
	var ticks5: int = int(OutpostSystem.BUILD_TICKS["civilian"][0])
	var pop5: int = 5
	var truth: float = OutpostSystem.build_eta_days(ticks5, pop5)
	var old_hi: float = float(ticks5) / float(pop5)                                   # #3/#4：漏除每日窗數
	var old_lo: float = float(ticks5) / float(pop5) / float(WorldState.TICKS_PER_DAY)  # #5：多除了整日 tick
	_ok(old_hi > truth and old_lo < truth,
		"gate5 舊兩種寫法一高一低夾住真值（高估 %.1f 天 / 真值 %.1f 天 / 低估 %.3f 天）" % [old_hi, truth, old_lo])
	print("  [scale] 高估倍數 = %.1f×，低估倍數 = %.1f×" % [old_hi / maxf(truth, 0.001), truth / maxf(old_lo, 0.000001)])

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
