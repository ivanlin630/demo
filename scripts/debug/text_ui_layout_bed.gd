extends SceneTree
# @bed-kind: invariant
# slice: 文字介面版面 v2（spec 2026-09-30；權威＝§1／§2／§3 ＋ §6 R² 加固 ＋ §5 誠實限）
#
# ★★★本床目前只有 P3a／P3b（寬度地基）—— systems 排的順序：
#   「P3b 第一個做 —— 全庫零 CJK 顯示寬度函式，它是地基」。
#   其餘格（P1 六區各一次／P2 頂列六欄／P4 逐列有原因／P5 原因來自引擎／
#   P6 事件流逐條／P7 Esc 只回一層／P8 未綁定鍵）隨版面 code 逐步進來。
#
# ★★而 §6② 換掉 P3 的理由要記在這裡（它是本床存在的原因）：
#   P3 原本那兩道（`120` 只出現一次 ＋ 把 COLS 改成 40 必紅）只證明
#   **「比較」那一步讀了那個常數** ——★一個永遠回 `text.length()`、不分全半形的函式
#   **一樣會通過 COLS 擾動測試** ⇒ 所以 P3b 用【2N+M 定樁】直接驗算法本身。

var _errors: int = 0
var _cells_ran: Array = []

# ★版面這條路上的檔（`120` 只准在其中一處出現）
const LAYOUT_PATH_FILES: Array = [
	"res://scripts/ui/text_ui_layout.gd",
	"res://scripts/ui/text_ui_main.gd",
]
const SPEC_COLS_LITERAL: String = "120"

const EXPECTED_CELLS: Array = [
	"_test_p3a_cols_has_one_source",
	"_test_p3b_width_algorithm_staked",
	"_test_p1_six_regions_each_exactly_once",
	"_test_p2_top_row_six_named_columns",
	"_test_p3c_every_line_within_cols",
	"_test_p4_every_false_row_has_a_reason",
	"_test_p5_reason_comes_from_the_engine",
	"_test_p6_feed_rows_each_carry_time",
]


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out


# 負對照：在別處再寫一次 120 ⇒ 本格紅（實測 2） ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# ══ P3a：★`120` 在版面這條路上只有一份（spec §3 P3／§6② 保留的那一半）════════
# ★母體地板：每一個檔都要真的讀到（讀不到 ⇒ 計數少算 ⇒ 這一格會假綠）。
func _test_p3a_cols_has_one_source() -> void:
	print("\n── P3a `120` 只有一份 ──")
	var total: int = 0
	var missing: Array = []
	for f in LAYOUT_PATH_FILES:
		var raw: String = FileAccess.get_file_as_string(String(f))
		if raw == "":
			missing.append(String(f))
			continue
		var n: int = _code_only(raw).count(SPEC_COLS_LITERAL)
		total += n
		print("   %-44s `%s` 出現 %d 次" % [String(f), SPEC_COLS_LITERAL, n])
	print("   ★母體：%d 個檔，讀不到的 %d 個 ⇒ %s" % [
		LAYOUT_PATH_FILES.size(), missing.size(), str(missing)])
	_check("★母體地板：版面這條路上的每一個檔都讀到了（讀不到 ⇒ 計數少算 ⇒ 假綠）",
		missing.is_empty())
	_check("★★★`%s` 在這條路上恰好 1 次（在 `TextUiLayout.COLS` 宣告處，實測 %d）" % [
		SPEC_COLS_LITERAL, total], total == 1)
	# ★另一半：那一次真的在常數宣告那一行（不是某個座標或迴圈上限）
	var decl: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/ui/text_ui_layout.gd"))
	_check("★★那一次出現在 `const COLS: int = 120` 那一行",
		decl.contains("const COLS: int = 120"))
	_cell("_test_p3a_cols_has_one_source")


