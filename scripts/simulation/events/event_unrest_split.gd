extends "res://scripts/simulation/events/base_event.gd"

const UNREST_SPLIT_THRESHOLD: int = 30
const LOYALTY_LEAVE_THRESHOLD: float = 0.35

func check(state: WorldState, team: TeamData) -> bool:
	if team.unrest_turns < UNREST_SPLIT_THRESHOLD:
		return false
	var dissenters := _get_dissenters(state, team)
	if dissenters.is_empty():
		return false
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null:
		return false
	return _has_goal_conflict(dissenters, leader)

func execute(state: WorldState, team: TeamData) -> Array:
	var dissenters := _get_dissenters(state, team)
	var new_team := _split_team(state, team, dissenters)
	if new_team == null:
		return []
	team.unrest_turns = 0
	print("[Event] Team %d 分裂 → 新 Team %d（%d人）" % [
		team.team_id, new_team.team_id, new_team.population
	])
	SimMessageSystem.new().emit_message(state, "split",
		"Team %d 發生分裂，新 Team %d 在 (%d,%d) 成立" % [
			team.team_id, new_team.team_id, team.tile_pos.x, team.tile_pos.y
		], team)
	return [new_team]

func _get_dissenters(state: WorldState, team: TeamData) -> Array:
	var result: Array = []
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == team.team_id and p.id != team.leader_id:
			if p.loyalty < LOYALTY_LEAVE_THRESHOLD:
				result.append(p)
	return result

# 義氣 < 0.4 的異見者才觸發分裂；義氣 >= 0.4 視為不足以割席
func _has_goal_conflict(dissenters: Array, leader: PersonData) -> bool:
	for p in dissenters:
		var loyalty_val: float = float(p.values.get("義氣", 0.5))
		if loyalty_val >= 0.4:
			continue
		for goal in p.goals:
			if not leader.goals.has(goal):
				return true
	return false

func _split_team(state: WorldState, parent: TeamData, dissenters: Array) -> TeamData:
	if dissenters.is_empty():
		return null
	var new_team := TeamData.new()
	new_team.team_id = _next_team_id(state)
	new_team.tile_pos = parent.tile_pos
	new_team.resources = { "food": 0.0, "material": 0, "weapon": 0, "coin": 0, "goods": 0 }
	new_team.tags = []
	new_team.faction_id = -1

	var split_count: int = maxi(dissenters.size() / 2, 1)
	var new_leader_assigned := false

	for i in range(split_count):
		var p: PersonData = dissenters[i]
		p.team_id = new_team.team_id
		parent.population = maxi(parent.population - 1, 1)
		new_team.population += 1
		if not new_leader_assigned:
			new_team.leader_id = p.id
			p.role = "leader"
			new_leader_assigned = true
		else:
			new_team.members.append(p.id)

	state.teams[new_team.team_id] = new_team
	state.team_known[new_team.team_id] = []
	return new_team

func _next_team_id(state: WorldState) -> int:
	var max_id: int = 0
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
