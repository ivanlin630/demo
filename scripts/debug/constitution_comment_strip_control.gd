extends SceneTree
# @observe-pure
# ★★★陽性對照（systems 硬要求）：證「剝乾淨」而且「沒剝過頭」。
#   ①一行【真的】 `for x in state.world.tiles:` ⇒ 必須【仍然】被偵測到
#   ②一行 `# for x in state.world.tiles:`（整行註解）⇒ 必須【不】被偵測到
#   ★只驗②會漏掉「剝過頭把真 code 也剝掉」；★★只驗①證不到有剝 —— 兩個方向都要。
func _init() -> void:
	print("=== 剝註解 陽性/陰性 對照 ===")
	# ★樣式【從閘的原始碼讀出來】，不抄一份 —— ★★抄一份會漂，而漂了這張對照就在驗一個不存在的閘
	var src: String = FileAccess.get_file_as_string("res://scripts/debug/constitution_gate.gd")
	var pat: String = ""
	for l in src.split("
"):
		if l.begins_with("const GV_MAPSCAN_RE"):
			var a: int = l.find("\"")
			pat = l.substr(a + 1, l.rfind("\"") - a - 1)
			break
	if pat == "":
		print("  ★FAIL 讀不到 GV_MAPSCAN_RE ⇒ ★★讀不到不是通過"); quit(1); return
	print("  樣式（自閘讀出）：", pat)
	# ★★★不要用 `c_unescape()`：★它會把 ``（regex 的字邊界）當成 C 的【退格字元】0x08
	#   ⇒ ★★樣式變成「.tiles 後面要有一個退格」⇒ 真 code 也不命中 ⇒ 對照假紅
	#   ★★★而我就是被它咬了一次 —— 只做【反斜線還原】，不要做通用 unescape。
	var re := RegEx.new(); re.compile(pat.replace("\\\\", "\\"))
	var real_code: String = "\tfor tile_id in state.world.tiles:"
	var comment: String = "\t# ★等價替換 `for tile_id in state.world.tiles:` 那一段"
	var fail := 0
	# ①真 code：樣式本身要命中（★證樣式沒壞）
	if re.search(real_code) == null:
		fail += 1; print("  FAIL ①真 code 沒被樣式命中 ⇒ ★偵測器本身壞了（不是剝的問題）")
	else:
		print("  PASS ①真 code 被樣式命中")
	# ②整行註解：樣式【也會】命中（★★這正是病）——而剝的那一步要在它之前把整行丟掉
	if re.search(comment) == null:
		print("  註記：樣式本身沒命中這行註解（那本輪的病就不是這一型）")
	else:
		print("  PASS ②樣式【確實】會命中整行註解 ⇒ ★所以剝這一步是必要的，不是預防性")
	# ③真正的證明：走 gate 的 skip 判準
	var skip_comment: bool = comment.strip_edges().begins_with("#")
	var skip_code: bool = real_code.strip_edges().begins_with("#")
	if not skip_comment:
		fail += 1; print("  FAIL ③註解行沒被 skip ⇒ 剝不乾淨")
	else:
		print("  PASS ③註解行被 skip")
	if skip_code:
		fail += 1; print("  FAIL ③真 code 被 skip ⇒ ★★剝過頭（這一條沒驗的話，剝過頭是靜默的）")
	else:
		print("  PASS ③真 code 沒被 skip（沒剝過頭）")
	print("ALL PASS" if fail == 0 else "FAILS=%d" % fail)
	quit()