# 負對照：把 `display_width` 換成 `return s.length()` ⇒ 本格紅（純全形 期望 10 實得 5） ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# ══ P3b：★★★寬度算法【定樁】—— 餵 N 全形 ＋ M 半形 ⇒ 精確等於 2N+M（§6②）════
# ★★期望值來自【算術】不是來自任何 code ⇒ 它與被測物**不同源**
#   （「比較的兩邊同源 ⇒ 恆真」那一族的正面版本）。
# ★★★而 N 與 M 是【建構出來的】：字串由 `"國".repeat(N) + "a".repeat(M)` 組出來
#   ⇒ 我不是去數一個字串裡有幾個全形（那會又用到被測的那套判斷），我是**先決定 N、M**。
func _test_p3b_width_algorithm_staked() -> void:
	print("\n── P3b 寬度算法定樁（2N+M）──")
	# ★★★[名稱, N（全形個數）, M（半形個數）, 排法, 用哪個全形字]
	#   ★字串是【建構】出來的（`repeat`／交錯迴圈）—— **我不手數**。
	#   ★★第一版我手寫了字面字串並手數 N／M，而 `"ab12"` 是 4 個半形不是 3
	#     ⇒ 本格報「期望 11 實得 12」⇒ **不符的是我的表，不是那支函式**。
	#     ⇒ 那正是我自己那條「常數的來源：寫常數的人要說出它怎麼數的」——
	#       而最好的「怎麼數」是【不要數，去建構】。
	var cases: Array = [
		["純半形",              0, 5, "wide_first",   "國"],
		["純全形",              5, 0, "wide_first",   "國"],
		["全形在前",            3, 4, "wide_first",   "國"],
		["半形在前",            4, 3, "narrow_first", "國"],
		["交錯",                3, 3, "interleave",   "國"],
		["全形數字（U+FF10 段）", 3, 2, "wide_first",  "１"],
		["諺文音節（U+AC00 段）", 2, 2, "wide_first",  "가"],
		["空字串",              0, 0, "wide_first",   "國"],
	]
	var wrong: Array = []
	for c in cases:
		var nm: String = String(c[0])
		var n: int = int(c[1])
		var m: int = int(c[2])
		var order: String = String(c[3])
		var wc: String = String(c[4])
		var s: String = ""
		match order:
			"wide_first":
				s = wc.repeat(n) + "a".repeat(m)
			"narrow_first":
				s = "a".repeat(m) + wc.repeat(n)
			"interleave":
				for i in range(maxi(n, m)):
					if i < n:
						s += wc
					if i < m:
						s += "a"
		var expect: int = 2 * n + m
		var got: int = TextUiLayout.display_width(s)
		print("   %-22s N=%d M=%d ⇒ 期望 2N+M=%-3d 實得 %-3d %s" % [
			nm, n, m, expect, got, "" if got == expect else "★不符"])
		if got != expect:
			wrong.append("%s（期望 %d 實得 %d）" % [nm, expect, got])
	_check("★母體地板：真的有案例（0 個 ⇒ 本格恆綠）", cases.size() > 0)
	_check("★★★每一個案例都精確等於 2N+M（不符的：%s）" % str(wrong), wrong.is_empty())
	# ★★一個【必須分辨得出來】的對照：純全形那一組的字元數是 5 而寬度是 10
	#   ⇒ 若算法回的是 `length()`，這一條會紅。★這一條就是 `length()` 與寬度的分水嶺。
	var wide5: String = "國隊人口糧"
	print("   ★分水嶺：`%s` 字元數 %d／顯示寬度 %d（回 length() 的實作會讓兩者相等）" % [
		wide5, wide5.length(), TextUiLayout.display_width(wide5)])
	_check("★★★顯示寬度 ≠ 字元數（10 vs 5；相等 ⇒ 它回的是 `length()`）",
		TextUiLayout.display_width(wide5) != wide5.length())
	# ★clip_to／pad_to 也要吃同一把尺（否則版面會在補齊那一步歪掉）
	print("   clip_to(\"%s\", 5) ⇒ \"%s\"（寬度 %d）" % [
		wide5, TextUiLayout.clip_to(wide5, 5), TextUiLayout.display_width(
			TextUiLayout.clip_to(wide5, 5))])
	_check("★`clip_to` 依【寬度】截（5 格只放得下 2 個全形 ⇒ 寬度 4，不是 5）",
		TextUiLayout.display_width(TextUiLayout.clip_to(wide5, 5)) <= 5)
	_check("★`pad_to` 依【寬度】補（全形 5 個補到 20 格 ⇒ 寬度剛好 20）",
		TextUiLayout.display_width(TextUiLayout.pad_to(wide5, 20)) == 20)
	_cell("_test_p3b_width_algorithm_staked")



# ── 一份【假資料】的畫面（純排版層 ⇒ 不需要場景樹）────────────────────────────
#   ★★★母體地板的形狀：這份 fixture 自己要說出它佈置了什麼（幾列可做／幾列不可做／
#     幾條事件），否則下面幾格會在一個「什麼都沒有」的畫面上恆綠。
func _fixture_rows() -> Array:
	return [
		{"action_id": "ignore",  "label": "忽略",   "enabled": true,  "disabled_reason": "",
		 "opens_submenu": false},
		{"action_id": "attack",  "label": "攻擊",   "enabled": true,  "disabled_reason": "",
		 "opens_submenu": false},
		{"action_id": "recruit", "label": "招募",   "enabled": true,  "disabled_reason": "",
		 "opens_submenu": true},
		{"action_id": "extort",  "label": "勒索",   "enabled": false,
		 "disabled_reason": "準備值不足（需 ≥ 0.7，現為 0.2）", "opens_submenu": false},
		{"action_id": "demand_tribute", "label": "索貢", "enabled": false,
		 "disabled_reason": "人口不足（需超過對方 1.5 倍；你 8、對方 12）", "opens_submenu": false},
	]

