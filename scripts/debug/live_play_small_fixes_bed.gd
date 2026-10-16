extends SceneTree
# @bed-kind: acceptance
# slice: 真玩小修七項（spec 2026-10-15-live-play-small-fixes-HOW）
# ★格（修前紅除註明）：
#   J1  求投靠：對方 1 隊長＋1 記名＋2 匿名、容量足 ⇒ 選單「+4 人，食物 −3.2」；接受後人口 +4、糧 −3.2、對方隊不存在、隊長與記名在玩家名冊
#   J2  容量只剩 2 ⇒ 選單標「不可：上限…對方 4 人」；按下 ok=false、雙方人口不變、沒多出隊、強制事件仍在
#   J1b 守恆：對方帶 2 小孩、1 組俘虜、coin／資源、anon_treasury、一個非空據點、一支子隊 ⇒ 全世界人口＋小孩＋俘虜＋coin＋各資源相等（糧＝扣掉一餐）、沒人被記成死、俘虜在玩家名下；據點與子隊去向印出
#   J3  子隊回歸三格（容量足／容量不足／容量 ≤ 0）結果印出並斷言形狀（_merge_into 本票未改，diff 為空）
#   P1  拔擢結果句含期望餉＝SalarySystem.fair_salary；成員頁「餉 0.0／期望 N」並標欠
#   P2  設餉＝期望後「欠」消失
#   P3  成員頁的期望值與發餉用同一支（mapper 值＝fair_salary）
#   P4  拔擢結果句（最長人名）含「✓ 」與前綴 ≤ COLS
#   P5  被發餉跳過的人（隊長、有 master 記憶）不標欠
#   K1  開面板 ⇒ 自家側有可做的 ⇒ 自家側；K1b 開著按 Tab 到目標側、推進結束（自動開分支重跑）⇒ 仍在目標側；K1c 自家側全不可 ⇒ 目標側
#   K2  數字超出這一側 ⇒ 結果行「X這一側沒有第 N 項（Tab 換側）」
#   K3  重現真玩鍵序：目標側、先按 X（面板開著不能推進）再按 9 ⇒ 結果行換成「目標這一側沒有第 9 項」
#   T1  出價被拒 ⇒ 面板仍開、理由在結果行、出價仍在；T1b 移動中送出被拒 ⇒ 面板仍開；T1c 先拒後成 ⇒ 第二次才關（seq 不同）；T2 對方接 ⇒ 關
#   B1  戰鬥畫面鍵列與 GUI 動作列無 Z；B2 產線無 current_order／messenger_target_idx／create_subteam／is_messenger
#   H1  真玩那一行（長家、長營地）⇒ 無「…」、拿掉的是家與營地整格、隊名完整；H2 依序加長 ⇒ 消失順序＝家、營地、隊名、人口、糧撐；
#       H3 極端值 ⇒ 無「…」、時間＋最寬威脅句＋待執行 99＋分隔 ≤ COLS；H4 故事結束句同斷言；每一格整格或無

const EXPECTED: Array = ["J1", "J2", "J1b", "J3", "P1", "P2", "P3", "P4", "P5", "K1", "K1b", "K1c", "K2", "K3",
	"T1", "T1b", "T1c", "T2", "B1", "B2", "H1", "H2", "H3", "H4"]
const SEED: int = 20261015
const FT: int = 930   # 求投靠那一隊
var _errors: int = 0
var _present: Dictionary = {}
var _only: Dictionary = {}

func _on(fn: String) -> bool:
	return _only.is_empty() or _only.has(fn)

func _initialize() -> void:
	print("=== live_play_small_fixes：真玩小修七項 ===")
	var only: String = OS.get_environment("BED_ONLY")
	if only != "":
		for f in only.split(","):
			_only[String(f).strip_edges()] = true
		print("★★★BED_ONLY=%s：只跑子集，這一輪不能當驗收" % only)
	if _on("_j"): _j()
	if _on("_j3"): _j3()
	if _on("_p"): _p()
	if _on("_k"): await _k()
	if _on("_t"): await _t()
	if _on("_b"): _b()
	if _on("_h"): _h()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty() and _only.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== live_play_small_fixes DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _cell(c: String) -> void:
	_present[c] = true

# ── 佈置 ─────────────────────────────────────────────────────────────────────
func _world() -> WorldState:
	seed(SEED)
	return MeasureBedHelper.arm_and_setup("res://config/default.json", false)

