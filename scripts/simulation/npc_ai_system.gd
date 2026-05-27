# scripts/simulation/npc_ai_system.gd
class_name NpcAiSystem

const MEMORY_MAX: int = 20   # TEST VALUE

func write_memory(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	p.memory.append({
		"type": type, "subject_id": subject_id,
		"tick": tick, "intensity": intensity,
	})
	_trim_memory(p)
	_update_relations(p, type, subject_id, intensity)
	_trigger_goals(p, type, subject_id)

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

func _activate_goal(p: PersonData, goal_type: String, target_id: int) -> void:
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
			if task in ["貿易", "生產", "製造", "掠奪"]: return 0.005
		"escape_war":
			if task in ["攻擊", "掠奪"]: return -0.015
			if task in ["逃跑", "rest", "貿易"]: return 0.005
		"domination":
			if task in ["攻擊", "掠奪"]: return 0.005
		"merit":
			if task in ["攻擊"]: return 0.005
		"peace":
			if task in ["攻擊", "掠奪"]: return -0.01
			if task in ["外交", "貿易"]: return 0.005
		"revenge":
			if task in ["攻擊", "掠奪"]: return 0.005
		"gratitude":
			if task in ["外交", "貿易"]: return 0.003
		"protect":
			if task in ["攻擊"]: return 0.008
	return 0.0

func get_goal_task_override(state: WorldState, p: PersonData) -> String:
	for g in p.goals:
		if not g.get("active", false): continue
		match g["type"]:
			"protect":
				var tgt: PersonData = state.persons.get(g["target_id"])
				if tgt != null and tgt.team_id != p.team_id:
					return "move_to_protect"
			"revenge":
				var tgt: PersonData = state.persons.get(g["target_id"])
				if tgt != null and tgt.team_id != p.team_id:
					if randf() < p.values.get("好戰", 0.5) * 0.3:
						return "攻擊"
			"escape_war":
				var team: TeamData = state.teams.get(p.team_id)
				if team != null and float(team.resources.get("food", 0)) < 20:
					return "逃跑"
	return ""

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
