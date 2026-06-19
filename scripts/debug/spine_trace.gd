class_name SpineTrace

# 時間軸脊椎 dump（純讀，仿 TeamTrace 風格）。對 WATCHED team + auto-pick named 印分脊椎結構化行。
# 只讀遊戲 state，禁改。host = game_sim_test（取樣鉤）。
const WATCHED: Array = [0, 1, 2, 3, 4]   # 統領/商隊/敵軍/生產村/流亡

static func dump(state: WorldState, tick: int) -> void:
	var day: int = tick / 240
	for tid in WATCHED:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		_dump_g1(state, day, t)
		_dump_g2(state, day, t)
		_dump_g3(state, day, t)
	_dump_named(state, day)

static func _dump_g1(state: WorldState, day: int, t: TeamData) -> void:
	print("[G1] d%d T%d order=%s/%s coin=%.0f food=%.0f mat=%.0f goods=%.0f" % [
		day, t.team_id, str(t.order_target_id), t.order_task,
		float(t.resources.get("coin", 0)), float(t.resources.get("food", 0)),
		float(t.resources.get("material", 0)), float(t.resources.get("goods", 0))])

static func _dump_g2(state: WorldState, day: int, t: TeamData) -> void:
	var leader: PersonData = state.persons.get(t.leader_id)
	var edges: Array = leader.relation_edges if leader else []
	var feud := 0; var grat := 0; var prot := 0; var trust := 0
	for e in edges:
		match e.get("type", ""):
			"feud": feud += 1
			"gratitude": grat += 1
			"protect": prot += 1
			"trust": trust += 1
	# vendetta 為 NpcAiSystem 計算值（讀 leader 最強 feud + 衝動 gate），非 TeamData 欄
	var vendetta: int = NpcAiSystem.new().vendetta_target(state, leader) if leader else -1
	print("[G2] d%d T%d rung=%d arch=%s cap=%d vendetta=%d edges(feud%d/grat%d/prot%d/trust%d)" % [
		day, t.team_id, t.ambition_rung, str(t.ambition_archetype), t.ambition_cap,
		vendetta, feud, grat, prot, trust])

static func _dump_g3(state: WorldState, day: int, t: TeamData) -> void:
	var tgts: Array = BeliefSystem.known_targets(state, t.team_id)
	var claim_total := 0
	var max_unc := 0.0
	for tg in tgts:
		claim_total += BeliefSystem.claims(state, t.team_id, tg).size()
		max_unc = maxf(max_unc, BeliefSystem.uncertainty(state, t.team_id, tg))
	# trust（known_reputations）分佈
	var lo := 1.0; var hi := 0.0; var sum := 0.0; var n := 0
	for k in t.known_reputations:
		var v: float = float(t.known_reputations[k])
		lo = minf(lo, v); hi = maxf(hi, v); sum += v; n += 1
	var trust_s: String = "%.2f/%.2f/%.2f" % [lo if n > 0 else 0.0, (sum / n) if n > 0 else 0.0, hi] if n > 0 else "-"
	print("[G3] d%d T%d task=%s belief(tgt%d/claim%d/maxUnc%.2f) trust(lo/avg/hi=%s)" % [
		day, t.team_id, t.current_task, tgts.size(), claim_total, max_unc, trust_s])

static func _dump_named(state: WorldState, day: int) -> void:
	# 5 leader + auto-pick 最高計謀/野心 named_member
	var named_ids: Array = []
	for tid in WATCHED:
		var t: TeamData = state.teams.get(tid)
		if t and t.leader_id != -1: named_ids.append(t.leader_id)
	var best_scheme := -1; var best_scheme_v := -1.0
	var best_amb := -1; var best_amb_v := -1.0
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.role == "leader": continue   # 已含
		var sc: float = float(p.skills.get("計謀", 0.0))
		var am: float = float(p.values.get("野心", 0.0))
		if sc > best_scheme_v: best_scheme_v = sc; best_scheme = pid
		if am > best_amb_v: best_amb_v = am; best_amb = pid
	if best_scheme != -1 and not named_ids.has(best_scheme): named_ids.append(best_scheme)
	if best_amb != -1 and not named_ids.has(best_amb): named_ids.append(best_amb)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var t: TeamData = state.teams.get(p.team_id)
		var rung: int = t.ambition_rung if t else -1
		print("[Named] d%d P%d(T%d) 統%.1f偵%.1f謀%.1f術%.1f商%.1f | 慎%.1f野%.1f戰%.1f殘%.1f貪%.1f信%.1f | rung=%d loy%.2f str%.2f fear%.2f" % [
			day, pid, p.team_id,
			float(p.skills.get("統領",0)), float(p.skills.get("偵查",0)), float(p.skills.get("計謀",0)),
			float(p.skills.get("戰術",0)), float(p.skills.get("商業",0)),
			float(p.values.get("慎重",0)), float(p.values.get("野心",0)), float(p.values.get("好戰",0)),
			float(p.values.get("殘忍",0)), float(p.values.get("貪婪",0)), float(p.values.get("信義",0)),
			rung, p.loyalty, p.stress, p.fear])
