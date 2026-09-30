# scripts/ui/text_ui_view.gd
# 文字介面版面 v2 的【排版層】（spec 2026-09-30 §1／§2；藍圖排版稿 `996465d21` §一）。
#
# ★★★為什麼它是一支【純】函式的檔：六區的斷言（P1 六個錨各剛好一次／P2 頂列六欄／
#   P3c 每行不超寬／P4 逐列有原因／P5 原因來自引擎／P6 事件流逐條／P8b 字母綁 id）
#   **全部只需要字串** ⇒ 不需要場景樹 ⇒ 床可以直接餵資料進來驗。
#
# ★★★排版層的鐵律（藍圖③，spec §2③）：**這裡不寫文案**。
#   ·動作的中文名 ← 引擎給的 `label`（`PlayerApiMapper.action_label` 是唯一生產者）
#   ·不可做的原因 ← 引擎給的 `disabled_reason`
#   ⇒ ★所以本檔裡「（不可：」後面**只准接變數**。P5 的 grep 咬這一件，
#     而它的範圍**限定在 `action_block` 函式體**（對整份檔裸搜會命中這一段
#     【描述規則的註解】⇒ 那是假紅）。
#
# ★誠實限（逐條，它們決定了「綠」是什麼意思）：
#   1. 欄依寬度 `clip_to`，而**整行不截斷** —— ★★刻意的：整行截斷會讓
#      「這一行太寬」變成一個**看不見**的錯，而 P3 要的是它**紅**。
#      ⇒ 分界線：**有宣告寬度的東西可以截；沒有宣告寬度的東西不可以截。**
#      （欄有它的寬度 ⇒ clip 是履約；行沒有 ⇒ 截行是隱匿。）
#   2. ★頂列的【威脅】那一欄是引擎給的一句話、**長度無界** ⇒ 只 clip 那一欄（把剩餘預算給它）。
#      ★★不這樣做的話它會讓 **P3c 紅，而紅的理由是資料長度不是版面錯** ——
#      而「一個紅在錯的理由上的格子」會被當成「守衛在工作」。
#   3. ★★★六區的**順序與存在**由本檔決定；而**區塊【內容】溢出／重複／位置錯位 P1 抓不到**。
#      血證（2026-10-01，我自己第一版就寫出來的）：分頁的錨自帶 `┬` 而我組框時又加了一個
#      ⇒ 印成 `┬┬─ [1]生存…`，★**而 P1 仍然綠**（`┬─ [` 照樣剛好出現一次）。
#      ⇒ 那一類落在【用戶看得出而床看不出】的那一邊。
class_name TextUiView
extends Node

# ══ 六區的機械錨（spec §1「HOW 定字串」；systems 裁 2026-10-01 取 (甲)：忠於稿子）══
# ★★A_TOP／A_FOOT **不是標題列**：稿子的頂列與底部沒有標題列
#   ⇒ 它們的錨是【那一區裡真的有的欄位前綴】。
#   ★而 (乙)「每一區都加一條統一標題列」被否決，理由是通則：
#     **守衛要適應被守的東西，不是反過來** —— 用戶核可的是那個外觀。
const A_TOP: String    = "｜ 待執行 "     # 頂列最後一欄
const A_MAP: String    = "┌─ 地圖（"     # ★自帶 `┌`
const A_PAGES: String  = "┬─ ["          # ★自帶 `┬` ⇒ 組框時**不要**再加一個
const A_ACTION: String = "─ 動作（"
const A_FEED: String   = "─ 事件（"
const A_FOOT: String   = " 鍵："          # 底部鍵位那一行
const REGION_ANCHORS: Array = [A_TOP, A_MAP, A_PAGES, A_ACTION, A_FEED, A_FOOT]

# ══ 頂列六欄（spec §2②：★指名六欄，不是「頂列非空」）═══════════════════════════
# ★★稿子逐字：`第 12 天 09:07 ｜ 灰狼隊（人口 14）｜ 家：(3,5) ｜ 糧撐 6 天 ｜ 威脅：… ｜ 待執行 0 道`
#   ⇒ **前兩欄沒有欄標** ⇒ 錨是「稿子裡真的有的字面」，而第一欄用【日期的形狀】。
#   ★★★為什麼第一欄不能用「第」這一個字：事件流每一條都是 `第12天 …`
#     ⇒ 那個錨會在別區命中 ⇒ **恆真**。判準：**錨太短 ⇒ 它在別處命中，而命中的長相是綠。**
# [key, kind("regex"|"literal"), 錨, 說明]
const TOP_FIELDS: Array = [
	["clock",   "regex",   "^第 [0-9]+ 天 [0-9][0-9]:[0-9][0-9]", "日期時刻"],
	["team",    "literal", "（人口 ",   "隊名人口"],
	["home",    "literal", "家：",      "家"],
	["food",    "literal", "糧撐 ",     "糧撐幾天"],
	["threat",  "literal", "威脅：",    "威脅一句（★唯一長度無界的欄）"],
	["pending", "literal", "待執行 ",   "待執行幾道"],
]

