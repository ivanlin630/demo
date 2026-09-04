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
	# ★★★兩種【形狀】而不是兩種大小（2026-09-04 訂正）：
	#   ★`many`  ＝ N 次獨立 `print()`（我第一版只測了這個 ⇒ 20000 行缺號 0）
	#   ★★`giant` ＝ 把 N 行 join 成【一個字串】只 print 一次
	#     ⇒ ★★★而那正是 `construction_funnel_bed.gd:559` 的形狀（`print(\n 串接)`），
	#       也就是我要重現的那個實物 —— ★我第一版測錯了形狀，所以測不出來。
	var mode: String = OS.get_environment("PROBE_MODE") if OS.has_environment("PROBE_MODE") else "many"
	print("[SOI] BEGIN lines=%d mode=%s" % [n, mode])
	if mode == "giant":
		var buf: PackedStringArray = PackedStringArray()
		for i in range(n):
			buf.append("[SOI] %06d %s" % [i, filler])
		print(("\n").join(buf))
	else:
		for i in range(n):
			print("[SOI] %06d %s" % [i, filler])
	print("[SOI] END lines=%d mode=%s" % [n, mode])
	quit()
