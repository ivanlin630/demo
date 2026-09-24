extends SceneTree
# @bed-kind: acceptance
# slice: 打聽 v1 —— 情報必進 belief ＋ 代價＝對方同意（spec 2026-09-25）
#
# ★★★這支床要證明的那一句：打聽【真的改變世界】，而代價是【對方同不同意】。
#   在本票之前：`resolve_inquiry()` 全程零寫入（票5 P13b 量到「連呼 5 次 fp 不變」的真因），
#   而 UI 只印四個字「情報獲取」⇒ ★兩半都沒有：既不寫，也不給看。
#
# ★★母體地板是這支床的命門（spec §4 P5）：
#   若那個世界【每次都 honest 且對方什麼都知道】，P1 會恆綠而我們不會知道
#   ⇒ ★★★所以每一格都要印出【實際的 mode】與【giver 的 known 數】——
#     那兩個數就是這支床的分母。
#
# ★誠實限：本床不經 `_input()`，走指令 API 與系統本體；
#   「玩家按鍵之後畫面長怎樣」由 ui_flow_test／player_entry_smoke_bed 驗。

var _errors: int = 0
var _cells_ran: Array = []
# ★★★失敗行要帶一個【不隨措辭變】的 token ＝ 目前這一格的名字。
#   ★理由是實測到的：負對照驅動器的 `expect` 是【格子訊息的第二份拷貝】
#     ⇒ 我改一次措辭，驅動器就報 NOT-RED，而那一格其實紅了（2026-09-25 發生三次）。
#   ★★而 token 讓驅動器可以認【格】而不是認【句子】⇒ 措辭再改也不會誤報。
var _cur_cell: String = ""

const EXPECTED_CELLS: Array = [
	"_test_p1_intel_enters_belief",
	"_test_p3_silence_writes_nothing",
	"_test_p4_unknown_is_not_silence",
	"_test_p6_source_is_the_asked_team",
	"_test_p7_topic_empty_is_verbatim",
	"_test_p8_food_narrowed_to_seen_tiles",
	"_test_counts_one_write_path",
]


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL][%s] %s" % [_cur_cell, msg])

# ★★★母體：t=0 時【沒有任何隊有 belief】—— belief 是 vision 逐 tick 建起來的
#   ⇒ 不先推進，`_colocated_npc()` 永遠找不到「自己有情報」的隊（實測：回 -1）
#   ⇒ ★★所以這支床的每一格都要先讓世界跑一段。那不是「暖機」，那是【造母體】。
const WARMUP_TICKS: int = 200

func _fresh() -> Array:
	seed(20260925)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	var runner := SimRunner.new()
	for _i in range(WARMUP_TICKS):
		runner.advance_tick(st, Vector2i(-1, -1))
	return [st, runner]

# 玩家隊對【所有】對象的 claim 總筆數（★這是 P1 的那個量）
func _claim_total(st: WorldState, ptid: int) -> int:
	var n: int = 0
	for tgt in BeliefSystem.known_targets(st, ptid):
		n += BeliefSystem.claims(st, ptid, int(tgt)).size()
	return n

# 造一支【同格的】NPC 隊（打聽的前置是既有的 interact-team：雙方同格）
func _colocated_npc(st: WorldState, ptid: int) -> int:
	var pt: TeamData = st.teams[ptid]
	for tid in st.teams:
		if int(tid) == ptid: continue
		if BeliefSystem.known_targets(st, int(tid)).size() > 0:
			st.teams[tid].tile_pos = pt.tile_pos
			return int(tid)
	return -1

