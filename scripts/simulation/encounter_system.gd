# scripts/simulation/encounter_system.gd
class_name EncounterSystem

const ESCORT_DETECT_RANGE: int    = 3    # TEST VALUE — 護送感知範圍
const ESCORT_MAX_NEARBY_ENEMIES: int = 1 # TEST VALUE
const PRISONER_CHECK_INTERVAL: int = 5   # TEST VALUE — 待校正
const MESSENGER_RANGE: int        = 5    # TEST VALUE

const WORLD_DIR_TO_EDGE: Dictionary = {
	Vector2i( 0, -1): 0,
	Vector2i( 1, -1): 1,
	Vector2i( 1,  0): 2,
	Vector2i( 0,  1): 3,
	Vector2i(-1,  1): 4,
	Vector2i(-1,  0): 5,
}

func hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _get_body_parts(unit: Dictionary, state: WorldState) -> Dictionary:
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		return p.body_parts if p else {}
	return unit.get("body_parts", {})

func is_dead(unit: Dictionary, state: WorldState) -> bool:
	var bp := _get_body_parts(unit, state)
	return bp.get("torso", {}).get("status", "healthy") == "severed"

func is_combat_capable(unit: Dictionary, state: WorldState) -> bool:
	if is_dead(unit, state): return false
	if unit.get("has_exited", false): return false
	var bp := _get_body_parts(unit, state)
	if bp.get("torso", {}).get("status", "healthy") == "critical": return false
	var legs_critical: int = 0
	if bp.get("right_leg", {}).get("status") == "critical": legs_critical += 1
	if bp.get("left_leg",  {}).get("status") == "critical": legs_critical += 1
	if legs_critical >= 2: return false
	return true

func _default_body_parts() -> Dictionary:
	return {
		"head":      {"status": "healthy"},
		"torso":     {"status": "healthy"},
		"right_arm": {"status": "healthy"},
		"left_arm":  {"status": "healthy"},
		"right_leg": {"status": "healthy"},
		"left_leg":  {"status": "healthy"},
	}

func _create_named_unit(pid: int, team_id: int, pos: Vector2i,
		state: WorldState) -> Dictionary:
	var fatigue: float = 0.0
	var t: TeamData = state.teams.get(team_id)
	if t: fatigue = t.fatigue
	return {
		"person_id":    pid,
		"team_id":      team_id,
		"pos":          pos,
		"stamina":      clampf(1.0 - fatigue, 0.1, 1.0),
		"is_messenger": false,
		"has_exited":   false,
		"escort_target": -1,
	}

func _create_anon_unit(team: TeamData, pos: Vector2i) -> Dictionary:
	return {
		"person_id":    -1,
		"team_id":      team.team_id,
		"pos":          pos,
		"stamina":      clampf(1.0 - team.fatigue, 0.1, 1.0),
		"is_messenger": false,
		"has_exited":   false,
		"escort_target": -1,
		"body_parts":   _default_body_parts(),
		"skills": { "戰鬥": float(team.resources.get("anon_combat_skill", 0.2)) },
	}

const MAP_RADIUS: int = 10   # TEST VALUE

func _get_edge_entry_positions(edge: int, count: int) -> Array:
	var positions: Array = []
	var edge_hexes: Array = _get_edge_hexes(edge)
	edge_hexes.shuffle()
	for i in range(mini(count, edge_hexes.size())):
		positions.append(edge_hexes[i])
	return positions

func _get_edge_hexes(edge: int) -> Array:
	var result: Array = []
	match edge:
		0: for x in range(-MAP_RADIUS, MAP_RADIUS + 1): result.append(Vector2i(x, -MAP_RADIUS))
		1: for y in range(-MAP_RADIUS, 0): result.append(Vector2i(MAP_RADIUS, y))
		2: for y in range(0, MAP_RADIUS + 1): result.append(Vector2i(MAP_RADIUS, y))
		3: for x in range(-MAP_RADIUS, MAP_RADIUS + 1): result.append(Vector2i(x, MAP_RADIUS))
		4: for y in range(0, MAP_RADIUS + 1): result.append(Vector2i(-MAP_RADIUS, y))
		5: for y in range(-MAP_RADIUS, 0): result.append(Vector2i(-MAP_RADIUS, y))
	return result

func _get_pursuit_entry_edges(offset: int) -> Array:
	return [(offset) % 6, (offset + 1) % 6, (offset + 2) % 6]

func get_reinforcement_entry_edge(
		encounter_tile: Vector2i, reinforcement_tile: Vector2i) -> int:
	var delta: Vector2i = encounter_tile - reinforcement_tile
	var best_edge: int = 0
	var best_dot: float = -99.0
	for dir in WORLD_DIR_TO_EDGE:
		var dot: float = float(delta.x * dir.x + delta.y * dir.y)
		if dot > best_dot:
			best_dot = dot
			best_edge = WORLD_DIR_TO_EDGE[dir]
	return best_edge

func init_encounter(state: WorldState, attacker_id: int, defender_id: int,
		combat_type: String) -> void:
	state.encounter_active      = true
	state.encounter_attacker_id = attacker_id
	state.encounter_defender_id = defender_id
	state.encounter_units.clear()

	var atk: TeamData = state.teams.get(attacker_id)
	var def: TeamData = state.teams.get(defender_id)
	if atk == null or def == null: return

	if combat_type == "pursuit":
		var center_positions: Array = [Vector2i(0,0), Vector2i(1,0),
			Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		_spawn_team_units(state, def, center_positions)
		var edges := _get_pursuit_entry_edges(state.pursuit_edge_offset)
		state.pursuit_edge_offset = (state.pursuit_edge_offset + 2) % 6
		var atk_positions: Array = []
		for e in edges:
			atk_positions += _get_edge_entry_positions(e, 5)
		_spawn_team_units(state, atk, atk_positions)
	else:
		var atk_pos := _get_edge_entry_positions(0, atk.population + atk.named_members.size())
		var def_pos := _get_edge_entry_positions(3, def.population + def.named_members.size())
		_spawn_team_units(state, atk, atk_pos)
		_spawn_team_units(state, def, def_pos)

	print("[Encounter] 遭遇戰開始 Team%d vs Team%d (type=%s) units=%d" % [
		attacker_id, defender_id, combat_type, state.encounter_units.size()])

func _spawn_team_units(state: WorldState, team: TeamData,
		positions: Array) -> void:
	var pos_idx: int = 0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var pos: Vector2i = positions[pos_idx % positions.size()]
		pos_idx += 1
		state.encounter_units.append(_create_named_unit(pid, team.team_id, pos, state))
	for _i in range(team.population):
		var pos: Vector2i = positions[pos_idx % positions.size()]
		pos_idx += 1
		state.encounter_units.append(_create_anon_unit(team, pos))
