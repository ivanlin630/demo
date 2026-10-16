extends SceneTree
# @bed-kind: acceptance
# slice: 玩家勢力目標改用引擎同一套詞（spec 2026-10-16-player-faction-goal-engine-vocabulary-HOW）
# ★格：
#   G1  攻擊 X（成員對 X、Y 都有 belief，Y 比 X 近）⇒ 設前 faction_duty 攻擊分量 0、攻擊不在 stakes；設後分量＝FACTION_DUTY_DRIVE、attack_target_id＝X（不是 Y）
#       ★咬 n1 的是 attack_target_id＝X 那格；faction_duty 變化咬不到 n1
#   G1b 成員不知道 X（清掉該成員對 X 的 belief：state.team_intel[成員].erase(X)）⇒ faction_attack_target＝-1、分量 0、directive.pinned.unknown_to_member ≥1
#   G1c 改對象叫醒成員：設攻擊 X → 成員想過一輪 → 改攻擊 Y ⇒ _update_goals 前 _directive_fresh＝false（地板）、後＝true，下一次 gather attack_target_id＝Y
#   G2  徵收 ⇒ 非最富成員的徵收 applicable、分量＝FACTION_DUTY_DRIVE
#   G3  外交 X ⇒ 外交 applicable、faction_diplo_target＝X、外交.to_task 目標位置＝成員對 X 的 belief 位置
#   G4  立國閘不過（統領低）⇒ ok:false「盟主統領 … 未達 …」、override 不變、30 天 is_established 仍 false
#   G4c 理由逐條表：NPC 版六列（隊長不存在／已立國／成員<2／統領／野心／準備度）＋全過；野心 0.59／0.60；玩家版不看野心、統領 0.39／0.40
#   G4e 走 action 路徑：玩家領導、盟主野心 0.3、其餘全過 ⇒ set_faction_goal 立國 ok:true
#   G4b 立國閘過 ⇒ 執行後 is_established、override 清空；之後 3 天 g2.faction_found 只 +1
#   G5  交接：設攻擊 X 後把盟主交給 NPC 隊 ⇒ 下一次重建 override＝""、target＝-1、goal_drivers 非空
#   G6  舊詞拒收："defend" ⇒ ok:false
#   G7  選單：攻擊／外交候選空 ⇒ 灰＋原因；立國閘不過 ⇒ 灰＋理由；面板對象失效印原因（真畫面 TextUI）

const EXPECTED: Array = ["G1", "G1b", "G1c", "G2", "G3", "G4", "G4c", "G4e", "G4b", "G5", "G6", "G7"]
const SEED: int = 20261016
const P: int = 0
const M: int = 1
const X: int = 2
const Y: int = 3
const Z: int = 4
var _errors: int = 0
var _present: Dictionary = {}
var _only: Dictionary = {}

func _on(fn: String) -> bool:
	return _only.is_empty() or _only.has(fn)

func _initialize() -> void:
	print("=== player_faction_goal：玩家勢力目標改用引擎詞 ===")
	var only: String = OS.get_environment("BED_ONLY")
	if only != "":
		for f in only.split(","):
			_only[String(f).strip_edges()] = true
		print("★★★BED_ONLY=%s：只跑子集，這一輪不能當驗收" % only)
	if _on("_g1"): _g1()
	if _on("_g1c"): _g1c()
	if _on("_g2"): _g2()
	if _on("_g3"): _g3()
	if _on("_g4"): _g4()
	if _on("_g4c"): _g4c()
	if _on("_g4e"): _g4e()
	if _on("_g4b"): _g4b()
	if _on("_g5"): _g5()
	if _on("_g6"): _g6()
	if _on("_g7"): await _g7()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty() and _only.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== player_faction_goal DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _cell(c: String) -> void:
	_present[c] = true

