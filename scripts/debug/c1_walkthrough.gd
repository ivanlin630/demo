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

func _initialize() -> void:
	var days: int = int(OS.get_environment("WALK_DAYS")) if OS.has_environment("WALK_DAYS") else 2
	var n_err: int = int(OS.get_environment("WALK_ERRORS")) if OS.has_environment("WALK_ERRORS") else 1
	var st := _run_world(days)
	_drop_field_from_query_surface(st)
	var q := PlayerQueryApi.new()
	print("")
	print("╔══════════════════════════════════════════════════════════════════╗")
	print("║ 世界沙盒 · 文字版畫面走查（C1 票②）                              ║")
	print("╚══════════════════════════════════════════════════════════════════╝")
	if n_err > 0:
		print("★★★開場先講明：**這一份裡埋了 %d 顆已知錯**（N 講明、位置不講）。" % n_err)
		print("   抓到幾顆算幾顆；漏抓的那一顆所在的【那一頁】重審，不整份作廢。")
		print("   ★為什麼要先講：暗埋＝對你設局，而信任是體驗窗的本錢。")
	else:
		print("（WALK_ERRORS=0：這一份【沒有】種錯，是乾淨版）")
	print("")
	_print_status_line(q, st)
	var fields: Dictionary = _ctx_fields(q, st)
	var page_map: Dictionary = _page_map()
	var seeded: Array = _seed_errors(fields, n_err)
	for page in PAGE_ORDER:
		_print_page(page, page_map, fields)
	_print_supplement(q, st)
	print("")
	print("── 走查結束 ──")
	print("★要你簽的三件（spec §3）：①這個欄位放這一頁，你找得到嗎")
	print("                        ②這一行字你知道它在說什麼嗎（看不懂的列進人話層清單）")
	print("                        ③★你想知道、而畫面上沒有的（★這一格最重要：只有真人給得出）")
	if n_err > 0:
		# ★答案【只在檔尾】：正文零標記（★★v1 在那一格印記號 ⇒ 對照恆真）
		print("")
		print("=== 埋錯答案（走查完再看）===")
		for e in seeded:
			print("  %s" % String(e))
		print("  ★選它的理由：food_days 與同頁的 food_stock【互相矛盾】⇒ 兩個數字一除就對不上，")
		print("    ★★所以它落在【有可能被抓到】的區間 —— 而不是一顆沒有人能發現的錯。")
		print("WALK_ANSWER %s" % str(seeded))
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
		print("★WALK_DROP_FIELD=%s 但沒有快照可拿掉 —— ★這個對照這次沒有跑到" % f)
		return
	var had: bool = (t.ctx_snapshot as Dictionary).has(f)
	(t.ctx_snapshot as Dictionary).erase(f)
	print("★對照已施加：從查詢面拿掉欄位 `%s`（原本%s）—— 它那一格【應該】變成天窗" % [f, "在" if had else "就不在★這個對照無效"])

func _print_status_line(q: PlayerQueryApi, st: WorldState) -> void:
	var r: Dictionary = q.get_status_line(st)
	var d: Dictionary = r.get("data", {})
	var doing: Dictionary = d.get("doing", {})
	var clock: Dictionary = d.get("clock", {})
	print("┌─ 常駐狀態列 ────────────────────────────────────────────────────")
	print("│ 我是誰：%s（隊：%s）" % [str(d.get("who", "（未接出）")), str(d.get("team", "—"))])
	var w: Dictionary = d.get("where", {})
	var tile_v = w.get("tile", null)
	var qv = (tile_v as Dictionary).get("q", w.get("q", "?")) if tile_v is Dictionary else w.get("q", "?")
	var rv = (tile_v as Dictionary).get("r", w.get("r", "?")) if tile_v is Dictionary else w.get("r", "?")
	print("│ 在哪　：格 (%s, %s)" % [str(qv), str(rv)])
	print("│ 在做啥：%s（intent: %s）%s" % [
		str(doing.get("current_task", "（未接出）")), str(doing.get("intent", "—")),
		("" if bool(doing.get("has_snapshot", false)) else "  ★尚無決策快照")])
	print("│ 現在　：第 %s 天（tick %s／每日 %s）｜速度：%s" % [
		str(clock.get("day", "?")), str(clock.get("tick", "?")),
		str(clock.get("ticks_per_day", "?")), str(clock.get("speed", "?"))])
	print("│ ★來源：%s" % str(d.get("sources", [])))
	print("└──────────────────────────────────────────────────────────────────")

