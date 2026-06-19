# scripts/simulation/npc_ai_system.gd
class_name NpcAiSystem

const MEMORY_MAX: int = 20   # TEST VALUE
const VENDETTA_INTENSITY: float = 0.6     # TEST VALUE：脫軌的最低仇恨強度
const VENDETTA_BELLIGERENCE: float = 0.6  # 好戰 ≥ 此
const VENDETTA_PRUDENCE: float = 0.4      # 慎重 < 此

# A feud：嚴重度×個性 gate。全 TEST VALUE。
const FEUD_BASE_FACTOR := 0.2
const FEUD_HONOR_W := 0.7
const FEUD_BELLIGERENCE_W := 0.4
const FEUD_MIN := 0.30
const FEUD_SPREAD_FACTOR := 0.6
const FEUD_SEVERITY := {
	"massacre": 1.0, "betrayal": 0.8, "subjugated": 0.5, "looted": 0.35, "extorted": 0.30,
}

# A feud：唯一形成點。severity×個性 factor，FEUD_MIN gate。回 true=已結仇。
static func form_feud(victim: PersonData, perp_id: int, severity: float, tick: int) -> bool:
	if victim == null or perp_id == -1 or victim.id == perp_id:
		return false
	var honor: float = float(victim.values.get("義氣", 0.5))
	var bell: float  = float(victim.values.get("好戰", 0.5))
	var factor: float = FEUD_BASE_FACTOR + honor * FEUD_HONOR_W + bell * FEUD_BELLIGERENCE_W
	var intensity: float = clampf(severity * factor, 0.0, 1.0)
	if intensity < FEUD_MIN:
		return false
	RelationGraph.add_edge(victim.relation_edges, "feud", perp_id, intensity, tick)
	_activate_goal(victim, "revenge", perp_id)
	Probe.bump("g2.feud_formed")
	return true

# A feud：滅族 → 同 faction 餘部繼承（弱於親歷）。事件當下（erase 前）呼。
static func spread_feud(state: WorldState, victim_team: TeamData, perp_id: int, severity: float, tick: int) -> void:
	var fid: int = victim_team.faction_id
	if fid == -1 or not state.factions.has(fid):
		return
	var perp: PersonData = state.persons.get(perp_id)
	var perp_team: int = perp.team_id if perp else -1
	for tid in state.factions[fid].member_team_ids:
		if tid == victim_team.team_id or tid == perp_team:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null:
			continue
		form_feud(state.persons.get(t.leader_id), perp_id, severity * FEUD_SPREAD_FACTOR, tick)

# 強血仇 + 衝動 → 脫軌目標 team_id（否則 -1）。讀 G2a feud 邊。
func vendetta_target(state: WorldState, leader: PersonData) -> int:
	if leader == null:
		return -1
	if float(leader.values.get("好戰", 0.5)) < VENDETTA_BELLIGERENCE:
		return -1
	if float(leader.values.get("慎重", 0.5)) >= VENDETTA_PRUDENCE:
		return -1
	var edge: Dictionary = RelationGraph.strongest(leader.relation_edges, "feud")
	if edge.is_empty() or float(edge.get("intensity", 0.0)) < VENDETTA_INTENSITY:
		return -1
	var foe: PersonData = state.persons.get(int(edge.get("target", -1)))
	if foe == null or foe.team_id == leader.team_id or not state.teams.has(foe.team_id):
		return -1
	return foe.team_id

