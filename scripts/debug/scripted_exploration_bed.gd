extends SceneTree
# @bed-kind: invariant
# slice: 死輸入探索床（把每個動詞 × 每種目標各按一遍，每步核四條）
#        spec `docs/superpowers/specs/2026-09-29-scripted-exploration-bed-HOW.md`
#        上游：用戶逐字「先跑死輸入」；藍圖要它的【人可讀矛盾清單】交給用戶。
#
# ★★★這支床的產物不是綠燈，是【一份清單】：它只負責把矛盾列出來（spec §3：修不在本票）。
#   ⇒ 所以它同時輸出機器讀的 tsv 與人讀的 txt，而人讀那一份要能單獨被讀懂。
#
# ★★母體是【三層】而三個數不同（spec §1②）：
#   層1 `PlayerCommandApi.dispatch` 的頂層動詞
#   層2 `_action_registry` 的鍵 ＋ `execute_action_with_target` 的 case
#   層3 forced_event 的 action 種類 × 每種的回應集（★動態拿，不手抄）
#   ⇒ 三個數都印、各自跟常數比；★對不上【床紅並印差集】，不是自動採用新值。
#
# ★★★而【幾筆症狀】與【幾件事】要分開講：本輪 (d) 一族有數十筆，
#   而它們大多共用【同一處】成因（`describe()` 把參數原樣印給玩家）
#   ⇒ 不分群的報告會讓人以為有數十個獨立缺陷，而那個數字會決定下一個人怎麼排優先序。
#
# ★誠實限（我開檔量到、與 spec 不同的地方，逐條寫出來不默默改）：
#   1. spec 寫的 `_forced_responses()` **全庫不存在**；真名是
#      `PlayerCommandSystem.get_forced_response_options(state)`（:973）。
#      ⇒ 我用真名，並把差異寫在這裡（下一個人照 spec 去 grep 會找不到）。
#   2. 層2 的「51」在 spec §1② 與派工信裡是【兩種讀法】：
#      spec 說「registry ＝ 51，另外還有 4 個 case」，派工信說「registry ＋ case ＝ 51」。
#      ⇒ ★我不猜，兩個數都印並各自比。
#   3. 上游那個「37 動詞」到今天仍然對不上任何一層 ⇒ 不猜它指哪一層、不拿我的數覆蓋它。
#   4. 本床走 `SimBridge.command_player`（＝press-is-one-tick 釘的那個咽喉）
#      ⇒ 每一道指令都真的推一顆 tick、真的經過消費點 ⇒ 結果句是世界產的不是我編的。
#   5. 本床【不修】它抓到的任何東西（spec §3）。
#   6. ★★★2026-09-30 訂正：前一版的 (c) 判準用【索引區間】讀結果句，而 `command_results`
#      有 60 tick 的 TTL ⇒ 走過 60 步之後那個區間會變空 ⇒ 生出 41 筆【假的靜默】。
#      ⇒ 現在用那一道指令自己的 `seq` 去找它的句子。★而那 41 筆要從清單裡消失，
#        不是「改分類」—— 它們從來不是產品的症狀。

var _errors: int = 0
var _cells_ran: Array = []

# ── 母體的三個數（spec §2①：常數在這裡，量出來的數跟它比）──────────────────
const SPEC_VERBS_L1: int = 14
const SPEC_ACTIONS_L2: int = 51
const SPEC_FORCED_L3: int = 5

# ★(d) 零英文識別字的白名單 —— spec §5③ 明寫它「必須被印出來」，
#   而真正的內容由【跑出來的第一份卷面】決定（不是先寫死）。
#   ⇒ 本輪的第一份卷面決定了下面這些；★每一個都附理由。
const ID_WHITELIST: Array = [
	"team",      # 隊伍顯示名（玩家面到處是 Team%d，它是專有名詞不是 id）
	"tick",      # 時間單位，玩家面用它講「幾 tick」
	"coin",      # 資源名：玩家面既有措辭（食物寫「食物」而錢寫 coin）
	"food",
	"material",
	"goods",
	"heir",      # 繼承人回應的代號字首 heir_<pid>
]
# ★「英文識別字」的判準：連續 4 個以上的小寫字母或底線。
#   4 而不是 3：三個字母的縮寫在中文句子裡幾乎都是專有名詞。
const ID_PATTERN: String = "[a-z_]{4,}"

const EXPECTED_CELLS: Array = [
	"_test_p1_population_three_layers",
	"_test_p2_walk_layer1_verbs",
	"_test_p3_walk_layer2_actions",
	"_test_p4_walk_forced_events",
	"_test_p5_four_rules_have_teeth",
	"_test_p6_artifacts",
	"_test_p7_positive_control_fixtures",
	"_test_p8_two_readers_on_the_same_input",
	"_test_p11_every_action_has_a_label",
]

var _contradictions: Array = []      # 每筆 {rule, where, cause, detail}
var _steps_walked: int = 0
var _silent_by_design: Array = []    # ★按設計靜默的步：要被列出來，不是被吞掉
var _tree_sha: String = ""
# ★讀法的母體地板：這一輪【預期幾句／實得幾句】（systems 要求①）
var _expected_sentences: int = 0
var _got_sentences: int = 0


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _note(rule: String, where: String, detail: String, cause: String = "") -> void:
	_contradictions.append({"rule": rule, "where": where, "detail": detail, "cause": cause})

# ★成因分群的判準（機械）：那個英文字是不是【參數本身】——
#   describe() 的形狀是「<動詞名>：<原樣參數>」，參數就是 action_id／response_id／slot_id／res。
func _cause_of(sentence: String, offender: String, args: Dictionary) -> String:
	for key in ["action_id", "response_id", "slot_id", "res", "item_grade"]:
		if String(args.get(key, "")) == offender:
			return "describe() 把參數原樣印給玩家（player_command_api.gd:237 的 match）"
	if sentence.contains("：被拒絕（") or sentence.contains("：完成"):
		return "handler 自己回的 msg 裡有英文（那一句是 handler 寫的，不是 describe 產的）"
	return "未分類（★這是「以上皆非」那一桶，要去數它多大）"

# ★★★跑的是哪一顆 sha 要印在【同一份輸出裡】（派工信逐字：不是寫在信裡）。
func _read_sha() -> String:
	var out: Array = []
	var rc: int = OS.execute("git", ["rev-parse", "--short", "HEAD"], out, true)
	if rc != 0 or out.is_empty():
		return ""
	return String(out[0]).strip_edges()

