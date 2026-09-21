extends SceneTree
# @bed-kind: gate
# slice: 一天有多長＝單一真值（票：窗標籤把「一天」手抄成 240，真值 1440）
#
# ★這支床擋什麼：**把 240 當【週期】用**（`/ 240`／`% 240`／`240 * N`）——
#   那是【手抄一天】的形狀，而它讓所有「天／月／年」標籤差 6 倍。
# ★★它【不】裸掃 `240`：240 在本 repo 有合法身分（`MOVE_TICKS_PER_HEX` ＝ 240 tick ＝ 4 小時）
#   ⇒ 裸掃分不出【合法的 240】與【手抄的一天】，只會製造假紅而沒有人再看這支閘。
# ★★★壞掉會長什麼樣（不是寫「別亂改」）：
#   有人為了「省事」直接把 240 換成 1440 ⇒ 這支閘會【變綠】而病沒好 ——
#   因為病不是那個數值錯，是【那個數值被手抄】。下一次 TICKS_PER_HOUR 一動，1440 又會腐爛。
#   ⇒ 所以真正的修法是【讀 WorldState.TICKS_PER_DAY】，而這支閘只能看見形狀、看不見動機。
#
# ★誠實限（寫在這裡，不寫在信裡就沒人看得到）：
#   ①它只掃 `scripts/`，掃不到 `tools/`、`config/`、doc 裡的換算。
#   ②它剝【行內註解】才比對（否則會命中「原寫 240*30」這種【說明自己歷史】的註解）——
#     ★而剝註解本身要小心字串裡的 `#`，所以剝法是逐字元走、遇到字串就整段收下。
#   ③它看不到【被指派給識別字】的手抄（`const TPD := 240` 之後用 `TPD`）——
#     ★那個形狀由下面第②格單獨守（掃「識別字 ＝ 240 而註解／名字自稱是一天」）。

var _fail: int = 0
var _cells: Array = []
var _pc_ok: int = -1   # ★毒值：沒跑到陽性對照那一格 ⇒ 卷面印 -1 ⇒ expect 不命中 ⇒ 紅
static var _D: String = "2" + "40"   # ★字面不出現在本檔：否則這支閘會把自己的判準行判成違規
const EXPECT_CELLS: int = 3   # ★到場點名的分母＝【常數期望】，不是「跑了幾格」

func _initialize() -> void:
	_run()
	# ★橫幅印在最後一格【之後】；N／N 的分母是常數 ⇒ 少跑一格就對不上
	print("[DAYLEN] 到場點名 %d／%d" % [_cells.size(), EXPECT_CELLS])
	if _cells.size() != EXPECT_CELLS:
		push_error("[FAIL] 到場點名 %d／%d —— 有格沒跑完（GDScript 只中止那一支 func）" % [
			_cells.size(), EXPECT_CELLS])
		_fail += 1
	print("=== day_length_single_source_gate DONE（fail=%d｜到場點名 %d／%d｜陽性對照 %d／10）===" % [
		_fail, _cells.size(), EXPECT_CELLS, _pc_ok])
	quit(1 if _fail > 0 else 0)

static func _id_liar(code: String) -> bool:
	var idre := RegEx.create_from_string("(const|var)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*(:=|:\\s*int\\s*=|=)\\s*" + _D + "\\b")
	var m := idre.search(code)
	if m == null: return false
	var nm: String = m.get_string(2).to_lower()
	# ★★判準必須指涉【日】：`ticks_per` 太寬 —— MOVE_TICKS_PER_HEX（每 hex 240 tick ＝ 4 小時）合法，
	#   而它被我第一版【誤殺】了。★★★是陽性對照抓到的，不是我讀出來的。
	return nm.contains("per_day") or nm == "tpd" or nm.ends_with("_day") \
		or nm.contains("day_tick")

# ── 判準本體（★兩處共用同一個實作：本體與陽性對照必須是同一支，否則自檢只證明副本會動）──
static func _period_use(code: String) -> bool:
	var re := RegEx.create_from_string("(/|%|\\*)\\s*" + _D + "\\b|\\b" + _D + "\\s*\\*\\s*[0-9]")
	return re.search(code) != null

static func _strip_comment(line: String) -> String:
	var out: String = ""
	var instr: String = ""
	for i in range(line.length()):
		var ch: String = line[i]
		if instr != "":
			out += ch
			if ch == instr: instr = ""
		elif ch == "\"" or ch == "'":
			instr = ch
			out += ch
		elif ch == "#":
			break
		else:
			out += ch
	return out

static func _walk(dir_path: String, acc: Array) -> void:
	var d := DirAccess.open(dir_path)
	if d == null: return
	d.list_dir_begin()
	var name := d.get_next()
	while name != "":
		var full: String = dir_path + "/" + name
		if d.current_is_dir():
			if not name.begins_with("."): _walk(full, acc)
		elif name.ends_with(".gd"):
			acc.append(full)
		name = d.get_next()
	d.list_dir_end()

