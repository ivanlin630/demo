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
#   3. ★★★②④ 於 2026-09-30 重派（spec §7）：②′＝按了就結算（鎖旗與去重兩層【刪掉】，
#      不是簡化 —— 它們守的那段時間在 #8 之後不存在了）、④′＝(a) 從「逾時競態」降級成
#      「同一顆 tick 內的 pipeline 次序」。⇒ ④′ 是本檔的 P7；②′ 的玩家層那一格在
#      `ui_flow_test::_test_p23_response_settles_on_press`（它要真的按鍵）。

var _errors: int = 0
var _cells_ran: Array = []

# ★來自 spec §1③ 的母體常數：`player_forced_event` 的【產生端】有幾處。
#   ★★動工時我逐處數過（grep `player_forced_event = ` 非空賦值）：8 處。
#   改機制的人若新增一個產生端而【沒有走 setter】，P3 會紅。
const SPEC_ARRIVAL_SITES: int = 8
# ★★★【兩種豁免，各自指名】—— systems 裁 2026-09-30「指名，不是放寬」。
#   ★而它們是【兩個不同的性質】，混成一個清單會讓其中一個失去斷言：
#   ①`SPEC_UNKNOWN_OK`＝handler **完全不認得**（落到「未知提案類型」）而那是正確的：
#     ·`tribute_offer` 語意是【對方要給你進貢】⇒ 併進索貢那支 arm 會讓【玩家倒付錢】
#       ⇒ 它的守衛是 P10（按接受之後 coin 不得減少）。
#   ②`SPEC_REFUSED_BY_DESIGN`＝handler **認得、而刻意只回一句人話拒絕**：
#     ·`propose_trade`（`diplomatic_ai_system.gd:149`）：通商沒有 handler，
#       而「接受通商之後發生什麼」是 WHAT（systems 已呈報 blueprint）
#       ⇒ 本票只把拒絕句改人話 ⇒ 它【不在】A＼B 裡（handler 認得它），
#         所以它的斷言是【那句人話存在】而不是【差集包含它】。
#   ⇒ ★★這個分法是被卷面逼出來的：我第一版把兩者放同一個清單，
#     而改人話之後 `propose_trade` 進了 B ⇒ 差集只剩一個 ⇒ 集合相等紅。
#     ★★★紅得對：那個紅說的是「你的分類法把兩件事當成一件」。
const SPEC_UNKNOWN_OK: Array = ["tribute_offer"]
# ★★★2026-09-30 通商票之後這一組的語意【變了】，而我改斷言不刪格：
#   ~~`SPEC_REFUSED_BY_DESIGN = ["propose_trade"]`（認得而刻意只回一句人話拒絕）~~
#   ~~`SPEC_REFUSAL_SENTENCE = "對方提議通商，而你目前還沒有回應通商的方式"`~~
#   ⇒ 藍圖裁 (b)：玩家接受通商【走 NPC 那一段同一份 code】⇒ 那一支 arm 不再只回一句話，
#     它真的做事（`DiplomaticAiSystem.apply_trade_accept`）。
#   ★而舊斷言【紅得對】：它守的行為被換掉了 ⇒ 這一票改的就是它
#     （抓到它的是「改完守衛參數要重跑那支床本身」那條紀律，2026-09-30 立的）。
#   ★★留著劃掉的兩行：下一個人才看得到「這裡曾經是一句人話拒絕」，
#     而不是以為它從來就是做事的。
const SPEC_HANDLED_BY_SHARED_CODE: Array = ["propose_trade"]
# ★那一支 arm 必須呼【共用的那一份】而不是自己寫 —— 判準指到函式名，不指到效果
#   （指到效果就會變成「玩家與 NPC 效果相同」那種同源恆真）。
const SPEC_SHARED_FN: String = "apply_trade_accept"
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
	"_test_p7_indict_the_real_cause",
	"_test_p8_settled_response_is_silent",
	"_test_p9_proposal_strings_cross_source",
	"_test_p10_reverse_tribute_must_not_charge_the_player",
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