func _pt(st: WorldState) -> TeamData:
	return st.teams[st.get_player_team_id()]

func _person(st: WorldState, pid: int, tid: int, nm: String) -> PersonData:
	var p := PersonData.new()
	p.id = pid
	p.team_id = tid
	p.person_name = nm
	st.persons[pid] = p
	return p

# 一支站在玩家格上、求投靠的隊：1 隊長＋named 個記名＋anon 個匿名
func _seeker(st: WorldState, named: int, anon: int, tid: int = FT) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.faction_id = -1
	t.tile_pos = _pt(st).tile_pos
	_person(st, tid * 10 + 1, tid, "流民首領")
	t.leader_id = tid * 10 + 1
	for i in range(named):
		_person(st, tid * 10 + 2 + i, tid, "流民%d" % i)
		t.named_members.append(tid * 10 + 2 + i)
	if anon > 0:
		AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, anon)
	t.resources["food"] = 10.0
	st.teams[tid] = t
	return t

func _arm_join(st: WorldState, tid: int) -> void:
	st.set_player_forced_event({"action": "join_request", "from_id": tid}, "bed-join-%d" % tid)

static func _cap_room(st: WorldState, pt: TeamData) -> int:
	return FactionAISystem.effective_pop_cap(st, pt) - pt.population

# 把玩家隊人口調到「剩 room 格」
static func _set_room(st: WorldState, pt: TeamData, room: int) -> void:
	var need: int = _cap_room(st, pt) - room
	if need > 0:
		AnonTierSystem.add_anon(pt, AnonCohort.TIER_PLEB, need)
	elif need < 0:
		AnonTierSystem.kill_random(pt, -need, "bed")

static func _label(st: WorldState, rid: String) -> String:
	return PlayerApiMapper.forced_label("join_request", rid, st, st.player_forced_event)

