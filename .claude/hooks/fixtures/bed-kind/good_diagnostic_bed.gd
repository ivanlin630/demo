extends SceneTree
# @bed-kind: diagnostic
# ★反向綠：真的純診斷 —— 只印觀察，沒有任何判決/完成彙總通道。
#   ★★成對的意義：光有「會紅」那格，證明不了它【不會亂紅】。
func _initialize() -> void:
	print("-- 觀察 --")
	print("  team 3 food_days=4.2 threat=0.31")
	quit()
