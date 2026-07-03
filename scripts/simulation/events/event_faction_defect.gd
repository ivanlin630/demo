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
	var honor: float = float(leader.values.get("義氣",  0.5))
	var trust: float = float(leader.values.get("信義", 0.5))
	return honor < DEFECT_HONOR_THRESHOLD or trust < DEFECT_HONOR_THRESHOLD

func execute(state: WorldState, team: TeamData) -> Array:
	var fid: int = team.faction_id
	if not state.factions.has(fid):
		state.clear_team_faction(team)   # S11：faction 已不存在防禦路徑，走 chokepoint（語意等同 =-1，無懸空可修）
		return []
	var f = state.factions[fid]
	state.clear_team_faction(team)   # 脫離 faction（雙向同步）
	if f.member_team_ids.size() <= 1:
		state.disband_faction(fid)
	SimMessageSystem.new().emit_message(state, "faction_defect",
		"Team%d 脫離勢力%d" % [team.team_id, fid], team,
		{ "origin": str(team.team_id) })
	print("[Faction] Team%d 脫離勢力%d" % [team.team_id, fid])
	return []