# ── J1／J2／J1b ──────────────────────────────────────────────────────────────
func _j() -> void:
	print("\n── J 求投靠：整隊或不成 ──")
	var cmd := PlayerCommandSystem.new()
	# J1
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	ResourceBank.set_amt(pt, "food", 100.0, "bed")
	_set_room(st, pt, 10)
	var ft: TeamData = _seeker(st, 1, 2)
	_arm_join(st, FT)
	var lab: String = _label(st, "accept")
	var pop0: int = pt.population
	var food0: float = float(pt.resources.get("food", 0))
	var ffood: float = float(ft.resources.get("food", 0))   # ★整隊併入：對方隊的糧也跟著來（長分支掃光資源）
	var r: Dictionary = cmd.respond_to_forced(st, "accept")
	var roster_ok: bool = pt.named_members.has(FT * 10 + 1) and pt.named_members.has(FT * 10 + 2)
	print("   J1 選單「%s」｜%s｜人口 %d→%d 糧 %.1f→%.1f" % [lab, str(r), pop0, pt.population, food0, float(pt.resources.get("food", 0))])
	_check("J1 選單「收留（+4 人，食物 −3.2）」；接受後人口 +4、糧＝原有＋對方帶來的 %.1f −3.2、對方隊不存在、隊長與記名在玩家名冊" % ffood,
		lab == "收留（+4 人，食物 −3.2）" and bool(r.get("ok", false)) and pt.population == pop0 + 4
		and absf(float(pt.resources.get("food", 0)) - (food0 + ffood - 3.2)) < 0.001 and not st.teams.has(FT) and roster_ok)
	_cell("J1")
	# J2
	st = _world()
	pt = _pt(st)
	ResourceBank.set_amt(pt, "food", 100.0, "bed")
	_set_room(st, pt, 2)
	ft = _seeker(st, 1, 2)
	_arm_join(st, FT)
	lab = _label(st, "accept")
	pop0 = pt.population
	var nteams: int = st.teams.size()
	r = cmd.respond_to_forced(st, "accept")
	print("   J2 選單「%s」｜%s｜人口 %d→%d、對方 %d 人、隊數 %d→%d、強制事件 %s" % [lab, str(r), pop0, pt.population,
		ft.population, nteams, st.teams.size(), str(st.player_forced_event)])
	_check("J2 選單標「不可：上限…對方 4 人」；按下 ok=false、雙方人口不變、沒多出隊、強制事件仍在",
		lab.contains("不可：上限") and lab.contains("對方 4 人") and not bool(r.get("ok", true)) and String(r.get("msg", "")).contains("對方 4 人")
		and pt.population == pop0 and ft.population == 4 and st.teams.size() == nteams and String(st.player_forced_event.get("action", "")) == "join_request")
	_cell("J2")
	# J1b 守恆
	st = _world()
	pt = _pt(st)
	ResourceBank.set_amt(pt, "food", 100.0, "bed")
	_set_room(st, pt, 10)
	ft = _seeker(st, 1, 2)
	ft.minor_population = 2
	var cco: Dictionary = {}
	AnonCohort.add(cco, AnonCohort.TIER_PLEB, "healthy", 3)
	ft.captive_groups.append(AnonTierSystem._new_captive_group(cco, -1, "bed"))
	ResourceBank.set_amt(ft, "coin", 40.0, "bed")
	ResourceBank.set_amt(ft, "material", 25.0, "bed")
	AnonTreasuryBank.transfer(pt, ft, 0.0, "bed")
	ft.anon_treasury = 12.0
	var otile: HexTileData = null
	for k in st.world.tiles:
		var tl: HexTileData = st.world.tiles[k]
		if tl.outpost_level == 0 and tl.tile_pos != pt.tile_pos:
			otile = tl
			break
	otile.outpost_level = 1
	otile.outpost_type = "civilian"
	OutpostOwnerBank.set_owner(st, otile, FT, "bed")
	TileBank.deposit(otile, "food", 5.0, "bed")
	var sub: TeamData = TeamData.new()
	sub.team_id = FT + 1
	sub.tile_pos = otile.tile_pos
	_person(st, sub.team_id * 10 + 1, sub.team_id, "子隊長")
	sub.leader_id = sub.team_id * 10 + 1
	AnonTierSystem.add_anon(sub, AnonCohort.TIER_PLEB, 1)
	st.teams[sub.team_id] = sub
	st.set_subteam_parent(sub, FT)
	var s0: Dictionary = _sums(st)
	var dead0: int = _dead(st)
	var cap0: int = AnonTierSystem.total_captives(pt)
	_arm_join(st, FT)
	r = cmd.respond_to_forced(st, "accept")
	var s1: Dictionary = _sums(st)
	print("   J1b %s｜前 %s\n       後 %s" % [str(r), str(s0), str(s1)])
	print("   J1b 去向：據點 (%d,%d) owner %d｜子隊 Team%d parent_team_id=%d 還在=%s｜玩家俘虜 %d→%d" % [
		otile.tile_pos.x, otile.tile_pos.y, otile.outpost_owner, sub.team_id, sub.parent_team_id, str(st.teams.has(sub.team_id)),
		cap0, AnonTierSystem.total_captives(pt)])
	var same: bool = true
	for k in s0:
		if k == "food":
			continue
		if absf(float(s0[k]) - float(s1[k])) > 0.001:
			same = false
	_check("J1b 守恆：人口＋小孩＋俘虜＋coin＋各資源（全世界）相等、糧只少一餐（%.1f）、沒人被記成死（%d→%d）" % [
		float(s0["food"]) - float(s1["food"]), dead0, _dead(st)],
		bool(r.get("ok", false)) and same and absf(float(s0["food"]) - float(s1["food"]) - 0.8 * 4) < 0.001 and _dead(st) == dead0)
	_check("J1b 俘虜組整組在玩家名下（%d→%d）" % [cap0, AnonTierSystem.total_captives(pt)], AnonTierSystem.total_captives(pt) == cap0 + 3)
	_cell("J1b")

func _sums(st: WorldState) -> Dictionary:
	var s: Dictionary = {"pop": 0, "minor": 0, "captive": 0, "treasury": 0.0}
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		s["pop"] += t.population
		s["minor"] += t.minor_population
		s["captive"] += AnonTierSystem.total_captives(t)
		s["treasury"] += t.anon_treasury
		for res in t.resources:
			s[res] = float(s.get(res, 0.0)) + float(t.resources[res])
	return s

static func _dead(st: WorldState) -> int:
	var n: int = 0
	for pid in st.persons:
		if (st.persons[pid] as PersonData).is_dead:
			n += 1
	return n