func _fixture_feed() -> Array:
	var out: Array = []
	for i in range(9):   # ★故意給 9 條（> FEED_ROWS 8）⇒ 驗它只取最近 8 條
		out.append({"when": "第%d天 08:%02d" % [3 + i, i * 5], "source": "隊%d" % i,
			"text": "事件內容 %d" % i})
	return out

func _fixture_screen() -> String:
	return TextUiView.compose({
		"top": {"clock": "第3天 08:00", "team": "我隊 8 人", "home": "(0,20)",
			"food": "4.2 天", "threat": "東邊有敵", "pending": "2 道"},
		"map": "  . . . @ . . .\n  . ^ ^ . . . .",
		"pages": "[生存] 糧 33.6｜水 12｜士氣 0.7",
		"action": _fixture_rows(),
		"feed": _fixture_feed(),
		"result": "你選了「收留（叛徒）」，但隊伍已滿，無法收留 ⇒ 沒有生效",
		"keymap": "[1-9]選動作 [Esc]返回 [,][.]切頁",
	})


# 負對照：刪掉一區的錨 ⇒ 本格紅 ⇒ 待實測
# 負對照 b：把一區複製一次 ⇒ 本格紅（★只數總數會讓 a、b 互相補償）⇒ 待實測
# ══ P1：★六區的六個錨【各出現剛好一次】（spec §1）═══════════════════════════════
# ★★★為什麼是「剛好一次」而不是「總數 6」：出現兩次 ＝ 有人複製了一區（版面搬了），
#   出現零次 ＝ 那一區沒畫出來 —— 兩種都要紅，而只數總數會讓它們**互相補償**。
func _test_p1_six_regions_each_exactly_once() -> void:
	print("\n── P1 六區各剛好一次 ──")
	var screen: String = _fixture_screen()
	print("   母體 ＝ `TextUiView.REGION_ANCHORS`（%d 個，順序就是畫面上下順序）"
		% TextUiView.REGION_ANCHORS.size())
	_check("★母體地板：錨的清單不是空的（空 ⇒ 下面的迴圈一格都不跑 ⇒ 恆綠）",
		not TextUiView.REGION_ANCHORS.is_empty())
	_check("★★母體 ＝ spec 的六區（實測 %d）" % TextUiView.REGION_ANCHORS.size(),
		TextUiView.REGION_ANCHORS.size() == 6)
	for a in TextUiView.REGION_ANCHORS:
		var n: int = screen.count(String(a))
		print("   %-12s 出現 %d 次" % [String(a), n])
		_check("★★★`%s` 剛好一次（實測 %d；0 ＝ 那一區沒畫，2 ＝ 有人複製了一區）" % [
			String(a), n], n == 1)
	_cell("_test_p1_six_regions_each_exactly_once")


# 負對照：拿掉頂列任一欄 ⇒ 本格紅並指名那一欄 ⇒ 待實測
# ══ P2：★頂列六欄【指名】都在（spec §2②：不是「頂列非空」）═════════════════════
func _test_p2_top_row_six_named_columns() -> void:
	print("\n── P2 頂列六欄（指名）──")
	var screen: String = _fixture_screen()
	var missing: Array = []
	var names: Array = []
	for c in TextUiView.TOP_COLUMNS:
		names.append(String(c[1]))
		if not screen.contains(String(c[1])):
			missing.append(String(c[1]))
	print("   母體（指名）＝ %s" % str(names))
	_check("★母體地板：欄的清單不是空的", not TextUiView.TOP_COLUMNS.is_empty())
	_check("★★六欄都在畫面上（缺的：%s）" % str(missing), missing.is_empty())
	_check("★★★欄數 ＝ spec 點名的 6（實測 %d）" % names.size(), names.size() == 6)
	_cell("_test_p2_top_row_six_named_columns")


