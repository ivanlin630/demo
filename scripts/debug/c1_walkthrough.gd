extends SceneTree
# @bed-kind: diagnostic
# ★C1 票② 文字版畫面走查（★給用戶看的東西，不是判決）——所以標 diagnostic：
#   它的判準在【真人眼睛】，不在斷言（走查是不是「看過了」由種錯那格擋，不由這支床判）。
#
# 三條硬規（spec §2）：
#   ①★只呼叫【公開查詢動詞】—— 不直接讀 state ⇒ 接不出來的欄位會【開天窗】
#   ②★★天窗要印出來（「未接出」）—— ★★★沉默的空白會被讀成「這個世界沒有這個東西」
#   ③★世界要是【真的跑過的】—— 空世界的每一頁都很好看
#
# 用法：.\tools\godot.ps1 --headless --script scripts/debug/c1_walkthrough.gd
#   WALK_DAYS=2（預設）／WALK_ERRORS=1（★種幾顆已知錯，預設 1；設 0 = 乾淨版）
#   WALK_DROP_FIELD=<欄位名>（★驗收④的成對對照：★★把那一欄從【查詢面】拿掉——
#     做法是把它從 team.ctx_snapshot 抹掉，★★★而不是在印的時候跳過它
#     ⇒ 走查那一格必須自己變成天窗；若它還印得出值，代表畫面讀的是快取／自己算的，不是查詢面。）

const PAGE_ORDER: Array = ["生存", "經濟", "威脅", "社交", "記憶"]

# ★★★v2 加的：走查【自己寫檔】，不靠 console 轉手。兩個理由都是實測撞到的——
#   ①**要讀的東西被埋在第 1200 行之後**：console 那份前面是 1200 行引擎 log
#     ⇒ 「可讀」這件事在用戶滑到之前就已經輸了。
#   ②★★**console 這條路會【無聲吃字】**：v2 第一版經 console 落檔後，
#     標題「C1 票②」變成「C1 票」、分隔線 `━` 整條消失（★而句子還是通順的 ⇒ 沒有任何錯誤訊息）。
#     ★★★那正是「工具騙人」那一族：**刪掉識別字、而句子仍然讀得通**。
#   ⇒ FileAccess 直接寫 UTF-8，字元原樣落地。
const DEFAULT_OUT: String = "res://docs/measurements/2026-09-17-c1-walkthrough-v2-clean.txt"
var _buf: PackedStringArray = PackedStringArray()

func _say(s: String) -> void:
	_buf.append(s)
	print(s)

func _write_clean_copy() -> void:
	var out_path: String = OS.get_environment("WALK_OUT") if OS.has_environment("WALK_OUT") else DEFAULT_OUT
	if out_path == "":
		return
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		# ★寫不出來要說話：靜默失敗＝下游以為有檔，然後拿一份舊的來讀。
		print("★走查乾淨版寫檔失敗：%s（err=%d）" % [out_path, FileAccess.get_open_error()])
		return
	for line in _buf:
		f.store_line(String(line))
	f.close()
	print("★走查乾淨版已落地：%s（%d 行）" % [out_path, _buf.size()])

func _initialize() -> void:
	var days: int = int(OS.get_environment("WALK_DAYS")) if OS.has_environment("WALK_DAYS") else 2
	var n_err: int = int(OS.get_environment("WALK_ERRORS")) if OS.has_environment("WALK_ERRORS") else 1
	var st := _run_world(days)
	_drop_field_from_query_surface(st)
	var q := PlayerQueryApi.new()
	_say("")
	_say("╔══════════════════════════════════════════════════════════════════╗")
	_say("║ 世界沙盒 · 文字版畫面走查（C1 票②）                              ║")
	_say("╚══════════════════════════════════════════════════════════════════╝")
	if n_err > 0:
		_say("★★★開場先講明：**這一份裡埋了 %d 顆已知錯**（N 講明、位置不講）。" % n_err)
		_say("   抓到幾顆算幾顆；漏抓的那一顆所在的【那一頁】重審，不整份作廢。")
		_say("   ★為什麼要先講：暗埋＝對你設局，而信任是體驗窗的本錢。")
	else:
		_say("（WALK_ERRORS=0：這一份【沒有】種錯，是乾淨版）")
	_say("")
	_print_status_line(q, st)
	var fields: Dictionary = _ctx_fields(q, st)
	var page_map: Dictionary = _page_map()
	var seeded: Array = _seed_errors(fields, n_err, page_map)
	for page in PAGE_ORDER:
		_print_page(page, page_map, fields)
	_print_supplement(q, st)
	_say("")
	_say("── 走查結束 ──")
	_say("★要你簽的三件（spec §3）：①這個欄位放這一頁，你找得到嗎")
	_say("                        ②這一行字你知道它在說什麼嗎（看不懂的列進人話層清單）")
	_say("                        ③★你想知道、而畫面上沒有的（★這一格最重要：只有真人給得出）")
	if n_err > 0:
		# ★答案【只在檔尾】：正文零標記（★★v1 在那一格印記號 ⇒ 對照恆真）
		_say("")
		_say("=== 埋錯答案（走查完再看）===")
		if seeded.is_empty():
			# ★★這次【沒有種到】要大聲說：沉默會讓「用戶沒抓到」與「根本沒東西可抓」長得一樣，
			#   而那兩件事的結論剛好相反。
			_say("  ★★★本份【沒有種到錯】—— 候選欄位這一輪都不在快照裡（或不是數字）。")
			_say("     ⇒ 這一份【不能】拿來判斷走查文件可不可讀：那一格這次是空的，不是綠的。")
			_say("WALK_ANSWER []")
		else:
			for e in seeded:
				_say("  %s" % String(e))
			_say("WALK_ANSWER %s" % str(seeded))
	_write_clean_copy()
	quit()