# ── J3 子隊回歸（_merge_into 未改）──────────────────────────────────────────
func _j3() -> void:
	print("\n── J3 子隊回歸三格 ──")
	var sigs: Array = []
	for room in [10, 1, 0]:
		var st: WorldState = _world()
		var pt: TeamData = _pt(st)
		_set_room(st, pt, room)
		var sub := TeamData.new()
		sub.team_id = FT + 5
		sub.tile_pos = pt.tile_pos
		AnonTierSystem.add_anon(sub, AnonCohort.TIER_PLEB, 3)
		st.teams[sub.team_id] = sub
		st.set_subteam_parent(sub, pt.team_id)
		var p0: int = pt.population
		SubteamSystem.new()._merge_into(st, pt.team_id, sub.team_id)
		var sig: String = "room=%d 母 %d→%d 子在=%s 子人口=%d 子 parent=%d" % [room, p0, pt.population, str(st.teams.has(sub.team_id)),
			sub.population if st.teams.has(sub.team_id) else -1, sub.parent_team_id]
		print("   " + sig)
		sigs.append([room, p0, pt.population, st.teams.has(sub.team_id), sub.parent_team_id])
	_check("J3 容量足 ⇒ 全併、子隊消失", sigs[0][2] == sigs[0][1] + 3 and not sigs[0][3])
	_check("J3 容量不足 ⇒ 部分併（+1）、子隊留下", sigs[1][2] == sigs[1][1] + 1 and sigs[1][3])
	_check("J3 容量 ≤ 0 ⇒ 不併、子隊脫離母團獨立", sigs[2][2] == sigs[2][1] and sigs[2][3] and sigs[2][4] == -1)
	_cell("J3")