# ══ ★★★字母鍵 → action_id 的【靜態】映射（systems 裁 2026-10-01 的條件）══════════
#   ·不變量 #10 禁的**不是字母**，是「意義由**位置／計數**決定」
#     （血證：索引式選單 `num < fe_count` 後接 self-actions）
#   ·⇒ 條件：**字母綁 `action_id`，不綁清單位置**
#   ★★而「動作全列」那張票剛好把前提補上了：**不可做的也在列上**
#     ⇒ 清單長度不再隨世界變動 ⇒ 靜態映射才**可能**。
#     （兩張票各自的理由完全不同，而後一張把前一張的前提補上了。）
#   ★★★沒有字母的列印「（未綁鍵）」並**由床數出來** —— **不用位置補一個字母**：
#     那會把這一格變回不變量 #10 那個病，**而且是靜默的**。
#     判準：**寧可印一個「沒有」並把它數出來，不要補一個看起來合理的值。**
const ACTION_LETTERS: Dictionary = {
	"trade": "A", "propose_alliance": "B", "demand_tribute": "C",
	"recruit": "D", "gather_intel": "E", "attack": "F",
	"extort": "G", "recruit_anon": "H", "invite_settle": "I",
	"beg": "J", "ignore": "K",
}

const FEED_ROWS: int = 8          # 事件流固定筆數（spec §2④）
const SUBMENU_MARK: String = "▸"  # 有下一層（spec §2③）
const UNBOUND_MARK: String = "（未綁鍵）"


# ── 補到某個顯示寬度：★用【補】不要用【換】 ─────────────────────────────────
# ★★`pad(...).replace(" ", "─")` 會吃掉標題【內部】的空白
#   （稿子的地圖標題逐字有空白：`大寫=看得到 小寫=記得 ?=沒去過`）
#   ⇒ 判準：**只動一端就用長度算，不要用內容比對**。
static func _fill_to(s: String, width: int, ch: String) -> String:
	var need: int = width - TextUiLayout.display_width(s)
	return s + ch.repeat(need) if need > 0 else s

static func region_title(anchor: String, note: String) -> String:
	return _fill_to(anchor + note + "）", TextUiLayout.COLS, "─")

# 左右各半：`COLS` 扣掉三根框線字元之後平分（lw ＋ rw ＋ 3 ＝ COLS）
static func box_widths() -> Array:
	var inner: int = TextUiLayout.COLS - 3
	var left: int = int(float(inner) / 2.0)
	return [left, inner - left]


# ══ ②左地圖 ＋ ③右分頁：★**一個框、兩欄**（稿子 §一）═════════════════════════
# ★★兩個錨在【同一行】（上框），而 `┬` 由 `A_PAGES` 自己帶 ⇒ 這裡**不要**再加。
static func map_pages_box(map_body: String, pages_body: String,
		map_note: String, tabs: String) -> String:
	var w: Array = box_widths()
	var lw: int = int(w[0])
	var rw: int = int(w[1])
	var lines: Array = []
	# 上框：`┌─ 地圖（…）───…` ＋ `┬─ [1]生存 …───…` ＋ `┐`
	lines.append(
		_fill_to(A_MAP + map_note + "）", lw + 1, "─")
		+ _fill_to(A_PAGES + tabs, rw + 1, "─") + "┐")
	# 中身：逐列並排，短的那一側補空白
	var ml: Array = map_body.split("\n")
	var pl: Array = pages_body.split("\n")
	for i in range(maxi(ml.size(), pl.size())):
		var l: String = String(ml[i]) if i < ml.size() else ""
		var r: String = String(pl[i]) if i < pl.size() else ""
		lines.append("│" + _fill_to(TextUiLayout.clip_to(l, lw), lw, " ")
			+ "│" + _fill_to(TextUiLayout.clip_to(r, rw), rw, " ") + "│")
	lines.append("└" + "─".repeat(lw) + "┴" + "─".repeat(rw) + "┘")
	return "\n".join(lines)


# ══ ①頂列：忠於稿子（前兩欄無欄標、欄間 ` ｜ `）═══════════════════════════════
# ★只有【威脅】那一欄會被 clip（見誠實限 2）。
static func top_row(v: Dictionary) -> String:
	var head: Array = [
		"第 %s" % String(v.get("clock", "—")),
		"%s（人口 %s）" % [String(v.get("team_name", "—")), String(v.get("pop", "—"))],
		"家：%s" % String(v.get("home", "—")),
		"糧撐 %s" % String(v.get("food", "—")),
	]
	var tail: String = "待執行 %s" % String(v.get("pending", "—"))
	var sep: String = " ｜ "
	var used: int = TextUiLayout.display_width(sep.join(PackedStringArray(head)))
	used += TextUiLayout.display_width(sep) * 2
	used += TextUiLayout.display_width("威脅：") + TextUiLayout.display_width(tail)
	var budget: int = TextUiLayout.COLS - used
	var threat: String = "威脅：" + TextUiLayout.clip_to(
		String(v.get("threat", "—")), maxi(budget, 0))
	return sep.join(PackedStringArray(head + [threat, tail]))