# ── 佈置：玩家盟主 P＋成員 M、Z；獨立 X（遠）、Y（近）──
static func _team(id: int, pos: Vector2i, pop: int, fid: int, leader: bool, vals: Dictionary, skills: Dictionary,
		coin: float, tags: Array = []) -> Dictionary:
	return {"id": id, "name": "T%d" % id, "tile_pos": [pos.x, pos.y], "population": pop, "tags": tags,
		"faction_id": fid, "is_faction_leader": leader, "anon_tiers": {"平民": pop - 1},
		"resources": {"food": 20000.0, "coin": coin, "material": 400.0},
		"leader": {"name": "L%d" % id, "skills": skills, "values": vals}}

func _mk(leader_vals: Dictionary = {"野心": 0.5}, leader_skills: Dictionary = {"統領": 0.8}) -> WorldState:
	seed(SEED)
	var cfg: Dictionary = {"seed": SEED, "mode": "explicit", "max_ticks": 100000, "map": {"radius": 16, "resource_richness": 5},
		"player": {"team_id": P},
		"teams": [
			_team(P, Vector2i(8, 8), 10, 1, true, leader_vals, leader_skills, 100.0, ["統領"]),
			_team(M, Vector2i(8, 8), 8, 1, false, {"慎重": 0.5}, {}, 10.0),
			_team(Z, Vector2i(8, 9), 8, 1, false, {"慎重": 0.5}, {}, 900.0),
			_team(X, Vector2i(12, 8), 5, -1, false, {"慎重": 0.5}, {}, 10.0),
			_team(Y, Vector2i(9, 8), 5, -1, false, {"慎重": 0.5}, {}, 10.0),
		]}
	var st: WorldState = MeasureBedHelper.arm_and_setup(cfg, false)
	for obs in [P, M, Z]:
		st.team_discovered[obs] = [X, Y]
		for tgt in [X, Y]:
			BeliefSystem.record_claim(st, obs, tgt, 99, "商旅", {"tile_pos": st.teams[tgt].tile_pos, "population_est": 5.0,
				"last_tick": st.world.current_tick}, 1.0, false)
	for tid in [P, M, Z]:
		st.snapshot_faction_member(tid, st.world.current_tick)
	(st.teams[P] as TeamData).readiness = 0.9
	return st

static func _f(st: WorldState):
	return st.factions[(st.teams[P] as TeamData).faction_id]

static func _set_goal(st: WorldState, word: String, tgt: int = -1) -> Dictionary:
	st.player_state["faction_goal_input"] = word
	st.player_state["faction_goal_target_input"] = tgt
	return PlayerCommandSystem.new().execute_action(st, -1, "set_faction_goal")

static func _duty(ctx: DecisionContext, opt: String) -> float:
	return DecisionTerms.eval("faction_duty", ctx, opt)

static func _util_dump(st: WorldState, team: TeamData, ctx: DecisionContext) -> String:
	var parts: Array = []
	for e in DecisionEngine.rank_scored_ctx(ctx, "", st, team, "bed"):
		var s: String = str(e)
		if s.contains("攻擊") or s.contains("外交") or s.contains("徵收"):
			parts.append(s)
	return "｜".join(PackedStringArray(parts))

