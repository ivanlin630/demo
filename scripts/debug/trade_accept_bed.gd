extends SceneTree
# @bed-kind: acceptance
# slice: 玩家接受通商 ＝ 走 NPC↔NPC 那一段【同一份 code】（spec 2026-09-30，藍圖裁 (b)）
#
# ★★★這支床要證明的那一句：玩家按接受【不再什麼都沒發生】，而且它拿到的效果
#   **與 NPC 拿到的完全一樣**（同一個函式）—— 零特例、零新狀態。
#   ★上游否決 (c)「暫不做」的逐字理由：**按接受什麼都沒發生 ＝ 拒絕禁靜默的鏡像**。
#
# ★★而「零特例」【不能】寫成「玩家路徑與 NPC 路徑效果相同」——
#   那兩邊是**同源**（同一個函式）⇒ **恆真** ⇒ 一句話講兩次。
#   ⇒ 所以 P2 拆成兩格【異源】的：
#     (a) `apply_trade_accept` 的呼叫點恰好 2 個，並指名它們在哪
#     (b) 玩家 handler 檔內**不得出現係數的字面**、也不得出現 `update_reputation(`
#     ⇒ 一邊是 code、一邊是判準，可以各自改 ⇒ 真比較。
#
# ★誠實限：
#   1. 本床走 `PlayerCommandSystem` 直呼，不經 UI（畫面那一段由 ui-flow 覆蓋）。
#   2. ★通商【真狀態】（許可／關稅／市場准入）不在本票 —— 已登 defer。
#      ⇒ 所以「接受之後世界多了什麼」的答案目前就是【只有名聲】，而那是裁定要的。

var _errors: int = 0
var _cells_ran: Array = []

# ★來自 spec 的常數：`apply_trade_accept` 該有幾個呼叫點。
#   ★★2 ＝ NPC 那一支 ＋ 玩家 handler。★第三個出現 ⇒ 有人又抄了一份 ⇒ P2(a) 紅。
const SPEC_CALLSITES: int = 2
# ★P2(b) 的禁字。★★★而它的範圍是【`_accept_diplomacy` 的函式體】不是整個檔 ——
#   我第一版寫「整個檔不得出現 `update_reputation(`」⇒ **紅了，而紅得對**：
#   那個檔有【兩處既有用途】（`player_command_system.gd:1149` 乞食被拒 -0.1／
#   `:1170` 施捨 +0.15），它們跟通商那份真相無關。
#   ⇒ ★判準過寬會誤報，而處置是【窄化】不是【刪掉子句】——
#     刪掉會變成反方向的空真（從此沒有人擋「玩家端自己寫一份名聲」）。
#   ⇒ ★★窄化後它守的正是 spec 要的那件事：**那一支 arm 不得自己寫名聲**。
const SPEC_FORBIDDEN_IN_ACCEPT_BODY: Array = ["update_reputation("]
# ★既有用途逐一指名（讓「為什麼整檔不能當範圍」有證據，不只有一句話）
const MEASURED_EXISTING_USES: Array = [
	"player_command_system.gd:1149 乞食被拒 -0.1",
	"player_command_system.gd:1170 施捨 +0.15",
]

const EXPECTED_CELLS: Array = [
	"_test_p1_accept_writes_reputation_only",
	"_test_p2a_exactly_two_callsites",
	"_test_p2b_player_file_has_no_copy",
	"_test_p3_refuse_is_zero_effect_but_speaks",
	"_test_p4_proposal_crosscheck_still_green",
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
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, PlayerCommandSystem.new()]

func _code_only(src: String) -> String:
	var out: String = ""
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out += l + "\n"
	return out

# 在玩家格上擺一支別隊（★同格是前提：同格閘會擋隔空的外交）
func _npc_at_player(st: WorldState, tid: int) -> TeamData:
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var t := TeamData.new()
	t.team_id = tid
	t.faction_id = -1
	t.tile_pos = pt.tile_pos
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 4)
	var l := PersonData.new()
	l.id = tid * 10 + 1
	l.team_id = tid
	l.person_name = "首領%d" % tid
	st.persons[l.id] = l
	t.leader_id = l.id
	st.teams[tid] = t
	return t

