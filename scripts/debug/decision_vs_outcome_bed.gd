extends SceneTree
# @bed-kind: invariant
# slice: 我的決定 vs 世界的結果要【分開講】（spec 2026-09-30 join-request-accept-says-rejected）
#
# ★★★這張票的重點不是那一筆，是【母體】：
#   用戶那句「我按 T 跳出表單後 還是寫我拒絕事件」與這一筆是**同族**，而那一族今天已經修過一次
#   ⇒ 這是第二個實例 ⇒ 所以要掃【回應集 × forced_event 的全部組合】，
#     逐一問「它的結果句會不會把我的決定說成別的決定」。
#   ⇒ ★若「要修」那一欄 > 1 ⇒ 那不是本票失敗，是本票找到第三個。
#
# ★★真因不是句子寫錯：**兩件事都真**（他接受了、隊伍滿了），
#   而那一句把【我的決定】與【世界的結果】混成一句 ⇒ 玩家讀成「我按的沒生效」。
#   ⇒ 修法＝分開講：「你選了「收留（…）」，但隊伍已滿，無法收留 ⇒ 沒有生效」。
#   ★★而決定那一半用 `_label_pre`（＝`PlayerApiMapper.forced_label`）⇒ 零第二份中文表。
#
# ★誠實限：
#   1. 本床走 `SimBridge.command_player`（真咽喉、真推 tick、真消費點）。
#   2. 「要修」的判準是機械的：接受側的回應 ⇒ 句子不得出現「被拒絕」或「你拒絕」。
#      ★它只抓【把決定說成相反的決定】那一類，抓不到「措辭難懂」那一類（那是另一張票）。
#   3. 本床【不改】任何 handler 的 msg（那是世界的話）。

var _errors: int = 0
var _cells_ran: Array = []

# 接受側的回應 id（★這一份不是新表：它與 `_rule_b` 那一族同一組語意，
#   而它必須寫在某處才能機械判斷「決定的方向」）
const ACCEPT_SIDE: Array = ["accept", "accept_join", "accept_lead", "pay", "give"]
const KINDS: Array = ["diplomacy", "extort", "join_request", "aid_request", "choose_heir"]

