extends SceneTree
# ★★★wrapper stdout 完整性探針（implementer 2026-09-04）。
#   ★動機：`construction_funnel_bed` 的第四張表在【兩次不同的跑】都少了中間一段，
#     而尾端的 `=== DONE ===` 【還在】—— ★★那不是「跑被砍」，是【中途掉了一塊】。
#   ★★★而掉一塊的輸出【看起來完全正常】：它有開頭、有結尾、格式也對。
#   ⇒ 本探針只做一件事：印 N 行【自帶序號】的輸出，讓讀的人可以【機械地】驗有沒有缺號。
#   ★不跑世界、不吃 CPU ⇒ 可以隨時跑，也可以並跑。
func _initialize() -> void:
	var n: int = int(OS.get_environment("PROBE_LINES")) if OS.has_environment("PROBE_LINES") else 20000
	var pad: String = "".lpad(0)
	# ★行長刻意做長（>80 字元）：短行不會撞到緩衝邊界，而我要驗的正是邊界。
	var filler: String = "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
	print("[SOI] BEGIN lines=%d" % n)
	for i in range(n):
		print("[SOI] %06d %s" % [i, filler])
	print("[SOI] END lines=%d" % n)
	quit()