# ★★★問一次。回傳裡的 `text` ＝【三句話】，而它取自 handler 的回傳而不是消費點的結果句：
#   ★實測（2026-09-25）：`sim_runner.gd:568` 在【成功】路徑上只印 `describe(...)+"：完成"`，
#     handler 回的 `msg` 被丟掉 ⇒ 玩家看到的是「行動：confirm_gather_intel：完成」。
#   ★★而那不是打聽獨有：全庫有 65 個 handler 在成功時回了 msg，全部到不了玩家。
#   ⇒ ★★★那是【改變 65 條玩家看得到的句子】的決定 ⇒ 已呈報 systems，不由我自己改。
#   ⇒ 在那之前，這支床驗【三句話有被產生出來】，並把消費點那一句也印出來，
#     讓那個缺口在卷面上【看得見】而不是被我用註解帶過。
func _ask(st: WorldState, runner: SimRunner, npc_id: int, topic: String) -> Dictionary:
	var cmd := PlayerCommandSystem.new()
	st.player_state["gather_intel_npc_id"] = npc_id
	st.player_state["gather_intel_choice"] = topic
	var r: Dictionary = cmd.execute_action(st, npc_id, "confirm_gather_intel")
	print("      handler 回的句子：「%s」" % String(r.get("msg", "")))
	return {"text": String(r.get("msg", "")), "ok": bool(r.get("ok", false)),
		"payload": r.get("payload", {})}