# ── G1／G1b ──
func _g1() -> void:
	print("\n── G1 攻擊 X（Y 比較近）／G1b 成員不知道 X ──")
	var st: WorldState = _mk()
	var f = _f(st)
	var fai := FactionAISystem.shared()
	var m: TeamData = st.teams[M]
	_check("G1 前提 a：盟主隊 player_controlled、勢力是玩家領導", (st.teams[P] as TeamData).player_controlled and st.is_player_led(f))
	_check("G1 前提 c：成員有隊長 PersonData", st.persons.has(m.leader_id))
	var dx: int = FactionAISystem._hex_dist(m.tile_pos, BeliefSystem.belief_pos(st, M, X))
	var dy: int = FactionAISystem._hex_dist(m.tile_pos, BeliefSystem.belief_pos(st, M, Y))
	_check("G1 佈置：成員對 X、Y 都有 belief，Y（%d 格）比 X（%d 格）近" % [dy, dx], dy < dx and dy >= 0)
	fai._update_goals(st, f)
	var c0: DecisionContext = DecisionContext.gather(st, m)
	print("    設前 util：%s｜attack_target_id=%d" % [_util_dump(st, m, c0), c0.attack_target_id])
	_check("G1 前提 d（地板）：設前「攻擊」不在 faction_stakes、faction_duty 攻擊分量 0", not c0.faction_stakes.has("攻擊") and _duty(c0, "攻擊") == 0.0)
	var r: Dictionary = _set_goal(st, "攻擊", X)
	fai._update_goals(st, f)   # ★前提 b：action 只寫 override ⇒ 要呼 _update_goals 再 gather
	var c1: DecisionContext = DecisionContext.gather(st, m)
	print("    %s｜設後 util：%s｜attack_target_id=%d" % [str(r), _util_dump(st, m, c1), c1.attack_target_id])
	_check("G1 設「攻擊 X」⇒ faction_duty 攻擊分量＝%.1f、attack_target_id＝X（%d），不是更近的 Y" % [DecisionTerms.FACTION_DUTY_DRIVE, c1.attack_target_id],
		bool(r.get("ok", false)) and absf(_duty(c1, "攻擊") - DecisionTerms.FACTION_DUTY_DRIVE) < 0.0001 and c1.attack_target_id == X)
	_cell("G1")
	# G1b
	_check("G1b 地板：清之前成員對 X 有 belief 位置", BeliefSystem.belief_pos(st, M, X) != Vector2i(-1, -1))
	(st.team_intel[M] as Dictionary).erase(X)
	var u0: int = int(Probe.counts.get("directive.pinned.unknown_to_member", 0))
	var c2: DecisionContext = DecisionContext.gather(st, m)
	var u1: int = int(Probe.counts.get("directive.pinned.unknown_to_member", 0))
	print("    G1b 清掉後：faction_attack_target=%d 分量 %.1f unknown_to_member %d→%d" % [c2.faction_attack_target, _duty(c2, "攻擊"), u0, u1])
	_check("G1b 成員不知道 X ⇒ faction_attack_target＝-1（不 fallback 到 Y）、faction_duty 攻擊分量 0、Probe 計到",
		c2.faction_attack_target == -1 and _duty(c2, "攻擊") == 0.0 and u1 > u0)
	_cell("G1b")

# ── G1c ──
func _g1c() -> void:
	print("\n── G1c 改對象叫醒成員 ──")
	var st: WorldState = _mk()
	var f = _f(st)
	var fai := FactionAISystem.shared()
	var m: TeamData = st.teams[M]
	_set_goal(st, "攻擊", X)
	fai._update_goals(st, f)
	st.world.current_tick += 30
	m.last_decision_tick = st.world.current_tick   # 成員想過一輪（追上戳記）
	st.world.current_tick += 30
	_set_goal(st, "攻擊", Y)
	var fresh0: bool = fai._directive_fresh(st, m)
	fai._update_goals(st, f)
	var fresh1: bool = fai._directive_fresh(st, m)
	var c: DecisionContext = DecisionContext.gather(st, m)
	print("    改 Y：_update_goals 前 fresh=%s 後 fresh=%s｜attack_target_id=%d" % [str(fresh0), str(fresh1), c.attack_target_id])
	_check("G1c 地板：_update_goals 前 _directive_fresh＝false", not fresh0)
	_check("G1c 改對象 ⇒ _update_goals 後 _directive_fresh＝true、attack_target_id＝Y", fresh1 and c.attack_target_id == Y)
	_cell("G1c")