# ══ P7：④′ 指認真因（★【指認】不是【通過】）═══════════════════════════════
# ★★★spec §7 的形狀：床【不預判】哪一個候選成立，它把四個候選各自的證據欄印出來。
#   而 systems 加了一句：(c) 是唯一他已經有 file:line 的
#   （`player_command_system.gd` 的 `_accept_diplomacy` match 沒有 propose_alliance 那一支）
#   ⇒ ★若卷面印出來【不是 (c)】，那件事本身是一個發現（表示還有第五個候選）。
# ★★母體地板兩條（spec §4 逐字＋R² 補的那半）：
#   ①到達真的發生（forced_event 非空）
#   ②`proposal` 真的是會撞 match 的那種值（propose_alliance／propose_trade／tribute_offer）
#     —— 否則床會在一個【proposal 剛好合法】的世界裡對 (c) 恆綠。
# ★★★(a) 欄在 #8 之後改印【次序】不印【時間】：消費點與逾時在同一顆 tick 的第幾步。
# 負對照：把 `propose_alliance` 從 handler 的 match 拿掉 ⇒ 回歸斷言（ok=true）紅（★同一個擾動也讓 P9 的差集紅 —— 一個擾動打兩格是對的：它們守同一件事的兩面） ⇒ 已於 feat/forced-response-settles（2026-09-30 這一輪） 實測紅
func _test_p7_indict_the_real_cause() -> void:
	print("\n── P7 指認真因（四候選證據欄）──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	_npc_at_player(st, 7320)
	var PROPOSAL: String = "propose_alliance"   # ★diplomatic_ai_system:174 真的會寫的那個值
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7320,
		"proposal": PROPOSAL}, "fe_p7")
	# ── 母體地板
	_check("母體地板 A：到達真的發生（forced_event 非空）", not st.player_forced_event.is_empty())
	var hits_match: Array = ["propose_alliance", "propose_trade", "tribute_offer"]
	_check("母體地板 B：proposal 真的是會撞 match 的那種值（%s）" % PROPOSAL,
		hits_match.has(PROPOSAL))
	# ── 按接受（走 #8 的咽喉：入列 ＋ 自動請求一顆）
	var before_res: int = st.command_results.size()
	var before_ev: int = st.player_events.size()
	var r: Dictionary = bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_p7", "response_id": "accept"})
	print("   入列回傳：ok=%s queued=%s｜請求量=%d" % [
		str(r.get("ok", "?")), str(r.get("queued", false)), bridge.ticks_remaining()])
	bridge.tick_step()
	# ── 證據欄①：消費點的回傳（逐字）
	print("   ── 消費點的結果句（逐字）──")
	for i in range(before_res, st.command_results.size()):
		var e: Dictionary = st.command_results[i]
		print("     ok=%-5s %s" % [str(e.get("ok", "?")), String(e.get("text", ""))])
	if st.command_results.size() == before_res:
		print("     （一句都沒有 —— ★若這是靜默出口，它是 ②′ 那條；否則是 TTL 咬掉了）")
	# ── 證據欄②：事件流那幾句
	print("   ── 玩家事件流新增的句子 ──")
	for j in range(before_ev, st.player_events.size()):
		print("     [%s] %s" % [String(st.player_events[j].get("kind", "")),
			String(st.player_events[j].get("text", ""))])
	# ── 四候選各自的證據欄（★全印，不預判）
	var all_text: String = ""
	for i2 in range(before_res, st.command_results.size()):
		all_text += String(st.command_results[i2].get("text", "")) + "\n"
	for j2 in range(before_ev, st.player_events.size()):
		all_text += String(st.player_events[j2].get("text", "")) + "\n"
	print("   ══ 四候選證據欄 ══")
	# (a) 次序（★#8 之後這一欄印【步序】不印【時間】）
	var sr_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/sim_runner.gd"))
	var lines_sr: PackedStringArray = sr_src.split("\n")
	var consume_at: int = -1
	var timeout_at: int = -1
	for k in range(lines_sr.size()):
		var t: String = lines_sr[k].strip_edges()
		if consume_at == -1 and t == "_consume_player_commands(state)":
			consume_at = k + 1
		if timeout_at == -1 and t.contains("forced_event 超時自動拒絕"):
			timeout_at = k + 1
	print("   (a) 次序：消費點在源碼第 %d 行／逾時判定在第 %d 行（同一顆 tick 內）" % [
		consume_at, timeout_at])
	print("       ⇒ 消費在逾時%s ⇒ ★這是【決定性的 pipeline 次序】不是玩家手速"
		% ("【之前】" if consume_at < timeout_at and consume_at != -1 else "【之後】"))
	var kinds_now: Array = _kinds(st)
	print("       ⇒ 事件流：resolved=%s／timeout=%s" % [
		str(kinds_now.has("forced_event_resolved")), str(kinds_now.has("forced_event_timeout"))])
	_check("(a) 母體地板：那兩個步序都找得到（消費 %d／逾時 %d）" % [consume_at, timeout_at],
		consume_at != -1 and timeout_at != -1)
	# (b) 重複回應
	print("   (b) 重複回應：卷面有沒有「無待處理強制事件」= %s" % str(all_text.contains("無待處理強制事件")))
	# (c) _accept_diplomacy 回 false
	print("   (c) 未知提案類型：卷面有沒有「未知提案類型」= %s｜含 %s = %s" % [
		str(all_text.contains("未知提案類型")), PROPOSAL, str(all_text.contains(PROPOSAL))])
	# (d) 措辭撞車 —— ★★★「事件有沒有真的被接受」要讀【結構欄位】不是搜字串：
	#   我第一版搜「結盟」⇒ 命中的是【提案名】「提議與你結盟」而不是接受確認句
	#   ⇒ 那一欄印出 true 而事實是 ok=false。★同一族第四次（判準搜到的是它的名字不是它的結果）。
	var accepted: bool = false
	for i3 in range(before_res, st.command_results.size()):
		if bool(st.command_results[i3].get("ok", false)):
			accepted = true
	print("   (d) 措辭撞車：卷面有沒有「被拒絕（」= %s｜★而事件【真的被接受了嗎】（讀 ok 欄）= %s" % [
		str(all_text.contains("被拒絕（")), str(accepted)])
	# ★★★(d) 要【兩件同時】—— 而我第二版又把它簡化成只看 `accepted` 一件
	#   ⇒ (c) 修好、accepted 變 true 之後，它就印出「(d) 成立」而卷面上根本沒有拒絕語。
	#   ★同一族第五次（把合取條件塌成它的其中一個合項）⇒ 這裡把兩個合項都寫進判斷式。
	var queue_reject: bool = all_text.contains("被拒絕（")
	print("       ⇒ (d) 要成立必須【兩件同時】：事件真的被接受（%s）＋ 畫面那句是佇列的拒絕語（%s）"
		% [str(accepted), str(queue_reject)])
	print("         ⇒ (d) %s" % ("成立" if (accepted and queue_reject) else "不成立"))
	# ★★★而 match 那一支到底認不認得它 —— 這一欄是靜態的，直接讀 code（不預判，只是把事實擺上來）
	var pcs_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd"))
	var at: int = pcs_src.find("func _accept_diplomacy")
	var body: String = pcs_src.substr(at, 700) if at != -1 else ""
	print("   ★(c) 的靜態證據：`_accept_diplomacy` 的 match 裡有 `%s` 嗎 = %s" % [
		PROPOSAL, str(body.contains(PROPOSAL))])
	_check("★母體地板：找得到 `_accept_diplomacy` 的函式體（找不到＝這一欄不可判）", at != -1)
	# ══ ★★★(c) 已修（2026-09-30 本票）⇒ 這一格從【純診斷】升成【也守回歸】。
	#   ★我在上一封 handback 自己寫過：「(c) 修好時要加一格斷言 accept 之後 ok=true，
	#     而那一格屬於修它的那張票」—— 這就是那一格，而它就在同一個場景裡。
	#   ★★而【指認欄照留】：把證據欄刪掉的話，下一次同族復發時沒有東西會把四個候選印出來。
	_check("★★★(c) 已修：accept `propose_alliance` 之後消費點 ok=true（實測 %s）" % str(accepted),
		accepted)
	_check("★★(c) 已修：卷面不再出現「未知提案類型」", not all_text.contains("未知提案類型"))
	print("   ★★★本格【不下結論】：上面五欄交由讀的人指認。")
	print("     而 systems 說 (c) 是唯一他有 file:line 的候選 ⇒ 若卷面指的不是 (c)，")
	print("     那是一個【發現】（第五個候選），要寫進 handback 不要當噪音。")
	_cell("_test_p7_indict_the_real_cause")