func _run_world(days: int) -> WorldState:
	seed(1337)
	Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json", false)
	# ★附身：挑一支有 leader 的隊（★世界要是真的跑過的 ⇒ 附身後再推進，快照才有值）
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.leader_id != -1 and st.persons.has(t.leader_id):
			st.player_id = t.leader_id
			break
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
	return st

# ★驗收④的對照：從【引擎存的那份快照】拿掉一欄 ⇒ 查詢動詞就回不出它。
#   ★★這一刀下在查詢面的【上游】，印的那段程式碼完全不知道有這回事。
func _drop_field_from_query_surface(st: WorldState) -> void:
	if not OS.has_environment("WALK_DROP_FIELD"):
		return
	var f: String = OS.get_environment("WALK_DROP_FIELD")
	if f == "":
		return
	var t: TeamData = null
	if st.player_id != -1 and st.persons.has(st.player_id):
		t = st.teams.get(int((st.persons[st.player_id] as PersonData).team_id))
	if t == null or not (t.ctx_snapshot is Dictionary):
		_say("★WALK_DROP_FIELD=%s 但沒有快照可拿掉 —— ★這個對照這次沒有跑到" % f)
		return
	var had: bool = (t.ctx_snapshot as Dictionary).has(f)
	(t.ctx_snapshot as Dictionary).erase(f)
	_say("★對照已施加：從查詢面拿掉欄位 `%s`（原本%s）—— 它那一格【應該】變成天窗" % [f, "在" if had else "就不在★這個對照無效"])

func _print_status_line(q: PlayerQueryApi, st: WorldState) -> void:
	var r: Dictionary = q.get_status_line(st)
	var d: Dictionary = r.get("data", {})
	var doing: Dictionary = d.get("doing", {})
	var clock: Dictionary = d.get("clock", {})
	_say("┌─ 常駐狀態列 ────────────────────────────────────────────────────")
	_say("│ 我是誰：%s（隊：%s）" % [str(d.get("who", "（未接出）")), str(d.get("team", "—"))])
	var w: Dictionary = d.get("where", {})
	var tile_v = w.get("tile", null)
	var qv = (tile_v as Dictionary).get("q", w.get("q", "?")) if tile_v is Dictionary else w.get("q", "?")
	var rv = (tile_v as Dictionary).get("r", w.get("r", "?")) if tile_v is Dictionary else w.get("r", "?")
	_say("│ 在哪　：格 (%s, %s)" % [str(qv), str(rv)])
	_say("│ 在做啥：%s（意向：%s）%s" % [
		_zh_value(str(doing.get("current_task", "（未接出）"))),
		_zh_value(str(doing.get("intent", "—"))),
		("" if bool(doing.get("has_snapshot", false)) else "  ★尚無決策快照")])
	_say("│ 現在　：第 %s 天（tick %s／每日 %s）｜速度：%s" % [
		str(clock.get("day", "?")), str(clock.get("tick", "?")),
		str(clock.get("ticks_per_day", "?")), str(clock.get("speed", "?"))])
	# ★這一行【不是給用戶讀的欄位】，是自陳資料從哪個查詢動詞來的除錯線索 ⇒ 明講，
	#   否則它看起來像「又一串沒翻成中文的東西」。
	_say("│ （除錯用·資料出處）%s" % str(d.get("sources", [])))
	_say("└──────────────────────────────────────────────────────────────────")

func _ctx_fields(q: PlayerQueryApi, st: WorldState) -> Dictionary:
	var r: Dictionary = q.get_decision_snapshot(st)
	var d: Dictionary = r.get("data", {})
	if not bool(d.get("snapshot", false)):
		_say("★沒有決策快照：%s" % str(d.get("note", "")))
		return {}
	return d.get("fields", {})