# ── G2 ──
func _g2() -> void:
	print("\n── G2 徵收 ──")
	var st: WorldState = _mk()
	var f = _f(st)
	var m: TeamData = st.teams[M]
	var r: Dictionary = _set_goal(st, "徵收")
	# ★佈置：勢力名冊最富＝Z（_richest_member 讀 known_member_states[成員]["food_est"]；平手取第一個＝M 自己 ⇒ 對自己不徵收）。
	#   ★觀察（交件信報 systems）：known_member_states 有兩個寫者、鍵名不同——snapshot_faction_member 寫 "food"、
	#     loop1 的 belief 覆寫（faction_ai_system 每輪 _update_goals 前）寫 "food_est"；_richest_member 拿不拿得到看最後誰寫。
	#     床直接寫成 belief 覆寫後的樣子，只決定「誰最富」，不測那兩個寫者
	(f.known_member_states.get(M, {}) as Dictionary)["food_est"] = 10.0
	(f.known_member_states.get(Z, {}) as Dictionary)["food_est"] = 900.0
	FactionAISystem.shared()._update_goals(st, f)
	var c: DecisionContext = DecisionContext.gather(st, m)
	print("    goals %s｜stakes %s｜勢力名冊最富 Team%d" % [str(f.goals), str(c.faction_stakes), FactionAISystem.shared()._richest_member(st, f)])
	print("    %s｜faction_tribute_target=%d｜util %s" % [str(r), c.faction_tribute_target, _util_dump(st, m, c)])
	_check("G2 設「徵收」⇒ 非最富成員的徵收 applicable、faction_duty 分量＝FACTION_DUTY_DRIVE",
		bool(r.get("ok", false)) and DecisionOptions.applicable(c).has("徵收") and absf(_duty(c, "徵收") - DecisionTerms.FACTION_DUTY_DRIVE) < 0.0001)
	_cell("G2")

# ── G3 ──
func _g3() -> void:
	print("\n── G3 外交 X ──")
	var st: WorldState = _mk()
	var f = _f(st)
	var m: TeamData = st.teams[M]
	var r: Dictionary = _set_goal(st, "外交", X)
	FactionAISystem.shared()._update_goals(st, f)
	var c: DecisionContext = DecisionContext.gather(st, m)
	var td: Dictionary = DecisionOptions.to_task(st, m, "外交")
	var bx: Vector2i = BeliefSystem.belief_pos(st, M, X)
	print("    %s｜faction_diplo_target=%d｜to_task %s｜成員對 X 的 belief 位置 %s｜util %s" % [str(r), c.faction_diplo_target, str(td), str(bx), _util_dump(st, m, c)])
	_check("G3 設「外交 X」⇒ 外交 applicable、faction_diplo_target＝X", DecisionOptions.applicable(c).has("外交") and c.faction_diplo_target == X)
	_check("G3 外交.to_task 目標位置＝成員對 X 的 belief 位置（門與執行同一個對象）", td.get("target", Vector2i(-2, -2)) == bx)
	_cell("G3")

# ── G4 ──
func _g4() -> void:
	print("\n── G4 立國閘不過 ──")
	var st: WorldState = _mk({"野心": 0.9}, {"統領": 0.2})
	var f = _f(st)
	var r: Dictionary = _set_goal(st, "立國")
	print("    %s｜override「%s」" % [str(r), f.player_goal_override])
	var runner := SimRunner.new()
	var end_t: int = st.world.current_tick + 30 * WorldState.TICKS_PER_DAY
	while st.world.current_tick < end_t:
		runner.advance_tick(st, Vector2i(-1, -1))
	_check("G4 統領低 ⇒ ok:false「盟主統領 … 未達 …」、override 不變、30 天 is_established 仍 false",
		not bool(r.get("ok", true)) and String(r.get("msg", "")).contains("盟主統領") and String(r.get("msg", "")).contains("未達")
		and f.player_goal_override == "" and not f.is_established)
	_cell("G4")