const EXPECTED_CELLS: Array = [
	"_test_p1_join_request_full_team",
	"_test_p2_all_combinations",
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
	var runner := SimRunner.new()
	return [st, runner, SimBridge.new(runner, st)]

# 佈置一個該種類的 forced_event，回它的 id
func _arm(st: WorldState, kind: String, proposal: String = "alliance") -> String:
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
	var eid: String = "bed_%s" % kind
	st.set_player_forced_event(evt, eid)
	return eid

# 下一道回應、推到消費、用【那一道的 seq】拿它的句子
#   ★★★用 seq 不用索引區間：`command_results` 有 60 tick 的 TTL，索引區間會在跑久之後
#     變成空的（2026-09-30 的血證：那讓我報了 41 筆假的「靜默」）。
func _respond(bridge: SimBridge, st: WorldState, eid: String, rid: String) -> String:
	var r: Dictionary = bridge.command_player("respond_to_forced",
		{"interaction_id": eid, "response_id": rid})
	if not bool(r.get("queued", false)):
		return String(r.get("message", r.get("msg", "")))
	var my_seq: int = int(r.get("seq", -1))
	if not bridge.is_advancing():
		bridge.request_advance(1)
	while bridge.is_advancing():
		bridge.tick_step()
	var out: String = ""
	for row in st.command_results:
		if int(row.get("seq", -999)) == my_seq:
			out += String(row.get("text", ""))
	return out

# 機械判準：這一句有沒有把【我的決定】說成別的決定？
#   回 "" ＝ 沒有；否則回那一句哪裡不對。
func _says_a_different_decision(rid: String, sentence: String) -> String:
	if not ACCEPT_SIDE.has(rid) and not rid.begins_with("heir_"):
		return ""   # 拒絕側：句子說「拒絕」是**對的**
	if sentence.contains("被拒絕") or sentence.contains("你拒絕"):
		return "回應是「%s」（接受側），而句子說：%s" % [rid, sentence]
	return ""


# ══ P1：那一筆 —— join_request 按接受而隊伍已滿 ═══════════════════════════════
# ★母體地板：先斷言【隊伍真的滿了】（不滿的話這一格測的是成功那條路）。
# 負對照：把 `respond_to_forced` 那段「分開講」拿掉 ⇒ 句子只剩「被拒絕（…）」⇒ 必紅
func _test_p1_join_request_full_team() -> void:
	print("\n── P1 join_request 按接受而隊伍已滿 ──")
	var tri: Array = _fresh()
	var st: WorldState = tri[0]
	var bridge: SimBridge = tri[2]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	# 佈置「隊伍已滿」：把玩家隊塞到 pop_cap（handler 的判準是 capacity <= 0）
	var cap: int = FactionAISystem.effective_pop_cap(st, pt)
	var need: int = cap - pt.population + 1
	if need > 0:
		AnonTierSystem.add_anon(pt, AnonCohort.TIER_PLEB, need)   # ★走入口（population 是計算屬性）
	var cap2: int = FactionAISystem.effective_pop_cap(st, pt)
	print("   佈置：玩家隊人口 %d／pop_cap %d ⇒ capacity %d（<= 0 才會說「隊伍已滿」）" % [
		pt.population, cap2, cap2 - pt.population])
	_check("★母體地板：隊伍真的滿了（capacity <= 0）", cap2 - pt.population <= 0)
	var eid: String = _arm(st, "join_request")
	var sentence: String = _respond(bridge, st, eid, "accept")
	print("   按【接受】之後畫面說：%s" % sentence)
	_check("★★★句子有【我的決定】那一半（「你選了」）", sentence.contains("你選了"))
	_check("★★★句子有【世界的結果】那一半（「隊伍已滿」）", sentence.contains("隊伍已滿"))
	_check("★★★句子【不得】說「被拒絕」—— 沒有人拒絕玩家，是世界裝不下",
		not sentence.contains("被拒絕"))
	_check("★而它也要說出【沒有生效】（玩家真正在問的那一件）", sentence.contains("沒有生效"))
	_cell("_test_p1_join_request_full_team")


# ══ P2：★母體 —— 回應集 × forced_event 的全部組合（三數相加＝總數）═══════════
# ★★★這一格才是本票的產出：那一筆只是第二個實例，而「還有第三個嗎」只能靠母體回答。
# 負對照：把 P1 那段「分開講」拿掉 ⇒ 至少一個組合落進【要修】⇒ 必紅
func _test_p2_all_combinations() -> void:
	print("\n── P2 母體：回應集 × forced_event 全部組合 ──")
	var total: int = 0
	var consistent: int = 0
	var to_fix: Array = []
	var not_applicable: Array = []
	for kind in KINDS:
		# 每一種都要問它的回應集（★動態拿，不手抄）
		var probe: Array = _fresh()
		var st0: WorldState = probe[0]
		var cs0 := PlayerCommandSystem.new()
		_arm(st0, String(kind))
		var opts: Array = cs0.get_forced_response_options(st0)
		if opts.is_empty():
			not_applicable.append("%s（回應集是空的 ⇒ 沒有組合可走）" % String(kind))
			continue
		for opt in opts:
			total += 1
			var tri: Array = _fresh()
			var st: WorldState = tri[0]
			var bridge: SimBridge = tri[2]
			var eid: String = _arm(st, String(kind))
			var sentence: String = _respond(bridge, st, eid, String(opt))
			if sentence.strip_edges() == "":
				not_applicable.append("%s/%s（沒有句子 ⇒ 另一族的問題，不是「說錯決定」）" % [
					String(kind), String(opt)])
				continue
			var bad: String = _says_a_different_decision(String(opt), sentence)
			if bad == "":
				consistent += 1
				print("   ✔ %-13s %-12s ⇒ %s" % [String(kind), String(opt), sentence.substr(0, 62)])
			else:
				to_fix.append(bad)
				print("   ★要修 %-13s %-12s ⇒ %s" % [String(kind), String(opt), sentence.substr(0, 62)])
	print("   ── 母體對帳 ──")
	print("   總組合 %d ＝ 一致 %d ＋ 要修 %d ＋ 不適用 %d" % [
		total, consistent, to_fix.size(), not_applicable.size()])
	for na in not_applicable:
		print("     · 不適用：%s" % String(na))
	for tf in to_fix:
		print("     · ★要修：%s" % String(tf).substr(0, 110))
	_check("★母體地板：總組合 > 0（0 的話本格恆綠）", total > 0)
	_check("★★★三數相加 ＝ 總組合數（%d ＋ %d ＋ %d ＝ %d／%d）" % [
		consistent, to_fix.size(), not_applicable.size(), total,
		consistent + to_fix.size() + not_applicable.size()],
		consistent + to_fix.size() + not_applicable.size() == total)
	_check("★★★沒有任何組合把我的決定說成別的決定（要修 %d 個）" % to_fix.size(),
		to_fix.is_empty())
	print("   ★而「不適用」那一欄要具名：上面每一條都寫了理由（空回應集／沒有句子）——")
	print("     ★★沒有具名的話，它會變成一個可以把任何不方便的組合掃進去的桶。")
	_cell("_test_p2_all_combinations")


func _initialize() -> void:
	print("=== decision_vs_outcome bed ===")
	_test_p1_join_request_full_team()
	_test_p2_all_combinations()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			miss.append(c)
	if not miss.is_empty():
		_errors += miss.size()
		push_error("[FAIL] 缺席的格：%s" % str(miss))
	print("\n=== decision_vs_outcome DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)