# ══ P8：②′ 的靜默出口（對已結算的強制事件再回應 ⇒ 不產任何句子）══════════
# ★★★為什麼這一格【不在 ui_flow 裡】：ui_flow 的 P23 量到玩家連按時，第二次按
#   根本走不到 `respond_to_forced` —— 它掉進 self-actions（P23 的 [DISCOVERY]）
#   ⇒ ★所以靜默出口目前【從 UI 是 0 命中的】，它守的是那個洞被修好之後的世界。
#   ★★而一個 0 命中的分支若沒有自己的格，就只剩註解在替它說話（同 09-28 那條教訓）
#     ⇒ 這一格用【直呼】把它點著。
# ★母體地板：先斷言第一次回應【真的結算了】（forced_event 從非空變空），
#   否則「第二次沒有句子」在一個從來沒有事件的世界裡恆綠。
# ★★同時斷言 `silent` 的【寫入點只有兩處】（兩個空事件出口）——
#   它是一個會讓句子消失的旗子，而讓句子消失的東西必須數得出來。
# 負對照：三支都點過 —— ①空事件出口不再 silent ②消費點不認 silent（★證明旗子與消費點兩端都接著）③silent 多一個寫入點（2 → 3） ⇒ 已於 feat/forced-response-settles（2026-09-30 這一輪） 實測紅
func _test_p8_settled_response_is_silent() -> void:
	print("\n── P8 已結算的回應＝靜默 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	_npc_at_player(st, 7330)
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7330,
		"proposal": "propose_alliance"}, "fe_p8")
	_check("母體地板 A：到達真的發生", not st.player_forced_event.is_empty())
	bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_p8", "response_id": "refuse"})
	bridge.tick_step()
	_check("★母體地板 B：第一次回應真的結算了（forced_event 變空）",
		st.player_forced_event.is_empty())
	var base: int = st.command_results.size()
	var log0: int = st.command_log.size()
	# ── 第二、三次：對一個已經不存在的事件回應
	for _k in range(2):
		bridge.command_player("respond_to_forced",
			{"interaction_id": "fe_p8", "response_id": "refuse"})
		bridge.tick_step()
	var added: Array = []
	for i in range(base, st.command_results.size()):
		added.append(String(st.command_results[i].get("text", "")))
	print("   第二、三次回應新增的結果句 = %s（期望空）" % str(added))
	print("   而 command_log 新增 %d 筆（★期望 2：審計軌跡要留著）" % (st.command_log.size() - log0))
	_check("★★★靜默：兩次都沒有產生任何結果句（新增 %d）" % added.size(), added.is_empty())
	_check("★★審計軌跡留著：command_log 有記到那兩道（新增 %d／期望 2）"
		% (st.command_log.size() - log0), st.command_log.size() - log0 == 2)
	# ── `silent` 的寫入點只有兩處（★會讓句子消失的東西必須數得出來）
	var pcs: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd"))
	var writers: int = 0
	for l in pcs.split("\n"):
		if l.contains("\"silent\": true"):
			writers += 1
	print("   `\"silent\": true` 在 player_command_system 的寫入點 = %d（期望 2）" % writers)
	_check("★`silent` 只有兩個寫入點（兩個空事件出口）＝%d" % writers, writers == 2)
	print("   ★邊界：本格【不】斷言「拒絕禁靜默」沒被破 —— 那條守的是")
	print("     『玩家分不出被拒絕與沒吃到鍵』，而這裡玩家已經看過第一次的結果句。")
	print("     ⇒ 真正的判準是【同一條指令的回音 ≤ 2 次】（ui_flow P15 那一格）。")
	_cell("_test_p8_settled_response_is_silent")