# ── P 拔擢說餉 ───────────────────────────────────────────────────────────────
func _p() -> void:
	print("\n── P 拔擢要說餉 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	if AnonTierSystem.total_pop(pt) <= 0:
		AnonTierSystem.add_anon(pt, AnonCohort.TIER_PLEB, 3)
	var cmd := PlayerCommandSystem.new()
	var before: Array = pt.named_members.duplicate()
	var r: Dictionary = cmd.execute_action(st, -1, "promote_anon")
	var nid: int = -1
	for m in pt.named_members:
		if not before.has(m):
			nid = int(m)
	var np: PersonData = st.persons.get(nid)
	var fair: float = SalarySystem.fair_salary(np) if np != null else -1.0
	var row: Dictionary = {}
	for m in PlayerApiMapper.map_members_detail(st):
		if int(m.get("id", -1)) == nid:
			row = m
	var card: Array = TeamUiHelper.render_quick_card(row)
	var sal_line: String = ""
	for l in card:
		if String(l).begins_with("餉 "):
			sal_line = String(l)
	print("   P1 %s｜期望 %.1f｜成員頁「%s」" % [str(r), fair, sal_line])
	_check("P1 拔擢結果句含期望餉（＝fair_salary）與去哪設；成員頁「餉 0.0／期望 N」並標欠",
		bool(r.get("ok", false)) and String(r.get("msg", "")).contains("期望餉 %.1f" % fair) and String(r.get("msg", "")).contains("[Y]")
		and sal_line.begins_with("餉 0.0／期望 %.1f" % fair) and sal_line.contains("欠"))
	_cell("P1")
	np.salary = fair
	var row2: Dictionary = {}
	for m in PlayerApiMapper.map_members_detail(st):
		if int(m.get("id", -1)) == nid:
			row2 = m
	var sal2: String = ""
	for l in TeamUiHelper.render_quick_card(row2):
		if String(l).begins_with("餉 "):
			sal2 = String(l)
	_check("P2 設餉＝期望後「欠」消失（%s）" % sal2, sal2 != "" and not sal2.contains("欠"))
	_cell("P2")
	_check("P3 成員頁期望值與發餉同一支（mapper %.3f＝SalarySystem.fair_salary %.3f）" % [float(row2.get("fair_salary", -9)), SalarySystem.fair_salary(np)],
		absf(float(row2.get("fair_salary", -9)) - SalarySystem.fair_salary(np)) < 0.0001)
	_cell("P3")
	# P4 最長人名
	var longest: String = ""
	var ls: String = ""
	var lg: String = ""
	for s in PersonGenerator.SURNAMES:
		if TextUiLayout.display_width(String(s)) > TextUiLayout.display_width(ls): ls = String(s)
	for g in PersonGenerator.GIVEN_NAMES:
		if TextUiLayout.display_width(String(g)) > TextUiLayout.display_width(lg): lg = String(g)
	longest = ls + lg + "9999"   # _random_name 撞名退路會加人數
	var msg: String = "拔擢 %s；期望餉 %.1f，現 %.1f（成員頁 [Y] 設餉）" % [longest, 999.9, 0.0]
	var w: int = TextUiLayout.display_width(" 結果：✓ " + msg)
	print("   P4 最長人名「%s」⇒ 結果行寬 %d／%d" % [longest, w, TextUiLayout.COLS])
	_check("P4 拔擢結果句（最長人名、期望 999.9）含前綴 ≤ COLS", w <= TextUiLayout.COLS)
	_cell("P4")
	# P5 跳過者不標欠：隊長、有 master 記憶的人
	var lrow: Dictionary = {}
	for m in PlayerApiMapper.map_members_detail(st):
		if int(m.get("id", -1)) == pt.leader_id:
			lrow = m
	np.salary = 0.0
	np.memory.append({"type": "master", "subject_id": pt.leader_id, "tick": 0, "intensity": 1.0})
	var mrow: Dictionary = {}
	for m in PlayerApiMapper.map_members_detail(st):
		if int(m.get("id", -1)) == nid:
			mrow = m
	var lcard: String = "\n".join(PackedStringArray(TeamUiHelper.render_quick_card(lrow)))
	var mcard: String = "\n".join(PackedStringArray(TeamUiHelper.render_quick_card(mrow)))
	_check("P5 隊長與有 master 記憶者不標欠（隊長 skipped=%s、門客 skipped=%s）" % [str(lrow.get("wage_skipped")), str(mrow.get("wage_skipped"))],
		bool(lrow.get("wage_skipped", false)) and bool(mrow.get("wage_skipped", false)) and not lcard.contains("欠") and not mcard.contains("欠"))
	_cell("P5")

# ── UI 共用 ─────────────────────────────────────────────────────────────────
func _build() -> Node:
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node.suppress_quit = true
	node._refresh()
	return node

func _drop(node: Node) -> void:
	node.queue_free()
	await process_frame

func _press(node: Node, token: String) -> void:
	await PlayerRepl.press_on(node, PlayerRepl.keycode_for(token))

func _settle(node: Node) -> void:
	for i in range(30):
		await process_frame
		if not node._bridge.is_advancing():
			break
	await process_frame

static func _fb(node: Node) -> String:
	return String(node._feedback_line.text) if node._feedback_line != null else ""

# ── K 互動面板 ───────────────────────────────────────────────────────────────
func _k() -> void:
	print("\n── K 互動面板預設側＋空項回句 ──")
	var node: Node = await _build()
	var selfs: Array = node._interact_action_split()["self"].filter(func(a): return bool(a.get("enabled", true)))
	node._interact_pane = node.PANE_TARGETS   # 上次留在目標側
	await _press(node, "t")
	print("   K1 自家側可做 %d 項 ⇒ 開在 %s" % [selfs.size(), node._interact_pane])
	_check("K1 開面板 ⇒ 自家側有可做的 ⇒ 自家側（上次留在目標側也一樣）", selfs.size() > 0 and node._interact_pane == node.PANE_SELF)
	_cell("K1")
	# K1b：面板開著按 Tab 到目標側；強制事件在 ⇒ 推進結束時自動開那一支重跑 ⇒ 仍在目標側
	await _press(node, "tab")
	var st: WorldState = node._bridge.get_state()
	_seeker(st, 0, 1, FT + 20)
	st.set_player_forced_event({"action": "join_request", "from_id": FT + 20}, "bed-k1b")
	node._bridge.request_advance(1)
	await _settle(node)
	print("   K1b Tab 後 ⇒ %s；推進結束後 ⇒ %s（面板開著 %s）" % ["targets", node._interact_pane, str(node._interact_mode)])
	_check("K1b 面板開著按 Tab 到目標側、推進結束（自動開分支重跑）⇒ 仍在目標側", node._interact_mode and node._interact_pane == node.PANE_TARGETS)
	_cell("K1b")
	# K1c：自家側全不可 ⇒ 目標側（判斷用開啟當下的快照）
	var snap_save = node._cached_snapshot.get("available_actions", [])
	var fake: Array = []
	for a in snap_save:
		var b: Dictionary = (a as Dictionary).duplicate(true)
		b["enabled"] = false
		fake.append(b)
	node._cached_snapshot["available_actions"] = fake
	var pane_c: String = node._default_interact_pane()
	node._cached_snapshot["available_actions"] = snap_save
	_check("K1c 自家側全不可 ⇒ 開在目標側（%s）" % pane_c, pane_c == node.PANE_TARGETS)
	_cell("K1c")
	await _drop(node)
	# K2／K3：目標側、先按 X（面板開著不能推進）、再按 9
	node = await _build()
	await _press(node, "t")
	node._interact_pane = node.PANE_TARGETS
	await _press(node, "x")
	var fb_x: String = _fb(node)
	await _press(node, "9")
	var fb_9: String = _fb(node)
	print("   K3 X ⇒「%s」｜再按 9 ⇒「%s」" % [fb_x, fb_9])
	_check("K3 重現真玩鍵序：X 回「面板開著時不能推進」，再按 9 ⇒ 結果行換成「目標這一側沒有第 9 項（Tab 換側）」（舊版無聲、留著上一句）",
		fb_x.contains("面板開著時不能推進") and fb_9.contains("目標這一側沒有第 9 項（Tab 換側）"))
	_cell("K3")
	node._interact_pane = node.PANE_SELF
	var nself: int = node._interact_action_split()["self"].size()
	var key: String = str(mini(nself + 1, 9))
	if nself >= 9:
		await _press(node, "tab")   # 自家側滿 9 項 ⇒ 改測目標側
		key = "9"
	await _press(node, key)
	var fb_k2: String = _fb(node)
	print("   K2 %s側共 %d 項、按 %s ⇒「%s」" % [node._interact_pane, nself, key, fb_k2])
	_check("K2 數字超出這一側 ⇒「X這一側沒有第 N 項（Tab 換側）」", fb_k2.contains("這一側沒有第 %s 項（Tab 換側）" % key))
	_cell("K2")
	await _drop(node)

# ── T 交換被拒面板不關 ───────────────────────────────────────────────────────
func _trade_setup(node: Node, gives: Dictionary) -> int:
	var st: WorldState = node._bridge.get_state()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var x: TeamData = _seeker(st, 0, 3, FT + 30)
	x.resources["coin"] = 50.0
	ResourceBank.set_amt(pt, "coin", 200.0, "bed")
	st.player_state["pending_trade_target"] = x.team_id
	node._trade_mode = true
	node._trade_target_id = x.team_id
	node._trade_wait_seq = -1
	node._bridge.set_player_input("trade_offer", {"player_gives": gives, "player_wants": {}})
	return x.team_id

static func _result_ok(st: WorldState, seq: int):
	for c in st.command_results:
		if int(c.get("seq", -1)) == seq:
			return bool(c.get("ok", false))
	return null

func _t() -> void:
	print("\n── T 交換被拒面板不自動關 ──")
	var node: Node = await _build()
	_trade_setup(node, {})
	await _press(node, "enter")
	await _settle(node)
	var st: WorldState = node._bridge.get_state()
	var offer_kept: bool = st.player_state.has("trade_offer")
	print("   T1 空出價 ⇒ 面板 %s｜結果行「%s」｜出價還在 %s" % [str(node._trade_mode), _fb(node), str(offer_kept)])
	_check("T1 對方拒 ⇒ 面板仍開、理由在結果行、出價仍在", node._trade_mode and _fb(node).contains("出價為空") and offer_kept)
	_cell("T1")
	# T1c：先拒（上面那一筆），再送一個會收的 ⇒ 第二筆到了才關；兩筆 seq 不同、第一筆的拒絕沒有讓面板關
	var seq1: int = int(st.command_seq)
	var r1ok = _result_ok(st, seq1)
	node._bridge.set_player_input("trade_offer", {"player_gives": {"coin": 5.0}, "player_wants": {}})
	await _press(node, "enter")
	await _settle(node)
	var seq2: int = int(st.command_seq)
	var r2ok = _result_ok(st, seq2)
	print("   T1c 第一筆 seq %d ok=%s｜第二筆 seq %d ok=%s ⇒ 面板 %s｜結果行「%s」" % [seq1, str(r1ok), seq2, str(r2ok), str(node._trade_mode), _fb(node)])
	_check("T1c 前一次的拒絕不被當成這一次：第一筆（seq %d）拒、面板沒關；第二筆（seq %d）成交才關" % [seq1, seq2],
		seq2 > seq1 and r1ok == false and r2ok == true and not node._trade_mode)
	_cell("T1c")
	_check("T2 對方接 ⇒ 關", not node._trade_mode)
	_cell("T2")
	await _drop(node)
	# T1b：玩家隊在移動中送出被拒的出價 ⇒ 面板仍開。
	#   ★移動換格會清掉 pending_trade_target（text_ui_main 換格那一段）⇒ 佈置照那個結果：pending 已被清、出價送出被拒
	#   ⇒ 判準若是「pending 不見了＝成交」就會把這次拒絕誤判成成交而關面板（負對照 n8）
	node = await _build()
	st = node._bridge.get_state()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	_trade_setup(node, {})
	pt.move_target = pt.tile_pos + Vector2i(1, 0)
	st.player_state.erase("pending_trade_target")
	await _press(node, "enter")
	await _settle(node)
	print("   T1b 移動中 ⇒ 面板 %s｜結果行「%s」" % [str(node._trade_mode), _fb(node)])
	_check("T1b 移動中送出被拒 ⇒ 面板仍開", node._trade_mode)
	_cell("T1b")
	await _drop(node)

# ── B 戰鬥命令拿掉 ───────────────────────────────────────────────────────────
static func _code_hits(path: String, word: String) -> int:
	var n: int = 0
	for l in FileAccess.get_file_as_string(path).split("\n"):
		if String(l).strip_edges().begins_with("#"):
			continue
		var code: String = String(l).split("#")[0]
		if code.contains(word):
			n += 1
	return n

func _b() -> void:
	print("\n── B 戰鬥畫面命令拿掉 ──")
	var ev = load("res://scripts/ui/encounter_view.gd")
	var hints: String = String(ev.ACTION_HINTS)
	var kz: int = _code_hits("res://scripts/ui/encounter_view.gd", "KEY_Z") + _code_hits("res://scripts/ui/encounter_view.gd", "Z:命令")
	print("   B1 ACTION_HINTS「%s」｜encounter_view 程式碼 KEY_Z／Z:命令 %d 處" % [hints.replace("\n", " / "), kz])
	_check("B1 戰鬥畫面鍵列與 GUI 動作列無 Z（終端按 Z 的未綁鍵處置由 terminal_e2e BATTLE⑦ 守）", not hints.contains("Z:") and kz == 0)
	_cell("B1")
	var hits: Dictionary = {}
	for f in ["res://scripts/ui/encounter_view.gd", "res://scripts/simulation/encounter_system.gd"]:
		for w in ["current_order", "messenger_target_idx", "create_subteam", "is_messenger", "_messenger_exit"]:
			var n: int = _code_hits(f, w)
			if n > 0:
				hits["%s:%s" % [f.get_file(), w]] = n
	print("   B2 產線殘留 %s" % str(hits))
	_check("B2 產線無 current_order／messenger_target_idx／create_subteam／is_messenger／_messenger_exit", hits.is_empty())
	_cell("B2")

# ── H 頂列 ───────────────────────────────────────────────────────────────────
static func _whole_cells(v: Dictionary) -> bool:
	var cells: Dictionary = TextUiView.top_cells(v)
	var row: String = TextUiView.top_row(v)
	var parts: Array = row.split(TextUiView.TOP_SEP)
	var shown: Array = TextUiView.top_shown(v)
	if parts.size() != shown.size():
		return false
	for i in range(shown.size()):
		if String(parts[i]) != String(cells[shown[i]]):
			return false
	return true

func _h() -> void:
	print("\n── H 頂列整格或不顯示 ──")
	var COLS: int = TextUiLayout.COLS
	# H1 真玩那一行（第 2 天 05:51、Team15、人口 10、威脅 Team11 敵對）：家與營地長
	var v1: Dictionary = {"clock": "2 天 05:51", "team_name": "Team15", "pop": "10",
		"home": "(3,5) 灰狼村（共 2 處）【暫代】很長很長很長很長很長",
		"camp": "(9,1) 離 0 格 很長很長很長很長很長很長很長很長很長",
		"food": "6.8 天", "threat": PlayerApiMapper.THREAT_ENEMY % [11, 0], "pending": "0 道"}
	var r1: String = TextUiView.top_row(v1)
	var miss1: Array = TextUiView.TOP_ORDER.filter(func(k): return not TextUiView.top_shown(v1).has(k))
	print("   H1 %s（寬 %d）｜拿掉 %s" % [r1, TextUiLayout.display_width(r1), str(miss1)])
	_check("H1 真玩那一行 ⇒ 無「…」、拿掉的是家與營地整格、隊名完整、≤ COLS",
		not r1.contains("…") and miss1 == ["home", "camp"] and r1.contains("Team15") and TextUiLayout.display_width(r1) <= COLS and _whole_cells(v1))
	_cell("H1")
	# H2 依序加長（五個可拿的格一起加長）⇒ 拿掉的永遠是 TOP_DROP_ORDER 的前綴、單調增加、最後五格全拿掉
	var prev: int = 0
	var mono: bool = true
	var prefix: bool = true
	var whole: bool = true
	var last: Array = []
	for L in range(0, 60, 3):
		var pad: String = "長".repeat(L)
		var v: Dictionary = {"clock": "2 天 05:51", "team_name": "隊" + pad, "pop": "10" + "0".repeat(L / 3),
			"home": "家" + pad, "camp": "營" + pad, "food": "6.8 天" + pad,
			"threat": PlayerApiMapper.THREAT_ENEMY % [11, 0], "pending": "0 道"}
		var miss: Array = TextUiView.TOP_ORDER.filter(func(k): return not TextUiView.top_shown(v).has(k))
		# ★期望順序寫 spec 的字面，不讀 TOP_DROP_ORDER（讀它＝同源比較恆真；負對照 n9 改常數這格要紅）
		var SPEC_ORDER: Array = ["home", "camp", "team", "pop", "food"]
		var want: Array = SPEC_ORDER.slice(0, miss.size())
		var ordered: Array = []
		for k in SPEC_ORDER:
			if miss.has(k): ordered.append(k)
		if ordered != want: prefix = false
		if miss.size() < prev: mono = false
		prev = miss.size()
		last = miss
		if not _whole_cells(v) or TextUiView.top_row(v).contains("…") or TextUiLayout.display_width(TextUiView.top_row(v)) > COLS:
			whole = false
	print("   H2 最後拿掉 %s" % str(last))
	_check("H2 依序加長 ⇒ 消失順序＝家、營地、隊名、人口、糧撐（前綴、單調、整格、≤ COLS）",
		prefix and mono and whole and last.size() == 5)
	_cell("H2")
	# H3 極端值：時間＋最寬威脅句＋待執行 99＋分隔 ≤ COLS
	var tr: int = TextUiView.threat_reserve()
	var fixed_w: int = TextUiLayout.display_width("第 999 天 23:59") + TextUiLayout.display_width("威脅：") + tr \
		+ TextUiLayout.display_width("待執行 99 道") + TextUiLayout.display_width(TextUiView.TOP_SEP) * 2
	var v3: Dictionary = {"clock": "999 天 23:59", "team_name": "Team99999", "pop": "9999", "home": "(999,999)",
		"camp": "(999,999) 離 99", "food": "999.9 天", "threat": "Team99999 敵對，最後所知 99 格", "pending": "99 道"}
	var r3: String = TextUiView.top_row(v3)
	print("   H3 threat_reserve＝%d｜時間＋最寬威脅＋待執行 99＋分隔＝%d／%d｜極端行 %s（寬 %d）" % [tr, fixed_w, COLS, r3, TextUiLayout.display_width(r3)])
	_check("H3 極端值 ⇒ 無「…」、整格、寬度斷言（%d ≤ %d）" % [fixed_w, COLS],
		fixed_w <= COLS and not r3.contains("…") and TextUiLayout.display_width(r3) <= COLS and _whole_cells(v3))
	_cell("H3")
	# H4 故事結束句：原因全集（event_system「玩家絕後（Team%d 無繼承人）」、player_command_system「玩家絕後（隊已滅,無繼承人）」、text_ui_main「（原因未記）」）
	var reasons: Array = ["玩家絕後（Team%d 無繼承人）" % 99999, "玩家絕後（隊已滅,無繼承人）", "（原因未記）"]
	var maxr: int = 0
	var ok4: bool = true
	for rs in reasons:
		maxr = maxi(maxr, TextUiLayout.display_width(String(rs)))
		var v4: Dictionary = v3.duplicate()
		v4["story_end"] = rs
		var r4: String = TextUiView.top_row(v4)
		if r4.contains("…") or TextUiLayout.display_width(r4) > COLS or not r4.contains(TextUiView.STORY_END_LABEL + String(rs)) or not _whole_cells(v4):
			ok4 = false
	var fixed4: int = TextUiLayout.display_width("第 999 天 23:59") + TextUiLayout.display_width(TextUiView.STORY_END_LABEL) + maxr \
		+ TextUiLayout.display_width("待執行 99 道") + TextUiLayout.display_width(TextUiView.TOP_SEP) * 2
	print("   H4 原因最寬 %d｜時間＋待執行＋欄標＋最長原因＋分隔＝%d／%d" % [maxr, fixed4, COLS])
	_check("H4 故事結束句整句、≤ COLS、整格（%d ≤ %d）" % [fixed4, COLS], fixed4 <= COLS and ok4)
	_cell("H4")
