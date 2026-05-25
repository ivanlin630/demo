class_name WorldState

var world: WorldData = WorldData.new()
var teams: Dictionary = {}
var persons: Dictionary = {}
var global_messages: Array = []
var team_known: Dictionary = {}
var team_discovered: Dictionary = {}   # int team_id → Array[int] 已知 team_id 清單
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

func snapshot_faction_member(team_id: int, tick: int) -> void:
	var t: TeamData = teams.get(team_id) as TeamData
	if t == null or t.faction_id == -1:
		return
	var f = factions.get(t.faction_id)
	if f == null:
		return
	f.known_member_states[team_id] = {
		"food":         float(t.resources.get("food", 0.0)),
		"weapons":      (int(t.resources.get("weapon_melee_low",   0))
		              + int(t.resources.get("weapon_melee_high",  0))
		              + int(t.resources.get("weapon_ranged_low",  0))
		              + int(t.resources.get("weapon_ranged_high", 0))),
		"goods":        float(t.resources.get("goods", 0.0)),
		"population":   t.population,
		"tile_pos":     t.tile_pos,
		"current_task": t.current_task,
		"last_tick":    tick,
	}
