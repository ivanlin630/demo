extends SceneTree
# 折現原語（脊椎第一磚）TDD。
# gate3(a) 人格路徑：★最短視人格下，「原地永遠覓食」仍必須是劣解
# gate3(b) ★存糧路徑（R² 必查項、3a 抓不到）：零被動收入＋低存糧＋紮營後仍 net 負 → 紮營仍必須最優
# gate4 人格區辨：不同人格挪門檻但不翻轉結論
# gate5 H_eff 不自打臉：投資後仍赤字 → 視野短（但★用執行後的淨流算）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== discounted flow primitive test ===")

	# δ ＝ 耐性/慎重族，且有地板
	var v_short_vals: Dictionary = {"慎重": 0.0, "貪婪": 1.0}
	var v_long_vals: Dictionary = {"慎重": 1.0, "貪婪": 0.0}
	var d_short: float = DiscountedFlow.delta_of(v_short_vals)
	var d_long: float = DiscountedFlow.delta_of(v_long_vals)
	_ok(d_short >= DiscountedFlow.DELTA_FLOOR, "★蟑螂地板①：最短視人格 δ=%.3f ≥ floor %.2f" % [d_short, DiscountedFlow.DELTA_FLOOR])
	_ok(d_long > d_short, "δ 由耐性/慎重決定（%.3f > %.3f）" % [d_long, d_short])
	_ok(is_equal_approx(DiscountedFlow.delta_of({"慎重": 0.0, "貪婪": 0.0}), d_short),
		"★貪婪不影響 δ（貪婪≠短視；它調的是在意哪種明天）")
	_ok(DiscountedFlow.flow_weight("wealth", {"貪婪": 1.0}) > DiscountedFlow.flow_weight("wealth", {"貪婪": 0.0}),
		"w_k：貪婪對【財流】折得少")
	_ok(is_equal_approx(DiscountedFlow.flow_weight("food", {"貪婪": 0.0}), 1.0), "w_k：活命流不受人格折扣")

	# ★gate3(b) 存糧路徑：紮營後【仍 net 負】但流血變慢 → H_eff 必須跟著放大
	var stock: float = 5.0
	var h_before: float = DiscountedFlow.horizon_eff(-4.8, stock)     # 沒紮營：淨流 -4.8
	var h_after: float = DiscountedFlow.horizon_eff(-0.8, stock)      # 紮營後：淨流 -0.8（仍負）
	_ok(h_after > h_before * 5.0,
		"★★gate3(b) 執行後 runway 6 倍 → H_eff 跟著放大（%.2f → %.2f）＝不被自己的低存糧壓死" % [h_before, h_after])

	# gate5 H_eff 不自打臉：轉正 → full horizon；仍赤字 → 短
	_ok(is_equal_approx(DiscountedFlow.horizon_eff(1.0, 5.0), DiscountedFlow.HORIZON_DAYS),
		"gate5 投資後轉正 → full horizon %.0f" % DiscountedFlow.HORIZON_DAYS)
	_ok(DiscountedFlow.horizon_eff(-2.0, 5.0) < DiscountedFlow.HORIZON_DAYS, "gate5 仍赤字 → 視野短")

	# ★gate3(a) 人格路徑：最短視人格下「永遠覓食」仍是劣解
	# 永遠覓食 ＝ 沒有任何未來增量（value 0）；紮營 ＝ P≈10/日、cost≈0
	var P: float = 10.0
	var h_worst: float = DiscountedFlow.horizon_eff(-0.8, 3.0)   # 低存糧、紮營後仍略負
	# ↑ 最壞情境：存糧只有 3、紮營後仍赤字
	var v_camp: float = DiscountedFlow.option_value(P, 0.0, 0.0, d_short, h_worst)
	_ok(v_camp > 0.0, "★★gate3(a) 最短視人格 + 最壞存糧：紮營折現值 %.2f > 永遠覓食 0" % v_camp)

	# gate4 人格區辨：耐性高的人給更高折現值（挪門檻），但方向一致（都 > 0）
	var v_long: float = DiscountedFlow.option_value(P, 0.0, 0.0, d_long, h_worst)
	_ok(v_long > v_camp and v_camp > 0.0,
		"gate4 人格挪門檻不翻轉結論（耐性 %.2f > 短視 %.2f，兩者同號）" % [v_long, v_camp])

	# baseline ＝ 真實被動所得：有被動收入的隊，紮營增益應該變小
	var v_zero_base: float = DiscountedFlow.option_value(P, 0.0, 0.0, d_long, DiscountedFlow.HORIZON_DAYS)
	var v_with_base: float = DiscountedFlow.option_value(P, 6.0, 0.0, d_long, DiscountedFlow.HORIZON_DAYS)
	_ok(v_with_base < v_zero_base and v_with_base > 0.0,
		"★baseline＝真實被動所得（6/日）→ 增益縮小但仍為正（%.1f < %.1f）" % [v_with_base, v_zero_base])

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