# 負對照：把 COLS 改成 40 ⇒ 本格紅（證它真的在讀那個常數）⇒ 待實測
# ══ P3c：★每一行的顯示寬度 ≤ COLS（spec §3 P3 後半）═══════════════════════════
# ★★排版層【刻意不截整行】：截了會讓「這一行太寬」變成一個看不見的錯
#   ⇒ 所以這一格有牙齒（地圖那一區與多行內容可以溢出）。
func _test_p3c_every_line_within_cols() -> void:
	print("\n── P3c 每行不超寬 ──")
	var screen: String = _fixture_screen()
	var lines: int = screen.split("\n").size()
	var bad: Array = TextUiView.overwide_lines(screen)
	print("   畫面 %d 行｜COLS ＝ %d｜超寬的 %d 行" % [lines, TextUiLayout.COLS, bad.size()])
	for b in bad:
		print("     · 第 %d 行 寬度 %d：%s…" % [
			int(b.get("line", -1)), int(b.get("width", -1)), String(b.get("text", ""))])
	_check("★母體地板：畫面真的有行（0 行 ⇒ 本格恆綠）", lines > 1)
	_check("★★★每一行的顯示寬度 ≤ COLS（超寬的 %d 行）" % bad.size(), bad.is_empty())
	_cell("_test_p3c_every_line_within_cols")


# 負對照：把某一列的原因清空 ⇒ 本格紅並指名 ⇒ 待實測
# ══ P4：★動作區逐列有原因 ＋ 母體地板（spec §3 P4）═════════════════════════════
func _test_p4_every_false_row_has_a_reason() -> void:
	print("\n── P4 不可做的每一列都印出原因 ──")
	var rows: Array = _fixture_rows()
	var block: String = TextUiView.action_block(rows)
	var n_false: int = 0
	var no_reason: Array = []
	for r in rows:
		if bool(r.get("enabled", false)):
			continue
		n_false += 1
		var why: String = String(r.get("disabled_reason", ""))
		if why.strip_edges() == "" or not block.contains(why):
			no_reason.append(String(r.get("action_id", "")))
	print("   ★本輪不可做的列 ＝ %d（0 的話本格在「什麼都能做」的世界裡恆綠）" % n_false)
	print(block)
	_check("★母體地板：本輪真的有不可做的列（%d）" % n_false, n_false > 0)
	_check("★★★每一列不可做的都把原因印在畫面上（沒有的：%s）" % str(no_reason),
		no_reason.is_empty())
	_check("★有下一層的那一列前面有 `%s`" % TextUiView.SUBMENU_MARK,
		block.contains(TextUiView.SUBMENU_MARK))
	_cell("_test_p4_every_false_row_has_a_reason")


# 負對照：在排版層寫死一句原因 ⇒ 本格紅 ⇒ 待實測
# ══ P5：★★★原因【來自引擎】—— 改引擎那一條的一個字，畫面那一行跟著變（藍圖驗收句）══
# ★★而靜態那一半（§6③ 兩條缺一不可）：①先剝整行註解再 grep ②★範圍限定在
#   **真正負責 render 動作區的那支函式**，不對整份檔裸搜 —— 否則會命中
#   【描述規則的註解】（今天 `simp-lint` 自己承認的同型病）。
func _test_p5_reason_comes_from_the_engine() -> void:
	print("\n── P5 原因來自引擎 ──")
	var rows_a: Array = _fixture_rows()
	var rows_b: Array = _fixture_rows()
	rows_b[3]["disabled_reason"] = String(rows_a[3]["disabled_reason"]).replace("準備值", "準備度")
	var a: String = TextUiView.action_block(rows_a)
	var b: String = TextUiView.action_block(rows_b)
	print("   改一個字之前：%s" % String(rows_a[3]["disabled_reason"]))
	print("   改一個字之後：%s" % String(rows_b[3]["disabled_reason"]))
	_check("★母體地板：那一個字真的被改掉了（沒改 ⇒ 下面兩條恆真）",
		String(rows_a[3]["disabled_reason"]) != String(rows_b[3]["disabled_reason"]))
	_check("★★★畫面跟著變（排版層沒有自己那一份文案）", a != b)
	_check("★★改後的那句真的出現在畫面上", b.contains(String(rows_b[3]["disabled_reason"])))
	_check("★而改前那句已經不在畫面上（還在 ⇒ 排版層留了一份舊的）",
		not b.contains(String(rows_a[3]["disabled_reason"])))
	var raw: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_view.gd")
	var i: int = raw.find("static func action_block(")
	var j: int = raw.find("\nstatic func ", i + 10)
	var body: String = _code_only(raw.substr(i, (j - i) if j > i else -1))
	_check("★母體地板：真的切到 `action_block` 的函式體（切不到 ⇒ 下面那條恆綠）",
		i >= 0 and body.length() > 0)
	var hardcoded: Array = []
	for line in body.split("\n"):
		var k: int = line.find("（不可：")
		if k < 0:
			continue
		var t: String = line.substr(k + 5).strip_edges()
		if not t.begins_with("%"):
			hardcoded.append(line.strip_edges())
	print("   `action_block` 裡「（不可：」後面不是變數的行 ＝ %d" % hardcoded.size())
	for h in hardcoded:
		print("     · %s" % String(h))
	_check("★★★排版層沒有寫死任何一句原因（「（不可：」後面只接變數；違規 %d 行）"
		% hardcoded.size(), hardcoded.is_empty())
	print("   ★★而這個 grep 的範圍【限定在那支函式】—— 對整份檔裸搜會命中")
	print("     【描述規則的註解】（本檔開頭那段就在講「（不可：」要接變數）⇒ 那是假紅。")
	_cell("_test_p5_reason_comes_from_the_engine")