func write_memory(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	p.memory.append({
		"type": type, "subject_id": subject_id,
		"tick": tick, "intensity": intensity,
	})
	_trim_memory(p)
	_update_relations(p, type, subject_id, intensity)
	_trigger_goals(p, type, subject_id)
	_write_relation_edge(p, type, subject_id, tick, intensity)   # G2a：同步 typed 邊

func _write_relation_edge(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	# G2a additive：對齊 _trigger_goals 映射，填 typed 邊。reader 在 G2b/G2d。
	match type:
		"betrayal", "looted", "extorted":
			# A feud：改走 form_feud（severity×個性 gate）。bump 移進 form_feud（不雙計）。
			NpcAiSystem.form_feud(p, subject_id, FEUD_SEVERITY.get(type, intensity), tick)
		"kindness", "aided_in_battle":
			RelationGraph.add_edge(p.relation_edges, "gratitude", subject_id, intensity, tick)
		"master":
			RelationGraph.add_edge(p.relation_edges, "protect", subject_id, intensity, tick)

func _trim_memory(p: PersonData) -> void:
	while p.memory.size() > MEMORY_MAX:
		p.memory.pop_front()

func _update_relations(p: PersonData, type: String,
		subject_id: int, intensity: float) -> void:
	if subject_id == -1: return
	var delta: float
	match type:
		"betrayal":          delta = -intensity * 0.8
		"kindness":          delta =  intensity * 0.4
		"master":            delta =  intensity * 0.5
		"witnessed_atrocity":delta = -0.1
		"looted":            delta = -intensity * 0.6
		"extorted":          delta = -intensity * 0.5
		"aided_in_battle":   delta =  intensity * 0.5
		_:                   delta = 0.0
	var cur: float = float(p.relations.get(subject_id, 0.0))
	p.relations[subject_id] = clampf(cur + delta, -1.0, 1.0)

func _trigger_goals(p: PersonData, type: String, subject_id: int) -> void:
	match type:
		"betrayal", "looted", "extorted":
			_activate_goal(p, "revenge", subject_id)
		"kindness", "aided_in_battle":
			_activate_goal(p, "gratitude", subject_id)
		"master":
			_activate_goal(p, "protect", subject_id)

static func _activate_goal(p: PersonData, goal_type: String, target_id: int) -> void:
	for g in p.goals:
		if g["type"] == goal_type and g["target_id"] == target_id:
			g["active"] = true
			return
	p.goals.append({ "type": goal_type, "target_id": target_id, "active": true })

func generate_birth_goals(p: PersonData) -> void:
	if p.values.get("貪婪",  0.5) > 0.6:
		p.goals.append({ "type": "wealth",      "target_id": -1, "active": true })
	if p.values.get("求生欲",0.5) > 0.6:
		p.goals.append({ "type": "escape_war",  "target_id": -1, "active": true })
	if p.values.get("野心",  0.5) > 0.65:
		p.goals.append({ "type": "domination",  "target_id": -1, "active": true })
	if p.values.get("好戰",  0.5) > 0.55:
		p.goals.append({ "type": "merit",       "target_id": -1, "active": true })
	if p.values.get("義氣",  0.5) > 0.65:
		p.goals.append({ "type": "peace",       "target_id": -1, "active": true })

func check_goal_alignment(p: PersonData, task: String) -> float:
	var delta: float = 0.0
	for g in p.goals:
		if not g.get("active", false): continue
		delta += _goal_task_delta(g["type"], task)
	return delta

func _goal_task_delta(goal_type: String, task: String) -> float:
	match goal_type:
		"wealth":
			if task in [TeamData.TASK_TRADE, TeamData.TASK_PRODUCE, TeamData.TASK_MANUFACTURE, TeamData.TASK_LOOT]: return 0.005
		"escape_war":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return -0.015
			if task in [TeamData.TASK_FLEE, TeamData.TASK_REST, TeamData.TASK_TRADE]: return 0.005
		"domination":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return 0.005
		"merit":
			if task in [TeamData.TASK_ATTACK]: return 0.005
		"peace":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return -0.01
			if task in [TeamData.TASK_DIPLOMACY, TeamData.TASK_TRADE]: return 0.005
		"revenge":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return 0.005
		"gratitude":
			if task in [TeamData.TASK_DIPLOMACY, TeamData.TASK_TRADE]: return 0.003
		"protect":
			if task in [TeamData.TASK_ATTACK]: return 0.008
	return 0.0

func cleanup_goals(state: WorldState, p: PersonData) -> void:
	for g in p.goals:
		if g["target_id"] == -1: continue
		if not state.persons.has(g["target_id"]):
			match g["type"]:
				"revenge":
					var new_target: int = _find_revenge_redirect(state, p, g["target_id"])
					if new_target != -1:
						g["target_id"] = new_target
					else:
						g["type"] = _fallback_birth_goal(p)
						g["target_id"] = -1
				"gratitude", "protect":
					g["type"] = _fallback_birth_goal(p)
					g["target_id"] = -1

func _find_revenge_redirect(state: WorldState, p: PersonData,
		dead_id: int) -> int:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.leader_id == dead_id or dead_id in t.named_members:
			if t.leader_id != p.id:
				return t.leader_id
	return -1

func _fallback_birth_goal(p: PersonData) -> String:
	var candidates: Array = [
		{ "type": "wealth",     "value": p.values.get("貪婪",  0.5) },
		{ "type": "escape_war", "value": p.values.get("求生欲",0.5) },
		{ "type": "domination", "value": p.values.get("野心",  0.5) },
		{ "type": "merit",      "value": p.values.get("好戰",  0.5) },
		{ "type": "peace",      "value": p.values.get("義氣",  0.5) },
	]
	candidates.sort_custom(func(a, b): return a["value"] > b["value"])
	return candidates[0]["type"]
