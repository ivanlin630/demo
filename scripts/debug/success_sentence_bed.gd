extends SceneTree
# @bed-kind: acceptance
# slice: 成功的結果句要用 handler 自己的話（spec 2026-09-25，一行改動／67 條句子）
#
# ★★★這張票修的是【一條原則只被套用在一半的分支上】：
#   `sim_runner.gd` 的結果句組裝算出了 `why`（handler 自己回的話），
#   卻只餵給【拒絕】那一支；成功那一支寫死「完成」
#   ⇒ 全庫 67 個成功回傳都帶話，而【一句都到不了玩家】。
#
# ★★而這支床最重要的一格不是 P1（換得上），是 P2（母體看得見）——
#   spec §6① 逐字：「那是我沒做的功課，交給卷面做。」
#   ⇒ 67 條裡哪幾條讀起來不像結果，要由【卷面】自己現形，不是等玩家撞到。
#
# ★三前綴（spec §9）：名字說出【改它要憑什麼】
#   SPEC_*      來自 spec        ⇒ 改它要回去改 spec
#   MEASURED_*  一次量測的現值   ⇒ 改它要重量一次
#   EXPECT_*    床自己宣告的     ⇒ 它本來就是自比，守的是【有沒有跑完】

var _errors: int = 0
var _cells_ran: Array = []
# ★失敗行帶【格名】token：負對照驅動器的 expect 是格子訊息的第二份拷貝
#   ⇒ 改一次措辭就誤報 NOT-RED（2026-09-25 發生四次）⇒ 讓它認【格】不認【句子】。
var _cur_cell: String = ""

const EXPECT_CELLS: Array = [
	"_test_p1_handler_words_reach_the_player",
	"_test_p2_population_is_visible",
	"_test_p3_empty_falls_back_by_injection",
	"_test_p4_rejection_branch_untouched",
	"_test_p5_text_is_not_in_the_fingerprint",
]

# ★來自 spec 的常數（★動工前我在 origin/main 8c77f542a 上【重量過】，三個都一致）
# ★★★67 → 68（2026-09-30 通商票）：玩家接受通商那一支 arm 新增了一條 `ok: true` 回傳
#   （`_accept_diplomacy` 的 `"propose_trade"`：`{ ok: true, msg: "與 TeamN 談成通商…" }`）
#   ⇒ 這一格【紅得對】：它的工作就是在成功回傳的母體變動時叫一聲。
#   ★而處置是【重量】不是【放寬】：我把數字改成實測的 68，而不是把斷言拿掉。
#   ★★這一族今天第四次（一張票改的就是閘）—— 而抓到它的是
#     「改完之後要重跑那支床本身」那條紀律，不是我想起來。
const SPEC_SUCCESS_RETURNS: int = 70
# ★★★★★68 → 70（2026-10-06，進貢提案那張票）——【基準更新】，而它是我造的：
#   那張票在 `player_command_system` 新增**兩句成功結果句**
#     ·接受：「收下 Team%d 的貢品（+%.0f 錢）」（還有一條「對方身上沒有錢可以給」）
#     ·拒絕：「婉拒 Team%d 的提案」
#   ⇒ 欄③的 `"ok": true` 條數 68 → 70。
#   ★這個數是**從床自己的輸出逐字抄**的（它印「掃到 80 條 ＝ 排除 10 ＋ 剩餘 70」），
#     不是推算的 —— 而我**先跑紅才改它**（70／68 那一行就是那個紅）。
#   ★★而這一格的方向是「**剩餘條數 ＝ 這個常數**」⇒ 它對**兩個方向**都會紅：
#     少寫一句結果句也紅、偷偷多一句也紅 ⇒ 所以它不能只往上調，要跟著實際動。
# ★★★★★【母體排除「純查詢前置檢查」】（systems 裁 (乙) 2026-10-01）——
#   本格問的是「**成功結果句**用 handler 自己的話」，而 `precheck_*` 的
#   `{"ok": true, "reason": ""}` **沒有句子** ⇒ 把它算進來是**稀釋母體**
#   （一個真的「少了句子」的 handler 會更容易躲過去）。
#   ★★而處置是**排除母體**不是**把 68 調大**：
#     把常數調大 ＝ 讓守衛閉嘴；排除母體 ＝ 改它在問什麼。
#   ★★★排除三件缺一不可：①宣告在一處（下面這個前綴）②判準錨在**函式體**
#     （不裸掃整檔）③**反向掃**（長得像前置檢查而不在那個前綴下的 ⇒ 紅並指名）。
const SPEC_PRECHECK_PREFIX: String = "precheck_"
const SPEC_REGISTRY_ACTIONS: int = 50
# ★★★★★51 → 50（2026-10-01，「直接成交」那條路線退場 ⇒ registry 少一列）——
#   ★這個數是從**床自己的輸出**抄的（它紅在「50／51」那一行），不是推算的。
#   ★★而本處值得記：退場票的 spec 用的是【指名清單】（§3 逐一列出要改哪幾處），
#     而**那份清單沒有點到這一支床** —— 接住它的是「跑一遍然後看它紅在哪」。
#     ⇒ 判準：**指名清單會漏，而跑出來的紅不會**
#       ⇒ 指名是為了「不要誤改」，不是為了「不會漏」；兩者要各自有機制。
#   ★★★而它的負對照（本檔 :126 那一行）逐字寫著「從 registry 拿掉一個 action（51→50）」
#     ⇒ 那一道對照**今天真的發生了**（而且是正式改動不是擾動）
#     ⇒ 那一行的 51→50 不動：它記的是**那一天**那道對照的數，不是現況。
const SPEC_NON_REGISTRY_DIFF: int = 3


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL][%s] %s" % [_cur_cell, msg])