func _ctx_fields(q: PlayerQueryApi, st: WorldState) -> Dictionary:
	var r: Dictionary = q.get_decision_snapshot(st)
	var d: Dictionary = r.get("data", {})
	if not bool(d.get("snapshot", false)):
		print("★沒有決策快照：%s" % str(d.get("note", "")))
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
#     ⇒ 選 food_days（糧食還能撐幾天）：★★它與同頁的 food_stock（庫存糧）互相矛盾，
#       用戶把兩個數字一除就知道對不上 ⇒ ★★★這一格【落在可判的區間】，
#       而不是一個「沒有人能發現、然後被讀成用戶不夠仔細」的錯。
func _seed_errors(fields: Dictionary, n: int) -> Array:
	if n <= 0 or fields.is_empty():
		return []
	var prefer: Array = ["food_days", "population", "coin"]
	var picked: Array = []
	for k in prefer:
		if picked.size() >= n:
			break
		if fields.has(k) and (fields[k] is float or fields[k] is int):
			var before = fields[k]
			var after = _plausible_mutation(before)
			if str(after) == str(before):
				continue        # ★不得等於真值（否則那一格根本沒被種）
			fields[k] = after
			picked.append("%s：%s → %s" % [k, str(before), str(after)])
	return picked

# ★同型且合理的變造（★★不引入任何「看形式就知道是假的」記號）
func _plausible_mutation(v):
	if v is float:
		return snappedf(float(v) * 2.7 + 3.0, 0.001)
	if v is int:
		return int(v) * 3 + 7
	if v is bool:
		return not bool(v)
	return v

func _print_page(page: String, page_map: Dictionary, fields: Dictionary) -> void:
	print("")
	print("━━━ 【%s】頁 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" % page)
	var names: Array = page_map.keys()
	names.sort()
	var shown: int = 0
	for name in names:
		var meta: Dictionary = page_map[name]
		if not String(meta["pages"]).contains(page):
			continue
		shown += 1
		var label: String = String(meta.get("label", ""))
		var shown_name: String = ("%s（%s）" % [label, name]) if label != "" else name
		if fields.has(name):
			print("  %-38s %s" % [shown_name, _fmt(fields[name])])
		else:
			# ★天窗：具名 TODO，不靜默 —— 沉默的空白會被讀成「這個世界沒有這個東西」
			print("  %-38s ★未接出（%s）" % [shown_name, String(meta["who"])])
	if shown == 0:
		print("  （這一頁沒有欄位 —— ★而那本身是一個要回報的發現）")

func _print_supplement(q: PlayerQueryApi, st: WorldState) -> void:
	print("")
	print("━━━ 【補充母體】（★結構上不在 119 列裡的東西）━━━━━━━━━━━━━━")
	var ev: Dictionary = q.get_event_stream(st, 5)
	var events: Array = (ev.get("data", {}) as Dictionary).get("events", [])
	print("  事件流（最近 5 則）：")
	if events.is_empty():
		print("    （這個窗裡沒有事件 —— ★不是壞了，是世界安靜）")
	for e in events:
		print("    · %s" % String(e))
	print("  關係圖全貌：★未接出（todo:docs/superpowers/specs/2026-09-10-observer-inspect-depth-HOW.md）")

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
	return str(v)
