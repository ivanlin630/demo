extends SceneTree

# mil-facility-cost70 TDD（spec dispatch 2026-07-23）。smeltery+armorsmith material 80→70
# 仿 weaponsmith(:87 已 70)閉同族 afford-ceiling 洞(material 80→×1.5=120>天花板 117;70→105<117 穩達)。
# ★僅這兩+weaponsmith;mint(100 bootstrap)/其餘≤60 不動。

var _fail: int = 0

func _initialize() -> void:
	var sm: float = float(OutpostSystem.upgrade_cost("smeltery", 1).get("material", 0))
	_ok(is_equal_approx(sm, 70.0), "upgrade_cost(smeltery,1).material==70（80→70 閉 afford-ceiling，got %.1f）" % sm)
	var am: float = float(OutpostSystem.upgrade_cost("armorsmith", 1).get("material", 0))
	_ok(is_equal_approx(am, 70.0), "upgrade_cost(armorsmith,1).material==70（got %.1f）" % am)
	# 護欄:weaponsmith 仍 70、mint 仍 100、其餘不動
	_ok(is_equal_approx(float(OutpostSystem.upgrade_cost("weaponsmith", 1).get("material", 0)), 70.0), "weaponsmith 仍 70（未回歸）")
	_ok(is_equal_approx(float(OutpostSystem.upgrade_cost("mint", 1).get("material", 0)), 100.0), "mint 仍 100（bootstrap，不動）")
	_ok(is_equal_approx(float(OutpostSystem.upgrade_cost("workshop", 1).get("material", 0)), 60.0), "workshop 仍 60（≤90 安全，不動）")
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