func _fresh() -> Array:
	seed(20260930)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	var runner := SimRunner.new()
	return [st, runner, SimBridge.new(runner, st)]

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 從一段 match 區塊機械抽出字面字串（三層母體的導出，★不手抄）
func _match_literals(src: String, start_marker: String, end_marker: String) -> Array:
	var body: String = src
	var i: int = body.find(start_marker)
	if i < 0:
		return []
	body = body.substr(i + start_marker.length())
	var j: int = body.find(end_marker)
	if j >= 0:
		body = body.substr(0, j)
	var names: Array = []
	for line in body.split("\n"):
		var t: String = line.strip_edges()
		if not t.ends_with(":") or not t.begins_with("\""):
			continue
		for part in t.trim_suffix(":").split(","):
			var p: String = part.strip_edges()
			if p.begins_with("\"") and p.ends_with("\"") and p.length() > 2:
				var n: String = p.substr(1, p.length() - 2)
				if not names.has(n):
					names.append(n)
	return names

func _first_offender(sentence: String) -> String:
	var re := RegEx.new()
	re.compile(ID_PATTERN)
	for m in re.search_all(sentence):
		var w: String = m.get_string()
		var listed: bool = false
		for ok in ID_WHITELIST:
			if w.contains(String(ok)) or String(ok).contains(w):
				listed = true
		if not listed:
			return w
	return ""


# ══ 四條判準（★純函式：走訪與負對照【用同一份】，否則對照驗的是另一份 code）══
# (a) 守恆：coin 全域總量不得因一道玩家指令而變（★用既有 CoinAudit／InvariantAudit）
func _rule_a(coin_before: float, coin_after: float, inv: Array) -> String:
	if absf(coin_after - coin_before) > 0.001:
		return "coin 全域總量從 %.3f 變成 %.3f（一道指令只該搬動、不該改變總量）" % [
			coin_before, coin_after]
	if not inv.is_empty():
		return "InvariantAudit 回報 %d 條違反：%s" % [inv.size(), String(inv[0])]
	return ""

# (b) 回應↔結果一致：按了接受那一側，句子不得說「拒絕」
func _rule_b(response: String, sentence: String) -> String:
	var accepted: bool = response in ["accept", "accept_join", "accept_lead", "pay", "give"] \
		or response.begins_with("heir_")
	if accepted and sentence.contains("拒絕"):
		return "回應是「%s」（接受那一側），而句子說：%s" % [response, sentence]
	return ""

# (c) 必有回饋：每一道指令都要產出一句玩家看得到的句子
func _rule_c(sentence: String) -> String:
	if sentence.strip_edges() == "":
		return "這一道指令【沒有任何句子】（command_results 沒有新增，或新增了空字串）"
	return ""

# (d) 玩家面字串零英文識別字（白名單之外）
func _rule_d(sentence: String) -> String:
	# ★★★具名例外：「（未知動作：xxx）」「（未知部位：xxx）」「（未知設施：xxx）」這種形狀
	#   **是 spec 要求的**（不認得的 id 不准吞掉，要印出來讓人看得到少了哪一個）
	#   ⇒ 若本條把它算成症狀，判準就會跟 spec 打對台，而下一個人會為了讓床綠而去吞掉 id。
	#   ★★而例外只放在【那個括號形狀】裡：句子其他地方的英文照樣算症狀。
	var probe: String = sentence
	for marker in ["（未知動作：", "（未知部位：", "（未知設施：", "（未知事件：", "（未知：'"]:
		while probe.contains(marker):
			var i: int = probe.find(marker)
			var j: int = probe.find("）", i)
			if j < 0:
				break
			probe = probe.substr(0, i) + probe.substr(j + 1)
	var re := RegEx.new()
	re.compile(ID_PATTERN)
	var bad: Array = []
	for m in re.search_all(probe):
		var w: String = m.get_string()
		var listed: bool = false
		for ok in ID_WHITELIST:
			if w.contains(String(ok)) or String(ok).contains(w):
				listed = true
		if not listed and not bad.has(w):
			bad.append(w)
	if bad.is_empty():
		return ""
	return "玩家面句子裡有英文識別字 %s：%s" % [str(bad), sentence]

# ══ (e) 付出有回報 —— ★這一條【不在 spec 的四條裡】，是 P3 的命門逼出來的 ═══════
# spec §2③ 要求陽性對照的第一件（「招募扣錢而搬 0 人」）必須被列出來，
# 而四條沒有一條看得到它：(a) 只看【全域總量守恆】，而那個缺陷是
#   【錢從玩家搬到對方而玩家什麼都沒拿到】—— 總量完全守恆。
# ⇒ ★所以我加第五條，並把理由寫在這裡：不加的話 P3 的第一件列不出來，
#   而 spec 明寫「列不出來 ＝ 這支床沒接電」。★★我沒有改動那四條。
# ★★★具名豁免（同 (d) 的白名單，必須印出來）：有些動作【本來就沒有物質回報】——
#   付贖金／納貢買的是「不打這一架」。它們不是缺陷 ⇒ 列名豁免，而不是放寬判準。
const PAY_WITHOUT_GAIN_OK: Array = [
	"pay",              # 付勒索（買的是不打這一架）
	"demand_tribute",   # 索貢失敗時玩家不付錢；成功時是【收】不是付 ⇒ 兩側都不該命中，列名以防誤判
	"give",             # 施捨（買的是名聲／關係，不是物資）
]

func _rule_e(response_or_action: String, ok: bool, coin_before: float, coin_after: float,
		pop_before: int, pop_after: int, gained_res: bool) -> String:
	if PAY_WITHOUT_GAIN_OK.has(response_or_action):
		return ""
	if not ok:
		return ""
	if coin_after >= coin_before - 0.001:
		return ""
	if pop_after > pop_before or gained_res:
		return ""
	return "玩家付了 %.1f coin 而【這一側什麼都沒增加】（人口 %d→%d、資源沒增加），" % [
		coin_before - coin_after, pop_before, pop_after] + "而結果句說它成功了"

# ★★★共用讀法（R² 2026-09-30 抓到的：P8 原本自己內聯一份 ⇒ 若 `_step()` 的讀法退化，
#   P8 不會發現 ⇒ 我宣稱的「兩向」是假的，而真正在守它的是 P6 那個母體地板）。
#   ⇒ 處置照 R² 的第一個建議：**抽成共用函式**，`_step()` 與 P8 都呼它
#     ⇒ 「兩向」從此是真的（P8 動的是同一份 code）。
#   ★這一支就是「一個真相只存一份」在【判準】這一層的版本。
func _sentences_for_seq(st: WorldState, my_seq: int) -> Array:
	var text: String = ""
	var n: int = 0
	for row in st.command_results:
		if int(row.get("seq", -999)) == my_seq:
			text += String(row.get("text", ""))
			n += 1
	return [text, n]

