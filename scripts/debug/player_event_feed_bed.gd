extends SceneTree
# @bed-kind: acceptance
# slice: 玩家事件流接世界事件匯流排（spec 2026-09-25 #4）
#
# ★★★這支床要證明的那一句：玩家的事件流【對自家隊不再全盲】——
#   在本票之前，畫面上的事件只有 `sim_bridge._diff_events()` 產的兩種
#   （遭遇戰觸發／看到新隊）⇒ 自家隊死了人、離了隊、招到人，★畫面一個字都不會說。
#
# ★★母體是這支床最容易出事的地方，理由是量出來的：
#   拿玩家入口跑 1200 tick，`world` 型事件有 10 筆，★而本票新增的那四種【一次都沒 fire】
#   ⇒ 「有 world 事件」不能當「那四種會動」的證據 —— ★★★所以每一種都要【造出來】。
#
# ★誠實限：本床【不經 `_input()`】，它驗的是「事件有沒有進佇列／過不過得了過濾器」，
#   不是「玩家按鍵之後畫面長怎樣」——後者由 `ui_flow_test` 與 `player_entry_smoke_bed` 驗。

var _errors: int = 0
var _cells_ran: Array = []

const EXPECTED_CELLS: Array = [
	"_test_p1_five_kinds_reach_the_feed",
	"_test_p3_single_write_point",
	"_test_p4_filter_uses_the_same_function",
	"_test_p5_other_teams_do_not_leak",
	"_test_p6_departure_carries_a_reason",
	"_test_p7_ttl_shares_one_constant",
	"_test_p8_queue_is_in_canon",
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
	seed(20260925)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return [st, SimRunner.new()]

# 佇列裡目前有哪些 kind（★回 kind 不回筆數：筆數答不出「是哪一種」）
func _kinds(st: WorldState) -> Array:
	var out: Array = []
	for e in st.player_events:
		out.append(String(e.get("kind", "")))
	return out

func _texts(st: WorldState) -> Array:
	var out: Array = []
	for e in st.player_events:
		out.append(String(e.get("text", "")))
	return out


func _initialize() -> void:
	print("=== 玩家事件流接匯流排（#4）===")
	_test_p1_five_kinds_reach_the_feed()
	_test_p3_single_write_point()
	_test_p4_filter_uses_the_same_function()
	_test_p5_other_teams_do_not_leak()
	_test_p6_departure_carries_a_reason()
	_test_p7_ttl_shares_one_constant()
	_test_p8_queue_is_in_canon()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== player_event_feed DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══════════ P1［五種都到得了事件流］══════════
# ★★★母體地板＝【逐種】斷言 ≥1，不是「總數 ≥5」——
#   五筆全是同一種也會滿足「總數 ≥5」，而那正是「計數是有損投影」。
# ★負對照：拿掉任一種 emit ⇒ 那一種必須紅（而其餘仍綠 ⇒ 指名得出是哪一種掉了）。
# 負對照：逐種拿掉那一支 emit（reaction／health／population／player_command）⇒ 只有那一種紅、其餘仍綠 ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p1_five_kinds_reach_the_feed() -> void:
	print("\n── P1 五種事件都到得了 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var ptid: int = st.get_player_team_id()
	_check("★母體地板①：造得出玩家隊（tid=%d）" % ptid, ptid != -1)
	if ptid == -1:
		_cell("_test_p1_five_kinds_reach_the_feed")
		return
	var team: TeamData = st.teams[ptid]
	st.player_events.clear()

	# ①離隊：走 ReactionSystem 真正的那一支（不是直接 emit —— 直接 emit 驗不到掛點）
	var rs := ReactionSystem.new()
	var victim_id: int = -1
	for pid in team.named_members:
		victim_id = int(pid)
		break
	_check("★母體地板②：玩家隊有具名成員可以離隊（id=%d）" % victim_id, victim_id != -1)
	if victim_id != -1:
		print("     [步1前] named=%s leader=%d pop=%d｜★ptid=%d team.team_id=%d｜perceive(自家)=%s" % [
			str(team.named_members), team.leader_id, team.population, ptid, team.team_id,
			str(WorldEvents._player_perceives(st, [ptid]))])
		rs._apply_reaction(st, st.persons[victim_id], team, "N1_flee")
		print("     [步1後] kinds=%s named=%s" % [str(_kinds(st)), str(team.named_members)])

	# ②死亡：走 HealthSystem 的餓死／失血結算（把 blood 歸零＝它自己的判準）
	var dying_id: int = -1
	for pid in team.named_members:
		dying_id = int(pid)
		break
	if dying_id == -1 and team.leader_id != -1:
		dying_id = int(team.leader_id)
	if dying_id != -1:
		st.persons[dying_id].blood = 0.0
		st.persons[dying_id].hunger = 0.9
		HealthSystem.check_starvation_deaths(st)
		print("     [步2後] dying=%d kinds=%s" % [dying_id, str(_kinds(st))])

	# ③成年：給它未成年人口，走 PopulationSystem 自己的那一支
	team.minor_population = 4
	PopulationSystem.new()._mature_minors(st)
	print("     [步3後] kinds=%s" % str(_kinds(st)))

	# ④招到：走玩家指令的真實路徑（入列 → 消費）
	var bridge := SimBridge.new(pair[1], st)
	var tgt: int = -1
	for tid in st.teams:
		if int(tid) == ptid: continue
		var t2: TeamData = st.teams[tid]
		if AnonTierSystem.total_pop(t2) > 0 and t2.tile_pos == team.tile_pos:
			tgt = int(tid)
			break
	if tgt == -1:
		# 沒有同格的 ⇒ 把一支有匿名的搬過來（★造母體，不是改判準）
		for tid in st.teams:
			if int(tid) == ptid: continue
			if AnonTierSystem.total_pop(st.teams[tid]) > 0:
				st.teams[tid].tile_pos = team.tile_pos
				tgt = int(tid)
				break
	_check("★母體地板③：造得出一支同格、有匿名的隊（tid=%d）" % tgt, tgt != -1)
	if tgt != -1:
		ResourceBank.set_amt(team, "coin", 999.0, "bed_seed")
		# ★`recruit_anon` 是【action_id】不是頂層 verb —— 頂層走 `execute_action`，
		#   而 target 的形狀是 `{"kind":"team","team_id":N}`（player_command_api.gd:50-57）。
		#   ★★我第一版直接送 `recruit_anon` ⇒ 回「沒有這個指令」——★而那個拒絕【是對的】：
		#     入列當下就擋不認得的 name，正是票5 做的那件事。
		var rq: Dictionary = bridge.command_player("execute_action",
			{"action_id": "recruit_anon", "target": {"kind": "team", "team_id": tgt}})
		print("     [步4入列] %s" % str(rq))
		pair[1].advance_tick(st, Vector2i(-1, -1))
		print("     [步4後] kinds=%s｜結果句=%s" % [str(_kinds(st)), str(st.command_results)])

	# ⑤挨餓：famine_warning 走訊息層，而 `message_system.gd:58` 的 emit_message
	#   本身就 `WorldEvents.emit` ⇒ ★它不需要本票補 emit（查過才這樣寫）
	# ★class_name 是 SimMessageSystem（不是檔名 MessageSystem）——★閘 id≠檔名的同族：
	#   我拿【檔名】當識別字，而 GDScript 認的是 class_name。
	SimMessageSystem.new().emit_message(st, "famine_warning", "糧食告急", team, {})

	var kinds: Array = _kinds(st)
	print("   佇列裡的 kind：%s" % str(kinds))
	for want in ["member_left", "member_died", "came_of_age", "member_joined", "famine_warning"]:
		_check("★【%s】到得了事件流" % want, kinds.has(want))
	_cell("_test_p1_five_kinds_reach_the_feed")


# ══════════ P3［單一寫入點］══════════
# ★grep 斷言：寫 `player_events` 的地方只有 `world_events.gd` 一處。
# ★★母體地板：先斷言【真的找到了那一處】—— 找不到＝不可判，不是綠。
# 負對照：在 `sim_runner` 另加一行 `state.player_events.append({})` ⇒ 實測 2 處 ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p3_single_write_point() -> void:
	print("\n── P3 玩家佇列只有一個寫入點 ──")
	var hits: Array = []
	for f in ["scripts/data/world_state.gd", "scripts/simulation/world_events.gd",
			"scripts/simulation/sim_runner.gd", "scripts/ui/sim_bridge.gd",
			"scripts/ui/text_ui_main.gd", "scripts/simulation/reaction_system.gd",
			"scripts/simulation/health_system.gd", "scripts/simulation/population_system.gd",
			"scripts/simulation/player_command_system.gd"]:
		var src: String = FileAccess.get_file_as_string("res://" + f)
		for l in src.split("\n"):
			var t: String = l.strip_edges()
			if t.begins_with("#"):
				continue   # ★剝註解：討論它的句子不是寫入點（同族的病踩過三次）
			if t.contains("player_events.append("):
				hits.append("%s：%s" % [f, t])
	print("   寫入點：%s" % str(hits))
	_check("★母體地板：真的找得到寫入點（%d 處）" % hits.size(), hits.size() >= 1)
	_check("★★寫入點只有一處（實測 %d）" % hits.size(), hits.size() == 1)
	if hits.size() >= 1:
		_check("★★★而它在 world_events.gd（＝ emit 那個呼叫點）",
			String(hits[0]).begins_with("scripts/simulation/world_events.gd"))
	_cell("_test_p3_single_write_point")


# ══════════ P4［過濾用 NPC 決定 belief 的那同一支函式］══════════
# ★不准另寫一條「玩家看得到什麼」的規則 —— 那會是第二份真相。
# 負對照：把 `BeliefSystem.has_belief()` 換成自己另寫的 `team_discovered.has()` 規則 ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p4_filter_uses_the_same_function() -> void:
	print("\n── P4 過濾器用同一支函式 ──")
	var src: String = FileAccess.get_file_as_string("res://scripts/simulation/world_events.gd")
	var at: int = src.find("func _player_perceives")
	_check("★母體地板：找得到過濾器（找不到＝不可判）", at != -1)
	if at != -1:
		var body: String = src.substr(at, 700)
		_check("★★它呼叫 BeliefSystem.has_belief（＝NPC 用的那一支）",
			body.contains("BeliefSystem.has_belief("))
		# ★★★預設不給：函式裡要有「沒有玩家 ⇒ return false」那一條
		_check("★★★預設是【不給】（沒有玩家就 return false）", body.contains("return false"))
	_cell("_test_p4_filter_uses_the_same_function")


# ══════════ P5［他隊不外洩］══════════
# ★★母體地板：那一輪要【真的有】一件玩家看不到的他隊事件 ——
#   否則「佇列裡沒有它」在【根本沒發生】時恆真。
# 負對照：把 `if not _player_perceives(...)` 改成 `if false:`（＝過濾整個拿掉） ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p5_other_teams_do_not_leak() -> void:
	print("\n── P5 看不到的他隊事件不外洩 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var ptid: int = st.get_player_team_id()
	var unknown: int = -1
	for tid in st.teams:
		if int(tid) == ptid: continue
		if not BeliefSystem.has_belief(st, ptid, int(tid)):
			unknown = int(tid)
			break
	_check("★母體地板：找得到一支【玩家對它沒有任何 belief】的隊（tid=%d）" % unknown, unknown != -1)
	if unknown == -1:
		_cell("_test_p5_other_teams_do_not_leak")
		return
	st.player_events.clear()
	WorldEvents.emit(st, "leader_death", [unknown])
	var n_after: int = st.player_events.size()
	print("   對一支看不到的隊 emit 之後，佇列 %d 筆" % n_after)
	_check("★★看不到的他隊事件【沒有】進玩家佇列", n_after == 0)
	# ★陽性對照：同一支隊，給玩家一筆 belief 之後【必須】進得來
	#   ⇒ 沒有這一格，「沒進來」也可能是【emit 整個壞掉】
	# 簽章：(state, obs, tgt, source_id, source_type, fields, credibility, distorted)
	BeliefSystem.record_claim(st, ptid, unknown, ptid, "firsthand", {"pop": 5.0}, 1.0, false)
	WorldEvents.emit(st, "leader_death", [unknown])
	print("   給了 belief 之後，佇列 %d 筆" % st.player_events.size())
	_check("★★★陽性對照：有 belief 之後同一件事【進得來】（證明不是 emit 壞了）",
		st.player_events.size() > n_after)
	_cell("_test_p5_other_teams_do_not_leak")


# ══════════ P6［離隊帶原因］══════════
# ★★而它要驗的是【原因不同、句子就不同】—— 只驗「句子裡有括號」會被一句寫死的話滿足。
# 負對照：把 N3_defect 的 reason 改成與 N1_flee 同一句 ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p6_departure_carries_a_reason() -> void:
	print("\n── P6 離隊帶原因 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var ptid: int = st.get_player_team_id()
	var team: TeamData = st.teams[ptid]
	st.player_events.clear()
	# ★★母體：這顆種子的玩家隊只有 1 名具名成員（實測），而這一格需要兩個人才驗得到
	#   「不同因 ⇒ 不同句」⇒ ★造第二名成員（造母體，★不是把判準放寬成「≥1」）。
	var ids: Array = []
	for pid in team.named_members:
		ids.append(int(pid))
	if ids.size() < 2:
		# ★這顆種子裡沒有【無隊】的人 ⇒ 從別隊借一名具名成員過來。
		#   ★★這是在造母體、不是在改判準：判準仍然是「不同因 ⇒ 不同句」。
		for tid2 in st.teams:
			if int(tid2) == ptid: continue
			var t3: TeamData = st.teams[tid2]
			for pid2 in t3.named_members.duplicate():
				st.remove_member(t3, int(pid2))
				st.add_member(team, int(pid2))
				ids.append(int(pid2))
				break
			if ids.size() >= 2: break
	_check("★母體地板：玩家隊有 ≥2 名具名成員（實測 %d）" % ids.size(), ids.size() >= 2)
	if ids.size() < 2:
		_cell("_test_p6_departure_carries_a_reason")
		return
	var rs := ReactionSystem.new()
	rs._apply_reaction(st, st.persons[ids[0]], team, "N1_flee")
	rs._apply_reaction(st, st.persons[ids[1]], team, "N3_defect")
	var txts: Array = _texts(st)
	print("   兩句：%s" % str(txts))
	_check("★兩件離隊都進了佇列（%d 筆）" % txts.size(), txts.size() >= 2)
	if txts.size() >= 2:
		_check("★★句子帶原因（含括號）",
			String(txts[0]).contains("（") and String(txts[1]).contains("（"))
		# ★★★第一版寫 `txts[0] != txts[1]` —— 而負對照抓到它是【空的】：
		#   把兩種原因改成同一句之後它【還是綠】，因為兩句話的【人名】不同
		#   ⇒ 那個不等號是被【名字】滿足的，不是被【原因】滿足的。
		# ⇒ 窄化成比【括號裡那一段】＝真正被守的東西。
		var r0: String = _reason_of(String(txts[0]))
		var r1: String = _reason_of(String(txts[1]))
		print("   兩個原因：「%s」 vs 「%s」" % [r0, r1])
		_check("★母體地板：兩句都抽得出原因（找不到＝不可判）", r0 != "" and r1 != "")
		_check("★★★逃走與叛離是【不同的原因】", r0 != r1)
	_cell("_test_p6_departure_carries_a_reason")


# ══════════ P7［TTL 與 step 上界共用同一個常數］══════════
# ★spec 要求「新佇列的 TTL 併入既有那條 >= STEP_TICK_BOUND 斷言」——
#   ★★而我做的比那更強：【共用同一個常數】⇒ 沒有第二個數字，就沒有第二條斷言要維護。
# 負對照：把 `RESULT_TTL_TICKS` 改成 `TICKS_PER_HOUR / 2`（＝比 step 上界小） ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p7_ttl_shares_one_constant() -> void:
	print("\n── P7 TTL 不是第二個數字 ──")
	print("   RESULT_TTL_TICKS=%d｜STEP_TICK_BOUND=%d｜TICKS_PER_HOUR=%d" % [
		SimRunner.RESULT_TTL_TICKS, SimBridge.STEP_TICK_BOUND, WorldState.TICKS_PER_HOUR])
	_check("★TTL >= 一次 step 的上界（漏一次讀就漏掉整整一小時）",
		SimRunner.RESULT_TTL_TICKS >= SimBridge.STEP_TICK_BOUND)
	var src: String = FileAccess.get_file_as_string("res://scripts/simulation/sim_runner.gd")
	var at: int = src.find("state.player_events = keep_ev")
	_check("★★母體地板：找得到玩家佇列的修剪（找不到＝不可判）", at != -1)
	if at != -1:
		var body: String = src.substr(maxi(0, at - 400), 400)
		_check("★★★修剪用的是 RESULT_TTL_TICKS（不是另一個常數）",
			body.contains("RESULT_TTL_TICKS"))
	_cell("_test_p7_ttl_shares_one_constant")


# ══════════ P8［佇列進 canon］══════════
# ★spec §2④：它進 fp。而理由寫在 `state_fingerprint.gd` 的那一段：
#   player_* 進 canon 不是因為玩家會影響 sim，★而是因為【sim 不該碰 player_*】
#   ⇒ 一顆【無玩家】的跑若讓這一行不是全 0，那就是有系統在沒有玩家的世界裡寫了玩家佇列。
# ★★母體地板：先斷言 canon 真的產得出來（空字串的話下面全是空談）。
# ★★★而它【不驗那個絕對雜湊】—— 那是 `world-fp` 那一格的工作，
#   在這裡再寫一次就是兩份真相，而其中一份遲早不會跟著改。
# 負對照：把 `state_fingerprint` 裡 `P|evt=` 那一行換成 `pass` ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p8_queue_is_in_canon() -> void:
	print("\n── P8 佇列進 canon ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	# ★★★判準＝【加一筆 ⇒ fp 變】，而不是去 grep canon 的字串：
	#   `StateFingerprint` 沒有公開的 canon 取用口（我第一版寫 `has_method()` 靜態呼叫 ⇒ 解析錯誤）
	#   ⇒ ★用【行為】驗它進得了 fp，比 grep 一行文字強：它連「有那一行但內容永遠一樣」都擋得住。
	var fp0: String = StateFingerprint.compute(st)
	st.player_events.append({"tick": 0, "seq": 1, "kind": "x", "subjects": [], "text": "t"})
	st.player_event_seq = 1
	var fp1: String = StateFingerprint.compute(st)
	print("   佇列空 fp=%s…｜佇列有一筆 fp=%s…" % [fp0.substr(0, 12), fp1.substr(0, 12)])
	_check("★母體地板：fp 產得出來（非空）", fp0 != "" and fp1 != "")
	_check("★★★佇列的內容【進得了 fp】（加一筆 ⇒ fp 變）", fp0 != fp1)
	_cell("_test_p8_queue_is_in_canon")

# 抽出「…（<原因>）」括號裡那一段。★找不到回空字串 ⇒ 由呼叫端判【不可判】，不是回一個假值。
func _reason_of(t: String) -> String:
	var a: int = t.find("（")
	var b: int = t.rfind("）")
	if a == -1 or b == -1 or b <= a + 1:
		return ""
	return t.substr(a + 1, b - a - 1)