# ══ ④動作區：逐列 `[字母] label ▸`＋（不可：`disabled_reason`）（spec §2③）═══════
# ★★★rows 逐字是全列版 API 回的那些（`get_action_availability`）：
#   `{action_id, label, enabled, disabled_reason, opens_submenu}`
#   ⇒ 本函式**不判斷可不可做、不寫任何原因文案** —— 它只排版。
static func action_block(rows: Array) -> String:
	var lines: Array = []
	var n_ok: int = 0
	var n_unbound: int = 0
	for r in rows:
		if bool(r.get("enabled", false)):
			n_ok += 1
		if not ACTION_LETTERS.has(String(r.get("action_id", ""))):
			n_unbound += 1
	lines.append(region_title(A_ACTION, "%d／%d 可做，未綁鍵 %d" % [
		n_ok, rows.size(), n_unbound]))
	for r2 in rows:
		var aid: String = String(r2.get("action_id", ""))
		var key: String = String(ACTION_LETTERS.get(aid, ""))
		var head: String = ("[%s]" % key) if key != "" else UNBOUND_MARK
		var mark: String = SUBMENU_MARK if bool(r2.get("opens_submenu", false)) else ""
		var line: String = " %s %s %s" % [head, String(r2.get("label", "")), mark]
		if not bool(r2.get("enabled", false)):
			line += "（不可：%s）" % String(r2.get("disabled_reason", ""))
		lines.append(TextUiLayout.clip_to(line, TextUiLayout.COLS))
	return "\n".join(lines)

# 某個 action_id 拿到哪個字母（""＝沒綁）★給床做 P8b 的比對用
static func letter_for(action_id: String) -> String:
	return String(ACTION_LETTERS.get(action_id, ""))


# ══ ⑤事件流：最近 FEED_ROWS 條，每條「第N天 HH:MM｜來源｜內容」（spec §2④）═════
# ★★逐條帶時間是 P6 的斷言 ⇒ ★本函式**不補時間**（自己補一個假時間 ＝ 讓 P6 恆綠）。
static func feed_block(events: Array) -> String:
	var lines: Array = []
	lines.append(region_title(A_FEED, "最近 %d 條" % FEED_ROWS))
	var start: int = maxi(0, events.size() - FEED_ROWS)
	for i in range(start, events.size()):
		var e: Dictionary = events[i]
		lines.append(TextUiLayout.clip_to("%s｜%s｜%s" % [
			String(e.get("when", "")), String(e.get("source", "")),
			String(e.get("text", ""))], TextUiLayout.COLS))
	return "\n".join(lines)


# ══ ⑥底部：結果句【一行】＋ 鍵位【永遠印全】（spec §2⑤）═════════════════════════
# ★鍵位那一行**不截**（截掉等於把鍵藏起來）⇒ 它是 P3c 唯一被允許超寬的來源，
#   而若它真的超寬，P3c 會紅 —— ★★那時要改的是【鍵位的內容】不是那個斷言。
static func foot_block(result_line: String, keymap: String) -> String:
	return "\n".join([
		"─".repeat(TextUiLayout.COLS),
		" 結果：" + TextUiLayout.clip_to(result_line, TextUiLayout.COLS - 4),
		A_FOOT + keymap,
	])


# ══ 六區組成整個畫面（★順序固定：任何模式都不搬，模式只改【動作區】的內容）═════
# regions：top(Dictionary)／map(String)／pages(String)／map_note／tabs／
#          action(Array)／feed(Array)／result(String)／keymap(String)
static func compose(regions: Dictionary) -> String:
	return "\n".join([
		top_row(regions.get("top", {}) as Dictionary),
		map_pages_box(String(regions.get("map", "")), String(regions.get("pages", "")),
			String(regions.get("map_note", "")), String(regions.get("tabs", ""))),
		action_block(regions.get("action", []) as Array),
		feed_block(regions.get("feed", []) as Array),
		foot_block(String(regions.get("result", "")), String(regions.get("keymap", ""))),
	])


# 每一行的顯示寬度超過 COLS 的那些（★回【行號與寬度】，不只回一個數：
#   ★★一個「有幾行超寬」的數字說不出是哪一行，而修的人要的是那一行）
static func overwide_lines(screen: String) -> Array:
	var bad: Array = []
	var ln: int = 0
	for l in screen.split("\n"):
		ln += 1
		var w: int = TextUiLayout.display_width(l)
		if w > TextUiLayout.COLS:
			bad.append({"line": ln, "width": w, "text": l.substr(0, 40)})
	return bad
