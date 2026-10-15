extends SceneTree
# @bed-kind: acceptance
# slice: 顧問讀信念不擲骰（spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot §一）
# ★格：
#   A1  三帶：己方武裝 own，敵估 own/2、own、own×2 ⇒ good／even／bad；fact 句人數＝belief（技能 1.0 ⇒ 零雜訊），不是真值
#   A2a 不擲骰：直呼 dispatch 的 handler，前後 randi() 對照 ⇒ handler 自身零抽取；同 tick 兩次同句
#   A2b emit 標 pending_rethink：玩家隊在勢力內／外兩種佈置，對照世界推進同一 tick 的 RNG 位移（只印，systems 裁接受）
#   A3  不知道：目標無 belief ⇒ 不知道句、ok:true、事件依據「無」；strategic 零敵對、intel_read 零傳聞同樣
#   A4  技能：同 belief，技能 0.9／0.1 各問 30 個 tick ⇒ 平均絕對誤差前者小（印兩數）
#   A5  偏頗：好戰 0.9／慎重 0.1 對 好戰 0.1／慎重 0.9 ⇒ 前者敵估較小、判斷帶不劣於後者（印數字）
#   A6  事件：一則 advice 進玩家事件流、帶依據（來源詞、幾天前）；command_results 同句；UI 檔不再有「[Advisor]」
#   A7  選單：五情境都在；目標選單只列 belief 裡未過期的隊（真在旁邊但沒 belief 的不在列）
#   A8  不讀真值：問之後目標真人口 ×3，同 tick 再問 ⇒ 句子不變
#   A9  雜訊命名空間：noise_u 與 path_system 同一 (tick, 數字 id, 數字 id) 不同；不帶 NS 直呼證明撞點存在
#   A10 diplomatic 不讀隊長：目標隊長換成與附身隊成員有 feud 的人（belief 不變）⇒ 同 tick 再問句子不變

