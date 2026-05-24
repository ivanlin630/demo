class_name ReactionSystem

const GOAL_CHECK_INTERVAL: int = 10

func evaluate_all(state: WorldState, team_ids: Array, skill_sys: Object = null) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			continue
		var flee_count: int = 0
		for pid in state.persons:
			var person: PersonData = state.persons[pid]
			if person.team_id != tid:
				continue
			if state.world.current_tick % GOAL_CHECK_INTERVAL == 0:
				_update_goals(person)
			var reaction: String = _evaluate_person(person, team)
			if reaction != "none":
				_apply_reaction(state, person, team, reaction)
				if skill_sys != null:
					skill_sys.on_reaction(person, reaction)
			if reaction == "N1_flee":
				flee_count += 1
		if flee_count > 0 and float(flee_count) / maxf(team.population, 1) >= 0.3:
			if team.current_task not in ["逃跑", "護衛"]:
				team.current_task = "逃跑"
				team.move_target  = Vector2i(-1, -1)
				print("[ReactionBridge] Team%d 逃跑（%d/%d 人）" % [tid, flee_count, team.population])

func _update_goals(person: PersonData) -> void:
	var ambition: float = float(person.values.get("野心", 0.5))
	var survival: float = float(person.values.get("求生欲", 0.5))
	var greed: float = float(person.values.get("貪婪", 0.5))
	var loyalty_val: float = float(person.values.get("義氣", 0.5))

	if ambition > 0.7 and not person.goals.has("建立勢力"):
		person.goals.append("建立勢力")
	if survival > 0.7 and person.stress > 0.5 and not person.goals.has("求生"):
		person.goals.append("求生")
	if greed > 0.7 and not person.goals.has("發財"):
		person.goals.append("發財")
	if loyalty_val > 0.7:
		person.goals.erase("逃離")
		person.goals.erase("復仇")

func _evaluate_person(person: PersonData, team: TeamData) -> String:
	var scores: Dictionary = {
		"P1_comply":  _score_comply(person, team),
		"P2_produce": _score_produce(person, team),
		"P3_recruit": _score_recruit(person, team),
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
		match goal:
			"求生", "逃離":
				if reaction == "N1_flee": bonus += 0.2
			"擴張", "繁榮":
				if reaction in ["P4_expand", "P3_recruit"]: bonus += 0.15
			"發財":
				if reaction in ["N5_extort", "P2_produce"]: bonus += 0.15
			"復仇":
				if reaction in ["N2_riot", "N3_defect"]: bonus += 0.2
			"建立勢力":
				if reaction in ["P3_recruit", "P4_expand"]: bonus += 0.2
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

func _score_recruit(p: PersonData, t: TeamData) -> float:
	var base: float = 0.5 if (t.population < 40 and p.stress < 0.3 and p.loyalty > 0.7) else 0.05
	base += float(p.skills.get("統領", 0.0)) * 0.3
	base += float(p.values.get("野心", 0.5)) * 0.15
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
			var skill: float = float(person.skills.get("生產", 0.0))
			var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
			var tile: HexTileData = state.world.tiles.get(tile_id)
			var farming_bonus: float = float(tile.farming_level) * 0.5 if tile != null else 0.0
			var food_gain: float = 1.0 + skill * 1.5 + farming_bonus
			team.resources["food"] = float(team.resources.get("food", 0)) + food_gain
		"P3_recruit":
			var leader = state.persons.get(team.leader_id)
			var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
			var cap: int = TeamData.pop_cap_from_leadership(cmd)
			team.population = mini(team.population + 1, cap)
		"P4_expand":
			team.unrest_turns = maxi(team.unrest_turns - 1, 0)
		"P5_breed":
			var cap: int = int(team.population * 0.2)
			if team.minor_population < cap:
				team.minor_population += 1
		"N1_flee":
			team.population = maxi(team.population - 1, 1)
			person.stress = maxf(person.stress - 0.3, 0.0)
		"N2_riot":
			team.unrest_turns += 1
		"N3_defect":
			team.population = maxi(team.population - 1, 1)
			person.loyalty = 0.0
		"N4_shirk":
			var f: float = float(team.resources.get("food", 0))
			team.resources["food"] = maxf(f - 1.0, 0.0)
		"N5_extort":
			var money: float = float(team.resources.get("coin", 0))
			var steal: float = minf(money, 5.0)
			team.resources["coin"] = money - steal

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
