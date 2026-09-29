extends SceneTree
# @bed-kind: acceptance
# slice: 強制事件的面板人話 ＋ 生命週期三點（spec 2026-09-29 #7 的 ①③ 兩件）
#
# ★★★這支床要證明的那一句：玩家看得懂【是誰找上門、要什麼、接受會怎樣、不回應會怎樣】，
#   而那四件事在本票之前只有半件 —— 選項有人話（`forced_label`），事件本身沒有
#   （`player_api_mapper.gd:304` 把 `proposal` 原樣印 ⇒ 畫面上是「Team11 提議 propose_alliance」）。
#
# ★★母體【不是封閉集】是這支床的核心：`proposal` 有兩個寫入者、兩套詞彙
#   （`diplomatic_ai_system` 寫 propose_*；`interaction_system` 寫 `order_task` ⇒ tribute_offer）
#   ⇒ P2 守的就是「不認得的 id 要印出來、不得吞掉」。
#
# ★誠實限（三條，逐條寫在格裡）：
#   1. 本床【不經 `_input()`】—— 玩家真的讀到的那幾行由 `ui_flow_test`
#      的 `_test_p20_forced_panel_three_lines` 驗（那一格印出整段畫面）。
#   2. P5 讀的是【原始碼】不是 stdout：它擋「那一行被刪掉」，不擋「它真的印出來」；
#      而到達／回應兩句在 headless 卷面上有實證（本輪逐字貼進 handback）。
#   3. ★★★本票【不含】②面板鎖＋去重、④「按 T 變拒絕」的真因指認 ——
#      systems 2026-09-29 裁：#8（按一下＝一顆 tick）會換掉那兩格要量的時序，
#      ⇒ 現在量會量到一個【即將被換掉的世界】。這兩件等 #8 落地後重寫 spec 再做。

var _errors: int = 0
var _cells_ran: Array = []

# ★來自 spec §1③ 的母體常數：`player_forced_event` 的【產生端】有幾處。
#   ★★動工時我逐處數過（grep `player_forced_event = ` 非空賦值）：8 處。
#   改機制的人若新增一個產生端而【沒有走 setter】，P3 會紅。
const SPEC_ARRIVAL_SITES: int = 8
# ★三點各自的終端 print token（★認 token 不認整句：措辭改了不該誤報）
const EXPECT_PRINT_TOKENS: Array = [
	"forced_event 到達", "forced_event 回應", "forced_event 超時自動拒絕",
]

const EXPECTED_CELLS: Array = [
	"_test_p1_panel_three_lines_dto",
	"_test_p2_unknown_id_not_swallowed",
	"_test_p3_single_arrival_writer",
	"_test_p4_three_lifecycle_points_in_feed",
	"_test_p5_three_terminal_prints_exist",
	"_test_p6_one_table_not_two",
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

func _fresh() -> Array:
	seed(20260929)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, SimRunner.new()]

# 在玩家隊同格擺一支 NPC 隊（★樣本佈置，不走指令路徑）
func _npc_at_player(st: WorldState, tid: int) -> TeamData:
	var ptid: int = st.get_player_team_id()
	var t := TeamData.new()
	t.team_id = tid
	t.faction_id = -1
	if ptid != -1 and st.teams.has(ptid):
		t.tile_pos = st.teams[ptid].tile_pos
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 4)
	var l := PersonData.new()
	l.id = tid * 10 + 1
	l.team_id = tid
	l.person_name = "首領%d" % tid
	st.persons[l.id] = l
	t.leader_id = l.id
	st.teams[tid] = t
	return t

func _kinds(st: WorldState) -> Array:
	var out: Array = []
	for e in st.player_events:
		out.append(String(e.get("kind", "")))
	return out

func _text_of(st: WorldState, kind: String) -> String:
	for e in st.player_events:
		if String(e.get("kind", "")) == kind:
			return String(e.get("text", ""))
	return ""

# 只看【程式碼】不看整行註解（★血證：上一輪兩次被自己寫的註解汙染計數）
func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out