func _page_map() -> Dictionary:
	var out := {}
	var f := FileAccess.open("res://docs/process/ctx-exposure.tsv", FileAccess.READ)
	if f == null:
		return out
	for line in f.get_as_text().split("\n"):
		var l: String = String(line)
		if l.begins_with("#") or l == "" or l.begins_with("field\t"):
			continue
		var c: PackedStringArray = l.split("\t")
		if c.size() >= 4:
			# ★第五欄＝中文顯示名（systems 已填滿 119 欄）——★★三個畫面同一張表取名，
			#   否則同一個欄位在 REPL／GUI／走查叫三個名字 ⇒ ★★★用戶無法交叉比對，
			#   而交叉比對正是走查唯一的工具。
			out[String(c[0])] = { "pages": String(c[2]), "status": String(c[1]), "who": String(c[3]),
				"label": String(c[4]) if c.size() >= 5 else "" }
	f.close()
	return out

# ★種錯（v2）：★★種進去的值必須與真值【同型且合理】——
#   ★★★v1 的做法（換成「★（本頁埋的錯：這個值是假的）」）讓對照【恆真】：
#     用戶不是「看出來」，是【被告知】⇒ 那個練習量不到任何東西。
#   ⇒ 規矩：數值乘倍數／位移（且不得等於真值）、布林翻面、字串換成另一個真的任務名、
#     陣列少一個元素 —— ★任何「一看形式就知道是假的」都是同一個病換個樣子。
#   ★而【選哪一格】也有判準（systems 加的）：它要有可能被抓到 ——
#     ⇒ 只選【同一頁上有對帳夥伴】的欄位：兩個數字擺在一起就違反一條算得出來的鐵則，
#       ★★所以它落在【可判的區間】，而不是一個「沒有人能發現、然後被讀成用戶不夠仔細」的錯。
#
# ★★★v2 換位置（systems 定）：`food_days` 是【舊位置】—— 用戶已經知道那一顆 ⇒
#   再埋一次那一格【恆綠】，證明不了任何事。所以它被列進 FORBIDDEN，不是只從清單拿掉：
#   ★下一個改這支的人會看見「為什麼不能用它」，而不是只看見「它不在清單上」。
const FORBIDDEN_SEED_FIELDS: Array = ["food_days"]

# ★每個候選都自帶【對帳夥伴 + 那條鐵則】——★★造假的手法是把它撐到違反鐵則，
#   不是隨便乘一個倍數：隨機倍數有可能剛好還是合理值 ⇒ 那顆錯就沒有人抓得到。
const SEED_CANDIDATES: Array = [
	{ "field": "material_shortfall", "partner": "material_need_total",
	  "rule": "材料缺口不可能【大於】材料總需求（缺的最多就是全部）" },
	{ "field": "pending_claim_coin", "partner": "pending_claim_amt",
	  "rule": "寄賣待收錢不可能【大於】寄賣待收金額總數" },
	{ "field": "idle_labor", "partner": "population",
	  "rule": "閒置人手不可能【多於】全隊人數" },
	{ "field": "forage_yield_here", "partner": "camp_forage_floor",
	  "rule": "在這裡覓食拿得到的量【低於】營地的糊口底，卻還留在這裡覓食" },
]

func _seed_errors(fields: Dictionary, n: int, page_map: Dictionary) -> Array:
	if n <= 0 or fields.is_empty():
		return []
	var picked: Array = []
	for cand in SEED_CANDIDATES:
		if picked.size() >= n:
			break
		var k: String = String(cand["field"])
		var pk: String = String(cand["partner"])
		if FORBIDDEN_SEED_FIELDS.has(k):
			continue
		if not (fields.has(k) and fields.has(pk)):
			continue
		if not (fields[k] is float or fields[k] is int):
			continue
		if not (fields[pk] is float or fields[pk] is int):
			continue
		var before = fields[k]
		var after = _contradicting_value(before, float(fields[pk]))
		if str(after) == str(before):
			continue        # ★不得等於真值（否則那一格根本沒被種）
		fields[k] = after
		picked.append("%s：%s → %s　｜對帳夥伴＝%s（值 %s）｜鐵則：%s" % [
			_display_name(k, page_map), str(before), str(after),
			_display_name(pk, page_map), str(fields[pk]), String(cand["rule"])])
	return picked

# ★造出一個【違反鐵則】的值：穩定大於夥伴值，而且看起來還是同一型的正常數字。
func _contradicting_value(before, partner: float):
	var target: float = maxf(partner * 1.6 + 5.0, absf(partner) + 5.0)
	if before is int:
		return int(ceili(target))
	return snappedf(target, 0.001)

