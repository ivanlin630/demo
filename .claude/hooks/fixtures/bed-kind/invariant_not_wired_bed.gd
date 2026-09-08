extends SceneTree
# @bed-kind: invariant
# ★陽性對照②：宣告 invariant 卻【不在 merge-gates.tsv】 ⇒ 閘必須紅
func _initialize() -> void:
	print("=== DONE === ALL PASS")
	quit()