func _initialize() -> void:
	print("=== 強制事件面板人話＋生命週期三點（#7 的一三兩件）===")
	_test_p1_panel_three_lines_dto()
	_test_p2_unknown_id_not_swallowed()
	_test_p3_single_arrival_writer()
	_test_p4_three_lifecycle_points_in_feed()
	_test_p5_three_terminal_prints_exist()
	_test_p6_one_table_not_two()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== forced_event_panel DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══ P1：DTO 三個欄位都有人話，且不含原樣 id ═════════════════════════════════
# ★這一格與 ui_flow 那一格【分工不同】：這裡驗 DTO 的三個欄位各自成句，
#   ui_flow 驗玩家畫面真的印出它們。★兩邊都要，因為「DTO 對」與「畫面對」是兩件事。
# 負對照：把 `proposal_phrase` 的 propose_alliance 那一行刪掉（面板印回原樣 id） ⇒ 已於 feat/forced-event-panel（2026-09-29 這一輪） 實測紅
func _test_p1_panel_three_lines_dto() -> void:
	print("\n── P1 面板三行（DTO）──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	_check("母體地板 A：造得出玩家隊", st.get_player_team_id() != -1)
	_npc_at_player(st, 7311)
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7311,
		"proposal": "propose_alliance"}, "fe1")
	_check("母體地板 B：到達真的發生（forced_event 非空）", not st.player_forced_event.is_empty())
	var p: Dictionary = PlayerApiMapper.map_forced_interaction(st)
	print("   message      = %s" % String(p.get("message", "")))
	print("   consequence  = %s" % String(p.get("consequence", "")))
	print("   no_response  = %s" % String(p.get("no_response", "")))
	_check("面板拿到同一個 id", String(p.get("interaction_id", "")) == "fe1")
	var msg: String = String(p.get("message", ""))
	_check("誰：帶隊號", msg.contains("Team7311"))
	_check("誰：帶勢力欄", msg.contains("（獨立") or msg.contains("（勢力"))
	_check("誰：帶關係欄", msg.contains("關係："))
	_check("要什麼：人話", msg.contains("提議與你結盟"))
	_check("★★不含原樣 id propose_alliance", not msg.contains("propose_alliance"))
	_check("接受後果那一句非空且成句", String(p.get("consequence", "")).begins_with("接受＝"))
	_check("不回應那一句非空且成句", String(p.get("no_response", "")).contains("視同拒絕"))
	# ★不回應那一句【不得寫死 tick 數】：逾時是 hour-tick 那一格清的 ⇒ 真實語意是「下一個整點」
	_check("★不回應那一句沒有寫死 60／1440",
		not String(p.get("no_response", "")).contains("60")
		and not String(p.get("no_response", "")).contains("1440"))
	_cell("_test_p1_panel_three_lines_dto")


# ══ P2：不認得的 id【印出來】不吞掉 ════════════════════════════════════════
# ★★★這一格守的是 spec §1③ 那個【開放母體】—— 沒有它，下一個新 proposal
#   會靜默變成空字串，而空字串在畫面上長得跟「沒有這件事」一樣。
# ★母體不是假設而是量出來的：本格順手把【全庫 order_task 的具體值】那一個
#   （TASK_TRIBUTE_OFFER）也走一次 —— 它是第三個會撞同一個病灶的字串。
# 負對照：把 `proposal_phrase` 的 fallback 改成 ""（吞掉） ⇒ 已於 feat/forced-event-panel（2026-09-29 這一輪） 實測紅
func _test_p2_unknown_id_not_swallowed() -> void:
	print("\n── P2 未知 id 不吞 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	_npc_at_player(st, 7312)
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7312,
		"proposal": "zzz_unknown"}, "fe2")
	var p: Dictionary = PlayerApiMapper.map_forced_interaction(st)
	print("   未知 proposal ⇒ message = %s" % String(p.get("message", "")))
	print("   未知 proposal ⇒ consequence = %s" % String(p.get("consequence", "")))
	_check("★★★未知 proposal 原樣印在括號裡",
		String(p.get("message", "")).contains("提議（未知：zzz_unknown）"))
	_check("★後果那一句也不吞（帶原樣 id）",
		String(p.get("consequence", "")).contains("zzz_unknown"))
	# 未知 action 同樣不吞（母體開放的是【兩個軸】不只 proposal 那一個）
	st.set_player_forced_event({"action": "zzz_action", "from_id": 7312}, "fe2b")
	var p2: Dictionary = PlayerApiMapper.map_forced_interaction(st)
	print("   未知 action ⇒ message = %s" % String(p2.get("message", "")))
	_check("★未知 action 原樣印在括號裡",
		String(p2.get("message", "")).contains("未知事件：zzz_action"))
	# ★第三個具體字串：interaction_system 經 order_task 餵進來的那一個
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7312,
		"proposal": TeamData.TASK_TRIBUTE_OFFER}, "fe2c")
	var p3: Dictionary = PlayerApiMapper.map_forced_interaction(st)
	print("   tribute_offer（= %s）⇒ message = %s" % [
		TeamData.TASK_TRIBUTE_OFFER, String(p3.get("message", ""))])
	_check("tribute_offer 有自己的人話（★不落到未知那一支）",
		not String(p3.get("message", "")).contains("未知"))
	_cell("_test_p2_unknown_id_not_swallowed")


