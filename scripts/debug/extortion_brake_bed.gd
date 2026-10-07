extends SceneTree
# @bed-kind: invariant
# ══ XB P2：勒索的怨要累積（spec 2026-10-07 battle-screen-asserted-and-extortion-brake §XB §2，藍圖 324b9041f）══════
# 格：P2a 同一施加者（玩家）連勒索 10 次 ⇒ 第 1 次接受、接受分數逐次下降、第 k 次轉拒（印 k 分佈：3 個對象／不同人格，不釘數字）
#     P2b【反向】10 個不同施加者各勒索同一對象 1 次 ⇒ 沒有任何一條怨邊由【累積】形成
#     P2c【反向】同一施加者兩次相隔 > 一季 ⇒ 不累加（不成怨）；★正對照：同一季兩次 ⇒ 累積成怨
# ★分數讀 DiplomaticAiSystem.tribute_eval（與判決同一份算式；讀的時候關 Probe，不讓量測多記一筆）

const CFG: String = "res://config/default.json"
const SEED: int = 1337
const N: int = 10

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P2a", "P2b", "P2c"]


func _initialize() -> void:
	print("=== extortion_brake：怨要累積 ===")
	_p2a_same_aggressor()
	_p2b_many_aggressors_once()
	_p2c_season_window()
	var missing: Array = EXPECTED_CELLS.filter(func(c): return not _cells_ran.has(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== extortion_brake DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _setup() -> WorldState:
	seed(SEED)
	return MeasureBedHelper.arm_and_setup(CFG, false)


func _npcs(st: WorldState, exclude_faction_of: Array) -> Array:
	var ids: Array = st.teams.keys()
	ids.sort()
	var out: Array = []
	for id in ids:
		var t: TeamData = st.teams[id]
		if t.leader_id == -1 or t.population <= 0 or exclude_faction_of.has(int(id)):
			continue
		var clash: bool = false
		for e in exclude_faction_of:
			if st.teams.has(e) and TeamData.same_faction(t, st.teams[e]):
				clash = true
		if not clash:
			out.append(t)
	return out


func _eval(st: WorldState, vic: TeamData, agg: TeamData) -> Dictionary:
	var was: bool = Probe.enabled
	Probe.enabled = false
	var ev: Dictionary = DiplomaticAiSystem.tribute_eval(st, vic, agg, agg.readiness)
	Probe.enabled = was
	return ev


static func _factor(p: PersonData) -> float:
	return NpcAiSystem.FEUD_BASE_FACTOR + float(p.values.get("義氣", 0.5)) * NpcAiSystem.FEUD_HONOR_W \
		+ float(p.values.get("好戰", 0.5)) * NpcAiSystem.FEUD_BELLIGERENCE_W


static func _feud(st: WorldState, vic: TeamData, agg: TeamData) -> float:
	var l: PersonData = st.persons.get(vic.leader_id)
	return DiplomaticAiSystem._edge_intensity_to(l.relation_edges, "feud", agg.leader_id) if l != null else 0.0


# ══ P2a ═══════════════════════════════════════════════════════════════════════════════════════════
func _p2a_same_aggressor() -> void:
	print("\n── P2a 同一施加者（玩家）連勒索 %d 次 ──" % N)
	var st: WorldState = _setup()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var isys := InteractionSystem.new()
	var ks: Array = []
	var bad: Array = []
	for v in _npcs(st, [ptid]).slice(0, 3):
		var vic: TeamData = v
		vic.tile_pos = pt.tile_pos
		var l: PersonData = st.persons.get(vic.leader_id)
		var k: int = -1
		var prev_acc_score: float = INF
		var first_accept: bool = false
		var seq: Array = []
		for i in range(1, N + 1):
			var ev: Dictionary = _eval(st, vic, pt)
			var res: Dictionary = isys.resolve_extortion_direct(st, ptid, vic.team_id)
			var acc: bool = bool(res.get("accepted", false))
			seq.append("%s%+.3f" % ["接" if acc else "拒", float(ev.get("score", 0.0))])
			if i == 1:
				first_accept = acc
			if acc:
				if float(ev["score"]) >= prev_acc_score:
					bad.append("Team%d 第 %d 次接受分數沒降（%.3f ≥ %.3f）" % [vic.team_id, i, float(ev["score"]), prev_acc_score])
				prev_acc_score = float(ev["score"])
			elif k == -1:
				k = i
		print("   Team%d（義氣 %.2f 好戰 %.2f 慎重 %.2f｜怨 factor %.2f）k＝%s｜feud %.3f｜%s" % [vic.team_id,
			float(l.values.get("義氣", 0.5)), float(l.values.get("好戰", 0.5)), float(l.values.get("慎重", 0.5)),
			_factor(l), str(k) if k != -1 else "（10 次內沒轉拒）", _feud(st, vic, pt), " ".join(PackedStringArray(seq))])
		if not first_accept:
			bad.append("Team%d 第 1 次就拒絕（基礎分不在門檻上方 ⇒ 這一隊量不到煞車）" % vic.team_id)
		ks.append(k)
	print("   ★k 分佈 ＝ %s" % str(ks))
	_check("★母體地板：量了 3 個對象（%d）" % ks.size(), ks.size() == 3)
	_check("P2a 每個對象：第 1 次接受、接受分數逐次下降（錯：%s）" % str(bad), bad.is_empty())
	_check("P2a 每個對象都在 10 次內轉拒（k ＝ %s）" % str(ks), not ks.has(-1))
	_cells_ran.append("P2a")


# ══ P2b【反向】10 個不同施加者各 1 次 ══════════════════════════════════════════════════════════════
func _p2b_many_aggressors_once() -> void:
	print("\n── P2b【反向】%d 個不同施加者各勒索同一對象 1 次 ⇒ 沒有累積成的怨 ──" % N)
	var st: WorldState = _setup()
	var ptid: int = st.get_player_team_id()
	var pool: Array = _npcs(st, [ptid])
	if pool.size() < N + 1:
		_check("★不可判：NPC 隊不足 %d（%d）" % [N + 1, pool.size()], false)
		_cells_ran.append("P2b")
		return
	var vic: TeamData = pool[0]
	var isys := InteractionSystem.new()
	var acc0: int = int(Probe.counts.get("grudge.form.feud.tributed_accumulated", 0))
	var used: int = 0
	for agg in pool.slice(1):
		var a: TeamData = agg
		if TeamData.same_faction(a, vic):
			continue
		a.tile_pos = vic.tile_pos
		isys.resolve_extortion_direct(st, a.team_id, vic.team_id)   # 非玩家施加者 ⇒ 不經秤、直接解算（照樣記一筆）
		used += 1
		if used >= N:
			break
	var acc1: int = int(Probe.counts.get("grudge.form.feud.tributed_accumulated", 0))
	var l: PersonData = st.persons.get(vic.leader_id)
	var n_feud: int = RelationGraph.edges_of_type(l.relation_edges, "feud").size()
	print("   對象 Team%d（怨 factor %.2f）：施加者 %d 個｜累積成怨 %d 次｜feud 邊 %d 條（單筆過門檻才會有）" % [
		vic.team_id, _factor(l), used, acc1 - acc0, n_feud])
	_check("★母體地板：真的有 %d 個不同施加者（%d）" % [N, used], used == N)
	_check("P2b【反向】不同施加者各 1 次 ⇒ 累積成怨 0 次（%d）" % (acc1 - acc0), acc1 - acc0 == 0)
	_cells_ran.append("P2b")


# ══ P2c【反向】相隔 > 一季不累加；正對照：同一季兩次會累積 ════════════════════════════════════════
#   ★挑一個「單筆不過門檻、兩筆會過」的對象（印 factor 與兩個門檻值）⇒ 這一格才有鑑別力
func _p2c_season_window() -> void:
	print("\n── P2c 一季窗：相隔 > 一季不累加｜正對照：同一季兩次累積成怨 ──")
	var rows: Array = []
	for gap in [WorldState.TICKS_PER_SEASON + 1, WorldState.TICKS_PER_DAY]:
		var st: WorldState = _setup()
		var ptid: int = st.get_player_team_id()
		var pool: Array = _npcs(st, [ptid])
		var vic: TeamData = null
		var agg: TeamData = null
		for v in pool:
			var lv: PersonData = st.persons.get((v as TeamData).leader_id)
			var f: float = _factor(lv)
			if InteractionSystem.TRIBUTE_RATE * f < NpcAiSystem.FEUD_MIN and 2.0 * InteractionSystem.TRIBUTE_RATE * f >= NpcAiSystem.FEUD_MIN:
				vic = v
				break
		for a in pool:
			if a != vic and not TeamData.same_faction(a, vic):
				agg = a
				break
		if vic == null or agg == null:
			_check("★不可判：找不到「單筆不過、兩筆會過」的對象", false)
			continue
		agg.tile_pos = vic.tile_pos
		var isys := InteractionSystem.new()
		var acc0: int = int(Probe.counts.get("grudge.form.feud.tributed_accumulated", 0))
		isys.resolve_extortion_direct(st, agg.team_id, vic.team_id)
		st.world.current_tick += gap
		isys.resolve_extortion_direct(st, agg.team_id, vic.team_id)
		var acc: int = int(Probe.counts.get("grudge.form.feud.tributed_accumulated", 0)) - acc0
		var fe: float = _feud(st, vic, agg)
		var lv2: PersonData = st.persons.get(vic.leader_id)
		print("   相隔 %d tick（一季 ＝ %d）：對象 Team%d factor %.2f（單筆 %.3f／兩筆 %.3f，門檻 %.2f）｜累積成怨 %d｜feud %.3f" % [
			gap, WorldState.TICKS_PER_SEASON, vic.team_id, _factor(lv2),
			InteractionSystem.TRIBUTE_RATE * _factor(lv2), 2.0 * InteractionSystem.TRIBUTE_RATE * _factor(lv2),
			NpcAiSystem.FEUD_MIN, acc, fe])
		rows.append({"gap": gap, "acc": acc, "feud": fe})
	if rows.size() == 2:
		_check("P2c【反向】相隔 > 一季 ⇒ 不累加（累積成怨 %d、feud %.3f）" % [int(rows[0]["acc"]), float(rows[0]["feud"])],
			int(rows[0]["acc"]) == 0 and float(rows[0]["feud"]) == 0.0)
		_check("P2c【正對照】同一季兩次 ⇒ 累積成怨 1 次、有 feud 邊（%d、%.3f）" % [int(rows[1]["acc"]), float(rows[1]["feud"])],
			int(rows[1]["acc"]) == 1 and float(rows[1]["feud"]) > 0.0)
	_cells_ran.append("P2c")
