extends SceneTree
# @bed-kind: invariant
# slice: 動作全列 ＋ 原因（spec 2026-09-30；權威＝§5 普查／§6 R² 加固／§7 母體邊界）
#
# ★★★這張票治的病：`map_available_action(…, enabled, disabled_reason, …)` 那兩個欄位
#   **存在於信封的型別裡而從來沒有被餵過非預設值** —— `player_query_api.gd:296` 硬寫 `true, ""`
#   ⇒ 恆 true／恆空，正是我們自己有守衛在抓的那一族。
#
# ★★而本票真正的重心有兩個，而它們不是同一件事：
#   ·P1／P1c 守【名字】（母體 ＝ `TEAM_TARGET_ACTIONS`，而且要逐字引用那個常數）
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
# ★§7：兩份同形信封的呼叫點總數（普查的數字，寫進 spec）
const SPEC_ENVELOPE_SITES_QUERY: int = 15   # 本票刪掉三處停用列之後（原 18）
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
	_check("★`opens_submenu` 這一欄逐字等於宣告（%s／%s）" % [
		str(openers), str(PlayerCommandSystem.SUBMENU_OPENERS)],
		str(openers) == str(PlayerCommandSystem.SUBMENU_OPENERS))
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
	for mark in ["no-source-constant: own-team-actions", "unreadable-boundary: tile-actions"]:
		if q_raw.contains(mark):
			marks += 1
	print("   兩個具名標記都在 ＝ %s（defer 的 met_check 錨在它們上面）" % str(marks == 2))
	_check("★★★兩個 defer 的錨（就地具名標記）都在（%d／2）" % marks, marks == 2)
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