# ══ P3：到達的【唯一寫入口】═══════════════════════════════════════════════
# ★★★為什麼這一格比「每個產生端都 emit 一次」重要：8 個產生端逐處 emit ＝【清單保證】，
#   下一個新增強制事件的人不會知道還要 emit，★而漏掉的長相就是「玩家沒看到」＝靜默。
# ★母體邊界（必印）：本格【只數產品碼】—— `scripts/debug/` 的床照舊直接賦值
#   （床是佈置樣本，不是產生端），而那正是本格【不】把它們算進來的理由。
# 負對照：把 `diplomatic_ai_system` 那個產生端改回直接賦值（繞過 setter，0 → 1 處） ⇒ 已於 feat/forced-event-panel（2026-09-29 這一輪） 實測紅
func _test_p3_single_arrival_writer() -> void:
	print("\n── P3 到達唯一寫入口 ──")
	var files: Array = _product_gd_files()
	_check("母體地板：掃得到產品 .gd（%d 支）" % files.size(), files.size() > 50)
	var bad: Array = []
	var setter_calls: int = 0
	var setter_def: int = 0
	for f in files:
		var src: String = _code_only(FileAccess.get_file_as_string(f))
		for l in src.split("\n"):
			var t: String = l.strip_edges()
			# 非空賦值 = 產生端；`= {}` 是清除（回應／逾時那三處）
			if t.contains("player_forced_event = ") and not t.ends_with("= {}"):
				if not f.ends_with("world_state.gd"):
					bad.append("%s :: %s" % [f.get_file(), t])
			if t.contains("set_player_forced_event("):
				if t.begins_with("func "):
					setter_def += 1
				else:
					setter_calls += 1
	print("   產生端呼叫 setter 的次數 = %d（spec 說 %d）｜setter 定義 %d 處" % [
		setter_calls, SPEC_ARRIVAL_SITES, setter_def])
	if not bad.is_empty():
		for b in bad: print("   ★繞過 setter：" + b)
	_check("★★★沒有任何產品碼繞過 setter 直接賦值（%d 處）" % bad.size(), bad.is_empty())
	_check("★setter 只有一個定義（%d）" % setter_def, setter_def == 1)
	_check("★★產生端數目與 spec 常數相符（%d／%d）" % [setter_calls, SPEC_ARRIVAL_SITES],
		setter_calls == SPEC_ARRIVAL_SITES)
	print("   ★邊界：本格只數 scripts/simulation 與 scripts/data —— 床（scripts/debug）照舊直接賦值，")
	print("     理由是床在【佈置樣本】不是【產生事件】；把床算進來會讓這一格永遠紅而資訊量為零。")
	_cell("_test_p3_single_arrival_writer")

func _product_gd_files() -> Array:
	var out: Array = []
	for d in ["res://scripts/simulation", "res://scripts/data", "res://scripts/ui"]:
		_walk(d, out)
	return out