const EXPECTED: Array = ["A1", "A2a", "A2b", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10"]
var _errors: int = 0
var _present: Dictionary = {}

func _initialize() -> void:
	print("=== advisor_belief：顧問讀信念、不擲骰 ===")
	_a1()
	_a2a()
	_a2b()
	_a3()
	_a4()
	_a5()
	_a6()
	_a7()
	_a8_a10()
	_a9()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== advisor_belief DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _world() -> WorldState:
	seed(20261015)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	Probe.enabled = false
	return st

func _pt(st: WorldState) -> TeamData:
	return st.teams[st.get_player_team_id()]

func _npcs(st: WorldState) -> Array:
	var ptid: int = st.get_player_team_id()
	var out: Array = []
	for tid in st.teams:
		if int(tid) != ptid and st.is_live_team(int(tid)) and st.teams[tid].beast_kind == "":
			out.append(int(tid))
	out.sort()
	return out

# 顧問：附身者本人（附身隊活著的成員），技能／人格由格設
func _advisor(st: WorldState, skill: float, hawk: float = 0.5, caution: float = 0.5) -> PersonData:
	var a: PersonData = st.persons[st.player_id]
	for k in AdvisorSystem.SITUATION_SKILL_MAP.values():
		a.skills[String(k)] = skill
	a.values["好戰"] = hawk
	a.values["慎重"] = caution
	return a

func _claim(st: WorldState, tgt: int, pop: float, armed: float, src: int = -2) -> void:
	var ptid: int = st.get_player_team_id()
	(st.team_intel.get(ptid, {}) as Dictionary).erase(tgt)
	var s: int = ptid if src == -2 else src
	BeliefSystem.record_claim(st, ptid, tgt, s, "親見" if s == ptid else "商旅",
		{"tile_pos": st.teams[tgt].tile_pos, "population_est": pop, "armed_est": armed, "last_tick": st.world.current_tick},
		1.0, false)

# ★population 是計算屬性（賦值會被吞）⇒ 真人口只能從 anon 帳加；回傳加完後的真人口供斷言佈置真的生效
static func _grow_true_pop(t: TeamData, n: int) -> int:
	if n > t.population:
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", n - t.population)
	return t.population

func _ask(st: WorldState, pid: int, sit: String, tgt: int) -> Dictionary:
	return PlayerCommandApi.new().dispatch(st, "ask_advisor", {"advisor_pid": pid, "situation": sit, "target_id": tgt})

static func _text(r: Dictionary) -> String:
	return String(r.get("payload", {}).get("advice", {}).get("text", ""))

static func _band(r: Dictionary) -> String:
	return String(r.get("payload", {}).get("advice", {}).get("band", ""))


# ── A1 ───────────────────────────────────────────────────────────────────────
func _a1() -> void:
	print("\n── A1 三帶、人數來自 belief ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var a: PersonData = _advisor(st, 1.0)
	var tgt: int = _npcs(st)[0]
	_check("A1 佈置：目標真人口＝40", _grow_true_pop(st.teams[tgt], 40) == 40)
	var own: int = EncounterSystem.armed_on_field(st, pt)
	print("   己方上場武裝 %d（EncounterSystem.armed_on_field）｜目標 Team%d 真人口 40" % [own, tgt])
	var got: Array = []
	for e in [float(own) / 2.0, float(own), float(own) * 2.0]:
		_claim(st, tgt, e * 2.0, e)
		var r: Dictionary = _ask(st, a.id, "assess_enemy", tgt)
		got.append(_band(r))
		print("   敵估武裝 %.1f（人口 %.1f）⇒ %s｜%s" % [e, e * 2.0, _band(r), _text(r)])
		if is_equal_approx(e, float(own)):
			_check("A1 fact 句人數＝belief %d（不是真值 40）" % roundi(e * 2.0), _text(r).contains("約 %d 人" % roundi(e * 2.0)) and not _text(r).contains("約 40 人"))
	_check("A1 三帶依序 good／even／bad（實得 %s）" % str(got), got == ["good", "even", "bad"])
	_present["A1"] = true


# ── A2a ──────────────────────────────────────────────────────────────────────
func _a2a() -> void:
	print("\n── A2a handler 零抽取、同 tick 同句 ──")
	var st: WorldState = _world()
	var a: PersonData = _advisor(st, 0.3)
	var tgt: int = _npcs(st)[0]
	_claim(st, tgt, 10.0, 5.0)
	seed(777)
	var r0: int = randi()
	seed(777)
	var r1: Dictionary = _ask(st, a.id, "assess_enemy", tgt)
	var x1: int = randi()
	var r2: Dictionary = _ask(st, a.id, "assess_enemy", tgt)
	print("   randi 對照 %d／%d｜第一次「%s」｜第二次「%s」" % [r0, x1, _text(r1), _text(r2)])
	_check("A2a handler 自身零抽取（呼前 seed 後第一個 randi 相同）", r0 == x1)
	_check("A2a 同 tick 兩次同句", _text(r1) != "" and _text(r1) == _text(r2))
	_present["A2a"] = true


# ── A2b ──────────────────────────────────────────────────────────────────────
func _a2b() -> void:
	print("\n── A2b emit 的 pending_rethink：RNG 位移（只印） ──")
	for in_faction in [true, false]:
		var rs: Array = []
		for ask in [false, true]:
			var st: WorldState = _world()
			var pt: TeamData = _pt(st)
			if not in_faction:
				pt.faction_id = -1
			var a: PersonData = _advisor(st, 0.5)
			if ask:
				_ask(st, a.id, "resources", -1)
			seed(4242)
			SimRunner.new().advance_tick(st, pt.tile_pos)
			rs.append(randi())
		print("   玩家隊%s勢力：不問 %d｜問 %d ⇒ %s" % ["在" if in_faction else "不在", rs[0], rs[1], "相同" if rs[0] == rs[1] else "不同（那一 tick 多想一輪）"])
	_present["A2b"] = true


# ── A3 ───────────────────────────────────────────────────────────────────────
func _a3() -> void:
	print("\n── A3 不知道 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var a: PersonData = _advisor(st, 0.5)
	var tgt: int = _npcs(st)[0]
	(st.team_intel.get(ptid, {}) as Dictionary).erase(tgt)
	var unk: String = TextBank.fmt("advisor_unknown", "default")
	var r: Dictionary = _ask(st, a.id, "assess_enemy", tgt)
	var ev: Dictionary = st.player_events.back() if not st.player_events.is_empty() else {}
	print("   無 belief：ok=%s「%s」｜事件依據 %s" % [str(r.get("ok")), _text(r), str(ev.get("info", {}).get("basis", {}))])
	_check("A3 無 belief ⇒ ok:true、不知道句", bool(r.get("ok", false)) and _text(r).begins_with(unk))
	_check("A3 事件依據「無」", String(ev.get("info", {}).get("basis", {}).get("source_word", "")) == "無")
	var r_t: Dictionary = _ask(st, a.id, "diplomatic", -1)
	_check("A3 要目標而 target_id=-1 ⇒ ok:true、不知道句", bool(r_t.get("ok", false)) and _text(r_t).begins_with(unk))
	st.player_hostile_teams.clear()
	var r_s: Dictionary = _ask(st, a.id, "strategic", -1)
	print("   零敵對 strategic：「%s」" % _text(r_s))
	_check("A3 strategic 零敵對 ⇒ 不知道", bool(r_s.get("ok", false)) and _text(r_s).begins_with(unk))
	st.team_intel[ptid] = {}
	var r_i: Dictionary = _ask(st, a.id, "intel_read", -1)
	print("   零傳聞 intel_read：「%s」" % _text(r_i))
	_check("A3 intel_read 零傳聞 ⇒ 不知道", bool(r_i.get("ok", false)) and _text(r_i).begins_with(unk))
	_present["A3"] = true


# ── A4 ───────────────────────────────────────────────────────────────────────
func _a4() -> void:
	print("\n── A4 技能高誤差小 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var tgt: int = _npcs(st)[0]
	var mae: Array = []
	for sk in [0.9, 0.1]:
		var a: PersonData = _advisor(st, sk)
		var t0: int = st.world.current_tick
		var tot: float = 0.0
		for i in range(30):
			st.world.current_tick = t0 + i
			_claim(st, tgt, 20.0, 10.0)
			var x: Dictionary = AdvisorSystem._assess(st, a, pt, tgt, "assess_enemy")
			tot += absf(float(x.get("pop", 0.0)) - 20.0)
		st.world.current_tick = t0
		mae.append(tot / 30.0)
	print("   平均絕對誤差：技能 0.9 ⇒ %.3f｜技能 0.1 ⇒ %.3f" % [mae[0], mae[1]])
	_check("A4 技能 0.9 的誤差 < 技能 0.1", float(mae[0]) < float(mae[1]))
	_present["A4"] = true


# ── A5 ───────────────────────────────────────────────────────────────────────
func _a5() -> void:
	print("\n── A5 好戰者看敵人小 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var tgt: int = _npcs(st)[0]
	var own: int = EncounterSystem.armed_on_field(st, pt)
	_claim(st, tgt, float(own) * 2.0, float(own))
	var hawk: Dictionary = AdvisorSystem._assess(st, _advisor(st, 1.0, 0.9, 0.1), pt, tgt, "assess_enemy")
	var dove: Dictionary = AdvisorSystem._assess(st, _advisor(st, 1.0, 0.1, 0.9), pt, tgt, "assess_enemy")
	print("   好戰：敵估武裝 %.2f、帶 %s｜慎重：敵估武裝 %.2f、帶 %s" % [float(hawk["armed"]), hawk["band"], float(dove["armed"]), dove["band"]])
	var rank: Dictionary = {"bad": 0, "even": 1, "good": 2}
	_check("A5 好戰者敵估 < 慎重者", float(hawk["armed"]) < float(dove["armed"]))
	_check("A5 好戰者判斷帶不劣於慎重者", int(rank[hawk["band"]]) >= int(rank[dove["band"]]))
	_present["A5"] = true


# ── A6 ───────────────────────────────────────────────────────────────────────
func _a6() -> void:
	print("\n── A6 事件＋結果句（走真的指令佇列） ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var a: PersonData = _advisor(st, 1.0)
	var tgt: int = _npcs(st)[0]
	_claim(st, tgt, 12.0, 6.0, _npcs(st)[1])
	st.world.current_tick += WorldState.TICKS_PER_DAY * 2
	var seq0: int = st.player_event_seq
	st.pending_commands.append({"name": "ask_advisor", "args": {"advisor_pid": a.id, "situation": "assess_enemy", "target_id": tgt}, "seq": 9001})
	SimRunner.new().advance_tick(st, pt.tile_pos)
	var advs: Array = st.player_events.filter(func(e): return String(e.get("kind", "")) == "advice" and int(e.get("seq", 0)) > seq0)
	var crs: Array = st.command_results.filter(func(c): return int(c.get("seq", 0)) == 9001)
	var ev: Dictionary = advs[0] if not advs.is_empty() else {}
	var text: String = String(ev.get("info", {}).get("text", ""))
	var basis: Dictionary = ev.get("info", {}).get("basis", {})
	print("   事件 %d 則｜「%s」｜依據 %s\n   結果句 %s" % [advs.size(), text, str(basis), str(crs[0].get("text", "")) if not crs.is_empty() else "（無）"])
	_check("A6 advice 事件恰好一則", advs.size() == 1)
	_check("A6 依據：聽說、來源隊、tick", String(basis.get("source_word", "")) == "聽說" and int(basis.get("source_id", -1)) == _npcs(st)[1])
	_check("A6 句子帶「2 天前」", text.contains("2 天前"))
	_check("A6 command_results 同句", not crs.is_empty() and String(crs[0].get("text", "")).contains(text) and text != "")
	_check("A6 事件 describe＝同一句", WorldEvents.describe(st, "advice", [pt.team_id], ev.get("info", {})) == text)
	var ui: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	_check("A6 UI 檔不再有「[Advisor]」", not ui.contains("[Advisor]"))
	_present["A6"] = true


# ── A7 ───────────────────────────────────────────────────────────────────────
func _a7() -> void:
	print("\n── A7 選單 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = _pt(st)
	var ns: Array = _npcs(st)
	st.team_intel[ptid] = {}
	_claim(st, ns[0], 10.0, 5.0)
	_claim(st, ns[1], 10.0, 5.0)
	# 過期的一筆
	# ★來源不能是自己：親見（source==obs）會把 value.last_tick 改寫成當 tick（belief_system 裁A）⇒ 用轉述
	BeliefSystem.record_claim(st, ptid, ns[2], ns[0], "商旅", {"tile_pos": st.teams[ns[2]].tile_pos, "population_est": 9.0,
		"last_tick": st.world.current_tick - BeliefSystem.BELIEF_STALE_TICKS - 10}, 1.0, false)
	# 真在旁邊、沒 belief
	st.teams[ns[3]].tile_pos = pt.tile_pos
	var menu: Array = AdvisorSystem.target_menu(st, ptid)
	print("   情境 %s｜目標選單 %s（有 belief：%d、%d｜過期：%d｜在旁邊沒 belief：%d）" % [str(AdvisorSystem.menu_situations()), str(menu), ns[0], ns[1], ns[2], ns[3]])
	_check("A7 五情境都在選單", AdvisorSystem.menu_situations().size() == 5)
	_check("A7 目標選單＝有 belief 未過期的兩隊", menu.has(ns[0]) and menu.has(ns[1]) and menu.size() == 2)
	_check("A7 過期的不在列", not menu.has(ns[2]))
	_check("A7 真在旁邊但沒 belief 的不在列", not menu.has(ns[3]))
	_present["A7"] = true


# ── A8／A10 ──────────────────────────────────────────────────────────────────
func _a8_a10() -> void:
	print("\n── A8 不讀真人口／A10 diplomatic 不讀隊長 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var a: PersonData = _advisor(st, 0.4)
	var tgt: int = _npcs(st)[0]
	_claim(st, tgt, 14.0, 7.0)
	var s1: String = _text(_ask(st, a.id, "assess_enemy", tgt))
	var p0: int = st.teams[tgt].population
	_check("A8 佈置：真人口真的 ×3", _grow_true_pop(st.teams[tgt], p0 * 3) == p0 * 3 and p0 > 0)
	var s2: String = _text(_ask(st, a.id, "assess_enemy", tgt))
	print("   改真人口前「%s」\n   改後「%s」" % [s1, s2])
	_check("A8 真人口 ×3 後同 tick 再問句子不變", s1 != "" and s1 == s2)
	_present["A8"] = true
	pt.known_reputations[tgt] = 0.55
	var d1: String = _text(_ask(st, a.id, "diplomatic", tgt))
	# 目標隊長換成一個與附身隊成員有 feud 的人
	var tt: TeamData = st.teams[tgt]
	var newl: int = -1
	for pid in tt.named_members:
		newl = int(pid)
		break
	if newl == -1:
		newl = tt.leader_id
	var member: PersonData = st.persons[st.player_id]
	RelationGraph.add_edge(member.relation_edges, "feud", newl, 0.95, st.world.current_tick)
	tt.leader_id = newl
	var d2: String = _text(_ask(st, a.id, "diplomatic", tgt))
	print("   換隊長前「%s」\n   換成有 feud 的 P%d 後「%s」" % [d1, newl, d2])
	_check("A10 母體地板：附身者對新隊長有 feud 邊", DiplomaticAiSystem._edge_intensity_to(member.relation_edges, "feud", newl) > 0.0)
	_check("A10 同 tick 再問 diplomatic 句子不變", d1 != "" and d1 == d2)
	_present["A10"] = true


# ── A9 ───────────────────────────────────────────────────────────────────────
func _a9() -> void:
	print("\n── A9 雜訊命名空間 ──")
	var t: int = 1234
	var k: int = 5
	var sit: String = "resources"
	var salt: int = -(AdvisorSystem.TEXT_SITUATIONS.find(sit) + 1)
	var with_ns: float = AdvisorSystem.noise_u(t, k, -1, sit)
	var path_like: float = PathSystem.observation_noise01(t, k, salt)
	var no_ns: float = PathSystem.observation_noise01(t, k, salt)
	print("   noise_u=%.6f｜path_system 同 (tick, %d, %d)=%.6f｜不帶 NS 直呼=%.6f" % [with_ns, k, salt, path_like, no_ns])
	_check("A9 noise_u 與 path_system 同一 (tick, 數字 id, 數字 id) 不同", with_ns != path_like)
	_check("A9 不帶 NS 直呼 ⇒ 與 path_system 撞點（相同）", no_ns == path_like)
	_present["A9"] = true
