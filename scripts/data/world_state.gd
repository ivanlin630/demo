class_name WorldState

var world: WorldData = WorldData.new()
var teams: Dictionary = {}
var persons: Dictionary = {}
var global_messages: Array = []
var team_known: Dictionary = {}
var factions: Dictionary = {}
var _next_faction_id: int = 0

func create_faction(leader_team_id: int) -> int:
	var f = load("res://scripts/data/faction_data.gd").new()
	f.faction_id = _next_faction_id
	f.leader_team_id = leader_team_id
	f.member_team_ids = [leader_team_id]
	factions[f.faction_id] = f
	_next_faction_id += 1
	teams[leader_team_id].faction_id = f.faction_id
	return f.faction_id

func disband_faction(faction_id: int) -> void:
	if not factions.has(faction_id):
		return
	var f = factions[faction_id]
	for tid in f.member_team_ids:
		if teams.has(tid):
			teams[tid].faction_id = -1
	factions.erase(faction_id)
	print("[Faction] 勢力%d 解散" % faction_id)
