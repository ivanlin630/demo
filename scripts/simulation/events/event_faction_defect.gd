extends "res://scripts/simulation/events/base_event.gd"

const DEFECT_UNREST_THRESHOLD: int   = 20
const DEFECT_HONOR_THRESHOLD: float  = 0.35

func check(state: WorldState, team: TeamData) -> bool:
	if team.faction_id == -1:
		return false
	if team.unrest_turns < DEFECT_UNREST_THRESHOLD:
		return false
	var leader = state.persons.get(team.leader_id)
	if leader == null:
		return false
	return float(leader.values.get("義氣", 0.5)) < DEFECT_HONOR_THRESHOLD

func execute(state: WorldState, team: TeamData) -> Array:
	var fid: int = team.faction_id
	if not state.factions.has(fid):
		team.faction_id = -1
		return []
	var f = state.factions[fid]
	f.member_team_ids.erase(team.team_id)
	team.faction_id = -1
	if f.member_team_ids.size() <= 1:
		state.disband_faction(fid)
	SimMessageSystem.new().emit_message(state, "faction_defect",
		"Team%d 脫離勢力%d" % [team.team_id, fid], team)
	print("[Faction] Team%d 脫離勢力%d" % [team.team_id, fid])
	return []
