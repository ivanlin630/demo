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
# ★★子模式面板的錨 —— ★**刻意不進 `REGION_ANCHORS`**：它與 map+pages **互斥**
#   （非空時取代那個框）⇒ 它不是第七區，而 P1「六個錨各剛好一次」在有面板時
#   本來就不該要求 `┌─ 地圖（`／`┬─ [` 出現。★★而那一點要由床證：見 P30。
const A_PANEL: String  = "─ 面板（"
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

# ══ ★★★動作鍵 → `action_id` 的【靜態】映射（systems 裁 2026-10-01｜藍圖裁 (乙-1) `c3e13a016`）══
#   ·不變量 #10 禁的**不是字母也不是數字**，是「意義由**位置／計數**決定」
#     （血證逐字在 `text_ui_main.gd:1521`：面板消失 fe_count 2 → 0 之後再按同一個 KEY_1，
#      實測執行了 `establish_faction` ＋ `train`）
#   ·⇒ 條件：**鍵綁 `action_id`，不綁清單位置**。★而那個性質**與字母／數字無關**。
#   ★★★為什麼不是字母（我提過 (甲)，systems 用一條原則否掉它，而理由比「違反字面」硬）：
#     **判別子必須是【玩家自己改變的狀態】，不能是【世界改變的狀態】。**
#     ·目標聚焦 ＝ 玩家按的 ⇒ 可以當判別子
#     ·面板在不在 ＝ **世界改的** ⇒ 不可以（鍵在玩家手指下換意思，而他什麼都沒做）
#     ⇒ 字母若也給動作，(甲) 會把 #10 的血證原封不動種回來（玩家按 A 回應 → 面板消失
#       → 再按一次 A ⇒ 變成交易／建國／扣錢）⇒ **強制回應的鍵空間必須被它獨佔**。
#   ⇒ ★稿子的外觀 `[A] 交易` 改成 `[1] 交易`（藍圖裁 (乙-1)：字母只是外觀，
#     而「一個鍵永遠是同一個動作」這個**性質**由這張靜態表保住）。
#
# ★★【上限 ＝ 9，而這是一個真的限制，寫在這裡不假裝不存在】（照 #10 註解那句的做法）：
#   數字鍵只有 1..9 ⇒ 母體超過 9 的那一天，第 10 個**按不到**。
#   ·今天 `TEAM_TARGET_ACTIONS` 是 **12** 個 ⇒ ★**已經有 3 個沒有鍵**（下面具名列出）
#     ★★11 → 12／2 → 3 是 `offer_surrender` 進母體那張票一起改的（2026-10-01）——
#       ★而它**必須一起改**：這句話是一個【會過期的現況描述】，
#       而過期之後它仍然是一句看起來正常的話（沒有人會因為它假掉而紅）。
#     ★★★`offer_surrender` **刻意不進這張表**（systems 裁 (乙)）：
#       遭遇中求和已經有玩家路徑（`encounter_view.gd:381` 的 `KEY_F`）
#       ⇒ 給它第二個鍵等於同一件事兩個入口。
#   ·⇒ 它們在畫面上印「（未綁鍵）」而**不是被隱藏**，而床把「現在幾個沒鍵」印在卷面上
#   ·★★★**不現在做分頁**（systems 裁）—— 分頁要等它真的痛；而「現在幾個」看得見，
#     所以它痛的那一天不需要有人記得回來看。
const ACTION_DIGITS: Dictionary = {
	"trade": "1", "propose_alliance": "2", "demand_tribute": "3",
	"recruit": "4", "gather_intel": "5", "attack": "6",
	"extort": "7", "recruit_anon": "8", "invite_settle": "9",
	# ★沒有鍵的（母體 12 − 鍵 9 ＝ 3）：`ignore`／`beg`／`offer_surrender`
	#   ★★具名列出而不是只寫一個數：數字對而成員錯的時候，只有名字看得出來。
	#   ⇒ 它們照樣**列出來**（全列版的語意）而鍵位印「（未綁鍵）」。
}

