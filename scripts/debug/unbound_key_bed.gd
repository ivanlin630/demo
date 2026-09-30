extends SceneTree
# @bed-kind: acceptance
# slice: 未綁定鍵＝無作用＋一句回饋（spec 2026-09-30，藍圖裁三禁）
#
# ★★★這支床的難點不在按鍵，在【那一組未綁定鍵怎麼來】（spec §1 逐字）：
#   那一組鍵**不准手挑** —— 手挑可能挑到一個【其實有綁】的鍵
#   ⇒ 那一格測不到東西，而它會過（＝「運氣與佈置在卷面上同形」）。
#   ⇒ 所以母體是【導出】的：
#     ①逐模式從 handler 本體機械抽【已綁鍵集合】（`KEY_*` 逐一抽，含範圍）
#     ②未綁定 ＝ 固定候選集合 **減掉** 該模式的已綁集合
#     ③★母體地板：斷言【測的那些真的不在已綁集合裡】——
#       沒有這一條，一格測到綁定鍵也會過，而它過的理由是錯的。
#
# ★★禁③（不改任何狀態）用【既有的尺】：`StateFingerprint.compute` 前後逐位元相同。
#   ⇒ 一個斷言蓋兩件事（狀態沒動 ＋ 沒有推進 tick），而且**不會因為我少列一個欄位而漏**。
#
# ★誠實限：
#   1. 本床按鍵走 `node._handle_*_mode(keycode)`（＝該模式的處理器本身）。
#      它**不經** `_input()` 的 mode dispatch ⇒ 「落到底層處理器」（禁②）的另一半
#      由 P1(d)（佇列長度不變）與 `ui_flow` 的 P24／P25 覆蓋。
#   2. ★`KEY_A` 在非 leader 的 faction mode 是【綁定而不允許】＝三態的②。
#      ★★舊版這裡寫【靜默 no-op、藍圖裁定沒涵蓋它、不在本票】——
#      **那句話已經過期**：藍圖 2026-09-30 裁將範圍擴成【按鍵三態語意】
#      （spec §6）⇒ ②進了本票，而它現在給【原因】
#      （「只有勢力領袖能設定目標」）⇒ P7 就是它的格。
#      ★★★留這段的理由：誤導過下游的話不要默默刪掉，要劃掉留理由。

var _errors: int = 0
var _cells_ran: Array = []

# ★候選鍵集合（母體的【上界】）：A..Z ＋ 0..9 ＋ 幾個常見符號。
#   ★★它是「可能被按到的鍵」的近似，而**不是**「未綁定鍵」——
#     未綁定 ＝ 候選 減 該模式的已綁（P2 的地板就在驗這個減法）。
const CANDIDATE_KEYS: Array = [
	KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J, KEY_K, KEY_L, KEY_M,
	KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z,
	KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9,
	KEY_COMMA, KEY_PERIOD, KEY_SEMICOLON, KEY_SLASH, KEY_MINUS, KEY_EQUAL,
]
# ★Esc 刻意【不在候選裡】：它有語意（回上一層）⇒ P3 單獨驗它，而它不得被當未綁定。
const SPEC_MODE_COUNT: int = 13
# ★回饋句的 token（★認 token 不認整句：措辭改了不該誤報，而語意改了要紅）
const SPEC_FEEDBACK_TOKEN: String = "此鍵在此模式無作用"

