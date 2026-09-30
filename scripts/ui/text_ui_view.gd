# scripts/ui/text_ui_view.gd
# 文字介面版面 v2 的【排版層】（spec 2026-09-30 §1／§2）。
#
# ★★★為什麼它是一支【純】函式的檔：六區的斷言（P1 六個錨各剛好一次／P2 頂列六欄／
#   P3 每行不超寬／P4 逐列有原因／P5 原因來自引擎／P6 事件流逐條）**全部只需要字串**
#   ⇒ 不需要場景樹、不需要 Godot 的 UI node ⇒ 床可以直接餵資料進來驗。
#   ★★而 `text_ui_main.gd` 那一側只負責【把這裡回的字串塞進 Label】。
#
# ★★★排版層的鐵律（藍圖③，spec §2③）：**這裡不寫文案**。
#   ·動作的中文名 ← 引擎給的 `label`（`PlayerApiMapper.action_label` 是唯一生產者）
#   ·不可做的原因 ← 引擎給的 `disabled_reason`
#   ⇒ ★所以本檔裡「（不可：」後面只准接變數。P5 的 grep 咬這一件。
#
# ★誠實限：
#   1. 本檔把【欄】依 `COLS` 切寬並 `clip_to`，而**整行不截斷** ——
#      ★★這是刻意的：整行截斷會讓「這一行太寬」變成一個**看不見**的錯，
#      而 P3 要的是它**紅**。⇒ 地圖那一區與多行內容可以溢出，而床會抓到。
#   2. 六區的**順序與存在**由本檔決定；★區塊【內容】溢出／重複／位置錯位
#      **P1 抓不到**（spec §5 點名的那一類）⇒ 那一類靠用戶的眼睛。
class_name TextUiView
extends Node

# ══ 六區的機械錨（spec §1：每一區一個機器可讀的標題錨，各出現剛好一次）══════════
const A_TOP: String    = "─ 狀態（"
const A_MAP: String    = "─ 地圖（"
const A_PAGES: String  = "─ 分頁（"
const A_ACTION: String = "─ 動作（"
const A_FEED: String   = "─ 事件（"
const A_FOOT: String   = "─ 鍵位（"

# ★★★六區的【唯一一份】清單（順序 ＝ 畫面上下順序；P1 的母體就是它）
const REGION_ANCHORS: Array = [A_TOP, A_MAP, A_PAGES, A_ACTION, A_FEED, A_FOOT]

# ══ 頂列六欄（spec §2②：★指名六欄，不是「頂列非空」）═══════════════════════════
# [鍵, 欄標]　★鍵是呼叫端要填的欄位名；欄標是畫面上的字
const TOP_COLUMNS: Array = [
	["clock",    "日期時刻"],
	["team",     "隊名人口"],
	["home",     "家"],
	["food",     "糧撐幾天"],
	["threat",   "威脅"],
	["pending",  "待執行"],
]

# 事件流固定筆數（spec §2④）
const FEED_ROWS: int = 8
# 有下一層的那一列前面加這個（spec §2③）
const SUBMENU_MARK: String = "▸"


# ── 一區的標題行：`─ 動作（3／11 可做）────────────` ─────────────────────────
static func region_title(anchor: String, note: String) -> String:
	var head: String = anchor + note + "）"
	var fill: int = TextUiLayout.COLS - TextUiLayout.display_width(head)
	if fill < 0:
		fill = 0
	return head + "─".repeat(fill)


# ══ ①頂列：六欄，各欄 `欄標:值`，依 COLS 平分欄寬 ═══════════════════════════════
# ★母體是 `TOP_COLUMNS` ⇒ 少一欄／多一欄都由它決定，呼叫端漏填只會讓那一欄的值是空的
#   （★而 P2 斷言的是【六個欄標都在】—— 值空不空是 P2 的下一層，不在本票）。
static func top_row(vals: Dictionary) -> String:
	var per: int = int(float(TextUiLayout.COLS) / float(TOP_COLUMNS.size()))
	var out: String = ""
	for c in TOP_COLUMNS:
		var cell: String = "%s:%s" % [String(c[1]), String(vals.get(String(c[0]), "—"))]
		out += TextUiLayout.pad_to(TextUiLayout.clip_to(cell, per - 1), per)
	return out


