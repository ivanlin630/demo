class_name UiPages
extends RefCounted
# 五分頁的【唯一一份】名單。
#
# ★★★為什麼要有這支檔：2026-09-23 之前，分頁名單在這個 repo 裡有【兩份】而且不一樣——
#   docs/notes/2026-09-08-...:71     團│據點│人│核心│事件      （物件分頁）
#   scripts/debug/c1_walkthrough.gd  生存│經濟│威脅│社交│記憶  （頁＝該欄回答的問題）
#   ⇒ blueprint 2026-09-23 裁後者，而★★【裁定只消滅今天的分歧】，
#     消滅「明天再長出第三份」的是【共用同一個常數】—— 這兩件事不互相取代。
#
# ★用法硬規（spec §2-1）：
#   ①畫面與走查都讀這裡；★★禁止在 text_ui_main.gd 另寫一份，或把頁名寫成字串字面值
#   ②名單【尚未經用戶簽核】（spec §0-4）⇒ 改名／改序必須是【改這一行】，不是改十幾處
const PAGE_ORDER: Array = ["生存", "經濟", "威脅", "社交", "記憶"]

# 頁首：`── 生存 (1/5) ──`
# ★「我現在在第幾頁」必須在畫面上 —— 否則玩家按了鍵不確定有沒有切過去，而他會以為是壞的。
static func header(idx: int) -> String:
	var i: int = clampi(idx, 0, PAGE_ORDER.size() - 1)
	return "── %s (%d/%d) ──" % [String(PAGE_ORDER[i]), i + 1, PAGE_ORDER.size()]

# 天窗：`<欄位名>：未接出（票B）`
# ★不得靜默略過 —— 沉默的空白會被讀成「這個世界沒有這個東西」。
static func skylight(field: String) -> String:
	return "%s：未接出（票B）" % field

# 循環切頁。★分頁是【常駐】的內容選擇，永遠有一個選中 ⇒ 不會有「沒有頁」的狀態。
static func next_idx(idx: int, delta: int) -> int:
	var n: int = PAGE_ORDER.size()
	return ((idx + delta) % n + n) % n