# 負對照：讓某一條事件少掉時間 ⇒ 本格紅並指名那一條 ⇒ 待實測
# ══ P6：★事件流【逐條】帶時間與來源（spec §3 P6：不是總數）════════════════════
func _test_p6_feed_rows_each_carry_time() -> void:
	print("\n── P6 事件流逐條帶時間 ──")
	var events: Array = _fixture_feed()
	var block: String = TextUiView.feed_block(events)
	var body_lines: Array = []
	for l in block.split("\n"):
		if String(l).begins_with(TextUiView.A_FEED):
			continue
		body_lines.append(String(l))
	print(block)
	print("   佈置 %d 條｜畫面上 %d 條｜FEED_ROWS ＝ %d" % [
		events.size(), body_lines.size(), TextUiView.FEED_ROWS])
	_check("★母體地板：佈置的條數 > FEED_ROWS（%d > %d）⇒ 才驗得到「只取最近 N 條」" % [
		events.size(), TextUiView.FEED_ROWS], events.size() > TextUiView.FEED_ROWS)
	_check("★★畫面上剛好 %d 條" % TextUiView.FEED_ROWS,
		body_lines.size() == TextUiView.FEED_ROWS)
	var bad: Array = []
	var re := RegEx.new()
	re.compile("^第[0-9]+天 [0-9][0-9]:[0-9][0-9]｜[^｜]+｜")
	for bl in body_lines:
		if re.search(String(bl)) == null:
			bad.append(String(bl).substr(0, 30))
	print("   逐條匹配「第N天 HH:MM｜來源｜」失敗的 ＝ %d" % bad.size())
	for bb in bad:
		print("     · %s" % String(bb))
	_check("★★★【逐條】匹配時間格式與非空來源（失敗的 %d 條）" % bad.size(), bad.is_empty())
	print("   ★逐條而不是總數：格式壞掉的那一條會被總數蓋過去。")
	_cell("_test_p6_feed_rows_each_carry_time")


func _initialize() -> void:
	print("=== text_ui_layout bed ===")
	_test_p3a_cols_has_one_source()
	_test_p3b_width_algorithm_staked()
	_test_p1_six_regions_each_exactly_once()
	_test_p2_top_row_six_named_columns()
	_test_p3c_every_line_within_cols()
	_test_p4_every_false_row_has_a_reason()
	_test_p5_reason_comes_from_the_engine()
	_test_p6_feed_rows_each_carry_time()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	# ★★★§5／§6-末【常駐輸出】—— 每一次跑都印，因為「寫在信裡／spec 裡的要求不是執行單位」
	print("\n★★★【本床證得了什麼／證不了什麼】（spec §5 誠實限，硬要求的常駐輸出）")
	print("  ①本床只證**結構**：寬度算法定樁、`120` 只有一份"
		+ "（版面 code 進來之後還會有六區各一次／頂列六欄／原因來自引擎／事件流逐條／Esc 只回一層）。")
	print("  ★用戶的驗收句是「排列合理且資訊豐富」——**機器判不了**"
		+ " ⇒ 全綠**不等於**這一票可以交，可以交的判準是【用戶看過】。")
	print("  ②★P1（六區各一次）**管不到**這一類：六個錨各剛好一次，"
		+ "而區塊【內容】溢出／重複／位置錯位 —— 例如事件流的內容印了 16 行而標題只印一次。")
	print("  ★★那一類落在【用戶看得出而床看不出】的那一邊，而它正是「排列合理」真正在守的東西。")
	print("  ③★而「120 欄是不是對的寬度」也判不了：本床只證「沒有超過那個常數」。")
	print("\n=== text_ui_layout DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