# ── G4c 理由逐條表 ──
func _g4c() -> void:
	print("\n── G4c 理由逐條表 ──")
	# NPC 版：每列只有一條不過
	var rows: Array = [
		["隊長不存在", "盟主隊長不存在"], ["已立國", "已經立國了"], ["成員<2", "勢力至少要 2 隊"],
		["統領", "盟主統領"], ["野心0.59", "盟主野心"], ["準備度", "盟主隊準備度"], ["全過", ""], ["野心0.60", ""]]
	var all_ok: bool = true
	for row in rows:
		var st: WorldState = _mk({"野心": 0.6}, {"統領": 0.8})
		var f = _f(st)
		var lt: TeamData = st.teams[P]
		var lp: PersonData = st.persons[lt.leader_id]
		match String(row[0]):
			"隊長不存在": st.persons.erase(lt.leader_id)
			"已立國": f.is_established = true
			"成員<2":
				st.set_team_faction(st.teams[M], -1, WorldState.LEAVE_PLAYER)
				st.set_team_faction(st.teams[Z], -1, WorldState.LEAVE_PLAYER)
			"統領": lp.skills["統領"] = 0.1
			"野心0.59": lp.values["野心"] = 0.59
			"準備度": lt.readiness = 0.5
			"野心0.60": lp.values["野心"] = 0.60
		var why: String = FactionAISystem.establish_block_reason(st, f, false)
		var ok: bool = (why == "") if String(row[1]) == "" else why.contains(String(row[1]))
		print("    NPC %s ⇒「%s」%s" % [row[0], why, "" if ok else "  ← 不符"])
		all_ok = all_ok and ok
	# 玩家版：不看野心、統領門檻不打折
	var pv: Array = [["野心0.3全過", 0.3, 0.8, true], ["統領0.39", 0.9, 0.39, false], ["統領0.40", 0.9, 0.40, true]]
	for row in pv:
		var st2: WorldState = _mk({"野心": float(row[1])}, {"統領": float(row[2])})
		var why2: String = FactionAISystem.establish_block_reason(st2, _f(st2), true)
		var ok2: bool = (why2 == "") == bool(row[3]) and not why2.contains("野心")
		print("    玩家 %s ⇒「%s」%s" % [row[0], why2, "" if ok2 else "  ← 不符"])
		all_ok = all_ok and ok2
	_check("G4c 理由逐條表：NPC 六列各回該條、全過＝空、野心 0.59 不過 0.60 過；玩家版不看野心、統領 0.39 不過 0.40 過、回句不含野心", all_ok)
	_cell("G4c")

# ── G4e ──
func _g4e() -> void:
	print("\n── G4e 立國走 action 路徑 ──")
	var st: WorldState = _mk({"野心": 0.3}, {"統領": 0.8})
	var r: Dictionary = _set_goal(st, "立國")
	print("    %s" % str(r))
	_check("G4e 玩家領導、野心 0.3、其餘全過 ⇒ set_faction_goal 立國 ok:true", bool(r.get("ok", false)) and _f(st).player_goal_override == "立國")
	_cell("G4e")

# ── G4b ──
func _g4b() -> void:
	print("\n── G4b 立國閘過 ⇒ 一次性 ──")
	var st: WorldState = _mk({"野心": 0.3}, {"統領": 0.8})
	var f = _f(st)
	_set_goal(st, "立國")
	var n0: int = int(Probe.counts.get("g2.faction_found", 0))
	var runner := SimRunner.new()
	var end_t: int = st.world.current_tick + 3 * WorldState.TICKS_PER_DAY
	while st.world.current_tick < end_t:
		runner.advance_tick(st, Vector2i(-1, -1))
	var n1: int = int(Probe.counts.get("g2.faction_found", 0))
	print("    is_established=%s｜override「%s」｜g2.faction_found %d→%d" % [str(f.is_established), f.player_goal_override, n0, n1])
	_check("G4b 立國閘過 ⇒ is_established、override 清空、3 天 g2.faction_found 只 +1", f.is_established and f.player_goal_override == "" and n1 - n0 == 1)
	_cell("G4b")

