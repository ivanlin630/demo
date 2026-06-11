class_name ReactionSystem

const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

func evaluate_all(state: WorldState, team_ids: Array, skill_sys: Object = null) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			continue
		var flee_count: int = 0
		var morale_acc: float = 0.0
		var morale_n: int = 0
		for pid in state.persons:
			var person: PersonData = state.persons[pid]
			if person.team_id != tid:
				continue
			if state.world.current_tick % GOAL_CHECK_INTERVAL == 0:
				_update_goals(person)
				var alignment: float = _npc_ai.check_goal_alignment(person, team.current_task)
				person.loyalty = clampf(person.loyalty + alignment, 0.0, 1.0)
			var reaction: String = _evaluate_person(person, team)
			if reaction != "none":
				_apply_reaction(state, person, team, reaction)
				if skill_sys != null:
					skill_sys.on_reaction(person, reaction)
			if reaction == "N1_flee":
				flee_count += 1
			match reaction:
				"P2_produce": morale_acc += 1.0; morale_n += 1
				"N4_shirk":   morale_acc -= 1.0; morale_n += 1
				"none":       pass
				_:            morale_n += 1   # 其他 reaction 中性計入
		if morale_n > 0:
			var target_morale: float = clampf(1.0 + (morale_acc / float(morale_n)) * 0.5, 0.5, 1.5)
			team.work_morale = clampf(lerpf(team.work_morale, target_morale, 0.1), 0.5, 1.5)
		if flee_count > 0 and float(flee_count) / maxf(team.population, 1) >= 0.3:
			if team.current_task not in ["逃跑", "護衛"]:
				team.current_task = "逃跑"
				team.move_target  = Vector2i(-1, -1)
				print("[ReactionBridge] Team%d 逃跑（%d/%d 人）" % [tid, flee_count, team.population])

# 主動攻擊戰敗 → named 成員忠誠降、leader 壓力升（無硬性 cooldown，純 reaction）
func on_attack_defeat(state: WorldState, team_id: int, pop_loss_ratio: float) -> void:
	var team: TeamData = state.teams.get(team_id)
	if team == null: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var honor: float = float(leader.values.get("義氣", 0.5))
	var faith: float = float(leader.values.get("信義", 0.5))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var loyalty_delta: float = -0.1 * (honor + faith) / 2.0
	var stress_delta: float = 0.2 * caution
	if pop_loss_ratio > 0.3:
		loyalty_delta *= 2.0
		stress_delta *= 1.5
	for pid in team.named_members:
		var p: PersonData = state.persons.get(int(pid))
		if p == null: continue
		p.loyalty = clampf(p.loyalty + loyalty_delta, 0.0, 1.0)
	leader.stress = clampf(leader.stress + stress_delta, 0.0, 1.0)
	print("[AttackDefeat] Team%d 戰敗 loss=%.2f loyalty_d=%.3f stress_d=%.3f" % [
		team_id, pop_loss_ratio, loyalty_delta, stress_delta])

func _has_goal_type(person: PersonData, type: String) -> bool:
	for g in person.goals:
		if g is Dictionary and g.get("type", "") == type:
			return true
	return false

func _erase_goal_type(person: PersonData, type: String) -> void:
	for i in range(person.goals.size() - 1, -1, -1):
		var g = person.goals[i]
		if g is Dictionary and g.get("type", "") == type:
			person.goals.remove_at(i)

func _update_goals(person: PersonData) -> void:
	var ambition: float = float(person.values.get("野心", 0.5))
	var survival: float = float(person.values.get("求生欲", 0.5))
	var greed: float = float(person.values.get("貪婪", 0.5))
	var loyalty_val: float = float(person.values.get("義氣", 0.5))

	if ambition > 0.7 and not _has_goal_type(person, "domination"):
		person.goals.append({ "type": "domination", "target_id": -1, "active": true })
	if survival > 0.7 and person.stress > 0.5 and not _has_goal_type(person, "wealth"):
		person.goals.append({ "type": "wealth", "target_id": -1, "active": true })
	if greed > 0.7 and not _has_goal_type(person, "wealth"):
		person.goals.append({ "type": "wealth", "target_id": -1, "active": true })
	if loyalty_val > 0.7:
		_erase_goal_type(person, "escape_war")
		_erase_goal_type(person, "revenge")

func _evaluate_person(person: PersonData, team: TeamData) -> String:
	var scores: Dictionary = {
		"P1_comply":  _score_comply(person, team),
		"P2_produce": _score_produce(person, team),
		"P4_expand":  _score_expand(person, team),
		"P5_breed":   _score_breed(person, team),
		"N1_flee":    _score_flee(person, team),
		"N2_riot":    _score_riot(person, team),
		"N3_defect":  _score_defect(person, team),
		"N4_shirk":   _score_shirk(person, team),
		"N5_extort":  _score_extort(person, team),
		"none":       0.2,
	}
	for key in scores:
		scores[key] = float(scores[key]) + _goal_bonus(person, key)

	var best: String = "none"
	var best_score: float = 0.0
	for key in scores:
		var s: float = float(scores[key])
		if s > best_score:
			best_score = s
			best = key
	return best

func _goal_bonus(person: PersonData, reaction: String) -> float:
	var bonus: float = 0.0
	for goal in person.goals:
		if not (goal is Dictionary):
			continue
		var gtype: String = goal.get("type", "")
		match gtype:
			"escape_war", "wealth":
				if reaction == "N1_flee": bonus += 0.2
			"domination":
				if reaction == "P4_expand": bonus += 0.35
			"revenge":
				if reaction in ["N2_riot", "N3_defect"]: bonus += 0.2
	return bonus