const FEED_ROWS: int = 8          # 事件流固定筆數（spec §2④）
const SUBMENU_MARK: String = "▸"  # 有下一層（spec §2③）
const UNBOUND_MARK: String = "（未綁鍵）"
# ★底部結果句的前綴（★它的寬度由 `display_width` 量，不寫死 —— 見 `foot_block`）
const _RESULT_PREFIX: String = " 結果："


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
	# ══ ★★★★★【故事結束 ⇒ 取代威脅欄】（票 #2 刀 0，寬度預算 systems 裁 (甲)）═══════════
	#   ·威脅欄是頂列**唯一無界欄**、吃剩餘並被 clip ⇒ 原因字串（≈30 cols）放這裡**有預算**
	#   ·故事結束之後「威脅」一句沒有意義 ⇒ **取代而非新增**
	#   ·★★「既有床零影響」的條件①：這一欄**只在 `story_end` 非空時**出現
	#     （常駐「故事：進行中」會讓釘頂列字面的床全變）
	var story_end: String = String(v.get("story_end", ""))
	var label: String = STORY_END_LABEL if story_end != "" else "威脅："
	var body: String = story_end if story_end != "" else String(v.get("threat", "—"))
	used += TextUiLayout.display_width(label) + TextUiLayout.display_width(tail)
	var budget: int = TextUiLayout.COLS - used
	var threat: String = label + TextUiLayout.clip_to(body, maxi(budget, 0))
	return sep.join(PackedStringArray(head + [threat, tail]))

# ★故事結束那一欄的欄標（床的 P0 斷言這個字面 ⇒ 給它名字，不在兩處各寫一次）
const STORY_END_LABEL: String = "故事已結束："


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
		if not ACTION_DIGITS.has(String(r.get("action_id", ""))):
			n_unbound += 1
	lines.append(region_title(A_ACTION, "%d／%d 可做，未綁鍵 %d" % [
		n_ok, rows.size(), n_unbound]))
	# ★★★★★【空的時候印一行佔位，而不是把區塊藏起來】（自驗 (e-2) 實測：六支走法全空）
	#   ★理由是既有的那一條：**只在非零時才出現的東西，玩家學不會它的意思**
	#     —— 而「區塊消失」與「這個功能不存在」在畫面上長得一樣。
	#   ★★而這一行**說出為什麼空**（不是一句「（無）」）：動作區只在**聚焦一支隊伍**之後有列。
	if rows.is_empty():
		lines.append(" （沒有可做的動作 —— 先按 [T] 進互動、再選一支同格的隊伍）")
	for r2 in rows:
		var aid: String = String(r2.get("action_id", ""))
		var key: String = String(ACTION_DIGITS.get(aid, ""))
		var head: String = ("[%s]" % key) if key != "" else UNBOUND_MARK
		var mark: String = SUBMENU_MARK if bool(r2.get("opens_submenu", false)) else ""
		var line: String = " %s %s %s" % [head, String(r2.get("label", "")), mark]
		if not bool(r2.get("enabled", false)):
			# ★原因放不下時截在欄寬、以「…」結尾（spec 2026-10-07 reasons ②）；完整原因按下去結果行印
			var room: int = TextUiLayout.COLS - TextUiLayout.display_width(line + "（不可：%s）" % "")
			line += "（不可：%s）" % TextUiLayout.clip_mark(String(r2.get("disabled_reason", "")), room)
		lines.append(TextUiLayout.clip_to(line, TextUiLayout.COLS))
	return "\n".join(lines)

# 某個 action_id 拿到哪個鍵（""＝沒綁）★給床做 P8b 的比對用
static func key_for(action_id: String) -> String:
	return String(ACTION_DIGITS.get(action_id, ""))

# ★★★【反查】那個鍵是哪個 action_id（""＝這個鍵沒有綁任何動作）——
#   ★它存在的理由是一個實測缺陷（2026-10-01，reviewer 抓到、我引入的）：
#     畫面用 `ACTION_DIGITS[action_id]` 印鍵，而 handler 用**位置索引** `actions[num]` 執行
#     ⇒ 9 個有鍵的動作裡 **7 個對不上** ——
#       按「提議結盟」那個鍵會【攻擊】、按「打聽」會【索貢】（真的動錢動名聲）。
#   ⇒ ★★而三支床全綠：P8b／`key_for()` 驗**畫面那一側**、`ui_flow` 的按鍵格驗**handler 那一側**
#     ⇒ **沒有任何一格把兩側接起來** ⇒ 缺陷剛好落在兩支床**之間**
#     （「檢查管道與失效管道不同軸」最乾淨的一個實例：兩邊各自都對，
#      而**它們對的不是同一件事**）。
#   ⇒ ★★★所以 handler **必須讀這一支**而不是自己手抄第二份對照表：
#     一份表、兩個方向、同一個權威。
static func action_for_key(key: String) -> String:
	for aid in ACTION_DIGITS:
		if String(ACTION_DIGITS[aid]) == key:
			return String(aid)
	return ""