# ★人話名（票① 的唯一出口）：中文在前、代碼名在括號裡。
#   ★★答案區也走同一支 —— v1 的答案區印的是裸代碼名 `food_days`，
#   ⇒ 用戶在正文看到的是「現有糧食還能吃幾天」，在答案看到的是另一個詞，等於自己把對照拆了。
func _display_name(name: String, page_map: Dictionary) -> String:
	var meta: Dictionary = page_map.get(name, {})
	var label: String = String(meta.get("label", ""))
	return ("%s（%s）" % [label, name]) if label != "" else name

func _print_page(page: String, page_map: Dictionary, fields: Dictionary) -> void:
	_say("")
	_say("━━━ 【%s】頁 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" % page)
	var names: Array = page_map.keys()
	names.sort()
	var shown: int = 0
	for name in names:
		var meta: Dictionary = page_map[name]
		if not String(meta["pages"]).contains(page):
			continue
		shown += 1
		var shown_name: String = _display_name(String(name), page_map)
		if fields.has(name):
			_say("  %-38s %s" % [shown_name, _fmt(fields[name])])
		else:
			# ★天窗：具名 TODO，不靜默 —— 沉默的空白會被讀成「這個世界沒有這個東西」
			_say("  %-38s ★未接出（%s）" % [shown_name, String(meta["who"])])
	if shown == 0:
		_say("  （這一頁沒有欄位 —— ★而那本身是一個要回報的發現）")

func _print_supplement(q: PlayerQueryApi, st: WorldState) -> void:
	_say("")
	_say("━━━ 【補充母體】（★結構上不在 119 列裡的東西）━━━━━━━━━━━━━━")
	var ev: Dictionary = q.get_event_stream(st, 5)
	var events: Array = (ev.get("data", {}) as Dictionary).get("events", [])
	_say("  事件流（最近 5 則）：")
	if events.is_empty():
		_say("    （這個窗裡沒有事件 —— ★不是壞了，是世界安靜）")
	for e in events:
		_say("    · %s" % String(e))
	_say("  關係圖全貌：★未接出（todo:docs/superpowers/specs/2026-09-10-observer-inspect-depth-HOW.md）")

func _fmt(v) -> String:
	# ★物件不要印成 <RefCounted#…>：那對玩家是【看不懂】而不是【沒有】
	#   ⇒ 明說它是物件、還沒轉成人話 ⇒ 這一行本身就是【人話層清單】的一筆。
	if v is Object:
		return "〈物件〉尚未轉成可讀值 —— ★人話層清單的一筆（票②第二個產物）"
	if v is float:
		return "%.3f" % v
	# ★空集合印「（無）」而不是「[0 項]」：★★空值與【未接出】在畫面上必須不同形
	#   —— 否則天窗要防的病會以【空值】的形態溜過去（systems 立為慣例 2026-09-10）。
	if (v is Array and (v as Array).is_empty()) or (v is Dictionary and (v as Dictionary).is_empty()):
		return "（無）"
	if v is Array:
		return "[%d 項] %s" % [v.size(), str(v).substr(0, 60)]
	if v is Dictionary:
		return "{%d 鍵} %s" % [v.size(), str(v).substr(0, 60)]
	if v is String:
		return _zh_value(String(v))
	return str(v)

# ★★票① 的第二半：【欄位名】翻完了，**值**還會是代碼。
#   隊伍任務大多本來就是中文（"覓食"／"紮營"…），而 team_data.gd 裡剩四個 ASCII 常數
#   （idle／return_home／rest，以及任何之後新加的）——它們在畫面上就是一串英文。
const VALUE_ZH: Dictionary = {
	"idle": "閒著（沒有任務）",
	"return_home": "回家",
	"rest": "休息",
}

# ★★★而重點不是這張表，是【表以外的漏網】會不會被看見：
#   任何 `純小寫英文＋底線` 的值一律當成【還沒翻】並就地標記 ——
#   ⇒ 這一頁自己會長出人話層清單，不必靠我下次記得回來檢查。
#   （中文值不含 a-z ⇒ 不會誤標；"ok"／"N/A" 這種短碼被標到也是對的：它們也不是人話。）
func _zh_value(s: String) -> String:
	if VALUE_ZH.has(s):
		return "%s（%s）" % [String(VALUE_ZH[s]), s]
	if s != "" and _is_code_token(s):
		return "%s　★這個【值】還是代碼，沒翻成人話" % s
	return s

func _is_code_token(s: String) -> bool:
	for i in range(s.length()):
		var c: String = s[i]
		if not ((c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or c == "_" \
			or (c >= "0" and c <= "9")):
			return false
	return true
