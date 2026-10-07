extends SceneTree
# @bed-kind: diagnostic
# @observe-pure
# ══ XB② 勒索煞車量測（spec 2026-10-07 battle-screen-asserted-and-extortion-brake §票 XB）══════════════════
# ★量測卷面，不是閘：同一隊連勒索 10 次，逐次印
#   accept／score／score_no_edge／affinity／feud 邊／是否寫了記憶（＋coin_before）
#   ＋ 被勒索那一刻【對方秤上有哪些選項】（DecisionEngine 的候選集與各自 util）
# ★三條路（spec XB③：索貢走同一個秤，一起量）：
#   A 玩家直接勒索  InteractionSystem.resolve_extortion_direct（玩家是勒索方 ⇒ 會呼 tribute_accept）
#   B NPC 同格掠奪  InteractionSystem._try_interact（LOOT＋readiness ≥ COMBAT_THRESHOLD 那一支）
#   C 玩家遠程索貢  PlayerCommandSystem._action_demand_tribute（threat＝0）
# ★分數讀 DiplomaticAiSystem.tribute_eval（判決同一份算式；量測時關 Probe，不讓量測多記 rel.tribute_eval）
# ★候選集讀 DecisionContext.gather(advance=false) ＋ rank_scored_ctx（不推 EWMA ⇒ 量測不改被量物）

const CFG: String = "res://config/default.json"
const SEED: int = 1337
const N: int = 10
const VICTIMS_A: int = 3


func _initialize() -> void:
	print("=== extortion_brake 量測（XB②）｜cfg=%s seed=%d 每隊 %d 次 ===" % [CFG, SEED, N])
	_path_a_player_direct()
	_path_b_npc_same_tile()
	_path_c_player_demand_tribute()
	print("\n=== extortion_brake_measure DONE ===")
	quit(0)


func _setup() -> WorldState:
	seed(SEED)
	return MeasureBedHelper.arm_and_setup(CFG, false)


func _victims(st: WorldState, exclude: Array, n: int) -> Array:
	var ids: Array = st.teams.keys()
	ids.sort()
	var out: Array = []
	for id in ids:
		var t: TeamData = st.teams[id]
		if exclude.has(int(id)) or t.leader_id == -1 or t.population <= 0:
			continue
		var ok: bool = true
		for e in exclude:
			if st.teams.has(e) and TeamData.same_faction(t, st.teams[e]):
				ok = false
		if not ok:
			continue
		out.append(t)
		if out.size() >= n:
			break
	return out


func _leader_line(st: WorldState, t: TeamData) -> String:
	var l: PersonData = st.persons.get(t.leader_id)
	if l == null:
		return "（無領袖）"
	return "慎重 %.2f 義氣 %.2f 求生欲 %.2f 恐懼 %.2f｜pop %d coin %.0f food %.0f" % [
		float(l.values.get("慎重", 0.5)), float(l.values.get("義氣", 0.5)), float(l.values.get("求生欲", 0.5)),
		l.fear, t.population, float(t.resources.get("coin", 0)), float(t.resources.get("food", 0))]


func _eval(st: WorldState, vic: TeamData, agg: TeamData, threat: float) -> Dictionary:
	var was: bool = Probe.enabled
	Probe.enabled = false
	var ev: Dictionary = DiplomaticAiSystem.tribute_eval(st, vic, agg, threat)
	Probe.enabled = was
	return ev


func _cands(st: WorldState, vic: TeamData) -> String:
	var was: bool = Probe.enabled
	Probe.enabled = false
	var ctx: DecisionContext = DecisionContext.gather(st, vic, false)
	var scored: Array = DecisionEngine.rank_scored_ctx(ctx, vic.current_option, st, vic, "xb_measure")
	Probe.enabled = was
	var parts: Array = []
	for r in scored:
		parts.append("%s %.3f" % [String(r["opt"]), float(r["u"])])
	return "（%d）%s" % [scored.size(), "｜".join(PackedStringArray(parts))]


func _typed_count(st: WorldState, t: TeamData, typ: String) -> int:
	var l: PersonData = st.persons.get(t.leader_id)
	if l == null:
		return 0
	var n: int = 0
	for m in l.memory:
		if String((m as Dictionary).get("type", "")) == typ:
			n += 1
	return n


func _tributed_count(st: WorldState, vic: TeamData) -> int:
	var l: PersonData = st.persons.get(vic.leader_id)
	if l == null:
		return 0
	var n: int = 0
	for m in l.memory:
		if String((m as Dictionary).get("type", "")) == "tributed":
			n += 1
	return n


func _row(i: int, st: WorldState, vic: TeamData, ev: Dictionary, coin_before: float, mem_before: int,
		result: String) -> void:
	var mem_after: int = _tributed_count(st, vic)
	print("  #%02d accept=%s score=%+.3f no_edge=%+.3f 門檻 %.2f｜affinity=%+.3f feud=%.3f grat=%.3f｜coin_before=%.0f｜寫記憶=%s（tributed %d→%d）｜%s" % [
		i, str(ev.get("accept", false)), float(ev.get("score", 0.0)), float(ev.get("score_no_edge", 0.0)),
		float(ev.get("threshold", 0.0)), float(ev.get("affinity", 0.0)), float(ev.get("feud", 0.0)),
		float(ev.get("gratitude", 0.0)), coin_before, str(mem_after > mem_before), mem_before, mem_after, result])