# ══ ⑤事件流：最近 FEED_ROWS 條，每條「第N天 HH:MM｜來源｜內容」（spec §2④）═════
# ★★逐條帶時間是 P6 的斷言 ⇒ ★本函式**不補時間**（自己補一個假時間 ＝ 讓 P6 恆綠）。
static func feed_block(events: Array) -> String:
	var lines: Array = []
	lines.append(region_title(A_FEED, "最近 %d 條" % FEED_ROWS))
	# ★★★★★【空的時候印一行佔位】（自驗 (e-2) 實測：事件區六支走法全空）
	#   ★理由同動作區：只在非零時才出現的東西，玩家學不會它的意思；
	#     而「區塊消失／只剩一條標題」與「這個功能不存在」在畫面上長得一樣。
	#   ★★而這一條**上一版被我自己的判準漏掉**：底部那條滿寬分隔線不屬於任何錨
	#     ⇒ `結果：` 那兩行被算成事件區的內容 ⇒ **假綠**（而我是看畫面才發現的）。
	if events.is_empty():
		lines.append(" （還沒有事件 —— 推進時間之後這裡會有紀錄）")
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
		# ★★★前綴的寬度要從【前綴自己】量，不要寫死一個數：
		#   `" 結果："` 的顯示寬度是 **7**（空白 1 ＋ 結 2 ＋ 果 2 ＋ ： 2），而我第一版寫 `COLS - 4`
		#   ⇒ 前綴 7 ＋ 內容 116 ＝ **123 > COLS** ⇒ **P3c 會紅，而紅的是我的減法不是版面**。
		#   ★同一族（今天第三次）：`（不可：` 我寫死 5 而它是 4；`k + 5` 那個偏移；這次是 `- 4`。
		#   ⇒ 判準：**寬度／偏移一律從那個字串自己量（`display_width`／`length`），不要寫死數字。**
		_RESULT_PREFIX + TextUiLayout.clip_to(result_line,
			TextUiLayout.COLS - TextUiLayout.display_width(_RESULT_PREFIX)),
		# ★★★★★【鍵位那一行要換行，不要截斷】（自驗 (e-1) 實測寬 167 而上限 120）
		#   ★判準：**有宣告寬度的東西可以截、沒有宣告寬度的不可以** ——
		#     而這一行的內容是**玩家需要的鍵**：截掉它 ＝ 把一半的鍵藏起來，
		#     而玩家不會知道後面還有（★「沒看到」與「沒有這個功能」在畫面上長得一樣）。
		#   ⇒ 所以**折行**：第一行帶 `A_FOOT`（`" 鍵："`），續行用等寬縮排
		#     ⇒ ★★`A_FOOT` 仍然**剛好出現一次**（區塊錨那一格在數它）。
	] + _keymap_lines(keymap))


# 把鍵位字串折成多行（第一行帶 `A_FOOT`，續行縮排對齊）
# ★在**空白處**折（不在一個 `[X]鍵名` 中間切開 —— 切開的鍵名玩家讀不出來）
static func _keymap_lines(keymap: String) -> Array:
	var indent: String = " ".repeat(TextUiLayout.display_width(A_FOOT))
	var out: Array = []
	var cur: String = A_FOOT
	var budget: int = TextUiLayout.COLS
	for tok in keymap.split(" "):
		var t: String = String(tok)
		if t == "":
			continue
		var cand: String = cur + ("" if cur.ends_with("：") else " ") + t
		if TextUiLayout.display_width(cand) > budget and cur.strip_edges() != "":
			out.append(cur)
			cur = indent + t
		else:
			cur = cand
	if cur.strip_edges() != "":
		out.append(cur)
	return out