func _score_comply(p: PersonData, _t: TeamData) -> float:
	var base: float = p.loyalty * (1.0 - p.stress) * 0.8
	base += float(p.values.get("義氣", 0.5)) * 0.2
	base -= float(p.values.get("野心", 0.5)) * 0.1
	return base

func _score_produce(p: PersonData, t: TeamData) -> float:
	var food_ok: bool = float(p.needs.get("food", 1.0)) > 0.6
	var active: bool = food_ok and p.stress < 0.4 \
		and (t.tags.has("生產") or t.current_task == "生產")
	var base: float = 0.6 if active else 0.1
	base += float(p.skills.get("生產", 0.0)) * 0.4
	base += float(p.values.get("慎重", 0.5)) * 0.1
	return base

func _score_expand(p: PersonData, t: TeamData) -> float:
	var food: float = float(t.resources.get("food", 0))
	var base: float = 0.55 if (food > 100.0 and p.stress < 0.3 and t.tags.has("統領")) else 0.05
	base += float(p.skills.get("統領", 0.0)) * 0.3
	base += float(p.values.get("野心", 0.5)) * 0.3
	base += float(p.skills.get("戰術", 0.0)) * 0.2
	return base

func _score_breed(p: PersonData, t: TeamData) -> float:
	var safe: bool = float(p.needs.get("safety", 1.0)) > 0.7
	var fed: bool = float(p.needs.get("food", 1.0)) > 0.7
	var minor_cap: int = int(t.population * 0.2)
	var base: float = 0.4 if (safe and fed and t.minor_population < minor_cap) else 0.0
	base += float(p.skills.get("醫療", 0.0)) * 0.1
	return base

func _score_flee(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * (1.0 - p.loyalty) * 0.9
	base += float(p.values.get("求生欲", 0.5)) * 0.3
	base += float(p.skills.get("求生", 0.0)) * 0.2
	base -= float(p.values.get("慎重", 0.5)) * 0.05
	return base

func _score_riot(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * p.fear * 0.85
	base += float(p.skills.get("戰鬥", 0.0)) * 0.2
	base += float(p.values.get("殘忍", 0.5)) * 0.15
	base -= float(p.values.get("慎重", 0.5)) * 0.2
	return base

func _score_defect(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * (1.0 - p.loyalty) * p.fear * 0.7
	base += float(p.skills.get("計謀", 0.0)) * 0.2
	base -= float(p.values.get("義氣", 0.5)) * 0.15
	base -= float(p.values.get("慎重", 0.5)) * 0.15
	return base

func _score_shirk(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * (1.0 - p.loyalty) * 0.5
	base -= float(p.values.get("慎重", 0.5)) * 0.05
	return base

func _score_extort(p: PersonData, _t: TeamData) -> float:
	var boldness: float = 1.0 - p.fear
	var base: float = p.stress * boldness * (1.0 - p.loyalty) * 0.6
	base += float(p.skills.get("商業", 0.0)) * 0.2
	base += float(p.values.get("貪婪", 0.5)) * 0.3
	base += float(p.values.get("殘忍", 0.5)) * 0.15
	base -= float(p.values.get("慎重", 0.5)) * 0.25
	return base

func _apply_reaction(state: WorldState, person: PersonData, team: TeamData, reaction: String) -> void:
	match reaction:
		"P1_comply":
			person.loyalty = minf(person.loyalty + 0.01, 1.0)
		"P2_produce":
			pass   # 效果改由 work_morale 係數體現（evaluate_all 統計）
		"P4_expand":
			team.unrest_turns = maxi(team.unrest_turns - 1, 0)
		"P5_breed":
			var surplus_ok: bool = float(team.resources.get("food", 0)) \
				> float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 7.0
			if surplus_ok:
				var cap: int = int(team.population * 0.2)
				if team.minor_population < cap:
					team.minor_population += 1
		"N1_flee":
			team.population = maxi(team.population - 1, 1)
			person.stress = maxf(person.stress - 0.3, 0.0)
			# 具名成員逃跑：清除 named_members 引用，避免 ghost member
			if team.named_members.has(person.id):
				team.named_members.erase(person.id)
				person.team_id = -1
		"N2_riot":
			team.unrest_turns += 1
		"N3_defect":
			team.population = maxi(team.population - 1, 1)
			person.loyalty = 0.0
			# 具名成員叛離：清除 named_members 引用
			if team.named_members.has(person.id):
				team.named_members.erase(person.id)
				person.team_id = -1
		"N4_shirk":
			var f: float = float(team.resources.get("food", 0))
			team.resources["food"] = maxf(f - 1.0, 0.0)
		"N5_extort":
			var money: float = float(team.resources.get("coin", 0))
			var steal: float = minf(money, 5.0)
			team.resources["coin"] = money - steal
			person.coin += steal   # 守恆：偷進私囊

	_maybe_write_memory(person, reaction, state.world.current_tick)

	print("[Tick %d] Person %d (%s/team%d) → %s | stress=%.2f loyalty=%.2f" % [
		state.world.current_tick, person.id, person.role, person.team_id,
		reaction, person.stress, person.loyalty
	])

func _maybe_write_memory(person: PersonData, reaction: String, tick: int) -> void:
	if reaction in ["none", "P1_comply", "P2_produce"]:
		return
	var intensity: String = "minor"
	if reaction in ["N2_riot", "N3_defect"]:
		intensity = "significant"
	elif reaction == "N1_flee":
		intensity = "traumatic"
	person.memory.append({ "event_id": tick, "intensity": intensity, "reaction": reaction })