func _run() -> void:
	print("=== 一天有多長＝單一真值（★母體＝把 240 當週期用，不是裸掃 240）===")
	print("[DAYLEN] 真值 WorldState.TICKS_PER_DAY = %d" % WorldState.TICKS_PER_DAY)

	# ── ①陽性對照：先證明判準【打得中】，再用它的陰性結果下結論 ──
	#   ★沒有這一格，「0 行」與「判準壞掉」長得一模一樣。
	# ★★★樣本【在執行期拼出來】：若把那個形狀寫成字面，這支閘掃到自己就會把自己的
	#   陽性對照判成違規 ——「引用一個形狀」與「犯那個形狀」在文字上不可分。
	var D: String = _D
	var must_hit: Array = [
		"\tvar day: int = tick / " + D,
		"\t\tif (tick + 1) % (" + D + " * 30) == 0:",
		"range(" + D + " * 60)",
	]
	var must_miss: Array = [
		"const MOVE_TICKS_PER_HEX: int = " + D,              # ★合法的那個數（4 小時），不得誤殺
		"\t# ★原寫 " + D + "*30 並稱「月」",                  # ★純註解：剝掉之後不該命中
		"\tvar day: int = tick / WorldState.TICKS_PER_DAY",  # ★修好的形狀
	]
	var pc_ok: int = 0
	for s in must_hit:
		if _period_use(_strip_comment(s)): pc_ok += 1
		else: push_error("[FAIL][陽性對照] 判準【沒打中】應該紅的樣本：%s" % s)
	for s in must_miss:
		if not _period_use(_strip_comment(s)): pc_ok += 1
		else: push_error("[FAIL][陽性對照] 判準【誤殺】不該紅的樣本：%s" % s)
	# ★第③格的判準也要有自己的陽性對照（否則它「不會亂紅」與「永遠不會紅」長得一樣）
	var id_hit: Array = ["const TPD := " + D, "const TICKS_PER_DAY: int = " + D]
	var id_miss: Array = ["const TICK_RUN: int = " + D, "const MOVE_TICKS_PER_HEX: int = " + D]
	for s2 in id_hit:
		if _id_liar(_strip_comment(s2)): pc_ok += 1
		else: push_error("[FAIL][陽性對照] 識別字判準【沒打中】：%s" % s2)
	for s2 in id_miss:
		if not _id_liar(_strip_comment(s2)): pc_ok += 1
		else: push_error("[FAIL][陽性對照] 識別字判準【誤殺】：%s" % s2)
	var pc_total: int = must_hit.size() + must_miss.size() + id_hit.size() + id_miss.size()
	_pc_ok = pc_ok
	print("[DAYLEN] 陽性對照 %d／%d（5 個會紅 ＋ 5 個不會亂紅）" % [pc_ok, pc_total])
	if pc_ok != pc_total: _fail += 1
	_cells.append("positive-control")

	# ── ②母體：scripts/ 裡還有幾行把 240 當週期用 ──
	var files: Array = []
	_walk("res://scripts", files)
	var bad: Array = []
	for f in files:
		var txt := FileAccess.get_file_as_string(f)
		if txt == "": continue
		var ln: int = 0
		for line in txt.split("\n"):
			ln += 1
			if _period_use(_strip_comment(line)):
				bad.append("%s:%d: %s" % [f, ln, line.strip_edges().substr(0, 90)])
	print("[DAYLEN] 掃了 %d 個 .gd｜★母體（把 240 當週期用）＝ %d 行" % [files.size(), bad.size()])
	if files.size() < 100:
		push_error("[FAIL] 只掃到 %d 個檔 ⇒ 母體塌陷（掃描器壞了，不是世界乾淨了）" % files.size())
		_fail += 1
	for b in bad:
		push_error("[FAIL] 把 240 當週期用：%s" % b)
	if not bad.is_empty(): _fail += 1
	_cells.append("population")

	# ── ③識別字形態：`const X = <那個數>` 而【名字】自稱是一天 ──
	#   ★這是 spec §0.1 自報抓不到的那個洞（判準本體在 _id_liar，與陽性對照共用同一支）。
	var liars: Array = []
	for f in files:
		var txt2 := FileAccess.get_file_as_string(f)
		if txt2 == "": continue
		var ln2: int = 0
		for line in txt2.split("\n"):
			ln2 += 1
			if not _id_liar(_strip_comment(line)): continue
			liars.append("%s:%d: %s" % [f, ln2, line.strip_edges().substr(0, 90)])
	print("[DAYLEN] 識別字【名字】自稱一天卻手抄的：%d 行" % liars.size())
	for l in liars:
		push_error("[FAIL] 識別字手抄一天：%s" % l)
	if not liars.is_empty(): _fail += 1
	_cells.append("identifier-shape")