func _fresh() -> Array:
	seed(20260929)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, SimRunner.new()]

# 送一道指令、推一顆 tick、回最後那一句結果句
func _say(st: WorldState, runner: SimRunner, name: String, args: Dictionary) -> String:
	var bridge := SimBridge.new(runner, st)
	bridge.command_player(name, args)
	runner.advance_tick(st, Vector2i(-1, -1))
	if st.command_results.is_empty():
		return ""
	return String(st.command_results[st.command_results.size() - 1].get("text", ""))


func _initialize() -> void:
	print("=== 成功結果句用 handler 自己的話 ===")
	_test_p1_handler_words_reach_the_player()
	_test_p2_population_is_visible()
	_test_p3_empty_falls_back_by_injection()
	_test_p4_rejection_branch_untouched()
	_test_p5_text_is_not_in_the_fingerprint()
	var miss: Array = []
	for c in EXPECT_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== success_sentence DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECT_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══════════ P1［換得上：結果句 ＝ 動作人話 ＋ handler 的話］══════════
# 負對照：把組裝那一行改回寫死「完成」⇒ 必紅
# 負對照：把成功那一支的條件改成 `if true`（＝無條件寫死「完成」） ⇒ 已於 feat/success-sentence（2026-09-29） 實測紅
func _test_p1_handler_words_reach_the_player() -> void:
	_cur_cell = "_test_p1_handler_words_reach_the_player"
	print("\n── P1 handler 的話到得了玩家 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var ptid: int = st.get_player_team_id()
	_check("★母體地板①：有玩家隊（tid=%d）" % ptid, ptid != -1)
	if ptid == -1:
		_cell(_cur_cell)
		return
	var tp: Vector2i = st.teams[ptid].tile_pos
	var txt: String = _say(st, pair[1], "move_to", {"tile_q": tp.x + 1, "tile_r": tp.y})
	print("   結果句：「%s」" % txt)
	_check("★母體地板②：真的產出了一句結果句（非空）", txt != "")
	# ★★判準是【它不再是寫死的「完成」】＋【它帶了 handler 的話】
	#   ★★★而「不等於『…：完成』」單獨不夠：一個空的 msg 也會讓它變成別的樣子
	#     ⇒ 所以要正面斷言【前綴在】而且【冒號後面不是「完成」】
	_check("★前綴在（玩家分辨得出哪一道指令）", txt.begins_with("移動到"))
	_check("★★★冒號後面不再是寫死的「完成」（實測「%s」）" % txt, not txt.ends_with("：完成"))
	_cell(_cur_cell)


# ══════════ P2［★★★母體看得見：67 條全印、不分類］══════════
# ★spec §6① 逐字：「那是我沒做的功課，交給卷面做。」
# ★★三條硬規（都是踩過才有的）：
#   ①不得以 `return {` 為錨 —— 4 處 `result = {…}` 賦值型會被漏掉，
#     而它們 ok:true 而語意是「我選擇拒絕」（拒絕外交提案／拒絕勒索／婉拒收留／無人可繼承）
#   ②不得用關鍵字分類 —— 血證：「Team%d 接受邀請」被誤判成中間步驟，
#     因為【「邀請」裡面有「請」】⇒ ★判準要用【詞】不是【字】⇒ 所以全印、不分類
#   ③沒有字面文案的單獨一類（`r.get("msg","")` 轉出別人的話／`msg` 變數）
#     ⇒ 不分類的話卷面會出現讀不出內容的列，而那看起來像抽取壞了
# ★★★母體地板：印出來的條數要跟【來自 spec 的常數】比 ——
#   不要拿「印了幾條」跟「掃到幾條」比（那是自己跟自己比，寫幾條都會綠）。
# 負對照：從 registry 拿掉一個 action（51→50）／或把一個成功回傳的 `"ok": true` 改成 `1 == 1`（67→66） ⇒ 已於 feat/success-sentence（2026-09-29） 實測紅
func _test_p2_population_is_visible() -> void:
	_cur_cell = "_test_p2_population_is_visible"
	print("\n── P2 母體看得見（三欄＋邊界句）──")
	var src: String = FileAccess.get_file_as_string("res://scripts/simulation/player_command_system.gd")
	_check("★母體地板①：讀得到原始碼（%d 字元）" % src.length(), src.length() > 1000)
	var lines: PackedStringArray = src.split("\n")

	# ══ 欄① registry 的 action 數（`execute_action` 那一行的 `.call()` 涵蓋它們全部）
	var reg_at: int = src.find("_action_registry = {")
	_check("★母體地板②：找得到 registry 的【賦值】處（★不是宣告行的空 {}）", reg_at != -1)
	var reg_keys: int = 0
	if reg_at != -1:
		var open_at: int = src.find("{", reg_at)
		var depth: int = 0
		var k: int = open_at
		var body: String = ""
		while k < src.length():
			var c: String = src[k]
			if c == "{":
				depth += 1
			elif c == "}":
				depth -= 1
				if depth == 0:
					body = src.substr(open_at, k - open_at + 1)
					break
			k += 1
		for l in body.split("\n"):
			var t: String = l.strip_edges()
			if t.begins_with("#"):
				continue
			# ★★比對【不得寫死空白數】：registry 行是 `"trade":                  _action_trade,`
			#   ⇒ 我第一版寫 `"\": _action_"`（一個空格）⇒ 只命中 2 條而不是 51（實測）
			#   ⇒ ★判準改成【以引號開頭 ＋ 含 _action_】，不管中間排版
			if t.begins_with("\"") and t.contains("_action_"):
				reg_keys += 1
	print("   欄①registry action 數 = %d（spec 說 %d）" % [reg_keys, SPEC_REGISTRY_ACTIONS])
	_check("★★欄①與【spec 的常數】相符（%d／%d）" % [reg_keys, SPEC_REGISTRY_ACTIONS],
		reg_keys == SPEC_REGISTRY_ACTIONS)

	# ══ 欄② 不經 registry 而可抵達的路徑 —— ★機械導出：定義集合 − registry 值集合
	var defs: Array = []
	var vals: Array = []
	for l in lines:
		var t: String = l.strip_edges()
		if t.begins_with("#"):
			continue
		if t.begins_with("func _action_"):
			defs.append(t.substr(5, t.find("(") - 5))
		# ★同上：不寫死空白 —— 抓 `_action_` 那個 token 本身
		if t.begins_with("\"") and t.contains("_action_"):
			var at2: int = t.find("_action_")
			var v: String = t.substr(at2).trim_suffix(",").strip_edges()
			vals.append(v)
	var diff: Array = []
	for d in defs:
		if not vals.has(d):
			diff.append(d)
	print("   欄②定義 %d／registry 值 %d ⇒ ★差集 %d：%s" % [
		defs.size(), vals.size(), diff.size(), str(diff)])
	print("      ＋早返／inline：choose_heir、ignore")
	print("      ＋第二條分派邊 execute_action_with_target 的 4 個 case")
	print("      ＋轉出別系統 dict：_action_submit_trade_offer（★另一支已退場 2026-10-01）")
	print("        （★列【函式名】不列行號 —— 行號逐樹會飄）")
	_check("★★★欄②差集與【spec 的常數】相符（%d／%d）" % [diff.size(), SPEC_NON_REGISTRY_DIFF],
		diff.size() == SPEC_NON_REGISTRY_DIFF)

	# ══ 欄③ 成功回傳逐條列名（寬視窗：ok:true 那一行往後看 3 行找話）★不以 return { 為錨
	var rows: Array = []
	var no_literal: Array = []
	# ★★★★★【先把每一行歸到它所屬的函式】—— 判準錨在**函式體**不是裸掃整檔
	#   （★血證：同一支床裡兩個抽取式而只有一個做對 —— 2026-10-01）
	var owner: Array = []          # 每一行屬於哪一支函式
	var cur_fn: String = ""
	for i0 in range(lines.size()):
		var l0: String = String(lines[i0])
		if l0.begins_with("func "):
			cur_fn = l0.substr(5, maxi(0, l0.find("(") - 5))
		owner.append(cur_fn)
	var excluded: Array = []       # ★逐名（不是只報一個數）
	for i in range(lines.size()):
		var t: String = String(lines[i]).strip_edges()
		if t.begins_with("#"):
			continue
		if not t.contains("\"ok\": true"):
			continue
		# ★排除「純查詢前置檢查」：它的 `ok:true` 不帶句子 ⇒ 不是結果句
		if String(owner[i]).begins_with(SPEC_PRECHECK_PREFIX):
			excluded.append("%d: %s()" % [i + 1, String(owner[i])])
			continue
		var win: String = ""
		for j in range(i, mini(i + 4, lines.size())):
			win += String(lines[j]) + " "
		var a: int = win.find("\"msg\"")
		if a == -1:
			a = win.find("\"message\"")
		var txt: String = win.substr(a, 92).strip_edges() if a != -1 else "（3 行內找不到話）"
		# ★★★分類只看【那個 msg 的值本身】，不看整個 4 行視窗 ——
		#   我第一版拿整段去判 ⇒ 視窗咬到【隔壁那個 return】的 `r.get(`
		#   ⇒ `:1135`／`:1136` 明明有文案卻被分到「沒有字面文案」（實測 6 條裡 2 條是誤分）。
		#   ⇒ ★視窗太寬與太小是同一軸的兩邊：太小回空集合、太寬把鄰居算進來。
		var val: String = ""
		if a != -1:
			var after: String = win.substr(a + 5)
			var c1: int = after.find(":")
			if c1 != -1:
				var seg: String = after.substr(c1 + 1)
				var cut: int = seg.length()
				for ch in [",", "}"]:
					var q: int = seg.find(ch)
					if q != -1 and q < cut: cut = q
				val = seg.substr(0, cut).strip_edges()
		var is_literal: bool = val.begins_with("\"")
		if a == -1 or not is_literal:
			no_literal.append("%d: %s" % [i + 1, txt])
		else:
			rows.append("%d: %s" % [i + 1, txt])
	var total: int = rows.size() + no_literal.size()
	# ★★★★★【三個數都印出來給人看】（systems 裁 2026-10-01）——
	#   ★不是「斷言 78−10＝68 成立」而是**把那個減法印在卷面上**：
	#     兩個數字相等而量綱不同是今天栽過的形狀 ⇒ 要讓讀的人看見它怎麼來的。
	print("   欄③母體：掃到 `\"ok\": true` 共 %d 條 ＝ 排除 %d 條（純查詢前置檢查）＋ 剩餘 %d 條" % [
		total + excluded.size(), excluded.size(), total])
	print("   ── 被排除的（逐名；★它們的 `ok:true` 不帶句子 ⇒ 不是結果句）──")
	for e in excluded:
		print("     " + String(e))
	print("   ★★而 `precheck_*` 有 11 支而這裡只排除到 %d 條 —— 那個差是**真的**：" % excluded.size())
	print("     `precheck_leave_loot` 的成功路徑是 `return precheck_take_loot(state, pt)`")
	print("     （條件共用、不抄第二份）⇒ 它**沒有自己的 `\"ok\": true` 字面** ⇒ 掃不到它。")
	print("     ⇒ ★「11 支」與「10 個字面」量綱不同：前者數函式、後者數字面。")
	# ★★★反向掃：長得像前置檢查而**不在**那個前綴下的 ⇒ 紅並指名
	#   （防命名慣例的例外，也防有人把 `precheck_*` 改名）
	# ★★★★★【反向掃要印出它自己的母體】（systems 裁 2026-10-01 §2）——
	#   ★回 `[]` 有兩種成因而**卷面上長得一樣**：
	#     (a) 真的沒有違規（我們要的）  (b) **母體為空**（抽取式一個成員都沒抓到）
	#   ⇒ 所以把三個數印在**同一段**：掃到幾行 `ok:true`／其中「有 `reason` 無 `msg`/`message`」
	#     幾行（＝反向掃**真正的母體**）／其中不在 `precheck_*` 內幾行（＝那個 `[]` 的**分子**）
	#   ⇒ ★★判準（systems 自己寫過的）：**任何回 0／回空的量，要在印出那個 0 的同一行問
	#     「有沒有可能是我沒看到，而不是它不存在」**。
	var looks_like: Array = []
	var n_ok_lines: int = 0          # 掃到幾行 `ok: true`（含被排除的）
	var n_reason_shape: int = 0      # 其中「有 reason 無 msg/message」＝ 反向掃真正的母體
	for i2 in range(lines.size()):
		var t2: String = String(lines[i2]).strip_edges()
		if t2.begins_with("#") or not t2.contains("\"ok\": true"):
			continue
		n_ok_lines += 1
		var w2: String = ""
		for j2 in range(i2, mini(i2 + 3, lines.size())):
			w2 += String(lines[j2]) + " "
		var is_reason_shape: bool = w2.contains("\"reason\"") and not (
			w2.contains("\"msg\"") or w2.contains("\"message\""))
		if not is_reason_shape:
			continue
		n_reason_shape += 1
		if String(owner[i2]).begins_with(SPEC_PRECHECK_PREFIX):
			continue
		looks_like.append("%d: %s()" % [i2 + 1, String(owner[i2])])
	print("   ★反向掃的母體：掃到 `\"ok\": true` %d 行 ⇒ 其中「有 `reason` 無 `msg`/`message`」%d 行（＝母體）⇒ 其中不在 `%s*` 內 %d 行（＝那個清單）" % [
		n_ok_lines, n_reason_shape, SPEC_PRECHECK_PREFIX, looks_like.size()])
	print("     ⇒ ★`[]` 的意思要看中間那個數：母體 %d > 0 ⇒ 它是「沒有違規」；母體 0 ⇒ 它是「母體為空」。" % n_reason_shape)
	_check("★★母體地板：反向掃的母體不是空的（%d；0 ⇒ 下面那個 `[]` 什麼都沒說）" % n_reason_shape,
		n_reason_shape > 0)
	print("   ★反向掃：帶 `reason` 而不帶 `msg`/`message`、又不在 `%s*` 下的 ＝ %s" % [
		SPEC_PRECHECK_PREFIX, str(looks_like)])
	_check("★★★★反向掃：沒有「長得像前置檢查而不在那個前綴下」的（有 ⇒ 命名慣例有例外或有人改名：%s）"
		% str(looks_like), looks_like.is_empty())
	_check("★母體地板：真的排除到東西（0 ⇒ 這個排除沒有生效而下面那條會拿舊母體去比）",
		excluded.size() > 0)
	print("   欄③成功回傳共 %d 條（spec 說 %d）｜其中【沒有字面文案】%d 條" % [
		total, SPEC_SUCCESS_RETURNS, no_literal.size()])
	# ★★★全印、不分類 —— 由讀的人判哪幾條不像結果句
	for r in rows:
		print("     " + r)
	print("   ── 沒有字面文案的（轉出別人的話／變數）──")
	for r in no_literal:
		print("     " + r)
	_check("★★★欄③條數與【spec 的常數】相符（%d／%d）" % [total, SPEC_SUCCESS_RETURNS],
		total == SPEC_SUCCESS_RETURNS)

	# ══ 邊界句（必印）
	print("   ★邊界：本格【沒有】數「收了但沒人轉出」的回傳")
	print("     （例：`_interaction.subjugate_team(...)` 的回傳沒有人轉出 ⇒ 不屬於母體）")
	print("   ★★而邊界非印不可的理由：這份 spec 在這一點上錯過兩次，而【兩次錯的方向相反】")
	print("     （單檔少算漏轉出／五檔加總多算收了沒人轉出的）")
	print("     ⇒ ★★★一個會往兩個方向錯的量，光看數字永遠判不出它在哪一邊。")
	_cell(_cur_cell)


# ══════════ P3［空的仍退回「完成」—— ★注入式對照］══════════
# ★★★它的母體今天是 0：實測 67／67 都帶話 ⇒ 不注入的話這一格是【恆綠的空母體】。
#   ⇒ 所以餵一個【回空 msg】的假 handler，並★把命中次數印出來（不只印結果）。
# 負對照：把條件改成 `if false`（＝空 msg 也照用）⇒ 實測印出空冒號「行動：take_loot：」 ⇒ 已於 feat/success-sentence（2026-09-29） 實測紅
func _test_p3_empty_falls_back_by_injection() -> void:
	_cur_cell = "_test_p3_empty_falls_back_by_injection"
	print("\n── P3 空的仍退回「完成」（注入式）──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	# ★注入：把 registry 裡某一個 action 換成一支【回空 msg】的假 handler
	# ★★★注入點是【消費點真正會用到的那一個實例】：
	#   `sim_runner:557` 走 `_cmd_api.dispatch(...)`，而 `PlayerCommandApi:3` 自己 new 了一個
	#   `_cmd_sys` ⇒ ★注入點是 `runner._cmd_api._cmd_sys`，不是 runner 身上。
	#   ★★我第一版在 runner 身上找 `_cmd_sys` ⇒ 注入到了【沒有人會用的地方】
	#     ⇒ 命中 0 次，而結果句是【真 handler】的話 ⇒ ★那是「注入沒接電」的樣子。
	var api = runner.get("_cmd_api")
	_check("★母體地板①a：runner 持有 _cmd_api", api != null)
	var cmd: PlayerCommandSystem = api.get("_cmd_sys") if api != null else null
	_check("★母體地板①b：而 api 持有 _cmd_sys（注入點）", cmd != null)
	if cmd == null:
		_cell(_cur_cell)
		return
	var hits: Array = [0]
	var fake: Callable = func(_s, _t, _pt, _ptid):
		hits[0] += 1
		return {"ok": true, "msg": ""}
	# ★★★注入點要選【只能經 registry 抵達】的那條路：
	#   `refresh_targets` 同時是【頂層 verb】（player_command_api.gd:268）與 registry 項（:104）
	#   ⇒ 我第一版用 `command_player("refresh_targets", {})` 送 ⇒ 走 verb 那條、★根本沒碰 registry
	#   ⇒ 命中 0 次，而結果句是【真 handler】的話（實測「重掃同格對象：已重掃同格對象」）
	#   ⇒ ★★所以改走 `execute_action`，它才會 `_action_registry[action].call(...)`
	cmd._action_registry["take_loot"] = fake
	var txt: String = _say(st, runner, "execute_action",
		{"action_id": "take_loot", "target": {"kind": "none"}})
	print("   假 handler 命中 %d 次｜結果句：「%s」" % [hits[0], txt])
	# ★★母體地板②：注入【真的被走到】—— 命中 0 次的話下面那一格是空談
	_check("★★母體地板②：注入的假 handler 真的被呼叫（命中 %d 次）" % hits[0], hits[0] >= 1)
	_check("★★★空 msg ⇒ 仍印「…：完成」（實測「%s」）" % txt, txt.ends_with("：完成"))
	_check("★而它沒有印出空的冒號（不是「…：」結尾）", not txt.ends_with("："))
	_cell(_cur_cell)


# ══════════ P4［拒絕那一支沒動：句子逐字不變］══════════
# 負對照：把拒絕那一支的「：被拒絕（」改成別的措辭 ⇒ 已於 feat/success-sentence（2026-09-29） 實測紅
func _test_p4_rejection_branch_untouched() -> void:
	_cur_cell = "_test_p4_rejection_branch_untouched"
	print("\n── P4 拒絕那一支逐字不變 ──")
	var pair: Array = _fresh()
	var txt: String = _say(pair[0], pair[1], "move_to", {"tile_q": 9999, "tile_r": 9999})
	print("   結果句：「%s」" % txt)
	_check("★母體地板：真的被拒絕了（句子非空）", txt != "")
	_check("★★拒絕句的形狀逐字不變（含「：被拒絕（」）", txt.contains("：被拒絕（"))
	_check("★★★而它【帶原因】（不是「沒有給原因」）", not txt.contains("沒有給原因"))
	_cell(_cur_cell)


# ══════════ P5［★結果句的【文字】不進 fp ⇒ world-fp 逐字不變］══════════
# ★★★這一格是【訂正後】的形狀（2026-09-25）：spec 原本寫「fp 變是預期內的」，
#   而那是一格【永遠滿足不了】的要求 —— `state_fingerprint.gd` 對 `command_results`
#   只印 `res=%d`（筆數），不印文字；而同段註解自己寫著「pend 印【內容】不印個數」
#   ⇒ 印內容是【只給 pend 的例外】。
# ★★而它反過來之後是一個【有內容】的不變量：**改文案不會動世界** ——
#   那正是這張票敢動 67 條句子的前提。
# ★負對照：把 `res=%d` 改成印 `str(state.command_results)` ⇒ world-fp 必變 ⇒ 這一格必紅。
#   ★★★此擾動【不得 commit】：`state_fingerprint.gd` 是所有 fp 基準的根。
# 負對照：把 `state_fingerprint.gd` 的 `command_results.size()` 改成 `str(state.command_results)`。★★此擾動【不得 commit】：那個檔是所有 fp 基準的根 ⇒ 已於 feat/success-sentence（2026-09-29） 實測紅
func _test_p5_text_is_not_in_the_fingerprint() -> void:
	_cur_cell = "_test_p5_text_is_not_in_the_fingerprint"
	print("\n── P5 結果句的文字不進 fp ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var ptid: int = st.get_player_team_id()
	if ptid == -1:
		_check("★母體地板：有玩家隊", false)
		_cell(_cur_cell)
		return
	var tp: Vector2i = st.teams[ptid].tile_pos
	var t1: String = _say(st, runner, "move_to", {"tile_q": tp.x + 1, "tile_r": tp.y})
	var fp_before: String = StateFingerprint.compute(st)
	var n_before: int = st.command_results.size()
	# ★手改那一句的【文字】（不改筆數）⇒ fp 必須逐字不變
	st.command_results[n_before - 1]["text"] = "★這是被手改過的字串，長度與內容都不同★"
	var fp_after: String = StateFingerprint.compute(st)
	print("   原句「%s」｜筆數 %d（改文字不改筆數）" % [t1, n_before])
	print("   fp %s… → %s…" % [fp_before.substr(0, 12), fp_after.substr(0, 12)])
	_check("★母體地板①：真的有一筆結果句可以改（%d 筆）" % n_before, n_before >= 1)
	_check("★母體地板②：fp 產得出來（非空）", fp_before != "" and fp_after != "")
	_check("★★★改結果句的【文字】⇒ world-fp【逐字不變】（改文案不會動世界）",
		fp_before == fp_after)
	# ★對照：改【筆數】必須讓 fp 變 —— 沒有這一格，上面那一格對「fp 根本沒讀佇列」也成立
	st.command_results.append({"tick": 0, "seq": 999, "ok": true, "text": "x"})
	var fp_more: String = StateFingerprint.compute(st)
	_check("★★對照：改【筆數】⇒ fp 必須變（證明 fp 真的在讀這個佇列）", fp_after != fp_more)
	_cell(_cur_cell)