# 走一步：下一道指令、推一顆 tick、核四條。回 [句子, 違反清單]
# expect_silent ＝ 這一步【按設計】不該有句子（消費點自己帶 silent 旗子）。
#   ★★它不是豁免權：卷面會把它列成「設計上的靜默」，而不是悄悄不算 ——
#     否則下一個人會以為這條路沒有人走過。
func _step(bridge: SimBridge, st: WorldState, where: String,
		name: String, args: Dictionary, response_for_b: String,
		expect_silent: bool = false) -> Array:
	var coin_before: float = CoinAudit.total(st)
	var before_n: int = st.command_results.size()
	# ★(e) 要的是【玩家這一側】的前後，不是全域（全域守恆與玩家有沒有拿到東西是兩件事）
	var pt0: TeamData = st.teams.get(st.get_player_team_id())
	var my_coin_before: float = float(pt0.resources.get("coin", 0)) if pt0 != null else 0.0
	var my_pop_before: int = pt0.population if pt0 != null else 0
	var my_res_before: Dictionary = {}
	if pt0 != null:
		for rk in ["food", "material", "goods"]:
			my_res_before[rk] = float(pt0.resources.get(rk, 0))
	# ★★「錢去哪了」有第三個去處：自己的匿名公庫（`anon_treasury`）——
	#   `train` 付的 30 coin 就是進那裡（餉銀，`AnonTreasuryBank.deposit`）
	#   ⇒ 錢【還在玩家這一側】⇒ 它不是「付了錢什麼都沒拿到」。
	#   ★第一版沒有這一軸 ⇒ (e) 把 `train` 報成症狀，而那是**我的 gain 軸不完整**，
	#     不是產品的缺陷。★★記在這裡而不是默默加：下一個人會想知道為什麼有這一軸。
	var my_treasury_before: float = pt0.anon_treasury if pt0 != null else 0.0
	var r: Dictionary = bridge.command_player(name, args)
	var my_seq: int = int(r.get("seq", -1))
	_steps_walked += 1
	# ★入列當下就被擋掉的（未知指令）不推 tick ⇒ 它的「句子」就是那個回傳
	if not bool(r.get("queued", false)):
		return [String(r.get("message", r.get("msg", ""))), []]
	# ★相容層②：`command_player` 自己推一顆 tick 是 #8 那張票做的。
	#   舊樹上它只入列 ⇒ 要自己推，否則「沒有句子」會是**我沒推 tick**造成的，
	#   而它在卷面上跟 (c) 真的被違反長得一樣。
	if not bridge.is_advancing():
		bridge.request_advance(1)
	while bridge.is_advancing():
		bridge.tick_step()
	# ★★★【訂正 2026-09-30】原本用索引區間讀（`range(before_n, size)`）——而那是錯的：
	#   `command_results` 有 TTL（`sim_runner.gd:517 RESULT_TTL_TICKS = TICKS_PER_HOUR = 60`），
	#   而本床每走一步就推一顆 tick ⇒ 走超過 60 步之後舊紀錄開始被剪掉
	#   ⇒ size 不再單調成長 ⇒ `range(before_n, size)` 變成【空區間】⇒ 我把它讀成「這一步沒有句子」。
	#   ⇒ ★那就是前一版報的【41 筆靜默】的真因：**它們是床的假紅，不是產品按了沒反應**。
	#     （而它們全部落在第二趟 kind=team，正是因為第一趟 14+51 步剛好跨過 60。）
	#   ⇒ ★★改成用【那一道指令自己的 seq】去找它的結果句 —— seq 由 `command_player` 回傳，
	#     它不會因為別人被剪掉而改變。
	var pair_read: Array = _sentences_for_seq(st, my_seq)   # ★共用讀法（P8 也呼這一支）
	var sentence: String = String(pair_read[0])
	var got_n: int = int(pair_read[1])
	# ★★★母體地板（systems 要求①）：新讀法要印【預期幾句／實得幾句】兩個數，
	#   不是只印結果 —— 舊讀法之所以能騙我一整輪，就是因為它只印「結果是空的」。
	#   ★一道被消費的指令預期恰好 1 句（silent 那一支除外 ⇒ 0 句，而它是具名例外）。
	_expected_sentences += 1
	_got_sentences += got_n
	var bad: Array = []
	var va: String = _rule_a(coin_before, CoinAudit.total(st), InvariantAudit.check(st))
	var vb: String = _rule_b(response_for_b, sentence)
	var vc: String = _rule_c(sentence)
	var vd: String = _rule_d(sentence)
	var pt1: TeamData = st.teams.get(st.get_player_team_id())
	var gained: bool = false
	if pt1 != null:
		for rk2 in my_res_before.keys():
			if float(pt1.resources.get(rk2, 0)) > float(my_res_before[rk2]) + 0.001:
				gained = true
		if pt1.anon_treasury > my_treasury_before + 0.001:
			gained = true
	var ve: String = ""
	if pt1 != null:
		var who: String = response_for_b if response_for_b != "" else String(args.get("action_id", name))
		ve = _rule_e(who, not sentence.contains("被拒絕"),
			my_coin_before, float(pt1.resources.get("coin", 0)),
			my_pop_before, pt1.population, gained)
	if vc != "" and expect_silent:
		_silent_by_design.append(where)
		vc = ""
	# ★★★(c) 的成因要把【那一刻的世界狀態】記下來，否則 41 筆靜默會變成
	#   41 筆「每一筆自己讀」，而它們很可能是【同一個前提】造成的。
	#   ⇒ 這裡記三件可觀測的事：玩家 person 還在嗎／在遭遇戰裡嗎／隊還在嗎。
	#   ★而本床【不判】它是產品缺陷還是佈置後果 —— 它只把那三個事實印出來（spec §3）。
	var ctx: String = ""
	if vc != "":
		var pp: PersonData = st.persons.get(st.player_id)
		var ptx: TeamData = st.teams.get(st.get_player_team_id())
		ctx = "靜默當下：玩家 person %s／遭遇戰 %s／玩家隊 %s" % [
			"在" if pp != null else "★不在（player_id=%d）" % st.player_id,
			"進行中" if st.encounter_active else "無",
			"在" if ptx != null else "★不在"]
	for pair in [["a", va], ["b", vb], ["c", vc], ["d", vd], ["e", ve]]:
		if String(pair[1]) != "":
			var cause: String = ""
			if String(pair[0]) == "c":
				cause = ctx
			if String(pair[0]) == "d":
				cause = _cause_of(sentence, _first_offender(sentence), args)
			bad.append([String(pair[0]), String(pair[1])])
			_note(String(pair[0]), where, String(pair[1]), cause)
	return [sentence, bad]