# ── G5 交接 ──
func _g5() -> void:
	print("\n── G5 交接清掉玩家的令 ──")
	var st: WorldState = _mk()
	var f = _f(st)
	_set_goal(st, "攻擊", X)
	FactionAISystem.shared()._update_goals(st, f)
	# 盟主交給 NPC 隊 M（野心高、建材枯 ⇒ NPC 重建會發「徵收／戰爭基金」那一筆 driver）
	var m: TeamData = st.teams[M]
	var ml: PersonData = st.persons[m.leader_id]
	ml.values["野心"] = 0.9
	ResourceBank.set_amt(m, "material", 0.0, "bed")
	f.leader_team_id = M
	var c0: int = int(Probe.counts.get("faction.override_cleared_on_handover", 0))
	FactionAISystem.shared()._update_goals(st, f)
	print("    交接後 override「%s」target %d｜goals %s drivers %s｜cleared_on_handover %d→%d" % [f.player_goal_override, f.player_goal_target,
		str(f.goals), str(f.goal_drivers.keys()), c0, int(Probe.counts.get("faction.override_cleared_on_handover", 0))])
	_check("G5 交接 ⇒ override＝\"\"、target＝-1、goal_drivers 非空（NPC 重建）",
		not st.is_player_led(f) and f.player_goal_override == "" and f.player_goal_target == -1 and not f.goal_drivers.is_empty())
	_cell("G5")

# ── G6 ──
func _g6() -> void:
	print("\n── G6 舊詞拒收 ──")
	var st: WorldState = _mk()
	var r: Dictionary = _set_goal(st, "defend")
	print("    %s" % str(r))
	_check("G6 「defend」⇒ ok:false", not bool(r.get("ok", true)) and _f(st).player_goal_override == "")
	_cell("G6")

# ── G7 選單與面板（真畫面）──
func _g7() -> void:
	print("\n── G7 選單灰＋理由、面板對象失效 ──")
	var l_atk: String = TextUiMain.goal_menu_label("攻擊", [], "")
	var l_dip: String = TextUiMain.goal_menu_label("外交", [], "")
	var l_est: String = TextUiMain.goal_menu_label("立國", [X], "盟主統領 0.20 未達 0.40")
	var l_ok: String = TextUiMain.goal_menu_label("攻擊", [X], "")
	print("    %s｜%s｜%s｜%s" % [l_atk, l_dip, l_est, l_ok])
	var menu_ok: bool = l_atk == "攻擊（不可：你知道位置的獨立隊伍：0）" and l_dip.begins_with("外交（不可：") and l_est == "立國（不可：盟主統領 0.20 未達 0.40）" and l_ok == "攻擊"
	seed(1337)
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var st: WorldState = node._bridge.get_state()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	if pt.faction_id != -1:
		st.set_team_faction(pt, -1, WorldState.LEAVE_PLAYER)
	var fid: int = st.create_faction(ptid)
	var f = st.factions[fid]
	var gone: int = -1
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if tid != ptid and t.faction_id == -1 and t.parent_team_id == -1 and t.beast_kind == "":
			gone = tid
			break
	f.player_goal_override = "攻擊"
	f.player_goal_target = gone
	st.teams.erase(gone)
	node._faction_mode = true
	var s: String = node._build_faction_str()
	print(s.split("\n")[1] if s.split("\n").size() > 1 else s)
	node.queue_free()
	await process_frame
	_check("G7 選單：攻擊／外交候選空 ⇒ 灰＋原因；立國閘不過 ⇒ 灰＋理由；面板「目標：攻擊 Team%d（你設的）（對象已失效：對方已不存在）」" % gone,
		menu_ok and s.contains("目標：攻擊 Team%d（你設的）（對象已失效：對方已不存在）" % gone))
	_cell("G7")