func _initialize() -> void:
	print("=== 打聽 v1（情報必進 belief ＋ 代價＝同意）===")
	_test_p1_intel_enters_belief()
	_test_p3_silence_writes_nothing()
	_test_p4_unknown_is_not_silence()
	_test_p6_source_is_the_asked_team()
	_test_p7_topic_empty_is_verbatim()
	_test_p8_food_narrowed_to_seen_tiles()
	_test_counts_one_write_path()
	var miss: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): miss.append(c)
	if not miss.is_empty():
		_errors += 1
		push_error("[FAIL] 到場點名少了：%s" % str(miss))
	print("=== inquiry_v1 DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══════════ P1［問成功一次 ⇒ claim +≥1 且 fp 變］══════════
# ★★★票5 的 P13b 量到「fp 不變」是對的觀測、錯的結論：不是沒接線，是那條路本來不寫。
#   ⇒ 本票把它【翻過來】：現在「fp 變」才是對的。
# ★母體地板（spec P5）：印出實際 mode 與 giver 的 known 數 —— 沒有它們這一格會在
#   「每次都 honest 且對方什麼都知道」的世界裡恆綠。
# 負對照：把打聽那一次 `_exchange_intel(...)` 換成 `pass`（spec P2 指名） ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_p1_intel_enters_belief() -> void:
	_cur_cell = "_test_p1_intel_enters_belief"
	print("\n── P1 情報進 belief ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var ptid: int = st.get_player_team_id()
	_check("★母體地板①：有玩家隊（tid=%d）" % ptid, ptid != -1)
	var npc: int = _colocated_npc(st, ptid)
	_check("★母體地板②：造得出一支同格、而且【自己有情報】的 NPC 隊（tid=%d）" % npc, npc != -1)
	if ptid == -1 or npc == -1:
		_cell("_test_p1_intel_enters_belief")
		return
	# ★★讓它願意說：把它對玩家的評價拉高（★這是【造母體】，不是改判準 ——
	#   判準仍然是 `_decide_exchange_mode()` 那把既有的秤）
	st.teams[npc].known_reputations[ptid] = 0.9
	st.player_hostile_teams.erase(npc)
	var known_before: int = BeliefSystem.known_targets(st, npc).size()
	var claims_before: int = _claim_total(st, ptid)
	var fp0: String = StateFingerprint.compute(st)
	var res: Dictionary = _ask(st, runner, npc, "ask_team_location")
	var claims_after: int = _claim_total(st, ptid)
	var fp1: String = StateFingerprint.compute(st)
	print("   ★母體：giver(Team%d) known=%d｜結果句「%s」" % [
		npc, known_before, String(res.get("text", ""))])
	print("   claim 總筆數 %d → %d｜fp %s… → %s…" % [
		claims_before, claims_after, fp0.substr(0, 10), fp1.substr(0, 10)])
	_check("★母體地板③：被問隊【真的有東西可講】（known=%d ≥ 1）" % known_before, known_before >= 1)
	_check("★★claim 筆數增加（%d → %d）" % [claims_before, claims_after], claims_after > claims_before)
	_check("★★★world-fp【變了】（票5 P13b 的「不變＝對」在本票翻成「變＝對」）", fp0 != fp1)
	_cell("_test_p1_intel_enters_belief")


# ══════════ P3［拒答：零寫入 ＋ 專屬句子］══════════
# ★母體地板：要印出【實際的 mode】—— 若它不是 silent，這一格驗的就不是拒答。
# 負對照：把「他不願多說」換成與第三句相同的字串 ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_p3_silence_writes_nothing() -> void:
	_cur_cell = "_test_p3_silence_writes_nothing"
	print("\n── P3 拒答 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var ptid: int = st.get_player_team_id()
	var npc: int = _colocated_npc(st, ptid)
	if ptid == -1 or npc == -1:
		_check("★母體地板：造得出同格 NPC", false)
		_cell("_test_p3_silence_writes_nothing")
		return
	# ★造拒答：評價低 ＋ 領袖計謀低（計謀高會走 malicious 而不是 silent）
	#   ⇒ ★★★這是【用那把既有的秤自己的輸入】把它推到 silent，不是繞過它
	st.teams[npc].known_reputations[ptid] = 0.0
	st.teams[npc].faction_id = -1
	var leader: PersonData = st.persons.get(st.teams[npc].leader_id)
	if leader != null:
		leader.skills["計謀"] = 0.0
		leader.values["慎重"] = 1.0
	var claims_before: int = _claim_total(st, ptid)
	var res: Dictionary = _ask(st, runner, npc, "ask_team_location")
	var txt: String = String(res.get("text", ""))
	var claims_after: int = _claim_total(st, ptid)
	print("   ★母體：結果句「%s」｜claim %d → %d" % [txt, claims_before, claims_after])
	_check("★母體地板：這一輪【真的走到拒答】（句子含「不願」）", txt.contains("不願"))
	_check("★★拒答 ⇒ claim 零寫入（%d → %d）" % [claims_before, claims_after],
		claims_after == claims_before)
	_cell("_test_p3_silence_writes_nothing")


# ══════════ P4［「不知道」≠「不願說」］══════════
# ★★★判準是【兩個不同的字串】：混成一句的話，玩家分不出「關係壞」與「他真的沒情報」，
#   而那兩件事的處置完全相反（一個要修關係、一個要換人問）。
# 負對照：把「他也不知道」併進第三句 ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_p4_unknown_is_not_silence() -> void:
	_cur_cell = "_test_p4_unknown_is_not_silence"
	print("\n── P4 不知道 ≠ 不願說 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var ptid: int = st.get_player_team_id()
	# ★造一支【願意說但什麼都不知道】的隊：清掉它的 belief 與訊息
	var npc: int = -1
	for tid in st.teams:
		if int(tid) == ptid: continue
		npc = int(tid)
		break
	if ptid == -1 or npc == -1:
		_check("★母體地板：造得出 NPC", false)
		_cell("_test_p4_unknown_is_not_silence")
		return
	st.teams[npc].tile_pos = st.teams[ptid].tile_pos
	st.teams[npc].known_reputations[ptid] = 0.95
	st.player_hostile_teams.erase(npc)
	st.team_intel[npc] = {}
	st.team_known[npc] = []
	var known_n: int = BeliefSystem.known_targets(st, npc).size()
	var claims_before: int = _claim_total(st, ptid)
	var res: Dictionary = _ask(st, runner, npc, "ask_team_location")
	var txt: String = String(res.get("text", ""))
	print("   ★母體：giver known=%d（必須是 0）｜結果句「%s」" % [known_n, txt])
	_check("★母體地板①：被問隊【真的什麼都不知道】（known=%d ＝ 0）" % known_n, known_n == 0)
	_check("★母體地板②：而它【不是】拒答（句子不含「不願」）", not txt.contains("不願"))
	_check("★★★句子是「他也不知道」（與拒答那句【不同】）", txt.contains("也不知道"))
	_check("★claim 零寫入（%d → %d）" % [claims_before, _claim_total(st, ptid)],
		_claim_total(st, ptid) == claims_before)
	_cell("_test_p4_unknown_is_not_silence")


# ══════════ P6［來源＝被問隊］══════════
# 負對照：`record_claim` 的 source 改成填 receiver 自己／或把記憶頁守衛換回 `is_empty()`（面板恆空） ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_p6_source_is_the_asked_team() -> void:
	_cur_cell = "_test_p6_source_is_the_asked_team"
	print("\n── P6 來源是被問的那支隊 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var ptid: int = st.get_player_team_id()
	var npc: int = _colocated_npc(st, ptid)
	if ptid == -1 or npc == -1:
		_check("★母體地板：造得出同格 NPC", false)
		_cell("_test_p6_source_is_the_asked_team")
		return
	st.teams[npc].known_reputations[ptid] = 0.9
	st.player_hostile_teams.erase(npc)
	var before: Dictionary = {}
	for tgt in BeliefSystem.known_targets(st, ptid):
		before[int(tgt)] = BeliefSystem.claims(st, ptid, int(tgt)).size()
	_ask(st, runner, npc, "ask_team_location")
	# 找一筆【新增的】claim，看它的 source_id
	var found_src: int = -999
	for tgt in BeliefSystem.known_targets(st, ptid):
		var cs: Array = BeliefSystem.claims(st, ptid, int(tgt))
		if cs.size() > int(before.get(int(tgt), 0)):
			found_src = int(cs[cs.size() - 1].get("source_id", -999))
			break
	print("   新增那一筆的 source_id=%d（期望 %d）" % [found_src, npc])
	_check("★母體地板：真的有新增的 claim（找到一筆）", found_src != -999)
	_check("★★★新那筆的 source_id == 被問隊 id", found_src == npc)
	# ★記憶頁印得出「來自 TeamX」
	var env: Dictionary = PlayerQueryApi.new().query_memory_panel(st)
	var rows: Array = env.get("data", {}).get("memory", [])
	var has_src: bool = false
	for r in rows:
		if String(r.get("source", "")) == ("Team%d" % npc): has_src = true
	print("   記憶頁 %d 列｜找到「來自 Team%d」=%s" % [rows.size(), npc, str(has_src)])
	_check("★母體地板：記憶頁非空（%d 列）" % rows.size(), rows.size() > 0)
	_check("★★記憶頁印得出「來自 Team%d」" % npc, has_src)
	_cell("_test_p6_source_is_the_asked_team")


# ══════════ P7［重構零行為：topic=="" 兩段都走］══════════
# ★★★第一版是【兩邊同源】：我拿「三參數呼叫」與「五參數 topic=\"\" 呼叫」比 fp，
#   而它們走的是【同一條 code path】⇒ 我把那條路改壞，兩邊一起壞、差異仍然是空
#   ⇒ 負對照【不紅】（2026-09-25 實測）。★那正是「比較的兩邊同源 ⇒ 差異集合恆空」。
# ⇒ ★★改成驗【被守的性質本身】：`topic == ""` 必須【兩段都走】——
#   訊息複製那一段（team_known 變多）＋ claim 那一段（written > 0）。
#   ★★★把 `topic == ""` 從任一段的條件裡拿掉 ⇒ 那一段就不走 ⇒ 這一格紅。
# 負對照：把 `topic == ""` 從 `want_claims` 的條件裡拿掉 ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_p7_topic_empty_is_verbatim() -> void:
	_cur_cell = "_test_p7_topic_empty_is_verbatim"
	print("
── P7 topic=\"\" 兩段都走 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var ms := SimMessageSystem.new()
	# 找一對【giver 有情報、也有訊息】的隊，否則這一格的母體是空的
	var giver: int = -1
	var recv: int = -1
	for tid in st.teams:
		if BeliefSystem.known_targets(st, int(tid)).size() > 0 				and not st.team_known.get(int(tid), []).is_empty():
			giver = int(tid)
			break
	for tid in st.teams:
		if int(tid) != giver:
			recv = int(tid)
			break
	_check("★母體地板①：找得到一支【有情報也有訊息】的 giver（tid=%d）" % giver, giver != -1)
	_check("★母體地板②：找得到 receiver（tid=%d）" % recv, recv != -1)
	if giver == -1 or recv == -1:
		_cell("_test_p7_topic_empty_is_verbatim")
		return
	# ★讓它願意說（否則 silent 之後兩段都不走，這一格會誤判成「沒走」）
	st.teams[giver].known_reputations[recv] = 0.9
	st.player_hostile_teams.erase(recv)
	var msgs_before: int = st.team_known.get(recv, []).size()
	var out: Dictionary = {}
	ms._exchange_intel(st, giver, recv, "", out)
	var msgs_after: int = st.team_known.get(recv, []).size()
	print("   mode=%s｜giver known=%d｜訊息 %d → %d｜claim 寫入 %d 筆" % [
		String(out.get("mode", "?")), int(out.get("giver_known", -1)),
		msgs_before, msgs_after, int(out.get("written", 0))])
	_check("★母體地板③：這一輪不是拒答（mode=%s）" % String(out.get("mode", "?")),
		String(out.get("mode", "")) != "silent")
	_check("★★topic=\"\" 走了【訊息複製】那一段（%d → %d）" % [msgs_before, msgs_after],
		msgs_after > msgs_before)
	_check("★★★topic=\"\" 也走了【claim】那一段（寫入 %d 筆）" % int(out.get("written", 0)),
		int(out.get("written", 0)) > 0)
	_cell("_test_p7_topic_empty_is_verbatim")


# ══════════ P8［食物收窄：沒見過的格不得出現］══════════
# ★負對照在對照腳本裡（把母體改回全圖 ⇒ 這一格必紅）。
# 負對照：把食物母體改回 `state.world.tiles`（全圖） ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_p8_food_narrowed_to_seen_tiles() -> void:
	_cur_cell = "_test_p8_food_narrowed_to_seen_tiles"
	print("\n── P8 食物只給【他見過的格】──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var ptid: int = st.get_player_team_id()
	var npc: int = _colocated_npc(st, ptid)
	if ptid == -1 or npc == -1:
		_check("★母體地板：造得出同格 NPC", false)
		_cell("_test_p8_food_narrowed_to_seen_tiles")
		return
	# ★造一塊【被問隊沒見過】的高食物格：挑一個不在 team_tile_known 裡的 tile
	var seen: Dictionary = st.team_tile_known.get(npc, {})
	var secret_id: int = -1
	for tid in st.world.tiles:
		if not seen.has(tid):
			secret_id = int(tid)
			break
	_check("★母體地板①：找得到一塊【他沒見過】的格（tile_id=%d）" % secret_id, secret_id != -1)
	if secret_id == -1:
		_cell("_test_p8_food_narrowed_to_seen_tiles")
		return
	var secret: HexTileData = st.world.tiles[secret_id]
	secret.resources["food"] = 9999.0
	var secret_pos: Vector2i = secret.tile_pos
	# ★★★母體必須鎖在【誠實】那一支：`_find_food_tiles()` 在 `honest == false` 時會把
	#   報出來的座標【隨機偏移】（`pos += randi_range(-2,2)`）⇒ 偏移後的格自然不在「見過」清單裡
	#   ⇒ ★那是【說謊】不是【洩漏】，而判準必須分得開這兩件事（2026-09-25 實測紅出來的）。
	#   ★★鎖法是動那把既有的秤的【輸入】（被問方對玩家的評價）——不是改判準。
	st.teams[npc].known_reputations[ptid] = 0.95
	# ★母體地板②：他見過的格【裡面】要有東西可給，否則「沒有洩漏」也可能是「什麼都沒給」
	print("   ★母體：他見過 %d 格｜藏的那格 tile_id=%d pos=%s food=9999" % [
		seen.size(), secret_id, str(secret_pos)])
	var res: Dictionary = InquirySystem.new().resolve_inquiry(
		st, st.teams[ptid], st.teams[npc], "ask_food_source")
	var tiles: Array = res.get("food_tiles", [])
	# ★★★判準是【回的每一塊都必須是他見過的】，不是【那一格有沒有洩漏】：
	#   `_find_food_tiles()` 取到 3 塊就 break ⇒ 藏的那格可能【排不進前 3】
	#   ⇒ 只看那一格的版本，負對照（母體改回全圖）【不紅】（2026-09-25 實測）。
	var outsiders: Array = []
	for t in tiles:
		var pp: Vector2i = Vector2i(t.get("tile_pos", Vector2i(-1, -1)))
		if not seen.has(pp.x * 1000 + pp.y):
			outsiders.append(str(pp))
	print("   回了 %d 塊｜其中【他沒見過】的有 %d 塊：%s" % [
		tiles.size(), outsiders.size(), str(outsiders)])
	# ★母體地板：要真的回了東西 —— 回 0 塊的話「沒有外來的」恆真
	_check("★母體地板②：真的回了至少 1 塊（%d）" % tiles.size(), tiles.size() >= 1)
	_check("★母體地板③：這一輪是【誠實】的（rel=%.2f > 0.5）⇒ 座標沒被偏移"
		% float(st.teams[npc].known_reputations.get(ptid, 0.5)),
		float(st.teams[npc].known_reputations.get(ptid, 0.5)) > 0.5)
	_check("★★★回的每一塊都是【他見過的格】（外來 %d 塊）" % outsiders.size(),
		outsiders.is_empty())
	_cell("_test_p8_food_narrowed_to_seen_tiles")


# ══════════ 數字格［一條寫入路徑／一個 relay 呼叫端］══════════
# ★★★systems 要的四個數之中，兩個可以做成【機械格】而不是靠人記得數。
#   ★而 grep 要【剝掉整行註解】：我自己解釋這個指標的那句話裡就含有它要數的字串
#     ⇒ 不剝的話這一格會把我的註解算進去（2026-09-25 實測：4 被數成 5、1 被數成 3）。
#   ★★而 `_exchange_intel(` 那一條要排除【定義行】與【`_step3b_exchange_intel(`】
#     —— 後者是子字串誤中，下一個人數出 11 還會以為自己對。
# 負對照：在別處另寫一個 `record_claim(` 呼叫點 ⇒ 已於 feat/inquiry-v1（2026-09-24 這一輪） 實測紅
func _test_counts_one_write_path() -> void:
	_cur_cell = "_test_counts_one_write_path"
	print("\n── 數字格：寫入路徑與 relay 呼叫端 ──")
	var files: Array = ["scripts/simulation/faction_ai_system.gd",
		"scripts/simulation/interaction_system.gd", "scripts/simulation/message_system.gd",
		"scripts/simulation/vision_system.gd", "scripts/simulation/player_command_system.gd",
		"scripts/simulation/inquiry_system.gd", "scripts/simulation/belief_system.gd",
		"scripts/simulation/sim_runner.gd", "scripts/ui/sim_bridge.gd"]
	var rc_sites: int = 0
	var ex_sites: int = 0
	for f in files:
		var src: String = FileAccess.get_file_as_string("res://" + f)
		_check("★母體地板：讀得到 %s" % f.get_file(), src.length() > 100)
		for l in src.split("\n"):
			var t: String = l.strip_edges()
			if t.begins_with("#"):
				continue   # ★剝整行註解：討論它的句子不是呼叫點
			if t.contains("record_claim(") and not t.contains("func record_claim"):
				rc_sites += 1
			if t.contains("_exchange_intel(") and not t.contains("func _exchange_intel") \
					and not t.contains("_step3b_exchange_intel("):
				ex_sites += 1
	print("   production record_claim 呼叫點=%d（期望 4）｜_exchange_intel 呼叫點=%d（期望 3）" % [
		rc_sites, ex_sites])
	# ★4 來自 spec §3(A)：「只要出現第二個 record_claim 呼叫點，這一票就寫錯了」
	_check("★★★寫入路徑仍然只有既有那 4 處（實測 %d）" % rc_sites, rc_sites == 4)
	# ★3 ＝ message_system 的 :187,188 兩行到達交換 ＋ player_command_system 打聽那一次
	_check("★★relay 呼叫端 ＝ 2 個到達 ＋ 1 個打聽（實測 %d）" % ex_sites, ex_sites == 3)
	_cell("_test_counts_one_write_path")