# ══ P1：母體三層（三個數，各自跟常數比；對不上印差集，不採用新值）════════════
func _test_p1_population_three_layers() -> void:
	print("\n── P1 母體：三層三個數 ──")
	var api_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_api.gd"))
	var l1_src: Array = _match_literals(api_src, "func dispatch(", "\treturn PlayerApiMapper")
	var l1_runtime: Array = []
	for v in PlayerCommandApi.VERB:
		l1_runtime.append(String(v))
	print("   層1 動詞：dispatch 的 match 抽出 %d 個｜PlayerCommandApi.VERB 有 %d 個｜常數 %d" % [
		l1_src.size(), l1_runtime.size(), SPEC_VERBS_L1])
	var only_src: Array = []
	var only_rt: Array = []
	for n in l1_src:
		if not l1_runtime.has(n):
			only_src.append(n)
	for n in l1_runtime:
		if not l1_src.has(n):
			only_rt.append(n)
	_check("★★層1【異源】一致：match 與 VERB 表逐名相同（只在 match：%s／只在 VERB：%s）" % [
		str(only_src), str(only_rt)], only_src.is_empty() and only_rt.is_empty())
	_check("★層1 的數 ＝ SPEC_VERBS_L1（%d／%d）" % [l1_src.size(), SPEC_VERBS_L1],
		l1_src.size() == SPEC_VERBS_L1)

	var cs := PlayerCommandSystem.new()
	cs.call("_setup_registry")
	var reg_keys: Array = cs.get("_action_registry").keys()
	var sys_src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd"))
	var wt_cases: Array = _match_literals(sys_src, "func execute_action_with_target(",
		"不支援 member 目標的行動")
	var wt_extra: Array = []
	for n in wt_cases:
		if not reg_keys.has(n):
			wt_extra.append(n)
	print("   層2：registry 鍵 %d 個｜with_target 的 case %d 個（不在 registry 的 %d 個：%s）" % [
		reg_keys.size(), wt_cases.size(), wt_extra.size(), str(wt_extra)])
	print("   ★兩種讀法都印（spec 與派工信不一致，我不猜）：")
	print("     讀法① registry 鍵 ＝ %d（spec §1② 的說法）" % reg_keys.size())
	print("     讀法② registry ＋ 不在 registry 的 case ＝ %d（派工信的說法）" % (
		reg_keys.size() + wt_extra.size()))
	print("     常數 SPEC_ACTIONS_L2 ＝ %d" % SPEC_ACTIONS_L2)
	_check("★層2 至少有一種讀法 ＝ SPEC_ACTIONS_L2（①%d／②%d／常數 %d）" % [
		reg_keys.size(), reg_keys.size() + wt_extra.size(), SPEC_ACTIONS_L2],
		reg_keys.size() == SPEC_ACTIONS_L2
			or reg_keys.size() + wt_extra.size() == SPEC_ACTIONS_L2)

	var l3_src: Array = _match_literals(sys_src, "func get_forced_response_options(",
		"func respond_to_forced(")
	print("   層3 forced_event 種類：%s（%d 種｜常數 %d）" % [
		str(l3_src), l3_src.size(), SPEC_FORCED_L3])
	_check("★層3 的數 ＝ SPEC_FORCED_L3（%d／%d）" % [l3_src.size(), SPEC_FORCED_L3],
		l3_src.size() == SPEC_FORCED_L3)
	print("   ★★★上游那個「37 動詞」對不上 14／51／5 任何一個 —— 本床不猜它指哪一層，")
	print("     也不拿這三個數去覆蓋它（spec §1③ 原樣執行）。")
	_cell("_test_p1_population_three_layers")


