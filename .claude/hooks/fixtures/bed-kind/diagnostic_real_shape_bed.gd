extends SceneTree
# @bed-kind: diagnostic
# ★陽性對照③b-2：★★★樣本【逐字取自真實床】`scripts/debug/ui_flow_test.gd:32`
#   —— 不是照偵測器的形狀造的（舊 fixture 寫的是字面 `=== DONE === ALL PASS`，
#   而真實床從來不長那樣 ⇒ 自檢全綠而真實的謊過得去）。
var _errors: int = 0
func _initialize() -> void:
	print("\n=== UI Flow Test DONE === errors: %d" % _errors)
	quit()
