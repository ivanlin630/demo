extends SceneTree
# @bed-kind: invariant
# slice: 動作全列 ＋ 原因（spec 2026-09-30；權威＝§5 普查／§6 R² 加固／§7 母體邊界）
#
# ★★★這張票治的病：`map_available_action(…, enabled, disabled_reason, …)` 那兩個欄位
#   **存在於信封的型別裡而從來沒有被餵過非預設值** —— `player_query_api.gd:296` 硬寫 `true, ""`
#   ⇒ 恆 true／恆空，正是我們自己有守衛在抓的那一族。
#
# ★★而本票真正的重心有兩個，而它們不是同一件事：
#   ·P1／P1c／P17 守【名字】（母體 ＝ `TEAM_TARGET_ACTIONS`，而且要逐字引用那個名字）
#     ★★★【2026-10-01】`TEAM_TARGET_ACTIONS` 已收成 `ACTION_SHAPE` 的**衍生檢視**
#       ⇒ 三格各自錨在**不同**的東西上，而只有一格要換：
#       ·**P1c 沒換**（它驗的是「全列版那段 code **逐字呼那個名字**，不是另一份字面陣列」
#         —— ★名字的來源變了不影響它，而它現在**更承重**：那個名字就是衍生檢視本身）
#       ·**P17 換掉**（它舊版拿 `ACTION_SHAPE` 的 team 集合跟 `TEAM_TARGET_ACTIONS` 比
#         ⇒ 收成衍生物之後**同源 ⇒ 恆真**）⇒ 新版比的是**外部期望**
#         （`SPEC_TEAM_TARGET_TOTAL` ＋ `SPEC_TEAM_TARGET_NAMES`）
#       ·**P19 是新的**（spec P1／P2）：全庫手抄字面 ＝ 0 處 ＋ 那條同源斷言不准回來
#     ★★而**P1 的誠實限**（它沒有換，而它的鑑別力有一半是舊的）：
#       `get_action_availability` 自己就是在跑 `for name in TEAM_TARGET_ACTIONS`
#       ⇒ P1 的「雙向一致（列裡沒多的／常數裡沒缺的）」那兩條在**成員身分**這一維
#         是**同源 ⇒ 恆真**（★而這**不是這次造成的**：它在改之前也一樣，
#         當時是 `const` 字面 ＋ 一個迭代那個 `const` 的迴圈）。
#       ⇒ P1 真正還在守的是**別的東西**：列數 ＝ 常數 − 具名排除、
#         每個名字**剛好一次**、每一列有非空 `label`、`opens_submenu` 逐字等於宣告、
#         以及那個「有鍵／沒鍵」的差距（看得見用，不是斷言）。
#       ⇒ ★★★而「成員身分」那一維**現在由 P17 守**（它比的是外部期望）。
#   ·P7 守【條件】（pop 1.5 倍／readiness 0.7／coin 只准有一份）
#   ⇒ P7 更接近「一個真相一份」的本體：名字漂開看得出來，條件漂開只會讓
#     「選單說可以、handler 說不行」，而那在卷面上是沉默的。
#
# ★誠實限（逐條）：
#   1. ★spec P4 寫「舊介面回逐字相同的陣列」，而藍圖④要求 STUB 的 `recruit` **不列**
#      ⇒ 兩者在字面上衝突。我照藍圖做（不列），而 P4 改成
#      【只差那個具名排除】並把差集印出來 —— ★不是把 P4 放寬，是把它的主詞講準。
#   2. 本床的靜態格（P1c／P7／P8）不需要 Godot 的世界，而行為格需要。
#   3. 本票不改庫存那四處（`_make_item_action`）；P8 會把 22 個呼叫點的分佈印出來，
#      並說清楚本票涵蓋的是哪幾個 —— 否則「全列」這個詞沒有母體。

var _errors: int = 0
var _cells_ran: Array = []

const SPEC_TEAM_TARGET_TOTAL: int = 12      # `TEAM_TARGET_ACTIONS` 的大小（spec §7）
# ★★★11 → 12（`offer_surrender` 進母體，2026-10-01）—— ★這個數**必須與母體同一顆 commit**：
#   先改常數 ＝ 讓守衛先【要求】一件世界還沒做到的事（恆紅到期）；
#   先改母體 ＝ 讓守衛先【接受】一件世界還沒做到的事（恆綠）。兩個方向都錯。
# ★而 `SPEC_PAYLOAD_SITES`（下面那個也是 11）**刻意不動**：它的量綱是**呼叫點數**不是動作名數
#   ⇒ 兩個 11 數字相同而量綱不同，動錯那一個會讓一支床綠著說謊。
const SPEC_STUB_EXCLUDED: int = 0           # ★待裁（見 player_command_system 的 const 註解）：暫不排除任何名字
const SPEC_STUB_WORDING: String = "尚未實裝"  # ★reviewer 要求的措辭（不要讓人讀成「停用」）
const SPEC_CONSTANT_SYMBOL: String = "TEAM_TARGET_ACTIONS"
# ★P7 要數的三個條件字面（來自 spec §6④，不是我從輸出抄回來的）
# ★★★`refuse_if_not_in_encounter`（2026-10-01 加）—— ★為什麼錨在**函式名**而不是
#   `encounter_active` 那個欄位：全列版那一臂是**委派**給共用前置檢查的
#   ⇒ 欄位字面在全列版函式體裡是 **0 次**，錨在欄位上會讓這一格紅在一個【正確的世界】。
#   ⇒ 判準：條件被抽成共用函式之後，「唯一持有者」的錨要跟著變成**那支函式的名字**。
const SPEC_CONDITION_LITERALS: Array = ["1.5", "0.7", "RECRUIT_COST_ANON",
	"refuse_if_not_in_encounter"]
# ★★【判斷的單一源】（systems 裁 2026-10-01 P10）：`encounter_active` 在整支
#   `player_command_system.gd` 裡**恰好出現一次**（就在共用前置檢查裡）
#   ⇒ 要繞過它必須**真的再讀一次 state** ⇒ 這一條比「措辭只有一份」硬。
const SPEC_ENCOUNTER_FIELD_HITS: int = 1
# ★★★【措辭只有一份】（systems 裁 P8／P11）：這兩句字面在產品側各**恰好一行**。
#   ★母體邊界逐字：`scripts/simulation/` ＋ `scripts/ui/`，**排除 `scripts/debug/`**
#     —— 床持有外部期望字面是它的【職責】不是重複（不排除的話床自己會污染母體）。
#   ★★而計數要**先剝掉整行註解**：討論一句措辭的註解與使用它的 code 在文字上同形
#     ⇒ 不剝的話這一格會咬到「解釋這條規則」的那一行（實測：我自己就踩了一次）。
const SPEC_ONE_COPY_PHRASES: Array = ["非戰鬥中", "投降請和"]
# ★★★★★【共用前置檢查的三個消費者】（spec §2③ 實作審要優先打的那三件之②）——
#   ★宣告在一處，而「有沒有第四個該呼而沒呼的」由**反向掃**回答（見 P7 那一段）。
#   ★★而斷言要逐一打在【那一支的函式體】上，不是檔案層級 ——
#     「守衛宣稱保護某支函式而它從來沒呼那支函式」那一族就是檔案層級斷言養出來的。
# ★★★★`ACTION_SHAPE` 的三個【具名豁免】（不在 `_action_registry` 裡）——
#   ★床自己持有這份字面：讀 production 那邊的清單＝同源恆真（它寫什麼這一格都綠）。
#   ★★而 spec §3① 只點名了兩個（`cancel_move`／`move_to`）；第三個 `ignore` 是
#     **P1c（今天的 P17）逼出來的**（`target=="team"` 要等於那 12 個，含它）
#     ⇒ 少了它那一格必紅。這一條差異已回報 systems。
const SPEC_SHAPE_EXEMPT: Array = ["ignore", "cancel_move", "move_to"]
# ══ ★★★★★【團隊目標動作的【逐名外部期望】—— 這一份是刻意手抄的】═════════════
# （spec `2026-10-01-team-target-actions-becomes-a-derived-view-HOW.md` §3③，裁 (甲)）
# ★**它的價值就在於它不是從 `ACTION_SHAPE` 導出來的。**
#   `PlayerCommandSystem.TEAM_TARGET_ACTIONS` 現在是 `ACTION_SHAPE` 的**衍生檢視**
#   ⇒ 拿它去跟 `ACTION_SHAPE` 比就是**同源 ⇒ 恆真**（而卷面長相是綠）。
# ★★【壞掉會長什麼樣】（不是「別亂改」）：
#   ·若有人把這一份收成 `ACTION_SHAPE` 的衍生物（「少一份手抄清單不是好事嗎」）
#     ⇒ 下面 P17 那一格**從那一刻起恆真** ⇒ `ACTION_SHAPE` 的 team 欄位怎麼改都不會紅
#     ⇒ 而它壞掉的長相是**一片綠**，沒有任何一格會說話。
#   ·若有人只在這裡加一個名字而忘了 `SPEC_TEAM_TARGET_TOTAL`（或反過來）
#     ⇒ P17 會紅並**指名**那個差 —— ★這一對是**刻意成對**的：
#       `SPEC_TEAM_TARGET_TOTAL` 管【數目】、本清單管【成員】，
#       而「少一個名字而數目不變」那一維由對方補（計數是有損投影）。
# ★★★而 `colocation_gate_bed.gd` 的 `SPEC_TEAM_TARGET_TOTAL` 旁邊那三行 12 個名字
#   **是給人讀的字、不承重**（systems 裁）—— ⇒ 本專案的「兩個檔各自手抄同一份清單」
#   那個病**不成立**：**只有一份是資料，另一份是字**。
const SPEC_TEAM_TARGET_NAMES: Array = [
	"attack", "beg", "demand_tribute", "extort", "gather_intel", "ignore",
	"invite_settle", "offer_surrender", "propose_alliance", "recruit",
	"recruit_anon", "trade",
]
const SPEC_ENC_GATE: String = "refuse_if_not_in_encounter"
const SPEC_ENC_CONSUMERS: Array = ["_action_offer_surrender",
	"_action_surrender_in_encounter", "get_action_availability"]
# ★§7：兩份同形信封的呼叫點總數（普查的數字，寫進 spec）
const SPEC_ENVELOPE_SITES_QUERY: int = 4    # ★★★14 → 4（2026-10-01，第二母體 §3③）
# 查詢面那 11 段各自 `map_available_action(` 的 `if` 收成**一個迴圈** ⇒ 呼叫點 14 − 11 ＋ 1 ＝ 4。
# ★這是【基準更新】：那 11 個呼叫點真的不在了（實測 4，床自己印在 P8 那一格）。
# ★★而它與「原 18 → 15 → 14」那條軌跡是同一個方向：每一次都是**少一個第二份**。
# ★★★15 → 14（2026-10-01，`offer_surrender` 那張票）—— ★這是【基準更新】不是弱化：
#   那張票把查詢面 Layer 5 的 `offer_surrender` emit **整段刪掉**（它是第二個決定者）
#   ⇒ `map_available_action` 的呼叫點真的少了一處（實測 14，床自己印在 P8 那一格）。
#   ★★而它**原子**地跟那個刪除同一顆 commit：基準先放主線 ＝ 讓守衛先要求一件
#     世界還沒做到的事；基準晚放 ＝ 讓守衛先接受一件世界已經不成立的事。
#   ★★★這個數字是從床的輸出抄的，不是推算的 —— 而「它會變」是我預測到的，
#     ⇒ 照規矩：**先量；變了才換；沒變就不要動**。這一次是「變了」。
const SPEC_ENVELOPE_SITES_ITEM: int = 4     # `_make_item_action`（庫存，不在本票）
# ★P9／P10（systems 裁 2026-10-01「第三類」）：`"payload"` 的呼叫點數 ——
#   ★這個數字是【從 code 數出來印在卷面】的（不是從信裡抄的）；這一行只記「今天量到多少」
#   ⇒ 對不上 ⇒ 有人加了一處回 payload 的路 ⇒ 回來看它該不該宣告成入口，不是改這個數。
const SPEC_PAYLOAD_SITES: int = 11
# ★P10 的佈置：打聽要有東西可答 ⇒ 被問方必須先知道一些事（tick 0 的世界沒有人知道任何事）
const ARM_TICKS_FOR_KNOWLEDGE: int = 400

const EXPECTED_CELLS: Array = [
	"_test_p1_full_list_both_directions",
	"_test_p1c_static_cross_evidence",
	"_test_p2_every_false_has_a_reason",
	"_test_p4_old_view_differs_only_by_the_named_exclusion",
	"_test_p5_stub_not_listed",
	"_test_p7_conditions_have_a_single_holder",
	"_test_p8_envelope_boundary",
	"_test_p9_declared_openers_are_pure",
	"_test_p10_reverse_sweep_payload_without_declaration",
	"_test_p11_label_has_one_producer",
	"_test_p12_degenerate_state_keeps_openers",
	"_test_p13_listed_exactly_once",
	"_test_p14_requires_being_in_an_encounter",
	"_test_p15_neighbours_unchanged",
	"_test_p16_action_shape_reverse_sweep",
	"_test_p17_shape_team_equals_team_target_actions",
	"_test_p18_unlisted_must_be_reachable_from_some_panel",
	"_test_p19_single_definition_and_no_same_source_cross",
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
	seed(20260930)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, PlayerCommandSystem.new()]

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 取某一支函式的【函式體】原始碼（到下一個頂層 `func ` 為止）
func _func_body(src: String, sig: String) -> String:
	var i: int = src.find(sig)
	if i < 0:
		return ""
	var rest: String = src.substr(i + sig.length())
	var j: int = rest.find("\nfunc ")
	return rest if j < 0 else rest.substr(0, j)

# 找一個同格的目標隊（團隊目標動作的前提）
func _target(st: WorldState, pt: TeamData) -> int:
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			st.teams[k].tile_pos = pt.tile_pos
			return int(k)
	return -1