func _walk(dir: String, out: Array) -> void:
	var da := DirAccess.open(dir)
	if da == null:
		return
	da.list_dir_begin()
	var n: String = da.get_next()
	while n != "":
		if da.current_is_dir():
			if not n.begins_with("."):
				_walk(dir + "/" + n, out)
		elif n.ends_with(".gd"):
			out.append(dir + "/" + n)
		n = da.get_next()
	da.list_dir_end()


# ══ P4：生命週期三點都進【玩家事件流】════════════════════════════════════
# ★★★三點在本票之前【一點都不在】佇列裡：到達只在 UI 面板（離開面板就再也看不到）、
#   回應結果只在指令佇列那一句、逾時只有一行 `str(dict)` 的 debug print。
#   ⇒ 用戶逐字：「像 team11 找我要幹嘛我 UI 看不到 至少終端 LOG 要記錄吧?」
# ★母體地板：每一點都要先斷言【它真的發生了】（到達 ⇒ forced_event 非空；
#   回應 ⇒ respond 真的回了東西；逾時 ⇒ forced_event 真的被清掉），
#   否則「佇列裡沒有那一句」會在一個【什麼都沒發生】的世界裡恆綠。
# 負對照：把 `set_player_forced_event` 裡的 emit 換成 `pass`（到達那一句不進佇列） ⇒ 已於 feat/forced-event-panel（2026-09-29 這一輪） 實測紅
func _test_p4_three_lifecycle_points_in_feed() -> void:
	print("\n── P4 生命週期三點進事件流 ──")
	# ── 第一點：到達
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	_npc_at_player(st, 7313)
	var before: int = st.player_events.size()
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7313,
		"proposal": "propose_alliance"}, "fe3")
	_check("母體地板 A：到達真的發生", not st.player_forced_event.is_empty())
	print("   到達句 = %s" % _text_of(st, "forced_event_arrived"))
	_check("到達進了佇列（筆數 %d → %d）" % [before, st.player_events.size()],
		_kinds(st).has("forced_event_arrived"))
	_check("到達句是人話（帶隊號＋提議內容）",
		_text_of(st, "forced_event_arrived").contains("Team7313")
		and _text_of(st, "forced_event_arrived").contains("提議與你結盟"))

	# ── 第二點：回應結果（★走真的 respond_to_forced，不是自己組字）
	var pcs := PlayerCommandSystem.new()
	var r: Dictionary = pcs.respond_to_forced(st, "refuse")
	print("   respond 回傳 = ok=%s msg=%s" % [str(r.get("ok", "?")), String(r.get("msg", ""))])
	_check("母體地板 B：respond 真的有回傳", r.has("ok"))
	print("   回應句 = %s" % _text_of(st, "forced_event_resolved"))
	_check("回應結果進了佇列", _kinds(st).has("forced_event_resolved"))
	_check("★回應句帶 handler 自己的話（零第二份真相）",
		_text_of(st, "forced_event_resolved").contains(String(r.get("msg", "zzz"))))
	_check("回應句帶選項人話", _text_of(st, "forced_event_resolved").contains("拒絕"))

	# ── 第三點：逾時（★走真的 SimRunner hour-tick，不手動呼 emit）
	var pair2: Array = _fresh()
	var st2: WorldState = pair2[0]
	var runner2: SimRunner = pair2[1]
	_npc_at_player(st2, 7314)
	st2.set_player_forced_event({"action": "extort", "from_id": 7314}, "fe4")
	var spun: int = 0
	var cap: int = WorldState.TICKS_PER_HOUR * 2 + 2   # ★用常數不寫死 60
	var ppos2: Vector2i = st2.teams[st2.get_player_team_id()].tile_pos
	while spun < cap and not st2.player_forced_event.is_empty():
		runner2.advance_tick(st2, ppos2)
		spun += 1
	print("   推了 %d tick（上限 %d＝TICKS_PER_HOUR×2+2）後 forced_event 空=%s" % [
		spun, cap, str(st2.player_forced_event.is_empty())])
	_check("母體地板 C：逾時真的發生（forced_event 被清掉）", st2.player_forced_event.is_empty())
	print("   逾時句 = %s" % _text_of(st2, "forced_event_timeout"))
	_check("逾時進了佇列", _kinds(st2).has("forced_event_timeout"))
	_check("逾時句是人話（帶隊號＋視同拒絕）",
		_text_of(st2, "forced_event_timeout").contains("Team7314")
		and _text_of(st2, "forced_event_timeout").contains("視同拒絕"))
	_cell("_test_p4_three_lifecycle_points_in_feed")


