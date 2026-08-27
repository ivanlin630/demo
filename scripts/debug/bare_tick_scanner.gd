extends SceneTree
# ★★★S1a：裸 tick 字面量【掃描器】—— 只產候選清單，★一顆字面量都不改（那是 S1b）。
#
# ★為什麼先產清單：★★清單就是 S1b 的【母體】—— 先有母體才能對帳「每一顆都有處置」。
#
# ★★★而 LOCKED spec 寫「擴充 `time_const_check.gd`」是不可行的（我開檔驗過）：
#   那支只有 25 行、硬編 10 顆具名常數的數值比對表、★零掃描能力 ⇒ 掃描能力【從零建】。
#
# ★候選定義：與 tick 族符號【同一行】出現的整數字面量。
#   ★★先剝掉【註解】與【字串字面量】再找數字 —— 否則 `".day.%03d" % current_tick` 會誤報 03。
#
# ★★★★★誠實限（★寫在【輸出頭】而不是只寫在信裡，因為讀清單的人未必讀過那封信）：
#   本掃描器是【文字比對】，看不到「把 tick 存進改名變數後再比裸值」：
#       var t = current_tick     ← 看不到
#       if t % 5 == 0:           ← 這顆裸 5 逃掉
#   ★這是【永久】盲點，不是本票能關的洞（GDScript 沒有可在 .gd 內呼叫的輕量 AST introspection）。
#
# 輸出：每筆一行、★ASCII `|` 分隔（★emoji 不得當欄位錨——emoji 打進 grep pattern 會回假 0）
#   path|line|literal|symbol|source
# env：SCAN_OUT（預設 docs/measurements/2026-08-27-bare-tick-candidates.txt）

const SCAN_ROOT: String = "res://scripts"
const EXCLUDE_DIRS: Array = ["res://scripts/debug"]   # ★床與測試；★排除寫在輸出裡不藏在 code 裡

var _sym_re: RegEx
var _num_re: RegEx
var _str_re: RegEx
var _name_re: RegEx

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	_sym_re = RegEx.new()
	_sym_re.compile("(current_tick|[A-Za-z_]+_next_tick|[A-Za-z_]+_eval_tick|TICKS_PER_[A-Z_]+|elapsed_ticks|\btick\b)")
	_num_re = RegEx.new(); _num_re.compile("(?<![A-Za-z0-9_.])([0-9]+)(?![0-9.])")
	_str_re = RegEx.new(); _str_re.compile("\"[^\"]*\"|'[^']*'")

	# ★★★第二軸（盲點修補 2026-08-27，systems 揭）：
	#   ★第一軸是【同行有 tick 符號】—— 它找的是【引用者】。
	#   ★★而 `const MSG_TTL_SHORT: int = 1680` 【自己就是那個值】，不引用任何 tick 符號
	#     ⇒ 【找引用者】永遠抓不到【定義者】，而那一族真的出事了（30 天靜默變 5 天）。
	#   ★★★所以第二軸換一個問法：【名字像時長 ＋ 值是裸整數】。
	#   ★它會誤報（例：MAX_MESSAGES 之類不在名單上，但 WINDOW/CADENCE 可能是次數）
	#     ★★而誤報的代價是【多一筆要人判】，漏報的代價是【靜默變 1/6】—— 不對稱，往吵的那邊倒。
	_name_re = RegEx.new()
	_name_re.compile("const\\s+([A-Z_]*(TTL|TIMEOUT|COOLDOWN|DURATION|DELAY|LIFETIME|EXPIRE|GRACE|WINDOW|CADENCE|INTERVAL|TICKS)[A-Z_]*)\\s*:\\s*int\\s*=\\s*[0-9]+\\s*$")

	# ── ★陽性對照：三種位置各一，走【同一支 `_scan_line`】，只是輸入被構造 ──
	var ctrl: Array = [
		["mod",  "\tif current_tick % 5 == 0:"],
		["cmp",  "\tif team.order_eval_next_tick > 120:"],
		["addsub", "\tvar n: int = state.world.current_tick + 240"]]
	var ctrl_lines: Array = []
	var ctrl_ok: int = 0
	for c in ctrl:
		var hits: Array = _scan_line(String(c[1]))
		ctrl_lines.append("CONTROL|%s|hits=%d|%s" % [String(c[0]), hits.size(), String(c[1]).strip_edges()])
		if hits.size() >= 1:
			ctrl_ok += 1
	# ★陰性對照：沒有 tick 符號的行不得命中（★否則掃描器等於全抓，清單毫無資訊）
	var neg: Array = _scan_line("\tvar hp: int = 100 + 5")
	ctrl_lines.append("CONTROL|negative|hits=%d|var hp: int = 100 + 5" % neg.size())

	var rows: Array = []
	var files_walked: int = 0
	files_walked = _walk(SCAN_ROOT, rows)

	var out_path: String = _env("SCAN_OUT", "docs/measurements/2026-08-27-bare-tick-candidates.txt")
	var head: Array = [
		"# ★S1a 裸 tick 候選清單（scanner: scripts/debug/bare_tick_scanner.gd）",
		"# ★★本票【一顆字面量都沒改】——本清單是 S1b 的母體。",
		"#",
		"# ★★★誠實限（永久盲點，不是本票能關的洞）：",
		"#   本掃描器是【文字比對】，看不到「把 tick 存進改名變數後再比裸值」：",
		"#       var t = current_tick     ← 看不到",
		"#       if t % 5 == 0:           ← 這顆裸 5 逃掉",
		"#   ⇒ ★清單【不是完備的】。讀的人請不要把它當成「全部」。",
		"#",
		"# 掃描範圍：%s｜★排除：%s（床與測試）" % [SCAN_ROOT, str(EXCLUDE_DIRS)],
		"# 走訪檔案數：%d｜候選筆數：%d" % [files_walked, rows.size()],
		"# 比對前先剝掉：註解（#之後）＋字串字面量（避免 \"%03d\" 之類誤報）",
		"#",
		"# 欄位（★ASCII | 分隔，可 grep；★emoji 不得當欄位錨）：path|line|literal|symbol|note|source",
		"# ★note 是【標籤不是過濾】——★★一筆都沒有被丟掉，母體完整；標籤只是讓 S1b 的分流便宜一點。",
		"#   decl_init = `var x: int = 0` 這種宣告初值（機械形狀，多半不是要改的那種裸值）",
		"#",
		"# ── 陽性/陰性對照（走同一支 _scan_line，只是輸入被構造）──"]
	for cl in ctrl_lines:
		head.append("# " + String(cl))
	head.append("# ★對照判準：mod／cmp／addsub 三種【各至少 1 hit】，negative【必須 0 hit】")
	head.append("# ★★實測：陽性 %d/3 ；陰性 %d hit" % [ctrl_ok, neg.size()])
	head.append("#")
	var text: String = "\n".join(PackedStringArray(head)) + "\n" + "\n".join(PackedStringArray(rows)) + "\n"
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		f.store_string(text); f.close()
	print("\n[S1a] 走訪 %d 檔｜候選 %d 筆｜★陽性對照 %d/3、陰性 %d hit" % [
		files_walked, rows.size(), ctrl_ok, neg.size()])
	print("[S1a] 落地：%s" % out_path)
	if ctrl_ok < 3 or neg.size() != 0:
		print("[S1a][FAIL] ★對照沒過 —— 清單不可信（抓不到 = 沒看那裡；陰性有 hit = 全抓）")
	print("=== bare_tick_scanner DONE ===")

