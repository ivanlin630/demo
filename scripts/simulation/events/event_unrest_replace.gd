extends "res://scripts/simulation/events/base_event.gd"

const UNREST_REPLACE_THRESHOLD: int = 20
const LOYALTY_LEAVE_THRESHOLD: float = 0.35
const COMMAND_SKILL_MIN: float = 0.3

func check(state: WorldState, team: TeamData) -> bool:
	if team.unrest_turns < UNREST_REPLACE_THRESHOLD:
		return false
	return not _get_dissenters(state, team).is_empty()

func execute(state: WorldState, team: TeamData) -> Array:
	var dissenters := _get_dissenters(state, team)
	var replaced := _try_replace_leader(state, team, dissenters)
	if replaced:
		team.unrest_turns = maxi(team.unrest_turns - UNREST_REPLACE_THRESHOLD, 0)
		SimMessageSystem.new().emit_message(state, "replace",
			"Team %d 發生領袖替換，新領袖 Person %d" % [team.team_id, team.leader_id],
			team,
			{ "origin": str(team.team_id) })
	return []

func _get_dissenters(state: WorldState, team: TeamData) -> Array:
	var result: Array = []
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == team.team_id and p.id != team.leader_id:
			if p.loyalty < LOYALTY_LEAVE_THRESHOLD:
				result.append(p)
	return result

func _try_replace_leader(state: WorldState, team: TeamData, dissenters: Array) -> bool:
	var best: PersonData = null
	var best_cmd: float = 0.0
	for p in dissenters:
		var cmd: float = float(p.skills.get("統領", 0.0))
		if cmd > best_cmd:
			best_cmd = cmd
			best = p
	if best == null or best_cmd < COMMAND_SKILL_MIN:
		return false
	var old_leader: PersonData = state.persons.get(team.leader_id)
	if old_leader != null:
		old_leader.role = "member"
		if not team.named_members.has(old_leader.id):
			team.named_members.append(old_leader.id)
	team.leader_id = best.id
	best.role = "leader"
	print("[Event] Team %d 領袖替換：Person %d → Person %d（統領=%.2f）" % [
		team.team_id, old_leader.id if old_leader else -1, best.id, best_cmd
	])
	return true