# ══ ④動作區：逐列印 `label` ＋（不可：`disabled_reason`）（spec §2③）═══════════
# ★★★rows 逐字是全列版 API 回的那些（`get_action_availability`）：
#   `{action_id, label, enabled, disabled_reason, opens_submenu}`
#   ⇒ 本函式**不判斷可不可做、不寫任何原因文案** —— 它只排版。
static func action_block(rows: Array) -> String:
	var lines: Array = []
	var n_ok: int = 0
	for r in rows:
		if bool(r.get("enabled", false)):
			n_ok += 1
	lines.append(region_title(A_ACTION, "%d／%d 可做" % [n_ok, rows.size()]))
	var idx: int = 0
	for r2 in rows:
		idx += 1
		var mark: String = SUBMENU_MARK if bool(r2.get("opens_submenu", false)) else " "
		var label: String = String(r2.get("label", ""))
		var line: String = "[%d]%s %s" % [idx, mark, label]
		if not bool(r2.get("enabled", false)):
			# ★「（不可：」後面【只准接變數】—— 原因是引擎給的（藍圖③／spec §3 P5）
			line += "（不可：%s）" % String(r2.get("disabled_reason", ""))
		lines.append(TextUiLayout.clip_to(line, TextUiLayout.COLS))
	return "\n".join(lines)


# ══ ⑤事件流：最近 FEED_ROWS 條，每條「第N天 HH:MM｜來源｜內容」（spec §2④）═════
# ★★逐條帶時間是 P6 的斷言 ⇒ ★本函式**不補時間**：時間來自呼叫端給的欄位，
#   少了就會印空 ⇒ 那一條會紅。★★★自己補一個假時間 ＝ 讓 P6 恆綠。
static func feed_block(events: Array) -> String:
	var lines: Array = []
	lines.append(region_title(A_FEED, "最近 %d 條" % FEED_ROWS))
	var start: int = maxi(0, events.size() - FEED_ROWS)
	for i in range(start, events.size()):
		var e: Dictionary = events[i]
		var line: String = "%s｜%s｜%s" % [
			String(e.get("when", "")), String(e.get("source", "")), String(e.get("text", ""))]
		lines.append(TextUiLayout.clip_to(line, TextUiLayout.COLS))
	return "\n".join(lines)


# ══ ⑥底部：最後一道令的結果句【一行】＋ 鍵位提示【永遠印全】（spec §2⑤）═════════
static func foot_block(result_line: String, keymap: String) -> String:
	var lines: Array = []
	lines.append(region_title(A_FOOT, "永遠印全"))
	lines.append(TextUiLayout.clip_to(result_line, TextUiLayout.COLS))
	lines.append(keymap)   # ★不截：鍵位要印全（截掉等於把鍵藏起來）
	return "\n".join(lines)


# ══ 把六區組成整個畫面（★順序固定：任何模式都不搬，模式只改【動作區】的內容）═════
# regions 要有：top(Dictionary)／map(String)／pages(String)／action(Array)／
#              feed(Array)／result(String)／keymap(String)
static func compose(regions: Dictionary) -> String:
	var out: Array = []
	out.append(region_title(A_TOP, "%d 欄" % TOP_COLUMNS.size()))
	out.append(top_row(regions.get("top", {})))
	out.append(region_title(A_MAP, "游標可移"))
	out.append(String(regions.get("map", "")))
	out.append(region_title(A_PAGES, "[,][.] 切頁"))
	out.append(String(regions.get("pages", "")))
	out.append(action_block(regions.get("action", []) as Array))
	out.append(feed_block(regions.get("feed", []) as Array))
	out.append(foot_block(String(regions.get("result", "")), String(regions.get("keymap", ""))))
	return "\n".join(out)


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
