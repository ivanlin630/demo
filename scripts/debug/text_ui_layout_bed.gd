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


func _initialize() -> void:
	print("=== text_ui_layout bed ===")
	_test_p3a_cols_has_one_source()
	_test_p3b_width_algorithm_staked()
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