const EXPECTED_CELLS: Array = [
	"_test_p2_population_is_derived_not_handpicked",
	"_test_p1_three_prohibitions",
	"_test_p3_escape_is_not_unbound",
	"_test_p4_bound_keys_still_work",
	"_test_p6_faction_precondition_does_not_close_on_unbound",
	"_test_p7_not_allowed_says_why",
	"_test_p8_early_return_census",
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

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 逐模式機械抽【已綁鍵集合】。★從那支 handler 的本體抽 `KEY_*`，含三種形狀：
#   ·`keycode == KEY_X`／`KEY_X:`（match arm）
#   ·`keycode >= KEY_1 and keycode <= KEY_9`（範圍 ⇒ 展開）
#   ·`keycode < KEY_1 or keycode > KEY_9`（反向範圍守衛 ⇒ 也代表 1..9 有綁）
# ★★而它【只讀程式碼】（剝整行註解）—— 註解裡提到的 KEY_ 不算綁定。
func _bound_keys_of(src_lines: PackedStringArray, start: int, end_at: int) -> Array:
	var out: Array = []
	for i in range(start, end_at):
		var t: String = src_lines[i]
		if t.strip_edges().begins_with("#"):
			continue
		# 範圍：兩端都抓到就展開。★★★三種範圍都要展 ——
		#   第一版只展 1..9 ⇒ `_input_mode` 的 A..Z／0..9（打字）沒被算成綁定
		#   ⇒ 母體多算 126 個「未綁」⇒ P1 報 126 次沒有回饋句，而那 126 個【其實有綁】。
		#   ★抓到它的是 P1 那一欄（回饋句沒出現 126 個都在同一個模式）——
		#     一個數字全部集中在一個模式，通常是【母體錯】不是【產品錯】。
		if t.contains("KEY_1") and t.contains("KEY_9"):
			for k in range(KEY_1, KEY_9 + 1):
				if not out.has(k):
					out.append(k)
		if t.contains("KEY_0") and t.contains("KEY_9"):
			for k in range(KEY_0, KEY_9 + 1):
				if not out.has(k):
					out.append(k)
		if t.contains("KEY_A") and t.contains("KEY_Z"):
			for k in range(KEY_A, KEY_Z + 1):
				if not out.has(k):
					out.append(k)
		if t.contains("KEY_1") and t.contains("KEY_4"):
			for k in range(KEY_1, KEY_4 + 1):
				if not out.has(k):
					out.append(k)
		var at: int = t.find("KEY_")
		while at != -1:
			var rest: String = t.substr(at)
			var j: int = 4
			while j < rest.length() and (rest[j].to_upper() == rest[j] or rest[j] == "_") \
					and rest[j] != " " and rest[j] != ":" and rest[j] != ")" and rest[j] != ",":
				j += 1
			var name: String = rest.substr(0, j)
			var code: int = OS.find_keycode_from_string(name.trim_prefix("KEY_"))
			if code != 0 and not out.has(code):
				out.append(code)
			at = t.find("KEY_", at + j)
	out.sort()
	return out

# 13 個模式的（旗標名, 中文標籤, handler 名）—— ★旗標與 handler 都從源碼列舉，不手抄
func _modes() -> Array:
	var src: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	var lines: PackedStringArray = src.split("\n")
	var out: Array = []
	for i in range(lines.size()):
		var t: String = lines[i].strip_edges()
		if not (t.begins_with("func _handle_") and t.contains("_mode(keycode")):
			continue
		var fname: String = t.substr(5, t.find("(") - 5)          # _handle_xxx_mode
		var flag: String = fname.trim_prefix("_handle")            # _xxx_mode
		var en: int = i + 1
		while en < lines.size() and not lines[en].begins_with("func "):
			en += 1
		out.append({"flag": flag, "fn": fname, "from": i, "to": en,
			"bound": _bound_keys_of(lines, i, en)})
	out.sort_custom(func(a, b): return String(a["flag"]) < String(b["flag"]))
	return out


func _initialize() -> void:
	print("=== 未綁定鍵＝無作用＋一句回饋（spec 2026-09-30）===")
	# ★★★那四格含 `await` ⇒ **必須 await 它們**，否則它們在第一個 await 就被放棄
	#   ⇒ 第一版我沒 await ⇒ 四格各印了標題就中止，而【到場點名 1／5 抓到它】。
	#   ★那正是 `ui_flow_test` 檔頭寫的那件事：「await 不保護」——
	#     而這一次不是丟錯被吞掉，是我根本沒等它。★★兩種失效長得一樣：格印了標題就沒聲音。
	await _test_p2_population_is_derived_not_handpicked()
	await _test_p1_three_prohibitions()
	await _test_p3_escape_is_not_unbound()
	await _test_p4_bound_keys_still_work()
	await _test_p6_faction_precondition_does_not_close_on_unbound()
	await _test_p7_not_allowed_says_why()
	_test_p8_early_return_census()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== unbound_key DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══ P2：母體是【導出】的，而且測的那些真的沒綁 ═════════════════════════════
# ★★★這一格是整支床的地基（spec §1）：它先跑，因為後面每一格都吃它的母體。
# 負對照：把 faction 謂詞漏掉 4 個綁定（C／D／E／G）⇒ 異源比對 1 處不一致 ⇒ 已於 feat/unbound-key-semantics（2026-09-30 這一輪） 實測紅
func _test_p2_population_is_derived_not_handpicked() -> void:
	print("\n── P2 母體導出（不手挑）──")
	var modes: Array = _modes()
	print("   列舉到 %d 個模式" % modes.size())
	_check("★母體地板 A：模式數與 spec 常數相符（%d／%d）" % [modes.size(), SPEC_MODE_COUNT],
		modes.size() == SPEC_MODE_COUNT)
	var total_presses: int = 0
	for m in modes:
		var bound: Array = m["bound"]
		var unbound: Array = []
		for k in CANDIDATE_KEYS:
			if not bound.has(int(k)):
				unbound.append(int(k))
		m["unbound"] = unbound
		total_presses += unbound.size()
		print("   %-22s 已綁 %2d 個／候選 %d ⇒ 測 %2d 個未綁" % [
			String(m["flag"]), bound.size(), CANDIDATE_KEYS.size(), unbound.size()])
		# ★★★母體地板：測的那些【真的不在已綁集合裡】
		var leaked: Array = []
		for u in unbound:
			if bound.has(int(u)):
				leaked.append(int(u))
		_check("★★%s：測的未綁鍵沒有一個落在已綁集合裡（%d 個洩漏）" % [
			String(m["flag"]), leaked.size()], leaked.is_empty())
		_check("★%s：已綁集合非空（空的話那個 handler 抽壞了）" % String(m["flag"]),
			not bound.is_empty())
	# ══ ★★★異源比對：產品的謂詞（`_xxx_mode_binds_key`）vs 本床機械抽的集合
	#   ⇒ 兩邊【可以各自改】：有人在 handler 加一個分支而忘了謂詞（或反之）⇒ 紅。
	#   ★而這正是「不信那一支謂詞」的意思：床不讀它的答案來當母體，床自己抽一份再對。
	var node0 = await _make_ui()
	var mismatch: Array = []
	for m in modes:
		var flag: String = String(m["flag"])
		var pred: String = "_%s_binds_key" % flag.trim_prefix("_").trim_suffix("_mode")
		pred = "_" + flag.trim_prefix("_").trim_suffix("_mode") + "_mode_binds_key"
		if not node0.has_method(pred):
			mismatch.append("%s：沒有謂詞 %s" % [flag, pred])
			continue
		for k in CANDIDATE_KEYS:
			var by_pred: bool = bool(node0.call(pred, int(k)))
			var by_scan: bool = (m["bound"] as Array).has(int(k))
			if by_pred != by_scan:
				mismatch.append("%s/%s（謂詞=%s／掃描=%s）" % [
					flag, OS.get_keycode_string(int(k)), str(by_pred), str(by_scan)])
	print("   ★異源比對：謂詞與機械抽取不一致 %d 處%s" % [
		mismatch.size(), ("：" + str(mismatch.slice(0, 8))) if not mismatch.is_empty() else ""])
	_check("★★★謂詞與機械抽取逐鍵一致（%d 處不一致）" % mismatch.size(), mismatch.is_empty())
	await _free_ui(node0)
	print("   ★總計：%d 個模式 × 各自的未綁鍵 ＝ %d 次按壓（P1 會跑這麼多次）" % [
		modes.size(), total_presses])
	_check("★★★總按壓數 > 0（0 的話 P1 是空跑而它會過）", total_presses > 0)
	_cell("_test_p2_population_is_derived_not_handpicked")


# ══ P1：三禁逐一（旗標／fingerprint／回饋句／佇列）═══════════════════════════
# ★★禁③用【既有的尺】：fp 前後逐位元相同 —— 一個斷言蓋兩件事，而且不會漏欄位。
# ★母體地板：先斷言 fp 產得出來（空字串的話「前後相同」恆真）。
# 負對照：把統一出口改成靜默（`pass`）⇒ 354 次都沒有回饋句（★「無作用」不等於「沒反應」） ⇒ 已於 feat/unbound-key-semantics（2026-09-30 這一輪） 實測紅
func _test_p1_three_prohibitions() -> void:
	print("\n── P1 三禁逐一 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var fp0: String = StateFingerprint.compute(st)
	_check("★母體地板：fp 產得出來（空的話「前後相同」恆真）", fp0 != "")
	var modes: Array = _modes()
	var bad_flag: Array = []
	var bad_fp: Array = []
	var no_say: Array = []
	var bad_queue: Array = []
	var presses: int = 0
	for m in modes:
		var flag: String = String(m["flag"])
		var bound: Array = m["bound"]
		for k in CANDIDATE_KEYS:
			if bound.has(int(k)):
				continue
			presses += 1
			for m2 in modes:
				node.set(String(m2["flag"]), false)
			node.set(flag, true)
			node._feedback_line.text = ""
			var q_before: int = st.pending_commands.size()
			var fp_before: String = StateFingerprint.compute(st)
			node.call(String(m["fn"]), int(k))
			if not bool(node.get(flag)):
				bad_flag.append("%s/%s" % [flag, OS.get_keycode_string(int(k))])
			if StateFingerprint.compute(st) != fp_before:
				bad_fp.append("%s/%s" % [flag, OS.get_keycode_string(int(k))])
			if not String(node._feedback_line.text).contains(SPEC_FEEDBACK_TOKEN):
				no_say.append("%s/%s" % [flag, OS.get_keycode_string(int(k))])
			if st.pending_commands.size() != q_before:
				bad_queue.append("%s/%s" % [flag, OS.get_keycode_string(int(k))])
	print("   按了 %d 次" % presses)
	for label in [["禁①旗標被關掉", bad_flag], ["禁③fp 變了", bad_fp],
			["回饋句沒出現", no_say], ["禁②佇列長度變了", bad_queue]]:
		var arr: Array = label[1]
		print("   %-16s %d 個%s" % [String(label[0]), arr.size(),
			("：" + str(arr.slice(0, 6))) if not arr.is_empty() else ""])
	_check("★★★禁①：沒有任何未綁定鍵關掉模式（%d 個違反）" % bad_flag.size(),
		bad_flag.is_empty())
	_check("★★★禁③：fp 前後逐位元相同（%d 個違反）" % bad_fp.size(), bad_fp.is_empty())
	_check("★★★回饋句每一次都出現（%d 次沒出現）" % no_say.size(), no_say.is_empty())
	_check("★★★禁②的一半：佇列長度不變（%d 個違反）" % bad_queue.size(), bad_queue.is_empty())
	await _free_ui(node)
	_cell("_test_p1_three_prohibitions")


# ══ P3：Esc 不得被當未綁定鍵 ════════════════════════════════════════════════
# ★Esc 有語意（回上一層）⇒ 它走各 handler 自己的分支，不得印那句回饋。
# ★母體地板：先斷言每個模式的旗標真的被設起來（否則「Esc 關掉它」恆真）。
# 負對照：把 `_pre_encounter_mode` 的 Esc 從綁定集合拿掉 ⇒ 1 個模式誤印 ⇒ 已於 feat/unbound-key-semantics（2026-09-30 這一輪） 實測紅
func _test_p3_escape_is_not_unbound() -> void:
	print("\n── P3 Esc 不是未綁定鍵 ──")
	var node = await _make_ui()
	var modes: Array = _modes()
	var said: Array = []
	var set_ok: int = 0
	for m in modes:
		var flag: String = String(m["flag"])
		for m2 in modes:
			node.set(String(m2["flag"]), false)
		node.set(flag, true)
		if bool(node.get(flag)):
			set_ok += 1
		node._feedback_line.text = ""
		node.call(String(m["fn"]), KEY_ESCAPE)
		if String(node._feedback_line.text).contains(SPEC_FEEDBACK_TOKEN):
			said.append(flag)
	print("   按 Esc 之後印了那句回饋的模式 = %s（期望空）" % str(said))
	_check("★母體地板：每個模式的旗標都真的被設起來（%d／%d）" % [set_ok, modes.size()],
		set_ok == modes.size())
	_check("★★★Esc 沒有被當成未綁定鍵（%d 個模式誤印）" % said.size(), said.is_empty())
	print("   ★邊界：本格【不】斷言 Esc 之後旗標變成 false —— 各模式的「回上一層」")
	print("     可能是關掉自己、也可能是退回上一層選單（例：interact 的 target 選擇）")
	print("     ⇒ 那是 13 個獨立的語意，不是一條可以一次斷言的規則。")
	await _free_ui(node)
	_cell("_test_p3_escape_is_not_unbound")


# ══ P4：已綁鍵沒被門死 ═════════════════════════════════════════════════════
# ★★這一格守「我沒把功能門死」：每個模式挑【該模式自己的開關鍵】按下去 ⇒ 它仍然生效。
#   ★為什麼挑開關鍵：它是每個模式都一定有的那一個（`KEY_F`／`KEY_K`／`KEY_U`…），
#     而它的效果可觀測（旗標變 false）⇒ 一條斷言可以對 13 個模式成立。
# ★母體地板：那個開關鍵真的在該模式的已綁集合裡（不在就不是這一格該測的東西）。
# 負對照：★尚未點火（P1 那支「出口改靜默」已經覆蓋了它的反面；本格的真正風險是出口擺錯位置，而那一版已被 P4 拓到並修掉）
func _test_p4_bound_keys_still_work() -> void:
	print("\n── P4 已綁鍵沒被門死 ──")
	var node = await _make_ui()
	var modes: Array = _modes()
	var checked: int = 0
	var stuck: Array = []
	for m in modes:
		var flag: String = String(m["flag"])
		var bound: Array = m["bound"]
		# 該模式的「自己的開關鍵」＝旗標名的第一個字母（_faction_mode ⇒ F）
		var letter: String = flag.substr(1, 1).to_upper()
		var code: int = OS.find_keycode_from_string(letter)
		if code == 0 or not bound.has(code):
			continue   # ★不是每個模式都用「名字首字母」當開關鍵 ⇒ 跳過並在下面印母體
		checked += 1
		for m2 in modes:
			node.set(String(m2["flag"]), false)
		node.set(flag, true)
		node._feedback_line.text = ""
		node.call(String(m["fn"]), code)
		var closed: bool = not bool(node.get(flag))
		var refused: bool = String(node._feedback_line.text).contains(SPEC_FEEDBACK_TOKEN)
		print("   %-22s 按 %s ⇒ 關掉=%s／被當未綁=%s" % [flag, letter, str(closed), str(refused)])
		if refused:
			stuck.append(flag)
	print("   ★母體：13 個模式裡有 %d 個用「名字首字母」當開關鍵（其餘的開關鍵不同名，本格跳過）" % checked)
	_check("★母體地板：至少測到 3 個（0 個的話本格什麼都沒驗）", checked >= 3)
	_check("★★★已綁鍵沒有被統一出口吃掉（%d 個被當未綁）" % stuck.size(), stuck.is_empty())
	await _free_ui(node)
	_cell("_test_p4_bound_keys_still_work")


# ══ P6：不在勢力裡按未綁定鍵 ⇒ 旗標不變 ＋ 回饋句出現（systems 裁 (b)）═══════
# ★★★這一格【故意】用「不在勢力裡」那個狀態 —— 那才是這一條路的母體（systems 逐字）。
#   舊寫法把 `in_faction` 前提擺在任何 key 比對之前 ⇒ 按任何未綁定鍵都會關掉面板
#   ⇒ 在畫面上與「我按了一個沒用的鍵把它關掉」一模一樣。
# ★母體地板：先斷言玩家【真的不在勢力裡】（在勢力裡的話這一格測的是另一條路）。
# 負對照：把前提檢查搬回未綁定出口之前 ⇒ 4 格紅（P1 的 26 個違反＋本格的面板被關） ⇒ 已於 feat/unbound-key-semantics（2026-09-30 這一輪） 實測紅
# ★★★而點火它的第一版報 NOT-RED，而那是【我的 expect 字串抓錯】：我拄的是 spec 的措辭
#   「旗標不變」，而床印的是「面板【没有】被關掉」
#   ⇒ 真的紅了卻被我讀成沒紅。★紀律：負對照的 expect 要從【床自己的輸出】拄，不從 spec 拄。

func _test_p6_faction_precondition_does_not_close_on_unbound() -> void:
	print("\n── P6 不在勢力裡，未綁定鍵不得關閉面板 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	pt.faction_id = -1
	print("   玩家隊 faction_id = %d（母體：不在勢力裡）" % pt.faction_id)
	_check("★母體地板：玩家真的不在任何勢力裡", pt.faction_id == -1)
	# 找一個在 faction mode 裡【沒綁】的鍵（從導出的集合取，不手挑）
	var modes: Array = _modes()
	var fm: Dictionary = {}
	for m in modes:
		if String(m["flag"]) == "_faction_mode":
			fm = m
	_check("母體地板：找得到 `_faction_mode` 的抽取結果", not fm.is_empty())
	if fm.is_empty():
		await _free_ui(node)
		_cell("_test_p6_faction_precondition_does_not_close_on_unbound")
		return
	var probe_key: int = 0
	for k in CANDIDATE_KEYS:
		if not (fm["bound"] as Array).has(int(k)):
			probe_key = int(k)
			break
	print("   取一個未綁的鍵：%s（從導出集合取，不手挑）" % OS.get_keycode_string(probe_key))
	_check("★母體地板：那個鍵真的不在 faction mode 的已綁集合裡", probe_key != 0
		and not (fm["bound"] as Array).has(probe_key))
	node.set("_faction_mode", true)
	node._feedback_line.text = ""
	node.call("_handle_faction_mode", probe_key)
	print("   按下之後：_faction_mode = %s｜回饋句 = 「%s」" % [
		str(bool(node.get("_faction_mode"))), String(node._feedback_line.text)])
	_check("★★★禁①：面板【沒有】被關掉（不在勢力裡也一樣）",
		bool(node.get("_faction_mode")))
	_check("★★★回饋句出現", String(node._feedback_line.text).contains(SPEC_FEEDBACK_TOKEN))
	await _free_ui(node)
	_cell("_test_p6_faction_precondition_does_not_close_on_unbound")



# ══ P7：②（綁定但當下不允許）必須給【原因】，而那句話不得與①相同 ═══════════
# ★★★systems 逐字：它守的是**兩種無作用要分得出來**，不是「有話就行」——
#   玩家分不出「這鍵沒用」與「這鍵有用但你不能用」時，**那兩件事的處置完全相反**
#   （前者是別按了，後者是去當上領袖）。
# ★母體地板兩道：①那個鍵真的【有綁】（不然這一格測的是①不是②）
#   ②玩家真的【不是領袖】（是領袖的話那一支走不到）
# 負對照：①那句原因改成靜默 ⇒ 紅；★★②把那句改成與①相同 ⇒ 也紅（systems 指定的那一道） ⇒ 已於 feat/unbound-key-semantics（2026-09-30 這一輪） 實測紅
func _test_p7_not_allowed_says_why() -> void:
	print("\n── P7 綁定但當下不允許 ⇒ 給原因（且與①不同句）──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	# 佈置：在勢力裡（否則走的是「不在勢力」那條）、而【不是領袖】
	st.create_faction(pt.team_id)
	var fid: int = pt.faction_id
	var other := TeamData.new()
	other.team_id = 7911
	other.tile_pos = pt.tile_pos
	AnonTierSystem.add_anon(other, AnonCohort.TIER_PLEB, 3)
	st.teams[7911] = other
	st.factions[fid].leader_team_id = 7911      # ★把領袖換成別人 ⇒ 玩家不是領袖
	other.faction_id = fid
	if not st.factions[fid].member_team_ids.has(pt.team_id):
		st.factions[fid].member_team_ids.append(pt.team_id)
	print("   佈置：玩家隊 %d 在勢力 %d｜領袖＝Team%d" % [
		pt.team_id, fid, int(st.factions[fid].leader_team_id)])
	_check("★母體地板 A：玩家真的在勢力裡", pt.faction_id != -1)
	_check("★母體地板 B：玩家真的【不是】領袖（是領袖的話那一支走不到）",
		int(st.factions[fid].leader_team_id) != pt.team_id)
	# ★母體地板 C：KEY_A 真的【有綁】—— 不然這一格測的是①不是②
	_check("★★母體地板 C：`KEY_A` 在 faction mode 真的有綁（否則這格測的是①）",
		bool(node.call("_faction_mode_binds_key", KEY_A)))
	node.set("_faction_mode", true)
	node._feedback_line.text = ""
	var fp_before: String = StateFingerprint.compute(st)
	node.call("_handle_faction_mode", KEY_A)
	var said: String = String(node._feedback_line.text)
	print("   按 A（非領袖）⇒ 回饋句 = 「%s」" % said)
	_check("★★★②有話說（不是靜默）", said.strip_edges() != "")
	_check("★★★②的句子【不是】①那一句（兩種無作用要分得出來）",
		not said.contains(SPEC_FEEDBACK_TOKEN))
	_check("★②也不改狀態：fp 前後逐位元相同",
		StateFingerprint.compute(st) == fp_before)
	_check("★②也不關模式", bool(node.get("_faction_mode")))
	await _free_ui(node)
	_cell("_test_p7_not_allowed_says_why")


# ══ P8：early return 的母體普查 —— ★四數相加要等於總數 ═══════════════════════
# ★★★systems 給的是【三桶】（有句子／具名例外／總數），而實測分類法要【四桶】：
#   最大的那一桶是他三桶裡沒有的 ——「做完事就 return」（畫面已更新，不是拒絕）。
#   ⇒ ★而我照自己那條處置：**最後一格永遠是「以上皆非」且要去數它多大；它最大就是分類法錯**。
#   ⇒ 所以本格印四欄並斷言四數相加 ＝ 總數，而不是硬把 9 個「做完事」塞進另兩桶。
# ★判準（機械，不靠我逐站讀）：以那個 `return` 之前 8 行的視窗為據 ——
#   ·有 `_set_feedback`／`_log_event`／`_refuse_unbound_key` ⇒ 有句子
#   ·有 `gate-ok:` 標記 ⇒ 具名例外
#   ·有 `command_player` ⇒ 執行了一道令（結果句由消費點產生）
#   ·以上皆非 ⇒ ★「以上皆非」那一桶，而它【必須逐站列名】
# 負對照：拿掉那個 `gate-ok:` 標記 ⇒ 具名例外 0 個 ⇒ 已於 feat/unbound-key-semantics（2026-09-30 這一輪） 實測紅
func _test_p8_early_return_census() -> void:
	print("\n── P8 early return 母體普查（四桶）──")
	var src: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	var lines: PackedStringArray = src.split("\n")
	var total: int = 0
	var with_say: int = 0
	var named_exempt: int = 0
	var with_cmd: int = 0
	var none_of_above: Array = []
	for i in range(lines.size()):
		var t: String = lines[i].strip_edges()
		if not (t.begins_with("func _handle_") and t.contains("_mode(keycode")):
			continue
		var fn: String = t.substr(5, t.find("(") - 5)
		var en: int = i + 1
		while en < lines.size() and not lines[en].begins_with("func "):
			en += 1
		for j in range(i, en):
			var u: String = lines[j].strip_edges()
			if u.begins_with("#"):
				continue
			if not (u == "return" or u.begins_with("return ")):
				continue
			total += 1
			var win: String = ""
			for k in range(maxi(i, j - 8), j):
				win += lines[k] + "\n"
			if win.contains("gate-ok:"):
				named_exempt += 1
			elif win.contains("_set_feedback") or win.contains("_log_event") \
					or win.contains("_refuse_unbound_key"):
				with_say += 1
			elif win.contains("command_player"):
				with_cmd += 1
			else:
				none_of_above.append("%s:%d" % [fn, j + 1])
	print("   總 early return %d" % total)
	print("     ①有句子（_set_feedback／_log_event／_refuse_unbound_key）＝ %d" % with_say)
	print("     ②具名例外（gate-ok:）                                  ＝ %d" % named_exempt)
	print("     ③執行了一道令（結果句由消費點產生）                      ＝ %d" % with_cmd)
	print("     ④★以上皆非（逐站列名）                                  ＝ %d" % none_of_above.size())
	for x in none_of_above:
		print("        · %s" % String(x))
	_check("★母體地板：總數 > 0（0 的話本格什麼都沒驗）", total > 0)
	_check("★★★四數相加 ＝ 總數（%d ＋ %d ＋ %d ＋ %d ＝ %d／%d）" % [
		with_say, named_exempt, with_cmd, none_of_above.size(), total,
		with_say + named_exempt + with_cmd + none_of_above.size()],
		with_say + named_exempt + with_cmd + none_of_above.size() == total)
	_check("★★具名例外至少一個（0 的話那個標記沒接上）", named_exempt >= 1)
	print("   ★★★而「以上皆非」那一桶【不是債】：本輪逐站開檔看過，它們是")
	print("     『做完事就 return』（選了一項／打了一個字／退了一層 —— 畫面已更新）。")
	print("     ⇒ 它們不需要句子，而它們【必須列名】：不列名的話下一次有人往這一桶")
	print("       加進一個【真的靜默拒絕】，那一桶的數字只會 +1 而沒有人看得出差別。")
	_cell("_test_p8_early_return_census")

# ── UI harness（與 ui_flow_test 同形：本床要真的 node 才按得到鍵）──
# ★seed 是硬條件（`ui_flow_test` 檔頭的血證）：Godot【每個行程開機時全域 RNG 是隨機的】
#   ⇒ 不 seed 的床每次跑的世界都不同 ⇒ 卷面會無故飄。
func _make_ui():
	seed(20260930)
	var scene: PackedScene = load("res://scenes/TextUI.tscn")
	var node = scene.instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	return node

func _free_ui(node) -> void:
	get_root().remove_child(node)
	node.free()
	await process_frame
