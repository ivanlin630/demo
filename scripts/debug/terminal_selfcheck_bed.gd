extends SceneTree
# @bed-kind: invariant
# ══ 終端介面自驗（spec §3 六條 ＋ §15③ debug 識別字 ＋ §16 的「＝0 必配反向」）══════
# spec：`docs/superpowers/specs/2026-10-01-player-ui-is-a-terminal-repl-HOW.md`
# 用戶逐字：「新版UI更爛 爛到沒救 改用終端形式的文字UI 你們自己抓排版 重複選項等問題」
#
# ★★★★★★【本床的形狀，以及為什麼是這個形狀】
#   ·六條自驗全部寫成**對「一屏字串」的純函式**（`_bad_*()`），回**違規清單**不回一個數
#     ⇒ 一個「有幾行超寬」的數字說不出**是哪一行**，而要修的人要的是那一行。
#   ·★**而每一條「＝ 0」都配一條【同一個抽取器在另一個輸入上必須 > 0】**（systems 裁 §16）：
#     反向對照**擾動的是那個函式的【輸入字串】**，不是世界、不是 production
#     ⇒ 「負對照要動【輸入】不要動【事實】」那一條的乾淨應用。
#   ·★★而**母體地板**與**反向對照**是兩件事，本床分開印：
#       母體地板 ＝ 「它**有沒有東西可量**」（這一屏有幾行、幾個區塊）
#       反向對照 ＝ 「它**量得出東西**」（＝有鑑別力）
#     ★★★**兩者都缺的那一格，它的綠完全無法區分於「這個功能根本不存在」。**
#
# ★★而「走法」＝ 一串**鍵的 token**，餵進 `PlayerRepl.keycode_for()` ＋ `node._input()`
#   ⇒ 與 REPL 走**同一條路**（不另造一條驅動方式），而那也順便驗了那個詞法器。

const SPEC_WALKS_MIN: int = 6        # spec §3 要六支走法（★含退化版本，見 WALKS）
var _errors: int = 0
var _cells_ran: Array = []

const EXPECTED_CELLS: Array = [
	"_test_a_regions_present_and_ordered",
	"_test_b_no_duplicate_labels",
	"_test_d_no_english_identifiers",
	"_test_e_width_and_no_empty_region",
	"_test_f_same_state_renders_identically",
	"_test_g_player_walk_has_no_debug_tokens",
	"_test_c_printed_keys_are_typeable",
]

# ══ 走法表（spec §3「六支走法」＋ R² 要的**退化版本**）════════════════════════════
# ★`setup` ＝ 開跑前對世界做什麼（退化狀態在這裡造：0 coin／清空清單）
# ★★`tokens` ＝ 一行一個鍵，與 REPL 完全同一條路
const WALKS: Array = [
	{"name": "開場", "tokens": [], "degenerate": false},
	{"name": "開場·退化（0 coin）", "tokens": [], "degenerate": true},
	{"name": "互動（t）", "tokens": ["t"], "degenerate": false},
	{"name": "互動·退化（0 coin）", "tokens": ["t"], "degenerate": true},
	{"name": "分頁切換（.）", "tokens": [".", "."], "degenerate": false},
	{"name": "物品（i）", "tokens": ["i"], "degenerate": false},
]

# ★debug 識別字（spec §15③，**逐一指名**）—— 玩家走法的輸出裡這些一個都不准出現
const DEBUG_TOKENS: Array = ["真值·debug", "tile_id", "outpost_level", "收成係數",
	"格上隊伍", "非附身者所知"]

# ★(d) 英文識別字：判準是「連續 3 個以上的小寫拉丁字母」，而**白名單逐一指名**
#   （★玩家畫面上合法出現的英文只有這些；多一個就要先問它該不該在那裡）
const EN_WHITELIST: Array = ["Team", "HP", "Esc", "Enter", "WASD", "Space", "Tick", "Day"]


func _init() -> void:
	print("=== terminal_selfcheck：終端介面自驗 ===")
	_run()