# ★單行掃描（★對照與實掃走同一支，不另寫一份比對邏輯）
func _scan_line(raw: String) -> Array:
	var out: Array = []
	var line: String = raw
	var h: int = line.find("#")
	if h != -1:
		line = line.substr(0, h)          # 剝註解
	line = _str_re.sub(line, "\"\"", true)  # 剝字串字面量
	var sm := _sym_re.search(line)
	var sym: String = ""
	if sm != null:
		sym = sm.get_string(1)
	else:
		# ★第二軸：沒有引用 tick 符號，但名字像時長且值是裸整數
		var nmm := _name_re.search(line)
		if nmm == null:
			return out
		sym = "name:" + nmm.get_string(1)
	for nm in _num_re.search_all(line):
		out.append({"literal": nm.get_string(1), "symbol": sym})
	return out

# ★標籤（★不是過濾）：把機械形狀標出來，讓 S1b 分流便宜 —— ★而一筆都不丟。
func _note_of(raw: String) -> String:
	var t: String = raw.strip_edges()
	if t.begins_with("var ") and t.find(": int = ") != -1:
		return "decl_init"
	if t.begins_with("const "):
		return "const_def"
	return "-"

func _walk(dir_path: String, rows: Array) -> int:
	for ex in EXCLUDE_DIRS:
		if dir_path == String(ex):
			return 0
	var n: int = 0
	var d := DirAccess.open(dir_path)
	if d == null:
		return 0
	d.list_dir_begin()
	var name_s: String = d.get_next()
	while name_s != "":
		var full: String = dir_path + "/" + name_s
		if d.current_is_dir():
			if not name_s.begins_with("."):
				n += _walk(full, rows)
		elif name_s.ends_with(".gd"):
			n += 1
			_scan_file(full, rows)
		name_s = d.get_next()
	d.list_dir_end()
	return n

func _scan_file(path: String, rows: Array) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var rel: String = path.replace("res://", "")
	var ln: int = 0
	while not f.eof_reached():
		var raw: String = f.get_line()
		ln += 1
		for hit in _scan_line(raw):
			rows.append("%s|%d|%s|%s|%s|%s" % [
				rel, ln, String(hit["literal"]), String(hit["symbol"]), _note_of(raw), raw.strip_edges()])
	f.close()

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