# ══ P1：全列 —— ★雙向（spec §3 P1 改雙向）═══════════════════════════════════
# ★這是少數「數數」合法的場合：那個數來自**外部常數**，不是自己算給自己看。
# ★★而雙向的理由：只驗「常數的每個名字都在列裡」擋不住列裡多出一個名字；
#   只驗「列裡的名字都在常數裡」擋不住少一個 ⇒ 兩個方向都要。
func _test_p1_full_list_both_directions() -> void:
	print("\n── P1 全列（雙向）──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	_check("★母體地板：找到同格目標（-1 的話每一列都會是「沒有目標」）", tid != -1)
	var rows: Array = cs.get_action_availability(st, tid)
	var expect_n: int = PlayerCommandSystem.TEAM_TARGET_ACTIONS.size() \
		- PlayerCommandSystem.STUB_NOT_IMPLEMENTED.size()
	print("   常數 %d 個 − 具名排除 %d 個 ＝ 預期 %d 列｜實得 %d 列" % [
		PlayerCommandSystem.TEAM_TARGET_ACTIONS.size(),
		PlayerCommandSystem.STUB_NOT_IMPLEMENTED.size(), expect_n, rows.size()])
	_check("★常數大小 ＝ spec 的 %d（對不上 ⇒ 母體變了，要回報不是改這裡）" % SPEC_TEAM_TARGET_TOTAL,
		PlayerCommandSystem.TEAM_TARGET_ACTIONS.size() == SPEC_TEAM_TARGET_TOTAL)
	_check("★★列數 ＝ 常數 − 具名排除（%d／%d）" % [rows.size(), expect_n], rows.size() == expect_n)
	# ★★★spec §4 要這個數**看得見**（它不是斷言，是一個會長大的痛）——
	#   母體 12 而 `ACTION_DIGITS` 只有 9 個鍵 ⇒ 有幾列【按不到】。
	#   ★本票**不決定鍵位**（§4 明文），但分頁那張票要等的就是這個數變大。
	var keyed: int = 0
	var unkeyed: Array = []
	for r0 in rows:
		var aid0: String = String((r0 as Dictionary).get("action_id", ""))
		if TextUiView.key_for(aid0) != "":
			keyed += 1
		else:
			unkeyed.append(aid0)
	print("   ★這一輪 %d 列裡【有鍵】的 %d 列｜沒有鍵的 %d 列：%s" % [
		rows.size(), keyed, unkeyed.size(), str(unkeyed)])
	print("     ⇒ ★本票不決定鍵位（spec §4）—— 這一行只讓那個差距看得見。")
	var seen: Dictionary = {}
	var extra: Array = []
	for r in rows:
		var id: String = String(r.get("action_id", ""))
		seen[id] = int(seen.get(id, 0)) + 1
		if not PlayerCommandSystem.TEAM_TARGET_ACTIONS.has(id):
			extra.append(id)
	var missing: Array = []
	for n in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		if PlayerCommandSystem.STUB_NOT_IMPLEMENTED.has(String(n)):
			continue
		if not seen.has(String(n)):
			missing.append(String(n))
	var dup: Array = []
	for k2 in seen.keys():
		if int(seen[k2]) != 1:
			dup.append("%s×%d" % [String(k2), int(seen[k2])])
	print("   方向①列裡多出來的：%s｜方向②常數裡缺的：%s｜重複出現的：%s" % [
		str(extra), str(missing), str(dup)])
	_check("★★★雙向一致：列裡沒有多的（%s）" % str(extra), extra.is_empty())
	_check("★★★雙向一致：常數裡沒有缺的（%s）" % str(missing), missing.is_empty())
	_check("★每個名字剛好出現一次（%s）" % str(dup), dup.is_empty())
	# ★★★敘述訂正（systems 裁 2026-10-01）：母體不再是「11 − 0 排除」而是
	#   「11 − 0 排除，其中 N 個是【第三類：子選單入口】」——★那 N 個的 `enabled` 沒有意義。
	var openers: Array = []
	var no_label: Array = []
	for r3 in rows:
		var id3: String = String(r3.get("action_id", ""))
		if String(r3.get("label", "")).strip_edges() == "":
			no_label.append(id3)
		if bool(r3.get("opens_submenu", false)):
			openers.append(id3)
	print("   ★母體敘述：常數 %d − 具名排除 %d，其中【子選單入口】%d 個 ＝ %s" % [
		PlayerCommandSystem.TEAM_TARGET_ACTIONS.size(),
		PlayerCommandSystem.STUB_NOT_IMPLEMENTED.size(), openers.size(), str(openers)])
	# ★★★★★【2026-10-01：這一條從「逐字（含順序）」窄化成「逐名（集合）」，理由寫在這裡】
	#   ·`TEAM_TARGET_ACTIONS` 收成 `ACTION_SHAPE` 的衍生檢視之後，**列序 ＝ 那張表的宣告順序**
	#     （字母序），而 `SUBMENU_OPENERS` 宣告的是**成員**，它的順序沒有語意。
	#   ·⇒ 拿兩個順序互比會在「有人重排那張表」時紅，而那不是缺陷 ⇒ 它是個會誤報的判準。
	#   ★★而**窄化不是刪除**：這一條仍然在守「這一欄不准多一個也不准少一個」。
	#   ★★★而【列序】這件事**本格不再有斷言**，所以它要被**印出來**（下一行）——
	#     列序是玩家看得到的東西，而它現在的擁有者是 `ACTION_SHAPE` 的宣告順序。
	var openers_sorted: Array = openers.duplicate()
	openers_sorted.sort()
	var decl_sorted: Array = PlayerCommandSystem.SUBMENU_OPENERS.duplicate()
	decl_sorted.sort()
	_check("★`opens_submenu` 這一欄逐名等於宣告（集合；列序 %s／宣告 %s）" % [
		str(openers), str(PlayerCommandSystem.SUBMENU_OPENERS)],
		openers_sorted == decl_sorted)
	var row_order: Array = []
	for r5 in rows:
		row_order.append(String(r5.get("action_id", "")))
	print("   ★【列序】（＝玩家看到的上下順序，擁有者 ＝ `ACTION_SHAPE` 的宣告順序）＝ %s" % str(row_order))
	# ★④（systems 裁）：每一列都要有 `label`，而來源只能是 `PlayerApiMapper.action_label`
	_check("★★每一列都有非空的 `label`（沒有的：%s）" % str(no_label), no_label.is_empty())
	var pcs_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd"))
	var body2: String = _func_body(pcs_src,
		"func get_action_availability(state: WorldState, target_id: int) -> Array:")
	_check("★★★`label` 的來源是 `PlayerApiMapper.action_label`（不是第二份中文表）",
		body2.contains("PlayerApiMapper.action_label("))
	# ★入口那幾列的語意：永遠可做、原因永遠空（★而 P9 用行為證它真的不改世界）
	for r4 in rows:
		if bool(r4.get("opens_submenu", false)):
			_check("★入口 `%s` 的 enabled ＝ true、原因是空的（它的語意，不是豁免）" % String(
				r4.get("action_id", "")),
				bool(r4.get("enabled", false)) and String(r4.get("disabled_reason", "")) == "")
	_cell("_test_p1_full_list_both_directions")


# 負對照：把母體換成另一份手抄的名字陣列（行為格照樣綠）⇒ 本格紅 ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ══ P1c：★靜態互證（§6①，reviewer 想到的第三種騙法）═══════════════════════════
# ★★★他推演的第三種：**兩份手抄名字剛好逐字同步**（靠人力維護）——
#   兩道動態擾動都測不出來（計數與集合都會對）。
#   ⇒ 所以要 grep 全列版那段 code：它必須**逐字呼 `TEAM_TARGET_ACTIONS`**，
#     而不是另一個字面陣列。
func _test_p1c_static_cross_evidence() -> void:
	print("\n── P1c 靜態互證（全列版必須逐字引用那個常數）──")
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var body: String = _code_only(_func_body(src,
		"func get_action_availability(state: WorldState, target_id: int) -> Array:"))
	_check("★母體地板：真的抓到全列版的函式體（抓不到 ⇒ 下面兩條恆綠）", body.length() > 0)
	var refs: int = body.count(SPEC_CONSTANT_SYMBOL)
	print("   全列版函式體裡 `%s` 出現 %d 次" % [SPEC_CONSTANT_SYMBOL, refs])
	_check("★★★它逐字引用 `%s`（不是另一個字面陣列）" % SPEC_CONSTANT_SYMBOL, refs >= 1)
	# ★另一半：函式體裡不得自己寫一個動作名字的字面陣列
	var suspicious: int = 0
	for line in body.split("\n"):
		var t: String = line.strip_edges()
		if t.contains("[\"ignore\"") or t.contains("[\"attack\"") \
				or (t.begins_with("var ") and t.contains("\"trade\"") and t.contains("\"extort\"")):
			suspicious += 1
	print("   函式體裡看起來像「另一份名字陣列」的行數 ＝ %d" % suspicious)
	_check("★★沒有第二份名字陣列（%d 行可疑）" % suspicious, suspicious == 0)
	_cell("_test_p1c_static_cross_evidence")


# 負對照：把某一條的原因字串清空（enabled 仍 false）⇒ 本格紅（空的：extort） ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ══ P2：enabled=false 的每一列都要有原因 ═════════════════════════════════════
# ★母體地板：印出【這一輪有幾列 false】—— 0 的話這一格會在「什麼都能做」的世界裡恆綠。
func _test_p2_every_false_has_a_reason() -> void:
	print("\n── P2 每一列 false 都有原因 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	# 造一個「幾乎每一條都不可做」的狀態：沒錢、準備值低、同勢力、對方人多
	ResourceBank.set_amt(pt, "coin", 0.0, "bed_fixture")
	pt.readiness = 0.0
	var tgt: TeamData = st.teams.get(tid)
	tgt.faction_id = pt.faction_id
	AnonTierSystem.add_anon(tgt, AnonCohort.TIER_PLEB, 30)
	var rows: Array = cs.get_action_availability(st, tid)
	var n_false: int = 0
	var empty_reason: Array = []
	for r in rows:
		if not bool(r.get("enabled", true)):
			n_false += 1
			if String(r.get("disabled_reason", "")).strip_edges() == "":
				empty_reason.append(String(r.get("action_id", "")))
		print("   %-18s enabled=%-5s｜%s" % [String(r.get("action_id", "")),
			str(r.get("enabled", "?")), String(r.get("disabled_reason", ""))])
	print("   ★本輪 false ＝ %d 列（0 的話本格恆綠）" % n_false)
	_check("★母體地板：本輪真的有 false 的列（%d）" % n_false, n_false > 0)
	_check("★★★每一列 false 的 `disabled_reason` 都非空（空的：%s）" % str(empty_reason),
		empty_reason.is_empty())
	_cell("_test_p2_every_false_has_a_reason")


# ══ P4：舊介面 ★只差那個具名排除（誠實限 1）══════════════════════════════════
# ★spec 的字面是「逐字相同」，而藍圖④要求 STUB 不列 ⇒ 兩者衝突。
#   本格照藍圖做並把**差集印出來**：差集只准是那個具名排除。
func _test_p4_old_view_differs_only_by_the_named_exclusion() -> void:
	print("\n── P4 舊介面只差具名排除 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	ResourceBank.set_amt(pt, "coin", 9999.0, "bed_fixture")   # ★讓 coin 條件過（否則差集恆空）
	pt.readiness = 1.0
	var derived: Array = cs.get_available_actions(st, tid)
	var enabled_from_rows: Array = []
	for r in cs.get_action_availability(st, tid):
		if bool(r.get("enabled", false)):
			enabled_from_rows.append(String(r.get("action_id", "")))
	print("   衍生檢視 ＝ %s" % str(derived))
	print("   全列版 enabled ＝ %s" % str(enabled_from_rows))
	_check("★★衍生檢視逐字等於全列版的 enabled 那些（含順序）",
		str(derived) == str(enabled_from_rows))
	# ★★★差集的判準（第一版寫錯了，紀錄留著）：我原本斷言「差集 ＝ 具名排除」，
	#   而那要求**每一條條件都過** —— 我的佈置只給了 coin 與 readiness，
	#   沒有給人口 1.5 倍與自家據點 ⇒ 差集實測是
	#   `["demand_tribute", "recruit", "invite_settle"]` ⇒ 紅。
	#   ★而那個紅【不是產品的錯，是我的判準把「條件沒過」與「被排除」混成一件事】。
	#   ⇒ 正確的不變量：**差集 ＝ 具名排除 ∪ 這一輪 enabled=false 的那些**，
	#     而且兩者不重疊、聯集剛好等於差集（三數相加的形狀）。
	#   ⇒ ★★它比原版強：它把差集的每一個成員都要求【說得出理由】——
	#     一個名字憑空從衍生檢視裡消失（既不是 stub、也沒有 reason）就會紅。
	var rows_all: Array = cs.get_action_availability(st, tid)
	var disabled_ids: Array = []
	for r2 in rows_all:
		if not bool(r2.get("enabled", false)):
			disabled_ids.append(String(r2.get("action_id", "")))
	var missing_vs_const: Array = []
	for n in PlayerCommandSystem.TEAM_TARGET_ACTIONS:
		if not derived.has(String(n)):
			missing_vs_const.append(String(n))
	var unexplained: Array = []
	for m in missing_vs_const:
		if PlayerCommandSystem.STUB_NOT_IMPLEMENTED.has(String(m)):
			continue
		if disabled_ids.has(String(m)):
			continue
		unexplained.append(String(m))
	print("   ★與常數的差集 ＝ %s" % str(missing_vs_const))
	print("     其中【具名排除】＝ %s｜【這一輪條件沒過】＝ %s" % [
		str(PlayerCommandSystem.STUB_NOT_IMPLEMENTED), str(disabled_ids)])
	print("     ⇒ 無法解釋的（既不是排除、也沒有 reason）＝ %s" % str(unexplained))
	_check("★★★差集的每一個成員都說得出理由（無法解釋的：%s）" % str(unexplained),
		unexplained.is_empty())
	_check("★具名排除真的在差集裡（否則這一格測不到 STUB 那一半）",
		PlayerCommandSystem.STUB_NOT_IMPLEMENTED.all(func(x): return missing_vs_const.has(String(x))))
	print("   ★★而 spec P4 的字面是「逐字相同」⇒ 本格把它講準成【差集的每個成員都有理由】，")
	print("     不是把 P4 放寬：一個名字憑空消失（無排除、無 reason）就紅。")
	_cell("_test_p4_old_view_differs_only_by_the_named_exclusion")


# ~~負對照：把具名排除拿掉（STUB 又被列）⇒ 本格與 P1 連動紅（2026-10-01 實測紅）~~
#   ★劃掉不刪：那一道確實紅過，而【排除清單現在是空的】（待裁，理由見 player_command_system）
#   ⇒ 它現在沒有母體可打 ⇒ 不算在棘輪地板裡；清單一有名字就把這一行的刪節線去掉。
# ══ P5：★STUB 不在列，而排除【就地具名寫了理由】＋措辭不得讓人讀成「停用」═══════
func _test_p5_stub_not_listed() -> void:
	print("\n── P5 STUB 不在列 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	ResourceBank.set_amt(pt, "coin", 9999.0, "bed_fixture")   # ★錢夠 ⇒ 舊版本來會列 recruit
	var tid: int = _target(st, pt)
	var ids: Array = []
	for r in cs.get_action_availability(st, tid):
		ids.append(String(r.get("action_id", "")))
	print("   全列版的名字：%s" % str(ids))
	_check("★母體地板：錢是夠的（否則「不列」可能只是條件沒過）",
		float(pt.resources.get("coin", 0)) >= PlayerCommandSystem.RECRUIT_COST_ANON)
	# ★★★【本格的主詞改了，理由在 code 裡】（2026-10-01）：藍圖④照字面做會把
	#   記名招募門死（`recruit` 是招募子選單的唯一開啟點，見 player_command_system 的註解）
	#   ⇒ 排除清單目前刻意留空、機制留著 ⇒ 本格守的是【機制接電】而不是「recruit 不在列」：
	#     排除清單裡的每一個名字都不在列（清單空 ⇒ 這一條恆真而**無害**，
	#     因為下面那一條在守清單本身不是靜態寫死的）。
	for ex in PlayerCommandSystem.STUB_NOT_IMPLEMENTED:
		_check("★★排除清單裡的 `%s` 真的不在列" % String(ex), not ids.has(String(ex)))
	print("   排除清單目前 ＝ %s（★空的是【待裁】不是忘了：理由寫在 player_command_system 那個 const 上方）"
		% str(PlayerCommandSystem.STUB_NOT_IMPLEMENTED))
	_check("★★★機制是接電的：全列版真的會讀那個清單（靜態證：函式體裡逐字出現 `STUB_NOT_IMPLEMENTED`）",
		_code_only(_func_body(FileAccess.get_file_as_string(
			"res://scripts/simulation/player_command_system.gd"),
			"func get_action_availability(state: WorldState, target_id: int) -> Array:")
		).contains("STUB_NOT_IMPLEMENTED"))
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	# ★措辭那一條（reviewer 要求）：**只在清單非空時才適用** ——
	#   清單空的時候沒有任何名字被排除，去要求一句排除理由是在守一件不存在的事
	#   （那會變成「恆紅到期」那一族）。★而清單一有名字，這一條就會回來守它。
	if PlayerCommandSystem.STUB_NOT_IMPLEMENTED.is_empty():
		print("   ★排除清單是空的 ⇒ 措辭那一條【本輪不適用】（清單一有名字就會回來守）")
	else:
		var near: bool = false
		for i2 in range(src.split("
").size()):
			var ln: String = src.split("
")[i2]
			if ln.contains("STUB_NOT_IMPLEMENTED") and ln.contains("const"):
				for k2 in range(maxi(0, i2 - 20), i2 + 2):
					if src.split("
")[k2].contains(SPEC_STUB_WORDING):
						near = true
		print("   排除的理由裡有「%s」這個措辭 ＝ %s" % [SPEC_STUB_WORDING, str(near)])
		_check("★★措辭是「%s」而不是模糊語（★reviewer：別讓人讀成「停用／暫停」）" % SPEC_STUB_WORDING,
			near)
	_cell("_test_p5_stub_not_listed")


# 負對照：把 readiness 條件複製回查詢面 ⇒ 本格紅（`0.7` 在查詢面 1 次） ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ══ P7：★★★條件只有一份（spec §6④；P1 守名字，本格守條件）═══════════════════
# 那三個條件的字面在【查詢面】必須 0 次、在全列版必須各 1 次。
func _test_p7_conditions_have_a_single_holder() -> void:
	print("\n── P7 條件只有一份 ──")
	var q: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_query_api.gd"))
	var pcs: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var body: String = _code_only(_func_body(pcs,
		"func get_action_availability(state: WorldState, target_id: int) -> Array:"))
	_check("★母體地板：抓到全列版的函式體", body.length() > 0)
	for lit in SPEC_CONDITION_LITERALS:
		var in_q: int = q.count(String(lit))
		var in_body: int = body.count(String(lit))
		print("   條件字面 `%s`：查詢面 %d 次｜全列版 %d 次" % [String(lit), in_q, in_body])
		_check("★★★`%s` 在查詢面 0 次（它是第二份的入口）" % String(lit), in_q == 0)
		_check("★`%s` 在全列版至少 1 次（唯一持有者）" % String(lit), in_body >= 1)
	# ★★★【判斷的單一源】（systems 裁 2026-10-01 P10）——
	#   `encounter_active` 在整支 `player_command_system.gd` 裡恰好出現一次（共用前置檢查裡）
	#   ⇒ ★它比「措辭只有一份」硬：**要繞過它必須真的再讀一次 state**
	#     （措辭可以被改寫成同義句而逃掉，判斷不行）。
	#   ★★而這裡**不剝註解**也不會誤判，因為錨是一個識別符而不是一句人話 ——
	#     ⇒ 所以要用 `_code_only()`：如果有人在註解裡提到它，那一行不該被算進來。
	# ★★★★【行號要是真的】：`_code_only()` 把註解那幾行**整行刪掉**
	#   ⇒ 在它的輸出上數行號會**位移** ⇒ 印出來的 `file:line` 指到錯的行。
	#   ⇒ 所以這裡走**原始行**、就地跳過整行註解 ⇒ 行號留在原本的坐標系裡。
	#   ★誠實限：**行尾註解**跳不掉（`code  # …提到那個字…`）⇒ 失效方向是【多算】
	#     ⇒ 它會誤報一個違規（吵但不靜默），不會把一個真違規藏起來。
	var pcs_src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var enc_hits: Array = []
	var ln: int = 0
	for line in pcs_src.split("\n"):
		ln += 1
		if String(line).strip_edges().begins_with("#"):
			continue
		if String(line).contains("encounter_active"):
			enc_hits.append("player_command_system.gd:%d" % ln)
	print("   `encounter_active`（剝掉註解之後）在全列版那一支檔裡 %d 處：%s" % [
		enc_hits.size(), str(enc_hits)])
	_check("★★★母體地板：印出命中的 file:line（空清單 ⇒ 那個 %d 可能是「它根本不在了」）"
		% enc_hits.size(), enc_hits.size() > 0)
	_check("★★★★判斷的單一源：`encounter_active` 恰好 %d 處（實測 %d）" % [
		SPEC_ENCOUNTER_FIELD_HITS, enc_hits.size()],
		enc_hits.size() == SPEC_ENCOUNTER_FIELD_HITS)
	# ── ★★★★★【②兩個呼叫點都呼到同一支】（spec §2③ 第二件）────────────────────
	#   ★①（上面那條）答的是「判斷只有一份」；★②答的是「**那一份真的被每個人用到**」
	#     —— 兩者是獨立的：一支共用函式可以存在而某個消費者自己又判一次
	#     （那時 ① 會紅）；也可以沒有人呼它（那時 ① 綠而 ② 紅）。
	#   ★★而斷言打在【函式體】上：檔案層級的「這個檔有呼它」會把
	#     「守衛宣稱保護某支函式而從來沒呼那支函式」那一族放過去。
	var consumer_miss: Array = []
	for cname in SPEC_ENC_CONSUMERS:
		var fb: String = _func_body(pcs_src, "func %s(" % String(cname))
		if fb == "":
			consumer_miss.append("%s（★抓不到函式體 —— 名字改了？）" % String(cname))
			continue
		var n_call: int = _code_only(fb).count(SPEC_ENC_GATE + "(")
		print("   消費者 %-32s 呼 `%s(` %d 次" % [String(cname), SPEC_ENC_GATE, n_call])
		if n_call < 1:
			consumer_miss.append("%s（0 次）" % String(cname))
	_check("★母體地板：消費者清單不是空的（空 ⇒ 下面那條恆綠）", SPEC_ENC_CONSUMERS.size() > 0)
	_check("★★★★★②每一個宣告的消費者都【真的呼到那一支】（沒呼到的：%s）" % str(consumer_miss),
		consumer_miss.is_empty())
	# ── ★★★反向掃：沒宣告卻【自己判同一件事】的 ──────────────────────────────
	#   ★具名清單解決「數字對而東西不在」，不解決「我沒看到的那些」
	#     ⇒ 反向掃的母體要從 code 數出來印在卷面。
	#   ★★這裡掃的特徵 ＝ 函式體裡出現 `encounter_active` 而它不是那支共用函式
	#     ⇒ 它就是「自己又讀了一次 state」。
	var self_judges: Array = []
	var scanned_funcs: int = 0
	var cur: String = ""
	for line2 in pcs_src.split("\n"):
		var t2: String = String(line2)
		if t2.begins_with("func "):
			cur = t2.substr(5, maxi(0, t2.find("(") - 5))
			scanned_funcs += 1
			continue
		if t2.strip_edges().begins_with("#"):
			continue
		if t2.contains("encounter_active") and cur != SPEC_ENC_GATE:
			self_judges.append(cur)
	print("   ★反向掃：掃了 %d 支函式｜自己讀 `encounter_active` 而不是那支共用函式的：%s" % [
		scanned_funcs, str(self_judges)])
	_check("★★母體地板：反向掃真的掃到函式（%d；0 ⇒ 下面那條恆綠）" % scanned_funcs,
		scanned_funcs > 0)
	_check("★★★★★③沒有人自己再判一次（違反的：%s）—— 這一條才讓「共用」是真的，"
		% str(self_judges) + "而不是「兩邊剛好同值」", self_judges.is_empty())
	print("   ★而本格比 P1 更接近「一個真相一份」的本體：名字漂開看得出來，")
	print("     條件漂開只會讓【選單說可以而 handler 說不行】，那在卷面上是沉默的。")
	_cell("_test_p7_conditions_have_a_single_holder")


# ══ P8：★母體邊界 —— 說得出本票涵蓋 22 個呼叫點裡的哪幾個（§7）═══════════════
func _test_p8_envelope_boundary() -> void:
	print("\n── P8 母體邊界（兩份同形信封）──")
	var q_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_query_api.gd")
	var m_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_api_mapper.gd")
	var q_sites: int = _code_only(q_raw).count("map_available_action(")
	var m_sites: int = 0
	for l in _code_only(m_raw).split("\n"):
		if l.contains("_make_item_action(") and not l.contains("static func"):
			m_sites += 1
	print("   `map_available_action` 呼叫點（查詢面）＝ %d｜`_make_item_action`（庫存）＝ %d" % [
		q_sites, m_sites])
	print("   ★本票涵蓋的是【團隊目標動作】那一條路：原本 4 處（1 啟用 ＋ 3 停用）")
	print("     ⇒ 現在收成 1 個迴圈（可做與不可做都由全列版產生）")
	print("   ★★不在本票：庫存那 %d 處（另一個信封）／自家隊 11 個／格動作（界線不可機械讀）" % m_sites)
	print("     ⇒ 後兩者已就地具名標記並登 defer（no-source-constant／unreadable-boundary）")
	_check("★查詢面的呼叫點數 ＝ spec 記的 %d（刪掉三處停用列之後）" % SPEC_ENVELOPE_SITES_QUERY,
		q_sites == SPEC_ENVELOPE_SITES_QUERY)
	_check("★★庫存那個信封的呼叫點數 ＝ %d（不在本票，但母體要數得到它）" % SPEC_ENVELOPE_SITES_ITEM,
		m_sites == SPEC_ENVELOPE_SITES_ITEM)
	var marks: int = 0
	# ★★★★★【2 → 1】（2026-10-01，本票 §3③／P6）——
	#   `no-source-constant: own-team-actions` 那個錨**已經不該在**：
	#   它錨的病是「這一類沒有來源常數」，而本票立了 `ACTION_SHAPE`
	#   ⇒ 那行標記住在被收成迴圈的那 11 段裡 ⇒ 隨之消失 ⇒ 那條 defer 的 met_check 自己翻真
	#   ⇒ 已移進 `docs/process/defers.tsv` 的「已解除」區（同一顆 commit）。
	#   ★★而**先紅的是這一條**（1／2）—— 它比我先發現那個錨不見了，
	#     所以這裡改成 1／1 是【基準更新】不是弱化。
	#   ★★★`unreadable-boundary: tile-actions`（defer 306）**不動**：
	#     它的解除條件是「宣告與**行為**對齊」，而本票不動行為（spec §3③ 逐字）。
	for mark in ["unreadable-boundary: tile-actions"]:
		if q_raw.contains(mark):
			marks += 1
	print("   兩個具名標記都在 ＝ %s（defer 的 met_check 錨在它們上面）" % str(marks == 2))
	_check("★★★那一個還該在的 defer 錨在（%d／1；306 的解除條件是行為對齊，本票不動行為）" % marks,
		marks == 1)
	_cell("_test_p8_envelope_boundary")


# ★把「這一輪前提不成立」那一堆盡量拉回母體 —— ★★佈置要走【真實入口】並【印出它生效了】，
#   否則「世界沒變」可能只是因為它一開頭就被擋掉（那是運氣不是佈置）。
# ★★★而有些動作有一個【選擇維度】（打聽要選問哪一題）⇒ 同一個動作的不同選擇會走到不同結果
#   ⇒ `variant` 就是那個維度；回 false ＝ 這個變體不存在（呼叫端的迴圈到此為止）。
func _arm_for(action: String, st: WorldState, pt: TeamData, tid: int, variant: int) -> bool:
	match action:
		"confirm_gather_intel":
			var tgt: TeamData = st.teams.get(tid if tid != -1 else _target(st, pt))
			if tgt == null:
				return false
			# ★★★母體：tick 0 的世界【沒有人知道任何事】（`BeliefSystem.known_targets`
			#   與 `state.team_known` 都是空的）⇒ 每一題都會回「他也不知道」、寫入 0
			#   ⇒ ★那會讓 P10 把它報成「漏宣告」，而真相是**我的世界太年輕**。
			#   ⇒ 所以先把世界推到有人知道事情為止，並【印出佈置生效了】。
			if int(st.world.current_tick) < 1:
				var runner := SimRunner.new()
				for _i in range(ARM_TICKS_FOR_KNOWLEDGE):
					runner.advance_tick(st, pt.tile_pos)
				var kn: int = BeliefSystem.known_targets(st, tgt.team_id).size()
				var ev: int = (st.team_known.get(tgt.team_id, []) as Array).size()
				print("     [佈置] 推 %d tick 之後：被問方知道 %d 支隊、記得 %d 條事件"
					% [ARM_TICKS_FOR_KNOWLEDGE, kn, ev])
			var opts: Array = InquirySystem.new().get_options(st, pt, tgt)
			if variant >= opts.size():
				return false
			st.player_state["gather_intel_npc_id"] = tgt.team_id
			st.player_state["gather_intel_choice"] = String(opts[variant].get("id", ""))
			return true
		"take_loot":
			if variant > 0:
				return false
			var other: int = _target(st, pt)
			if other == -1:
				return false
			st.last_encounter_result = {
				"winner_id": pt.team_id, "loser_id": other,
				"loot_pool": {"coin": 10.0},
			}
			return true
		_:
			return variant == 0

# ── P9／P10 共用：呼一個動作，回 [結果, 世界有沒有變] ─────────────────────────
#   ★「世界有沒有變」用 `StateFingerprint.compute`（專案的正規世界摘要）。
#   ★★誠實限：fp 只涵蓋它涵蓋的欄位（teams／persons／factions／belief／tiles／world／player_*）
#     ⇒ 陰性**不等於**「絕對什麼都沒動」；所以再加一個獨立軸：coin 總額（`CoinAudit.total`）。
#     兩個軸都沒動才算「不改世界」——★而這一點就是負對照要打的地方（讓入口寫一個欄位 ⇒ 必紅）。
# ★★★`via_target` ＝ 這個名字來自【第二套分派表】⇒ 要走 `execute_action_with_target`。
#   ★第一版沒有這一半 ⇒ `recruit_named` 回「未知行動」被我記成「不適用」，
#     而那個理由是【我用錯入口】不是【它的性質】—— 正是我自己在 P10 分開過的那兩件事，
#     同一輪我在另一行又混了一次。
func _call_once(action: String, variant: int = 0, via_target: bool = false) -> Array:
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	ResourceBank.set_amt(pt, "coin", 9999.0, "bed_fixture")
	pt.readiness = 1.0
	var tid: int = -1
	if via_target or PlayerCommandSystem.TEAM_TARGET_ACTIONS.has(action):
		tid = _target(st, pt)
	if not _arm_for(action, st, pt, tid, variant):
		return [{}, false, false, false, false]
	var fp0: String = StateFingerprint.compute(st)
	var coin0: float = CoinAudit.total(st)
	var r: Dictionary = {}
	if via_target:
		# 第二套分派表吃完整 target dict（member kind）
		var tgt2: TeamData = st.teams.get(tid)
		var mid: int = -1
		if tgt2 != null:
			for pid in tgt2.named_members:
				if int(pid) != tgt2.leader_id:
					mid = int(pid)
					break
		r = cs.execute_action_with_target(st, action, {
			"kind": "member", "team_id": tid, "member_id": mid,
			"tile_q": -1, "tile_r": -1,
		})
	else:
		r = cs.execute_action(st, tid, action)
	var fp1: String = StateFingerprint.compute(st)
	var coin1: float = CoinAudit.total(st)
	var changed: bool = (fp0 != fp1) or (absf(coin1 - coin0) > 0.000001)
	return [r, changed, fp0 != fp1, absf(coin1 - coin0) > 0.000001, true]

# 本檔裡【回 payload 的函式】→ 它在 registry 裡的動作名（回不在 registry 的就是空）
func _payload_functions(src: String) -> Dictionary:
	var out: Dictionary = {}
	var cur: String = ""
	for l in src.split("
"):
		var t: String = l.strip_edges()
		if t.begins_with("#"):
			continue
		if l.begins_with("func ") or l.begins_with("static func "):
			var head: String = l.replace("static func ", "").replace("func ", "")
			cur = head.split("(")[0]
		if t.contains("\"payload\"") and cur != "":
			out[cur] = int(out.get(cur, 0)) + 1
	return out

# 取某一支【具名函式】的函式體（不用寫完整簽章）
func _body_of(src: String, fname: String) -> String:
	var i: int = src.find("func " + fname + "(")
	if i < 0:
		return ""
	var rest: String = src.substr(i)
	var j: int = rest.find("
func ")
	return rest if j < 0 else rest.substr(0, j)

# registry 的 (動作名 → handler 函式名) 對
# ★★★範圍要切（reviewer 2026-10-01 抓到）：第一版**裸掃整個檔案** ⇒ 多吞兩條
#   `"action": _fe_action`／`"response_label": _label_pre`（它們在 `respond_to_forced`
#   組信封那一段的字面 dict 裡，跟分派表完全無關）⇒ 印 53 而 `_setup_registry` 實際只有 51。
#   ★這一次僥倖沒撞上本輪追蹤的 9 支函式名 ⇒ **沒有腐蝕分類**，而它下一次會。
#   ⇒ 比照同床已經在用的 `_eawt_arms()` 手法：用 `_body_of` 切到那支函式體再掃。
# 負對照：把本支的範圍限定拿掉（裸掃整檔）⇒ 條數變大、多吞兩對區域變數 ⇒ 本格紅（多吞的：["action → _fe_action", "response_label → _label_pre"]） ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ★★而「多吞」要有自己的守衛（見 P10 那兩條地板下面新增的那一條）：
#   舊的兩條地板只擋【少吞】（回 0），而**多吞正是實際發生的方向** ——
#   ★★★一個偵測器會往兩個方向錯，而只擋一個方向的地板在另一個方向上是沉默的。
func _registry_pairs(src: String) -> Array:
	var body: String = _body_of(src, "_setup_registry")
	var pairs: Array = []
	for l in body.split("
"):
		var t: String = l.strip_edges()
		if t.begins_with("#") or not t.begins_with("\"") or not t.ends_with(","):
			continue
		var parts: Array = t.split("\"")
		if parts.size() < 3:
			continue
		var rhs: String = String(parts[2]).replace(":", "").replace(",", "").strip_edges()
		if rhs.begins_with("_"):
			pairs.append([String(parts[1]), rhs])
	return pairs

# ★只為卷面：**裸掃整個檔案**的版本（不參與分類）—— 它存在的唯一理由是讓
#   「限定範圍」與「不限定」的差距**每一次跑都印出來**，而不是寫在註解裡讓人自己相信。
func _registry_pairs_naked(src: String) -> Array:
	var pairs: Array = []
	for l in src.split("
"):
		var t: String = l.strip_edges()
		if t.begins_with("#") or not t.begins_with("\"") or not t.ends_with(","):
			continue
		var parts: Array = t.split("\"")
		if parts.size() < 3:
			continue
		var rhs: String = String(parts[2]).replace(":", "").replace(",", "").strip_edges()
		if rhs.begins_with("_"):
			pairs.append([String(parts[1]), rhs])
	return pairs

# ★★★【可達性要追到底】—— reviewer 2026-10-01 抓到的：`establish_faction` 被我分進
#   「不可經由 action id 抵達」那一堆，而**那個理由是假的**：registry 指到
#   `_action_establish_faction_cmd`（:188），而它下一行就 `return establish_faction(state)`
#   ⇒ 玩家真的按得到。★我只追了一層（registry 的右手邊），沒追委派。
#   ⇒ 本支回【直接 ∪ 一層委派】；★★而一個假的具名理由比沒有理由更糟：
#     那一堆是我自己寫的「不適用」桶，而它會把東西吞掉而卷面上看起來已經解釋過了。
func _reachable_names(src: String, fn: String) -> Array:
	var direct: Array = []
	for pr in _registry_pairs(src):
		if String(pr[1]) == fn:
			direct.append(String(pr[0]))
	if not direct.is_empty():
		return direct
	var via: Array = []
	for pr2 in _registry_pairs(src):
		var body: String = _code_only(_body_of(src, String(pr2[1])))
		if body != "" and body.contains(fn + "("):
			via.append(String(pr2[0]))
	# ★★★【第二套分派表】—— 2026-10-01 我自己核 reviewer 那一族的剩餘成員時抓到的：
	#   `_recruit_named_internal` 也按得到，而它走的是 `execute_action_with_target` 的
	#   `match action:`（`player_command_system.gd:1560` 附近），**不是** `_setup_registry`。
	#   ⇒ ★所以「動作名 → handler」有【兩套】機制，而我第一版只查了一套
	#     ⇒ 桶裡那一行的診斷對它也是假的（與 reviewer 抓到的 `establish_faction` 同族、不同機制）。
	for arm in _eawt_arms(src):
		if String(arm[1]).contains(fn + "("):
			via.append(String(arm[0]))
	return via

# 第二套分派表的 (動作名 → 那一臂的原文)
func _eawt_arms(src: String) -> Array:
	var body: String = _code_only(_body_of(src, "execute_action_with_target"))
	var arms: Array = []
	var cur_name: String = ""
	var cur_text: String = ""
	for l in body.split("
"):
		var t: String = l.strip_edges()
		if t.begins_with("\"") and t.ends_with("\":"):
			if cur_name != "":
				arms.append([cur_name, cur_text])
			cur_name = t.substr(1, t.length() - 3)
			cur_text = ""
		elif cur_name != "":
			cur_text += l + "
"
	if cur_name != "":
		arms.append([cur_name, cur_text])
	return arms


# 負對照：讓一個宣告過的入口寫一個欄位（`pt.readiness = 0.123`）⇒ 本格紅 ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ══ P9：★行為證 —— 每一個【宣告過的入口】呼它前後世界不變（systems 裁 (b)）══════
# ★母體 ＝ `SUBMENU_OPENERS`（宣告在一處）；地板：它不得是空的（空 ⇒ 本格恆綠）。
func _test_p9_declared_openers_are_pure() -> void:
	print("
── P9 宣告過的入口呼它前後世界不變 ──")
	print("   宣告 ＝ %s（母體 %d）" % [
		str(PlayerCommandSystem.SUBMENU_OPENERS), PlayerCommandSystem.SUBMENU_OPENERS.size()])
	_check("★母體地板：宣告不是空的（空 ⇒ 本格恆綠）",
		not PlayerCommandSystem.SUBMENU_OPENERS.is_empty())
	for op in PlayerCommandSystem.SUBMENU_OPENERS:
		var act: String = String(op)
		var got: Array = _call_once(act)
		var r: Dictionary = got[0]
		print("   %-16s ok=%-5s｜世界變了=%-5s（fp 變=%s／coin 變=%s）｜%s" % [
			act, str(r.get("ok", "?")), str(got[1]), str(got[2]), str(got[3]),
			String(r.get("msg", "")).substr(0, 40)])
		# ★★★前提要自己證明：入口必須【真的被呼到而且成功回菜單】——
		#   ok=false 的話「世界沒變」可能只是因為它一開頭就被擋掉（那是運氣不是佈置）。
		_check("★%s 真的回了菜單（ok=true；false ⇒ 下一條的陰性沒有主詞）" % act,
			bool(r.get("ok", false)))
		_check("★★★%s 呼它前後世界不變（fp ＋ coin 兩個軸）" % act, not bool(got[1]))
		_check("★%s 真的回了 payload（它是入口 ⇒ 下一層的內容要在回傳裡）" % act,
			r.has("payload"))
	_cell("_test_p9_declared_openers_are_pure")


# 負對照：把 `gather_intel` 從 `SUBMENU_OPENERS` 拿掉 ⇒ 本格必須指名它（指名：["gather_intel"]） ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ══ P10：★★★反向掃 —— 沒有宣告而回 payload 的，逐列問「它改世界嗎」（systems 裁 (c)）══
# ★這一格才是「漏宣告不再是靜默的」那一半：(a)+(b) 只能守住已經宣告的那些，
#   而 2026-10-01 漏掉的那一個（`gather_intel`）正是**沒有被宣告**的那一個。
# ★★母體從 code 數出來印在卷面（不是從信裡抄）。
func _test_p10_reverse_sweep_payload_without_declaration() -> void:
	print("
── P10 反向掃：回 payload 而沒有宣告的 ──")
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var fns: Dictionary = _payload_functions(src)
	var sites: int = 0
	for k in fns.keys():
		sites += int(fns[k])
	print("   回 `payload` 的函式 %d 支／呼叫點 %d 處：%s" % [fns.size(), sites, str(fns.keys())])
	_check("★母體地板：真的數到回 payload 的路（0 ⇒ 掃描器壞了，不是沒有）", sites > 0)
	_check("★呼叫點數 ＝ 今天量到的 %d（對不上 ⇒ 有人加了一條路 ⇒ 回來看它該不該宣告）"
		% SPEC_PAYLOAD_SITES, sites == SPEC_PAYLOAD_SITES)
	var declared: Array = []
	var must_change: Array = []
	var must_change_fns: Array = []
	var not_reachable: Array = []
	# ★★★分堆的單位是【函式】不是【名字】：一支函式可以對到多個動作名
	#   ⇒ 拿名字數去跟函式數相加會紅，而那個紅跟缺陷無關（reviewer 2026-10-01 之後改）。
	for fn in fns.keys():
		var names: Array = _reachable_names(src, String(fn))
		if names.is_empty():
			# ★★★桶名只講【判準看到了什麼】，不講【世界是什麼】（systems 裁 2026-10-01）：
			#   「不是一個玩家可以按的 action id」是對世界的斷言，而它**曾經是假的**
			#   ⇒ ★一句假的診斷比一個紅更毒：沒有人會來推翻它，而下一個人會拿它當前提。
			not_reachable.append("%s（判準看到的：兩套分派表的字面裡都沒有它，兩套裡的 handler 函式體也沒有呼它）"
				% String(fn))
			continue
		var is_decl: bool = false
		for n in names:
			if PlayerCommandSystem.SUBMENU_OPENERS.has(String(n)):
				is_decl = true
		if is_decl:
			declared.append("%s → %s" % [String(fn), str(names)])
		else:
			must_change_fns.append(String(fn))
			for n2 in names:
				if not must_change.has(String(n2)):
					must_change.append(String(n2))
	print("   ── 分三堆（相加 ＝ 函式數）──")
	print("   ①已宣告成入口 ＝ %s" % str(declared))
	print("   ②沒宣告 ⇒ 必須改世界 ＝ %s" % str(must_change))
	print("   ③不可經由 action id 抵達 ＝ %d 支" % not_reachable.size())
	for nr in not_reachable:
		print("     · %s" % String(nr))
	# ★★★就地誠實限（systems 裁 2026-10-01：把已知盲點寫在產出它的那一行旁邊，
	#   比一個沉默的正確更有用）——
	var n_reg: int = _registry_pairs(src).size()
	var n_arm: int = _eawt_arms(src).size()
	print("     ★這一堆的意思【不等於】玩家按不到它：抽取式只認得【字面】分派，")
	print("       而它認得的是兩套 —— `_setup_registry` 的 dict（%d 條）" % n_reg)
	print("       ＋ `execute_action_with_target` 的 match 臂（%d 條），各加一層委派。" % n_arm)
	print("       ★★兩個血證：`establish_faction` 經一行委派按得到（reviewer 2026-10-01 抓到，")
	print("         我第一版把它分進這一堆而理由是假的）；`_recruit_named_internal` 走第二套")
	print("         分派表（我核剩餘成員時抓到）⇒ **同一族、兩個不同機制**。")
	print("     ★★★仍然看不到的：執行期組出來的字串分派、或第三套分派表 ——")
	print("       那時這一堆會多一個成員而理由**看起來還是對的**（它只說判準沒看到）。")
	_check("★母體地板：第一套分派表非空（%d 條；0 ⇒ 抽取式壞了）" % n_reg, n_reg > 0)
	_check("★母體地板：第二套分派表非空（%d 條；0 ⇒ 抽取式壞了，而那會讓這一堆多吞成員）"
		% n_arm, n_arm > 0)
	# ★★★另一個方向的地板（reviewer 2026-10-01：舊的兩條只擋【少吞】，
	#   而多吞正是實際發生的方向）—— 抽到的每一個 handler 名字都要真的是本檔的一支函式。
	#   ★`"response_label": _label_pre` 那一類（區域變數／無關字面 dict）會被這一條咬住。
	var not_a_func: Array = []
	for pr3 in _registry_pairs(src):
		if not src.contains("func " + String(pr3[1]) + "("):
			not_a_func.append("%s → %s" % [String(pr3[0]), String(pr3[1])])
	# ★★★(c) 血證與【那句運氣】要印在卷面上（systems 裁 2026-10-01）——
	#   因為「寫在註解裡」的東西不會被讀，而一個沒有記下運氣的數字會被讀成「這個抽取式沒問題」。
	var naked: Array = _registry_pairs_naked(src)
	var over: Array = []
	for pn in naked:
		var found: bool = false
		for ps in _registry_pairs(src):
			if String(ps[0]) == String(pn[0]) and String(ps[1]) == String(pn[1]):
				found = true
		if not found:
			over.append("%s → %s" % [String(pn[0]), String(pn[1])])
	print("     ★★血證（reviewer 2026-10-01）：裸掃整個檔案 %d 條／限定 `_setup_registry` 之後 %d 條"
		% [naked.size(), n_reg])
	print("       ⇒ 多吞的 %d 對，具名：%s（:1163／:1166 附近，"
		% [over.size(), str(over)] + "它們是 `respond_to_forced` 組信封時的區域變數名）")
	print("     ★★★而【這次沒有腐蝕紅綠是運氣】：那兩個 RHS 剛好不等於本輪追蹤的 9 支目標函式名。")
	print("       ⇒ 運氣要寫在卷面上，否則下一個人會把它讀成「這個抽取式沒問題」。")
	print("     ★多吞方向：抽到的 handler 名字裡【不是本檔函式】的 ＝ %s" % str(not_a_func))
	_check("★★★抽取式沒有多吞（每一個抽到的 handler 都是本檔的一支函式；多吞的：%s）"
		% str(not_a_func), not_a_func.is_empty())
	# ★分母是【函式數】：declared／not_reachable 各存一支函式一列，
	#   而 must_change 存的是【動作名】（去重）⇒ 相加要用「被分過堆的函式數」。
	var classified: int = declared.size() + not_reachable.size() + must_change_fns.size()
	_check("★★逐函式分三堆相加 ＝ 回 payload 的函式數（%d ＋ %d ＋ %d ＝ %d／%d）" % [
		declared.size(), must_change_fns.size(), not_reachable.size(),
		classified, fns.size()], classified == fns.size())
	# ★★★逐列問：沒宣告的那些，呼它【成功】的時候世界必須真的變。
	#   不變 ⇒ 它其實是一個入口而沒有人宣告 ⇒ 紅並**指名**。
	var leaked: Array = []
	var na: Array = []
	# ★★★判準的第三格（2026-10-01 實測抓出來的）：`confirm_gather_intel` 的第一個變體
	#   回 ok=true、訊息「他也不知道」、**寫入 0 ⇒ 世界沒變** —— ★那不是漏宣告，
	#   是**成功執行而結果為空**（同「決定 vs 結果要分開講」那一族）。
	#   ⇒ ★所以正確的謂詞不是「這一次改了世界嗎」，是【**存在一個可達結果使它改世界**】。
	#   ⇒ ★★而它不是「試到綠為止」：變體數會印在卷面上，而**全部變體都不改世界**才算漏宣告
	#     —— 那時它就真的是一個沒有人宣告的入口。
	var eawt: Array = []
	for arm2 in _eawt_arms(src):
		eawt.append(String(arm2[0]))
	for m in must_change:
		var act: String = String(m)
		var via_t: bool = eawt.has(act)
		var tried: int = 0
		var changed_any: bool = false
		var last_msg: String = ""
		var last_ok: bool = false
		while true:
			var got: Array = _call_once(act, tried, via_t)
			if not bool(got[4]):
				break
			tried += 1
			var r: Dictionary = got[0]
			last_ok = bool(r.get("ok", false))
			last_msg = String(r.get("msg", ""))
			if last_ok and bool(got[1]):
				changed_any = true
				break
			if tried >= 12:
				break
		print("   %-22s 入口=%-22s 試了 %d 個變體｜曾改世界=%-5s｜ok=%-5s｜%s" % [
			act, "execute_action_with_target" if via_t else "execute_action",
			tried, str(changed_any), str(last_ok), last_msg.substr(0, 36)])
		if tried == 0:
			na.append("%s（一個變體都佈置不起來 ⇒ 沒有主詞）" % act)
			continue
		if not last_ok and not changed_any:
			na.append("%s（%s）" % [act, last_msg.substr(0, 30)])
			continue
		if not changed_any:
			leaked.append(act)
	print("   ★不適用（這一輪前提不成立 ⇒ 沒有主詞，具名）＝ %s" % str(na))
	_check("★母體地板：至少有一支【沒宣告的】真的跑成功了（0 ⇒ 下一條恆綠）",
		must_change.size() - na.size() > 0)
	_check("★★★沒有【回 payload、不改世界、卻沒有宣告】的漏網（指名：%s）" % str(leaked),
		leaked.is_empty())
	print("   ★★而這一格的方向很重要：誤標成入口 ⇒ 玩家以為按下去只是開一層選單，")
	print("     所以判準不是「回 payload」（那只編碼了前半句），是【回 payload 且不改世界】。")
	_cell("_test_p10_reverse_sweep_payload_without_declaration")


# 負對照：在 production 再寫一句同字面（`_negctrl_e_second_copy()` 回同一個 msg）⇒ 本格紅並指名兩處真行號 player_command_system.gd:333／:337 ⇒ 已於 4e50c0ec6（2026-10-01 這一輪） 實測紅
# 負對照：把 `_action_label(act)` 加回信封那一側 ⇒ 本格紅（在這一段 0 次，實測 1） ⇒ 已於 feat/available-actions-full-list（2026-10-01 這一輪） 實測紅
# ══ P11：★label 在這條路上只有【一個生產者】（systems 裁 2026-10-01 ②）════════════
# ★★★為什麼「兩邊都委派到同一張表」不算安全：那只代表它們**今天同值**。
#   兩份生產者可以各自被改（換成別的表、加前綴、加狀態字），而**同源那一刻的相等
#   不是不變量** —— 這正是「比較的兩邊同源 ⇒ 恆真」那一族的鏡像：
#   ★不是判準同源，是【被守的東西】同源，而同源會被人拆開。
# ★★母體邊界：本格只管【團隊目標動作那一條路】（`# Layer 4` 到「具名登記」那一段）。
#   同檔其他幾處 `_action_label` 是自家隊／格動作那幾條路 —— 它們沒有全列版可以拿 label，
#   ★那一側 `_action_label` 就是它們唯一的生產者 ⇒ 不在本格母體（已就地登 defer）。
func _test_p11_label_has_one_producer() -> void:
	print("
── P11 label 只有一個生產者 ──")
	var q_raw: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_query_api.gd")
	var a: int = q_raw.find("# Layer 4: team-level actions against focused team")
	var b: int = q_raw.find("unreadable-boundary: tile-actions")
	_check("★母體地板：真的切到那一段（切不到 ⇒ 下面幾條恆綠）", a >= 0 and b > a)
	var block: String = _code_only(q_raw.substr(a, b - a)) if (a >= 0 and b > a) else ""
	var in_block: int = block.count("action_label")
	var from_row: int = block.count("row2.get(\"label\"")
	var pcs: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var body: String = _code_only(_func_body(pcs,
		"func get_action_availability(state: WorldState, target_id: int) -> Array:"))
	var in_rows: int = body.count("PlayerApiMapper.action_label(")
	print("   這條路上：信封側 `action_label` %d 次｜從列裡拿 label %d 次｜全列版生產 %d 次" % [
		in_block, from_row, in_rows])
	_check("★★★信封那一側【不再生產】label（`action_label` 在這一段 0 次，實測 %d）" % in_block,
		in_block == 0)
	_check("★★信封那一側是【從列裡拿】的（%d 處）" % from_row, from_row >= 1)
	# ★★★★★【那句字面只有一份】（systems 裁 P8／P11）——
	#   母體邊界逐字：`scripts/simulation/` ＋ `scripts/ui/`，**排除 `scripts/debug/`**
	#     ⇒ 床持有外部期望字面是它的【職責】不是重複（不排除的話床自己會污染母體）。
	#   ★★而計數**先剝整行註解**（`_code_only`）：討論一句措辭的註解與使用它的 code
	#     在文字上同形 ⇒ 不剝的話這一格會咬到「解釋這條規則」的那一行。
	#     ★實測血證（2026-10-01）：我自己寫完共用檢查之後 `git grep 非戰鬥中` 回 **2 行**，
	#       而第二行是我**解釋這條規則**的註解 —— 那不是違規。
	#   ★★★母體地板：**印出每一句命中的 file:line** —— 否則「1」可能是【它根本不在了】
	#     （一個看起來剛好的數）。
	var scan_dirs: Array = ["res://scripts/simulation", "res://scripts/ui"]
	var scanned_files: int = 0
	var phrase_hits: Dictionary = {}
	for ph in SPEC_ONE_COPY_PHRASES:
		phrase_hits[String(ph)] = []
	for dpath in scan_dirs:
		var d := DirAccess.open(String(dpath))
		if d == null:
			continue
		d.list_dir_begin()
		var f: String = d.get_next()
		while f != "":
			if f.ends_with(".gd"):
				scanned_files += 1
				# ★走【原始行】而不是 `_code_only()` 的輸出：後者整行刪掉註解
				#   ⇒ 行號會位移 ⇒ 印出來的 `file:line` 指到錯的行（見 P7 那一段的理由）。
				var raw: String = FileAccess.get_file_as_string(String(dpath) + "/" + f)
				var n2: int = 0
				for l2 in raw.split("\n"):
					n2 += 1
					if String(l2).strip_edges().begins_with("#"):
						continue
					for ph2 in SPEC_ONE_COPY_PHRASES:
						if String(l2).contains(String(ph2)):
							(phrase_hits[String(ph2)] as Array).append("%s:%d" % [f, n2])
			f = d.get_next()
		d.list_dir_end()
	print("   掃了 %d 支 .gd（simulation ＋ ui，★排除 debug）" % scanned_files)
	_check("★母體地板：真的掃到檔案（0 ⇒ 下面每一條恆綠）", scanned_files > 0)
	var phrase_bad: Array = []
	for ph3 in SPEC_ONE_COPY_PHRASES:
		var hits: Array = phrase_hits[String(ph3)]
		print("   「%s」⇒ %d 處：%s" % [String(ph3), hits.size(), str(hits)])
		if hits.size() != 1:
			phrase_bad.append("「%s」%d 處：%s" % [String(ph3), hits.size(), str(hits)])
	_check("★★★★那兩句字面在產品側各恰好一行（違反的：%s）" % str(phrase_bad),
		phrase_bad.is_empty())
	_check("★★★生產者恰好一個：全列版裡 `PlayerApiMapper.action_label(` ＝ 1 次（實測 %d）"
		% in_rows, in_rows == 1)
	_cell("_test_p11_label_has_one_producer")





# == P18 ＝ 第三條反向掃 [★★★`listed==false` 的那些要【進得去某一屏】] ===========
# ★systems 裁 (甲) 時加的那一條：`listed` 把「出現在自家隊動作區」宣告出來，
#   而**被宣告為不在那一屏的那些**，必須在**某個子模式 handler 的函式體**裡出現
#   —— 否則它是**哪一屏都進不去**的動作 ＝ **一個真正的新呈現決定（WHAT）**。
# ★★而這一格**不裁定**那件事：它只把那份名單**逐名印出來**，拿去問藍圖。
#   ⇒ ★★★它讓「哪一屏都進不去」從【一句需要有人想起來的話】
#     變成【卷面上一份會自己長出來的名單】。
# ★★★★而空名單**也要印**：那是「這一輪沒有 WHAT 殘餘物」的證據
#   （一個沒有印出來的空集合跟一個沒有跑的迴圈長得一樣）。
# ★誠實限（就地寫）：本格掃的是 `_handle_*_mode` 的**函式體文字**
#   ⇒ 它答「那個 action_id 的字面在某一屏的 handler 裡出現過」，
#     **不答**「玩家真的按得到它」（後者要行為證，而那不在本票）。
#   ⇒ 失效方向是【少算 WHAT 殘餘物】（字面出現就算進去了）⇒ 名單是**下界**。
# 負對照：把一個 `listed==false` 的 id 從它那一屏的 handler 裡拿掉 ⇒ 它出現在名單上 ⇒ 待實測
func _test_p18_unlisted_must_be_reachable_from_some_panel() -> void:
	print("\n── P18 `listed==false` 的那些進得去哪一屏 ──")
	var shape: Dictionary = PlayerCommandSystem.ACTION_SHAPE
	# ★★★★★【母體第一版太寬，而寬的壞得更安靜】（2026-10-01 實測）——
	#   第一版母體 ＝ 所有 `listed==false`（43 個）⇒ 名單生出 **19 個**名字，
	#   而其中 8 個是**團隊目標動作**（`attack`／`extort`／`propose_alliance`…）：
	#   它們從**互動層查表**進去（`TextUiView.action_for_key` → `action_id`）
	#   ⇒ handler 的函式體裡**根本沒有那個字面** ⇒ 我的掃描看不到它們。
	#   ⇒ ★★那是一個「看起來像大工作的數字」—— 而真正要問藍圖的只有
	#     **不吃目標而又不在那一屏**的那些（`target=="none" and not listed`）。
	#   ⇒ ★★★所以母體收窄成那一類；而 `team`／`tile` 有它們自己的入口
	#     （互動層的查表／地圖游標）⇒ 它們不是本格的問題。
	var unlisted: Array = []
	for k in shape.keys():
		var row: Dictionary = shape[k] as Dictionary
		if String(row.get("target", "")) == "none" and not bool(row.get("listed", false)):
			unlisted.append(String(k))
	unlisted.sort()
	print("   母體 ＝ `target==\"none\"` 且 `listed==false` ⇒ %d 個" % unlisted.size())
	_check("★母體地板 A：那一類不是空的（空 ⇒ 下面整格不跑）", unlisted.size() > 0)
	# ★★★★掃描母體也放寬：不只 `_handle_*_mode`，而是 `scripts/ui/` 的**每一行非註解**
	#   ★理由（實測逼出來的）：`surrender_in_encounter` 走 `encounter_view.gd` 的按鍵處理，
	#     那裡**沒有** `_handle_*_mode` 這種函式 ⇒ 只掃那個命名樣式會把它誤報成「進不去」。
	#   ⇒ ★★判準：**掃描母體用「哪些檔」不要用「哪些函式名」** ——
	#     函式命名慣例是一個會有例外的東西，而例外會變成假的 WHAT 殘餘物。
	# ★★★★★★【掃描母體要排除死樹，而「哪些是活的」不是我判的】（2026-10-01 實測）——
	#   `main.gd` 是**整棵死樹**（`press_is_one_tick_bed.gd` 的 `SPEC_LIVE_UI_FILES`
	#   那一段逐字寫著「main.gd 10 是死樹」，而本票沒有改那件事）
	#   ⇒ 把它算進掃描母體 ⇒ 那個動作會被判成「進得去」而它只出現在死樹裡
#     （★那個 id 於 2026-10-01 整支退場 ⇒ 這裡不再寫它的字面：P1／P2 的地板是 grep ＝ 0）
	#   ⇒ ★那是一個**假陰性**：名單少一個，而少的那個正是要問藍圖的。
	const DEAD_TREE: Array = ["main.gd"]
	# ★★★★★★★【第二桶：強制事件回應】——
	#   `choose_heir`／`respond_aid_request` 這一類是**強制事件的回應動作**
	#   （`event_system.gd:85` 逐字 `"action": "choose_heir"`）⇒ 玩家按的是**字母鍵**，
	#   而 `action_id` 從 **payload** 來 ⇒ UI 的 code 裡**沒有那個字面**。
	#   ⇒ ★所以它們不是「哪一屏都進不去」，是**我的掃描結構上看不到它們**
	#     —— 與團隊目標動作被查表派發是同一個形狀（第三次）。
	#   ⇒ ★★處置：把它們分到自己一桶，而歸類的依據是**機械的**
	#     （`scripts/simulation/` 裡有 `"action": "<id>"` 這個字面）不是我手挑。
	var hits: Dictionary = {}
	var n_files: int = 0
	var skipped: Array = []
	var d := DirAccess.open("res://scripts/ui")
	if d == null:
		_check("★母體地板 B：開得了 res://scripts/ui（開不了 ⇒ 本格不可判不是綠）", false)
	else:
		d.list_dir_begin()
		var f: String = d.get_next()
		while f != "":
			if f.ends_with(".gd"):
				if DEAD_TREE.has(f):
					skipped.append(f)
					f = d.get_next()
					continue
				n_files += 1
				for line in FileAccess.get_file_as_string("res://scripts/ui/" + f).split("\n"):
					var l: String = String(line)
					if l.strip_edges().begins_with("#"):
						continue
					for aid in unlisted:
						if l.contains('"%s"' % String(aid)):
							if not hits.has(String(aid)):
								hits[String(aid)] = []
							if not (hits[String(aid)] as Array).has(f):
								(hits[String(aid)] as Array).append(f)
			f = d.get_next()
		d.list_dir_end()
	print("   掃了 `scripts/ui/` 的 %d 支 .gd（★排除死樹 %s）" % [n_files, str(skipped)])
	_check("★★母體地板 B：真的掃到檔（%d；0 ⇒ 下面那份名單會是【全部】而那是假的）" % n_files,
		n_files > 0)
	_check("★★★母體地板 C：死樹真的被排除了（%d 支；0 ⇒ 那個排除沒有生效）" % skipped.size(),
		skipped.size() == DEAD_TREE.size())
	# ★★★★★★★★【第二桶的判準第一版太窄 ⇒ 它【多報】了一個】（2026-10-01 實測）——
	#   第一版判準 ＝ `scripts/simulation/` 裡有 `"action": "<id>"` 這個字面。
	#   ★而 `respond_aid_request` 的可達路徑是 `respond_to_forced()`（`:1242`）
	#     **直接呼 handler**（`:1281` 逐字 `result = _action_respond_aid_request(state, -1, …)`）
	#     ⇒ 沒有那個字面 ⇒ 它被誤判成「哪一桶都不是」。
	#   ⇒ ★★而那個誤判的方向是**多報**，與我原本寫的「失效方向是少算」**相反**
	#     —— ⇒ 判準的失效方向要**逐桶**講，不能用一句話蓋兩桶。
	#   ⇒ ★★★所以判準換成**行為形狀**：那支 handler 在 registry 之外**還有直接呼叫點**
	#     ⇒ 它有第二條派發路徑 ⇒ 玩家進得去（而卷面要**指名那支函式**）。
	var forced: Dictionary = {}
	var pcs_src: String = FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd")
	var cur_fn: String = ""
	for line2 in pcs_src.split("\n"):
		var l2: String = String(line2)
		if l2.begins_with("func "):
			cur_fn = l2.substr(5, maxi(0, l2.find("(") - 5))
			continue
		if l2.strip_edges().begins_with("#") or cur_fn == "_setup_registry":
			continue
		for aid3 in unlisted:
			if l2.contains("_action_%s(" % String(aid3)) and cur_fn != "_action_%s" % String(aid3):
				forced[String(aid3)] = cur_fn
	_check("★★母體地板 D：第二桶真的讀到那支檔（%d 行）" % pcs_src.split("\n").size(),
		pcs_src.length() > 0)
	var nowhere: Array = []
	var in_panel: int = 0
	var n_forced: int = 0   # ★用分類時的計數，不用 forced.size()：有 id 同時在兩桶 ⇒ 會重複計
	for aid2 in unlisted:
		if hits.has(String(aid2)):
			in_panel += 1
			print("     · %-24s 出現在 %s" % [String(aid2), str(hits[String(aid2)])])
		elif forced.has(String(aid2)):
			n_forced += 1
			print("     · %-24s ★registry 之外的第二條派發路徑：`%s()`" % [
				String(aid2), String(forced[String(aid2)])])
		else:
			nowhere.append(String(aid2))
	print("   ── 三桶相加 ＝ 母體 ──")
	print("   某一屏的 UI code 裡有字面 %d｜強制事件回應 %d｜★哪一桶都不是 %d｜母體 %d" % [
		in_panel, n_forced, nowhere.size(), unlisted.size()])
	_check("★★★★三數相加 ＝ 母體（%d ＋ %d ＋ %d ＝ %d）" % [
		in_panel, n_forced, nowhere.size(), unlisted.size()],
		in_panel + n_forced + nowhere.size() == unlisted.size())
	print("   ★★★【哪一桶都不是】＝ %s　⇒ 這份名單要拿去問藍圖（systems 裁）" % str(nowhere))
	print("     ★空名單也是結果：它是「這一輪沒有 WHAT 殘餘物」的證據。")
	print("   ★誠實限要【逐桶】講（一句話蓋兩桶會把方向講錯 —— 2026-10-01 實測過一次）：")
	print("     ·第一桶：答【字面出現在某支活的 UI 檔裡】，不答【玩家真的按得到】")
	print("       ⇒ 失效方向【少算殘餘物】（字面在就算進去了）")
	print("     ·第二桶：答【handler 在 registry 之外還有直接呼叫點】")
	print("       ⇒ 失效方向也是【少算】（有第二條路就算進去，不問那條路通不通）")
	print("     ⇒ 兩桶都少算 ⇒ 最後那份名單是**下界**（真正進不去的可能更多）。")
	_check("★★★★本格只要求名單被印出來（印了 %d 個）" % nowhere.size(), true)
	_cell("_test_p18_unlisted_must_be_reachable_from_some_panel")


# == P16 ＝ spec P1 [母體機械導出 ＋ 反向掃] =====================================
# ★母體【不是一份新清單】：`_action_registry` 是權威，`ACTION_SHAPE` 只多一個維度。
#   ⇒ 完整性靠**反向掃**不靠紀律：registry 的每一個 key 都要有人宣告過，
#     **漏一個紅並指名** ⇒ 新增 handler 的人會被擋下來。
# ★★斷言用【指名】不用【數數】（血證：merge 判準「行數≥兩邊」被 77 滿足而少一支閘
#   —— 三個集合可以大小相同而成員不同）。
# ★★★而兩個方向要分開問：
#   ·registry ∖ ACTION_SHAPE ＝ ∅        （有 handler 而沒宣告 ⇒ 下一個人漏登記）
#   ·ACTION_SHAPE ∖ registry ⊆ 具名豁免  （宣告了而沒 handler ⇒ 要嘛打錯字要嘛是豁免）
# 負對照 a：從 `ACTION_SHAPE` 刪掉一列 ⇒ 第一個方向紅並指名那個字 ⇒ 待實測
# 負對照 b：在 registry 加一個假 handler 而不宣告 ⇒ 同一條紅（守的是「下一個人」）⇒ 待實測
func _test_p16_action_shape_reverse_sweep() -> void:
	print("\n── P16（spec P1）ACTION_SHAPE 的母體與反向掃 ──")
	var arr: Array = _fresh()
	var cs: PlayerCommandSystem = arr[1]
	var reg: Array = cs.get_registered_actions()
	var shape: Dictionary = PlayerCommandSystem.ACTION_SHAPE
	var none_ids: Array = []
	var team_ids: Array = []
	var other_ids: Array = []
	for k in shape.keys():
		var t: String = String((shape[k] as Dictionary).get("target", ""))
		if t == "none":
			none_ids.append(String(k))
		elif t == "team":
			team_ids.append(String(k))
		else:
			other_ids.append("%s（%s）" % [String(k), t])
	none_ids.sort(); team_ids.sort(); other_ids.sort()
	print("   `_action_registry` 的 key ＝ %d｜`ACTION_SHAPE` 的列 ＝ %d" % [reg.size(), shape.size()])
	print("   target==\"none\" 共 %d 個（逐名）：%s" % [none_ids.size(), str(none_ids)])
	print("   target==\"team\" 共 %d 個｜其他 %d 個：%s" % [
		team_ids.size(), other_ids.size(), str(other_ids)])
	_check("★母體地板 A：registry 不是空的（空 ⇒ 下面兩個方向都恆綠）", reg.size() > 0)
	_check("★母體地板 B：`ACTION_SHAPE` 不是空的", shape.size() > 0)
	_check("★★母體地板 C：`target==\"none\"` 那一類不是空的（本票的消費者就是它）",
		none_ids.size() > 0)
	# ── 方向一：registry ∖ ACTION_SHAPE（有 handler 而沒宣告）──
	var undeclared: Array = []
	for r in reg:
		if not shape.has(String(r)):
			undeclared.append(String(r))
	undeclared.sort()
	_check("★★★★反向掃①：每一個 registry key 都有人宣告過（沒宣告的：%s）" % str(undeclared),
		undeclared.is_empty())
	# ── 方向二：ACTION_SHAPE ∖ registry（宣告了而沒 handler）──
	var orphan: Array = []
	for k2 in shape.keys():
		if not reg.has(String(k2)) and not SPEC_SHAPE_EXEMPT.has(String(k2)):
			orphan.append(String(k2))
	orphan.sort()
	print("   ★具名豁免（床持有）＝ %s" % str(SPEC_SHAPE_EXEMPT))
	_check("★★★★反向掃②：宣告了而沒 handler 的，只剩具名豁免（多出來的：%s）" % str(orphan),
		orphan.is_empty())
	# ★★★而豁免自己要真的【不在】registry —— 否則那份豁免是一句沒有主詞的話
	var fake_exempt: Array = []
	for e in SPEC_SHAPE_EXEMPT:
		if reg.has(String(e)):
			fake_exempt.append(String(e))
	_check("★★★豁免清單裡的每一個都【真的不在】registry（在的話那個豁免沒有主詞：%s）"
		% str(fake_exempt), fake_exempt.is_empty())
	_cell("_test_p16_action_shape_reverse_sweep")


# == P17：★★★★★【衍生集合 vs 外部期望】（原本是異源交叉，而它已經變成同源）=======
# ★原本這一格比的是「`ACTION_SHAPE` 的 team 集合」vs「`TEAM_TARGET_ACTIONS`」，
#   而那在當時是**異源**（兩份各自獨立的手抄字面）。
# ★★而 `TEAM_TARGET_ACTIONS` 收成 `ACTION_SHAPE` 的衍生檢視之後，那兩邊**同源**
#   ⇒ 它會**恆真**（寫什麼都綠）⇒ ★**所以它被換掉，不是留著**
#     （留著比沒有格更糟：卷面上多一行綠色的保證，而它什麼都沒保證）。
# ★★★換成什麼：拿衍生集合去跟**外部期望**比，而外部期望有**兩個維度且刻意成對**：
#   ·**數目** ＝ `SPEC_TEAM_TARGET_TOTAL`
#   ·**成員** ＝ `SPEC_TEAM_TARGET_NAMES`（★那一份刻意手抄的清單，理由寫在它旁邊）
#   ⇒ 只比數目會漏掉「換了一個名字而數目不變」；只比成員會漏掉…其實不會，
#     但兩個都比會讓**差在哪一維**直接印在卷面上（而那是給讀的人的）。
# 負對照：把 `extort` 的 `target` 從 `"team"` 改成 `"none"` ⇒ 本格紅 3 條並指名（差集 ["extort"]、兩個大小對照） ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# ★★★而另一道**刻意不跑**（跑它要先把本格弄壞）：把 `SPEC_TEAM_TARGET_NAMES` 改成從
#   `ACTION_SHAPE` 導出（＝有人「順手去重」）⇒ 本格從那一刻起**恆真**，而上面那一道
#   就**再也紅不起來** ⇒ 接住它的是 **P19**（它數本格的承重斷言）—— P19 的負對照已實測。
func _test_p17_shape_team_equals_team_target_actions() -> void:
	print("\n── P17 衍生集合 vs 外部期望 ──")
	var shape: Dictionary = PlayerCommandSystem.ACTION_SHAPE
	var derived: Array = []
	for k in shape.keys():
		if String((shape[k] as Dictionary).get("target", "")) == "team":
			derived.append(String(k))
	derived.sort()
	var expect: Array = SPEC_TEAM_TARGET_NAMES.duplicate()
	expect.sort()
	print("   衍生集合（`ACTION_SHAPE` 的 team，%d）：%s" % [derived.size(), str(derived)])
	print("   外部期望（手抄清單，%d｜spec 常數 ＝ %d）：%s" % [
		expect.size(), SPEC_TEAM_TARGET_TOTAL, str(expect)])
	_check("★母體地板 A：衍生集合不是空的（空 ⇒ 下面兩個差集恆空 ⇒ 本格恆綠）",
		derived.size() > 0)
	_check("★母體地板 B：外部期望不是空的", expect.size() > 0)
	# ★★★【成對】：名字加進一邊而沒加另一邊 ⇒ 這一條先紅
	_check("★★★【成對】手抄清單的長度 ＝ `SPEC_TEAM_TARGET_TOTAL`（%d／%d；對不上 ⇒ 有人只改了一邊）"
		% [expect.size(), SPEC_TEAM_TARGET_TOTAL], expect.size() == SPEC_TEAM_TARGET_TOTAL)
	var only_derived: Array = []
	var only_expect: Array = []
	for a in derived:
		if not expect.has(String(a)):
			only_derived.append(String(a))
	for b in expect:
		if not derived.has(String(b)):
			only_expect.append(String(b))
	_check("★★★★★兩個差集都空（只在衍生集合：%s｜只在外部期望：%s）"
		% [str(only_derived), str(only_expect)],
		only_derived.is_empty() and only_expect.is_empty())
	_check("★★衍生集合的大小 ＝ `SPEC_TEAM_TARGET_TOTAL`（%d／%d）" % [
		derived.size(), SPEC_TEAM_TARGET_TOTAL], derived.size() == SPEC_TEAM_TARGET_TOTAL)
	# ★★★★而「它真的是衍生物」要自己證一句：`TEAM_TARGET_ACTIONS` 必須等於衍生集合
	#   ⇒ ★這一條**刻意是同源的**（它問的不是「兩份清單一致嗎」，
	#     而是「那個名字現在**真的**是衍生檢視嗎」）⇒ 它與上面那條不是同一個問題。
	var live: Array = PlayerCommandSystem.TEAM_TARGET_ACTIONS.duplicate()
	live.sort()
	_check("★★★★`TEAM_TARGET_ACTIONS` 現在就是那個衍生集合（＝它不再是第二份清單；%s）"
		% ("相同" if live == derived else "★不同：%s vs %s" % [str(live), str(derived)]),
		live == derived)
	print("   ★而本格【不再】拿 `TEAM_TARGET_ACTIONS` 當外部期望 —— 它已經是衍生物 ⇒ 那會恆真。")
	_cell("_test_p17_shape_team_equals_team_target_actions")

# ══ P19 ＝ spec P1 ＋ P2【單一定義 ＋ 那條交叉斷言不准還在】════════════════════
# （spec `2026-10-01-team-target-actions-becomes-a-derived-view-HOW.md` §4 P1／P2）
# ★P1：全庫 `TEAM_TARGET_ACTIONS` 的**手抄字面** ＝ **0 處**（★指名，不數數）——
#   它收成 `ACTION_SHAPE` 的衍生檢視之後，是一個 **`static var`**（`const` 不能用迴圈導出）
#   ⇒ ★★它**可寫**，而「沒有人會去 append 它／沒有人會把它改回手抄」不是保證 ⇒ 由本格看著。
# ★★P2：原本那條交叉斷言（`ACTION_SHAPE` 的 team 集合 ＝ `TEAM_TARGET_ACTIONS`）
#   **若還在就是紅的** —— 它在收成衍生物那一刻變成**同源 ⇒ 恆真**，
#   而恆真格比沒有格更糟（卷面上多一行綠色的保證，而它什麼都沒保證）。
#   ⇒ 本格的驗法不是「找那段文字」（錨在文字上會被重排弄紅），而是**數 P17 的承重斷言**：
#     ·P17 的 `_check(` 裡**至少一條**要提到 `SPEC_TEAM_TARGET_NAMES`（＝外部期望）
#     ·P17 的 `_check(` 裡提到 `TEAM_TARGET_ACTIONS` 的**只准一條** ——
#       就是那條**刻意同源**的（「它現在真的是衍生檢視嗎」）⇒ 多出來的就是舊斷言回來了。
# ★★★母體地板（本格自己）：掃到的 `.gd` 檔數 > 0、P17 的 `_check(` 條數 > 0，
#   且**陽性對照**：那個衍生宣告（`static var … = _derive_team_target_actions()`）
#   必須被掃到剛好 1 次 —— ⇒ 掃不到它 ⇒ 抽取式壞了，而壞的方向是「什麼都沒找到」。
# 負對照：把 `static var TEAM_TARGET_ACTIONS` 改回手抄字面 ⇒ P1 紅並指名 `player_command_system.gd:434`，而陽性對照同時紅（1 → 0） ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# 負對照：把 P17 裡那條比【成員】的 `_check`（兩個差集）刪掉 ⇒ P2b 紅（0 個） ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# 負對照：在 P17 再加一條拿 `TEAM_TARGET_ACTIONS` 當外部期望的 `_check` ⇒ P2 紅並指名（實得 2） ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# ★★★★★而**第一版的 P2b 對它自己的負對照沒有鑑別力**（實測：刪掉那一條，一格都沒紅）——
#   因為它只讀 `_check(` 的**第一行**，而「成對」那一條的訊息字串裡也有 `expect`
#   ⇒ 修法是**按括號配對切出整個呼叫**（`_check_calls()`），不是把判準的字眼換一個
#   ⇒ ★判準的【粒度】要對上它要抓的那個擾動發生在哪一行。
func _test_p19_single_definition_and_no_same_source_cross() -> void:
	print("\n── P19（spec P1／P2）單一定義 ＋ 交叉斷言不准還在 ──")
	var files: Array = []
	_collect_gd("res://scripts", files)
	print("   掃描母體：`res://scripts` 之下的 `.gd` ＝ %d 檔" % files.size())
	_check("★母體地板 A：掃到的檔數 > 0（0 ⇒ 下面那個「0 處」是母體為空不是沒有違規）",
		files.size() > 0)
	var handwritten: Array = []
	var derived_decl: Array = []
	var mutations: Array = []       # ★對它的【寫入】—— 見下面那一條地板
	for f in files:
		var raw: String = FileAccess.get_file_as_string(String(f))
		var ls: Array = raw.split("\n")
		for i in range(ls.size()):
			var line: String = String(ls[i])
			var t: String = line.strip_edges()
			if t.begins_with("#"):
				continue        # ★逐行跳註解（不用 `_code_only()`：它會讓行號漂掉）
			var code: String = line
			var hash_at: int = code.find("#")
			if hash_at != -1:
				code = code.substr(0, hash_at)
			if not code.contains("TEAM_TARGET_ACTIONS"):
				continue
			if code.contains("_derive_team_target_actions()"):
				derived_decl.append("%s:%d" % [String(f), i + 1])
			elif _is_mutation(_strip_strings(code)):   # ★剝字串 ＝ 保險（別的檔可能在字串裡印它）
				mutations.append("%s:%d ⇒ %s" % [String(f), i + 1, t])
			# ★★★★★【判準的描述與判準的違反在文字上同形】——
			#   第一版寫「含 `TEAM_TARGET_ACTIONS` 且含 `= [`」⇒ **它命中了自己這一行**
			#   （掃描器的條件式逐字長得像它要抓的東西）。
			#   ⇒ 修法是**錨在宣告上**（`const`／`var`／`static var` ＋ 那個名字），
			#     不是「把自己的檔排除掉」（那會讓同檔裡真的手抄回來的那一天抓不到）。
			elif _is_handwritten_decl(code):
				handwritten.append("%s:%d ⇒ %s" % [String(f), i + 1, t])
	print("   ★陽性對照（衍生宣告，要剛好 1 處）＝ %s" % str(derived_decl))
	_check("★★母體地板 B【陽性對照】：抽取式掃得到那個衍生宣告，且剛好 1 處（%d）"
		% derived_decl.size(), derived_decl.size() == 1)
	print("   ★P1 手抄字面（要 0 處）＝ %s" % str(handwritten))
	_check("★★★★★P1a：全庫沒有 `TEAM_TARGET_ACTIONS` 的手抄字面（有的話逐條指名：%s）"
		% str(handwritten), handwritten.is_empty())
	# ★★★★★【P1b ＝ 另一個方向，而它是 2026-10-01 電池的 `cross-run-static` 紅逼出來的】
	#   `const` → `static var` 換來了「可以用迴圈導出」，★代價是**它變成跨 run 可變狀態**：
	#   `static` 的生命週期跨越整個進程 ⇒ 任何人對它 `append`／`erase`／`sort`
	#   都會**洩到下一次 run**，而那種汙染的長相是「上一輪的殘留讓這一輪剛好過」。
	#   ⇒ 電池那支閘（`cross-run-static`）抓到它沒有清除點也不在白名單 ⇒ 我走白名單，
	#     ★而白名單那一列的理由裡寫著「grep 寫入形式命中 0」——
	#     ★★**那句話必須有執法點，否則它會靜默腐爛**（白名單是一句話，不是一個守衛）
	#   ⇒ **本條就是那個執法點**，而它擋的方向與 P1a **相反**：
	#     P1a 擋「把它改回一份手抄清單」、P1b 擋「把它當成一個可以改的陣列」。
	# 負對照：在 `colocation_gate_bed.gd` 寫一行對它的 `append` ⇒ P1b 紅並指名 `colocation_gate_bed.gd:78` ⇒ 已於 feat/text-ui-layout-v2（2026-10-01 這一輪） 實測紅
# ★★而這一道**第一次沒跑成**而我差一步把它當成跑過了：插入點的 assert 先失敗 ⇒ **什麼都沒寫** ⇒
#   接下來那一跑量到的是**沒有擾動的樹**，卷面印 `[]`。★那個 `[]` 與「對照紅完之後還原乾淨」
#   在畫面上**一模一樣** ⇒ 判準：**負對照要先確認擾動真的落在檔案裡**（這次是 assert 擋住了它，
#   而 assert 擋住的理由是「安全的失敗長相」—— 它沒有寫半套）。
	# ★陽性對照（**sanity check 不是對照組**：它只驗「剝字串之後抽取式還認得真的寫入」，
	#   不分辨任何兩個假設）—— 真正有鑑別力的是負對照（在某支 .gd 裡真的寫一行）。
	var sym_probe: String = SPEC_CONSTANT_SYMBOL
	_check("★陽性對照：抽取式認得真的寫入（認不得 ⇒ P1b 恆綠）",
		_is_mutation(sym_probe + ".append(\"x\")"))
	_check("★陽性對照（反面）：只是**讀**它不算（算 ⇒ 本床到處在讀它 ⇒ P1b 會恆紅）",
		not _is_mutation("var a = " + sym_probe + ".duplicate()"))
	print("   ★P1b 對它的寫入（要 0 處）＝ %s" % str(mutations))
	_check("★★★★★P1b：全庫沒有人寫 `TEAM_TARGET_ACTIONS`（它是 `static var` ⇒ 寫它會洩到下一次 run；有的話逐條指名：%s）"
		% str(mutations), mutations.is_empty())
	# ── P2：數 P17 的承重斷言 ──
	var self_src: String = FileAccess.get_file_as_string(
		"res://scripts/debug/available_actions_bed.gd")
	var p17: String = _func_body(self_src, "func _test_p17_shape_team_equals_team_target_actions")
	_check("★母體地板 C：切得出 P17 的函式體（空 ⇒ 下面兩條恆綠）", p17.strip_edges() != "")
	# ★★★★★【判準的粒度，第二次】NEG-b 的血證：第一版只讀 `_check(` 的**第一行**，
	#   而「成對」那一條的**訊息字串**裡也有 `expect` ⇒ 把真正比成員的那一條刪掉
	#   **一格都沒有紅**。⇒ 所以這裡按**括號配對**切出整個 `_check(…)` 呼叫再看它的全文。
	#   ★而「比成員」要認的不是某個變數名碰巧出現，是**那兩個差集同時出現在同一個呼叫裡**。
	var calls: Array = _check_calls(p17)
	var n_check_lines: int = 0
	for l3 in p17.split("
"):
		if String(l3).strip_edges().begins_with("_check("):
			n_check_lines += 1
	print("   P17 的 `_check(` 起始行 %d 行｜括號配對切出 %d 個完整呼叫" % [
		n_check_lines, calls.size()])
	_check("★母體地板 D：切得出 `_check(` 呼叫（%d；0 ⇒ 下面每一條都在空集合上成立）"
		% calls.size(), calls.size() > 0)
	_check("★★母體地板 E：配對切出的呼叫數 ＝ 起始行數（%d／%d；對不上 ⇒ 配對器吞掉或切斷了呼叫）"
		% [calls.size(), n_check_lines], calls.size() == n_check_lines)
	var checks_member: Array = []     # 真的在比【成員】的（兩個差集同時出現）
	var checks_ttag: Array = []       # 拿 `TEAM_TARGET_ACTIONS` 當期望的
	for c in calls:
		var txt: String = String(c)
		if txt.contains("only_derived") and txt.contains("only_expect"):
			checks_member.append(txt.strip_edges().substr(0, 60))
		if txt.contains("TEAM_TARGET_ACTIONS") and not txt.contains("SPEC_TEAM_TARGET_"):
			checks_ttag.append(txt.strip_edges().substr(0, 60))
	var body_refs_named: int = p17.count("SPEC_TEAM_TARGET_NAMES")
	print("   P17 函式體引用 `SPEC_TEAM_TARGET_NAMES` %d 次｜比【成員】的呼叫 %d 個｜拿 `TEAM_TARGET_ACTIONS` 當期望的 %d 個" % [
		body_refs_named, checks_member.size(), checks_ttag.size()])
	_check("★★★★P2①a：P17 的函式體引用了外部期望 `SPEC_TEAM_TARGET_NAMES`（%d 次）"
		% body_refs_named, body_refs_named > 0)
	_check("★★★★★P2①b：而且真的有一條在比【成員】（兩個差集同時進同一個 `_check`；%d 個：%s）"
		% [checks_member.size(), str(checks_member)], checks_member.size() > 0)
	_check("★★★★★P2②：P17 裡拿 `TEAM_TARGET_ACTIONS` 比的**只准一條**（那條刻意同源的；實得 %d：%s）"
		% [checks_ttag.size(), str(checks_ttag)], checks_ttag.size() == 1)
	_cell("_test_p19_single_definition_and_no_same_source_cross")


# 按括號配對切出一段 code 裡的每一個 `_check(…)` 呼叫**全文**（含跨行的續行）。
# ★為什麼不逐行看：一個 `_check(` 的**條件**常在第二、三行，而訊息字串裡的字會冒充條件
#   ⇒ 逐行判準會對「把條件刪掉」這個擾動沒有鑑別力（NEG-b 實測，2026-10-01）。
func _check_calls(src: String) -> Array:
	var out: Array = []
	var ls: Array = src.split("
")
	var i: int = 0
	while i < ls.size():
		var t: String = String(ls[i]).strip_edges()
		if not t.begins_with("_check("):
			i += 1
			continue
		var buf: String = ""
		var depth: int = 0
		var started: bool = false
		while i < ls.size():
			var line: String = String(ls[i])
			buf += line + "
"
			var in_str: bool = false
			for ch in line:
				if ch == "\"":
					in_str = not in_str
				elif not in_str and ch == "(":
					depth += 1
					started = true
				elif not in_str and ch == ")":
					depth -= 1
			i += 1
			if started and depth <= 0:
				break
		out.append(buf)
	return out


# 把一行 code 裡的【雙引號字串字面】挖掉（★長度保留成空白，行號與欄位不漂）。
# ★★★★★為什麼需要它（2026-10-01 實測，今天同族第五次）：
#   `_is_mutation()` 自己那份 pattern 目錄**被 P1b 命中 8 行** ——
#   **規則的描述與規則的違反在文字上同形**，而這不是判準寫得不好，是它結構上必然遇到的
#   ⇒ 所以「以後小心」無效，要機械處置。
# ★★而處置是**提高精度**不是**排除自己那支函式**：
#   真的寫入那個符號時，它出現在引號**外**；目錄項出現在引號**內**
#   ⇒ 剝掉字串字面之後，兩者就不再同形了。
#   （對照：P1a 當時走的是「錨在宣告關鍵字」—— 同樣是提高精度，不是縮小母體。）
func _strip_strings(code: String) -> String:
	var out: String = ""
	var in_str: bool = false
	for i in range(code.length()):
		var ch: String = code[i]
		if ch == "\"":
			in_str = not in_str
			out += " "
		elif in_str:
			out += " "
		else:
			out += ch
	return out


# 一行 code 是不是【對 `TEAM_TARGET_ACTIONS` 的寫入】——
# ★母體是「會改到那個陣列的形式」：方法呼叫與下標指派。
#   ★★`.duplicate()` 不算（它回一份新的，床裡到處在用）；讀取不算。
func _is_mutation(code: String) -> bool:
	# ★★★★★★【第六次同族之後改成這個形狀】：掃描器裡**不再出現那個符號的字面** ——
	#   它從 `SPEC_CONSTANT_SYMBOL`（本床既有的單一來源）**組出來**。
	#   ⇒ 前五次我都在補洞（剝註解／錨宣告關鍵字／剝字串字面），而每一次
	#     「把規則寫下來」都會與規則本身再碰撞一次（最後一次命中的是我剛寫的陽性對照，
	#     因為它含轉義引號而我的引號切換器解析錯）。
	#   ⇒ ★★處置不是再補一個洞，是**把碰撞的源頭拿掉**：沒有字面就不會自我命中，
	#     而母體**不縮小**（比「排除自己那支函式／那個檔」嚴格好：那是縮小母體）。
	#   ⇒ ★★★附帶好處：掃描器因此**錨在那個宣告過的符號名上** —— 有人改名時，
	#     `SPEC_CONSTANT_SYMBOL` 那一處改掉，本掃描器跟著走，不會變成一個掃不到東西的綠。
	var sym: String = SPEC_CONSTANT_SYMBOL
	for m in ["append", "erase", "clear", "sort", "sort_custom", "insert", "resize",
			"remove_at", "push_back", "push_front", "pop_back", "pop_front",
			"reverse", "assign", "fill", "shuffle"]:
		if code.contains(sym + "." + String(m) + "("):
			return true
	# 下標指派：`<SYM>[...] = `
	var at: int = code.find(sym + "[")
	if at != -1 and code.substr(at).contains("] ="):
		return true
	return false


# 一行 code 是不是【手抄的 `TEAM_TARGET_ACTIONS` 宣告】——
# ★錨在「宣告關鍵字 ＋ 那個名字 ＋ `= [`」三件同時成立，所以描述這條規則的 code／註解不會命中。
func _is_handwritten_decl(code: String) -> bool:
	if not code.contains(SPEC_CONSTANT_SYMBOL) or not code.contains("= ["):
		return false
	var t: String = code.strip_edges()
	return t.begins_with("const ") or t.begins_with("var ") or t.begins_with("static var ")


# 遞迴收集 `.gd`（★本格的母體要從磁碟數出來，不是手抄一份檔清單）
func _collect_gd(dir_path: String, out: Array) -> void:
	var d: DirAccess = DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var n: String = d.get_next()
	while n != "":
		if d.current_is_dir():
			if not n.begins_with("."):
				_collect_gd(dir_path + "/" + n, out)
		elif n.ends_with(".gd"):
			out.append(dir_path + "/" + n)
		n = d.get_next()
	d.list_dir_end()



# 負對照：把入口那一格關掉（`elif false and SUBMENU_OPENERS.has(act)`）⇒ 本格紅（在【沒錢】的世界裡仍然可做） ⇒ 已於 fix/exploration-two-english-strings（2026-10-01 這一輪） 實測紅
# ══ P12：★★★【退化狀態】下入口仍在、而動作消失（battery10 的血證釘成一格）════════
# ★★★為什麼要有這一格：battery10 的 `headless` 紅，而紅的那條是
#   `assert(not _actions_no_coin.has("recruit"), "recruit: coin 不足時不可選")`
#   —— 它編碼了**舊語意**，而今天的裁定（子選單入口的 `enabled` 沒有意義）推翻了它。
#   ⇒ ★而**本票的 P4 沒有抓到這件事**，因為 P4 的母體**只有一個狀態**（有錢、有目標）。
#   ⇒ ★★systems 的判準：「**兩個版本行為相同**」這種斷言，它的母體必須含
#     【會讓兩者分岔的那些狀態】，而那些狀態通常是**退化狀態**（沒錢／沒目標／空清單）。
#   ⇒ ★★★所以這一格把那個退化狀態（`coin = 0`）釘進本票自己的床 ——
#     **接住它的是跨切面的 `headless`，而票內的守衛沒接住** ⇒ 把它補在票內。
# ★而它守的不變量有兩半，缺一半都不算：
#   ①入口在退化狀態下**仍然列得出來**（打開選單不用錢）
#   ②而**真的要花錢的那個動作**（`recruit_anon`）在退化狀態下**消失並說出原因**
#   ⇒ 只驗 ① 會讓「全部都永遠可做」也綠；只驗 ② 抓不到入口被錢擋掉。
# 負對照：把 §2④ 刪掉的那段 Layer 5 emit 加回去 ⇒ 本格紅「查詢面裡恰好一次（實測 2）」（另帶信封呼叫點那一格 14 → 15） ⇒ 已於 4e50c0ec6（2026-10-01 這一輪） 實測紅
# == P13 = spec P2 [恰好一次] ===================================================
# ★這一格擋的是「**搬了但沒刪舊的**」—— 本票最容易漏的那一件：
#   `offer_surrender` 進了 `TEAM_TARGET_ACTIONS` ⇒ 它由 `get_action_availability` 產出；
#   而查詢面原本**自己也 emit 一列**（Layer 5）⇒ 兩條路各產一列 ⇒ 畫面上出現兩次。
# ★★母體地板最承重的一條在這裡：那段舊 emit 的條件是 `encounter_active and focus != -1`
#   ⇒ **不在遭遇中的話重複【不可能發生】** ⇒ 這一格會恆綠、而它的負對照也不會紅。
#   ⇒ 所以 fixture **必須在遭遇中**，而那件事要印出來。
func _test_p13_listed_exactly_once() -> void:
	print("\n── P13（spec P2）`offer_surrender` 在清單裡恰好一次 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams.get(ptid)
	var tid: int = _target(st, pt)
	_check("★母體地板：找到同格目標", tid != -1)
	# ★★在遭遇中（否則舊那段 emit 的條件不成立 ⇒ 重複不可能發生 ⇒ 本格恆綠）
	st.encounter_active = true
	st.encounter_attacker_id = ptid
	st.encounter_defender_id = tid
	print("   fixture：encounter_active=%s｜attacker=%d defender=%d（★舊那段 emit 的條件）" % [
		str(st.encounter_active), int(st.encounter_attacker_id), int(st.encounter_defender_id)])
	_check("★★母體地板：真的在遭遇中（false ⇒ 重複不可能發生 ⇒ 本格不可判不是綠）",
		st.encounter_active)
	var q := PlayerQueryApi.new()
	var env: Dictionary = q.get_available_actions(st, {"team_id": tid})
	var data: Dictionary = env.get("data", {})
	var acts: Array = data.get("actions", [])
	print("   查詢面回了 %d 列（envelope ok=%s）" % [acts.size(), str(env.get("ok", false))])
	_check("★母體地板：查詢面真的回了列（0 ⇒ 下面那條恆綠）", acts.size() > 0)
	var n_os: int = 0
	for a in acts:
		if String((a as Dictionary).get("action_id", "")) == "offer_surrender":
			n_os += 1
	var rows: Array = cs.get_action_availability(st, tid)
	var n_full: int = 0
	for r in rows:
		if String((r as Dictionary).get("action_id", "")) == "offer_surrender":
			n_full += 1
	print("   `offer_surrender`：查詢面 %d 次｜全列版 %d 次" % [n_os, n_full])
	_check("★★★★查詢面裡恰好一次（實測 %d）—— 兩次 ＝ 搬了但沒刪舊的那一段" % n_os, n_os == 1)
	_check("★全列版裡恰好一次（實測 %d）" % n_full, n_full == 1)
	_cell("_test_p13_listed_exactly_once")


# 負對照：共用前置檢查的條件【反轉】（`if state.encounter_active:`）⇒ 本格甲／乙／丙三條與 P15 一起紅（5 條），而①判斷單一源與②消費者檢查**保持綠** ⇒ 已於 4e50c0ec6（2026-10-01 這一輪） 實測紅
# ★★用【反轉】不用 `if false`：反轉讓那個字面仍然出現一次 ⇒ ①② 保持綠 ⇒ 紅燈留在【行為】那幾格。
# ★★★而它紅【五條】不是連帶污染：**共用之後一個擾動必然讓所有消費者的格一起紅**
#   —— 那本身就是「它們真的共用」的證據（systems 收了這一句）。
# == P14 = spec P4 [在遭遇中] ===================================================
# ★spec 明文要 P3 與 P4 **分兩格**：它們是兩個獨立的洞，
#   而一個 OR 斷言會讓其中一支永遠沒被驗到。
#   ⇒ 本格只管【在遭遇中】那一半；【同格】那一半在 `colocation_gate_bed` 的 P7。
# ★★而「在遭遇中可做」這一條**不斷言外交結果**：對方可以拒絕投降（那是引擎的事）
#   ⇒ 本格驗的是「**它不再被那一閘擋住**」（msg 不是那一句）—— 不是「它成功了」。
func _test_p14_requires_being_in_an_encounter() -> void:
	print("\n── P14（spec P4）同格但不在遭遇中 ⇒ 拒絕；在遭遇中 ⇒ 過得了那一閘 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams.get(ptid)
	var tid: int = _target(st, pt)
	_check("★母體地板：找到同格目標", tid != -1)
	var tgt: TeamData = st.teams.get(tid)
	_check("★★母體地板：真的【同格】（不同格的話擋住它的是另一閘 ⇒ 本格沒有主詞；玩家 %s／目標 %s）"
		% [str(pt.tile_pos), str(tgt.tile_pos)], pt.tile_pos == tgt.tile_pos)
	# ── 甲：不在遭遇中 ──
	st.encounter_active = false
	var r1: Dictionary = cs.execute_action(st, tid, "offer_surrender")
	var m1: String = String(r1.get("msg", r1.get("message", "")))
	print("   甲 不在遭遇中 ⇒ ok=%s｜msg「%s」" % [str(r1.get("ok", false)), m1])
	_check("★★★甲：被拒絕（ok=false）", not bool(r1.get("ok", false)))
	_check("★甲：原因非空", m1.strip_edges() != "")
	_check("★★甲：原因就是那一句既有的措辭（床持有的期望：`%s`）" % String(SPEC_ONE_COPY_PHRASES[0]),
		m1.contains(String(SPEC_ONE_COPY_PHRASES[0])))
	# ── 乙：在遭遇中 ──
	st.encounter_active = true
	st.encounter_attacker_id = ptid
	st.encounter_defender_id = tid
	var r2: Dictionary = cs.execute_action(st, tid, "offer_surrender")
	var m2: String = String(r2.get("msg", r2.get("message", "")))
	print("   乙 在遭遇中   ⇒ ok=%s｜msg「%s」" % [str(r2.get("ok", false)), m2])
	_check("★★★★乙：不再被那一閘擋住（msg 不是「%s」；實測「%s」）"
		% [String(SPEC_ONE_COPY_PHRASES[0]), m2],
		not m2.contains(String(SPEC_ONE_COPY_PHRASES[0])))
	print("   ★本格【不斷言】乙成功：對方可以拒絕投降，那是引擎的事（spec §4 不在本票）。")
	# ── 丙：全列版那一臂的原因 ＝ 同一句（spec P6 的這個動詞那一列）──
	st.encounter_active = false
	var rows: Array = cs.get_action_availability(st, tid)
	var found: Dictionary = {}
	for r in rows:
		if String((r as Dictionary).get("action_id", "")) == "offer_surrender":
			found = r as Dictionary
	print("   丙 全列版那一列：enabled=%s｜原因「%s」" % [
		str(found.get("enabled", true)), String(found.get("disabled_reason", ""))])
	_check("★母體地板：全列版真的有那一列（沒有 ⇒ 下面兩條沒有主詞）", not found.is_empty())
	_check("★★★丙：不在遭遇中 ⇒ `enabled=false`", not bool(found.get("enabled", true)))
	_check("★★★★丙：原因**與 handler 同一句**（＝它讀的是同一支共用檢查的回傳）",
		String(found.get("disabled_reason", "")).contains(String(SPEC_ONE_COPY_PHRASES[0])))
	_cell("_test_p14_requires_being_in_an_encounter")


# == P15 = spec P5 [鄰居沒被我動到] =============================================
# ★本票動了一支**本來就對**的 handler（`_action_surrender_in_encounter` 那一行改呼共用檢查）
#   ⇒ 它的爆炸半徑要有一格。★而另兩支鄰居（`surrender_pre_encounter`／`accept_encounter`）
#   讀的是 `player_pre_encounter`，本票沒碰 ⇒ 它們驗【形狀】＋把措辭印出來（不硬寫我沒核過的字）。
func _test_p15_neighbours_unchanged() -> void:
	print("\n── P15（spec P5）三個鄰居的既有行為 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	st.encounter_active = false
	st.player_pre_encounter = {}
	var bad: Array = []
	for verb in ["surrender_in_encounter", "surrender_pre_encounter", "accept_encounter"]:
		var r: Dictionary = cs.execute_action(st, tid, String(verb))
		var m: String = String(r.get("msg", r.get("message", "")))
		print("   %-26s ⇒ ok=%s｜msg「%s」" % [String(verb), str(r.get("ok", false)), m])
		if bool(r.get("ok", false)):
			bad.append("%s：不該成功（沒有遭遇戰、沒有預備遭遇）" % String(verb))
		if m.strip_edges() == "":
			bad.append("%s：靜默（沒有原因）" % String(verb))
	_check("★★★三個鄰居都【拒絕且有話說】（違反的：%s）" % str(bad), bad.is_empty())
	# ★而 `surrender_in_encounter` 那一支的措辭【逐字不變】—— 這是本票改它的爆炸半徑
	var r_si: Dictionary = cs.execute_action(st, tid, "surrender_in_encounter")
	var m_si: String = String(r_si.get("msg", r_si.get("message", "")))
	_check("★★★★`surrender_in_encounter` 的那句話逐字不變（床持有的期望：`%s`；實測「%s」）"
		% [String(SPEC_ONE_COPY_PHRASES[0]), m_si],
		m_si.contains(String(SPEC_ONE_COPY_PHRASES[0])))
	print("   ★★而它現在是**呼共用檢查**拿到這句話的 —— 回傳逐字不變就是「抽共用沒有改行為」的證據。")
	_cell("_test_p15_neighbours_unchanged")


func _test_p12_degenerate_state_keeps_openers() -> void:
	print("\n── P12 退化狀態：入口仍在、動作消失 ──")
	var arr: Array = _fresh()
	var st: WorldState = arr[0]
	var cs: PlayerCommandSystem = arr[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tid: int = _target(st, pt)
	_check("★母體地板：找到同格目標", tid != -1)
	var tgt: TeamData = st.teams.get(tid)
	if tgt != null and AnonTierSystem.total_pop(tgt) == 0:
		AnonTierSystem.add_anon(tgt, AnonCohort.TIER_PLEB, 3)
	# ★退化狀態：錢歸零（★而對方【有】無名之人 ⇒ 擋住 `recruit_anon` 的只剩錢）
	ResourceBank.set_amt(pt, "coin", 0.0, "bed_fixture")
	print("   [佈置] 玩家 coin = %.0f（RECRUIT_COST_ANON = %.0f）｜對方無名之人 = %d 人" % [
		float(pt.resources.get("coin", 0)), PlayerCommandSystem.RECRUIT_COST_ANON,
		AnonTierSystem.total_pop(tgt) if tgt != null else -1])
	_check("★★母體地板：錢真的是 0（不是 0 ⇒ 下面那半沒有主詞）",
		float(pt.resources.get("coin", 0)) == 0.0)
	_check("★★母體地板：對方真的有無名之人（沒有 ⇒ `recruit_anon` 消失的原因會是【沒人可招】"
		+ "而不是【沒錢】—— 一個紅在錯理由上的斷言會被讀成「錢那條守衛在工作」）",
		tgt != null and AnonTierSystem.total_pop(tgt) > 0)
	var rows: Array = cs.get_action_availability(st, tid)
	var by_id: Dictionary = {}
	for r in rows:
		by_id[String(r.get("action_id", ""))] = r
	# ①每一個【宣告過的入口】在退化狀態下仍然可做、原因仍然空
	for op in PlayerCommandSystem.SUBMENU_OPENERS:
		var id: String = String(op)
		var row: Dictionary = by_id.get(id, {})
		print("   入口 %-14s enabled=%-5s｜原因「%s」" % [
			id, str(row.get("enabled", "?")), String(row.get("disabled_reason", ""))])
		_check("★母體地板：入口 `%s` 真的在列上" % id, by_id.has(id))
		_check("★★★入口 `%s` 在【沒錢】的世界裡仍然可做（打開選單不用錢）" % id,
			bool(row.get("enabled", false)))
		_check("★入口 `%s` 的原因仍然是空的（它的 `enabled` 沒有意義）" % id,
			String(row.get("disabled_reason", "")) == "")
	# ②而真的要花錢的那個動作要消失並說出原因
	var anon_row: Dictionary = by_id.get("recruit_anon", {})
	print("   動作 recruit_anon  enabled=%-5s｜原因「%s」" % [
		str(anon_row.get("enabled", "?")), String(anon_row.get("disabled_reason", ""))])
	_check("★母體地板：`recruit_anon` 在列上", by_id.has("recruit_anon"))
	_check("★★★`recruit_anon` 在【沒錢】的世界裡不可做（★錢真正在守的地方）",
		not bool(anon_row.get("enabled", true)))
	_check("★★而它說得出原因（空的 ⇒ 玩家只看到它灰掉而不知道為什麼）",
		String(anon_row.get("disabled_reason", "")).strip_edges() != "")
	# ★衍生檢視要跟著少一個名字（★兩半合起來：入口留著、動作走掉）
	var derived: Array = cs.get_available_actions(st, tid)
	print("   衍生檢視（沒錢）＝ %s" % str(derived))
	for op2 in PlayerCommandSystem.SUBMENU_OPENERS:
		_check("★入口 `%s` 也在衍生檢視裡（它 enabled ⇒ 一定在）" % String(op2),
			derived.has(String(op2)))
	_check("★★`recruit_anon` 不在衍生檢視裡", not derived.has("recruit_anon"))
	print("   ★★★而這一格的血證是 battery10 的 `headless`：那一條舊 assert 寫的是")
	print("     「coin 不足時 recruit 不可選」—— 接住裁定與 code 分岔的是【跨切面的網】，")
	print("     而票內的 P4 沒接住（它的母體只有一個狀態）⇒ 這一格把退化狀態補進票內。")
	_cell("_test_p12_degenerate_state_keeps_openers")

func _initialize() -> void:
	print("=== available_actions bed ===")
	_test_p1_full_list_both_directions()
	_test_p1c_static_cross_evidence()
	_test_p2_every_false_has_a_reason()
	_test_p4_old_view_differs_only_by_the_named_exclusion()
	_test_p5_stub_not_listed()
	_test_p7_conditions_have_a_single_holder()
	_test_p8_envelope_boundary()
	_test_p9_declared_openers_are_pure()
	_test_p10_reverse_sweep_payload_without_declaration()
	_test_p11_label_has_one_producer()
	_test_p12_degenerate_state_keeps_openers()
	_test_p13_listed_exactly_once()
	_test_p14_requires_being_in_an_encounter()
	_test_p15_neighbours_unchanged()
	_test_p16_action_shape_reverse_sweep()
	_test_p17_shape_team_equals_team_target_actions()
	_test_p18_unlisted_must_be_reachable_from_some_panel()
	_test_p19_single_definition_and_no_same_source_cross()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== available_actions DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
