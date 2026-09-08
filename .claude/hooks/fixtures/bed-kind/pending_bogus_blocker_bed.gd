extends SceneTree
# @bed-kind: pending
# blocker: this-token-does-not-exist-in-defers
# ★陽性對照③：blocker 在 defers.tsv 的 token 欄【找不到】 ⇒ 閘必須紅
func _initialize() -> void:
	print("=== DONE === ALL PASS")
	quit()