# ══ A 玩家直接勒索 ══════════════════════════════════════════════════════════════════════════
func _path_a_player_direct() -> void:
	print("\n── A 玩家直接勒索（resolve_extortion_direct）──")
	var st: WorldState = _setup()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var isys := InteractionSystem.new()
	print("  玩家 Team%d readiness=%.2f（＝threat）pop %d" % [ptid, pt.readiness, pt.population])
	for vic in _victims(st, [ptid], VICTIMS_A):
		var v: TeamData = vic
		v.tile_pos = pt.tile_pos
		print("\n  ▶ 對象 Team%d｜%s" % [v.team_id, _leader_line(st, v)])
		for i in range(1, N + 1):
			var coin_before: float = float(v.resources.get("coin", 0))
			var mem_before: int = _tributed_count(st, v)
			var ev: Dictionary = _eval(st, v, pt, pt.readiness)
			var cands: String = _cands(st, v)
			var res: Dictionary = isys.resolve_extortion_direct(st, ptid, v.team_id)
			_row(i, st, v, ev, coin_before, mem_before, String(res.get("msg", "")))
			print("       對方候選集 %s" % cands)


# ══ B NPC 同格掠奪 ══════════════════════════════════════════════════════════════════════════
func _path_b_npc_same_tile() -> void:
	print("\n── B NPC 同格掠奪（_try_interact：LOOT＋readiness ≥ %.1f）──" % InteractionSystem.COMBAT_THRESHOLD)
	var st: WorldState = _setup()
	var ptid: int = st.get_player_team_id()
	var va: Array = _victims(st, [ptid], 1)
	if va.is_empty():
		print("  ★不可判：找不到勒索方")
		return
	var agg: TeamData = va[0]
	var vs: Array = _victims(st, [ptid, agg.team_id], 1)
	if vs.is_empty():
		print("  ★不可判：找不到與勒索方不同勢力的對象")
		return
	var vic: TeamData = vs[0]
	print("  勢力：勒索方 %d／對象 %d（同勢力＝%s）" % [agg.faction_id, vic.faction_id, str(TeamData.same_faction(agg, vic))])
	agg.readiness = 0.9
	vic.tile_pos = agg.tile_pos
	print("  勒索方 Team%d readiness=%.2f｜對象 Team%d｜%s" % [agg.team_id, agg.readiness, vic.team_id, _leader_line(st, vic)])
	var isys := InteractionSystem.new()
	# ★XB④：前 N 次每次隔 EXTORT_CONTACT_GAP＋1（＝每次都是新的接觸）；之後 3 次每次只隔 1 tick（同一次接觸）
	for i in range(1, N + 4):
		agg.current_task = TeamData.TASK_LOOT
		agg.readiness = 0.9
		vic.current_task = TeamData.TASK_IDLE
		vic.tile_pos = agg.tile_pos
		agg.combat_target = -1   # ★上一次拒絕若開了戰，同格互動會早返回（:350）⇒ 每次量的是「再來勒索一次」
		vic.combat_target = -1
		st.world.current_tick += (InteractionSystem.EXTORT_CONTACT_GAP + 1) if i <= N else 1
		if i == N + 1:
			print("  ── 以下 3 次＝同一次接觸（每次只隔 1 tick；拒絕支應不再寫）──")
		var coin_before: float = float(vic.resources.get("coin", 0))
		var mem_before: int = _tributed_count(st, vic)
		var ev: Dictionary = _eval(st, vic, agg, agg.readiness)
		var cands: String = _cands(st, vic)
		var c_before: float = coin_before
		isys._try_interact(st, agg.team_id, vic.team_id)
		var took: float = c_before - float(vic.resources.get("coin", 0))
		_row(i, st, vic, ev, coin_before, mem_before, "對方 coin −%.0f｜勒索方 task=%s 交戰中=%s" % [
			took, str(agg.current_task), str(agg.combat_target != -1)])
		print("       對方候選集 %s" % cands)


# ══ C 玩家遠程索貢 ══════════════════════════════════════════════════════════════════════════
func _path_c_player_demand_tribute() -> void:
	print("\n── C 玩家遠程索貢（_action_demand_tribute，threat＝0）──")
	var st: WorldState = _setup()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var pcs := PlayerCommandSystem.new()
	var vs: Array = _victims(st, [ptid], 1)
	if vs.is_empty():
		print("  ★不可判：找不到對象")
		return
	var v: TeamData = vs[0]
	print("  ▶ 對象 Team%d｜%s" % [v.team_id, _leader_line(st, v)])
	for i in range(1, N + 1):
		var coin_before: float = float(v.resources.get("coin", 0))
		var mem_before: int = _tributed_count(st, v)
		var ev: Dictionary = _eval(st, v, pt, 0.0)
		var cands: String = _cands(st, v)
		var res: Dictionary = pcs._action_demand_tribute(st, v.team_id, pt, ptid)
		_row(i, st, v, ev, coin_before, mem_before, "%s｜索貢方（玩家領袖）typed tribute_refused %d 筆" % [
			String(res.get("msg", "")), _typed_count(st, pt, "tribute_refused")])
		print("       對方候選集 %s" % cands)