# ══ P9：提案字串的【異源比對】（A ＼ B ＝ 指名豁免）═══════════════════════
# ★★★systems 裁 2026-09-30：只加第三個字串等於等第三次
#   （那支 arm 的註解記著第一次 `demand_tribute`，本票是第二次 `propose_alliance`）
#   ⇒ 要一格異源比對：
#     A ＝【寄件端】會寫進 forced_event 的 proposal 字串（機械導出，不手抄）
#     B ＝【handler】`_accept_diplomacy` 的 match 認得的字串
#     斷言 A ＼ B ＝ 指名豁免集合（★集合相等，不是 ⊆ —— 多一個少一個都紅）
# ★★為什麼這是【真比較】不是一句話講兩次：A 與 B 能各自獨立改變
#   ——有人加一個新提案而忘了 handler ⇒ A 變大、B 不變 ⇒ 差集多一個 ⇒ 紅。
# ★★★誠實限：A 從兩個寫入端導出 ——
#   ①`diplomatic_ai_system` 的 `_send_diplomacy_message(...)` 呼叫端第 4 個實參（字面字串）
#   ②`interaction_system` 那條：`npc.order_task if ... else "alliance"`
#      ⇒ 它的值域【不是字面可見的】：我取那一行的 fallback 字面（"alliance"）＋
#        全庫 `order_task` 的具體賦值（`TeamData.TASK_TRIBUTE_OFFER`）。
#      ⇒ ★若有人日後寫第二個具體 order_task 值而沒有經過那個常數，本格【看不到它】
#        —— 那是這一格已知的洞，寫在這裡而不是假裝 A 是封閉的。
# 負對照：把 `propose_alliance` 從 handler 的 match 拿掉 ⇒ 差集多一個（少 0／多 1） ⇒ 已於 feat/forced-response-settles（2026-09-30 這一輪） 實測紅
func _test_p9_proposal_strings_cross_source() -> void:
	print("\n── P9 提案字串異源比對 ──")
	# ══ A：寄件端
	var da_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/diplomatic_ai_system.gd"))
	var a_set: Array = []
	for l in da_src.split("\n"):
		if not l.contains("_send_diplomacy_message(") or l.strip_edges().begins_with("func "):
			continue
		# 取最後一個字面字串實參
		var parts: PackedStringArray = l.split("\"")
		if parts.size() >= 2:
			var v: String = String(parts[parts.size() - 2])
			if v != "" and not a_set.has(v):
				a_set.append(v)
	var is_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/interaction_system.gd"))
	for l2 in is_src.split("\n"):
		if l2.contains("\"proposal\":") and l2.contains("order_task"):
			# 那一行的 fallback 字面（`else "alliance"`）
			var p2: PackedStringArray = l2.split("\"")
			var fb: String = String(p2[p2.size() - 2]) if p2.size() >= 2 else ""
			if fb != "" and not a_set.has(fb):
				a_set.append(fb)
	# ★order_task 的具體值走常數（全庫唯一非空賦值）
	if not a_set.has(TeamData.TASK_TRIBUTE_OFFER):
		a_set.append(TeamData.TASK_TRIBUTE_OFFER)
	a_set.sort()
	print("   A（寄件端會寫的 proposal）= %s" % str(a_set))
	_check("★母體地板 A：寄件端集合非空（空的話下面全是空真）", not a_set.is_empty())
	_check("★★母體地板 A2：A 至少含三個 `_send_diplomacy_message` 呼叫端的字串（%d）" % a_set.size(),
		a_set.has("propose_alliance") and a_set.has("propose_trade") and a_set.has("demand_tribute"))
	# ══ B：handler 認得的
	var pcs: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd"))
	var at: int = pcs.find("func _accept_diplomacy")
	_check("★母體地板 B：找得到 `_accept_diplomacy`", at != -1)
	var body: String = pcs.substr(at, 1600) if at != -1 else ""
	var b_set: Array = []
	for l3 in body.split("\n"):
		# ★★★剝【行尾】註解：`_code_only` 只剝整行註解，而那支既有的 arm 行尾帶註解
		#   ⇒ `ends_with(":")` 不成立 ⇒ B 少一個 ⇒ 差集多一個。
		#   ★抓到它的是 B2 那條母體地板（「含 demand_tribute」）。
		#   ★★這正是我在 ui_flow 的 P9 寫過的那個已知洞（行尾註解仍騙得過它）——
		#     ★★★而【寫下來的已知洞不會自己修好】：同一個洞在另一支床上又咬了一次。
		var t3: String = _strip_trailing_comment(l3).strip_edges()
		if not t3.ends_with(":") or not t3.begins_with("\""):
			continue
		for tok in t3.trim_suffix(":").split(","):
			var v3: String = String(tok).strip_edges().trim_prefix("\"").trim_suffix("\"")
			if v3 != "" and not b_set.has(v3):
				b_set.append(v3)
	b_set.sort()
	print("   B（handler match 認得的）= %s" % str(b_set))
	_check("★★母體地板 B2：B 非空且含既有的 `demand_tribute`（否則抽取壞了）",
		b_set.has("demand_tribute"))
	# ══ A ＼ B
	var diff: Array = []
	for a in a_set:
		if not b_set.has(a):
			diff.append(a)
	diff.sort()
	var want: Array = SPEC_UNKNOWN_OK.duplicate()
	want.sort()
	print("   ★A ＼ B ＝ %s（①完全不認得而正確 ＝ %s）" % [str(diff), str(want)])
	_check("★★★A ＼ B 與【①完全不認得】那一組集合相等（多一個少一個都紅）", diff == want)
	# ══ ②認得【而且真的做事】的那一組（2026-09-30 通商票之後）
	for e0 in SPEC_HANDLED_BY_SHARED_CODE:
		print("   二：`%s` 在 B 裡＝%s（handler 認得它）" % [String(e0), str(b_set.has(String(e0)))])
		_check("二：`%s` handler 認得它（否則它該在差集裡而不是這一組）" % String(e0),
			b_set.has(String(e0)))
	# ★斷言那一支 arm 呼【共用那一份】—— 抽出 arm 的本體再找函式名，不掃整個檔
	var arm_at: int = pcs.find("\"propose_trade\":")
	_check("★母體地板：找得到 `propose_trade` 那一支 arm（找不到＝本條不可判）", arm_at != -1)
	var arm_body: String = pcs.substr(arm_at, 260) if arm_at != -1 else ""
	print("   二：那一支 arm 有沒有呼 `%s` ＝ %s" % [
		SPEC_SHARED_FN, str(arm_body.contains(SPEC_SHARED_FN))])
	_check("★★★二：那一支 arm 呼【共用的那一份】（不是自己寫一份）",
		arm_body.contains(SPEC_SHARED_FN))
	# ══ 兩組的理由都必須在檔裡指名（不是裸清單）
	var self_src: String = FileAccess.get_file_as_string(
		"res://scripts/debug/forced_event_panel_bed.gd")
	for e in (want + SPEC_HANDLED_BY_SHARED_CODE):
		_check("豁免 `%s` 在本檔有指名理由" % String(e),
			self_src.contains("`" + String(e) + "`"))
	# ══ defer token 狀態（★defers.tsv 是 systems 的檔 ⇒ 本格【印】不【改】）
	var defers: String = FileAccess.get_file_as_string("res://docs/process/defers.tsv")
	for e2 in (want + SPEC_HANDLED_BY_SHARED_CODE):
		print("   defers.tsv 有 `%s` 的 token 嗎 = %s" % [
			String(e2), str(defers.contains(String(e2)))])
	print("   ★上面兩行是【請求】不是斷言：defers.tsv 的 owner 是 systems（流程 doc）")
	print("     ⇒ 我不改他的檔；token 登記之後由他把這兩行收緊成硬斷言。")
	_cell("_test_p9_proposal_strings_cross_source")