# 玩家隊的 leader（P1 要驗它的 relations／relation_edges 都沒動）
func _player_leader(st: WorldState) -> PersonData:
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	if pt == null:
		return null
	return st.persons.get(pt.leader_id)


func _initialize() -> void:
	print("=== 玩家接受通商＝走 NPC 同一份 code（spec 2026-09-30）===")
	_test_p1_accept_writes_reputation_only()
	_test_p2a_exactly_two_callsites()
	_test_p2b_player_file_has_no_copy()
	_test_p3_refuse_is_zero_effect_but_speaks()
	_test_p4_proposal_crosscheck_still_green()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== trade_accept DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══ P1：接受 ⇒ 雙向名聲各 +係數，而【其他狀態一個都沒動】═════════════════
# ★★★後半那一句是這一格的重點：spec 逐字寫「這一格守的是【不要順手多給玩家一個效果】，
#   而那是最容易發生的越界」——裁定寫「名聲／好感」而 code 只做名聲。
# ★母體地板三道：①接受前的名聲值印出來（不然「+0.05」沒有主詞）
#   ②`relations`／`relation_edges` 在【動之前】的內容也印出來（空的話「沒變」恆真）
#   ③接受真的成立（ok=true）—— 失敗的接受當然什麼都不會動
# 負對照：把 `apply_trade_accept` 的本體換成 `pass` ⇒ 雙向名聲各 +0.0000 ⇒ 已於 feat/trade-accept-same-code（2026-09-30 這一輪） 實測紅
func _test_p1_accept_writes_reputation_only() -> void:
	print("\n── P1 接受＝只寫名聲 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tgt: TeamData = _npc_at_player(st, 7711)
	_check("母體地板 A：造得出玩家隊與同格的別隊", pt != null and tgt != null)
	var pl: PersonData = _player_leader(st)
	_check("母體地板 B：找得到玩家隊的 leader（P1 要驗他的好感沒動）", pl != null)
	if pt == null or pl == null:
		_cell("_test_p1_accept_writes_reputation_only")
		return
	var before_p2t: float = float(pt.known_reputations.get(tgt.team_id, 0.5))
	var before_t2p: float = float(tgt.known_reputations.get(pt.team_id, 0.5))
	var before_rel: Dictionary = pl.relations.duplicate(true)
	var before_edges: int = pl.relation_edges.size()
	print("   接受前：玩家→對方 %.4f／對方→玩家 %.4f｜leader.relations %d 筆／relation_edges %d 筆" % [
		before_p2t, before_t2p, before_rel.size(), before_edges])
	st.set_player_forced_event({"action": "diplomacy", "from_id": tgt.team_id,
		"proposal": "propose_trade"}, "fe_trade")
	var r: Dictionary = cmd.respond_to_forced(st, "accept")
	print("   接受回傳：ok=%s msg=%s" % [str(r.get("ok", "?")), String(r.get("msg", ""))])
	_check("★母體地板 C：接受真的成立（ok=true）—— 失敗的接受當然什麼都不會動",
		bool(r.get("ok", false)))
	var after_p2t: float = float(pt.known_reputations.get(tgt.team_id, 0.5))
	var after_t2p: float = float(tgt.known_reputations.get(pt.team_id, 0.5))
	print("   接受後：玩家→對方 %.4f（+%.4f）／對方→玩家 %.4f（+%.4f）" % [
		after_p2t, after_p2t - before_p2t, after_t2p, after_t2p - before_t2p])
	_check("★★★雙向名聲都變高了（玩家→對方 +%.4f／對方→玩家 +%.4f）" % [
		after_p2t - before_p2t, after_t2p - before_t2p],
		after_p2t > before_p2t and after_t2p > before_t2p)
	_check("★★兩邊的增量相同（對稱，因為是同一個函式寫的）",
		is_equal_approx(after_p2t - before_p2t, after_t2p - before_t2p))
	# ══ ★零其他狀態變動（spec：最容易發生的越界）
	print("   接受後：leader.relations %d 筆／relation_edges %d 筆" % [
		pl.relations.size(), pl.relation_edges.size()])
	_check("★★★零越界①：`p.relations`（person 好感）**筆數**沒變（%d → %d）" % [
		before_rel.size(), pl.relations.size()], pl.relations.size() == before_rel.size())
	var rel_same: bool = true
	for k in before_rel:
		if not is_equal_approx(float(pl.relations.get(k, -999.0)), float(before_rel[k])):
			rel_same = false
	_check("★★★零越界②：`p.relations` 的每一個【值】也沒變", rel_same)
	_check("★★★零越界③：`relation_edges` 沒有增加（%d → %d）" % [
		before_edges, pl.relation_edges.size()], pl.relation_edges.size() == before_edges)
	print("   ★為什麼要驗這三條：裁定寫「名聲／好感加分」而 NPC 那一支 code 只做【名聲】")
	print("     ⇒ 玩家多拿一個 person 好感就是【NPC 得不到的效果】＝特例，")
	print("       而那正好違反這條裁定自己的原則（零特例）。")
	_cell("_test_p1_accept_writes_reputation_only")


# ══ P2(a)：`apply_trade_accept` 的呼叫點恰好 2 個（★異源之一）═══════════════
# ★★spec 明寫【不可以】寫成「玩家路徑與 NPC 路徑效果相同」——同源 ⇒ 恆真。
#   這一格改問一個可以獨立改變的事實：**有幾個地方呼它**。
#   ⇒ 第三個出現 ＝ 有人又抄了一份真相 ⇒ 紅。
# ★母體地板：定義處真的找得到（找不到的話「呼叫點 2 個」可能是兩個錯字）。
# 負對照：在玩家 arm 多加一個呼叫 ⇒ 呼叫點 3 個 ⇒ 已於 feat/trade-accept-same-code（2026-09-30 這一輪） 實測紅
func _test_p2a_exactly_two_callsites() -> void:
	print("\n── P2(a) 呼叫點恰好 2 個 ──")
	var files: Array = [
		"res://scripts/simulation/diplomatic_ai_system.gd",
		"res://scripts/simulation/player_command_system.gd",
	]
	var defs: int = 0
	var calls: Array = []
	for path in files:
		var src: String = _code_only(FileAccess.get_file_as_string(path))
		var ln: int = 0
		for l in src.split("\n"):
			ln += 1
			if not l.contains("apply_trade_accept"):
				continue
			if l.strip_edges().begins_with("static func ") or l.strip_edges().begins_with("func "):
				defs += 1
			else:
				calls.append("%s（剝註解後第 %d 行）" % [String(path).get_file(), ln])
	print("   定義處 %d｜呼叫點 %d：" % [defs, calls.size()])
	for c in calls:
		print("     · %s" % String(c))
	_check("★母體地板：定義處恰好 1（找得到它；找不到的話下面全是空談）", defs == 1)
	_check("★★★呼叫點恰好 %d 個（實測 %d）—— 第三個出現＝有人又抄了一份真相"
		% [SPEC_CALLSITES, calls.size()], calls.size() == SPEC_CALLSITES)
	_check("★★一個在 NPC 那一支、一個在玩家 handler（不是同一個檔裡兩個）",
		calls.size() == 2 and String(calls[0]).begins_with("diplomatic_ai_system")
		and String(calls[1]).begins_with("player_command_system"))
	_cell("_test_p2a_exactly_two_callsites")


# ══ P2(b)：玩家 handler 檔內沒有複製那份真相（★異源之二）═══════════════════
# ★判準：那個檔不得出現 `update_reputation(`，也不得出現係數的字面。
#   ⇒ 係數的字面【從 spec 常數取】而不是我手抄：常數住在 `DiplomaticAiSystem.TRADE_ACCEPT_REP`
#     ⇒ ★★兩邊可以各自改（有人改係數 ⇒ 這一格用【新值】去 grep）⇒ 真比較。
# ★母體地板：那個係數字面真的不是空字串（空的話「找不到它」恆真）。
# 負對照：讓玩家 arm 自己寫一行 `pt.update_reputation(...)` ⇒ 那一支 arm 出现 1 次 ⇒ 已於 feat/trade-accept-same-code（2026-09-30 這一輪） 實測紅
func _test_p2b_player_file_has_no_copy() -> void:
	print("\n── P2(b) 玩家檔沒有複製那份真相 ──")
	var src: String = _code_only(FileAccess.get_file_as_string(
		"res://scripts/simulation/player_command_system.gd"))
	var lit: String = str(DiplomaticAiSystem.TRADE_ACCEPT_REP)
	print("   係數字面（從常數取，不手抄）＝ `%s`" % lit)
	_check("★母體地板：係數字面非空（空的話「找不到它」恆真）", lit != "" and lit != "0")
	var hit_lit: int = 0
	for l in src.split("\n"):
		if l.contains(lit):
			hit_lit += 1
			print("     ★玩家檔出現了係數字面：%s" % l.strip_edges().substr(0, 90))
	_check("★★★玩家 handler 檔內【沒有】係數的字面（%d 處）" % hit_lit, hit_lit == 0)
	# ★★範圍是【`_accept_diplomacy` 的函式體】不是整個檔（理由見常數檔頭）
	var at: int = src.find("func _accept_diplomacy")
	_check("★母體地板：找得到 `_accept_diplomacy` 的函式體（找不到＝本格不可判）", at != -1)
	var body: String = ""
	if at != -1:
		var rest: String = src.substr(at)
		var nxt: int = rest.find("
func ", 10)
		body = rest.substr(0, nxt) if nxt != -1 else rest
	print("   `_accept_diplomacy` 函式體 %d 字元" % body.length())
	_check("★★母體地板：函式體非空且含 `propose_trade` 那一支（否則抽錯了）",
		body.length() > 100 and body.contains("propose_trade"))
	for forb in SPEC_FORBIDDEN_IN_ACCEPT_BODY:
		var n: int = body.count(String(forb))
		print("   `%s` 在那一支函式體裡出現 %d 次（★整個檔另有 %d 處既有用途）" % [
			String(forb), n, src.count(String(forb))])
		_check("★★★那一支 arm 沒有自己寫名聲（`%s` %d 次）" % [String(forb), n], n == 0)
	print("   ★既有用途逐一指名（為什麼整檔不能當範圍，有證據不只有一句話）：")
	for u in MEASURED_EXISTING_USES:
		print("     · %s" % String(u))
	print("   ★這一格與 P2(a) 是【兩個獨立的來源】：(a) 問「有幾個地方呼它」、")
	print("     (b) 問「玩家檔有沒有自己寫一份」⇒ 它們可以各自改而不影響對方。")
	_cell("_test_p2b_player_file_has_no_copy")


# ══ P3：拒絕 ⇒ 狀態逐欄不變，而畫面【有一句人話】═══════════════════════════
# ★★★裁定否決 (c) 的那句話就是這一格要執法的：**按了什麼都沒發生＝禁靜默的鏡像**。
#   ⇒ 拒絕【零效果】是對的，而【沒有一句話】不對。
# ★母體地板：先斷言拒絕真的被處理（forced_event 被清掉），否則「狀態沒變」恆真。
# 負對照：把拒絕那一支的 msg 改成空字串 ⇒ 靜默（禁靜默的鏡像） ⇒ 已於 feat/trade-accept-same-code（2026-09-30 這一輪） 實測紅
func _test_p3_refuse_is_zero_effect_but_speaks() -> void:
	print("\n── P3 拒絕＝零效果但有人話 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var cmd: PlayerCommandSystem = pair[1]
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	var tgt: TeamData = _npc_at_player(st, 7712)
	var before_p2t: float = float(pt.known_reputations.get(tgt.team_id, 0.5))
	var before_t2p: float = float(tgt.known_reputations.get(pt.team_id, 0.5))
	st.set_player_forced_event({"action": "diplomacy", "from_id": tgt.team_id,
		"proposal": "propose_trade"}, "fe_trade_r")
	var r: Dictionary = cmd.respond_to_forced(st, "refuse")
	print("   拒絕回傳：ok=%s msg=「%s」" % [str(r.get("ok", "?")), String(r.get("msg", ""))])
	_check("★母體地板：拒絕真的被處理（forced_event 被清掉）",
		st.player_forced_event.is_empty())
	_check("★★★有一句人話（msg 非空）—— 按了什麼都沒發生＝禁靜默的鏡像",
		String(r.get("msg", "")) != "")
	print("   拒絕後：玩家→對方 %.4f（前 %.4f）／對方→玩家 %.4f（前 %.4f）" % [
		float(pt.known_reputations.get(tgt.team_id, 0.5)), before_p2t,
		float(tgt.known_reputations.get(pt.team_id, 0.5)), before_t2p])
	_check("★拒絕＝零效果①：玩家→對方名聲沒變",
		is_equal_approx(float(pt.known_reputations.get(tgt.team_id, 0.5)), before_p2t))
	_check("★拒絕＝零效果②：對方→玩家名聲沒變",
		is_equal_approx(float(tgt.known_reputations.get(pt.team_id, 0.5)), before_t2p))
	print("   ★邊界：NPC 那一支拒絕也是零效果（`return \"reject\"`）⇒ 兩邊語意一致，")
	print("     而【人話】是玩家端獨有的需求（NPC 不需要看字）—— 那不是特例，是介面。")
	_cell("_test_p3_refuse_is_zero_effect_but_speaks")


# ══ P4：提案字串異源比對【仍綠】，而且沒有被放寬 ════════════════════════════
# ★★★spec 逐字：`propose_trade` 現在應該落在 B（handler 認得它）⇒ 差集只剩那個
#   方向相反的提案（指名豁免）⇒ **確認仍綠，不要放寬它**。
# ★★而本格【不重寫那個比對】——它去讀同格票那支床的常數，確認豁免集合沒有變大。
#   ⇒ 為什麼不重跑比對：那會變成第二份判準，而兩份判準會漂。
# 負對照：把 `SPEC_UNKNOWN_OK` 多塞 `propose_trade` ⇒ 豁免集合被放寬 ⇒ 已於 feat/trade-accept-same-code（2026-09-30 這一輪） 實測紅
func _test_p4_proposal_crosscheck_still_green() -> void:
	print("\n── P4 提案字串比對沒有被放寬 ──")
	var src: String = FileAccess.get_file_as_string(
		"res://scripts/debug/forced_event_panel_bed.gd")
	_check("母體地板：讀得到那支床（%d 字元）" % src.length(), src.length() > 1000)
	var unknown_ok: String = ""
	var refused: String = ""
	for l in src.split("\n"):
		var t: String = l.strip_edges()
		if t.begins_with("const SPEC_UNKNOWN_OK"):
			unknown_ok = t
		elif t.begins_with("const SPEC_REFUSED_BY_DESIGN"):
			refused = t
	print("   %s" % unknown_ok)
	print("   %s" % refused)
	_check("★兩個豁免集合都找得到（找不到＝那支床被改過形狀，本格不可判）",
		unknown_ok != "" and refused != "")
	_check("★★★「完全不認得」那一組仍然只有那個方向相反的提案（沒有被放寬）",
		unknown_ok.contains("tribute_offer") and not unknown_ok.contains("propose_trade"))
	_check("★★`propose_trade` 仍在「認得而刻意只回人話」那一組的位置上被指名",
		refused.contains("propose_trade"))
	print("   ★邊界：本格【不重跑】那個異源比對 —— 重跑等於第二份判準，而兩份判準會漂。")
	print("     它只確認【豁免集合沒有變大】；比對本身由 `forced-event-panel` 那一格負責。")
	print("   ★★而 `propose_trade` 現在的語意變了（從「認得而只回人話」變成「真的做事」）")
	print("     ⇒ 那支床的 P9 會自己說話：它仍在 B 裡，只是那一支 arm 不再回 ok=false。")
	_cell("_test_p4_proposal_crosscheck_still_green")