# ══ P2：層1 每個動詞各按一遍 ═════════════════════════════════════════════════
# ★args 的形狀是這張票的一部分：每個動詞給一組【形狀正確】的參數，
#   而參數指到的東西存不存在刻意不一致 —— (c)「必有回饋」守的正是
#   【按了一個做不到的動作也要有一句話】。
func _test_p2_walk_layer1_verbs() -> void:
	print("\n── P2 層1：14 個動詞各按一遍 ──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tgt_id: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			tgt_id = int(k)
			st.teams[tgt_id].tile_pos = pt.tile_pos
			break
	var plan: Array = [
		["move_to", {"tile_q": pt.tile_pos.x + 1, "tile_r": pt.tile_pos.y}, false],
		["cancel_move", {}, false],
		["refresh_targets", {}, false],
		["execute_action", {"action_id": "ignore", "target": {"kind": "team", "team_id": tgt_id}}, false],
		# ★這一步【按設計】沒有句子：世界上沒有那個 forced event ⇒ 消費點帶 silent 旗子
		#   （#7 那張票裁的：已結案／不存在的事件不再回音，否則玩家收到第二次回音）
		["respond_to_forced", {"interaction_id": "none", "response_id": "accept"}, true],
		["equip_item", {"slot_id": "hand_1", "item_grade": "粗製"}, false],
		["unequip_item", {"slot_id": "hand_1"}, false],
		["deposit_item", {"item_grade": "粗製", "qty": 1}, false],
		["take_team_item", {"item_grade": "粗製", "qty": 1}, false],
		["post_buy_order", {"res": "food", "qty": 1}, false],
		["post_sell_order", {"res": "food", "qty": 1}, false],
		["cancel_order", {"order_id": -1}, false],
		["possess", {"person_id": pt.leader_id}, false],
		["unpossess", {}, false],
	]
	_check("★母體地板：本格走的動詞數 ＝ 層1 的常數（%d／%d）" % [plan.size(), SPEC_VERBS_L1],
		plan.size() == SPEC_VERBS_L1)
	for row in plan:
		var name: String = String(row[0])
		var res: Array = _step(bridge, st, "L1:" + name, name, row[1], "", bool(row[2]))
		print("   %-18s ⇒ %s" % [name, String(res[0]).substr(0, 92)])
		for v in res[1]:
			print("      ★症狀(%s) %s" % [String(v[0]), String(v[1]).substr(0, 106)])
	print("   ★本格走了 %d 步（母體地板：0 步的話「沒有矛盾」是恆真）" % plan.size())
	_cell("_test_p2_walk_layer1_verbs")


# ══ P3：層2 每個動作各按一遍（對同格目標）════════════════════════════════════
func _test_p3_walk_layer2_actions() -> void:
	print("\n── P3 層2：每個 action 對同格目標各按一遍 ──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tgt_id: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			tgt_id = int(k)
			st.teams[tgt_id].tile_pos = pt.tile_pos
			break
	var cs := PlayerCommandSystem.new()
	cs.call("_setup_registry")
	var keys: Array = cs.get("_action_registry").keys()
	keys.sort()
	var silent: int = 0
	var with_bad: int = 0
	# ★★★「每種目標」那一維：`PlayerCommandApi.execute_action` 讀的是 `target["kind"]`，
	#   而**沒有 kind 就是 "none"** ⇒ 我第一版只傳 team_id ⇒ 51 個動作【全部】走在
	#   kind=none 那條路上，於是幾乎每一句都是「目標不存在」——
	#   ★卷面很滿（51 個都走了、也真的抓到英文識別字），而 spec 要的
	#     【動詞 × 每種目標】那一維**一次都沒被走到**。
	#   ⇒ ★★這就是「母體錯不是產品錯」的另一面：走完了 ≠ 走對了。
	#     修法：兩種 kind 各走一遍，並在卷面上分開數。
	var kinds_of_target: Array = [
		["none", {}],
		["team", {"kind": "team", "team_id": tgt_id}],
	]
	for tk in kinds_of_target:
		var kname: String = String(tk[0])
		var base: Dictionary = tk[1]
		var bad_here: int = 0
		for k in keys:
			var action: String = String(k)
			var tgt_arg: Dictionary = base.duplicate(true)
			var res: Array = _step(bridge, st, "L2:%s@%s" % [action, kname], "execute_action",
				{"action_id": action, "target": tgt_arg}, "")
			if String(res[0]).strip_edges() == "":
				silent += 1
			if not res[1].is_empty():
				with_bad += 1
				bad_here += 1
		print("   目標 kind=%-5s ⇒ 走了 %d 個 action，其中有症狀的 %d 個" % [
			kname, keys.size(), bad_here])
	print("   ★本格走了 %d 步（%d 個 action × %d 種目標）｜有症狀 %d｜完全沒有句子 %d" % [
		keys.size() * kinds_of_target.size(), keys.size(), kinds_of_target.size(),
		with_bad, silent])
	_check("★母體地板：走過的 action 數 > 0（0 的話本格恆綠）", keys.size() > 0)
	_cell("_test_p3_walk_layer2_actions")


# 佈置一個該種類的 forced_event，回它的 id
# ★★★proposal 要能換：#7 那個缺陷是 **"propose_alliance" 這個【字串】** 不在
#   `_accept_diplomacy` 的 match 裡 —— 用 "alliance" 佈置的話那條路根本沒被走到，
#   而它在卷面上跟「這個缺陷不存在」長得一樣（＝陽性對照沒接電）。
func _arm_forced(st: WorldState, kind: String, proposal: String = "alliance") -> String:
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var from_id: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			from_id = int(k)
			st.teams[from_id].tile_pos = pt.tile_pos
			break
	var evt: Dictionary = {"action": kind, "from_id": from_id, "team_id": pt.team_id}
	match kind:
		"diplomacy": evt["proposal"] = proposal
		"extort": evt["amount"] = 10.0
		"aid_request": evt["amount"] = 5.0
		"choose_heir": evt["candidates"] = pt.named_members.duplicate()
	var eid: String = "probe_%s" % kind
	# ★★★相容層（★這支床要能跑在【修法前的舊樹】上 —— 那是陽性對照的整個意義）：
	#   `set_player_forced_event` 是 #7 那張票才加的【單一寫入點】；
	#   舊樹上沒有它 ⇒ 直接寫那兩個欄位（那就是舊樹上的寫法）。
	#   ★不加這一層的話，陽性對照會在舊樹上死在「方法不存在」，
	#     而那個紅【不是症狀被列出來】—— 它只是床跑不起來。
	if st.has_method("set_player_forced_event"):
		st.set_player_forced_event(evt, eid)
	else:
		st.player_forced_event = evt
		st.player_forced_event_id = eid
	return eid


# ══ P4：層3 五種 forced_event × 每個回應（回應集動態拿，不手抄）═══════════════
func _test_p4_walk_forced_events() -> void:
	print("\n── P4 層3：五種 forced_event × 每個回應 ──")
	# ★★★母體是【種類 × 提案字串 × 回應】：提案字串那一維是 #7 那個缺陷的所在，
	#   漏掉它的話陽性對照會在一個【沒走到那條路】的世界裡看起來很乾淨。
	var kinds: Array = [
		["diplomacy", "alliance"], ["diplomacy", "propose_alliance"],
		["extort", "alliance"], ["join_request", "alliance"],
		["aid_request", "alliance"], ["choose_heir", "alliance"],
	]
	var total_combos: int = 0
	for row0 in kinds:
		var kind: String = String(row0[0])
		var proposal: String = String(row0[1])
		var tri0: Array = _fresh()
		var st0: WorldState = tri0[0]
		var cs0 := PlayerCommandSystem.new()
		_arm_forced(st0, kind, proposal)
		var opts: Array = cs0.get_forced_response_options(st0)
		print("   %s（提案字串 %s）⇒ 回應集 %s（%d 個）" % [kind, proposal, str(opts), opts.size()])
		# ★★面板文字也是【玩家面字串】⇒ 它也要過 (d)。#7 的第三件症狀
		#   （「Team11 提議 alliance」原樣 id）就活在這裡，而只看結果句看不到它
		#   （檢查管道 vs 失效管道不同軸 ⇒ 缺陷天生隱形）。
		var panel: Dictionary = PlayerApiMapper.map_forced_interaction(st0)
		for pk in ["message", "consequence", "no_response"]:
			var ptxt: String = String(panel.get(pk, ""))
			if ptxt == "":
				continue
			var pv: String = _rule_d(ptxt)
			if pv != "":
				print("      ★症狀(d/面板 %s) %s" % [pk, pv.substr(0, 100)])
				_note("d", "L3面板:%s(%s)/%s" % [kind, proposal, pk], pv,
					"面板文字（map_forced_interaction）把 id 原樣印給玩家")
		if opts.is_empty():
			_note("母體", "L3:" + String(kind),
				"這種事件的回應集是【空的】⇒ 它的每一個組合都沒有被走到", "回應集空")
			continue
		for opt in opts:
			var tri: Array = _fresh()
			var st: WorldState = tri[0]
			var bridge: SimBridge = tri[2]
			var eid: String = _arm_forced(st, kind, proposal)
			var res: Array = _step(bridge, st, "L3:%s(%s)/%s" % [kind, proposal, String(opt)],
				"respond_to_forced",
				{"interaction_id": eid, "response_id": String(opt)}, String(opt))
			total_combos += 1
			print("      [%s] ⇒ %s" % [String(opt), String(res[0]).substr(0, 86)])
			for v in res[1]:
				print("         ★症狀(%s) %s" % [String(v[0]), String(v[1]).substr(0, 104)])
	print("   ★本格走了 %d 個（事件 × 回應）組合" % total_combos)
	_check("★母體地板：組合數 > 0（0 的話「沒有矛盾」恆真）", total_combos > 0)
	_cell("_test_p4_walk_forced_events")


# ══ P5：四條判準各自【咬得動】（每條餵一個真實形狀的違反）════════════════════
# ★這一格與走訪【共用同一份判準函式】—— 否則對照驗的是另一份 code。
# ★★(d) 的樣本是【用戶那一輪真的看到的那一句】（派工信：不要造假樣本）。
func _test_p5_four_rules_have_teeth() -> void:
	print("\n── P5 四條判準各自咬得動 ──")
	var a: String = _rule_a(100.0, 90.0, [])
	print("   (a) 餵 coin 100 → 90 ⇒ %s" % a.substr(0, 86))
	_check("★(a) 守恆咬得動", a != "")
	_check("★(a) 不會亂咬：總量沒變、無違反 ⇒ 空", _rule_a(100.0, 100.0, []) == "")
	var b: String = _rule_b("accept", "與 Team3 結盟：你拒絕了這個提議")
	print("   (b) 餵 accept ＋ 含「拒絕」的句子 ⇒ %s" % b.substr(0, 86))
	_check("★(b) 回應↔結果不一致咬得動", b != "")
	_check("★(b) 不會亂咬：refuse ＋ 含「拒絕」 ⇒ 空（那是正確的）",
		_rule_b("refuse", "你拒絕了這個提議") == "")
	var c: String = _rule_c("   ")
	print("   (c) 餵空句子 ⇒ %s" % c.substr(0, 86))
	_check("★(c) 靜默咬得動", c != "")
	_check("★(c) 不會亂咬：有句子 ⇒ 空", _rule_c("你接受了結盟") == "")
	var d: String = _rule_d("Team11 提議 alliance")
	print("   (d) 餵【用戶那一輪真的看到的那一句】「Team11 提議 alliance」 ⇒ %s" % d.substr(0, 86))
	_check("★★(d) 英文識別字咬得動（樣本是真實症狀的原文，不是我編的）", d != "")
	_check("★(d) 不會亂咬：白名單內的 Team11／coin ⇒ 空", _rule_d("Team11 交給你 3 coin") == "")
	print("   ★★★白名單（spec §5③ 要求印出來）：%s" % str(ID_WHITELIST))
	print("     判準＝連續 %s 的小寫字母／底線；白名單外的命中才算症狀。" % ID_PATTERN)
	_cell("_test_p5_four_rules_have_teeth")


# ══ P6：產物（機器讀 tsv ＋ 人讀 txt，兩份對得上）═══════════════════════════
func _test_p6_artifacts() -> void:
	print("\n── P6 產物：tsv ＋ txt ──")
	var stamp: String = "docs/measurements/2026-09-30-scripted-exploration"
	var tsv: String = "rule\twhere\tcause\tdetail\n"
	for c in _contradictions:
		tsv += "%s\t%s\t%s\t%s\n" % [String(c["rule"]), String(c["where"]),
			String(c.get("cause", "")),
			String(c["detail"]).replace("\t", " ").replace("\n", " ")]
	var f1 := FileAccess.open("res://" + stamp + ".tsv", FileAccess.WRITE)
	f1.store_string(tsv)
	f1.close()
	# ★★★成因分群：把【幾件事】與【幾筆症狀】分開講。
	var by_cause: Dictionary = {}
	for c2 in _contradictions:
		var ck: String = String(c2.get("cause", ""))
		if ck == "":
			ck = "（%s 這一條沒有成因分群 ⇒ 每一筆要自己讀）" % String(c2["rule"])
		by_cause[ck] = int(by_cause.get(ck, 0)) + 1
	var human: String = ""
	human += "死輸入探索：矛盾清單（人讀版）\n\n"
	human += "跑的是哪一棵樹：sha %s\n" % (_tree_sha if _tree_sha != "" else "（取不到）")
	human += "走了幾步：%d（動詞、動作、強制事件回應的組合總數）\n" % _steps_walked
	human += "找到幾筆症狀：%d\n" % _contradictions.size()
	human += "落在幾個成因裡：%d ← 這個數才是【要修幾個地方】的上界\n\n" % by_cause.size()
	human += "四條判準各自是什麼（給沒有跟這條線的人讀）：\n"
	human += "  (a) 守恆      一道玩家指令只該搬動資源，不該讓全世界的錢總量變多變少\n"
	human += "  (b) 說到做到   你按「接受」，畫面就不該說你拒絕了\n"
	human += "  (c) 必有回應   每按一次就要有一句話（按了沒反應是最難查的那種壞）\n"
	human += "  (d) 說人話     玩家看到的句子裡不該出現程式碼的英文名字（例：alliance）\n\n"
	human += "成因分群（幾筆症狀 vs 幾件事）：\n"
	for ck2 in by_cause.keys():
		human += "  · %d 筆 ← %s\n" % [int(by_cause[ck2]), String(ck2)]
	human += "\n"
	if not _silent_by_design.is_empty():
		human += "設計上的靜默（這些步按設計沒有句子，不算症狀，但要看得到）：\n"
		for w in _silent_by_design:
			human += "  · %s\n" % String(w)
		human += "\n"
	if _contradictions.is_empty():
		human += "本輪沒有找到症狀。\n"
		human += "★而這不等於世界很乾淨：它只說「這 %d 步裡沒有」。\n" % _steps_walked
		human += "  要判斷它有沒有在測東西，看上面那個步數；步數 0 的話這份清單恆空。\n"
	else:
		human += "逐筆（判準／位置／內容）：\n"
		for c3 in _contradictions:
			human += "· [%s] %s\n    %s\n" % [String(c3["rule"]), String(c3["where"]),
				String(c3["detail"])]
	var f2 := FileAccess.open("res://" + stamp + ".txt", FileAccess.WRITE)
	f2.store_string(human)
	f2.close()
	print("   ★成因分群：%d 筆症狀落在 %d 個成因裡（幾件事 ≠ 幾筆症狀）" % [
		_contradictions.size(), by_cause.size()])
	for ck3 in by_cause.keys():
		print("     · %d 筆 ← %s" % [int(by_cause[ck3]), String(ck3)])
	print("   ★設計上的靜默 %d 步：%s" % [_silent_by_design.size(), str(_silent_by_design)])
	print("   ★★讀法的母體地板：本輪預期 %d 句／實得 %d 句（差額 %d ＝ 設計上的靜默那幾步）" % [
		_expected_sentences, _got_sentences, _expected_sentences - _got_sentences])
	_check("★★★讀法沒有漏句：預期 − 實得 ＝ 設計上的靜默步數（%d − %d ＝ %d／靜默 %d）" % [
		_expected_sentences, _got_sentences, _expected_sentences - _got_sentences,
		_silent_by_design.size()],
		_expected_sentences - _got_sentences == _silent_by_design.size())
	var back: String = FileAccess.get_file_as_string("res://" + stamp + ".tsv")
	var rows: int = back.split("\n").size() - 2
	print("   落檔：%s.tsv（%d 列資料）／%s.txt" % [stamp, rows, stamp])
	_check("★tsv 的列數 ＝ 症狀筆數（%d／%d）" % [rows, _contradictions.size()],
		rows == _contradictions.size())
	_check("★兩份都落地", FileAccess.file_exists("res://" + stamp + ".tsv")
		and FileAccess.file_exists("res://" + stamp + ".txt"))
	_check("★★母體地板：本輪走過的步數 > 0（0 步的話「沒有矛盾」是恆真）", _steps_walked > 0)
	_cell("_test_p6_artifacts")


# ══ P7：陽性對照的【專用佈置】（spec §2③ 的三件，★這是本票的命門）══════════
# ★★★走訪碰巧走到 ≠ 陽性對照：走訪給的參數是【形狀正確】的，
#   而那三件症狀各自有自己的前提（有 anon 可招／提案字串是 propose_alliance／面板有內容）
#   ⇒ 沒有專用佈置，它們在舊樹上也可能不出現，而那個「沒出現」會被讀成「床沒接電」。
# ★★本格在【今天的樹】上預期是乾淨的（三件都修掉了）；在【修法前的舊樹】上預期列出來。
#   ⇒ 兩棵樹各跑一次，而 sha 印在同一份輸出裡（`_read_sha`）。
func _test_p7_positive_control_fixtures() -> void:
	print("
── P7 陽性對照的專用佈置（三件）──")
	# ① 招募匿名：玩家付錢 ⇒ 這一側必須真的多人
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tgt_id: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1 				and AnonTierSystem.total_pop(st.teams[k]) > 1:
			tgt_id = int(k)
			st.teams[tgt_id].tile_pos = pt.tile_pos
			break
	ResourceBank.add(pt, "coin", 500.0, "bed_fixture_recruit")
	var pop_before: int = pt.population
	var coin_before: float = float(pt.resources.get("coin", 0))
	print("   [1] 佈置：對方 Team%d 同格、匿名人口 %d｜玩家 coin %.0f、人口 %d" % [
		tgt_id, AnonTierSystem.total_pop(st.teams[tgt_id]) if tgt_id != -1 else -1,
		coin_before, pop_before])
	_check("★[1] 母體地板：目標存在且有匿名人口可招（否則這一格測不到東西）",
		tgt_id != -1 and AnonTierSystem.total_pop(st.teams[tgt_id]) > 1)
	var res1: Array = _step(bridge, st, "P7[1]:recruit_anon", "execute_action",
		{"action_id": "recruit_anon", "target": {"kind": "team", "team_id": tgt_id}}, "")
	var pt_after: TeamData = st.teams.get(st.get_player_team_id())
	print("   [1] 結果：%s｜玩家 coin %.0f→%.0f、人口 %d→%d" % [
		String(res1[0]).substr(0, 60), coin_before,
		float(pt_after.resources.get("coin", 0)), pop_before, pt_after.population])
	# ★★★[1b][1c]：[1] 那個佈置【沒有重現】那個症狀 —— 舊樹上它也真的搬了 1 人。
	#   回頭讀那顆 merge 的訊息：它寫的是「招募對【不存在的交易】收費」
	#   ⇒ 症狀的前提是【那筆交易不存在】，而我給了一個有匿名人口可招的目標 ⇒ 交易存在。
	#   ⇒ ★兩個「交易不存在」的形狀各試一次：
	#     [1b] 對【沒有匿名人口】的目標招募匿名
	#     [1c] 招募一個【不存在的】記名成員（走 execute_action_with_target 那條入口）
	var trib: Array = _fresh()
	var stb: WorldState = trib[0]
	var bridgeb: SimBridge = trib[2]
	var ptb: TeamData = stb.teams.get(stb.get_player_team_id())
	# ★★★正確的前提（我回頭讀 05befff7f 的 merge 訊息才找到）：
	#   那個缺陷是 `_target_has_anon` 用 `population > 1` 當【代理量】——
	#   它問的是「人夠多嗎」而要問的是「真的有匿名嗎」
	#   ⇒ 症狀的佈置是【人口 > 1 而匿名 0（全具名）】，
	#     ★我第一版造了一個 pop 0 的空隊 ⇒ 舊樹回「目標人口不足」⇒ 走不到那條路。
	#   ⇒ ★★這就是「前提沒佈置對，而卷面跟『缺陷不存在』長得一樣」。
	var empty_id: int = -1
	for kb in stb.teams.keys():
		var cand: TeamData = stb.teams[kb]
		if int(kb) == ptb.team_id or cand.named_members.size() < 2:
			continue
		# 把它的匿名清成 0（人口仍 > 1，因為具名成員還在）
		for tier in AnonTierSystem.TIER_ORDER:
			var n0: int = int(cand.anon_tiers.get(tier, 0))
			if n0 > 0:
				AnonTierSystem.remove_anon(cand, tier, n0)
		if AnonTierSystem.total_pop(cand) <= 0 and cand.population > 1:
			empty_id = int(kb)
			cand.tile_pos = ptb.tile_pos
			print("   [1b] 佈置：Team%d 同格、人口 %d（全具名，匿名 %d）" % [
				empty_id, cand.population, AnonTierSystem.total_pop(cand)])
			break
	_check("★[1b] 母體地板：找到【人口 > 1 而匿名 0】的目標（找不到的話這一格測不到那個缺陷）",
		empty_id != -1)
	ResourceBank.add(ptb, "coin", 500.0, "bed_fixture_recruit_b")
	ResourceBank.add(ptb, "coin", 500.0, "bed_fixture_recruit_b")
	var cb: float = float(ptb.resources.get("coin", 0))
	var pb: int = ptb.population
	var resb: Array = _step(bridgeb, stb, "P7[1b]:recruit_anon@空隊", "execute_action",
		{"action_id": "recruit_anon", "target": {"kind": "team", "team_id": empty_id}}, "")
	print("   [1b] 對匿名人口 0 的隊招募 ⇒ %s｜coin %.0f→%.0f、人口 %d→%d" % [
		String(resb[0]).substr(0, 56), cb, float(ptb.resources.get("coin", 0)), pb, ptb.population])
	var tric: Array = _fresh()
	var stc: WorldState = tric[0]
	var bridgec: SimBridge = tric[2]
	var ptc: TeamData = stc.teams.get(stc.get_player_team_id())
	var other_id: int = -1
	for kc in stc.teams.keys():
		if int(kc) != ptc.team_id and stc.teams[kc].leader_id != -1:
			other_id = int(kc)
			stc.teams[other_id].tile_pos = ptc.tile_pos
			break
	ResourceBank.add(ptc, "coin", 500.0, "bed_fixture_recruit_c")
	var cc: float = float(ptc.resources.get("coin", 0))
	var pc: int = ptc.population
	var resc: Array = _step(bridgec, stc, "P7[1c]:recruit_named@不存在的人", "execute_action",
		{"action_id": "recruit_named", "target": {
			"kind": "member", "team_id": other_id, "member_id": 999999}}, "")
	print("   [1c] 招募不存在的記名成員 ⇒ %s｜coin %.0f→%.0f、人口 %d→%d" % [
		String(resc[0]).substr(0, 56), cc, float(ptc.resources.get("coin", 0)), pc, ptc.population])
	# ② 提案字串 propose_alliance ⇒ 按接受不得說拒絕（走訪已涵蓋，這裡印出那一句給人讀）
	var tri2: Array = _fresh()
	var st2: WorldState = tri2[0]
	var bridge2: SimBridge = tri2[2]
	var eid2: String = _arm_forced(st2, "diplomacy", "propose_alliance")
	var res2: Array = _step(bridge2, st2, "P7[2]:propose_alliance/accept", "respond_to_forced",
		{"interaction_id": eid2, "response_id": "accept"}, "accept")
	print("   [2] 按【接受】之後畫面說：%s" % String(res2[0]).substr(0, 90))
	# ③ 面板文字（那一句就是用戶看到的「TeamN 提議 alliance」）
	var tri3: Array = _fresh()
	var st3: WorldState = tri3[0]
	_arm_forced(st3, "diplomacy", "propose_alliance")
	var panel: Dictionary = PlayerApiMapper.map_forced_interaction(st3)
	print("   [3] 面板 message ＝「%s」" % String(panel.get("message", "")))
	var pv: String = _rule_d(String(panel.get("message", "")))
	if pv != "":
		_note("d", "P7[3]:面板 message", pv, "面板文字（map_forced_interaction）把 id 原樣印給玩家")
	print("   ★★★本格【只印不判】那三件的有無 —— 判它們的是 tsv 裡有沒有那幾列，")
	print("     而兩棵樹（今天／修法前）的差集才是「這支床接上電了」的證據。")
	_cell("_test_p7_positive_control_fixtures")


# ══ P8：★兩種讀法在【同一個輸入】上對照 —— 證「新讀法不會再被 TTL 騙」═══════════
# ★★★systems 的要求逐字：負對照要證【這個讀法不會再被 TTL 騙】，不是證【現在沒有 41 筆】。
#   ⇒ 而「動輸入不動事實」：本格動的是**步數**（推到遠超過 TTL 的 60），
#     **不改** `sim_runner` 的 `RESULT_TTL_TICKS`（那是改事實讓症狀消失）。
# ★做法：走 N 步（N > 60）無害指令，每一步同時用【兩種讀法】數它的句子：
#   ·新讀法：比對那一道指令自己的 `seq`
#   ·舊讀法：`range(before_n, command_results.size())` 的索引區間
#   ⇒ 新讀法必須 N／N；★★舊讀法必須【少於 N】——它少掉的那些就是它當初騙我的那些。
# ★★★【兩向】怎麼成立（R² 訂正過我一次，紀錄留著）：
#   我第一版說「P8 是兩向的」，而它當時**自己內聯**一份讀法 ⇒ `_step()` 的讀法退化它不會發現
#   ⇒ 那個宣稱指錯了測。★真正在守回歸的是 P6 的母體地板（預期 − 實得 ＝ 設計靜默）。
#   ⇒ 現在 P8 與 `_step()` **呼同一支** `_sentences_for_seq()` ⇒ 兩向成立：
#     哪天有人把那一支改回索引區間，P8 與 P6 會一起紅（實測見 commit 訊息）。
func _test_p8_two_readers_on_the_same_input() -> void:
	print("
── P8 兩讀法對照（步數推到遠超過 TTL）──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var ttl: int = SimRunner.RESULT_TTL_TICKS
	var steps: int = ttl + 30            # ★遠超過 TTL（不是剛好跨過）
	var by_seq: int = 0
	var by_index: int = 0
	for i in range(steps):
		var before_n: int = st.command_results.size()
		var r: Dictionary = bridge.command_player("cancel_move", {})
		if not bool(r.get("queued", false)):
			continue
		var my_seq: int = int(r.get("seq", -1))
		if not bridge.is_advancing():
			bridge.request_advance(1)
		while bridge.is_advancing():
			bridge.tick_step()
		# 新讀法 ★呼【共用的那一支】—— R² 的要求：P8 必須動到 `_step()` 真的在用的那份 code，
		#   否則 P8 綠而 `_step()` 的讀法退化了它也不會知道。
		by_seq += int(_sentences_for_seq(st, my_seq)[1])
		# 舊讀法（就是騙了我一整輪的那一個）
		for k in range(before_n, st.command_results.size()):
			by_index += 1
	print("   TTL ＝ %d tick（sim_runner.RESULT_TTL_TICKS）｜本格走 %d 步（★遠超過它）" % [ttl, steps])
	print("   新讀法（比 seq）數到 %d／%d" % [by_seq, steps])
	print("   舊讀法（索引區間）數到 %d／%d ← ★少掉的那些就是它當初報成「靜默」的那些" % [
		by_index, steps])
	_check("★★★新讀法在【遠超過 TTL】的輸入上仍然數對（%d／%d）" % [by_seq, steps],
		by_seq == steps)
	_check("★★舊讀法在【同一個輸入】上數不對（%d < %d）—— 這一條就是那 41 筆的機制證明" % [
		by_index, steps], by_index < steps)
	print("   ★而本格【沒有】改 `RESULT_TTL_TICKS`：動的是輸入（步數），不是事實。")
	_cell("_test_p8_two_readers_on_the_same_input")
# ══ P11：★每個 action id 都要有中文 label（母體 ＝ registry 的鍵）══════════════
# ★★★這一格就是找出那 12 個漏網的那一格：舊表只收了【選單會列的】那些，
#   而 registry 有 51 個鍵 ⇒ 其餘 12 個玩家按得到卻只看得到原樣 id。
#   ⇒ 而它是常駐的：以後新增動詞沒寫中文 ⇒ 這一格紅並把名字印出來。
# ★母體不是我手抄的清單：它是 `_action_registry` 的鍵（動詞從哪來就從那裡數）。
func _test_p11_every_action_has_a_label() -> void:
	print("
── P11 每個 action id 都有中文 label ──")
	var cs := PlayerCommandSystem.new()
	cs.call("_setup_registry")
	var keys: Array = cs.get("_action_registry").keys()
	keys.sort()
	var missing: Array = []
	for k in keys:
		if PlayerApiMapper.action_label(String(k)).begins_with("（未知動作"):
			missing.append(String(k))
	print("   registry 鍵 %d 個｜沒有中文 label 的 %d 個：%s" % [
		keys.size(), missing.size(), str(missing)])
	_check("★母體地板：registry 鍵 > 0（0 的話本格恆綠）", keys.size() > 0)
	_check("★★★每一個 action id 都有中文 label（缺 %d 個）" % missing.size(), missing.is_empty())
	print("   ★而「（未知動作：xxx）」那個 fallback 要留著：它是【不吞掉】那條規矩的執法，")
	print("     而本格保證正常路徑不會走到它。")
	_cell("_test_p11_every_action_has_a_label")


func _initialize() -> void:
	_tree_sha = _read_sha()
	print("=== scripted_exploration bed ===")
	# ★★★這一行是那一段的主詞：陽性對照跑在【修法前的舊樹】上，
	#   而「我在哪棵樹上量」必須印在同一份輸出裡（派工信逐字）。
	print("★跑的是哪一棵樹：sha = %s" % (_tree_sha if _tree_sha != "" else "（取不到）"))
	_test_p1_population_three_layers()
	_test_p2_walk_layer1_verbs()
	_test_p3_walk_layer2_actions()
	_test_p4_walk_forced_events()
	_test_p5_four_rules_have_teeth()
	_test_p7_positive_control_fixtures()
	_test_p8_two_readers_on_the_same_input()
	_test_p11_every_action_has_a_label()
	_test_p6_artifacts()   # ★產物最後跑：它要收 P7 的那幾筆
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== scripted_exploration DONE === errors: %d｜到場點名 %d／%d｜症狀 %d 筆｜步數 %d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size(), _contradictions.size(), _steps_walked])
	quit(1 if _errors > 0 else 0)