# ══ P5：三點的終端 print 都在，而且不是 str(dict) ═════════════════════════
# ★★★誠實限（這一格自己的邊界）：它讀【原始碼】不讀 stdout ⇒ 它擋的是
#   「那一行被刪掉／被改回印 dict」，★不擋「它在真實跑動裡有沒有印出來」。
#   後者的證據在 headless 卷面（本輪到達／回應兩句逐字出現），而逾時那一句由 P4 的佇列版覆蓋。
# 負對照：把 sim_runner 逾時那一行改回 `str(state.player_forced_event)` ⇒ 已於 feat/forced-event-panel（2026-09-29 這一輪） 實測紅
func _test_p5_three_terminal_prints_exist() -> void:
	print("\n── P5 終端三點 ──")
	var srcs: Dictionary = {
		"forced_event 到達": "res://scripts/data/world_state.gd",
		"forced_event 回應": "res://scripts/simulation/player_command_system.gd",
		"forced_event 超時自動拒絕": "res://scripts/simulation/sim_runner.gd",
	}
	_check("母體地板：三個 token 都在表裡（%d）" % EXPECT_PRINT_TOKENS.size(),
		EXPECT_PRINT_TOKENS.size() == 3)
	for tok in EXPECT_PRINT_TOKENS:
		var path: String = String(srcs.get(tok, ""))
		var src: String = _code_only(FileAccess.get_file_as_string(path))
		var hit: String = ""
		for l in src.split("\n"):
			if l.contains(String(tok)) and l.contains("print("):
				hit = l.strip_edges()
				break
		print("   %s → %s" % [String(tok), hit if hit != "" else "★找不到"])
		_check("終端有這一點：%s" % String(tok), hit != "")
		_check("★這一點印的是人話不是 str(dict)：%s" % String(tok),
			hit != "" and not hit.contains("str(state.player_forced_event)"))
	_cell("_test_p5_three_terminal_prints_exist")


# ══ P6：面板與事件流用【同一張表】═════════════════════════════════════════
# ★★★這一格守的是本票要修的那個病【自己復發】：選項有人話而事件本身沒有，
#   成因就是那兩半不在同一個地方被維護。若哪天有人把中文片語複製進 world_events.gd，
#   兩邊就會各自漂 —— 而漂開的樣子在卷面上是綠的（兩邊各自都「有人話」）。
# ★判準能紅在哪：把任一句中文片語複製進 world_events.gd ⇒ 必紅。
# 負對照：在 `world_events.gd` 裡多寫一句中文片語（＝第二張表） ⇒ 已於 feat/forced-event-panel（2026-09-29 這一輪） 實測紅
func _test_p6_one_table_not_two() -> void:
	print("\n── P6 一張表不是兩張 ──")
	var we: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/world_events.gd"))
	var calls: int = we.count("PlayerApiMapper.action_phrase(")
	print("   world_events 呼叫 action_phrase 次數 = %d" % calls)
	_check("★事件流的片語是【呼叫】那張表來的（%d 次）" % calls, calls > 0)
	var dup: Array = []
	for phrase in ["提議與你結盟", "提議與你通商", "要求你納貢", "要向你進貢", "勒索你", "求投靠"]:
		if we.contains(String(phrase)):
			dup.append(String(phrase))
	if not dup.is_empty():
		print("   ★第二張表的證據：%s" % str(dup))
	_check("★★★world_events 裡沒有複製一份中文片語（%d 處）" % dup.size(), dup.is_empty())
	# 反向：那張表真的在 mapper 裡（否則上面那一句會因為【兩邊都空】而恆綠）
	var pm: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_api_mapper.gd"))
	_check("母體地板：表真的在 mapper 裡（不是兩邊都空）",
		pm.contains("提議與你結盟") and pm.contains("func proposal_phrase"))
	_cell("_test_p6_one_table_not_two")
