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

# ★★票 #2 刀 0（2026-10-06）：6 → **8**＝多兩支「已結束」走法（故事結束 spec §5c 的 P0）
#   ⇒ ★★它是**走法**不是一格：八條自驗規則（寬度／重複／英文／debug…）**全部**跑在那一屏上
#     （只斷言「整屏含那個字面」會放過一列 130 cols 的頂列）
const SPEC_WALKS_MIN: int = 9        # spec §3 要**六支玩家走法**（★含退化版本，見 WALKS）＋ 兩支已結束 ＋ 一支戰鬥（終端戰鬥區 spec 2026-10-07 §3）
# ★★而 `WALKS` 共 9 支：八支玩家走法 ＋ **一支 debug 走法**（它是對照組不是玩家走法）
#   ⇒ 下面每一條「玩家走法 ＝ 0」的斷言都**只看那六支**，而 debug 那一支要**必須 > 0**。
var _errors: int = 0
var _cells_ran: Array = []
var _last_flags: Dictionary = {}   # ★`_screen_for()` 在 render 那一刻記下的事實（P0 母體地板讀它）

const EXPECTED_CELLS: Array = [
	"_test_a_regions_present_and_ordered",
	"_test_b_no_duplicate_labels",
	"_test_d_no_english_identifiers",
	"_test_e_width_and_no_empty_region",
	"_test_f_same_state_renders_identically",
	"_test_g_player_walk_has_no_debug_tokens",
	"_test_c_printed_keys_are_typeable",
	"_test_h_no_dev_notes",
	"_test_i_story_end_column",
	"_test_j_fatigue_column_and_rest_key",
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
	# ══ ★★★★★【已結束】兩支（故事結束 spec §5c 的 P0；骨架 spec §12「走法母體多一個已結束狀態」）══
	#   ·「旗標」＝ spec 字面的 setup：`game_over=true` ＋ `game_over_reason`，**玩家還在**
	#   ·★★「戰死」＝ **真的 game_over 的形狀**：玩家從 `persons` 消失
	#     （`npc_combat_system.gd` 戰死那條最後一行是 `state.persons.erase(p.id)`）
	#     ⇒ `get_player_snapshot` 走**失敗出口** ⇒ ★只有「旗標」那支的話，
	#       「那一欄只在一個活世界上亮」與「玩家真的死了也看得到」在卷面上**分不開**
	{"name": "已結束（旗標）", "tokens": [], "degenerate": false, "story_end": "flag"},
	{"name": "已結束（戰死）", "tokens": [], "degenerate": false, "story_end": "dead"},
	# ★戰鬥區 §3：進戰鬥那一步（同格佈置一支隊 → T → 切到目標 → 選它 → 畫面上「攻擊」那一鍵）⇒ 戰鬥區也被 (d) 等格掃
	#   ★修前：主角狀態「head: healthy」、裝備「weapon_melee_low」是 GUI Label 原文 ⇒ (d) 紅
	{"name": "戰鬥（攻擊同格隊）", "tokens": [], "degenerate": false, "battle": true},
	# ★★★【反向走法】debug 走法 —— 它**必須**印出那幾個識別字（見 (g)）
	#   ⇒ 它不是第七支「玩家走法」，它是那條「＝ 0」斷言的**對照組**
	{"name": "★debug 走法", "tokens": [], "degenerate": false, "debug_pane": true},
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
	await _test_h_no_dev_notes()
	await _test_i_story_end_column()
	await _test_j_fatigue_column_and_rest_key()
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
	# ★★★★★【debug 走法 ＝ 真的把那個開關打開再跑】（systems 裁 §15③ 的反向那一半）
	#   ★合成字串只證明「判準有鑑別力」，**不證明那條走法還活著** ——
	#     真風險是 `truth_pane_enabled()` 永遠為假 ⇒ 功能死了而沒有人知道，
	#     而那時 (g) 照樣是綠的（「玩家看不到」與「它根本不存在」在卷面上長得一樣）。
	#   ⇒ 所以這裡**真的設環境變數**，跑完**復原**（不留給下一支走法）。
	var dbg: bool = bool(walk.get("debug_pane", false))
	var prev_env: String = OS.get_environment(TextUiMain.TRUTH_PANE_ENV)
	OS.set_environment(TextUiMain.TRUTH_PANE_ENV, "1" if dbg else "")
	if bool(walk.get("degenerate", false)):
		var st: WorldState = node._bridge.get_state()
		var pt: TeamData = st.teams.get(st.persons[st.player_id].team_id)
		ResourceBank.set_amt(pt, "coin", 0.0, "bed_fixture")
	var story: String = String(walk.get("story_end", ""))
	if story != "":
		var sw: WorldState = node._bridge.get_state()
		var ptid: int = sw.persons[sw.player_id].team_id
		if story == "dead":
			# ★照戰死那條的兩步：出 named ＋ 從 persons 抹掉（`player_id` 不清 —— 戰死也不清它）
			var pteam: TeamData = sw.teams.get(ptid)
			if pteam != null:
				sw.remove_member(pteam, sw.player_id, false)
			sw.persons.erase(sw.player_id)
		sw.game_over = true
		# ★原因字串**逐字照** `event_system.gd` 那個寫入者的格式（寬度預算要量真的長度）
		sw.game_over_reason = "玩家絕後（Team%d 無繼承人）" % ptid
	_last_flags = {}
	if bool(walk.get("battle", false)):
		var sb: WorldState = node._bridge.get_state()
		var bptid: int = sb.persons[sb.player_id].team_id
		var foe := TeamData.new()
		foe.team_id = 7320
		foe.faction_id = -1
		foe.tile_pos = sb.teams[bptid].tile_pos
		AnonTierSystem.add_anon(foe, AnonCohort.TIER_PLEB, 2)
		var fl := PersonData.new()
		fl.id = 73201
		fl.team_id = 7320
		sb.persons[fl.id] = fl
		foe.leader_id = fl.id
		sb.teams[7320] = foe
		node._refresh()
		# ★送鍵走玩家那一條（PlayerRepl.press_on：戰鬥中分流到戰鬥畫面、等到輪到玩家才回）；攻擊鍵讀綁定表不手寫
		for tk in ["t", "tab", "1", TextUiView.key_for("attack")]:
			await PlayerRepl.press_on(node, PlayerRepl.keycode_for(String(tk)))
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
	# ★母體地板要讀的事實：**render 那一刻**的旗標與玩家在不在（同一時刻，不是事後重查）
	var sf: WorldState = node._bridge.get_state()
	_last_flags = {"game_over": sf.game_over, "game_over_reason": sf.game_over_reason,
		"player_in_persons": sf.persons.has(sf.player_id)}
	OS.set_environment(TextUiMain.TRUTH_PANE_ENV, prev_env)   # ★復原（不污染下一支走法）
	node.queue_free()
	await process_frame
	return s


func _all_screens() -> Array:
	var out: Array = []
	for w in WALKS:
		var s: String = await _screen_for(w as Dictionary)
		out.append({"name": String((w as Dictionary).get("name", "?")), "screen": s,
			"story_end": String((w as Dictionary).get("story_end", "")),
			"flags": _last_flags.duplicate(),
			"degenerate": bool((w as Dictionary).get("degenerate", false)),
			"debug_pane": bool((w as Dictionary).get("debug_pane", false))})
	return out


# ★只取**玩家走法**（debug 那一支是對照組，不是玩家會走的路）
#   ⇒ ★★每一條「玩家走法裡某東西 ＝ 0」的斷言都只看這一組；
#     而 debug 那一支**必須 > 0**（否則那條走法是死的而沒有人知道）
static func _player_only(screens: Array) -> Array:
	var out: Array = []
	for s in screens:
		if not bool((s as Dictionary).get("debug_pane", false)):
			out.append(s)
	return out

static func _debug_only(screens: Array) -> Array:
	var out: Array = []
	for s in screens:
		if bool((s as Dictionary).get("debug_pane", false)):
			out.append(s)
	return out


# ══ 六條判準（純函式，回【違規清單】不回一個數）═════════════════════════════════

# (a) 區塊齊全且順序固定
# ★★panel 非空時**取代** map+pages 那一框（`text_ui_view.gd:272`）⇒ 那兩個錨在子模式中
#   **本來就不該出現** ⇒ 判準要照這條規則走，否則它會在每一個子模式屏上誤報。
static func _bad_regions(screen: String) -> Array:
	var bad: Array = []
	var has_panel: bool = screen.contains(TextUiView.A_PANEL)
	# ★戰鬥區（終端戰鬥區 spec §1②）：戰鬥中取代 map+pages 那一框，主畫面的動作區也不印（那些鍵不歸它）
	var has_battle: bool = screen.contains(TextUiView.BATTLE_TITLE)
	var want: Array = []
	for a in TextUiView.REGION_ANCHORS:
		var an: String = String(a)
		if has_panel and (an == TextUiView.A_MAP or an == TextUiView.A_PAGES):
			continue
		if has_battle and (an == TextUiView.A_MAP or an == TextUiView.A_PAGES or an == TextUiView.A_ACTION):
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
			# ★★★★★【第四次同族：區塊邊界不只有「錨」】（實測 2026-10-01）
			#   底部那一區的開頭是一條**滿寬分隔線**（`foot_block()` 的第一行），
			#   而 `A_FOOT` 是 `" 鍵："`（那一區的**最後**一行）
			#   ⇒ 那條分隔線與 `" 結果："` 那一行**不屬於任何錨** ⇒ 它們被算成**事件區的內容**
			#   ⇒ ★事件區明明是空的而 (e-2) 給了它綠（**假綠**，而我是看畫面才發現的）。
			#   ⇒ 修法：**滿寬分隔線也是邊界**（它在畫面上就是「上一區結束了」的意思）。
			if nx.strip_edges() == "─".repeat(TextUiLayout.COLS):
				nx_is_any_title = true
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
	_check("★母體地板：**玩家**走法數 ＝ spec 的 %d（%d；另有 %d 支 debug 走法當對照組）" % [
		SPEC_WALKS_MIN, _player_only(screens).size(), _debug_only(screens).size()],
		_player_only(screens).size() == SPEC_WALKS_MIN)
	_check("★★母體地板：**debug 走法**剛好 1 支（0 ⇒ 下面那條「＝ 0」沒有對照組）",
		_debug_only(screens).size() == 1)
	# ★戰鬥那一支真的進了戰鬥（否則 (d) 等格對戰鬥區的「＝ 0」沒有主詞）
	var battle_n: int = 0
	for sc in _player_only(screens):
		if String((sc as Dictionary).get("screen", "")).contains(TextUiView.BATTLE_TITLE):
			battle_n += 1
	_check("★★母體地板：有一支走法的畫面真的是戰鬥區（%d）" % battle_n, battle_n == 1)
	var all_bad: Array = []
	for s in _player_only(screens):
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
	for s in _player_only(screens):
		var d: Dictionary = s as Dictionary
		var dup: Array = _bad_duplicate_labels(String(d.get("screen", "")))
		print("   %-22s 重複 %d 個%s" % [String(d.get("name", "")), dup.size(),
			("：" + str(dup)) if not dup.is_empty() else ""])
		for x in dup:
			all_dup.append("%s｜%s" % [String(d.get("name", "")), String(x)])
	_check("★★★★★(b-1) 沒有任何一屏有重複【選項標籤】（%s）" % str(all_dup), all_dup.is_empty())
	# ★★(b-2) 另一種重複：**框抬頭與內容逐字相同** —— (b-1) 蓋不到它（它數的是 `[n]標籤`）
	var all_echo: Array = []
	for s2 in _player_only(screens):
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
	for s in _player_only(screens):
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
	for s in _player_only(screens):
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
	for s in _player_only(screens):
		var d: Dictionary = s as Dictionary
		var sc: String = String(d.get("screen", ""))
		# ★逐個指名（不只回一個數）；而「有幾個」那一半用 `_debug_hits()`
		#   ⇒ ★正向與反向對照**用同一個判準**，否則反向綠了也不代表正向有鑑別力
		for t in DEBUG_TOKENS:
			if sc.contains(String(t)):
				hits.append("%s｜%s" % [String(d.get("name", "")), String(t)])
	print("   命中 %d 處%s" % [hits.size(), ("：" + str(hits)) if not hits.is_empty() else ""])
	# ★★★★★★【反向走法：debug 走法下它【必須】出現】——
	#   沒有這一半，一個永遠為 0 的計數跟「那個功能被刪掉了」在卷面上一模一樣。
	var dbg_hits: int = 0
	for s3 in _debug_only(screens):
		dbg_hits = _debug_hits(String((s3 as Dictionary).get("screen", "")))
		print("   ★debug 走法命中 %d 個識別字（必須 > 0）" % dbg_hits)
	_check("★★★★★★【反向走法】debug 走法下那幾個識別字**必須出現**（%d）⇒ 那條走法是活的"
		% dbg_hits, dbg_hits > 0)
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


# ══ (h) ★★★★★【玩家畫面不得出現開發備註】════════════════════════════════════
# ★實測（看畫面才看到的，六條一條都不管它）：
#     `── 未分類（票B 將搬走：2 行，皆為跨頁混合（拆行是另一張票）`
#     `糧食跑道（缺趨勢）：未接出（票B）`
#     `（共 %d 處）【暫代】`
#   ⇒ 它們是**我們寫給自己看的話**，而玩家正在讀它 —— 而且括號還不平衡（被框寬截斷）。
# ★★為什麼六條抓不到：它是**中文**（(d) 只管英文識別字）、不重複（(b)）、不超寬（(e)）
#   ⇒ **檢查管道與失效管道不同軸** ⇒ 只能新增一條**指名**的判準。
# ★★★而判準是**指名**不是「看起來像開發話」：指名會漏（下一個人寫新的備註不在清單裡），
#   而**漏掉的代價是一個沒抓到**；猜測會誤報，而**誤報的代價是有人把這一條關掉**。
#   ⇒ 兩害取前者，而「會漏」這件事寫在這裡。
const DEV_NOTE_TOKENS: Array = ["票B", "另一張票", "【暫代】", "未接出", "未分類"]

func _test_h_no_dev_notes() -> void:
	print("\n── (h) 玩家畫面不得出現開發備註 ──")
	print("   指名的 token ＝ %s（★指名會漏，而漏的代價小於誤報 —— 理由在就地）" % str(DEV_NOTE_TOKENS))
	var screens: Array = await _all_screens()
	var hits: Array = []
	for s in _player_only(screens):
		var d: Dictionary = s as Dictionary
		var sc: String = String(d.get("screen", ""))
		for t in DEV_NOTE_TOKENS:
			if sc.contains(String(t)):
				hits.append("%s｜%s" % [String(d.get("name", "")), String(t)])
	print("   命中 %d 處%s" % [hits.size(), ("：" + str(hits)) if not hits.is_empty() else ""])
	_check("★★★★★★(h) 玩家走法的輸出裡開發備註 ＝ 0（命中：%s）" % str(hits), hits.is_empty())
	# ★反向對照：乾淨合成字串 0 → 塞一個必須 > 0
	var clean: String = "第 1 天 00:00｜一個乾淨的合成畫面"
	var c0: int = 0
	var c1: int = 0
	for t2 in DEV_NOTE_TOKENS:
		if clean.contains(String(t2)):
			c0 += 1
		if (clean + String(DEV_NOTE_TOKENS[0])).contains(String(t2)):
			c1 += 1
	print("   ★反向對照：乾淨 %d 命中 → 塞一個之後 %d 命中" % [c0, c1])
	_check("★★【反向對照】乾淨輸入命中 0（%d）" % c0, c0 == 0)
	_check("★★★【反向對照】塞一個開發備註之後必須命中（%d）" % c1, c1 > 0)
	# ★★★★★★【反向走法：那些儀器在 debug 走法下**必須還在**】——
	#   `票B 將搬走 N 行`／`【暫代】`／天窗的票號**不是雜訊，是儀器**
	#   （那個 N 就是票B 的母體 —— `text_ui_main.gd` 那一段的原裁定逐字寫著這件事）
	#   ⇒ 把它們移出玩家走法之後，**必須有一條確認它們沒有被順手刪掉** ——
	#     否則「玩家看不到」會變成「它根本不存在」，而票B 的進度讀數靜靜歸零。
	var dbg_notes: Array = []
	for s4 in _debug_only(screens):
		var sc4: String = String((s4 as Dictionary).get("screen", ""))
		for t4 in DEV_NOTE_TOKENS:
			if sc4.contains(String(t4)):
				dbg_notes.append(String(t4))
	print("   ★debug 走法裡那些儀器 ＝ %s（必須非空）" % str(dbg_notes))
	_check("★★★★★★【反向走法】debug 走法下票B 的儀器**還在**（%d 個）⇒ 它只是不在玩家那條路上"
		% dbg_notes.size(), not dbg_notes.is_empty())
	_cell("_test_h_no_dev_notes")


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


# ══ (i) ★★★★★【故事結束那一欄】（故事結束 spec §5c 的 P0；票 #2 刀 0）══════════════════
# ★八條自驗規則已經跑在兩支「已結束」走法上（它們在 `WALKS` 裡）⇒ 這一格只管**那一欄本身**：
#   ①已結束的兩支：頂列含 `故事已結束：<原因>`（★母體地板：render 那一刻旗標**真的為真**）
#   ②其餘玩家走法：**不含**那個欄標（★條件①：那一欄只在 `game_over` 為真時出現）
#   ③★「戰死」那一支：母體地板＝玩家**真的不在** `persons`（否則它退化成「旗標」那支）
#   ⇒ ★★負對照（先紅再修）：把 view 那一欄拿掉 ⇒ ①必紅；把失敗出口的兩鍵拿掉 ⇒ **只有戰死那支**紅
func _test_i_story_end_column() -> void:
	print("\n── (i) 故事結束那一欄（P0）──")
	var screens: Array = await _all_screens()
	var label: String = TextUiView.STORY_END_LABEL
	var ended: int = 0
	for sc in _player_only(screens):
		var d: Dictionary = sc as Dictionary
		var name: String = String(d.get("name", ""))
		var screen: String = String(d.get("screen", ""))
		var top: String = String(screen.split("\n")[0]) if screen != "" else ""
		var fl: Dictionary = d.get("flags", {})
		var story: String = String(d.get("story_end", ""))
		if story == "":
			_check("(i)② %s：頂列**不含**「%s」（故事沒結束 ⇒ 那一欄不出現）" % [name, label],
				not screen.contains(label))
			continue
		ended += 1
		print("   %s 頂列（display width %d）：" % [name, TextUiLayout.display_width(top)])
		print("     " + top)
		_check("★母體地板 %s：render 那一刻 `game_over` 真的為真（%s）"
			% [name, str(fl.get("game_over", null))], bool(fl.get("game_over", false)))
		if story == "dead":
			_check("★母體地板 %s：render 那一刻玩家真的不在 persons（在 ＝ %s）"
				% [name, str(fl.get("player_in_persons", null))],
				not bool(fl.get("player_in_persons", true)))
		# ★★實測（2026-10-06 第一次跑）：「旗標」那支隊名人口欄比較寬 ⇒ 原因被 clip 掉末尾一個字
		#   ⇒ 那是威脅欄的**寬度契約**（唯一無界欄、吃剩餘被 clip；spec §5c (甲) 已接受）不是缺陷。
		#   ⇒ 判準：欄標之後到 ` ｜ 待執行` 那一段必須是原因的**非空前綴**（被截的話印出來）
		var reason: String = String(fl.get("game_over_reason", "?"))
		var at: int = top.find(label)
		var tail_at: int = top.find(" ｜ 待執行")
		var body: String = top.substr(at + label.length(), tail_at - at - label.length()) if at != -1 and tail_at > at else ""
		print("   欄內容「%s」｜原因「%s」｜被截 ＝ %s" % [body, reason, str(body != reason)])
		_check("★★★★★(i)① %s：頂列含「%s」且其後是原因的非空前綴" % [name, label],
			at != -1 and body != "" and reason.begins_with(body))
	_check("★母體地板：已結束走法數 ＝ 2（%d）" % ended, ended == 2)
	# ★反向對照：同一個判準（contains 欄標）在乾淨合成字串上 0、塞進去之後 1
	var clean: String = "第 1 天 00:00 ｜ 灰狼隊（人口 14） ｜ 威脅：（無）"
	_check("★★【反向對照】乾淨輸入不含欄標", not clean.contains(label))
	_check("★★★【反向對照】塞進欄標之後必須含", (clean + label).contains(label))
	_cell("_test_i_story_end_column")


# ══ (j) 票 T §1③：玩家看得見疲勞（數值＋文字級距），也找得到「休息」那一鍵 ══════════════════════════════
func _test_j_fatigue_column_and_rest_key() -> void:
	print("
── (j) 疲勞欄（數值＋級距）與休息鍵（票 T）──")
	var screens: Array = _player_only(await _all_screens())
	var levels: Array = ["精神好", "有點累", "疲憊，走得慢", "累垮了，只剩三成速度"]
	var rest_label: String = PlayerApiMapper.action_label("rest")
	var open_n: int = 0
	var with_col: int = 0
	var inter_n: int = 0
	var with_rest: int = 0
	for sc in screens:
		var d: Dictionary = sc as Dictionary
		var screen: String = String(d.get("screen", ""))
		if String(d.get("story_end", "")) != "":
			continue
		var re := RegEx.new()
		re.compile("疲勞: \\d+%[^\\n]*\\n[^\\n]*體力：([^\\s│|]+)")   # ★級距在狀態列的下一行（狀態列那行是 ui-flow 零損失的舊行，不動）
		var m := re.search(screen)
		if screen.contains("狀態: "):
			open_n += 1
			if m != null and levels.has(m.get_string(1)):
				with_col += 1
		if screen.contains("── 自家隊動作（"):
			inter_n += 1
			if screen.contains("]" + rest_label):
				with_rest += 1
		print("   %s：疲勞欄 %s｜自家隊動作區 %s／休息鍵 %s" % [String(d.get("name", "")), m.get_string(0) if m != null else "（無）",
			str(screen.contains("── 自家隊動作（")), str(screen.contains("]" + rest_label))])
	_check("★母體地板：有狀態列的走法 ≥ 1（%d）、有自家隊動作區的走法 ≥ 1（%d）" % [open_n, inter_n], open_n >= 1 and inter_n >= 1)
	_check("(j)① 每一支有狀態列的走法都印「疲勞: N%%」＋下一行「體力：級距」（%d／%d）" % [with_col, open_n], with_col == open_n)
	_check("(j)② 每一支有自家隊動作區的走法都列出「%s」那一鍵（%d／%d）" % [rest_label, with_rest, inter_n], with_rest == inter_n)
	# ★反向：級距真的會隨數值變（四段各給一個值 ⇒ 四個不同的字）
	var seen: Array = [0, 30, 70, 100].map(func(x): return TextUiMain.fatigue_level_text(x))
	print("   級距 0／30／70／100 ％ ⇒ %s" % str(seen))
	_check("(j)③【反向】級距隨數值變（四段四個字）", seen == levels)
	_cells_ran.append("_test_j_fatigue_column_and_rest_key")