# ══ ★★★【子模式面板】—— 非空時**取代** map+pages 那個框（systems 裁 2026-10-01 BLOCKER-2）
#   ★缺陷（我引入的形狀造成的）：舊的 `_event_label` 載著 **12 個子模式面板**
#     （戰前／交易／**目標清單**／成員／背包／勢力／據點／子隊／顧問／倉庫／打聽／招募），
#     而 `_render_screen()` 每次 render 都把它 `visible = false`、
#     而 `compose()` **沒有它們的位置** ⇒ 那 12 個面板【從來沒有進畫面】。
#   ⇒ ★★「選目標」最致命：玩家看不到目標清單，而動作清單要先選到目標才會出現
#     ⇒ **新版面的整條入口是黑的**。
#   ⇒ ★★★而三支床全綠，因為它們讀的是 `node._event_label.text`（**載體**）不是畫面
#     —— 而那正是「49 處斷言零遷移」那個性質的另一面：
#     **那 49 格從此不看畫面**。判準寫在床的 P30 旁邊。
#   ★放在 map+pages 的位置：子模式本來就是「接管畫面」的語意，
#     而放那裡保住「顯示只有一個」（不是再加一區）。
static func panel_block(panel_body: String) -> String:
	var w: Array = box_widths()
	var lines: Array = []
	lines.append(_fill_to(A_PANEL + "接管畫面）", TextUiLayout.COLS, "─"))
	for l in panel_body.split("\n"):
		lines.append(TextUiLayout.clip_to(String(l), TextUiLayout.COLS))
	return "\n".join(lines)


const BATTLE_TITLE: String = "─ 戰鬥（接管畫面）"

# ★BS v2 A：戰鬥區的局部地圖 —— 沿用世界地圖（TextMapRenderer）的格線語彙：一格 4 個字元、
#   每往下一列右移 2 個字元、菱形外留白；資料由 encounter_view.local_map_data() 供（這裡不讀世界）
static func render_battle_map(data: Dictionary) -> String:
	var center: Vector2i = data.get("center", Vector2i.ZERO)
	var r: int = int(data.get("radius", 0))
	var cells: Dictionary = data.get("cells", {})
	var lines: Array = []
	for dr in range(-r, r + 1):
		var line: String = "  ".repeat(dr + r)
		for dq in range(-r, r + 1):
			var h: Vector2i = center + Vector2i(dq, dr)
			line += ("%s   " % String(cells[h])) if cells.has(h) else "    "
		lines.append(line.rstrip(" "))
	return "\n".join(lines)
static func battle_block(body: String) -> String:
	var lines: Array = []
	lines.append(_fill_to(BATTLE_TITLE, TextUiLayout.COLS, "─"))
	for l in body.split("\n"):
		lines.append(TextUiLayout.clip_to(String(l), TextUiLayout.COLS))
	return "\n".join(lines)


# ══ 六區組成整個畫面（★順序固定：任何模式都不搬，模式只改【動作區】的內容）═════
# regions：top(Dictionary)／map(String)／pages(String)／map_note／tabs／
#          action(Array)／feed(Array)／result(String)／keymap(String)
static func compose(regions: Dictionary) -> String:
	var panel: String = String(regions.get("panel", ""))
	# ★★★子模式面板非空 ⇒ **取代** map+pages 那個框（見 `panel_block` 上方的理由）
	var mid: String = panel_block(panel) if panel.strip_edges() != "" else map_pages_box(
		String(regions.get("map", "")), String(regions.get("pages", "")),
		String(regions.get("map_note", "")), String(regions.get("tabs", "")))
	# ★終端戰鬥區（spec 2026-10-07 terminal-battle-screen §1②）：戰鬥中取代中間那個框；
	#   主畫面的動作區不印（那些鍵現在不歸它）；頁腳鍵列換成戰鬥的鍵（`_lbl_actions.text`，同一處讀）
	var battle: String = String(regions.get("battle", ""))
	if battle.strip_edges() != "":
		return "\n".join([
			top_row(regions.get("top", {}) as Dictionary),
			battle_block(battle),
			feed_block(regions.get("feed", []) as Array),
			foot_block(String(regions.get("result", "")), "戰鬥｜" + String(regions.get("battle_keys", ""))),
		])
	return "\n".join([
		top_row(regions.get("top", {}) as Dictionary),
		mid,
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