# ══ P10：方向相反的提案【不得】讓玩家付錢（systems 裁 2026-09-30）═══════════
# ★★★這一格的工作是把「我讀出來的」變成「我量出來的」：
#   上一封我寫「`tribute_offer` 併進索貢那支 arm 會讓玩家倒付錢」並標明【沒有跑過】
#   ⇒ systems 裁：那一格的工作就是去跑它。
# ★而它同時是一道【柵欄】：防止未來有人「順手把所有字串都加進 match」。
# ★母體地板：先斷言玩家真的【有錢可以被扣】（0 coin 的話「沒有減少」恆真）。
# 負對照：把 `tribute_offer` 併進 `"tribute", "demand_tribute"` 那支 arm ⇒ ★★★實測 coin 500 → 375（玩家倒付 125）—— 這一支把我的【推論】變成【量測】 ⇒ 已於 feat/forced-response-settles（2026-09-30 這一輪） 實測紅
func _test_p10_reverse_tribute_must_not_charge_the_player() -> void:
	print("\n── P10 對方要進貢 ⇒ 玩家不得付錢 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	_check("母體地板 A：造得出玩家隊", pt != null)
	if pt == null:
		_cell("_test_p10_reverse_tribute_must_not_charge_the_player")
		return
	pt.resources["coin"] = 500.0
	var before_coin: float = float(pt.resources.get("coin", 0))
	_check("★母體地板 B：玩家真的有錢可以被扣（%.0f coin）—— 0 的話「沒有減少」恆真" % before_coin,
		before_coin > 0.0)
	_npc_at_player(st, 7340)
	st.set_player_forced_event({"action": "diplomacy", "from_id": 7340,
		"proposal": TeamData.TASK_TRIBUTE_OFFER}, "fe_p10")
	_check("母體地板 C：到達真的發生，且 proposal 就是那個反向字串（%s）"
		% TeamData.TASK_TRIBUTE_OFFER,
		String(st.player_forced_event.get("proposal", "")) == TeamData.TASK_TRIBUTE_OFFER)
	bridge.command_player("respond_to_forced",
		{"interaction_id": "fe_p10", "response_id": "accept"})
	bridge.tick_step()
	var after_coin: float = float(pt.resources.get("coin", 0))
	var said: String = ""
	if not st.command_results.is_empty():
		said = String(st.command_results[st.command_results.size() - 1].get("text", ""))
	print("   coin %.1f → %.1f（差 %+.1f）｜結果句＝%s" % [
		before_coin, after_coin, after_coin - before_coin, said])
	_check("★★★玩家 coin【不得減少】（%.1f → %.1f）" % [before_coin, after_coin],
		after_coin >= before_coin)
	print("   ★邊界：本格【不】斷言玩家【收到】貢品 —— 那條路不存在（接受對方進貢是另一張票）")
	print("     ⇒ 它只守【不得倒付錢】這一件，而那正是「順手把字串都加進 match」會造成的傷害。")
	_cell("_test_p10_reverse_tribute_must_not_charge_the_player")

# 只看【程式碼】不看整行註解（★血證：上一輪兩次被自己寫的註解汙染計數）
# 剝行尾註解。★`#` 只在【引號外】才算註解起點（引號計數奇偶）——
#   否則字串字面裡的 `#` 會把那一行切斷。
func _strip_trailing_comment(line: String) -> String:
	var q: int = 0
	for i in range(line.length()):
		var ch: String = line[i]
		if ch == "\"":
			q += 1
		elif ch == "#" and q % 2 == 0:
			return line.substr(0, i)
	return line

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
	_test_p7_indict_the_real_cause()
	_test_p8_settled_response_is_silent()
	_test_p9_proposal_strings_cross_source()
	_test_p10_reverse_tribute_must_not_charge_the_player()
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