func _run() -> void:
	await _test_a_regions_present_and_ordered()
	await _test_b_no_duplicate_labels()
	await _test_d_no_english_identifiers()
	await _test_e_width_and_no_empty_region()
	await _test_f_same_state_renders_identically()
	await _test_g_player_walk_has_no_debug_tokens()
	await _test_c_printed_keys_are_typeable()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	if not missing.is_empty():
		_errors += 1
		push_error("[FAIL] ★到場點名缺：%s" % str(missing))
	print("\n=== terminal_selfcheck DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


# ══ 走法 → 一屏字串 ═══════════════════════════════════════════════════════════
func _screen_for(walk: Dictionary) -> String:
	seed(1337)
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	if bool(walk.get("degenerate", false)):
		var st: WorldState = node._bridge.get_state()
		var pt: TeamData = st.teams.get(st.persons[st.player_id].team_id)
		ResourceBank.set_amt(pt, "coin", 0.0, "bed_fixture")
	for t in walk.get("tokens", []):
		var kc: int = PlayerRepl.keycode_for(String(t))
		if kc == -1:
			continue
		var ev: InputEventKey = InputEventKey.new()
		ev.keycode = kc
		ev.pressed = true
		node._input(ev)
	node._refresh()
	var s: String = String(node._screen_label.text)
	node.queue_free()
	await process_frame
	return s


func _all_screens() -> Array:
	var out: Array = []
	for w in WALKS:
		var s: String = await _screen_for(w as Dictionary)
		out.append({"name": String((w as Dictionary).get("name", "?")), "screen": s,
			"degenerate": bool((w as Dictionary).get("degenerate", false))})
	return out


# ══ 六條判準（純函式，回【違規清單】不回一個數）═════════════════════════════════

# (a) 區塊齊全且順序固定
# ★★panel 非空時**取代** map+pages 那一框（`text_ui_view.gd:272`）⇒ 那兩個錨在子模式中
#   **本來就不該出現** ⇒ 判準要照這條規則走，否則它會在每一個子模式屏上誤報。
static func _bad_regions(screen: String) -> Array:
	var bad: Array = []
	var has_panel: bool = screen.contains(TextUiView.A_PANEL)
	var want: Array = []
	for a in TextUiView.REGION_ANCHORS:
		var an: String = String(a)
		if has_panel and (an == TextUiView.A_MAP or an == TextUiView.A_PAGES):
			continue
		want.append(an)
	var last: int = -1
	for a2 in want:
		var an2: String = String(a2)
		var n: int = screen.count(an2)
		if n != 1:
			bad.append("錨 `%s` 出現 %d 次（要剛好 1 次）" % [an2, n])
			continue
		var at: int = screen.find(an2)
		if at < last:
			bad.append("錨 `%s` 的位置在前一個之前（順序亂了）" % an2)
		last = at
	return bad


# (b) 同一屏同一選項標籤只准出現一次（★整列相等，不用子字串）
static func _bad_duplicate_labels(screen: String) -> Array:
	var labels: Array = []
	for line in screen.split("\n"):
		var l: String = String(line)
		var parts: PackedStringArray = l.split("[")
		for p in parts:
			var ps: String = String(p)
			if ps.length() < 3 or ps[1] != "]":
				continue
			if not ps[0].is_valid_int():
				continue
			var lbl: String = _label_head(ps.substr(2).strip_edges())
			if lbl != "":
				labels.append(lbl)
	var seen: Dictionary = {}
	var dup: Array = []
	for lb in labels:
		var k: String = String(lb)
		seen[k] = int(seen.get(k, 0)) + 1
		if int(seen[k]) == 2:
			dup.append(k)
	return dup


# 把標籤後面黏著的裝飾切掉（三個切點取最前）——★與 `ui_flow_test._label_head()` 同一個形狀
static func _label_head(rest: String) -> String:
	var cuts: Array = [rest.find("  "), rest.find(TextUiView.SUBMENU_MARK), rest.find("（不可")]
	var at: int = -1
	for c in cuts:
		var ci: int = int(c)
		if ci > 0 and (at < 0 or ci < at):
			at = ci
	return (rest.substr(0, at) if at > 0 else rest).strip_edges()


# (d) 無英文識別字（★白名單逐一指名；判準 ＝ 連續 3 個以上小寫拉丁字母）
static func _bad_english(screen: String) -> Array:
	var bad: Array = []
	var cur: String = ""
	var body: String = screen
	for w in EN_WHITELIST:
		body = body.replace(String(w), "")
	for i in range(body.length() + 1):
		var ch: String = body[i] if i < body.length() else " "
		var is_low: bool = ch.length() == 1 and ch >= "a" and ch <= "z"
		if is_low or ch == "_":
			cur += ch
		else:
			if cur.length() >= 3 and not bad.has(cur):
				bad.append(cur)
			cur = ""
	return bad


# (e) 每一行 ≤ 寬度上限（★用 production 那支算，不在床裡手抄全形表）＋ 無空區塊
static func _bad_width(screen: String) -> Array:
	var bad: Array = []
	for row in TextUiView.overwide_lines(screen):
		var r: Dictionary = row as Dictionary
		bad.append("第 %d 行寬 %d（上限 %d）：%s" % [int(r.get("line", 0)),
			int(r.get("width", 0)), TextUiLayout.COLS, String(r.get("text", ""))])
	return bad

# ★★★★★★【「空區塊」只對【擁有後續行】的區塊有意義】（實測訂正兩次，2026-10-01）
#   ·第一版：對**每一個**錨問「下一個非空行有沒有內容」
#     ⇒ 誤報 `A_FOOT`（`" 鍵："`）與 `A_TOP`（`"｜ 待執行 "`）—— ★它們是**行內錨**，
#       內容**就在那一行上**，後面本來就沒有行。
#   ·★第二版我「放寬」成「標題行自己帶字就算有內容」⇒ **把真發現也消音了**
#     （動作區標題帶著「0／0 可做」⇒ 它永遠不空）⇒ ★那是「刪子句 ⇒ 反方向的空真」。
#   ·⇒ 第三版**窄化**：母體 ＝ **只有 `A_ACTION` 與 `A_FEED`**（這兩個是「標題一行、
#     內容在後面幾行」的清單式區塊）；`A_MAP`／`A_PAGES` 是**框**（內容在框線之間）、
#     `A_TOP`／`A_FOOT` 是**行內錨** ⇒ 三者各自不適用，而**理由逐個寫在這裡**。
#   ★★而母體寫死成兩個是刻意的：它要在有人新增一個清單式區塊時**被迫回來看**，
#     而那比一個「自動涵蓋全部」卻會誤報的判準有用（誤報會讓人把判準關掉）。
static func _bad_empty_regions(screen: String) -> Array:
	var bad: Array = []
	var list_anchors: Array = [TextUiView.A_ACTION, TextUiView.A_FEED]
	var lines: Array = screen.split("\n")
	for i in range(lines.size()):
		var l: String = String(lines[i])
		var is_title: bool = false
		for a in list_anchors:
			if l.begins_with(String(a)):
				is_title = true
				break
		if not is_title:
			continue
		var j: int = i + 1
		var content: int = 0
		while j < lines.size():
			var nx: String = String(lines[j])
			var nx_is_any_title: bool = false
			for a2 in TextUiView.REGION_ANCHORS:
				if nx.begins_with(String(a2)):
					nx_is_any_title = true
					break
			if nx_is_any_title:
				break
			var t: String = nx.strip_edges()
			# ★純分隔線（整行都是 `─`）不算內容
			if t != "" and t != "─".repeat(t.length()):
				content += 1
			j += 1
		if content == 0:
			bad.append("第 %d 行的清單式區塊【沒有內容】：%s" % [i + 1, l.substr(0, 40)])
	return bad


# (b2) ★區塊標題的文字不得在該區塊的內容裡**再出現一次**
# ★★為什麼要這一條（而 (b) 蓋不到）：(b) 數的是 `[n]標籤`（**選項**標籤）；
#   而實測看到的那個重複是**框標題與內容第一行逐字相同**
#   （`┬─ [── 生存 (1/5) ──` 的分頁抬頭，與 `_build_state_str()` 的第一行）
#   ⇒ ★兩者是不同的重複：一個是「同一個選項列兩次」，一個是「同一句話印兩次」
#   ⇒ **(b) 綠而畫面上有重複** —— 那正是「檢查管道與失效管道不同軸」。
# 把兩端的框線／填充線／空白剝掉，留下人讀的那一段
static func _strip_frame(t: String) -> String:
	var out: String = t
	var junk: String = "─│┌┐└┘┬┴├┤ 	"
	while out.length() > 0 and junk.contains(out[0]):
		out = out.substr(1)
	while out.length() > 0 and junk.contains(out[out.length() - 1]):
		out = out.substr(0, out.length() - 1)
	return out


static func _bad_title_echo(screen: String) -> Array:
	var bad: Array = []
	var lines: Array = screen.split("\n")
	for i in range(lines.size()):
		var l: String = String(lines[i])
		# ★★★★★`A_PAGES`（`"┬─ ["`）是**行內錨** —— 那一行的行首是 `A_MAP`（`"┌─ 地圖（"`）
		#   ⇒ 第一版用 `begins_with()` ⇒ **0 命中**，而畫面上那個重複是真的
		#   ⇒ ★這是今天同一族的第三次：**錨在行內 vs 行首**（前兩次是 `A_FOOT`／`A_TOP`）
		#   ⇒ 判準改成**找它在哪個位置**，不是問它是否開頭。
		var at_pages: int = l.find(TextUiView.A_PAGES)
		if at_pages < 0:
			continue
		var head: String = l.substr(at_pages + String(TextUiView.A_PAGES).length())
		head = head.split("│")[0]
		# ★★★★★【抬頭文字與填充線不可分】：抬頭自己就以 `──` 結尾，後面接的也是 `─`
		#   ⇒ 「剝掉尾端一個 `─`」剝不乾淨（第二版實測 0 命中而畫面上重複是真的）
		#   ⇒ 改比**核心標籤**：兩端的 `─`／框線／空白**全剝**，剩下的那一段才是人讀的字。
		var core: String = _strip_frame(head)
		if core.length() < 4:
			continue
		for j in range(i + 1, lines.size()):
			var nx: String = String(lines[j])
			if _strip_frame(nx.split("│")[-1] if nx.contains("│") else nx).contains(core) 					or nx.contains(core):
				bad.append("第 %d 行的抬頭「%s」在第 %d 行又出現一次" % [i + 1, core, j + 1])
				break
	return bad



# ══ 格 ═══════════════════════════════════════════════════════════════════════

# 負對照（擾動輸入，不動事實）：把一個區塊錨刪掉 ⇒ 本格的判準必須報它
func _test_a_regions_present_and_ordered() -> void:
	print("\n── (a) 區塊齊全且順序固定 ──")
	var screens: Array = await _all_screens()
	_check("★母體地板：走法數 ＝ spec 的 %d（%d）" % [SPEC_WALKS_MIN, screens.size()],
		screens.size() == SPEC_WALKS_MIN)
	var all_bad: Array = []
	for s in screens:
		var d: Dictionary = s as Dictionary
		var bad: Array = _bad_regions(String(d.get("screen", "")))
		print("   %-22s 違規 %d 條%s" % [String(d.get("name", "")), bad.size(),
			("：" + str(bad)) if not bad.is_empty() else ""])
		for b in bad:
			all_bad.append("%s｜%s" % [String(d.get("name", "")), String(b)])
	_check("★★★★★(a) 每一支走法的區塊都齊全且順序固定（違規：%s）" % str(all_bad),
		all_bad.is_empty())
	# ★反向對照：同一個抽取器在**刻意拿掉一個錨**的輸入上必須 > 0
	var probe: String = String((screens[0] as Dictionary).get("screen", "")).replace(
		TextUiView.A_FEED, "─ 不是錨（")
	_check("★★【反向對照】把一個區塊錨改掉 ⇒ 同一個抽取器必須報出來（報了 %d 條）"
		% _bad_regions(probe).size(), _bad_regions(probe).size() > 0)
	_cell("_test_a_regions_present_and_ordered")


func _test_b_no_duplicate_labels() -> void:
	print("\n── (b) 無重複選項標籤（整列相等）──")
	var screens: Array = await _all_screens()
	var all_dup: Array = []
	for s in screens:
		var d: Dictionary = s as Dictionary
		var dup: Array = _bad_duplicate_labels(String(d.get("screen", "")))
		print("   %-22s 重複 %d 個%s" % [String(d.get("name", "")), dup.size(),
			("：" + str(dup)) if not dup.is_empty() else ""])
		for x in dup:
			all_dup.append("%s｜%s" % [String(d.get("name", "")), String(x)])
	_check("★★★★★(b-1) 沒有任何一屏有重複【選項標籤】（%s）" % str(all_dup), all_dup.is_empty())
	# ★★(b-2) 另一種重複：**框抬頭與內容逐字相同** —— (b-1) 蓋不到它（它數的是 `[n]標籤`）
	var all_echo: Array = []
	for s2 in screens:
		var d2: Dictionary = s2 as Dictionary
		var echo: Array = _bad_title_echo(String(d2.get("screen", "")))
		print("   %-22s 抬頭回音 %d 條%s" % [String(d2.get("name", "")), echo.size(),
			("：" + str(echo)) if not echo.is_empty() else ""])
		for e2 in echo:
			all_echo.append("%s｜%s" % [String(d2.get("name", "")), String(e2)])
	_check("★★★★★(b-2) 框抬頭沒有在內容裡再出現一次（%s）" % str(all_echo), all_echo.is_empty())
	# ★反向對照（(b-2)）：用一個**合成的乾淨字串**（不是已經脏的那一屏）⇒ 0 → 1
	#   ★★理由與 (g) 同：在脏的 base 上塞東西，「必須 > 0」不用鑑別力就會過。
	var clean_t: String = "┌─ 地圖（x）──┬─ [── 測試抬頭 ────┐
│  │內容與抬頭無關        │"
	var dirty_t: String = clean_t + "
│  │測試抬頭               │"
	print("   ★反向對照：乾淨合成 %d 條 → 造一個回音之後 %d 條" % [
		_bad_title_echo(clean_t).size(), _bad_title_echo(dirty_t).size()])
	_check("★★【反向對照】乾淨合成字串 0 條（%d）" % _bad_title_echo(clean_t).size(),
		_bad_title_echo(clean_t).size() == 0)
	_check("★★★【反向對照】造一個抬頭回音之後必須報出來（%d）"
		% _bad_title_echo(dirty_t).size(), _bad_title_echo(dirty_t).size() > 0)
	# ★反向對照：刻意造一個重複
	var probe: String = String((screens[0] as Dictionary).get("screen", "")) \
		+ "\n [1] 測試重複\n [2] 測試重複"
	_check("★★【反向對照】刻意造一個重複 ⇒ 同一個抽取器必須報出來（報了 %d 個）"
		% _bad_duplicate_labels(probe).size(), _bad_duplicate_labels(probe).size() > 0)
	_cell("_test_b_no_duplicate_labels")


func _test_d_no_english_identifiers() -> void:
	print("\n── (d) 無英文識別字（白名單逐一指名）──")
	print("   白名單 ＝ %s" % str(EN_WHITELIST))
	var screens: Array = await _all_screens()
	var all_en: Array = []
	for s in screens:
		var d: Dictionary = s as Dictionary
		var en: Array = _bad_english(String(d.get("screen", "")))
		print("   %-22s 英文識別字 %d 個%s" % [String(d.get("name", "")), en.size(),
			("：" + str(en)) if not en.is_empty() else ""])
		for x in en:
			all_en.append("%s｜%s" % [String(d.get("name", "")), String(x)])
	_check("★★★★★(d) 玩家畫面沒有英文識別字（%s）" % str(all_en), all_en.is_empty())
	# ★反向對照：刻意塞一個
	# ★★★★★【反向對照要比 delta，不是比「> 0」】—— 第一版在**已經脏的 base** 上塞一個
	#   ⇒ 它不用鑑別力就會過（base 本來就 11 個）。★那是「對照組自己也沒有鑑別力」那一族。
	#   ⇒ 改成：**同一個抽取器在「base ＋ 一個刻意塞的」上必須比 base 多抓到那一個**。
	var base_d: String = String((screens[0] as Dictionary).get("screen", ""))
	var n_before: int = _bad_english(base_d).size()
	var probe_d: String = base_d + "\n zzqqx=0.5"
	var n_after: int = _bad_english(probe_d).size()
	print("   ★反向對照：base %d 個 → 塞一個之後 %d 個" % [n_before, n_after])
	_check("★★【反向對照】刻意塞一個英文識別字 ⇒ 同一個抽取器必須**多抓到一個**（%d → %d）"
		% [n_before, n_after], n_after == n_before + 1)
	_cell("_test_d_no_english_identifiers")


func _test_e_width_and_no_empty_region() -> void:
	print("\n── (e) 每行 ≤ 寬度上限、無空區塊 ──")
	print("   ★寬度用 production 那支算（`TextUiView.overwide_lines()` → `TextUiLayout.display_width()`）"
		+ "—— 不在床裡手抄全形表")
	var screens: Array = await _all_screens()
	var all_w: Array = []
	var all_e: Array = []
	for s in screens:
		var d: Dictionary = s as Dictionary
		var sc: String = String(d.get("screen", ""))
		var w: Array = _bad_width(sc)
		var e: Array = _bad_empty_regions(sc)
		print("   %-22s 超寬 %d 行｜空區塊 %d 個" % [String(d.get("name", "")), w.size(), e.size()])
		for x in w:
			all_w.append("%s｜%s" % [String(d.get("name", "")), String(x)])
		for y in e:
			all_e.append("%s｜%s" % [String(d.get("name", "")), String(y)])
	_check("★★★★★(e-1) 沒有超寬的行（%s）" % str(all_w), all_w.is_empty())
	_check("★★★★★(e-2) 沒有空區塊（%s）" % str(all_e), all_e.is_empty())
	# ★反向對照各一
	# ★★★★★反向對照【比 delta】（理由同 (d)：base 本來就脏，比「> 0」沒有鑑別力）
	var base: String = String((screens[0] as Dictionary).get("screen", ""))
	var w0: int = _bad_width(base).size()
	var w1: int = _bad_width(base + "\n" + "超".repeat(TextUiLayout.COLS)).size()
	print("   ★反向對照（超寬）：base %d 行 → 造一行之後 %d 行" % [w0, w1])
	_check("★★【反向對照】刻意造一行超寬 ⇒ 必須**多報一行**（%d → %d）" % [w0, w1],
		w1 == w0 + 1)
	var e0: int = _bad_empty_regions(base).size()
	# ★反向對照要造一個**真的**空的清單式區塊：標題一行、後面什麼都沒有
	#   （第二版造的 `─ 事件（空）` 被我自己那條「標題帶字就算有內容」吃掉了 ⇒ 0 → 0）
	var e1: int = _bad_empty_regions(base + "\n" + TextUiView.A_FEED + "反向對照）").size()
	print("   ★反向對照（空區塊）：base %d 個 → 造一個之後 %d 個" % [e0, e1])
	_check("★★【反向對照】刻意造一個空區塊 ⇒ 必須**多報一個**（%d → %d）" % [e0, e1],
		e1 == e0 + 1)
	_cell("_test_e_width_and_no_empty_region")


func _test_f_same_state_renders_identically() -> void:
	print("\n── (f) 同一狀態重印兩次逐字相同 ──")
	var a: String = await _screen_for(WALKS[0] as Dictionary)
	var b: String = await _screen_for(WALKS[0] as Dictionary)
	_check("★母體地板：那一屏不是空的（%d 字）" % a.length(), a.length() > 0)
	_check("★★★★★(f) 兩次重印逐字相同（不同 ⇒ 畫面不可 diff，而那讓所有逐字斷言失去意義）",
		a == b)
	_check("★★【反向對照】改一個字元 ⇒ 比較必須說不同", a != (a + "x"))
	_cell("_test_f_same_state_renders_identically")


func _test_g_player_walk_has_no_debug_tokens() -> void:
	print("\n── (g) 玩家走法不印 debug（spec §15③）──")
	print("   debug 識別字（逐一指名）＝ %s" % str(DEBUG_TOKENS))
	var screens: Array = await _all_screens()
	var hits: Array = []
	for s in screens:
		var d: Dictionary = s as Dictionary
		var sc: String = String(d.get("screen", ""))
		# ★逐個指名（不只回一個數）；而「有幾個」那一半用 `_debug_hits()`
		#   ⇒ ★正向與反向對照**用同一個判準**，否則反向綠了也不代表正向有鑑別力
		for t in DEBUG_TOKENS:
			if sc.contains(String(t)):
				hits.append("%s｜%s" % [String(d.get("name", "")), String(t)])
	print("   命中 %d 處%s" % [hits.size(), ("：" + str(hits)) if not hits.is_empty() else ""])
	_check("★★★★★★(g) 玩家走法的輸出裡 debug 識別字 ＝ 0（命中：%s）" % str(hits),
		hits.is_empty())
	# ★★★反向對照：**同一個判準**在刻意塞進那些字的輸入上必須 > 0
	#   ⇒ 沒有這一半，一個永遠為 0 的計數跟「那個功能被刪掉了」在卷面上一模一樣。
	# ★★★★★反向對照：這一條的正確形狀是**在一個乾淨的輸入上**（而不是在已經脏的那一屏上）
	#   —— ★它問的是「這個判準**量得出東西**嗎」，而那只有在「0 → 1」上才看得出來。
	#   ⇒ 所以用一個**合成的乾淨字串**當 base（不是真的那一屏）。
	var clean: String = "第 1 天 00:00｜一個乾淨的合成畫面（床自己造的）"
	var c0: int = _debug_hits(clean)
	var c1: int = _debug_hits(clean + "\n" + String(DEBUG_TOKENS[0]))
	print("   ★反向對照：乾淨字串 %d 命中 → 塞一個之後 %d 命中" % [c0, c1])
	_check("★★【反向對照】乾淨輸入命中 0（%d）" % c0, c0 == 0)
	_check("★★★【反向對照】塞一個 debug 識別字之後必須命中（%d）" % c1, c1 > 0)
	print("   ★★而**沒有這一半**，一個永遠為 0 的計數跟「那個功能被刪掉了」在卷面上一模一樣。")
	_cell("_test_g_player_walk_has_no_debug_tokens")


# 一段畫面裡命中幾個 debug 識別字（★抽成函式，正向與反向對照**用同一個**）
static func _debug_hits(screen: String) -> int:
	var n: int = 0
	for t in DEBUG_TOKENS:
		if screen.contains(String(t)):
			n += 1
	return n


# (c) 印出的鍵 ＝ 打得出來的鍵（★終端引入的新缺陷類別）
# ★★`MODE_KEYMAP` 印出的每一個 `[X]` 都要能被 `PlayerRepl.keycode_for()` 打出來 ——
#   打不出來 ＝ 玩家在終端裡**按不到那個鍵**，而那在 GUI 版不會發生（那裡的鍵盤直接進 `_input`）
#   ⇒ **它不在 R² 列的那六條裡，是這張票自己長出來的第七條。**
func _test_c_printed_keys_are_typeable() -> void:
	print("\n── (c) 印出的鍵都要打得出來（終端引入的新缺陷類別）──")
	var printed: Array = []
	for mode in TextUiMain.MODE_KEYMAP.keys():
		var line: String = String(TextUiMain.MODE_KEYMAP[mode])
		for part in line.split("["):
			var ps: String = String(part)
			var at: int = ps.find("]")
			if at <= 0:
				continue
			var tok: String = ps.substr(0, at)
			if not printed.has(tok):
				printed.append(tok)
	print("   `MODE_KEYMAP` 共印出 %d 個鍵 token" % printed.size())
	_check("★母體地板：真的抓到鍵 token（0 ⇒ 下面那條恆綠）", printed.size() > 0)
	var untypeable: Array = []
	for tok in printed:
		var t: String = String(tok)
		# ★一個 token 可能是一組（`1-9`／`WASD`／`W/S`／`A-`）⇒ 逐字元問，而**整組記錄**
		var any_ok: bool = false
		for i in range(t.length()):
			if PlayerRepl.keycode_for(t[i]) != -1:
				any_ok = true
				break
		var named: bool = PlayerRepl.keycode_for(t) != -1
		if not any_ok and not named:
			untypeable.append(t)
	print("   打不出來的 ＝ %s" % str(untypeable))
	_check("★★★★★(c) `MODE_KEYMAP` 印出的每一個鍵都打得出來（打不出來的：%s）"
		% str(untypeable), untypeable.is_empty())
	# ★反向對照：一個不存在的鍵名必須被判成打不出來
	_check("★★【反向對照】一個假鍵名（`幽靈`）必須被判成打不出來",
		PlayerRepl.keycode_for("幽靈") == -1)
	_cell("_test_c_printed_keys_are_typeable")
