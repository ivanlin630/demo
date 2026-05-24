class_name ResourceSystem

const FOOD_PER_PERSON_PER_TICK: float = 0.1

func collect_resources(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams[tid]
		var tile_id: int = _pos_to_tile_id(team.tile_pos)
		if not state.world.tiles.has(tile_id):
			continue
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0:
			continue
		for res in tile.resources:
			var gain: float = tile.productivity * float(tile.resources[res]) * 0.01
			if res == "food" and tile.farming_level > 0:
				gain *= (1.0 + tile.farming_level * 0.5)
			team.resources[res] = float(team.resources.get(res, 0)) + gain

func resolve_consumption(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams[tid]
		var total_pop: int = team.population + team.minor_population
		var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_TICK
		var food_available: float = float(team.resources.get("food", 0))

		if food_available >= food_needed:
			team.resources["food"] = food_available - food_needed
			_update_person_needs(state, tid, "food", 1.0)
		else:
			team.resources["food"] = 0.0
			var satisfaction: float = food_available / food_needed if food_needed > 0.0 else 0.0
			_update_person_needs(state, tid, "food", satisfaction)

func _update_person_needs(state: WorldState, team_id: int, need: String, value: float) -> void:
	for pid in state.persons:
		var person: PersonData = state.persons[pid]
		if person.team_id != team_id:
			continue
		person.needs[need] = value
		if value < 0.5:
			person.stress = minf(person.stress + (0.5 - value) * 0.2, 1.0)
		else:
			person.stress = maxf(person.stress - 0.05, 0.0)
		if need == "food":
			if value < 0.3:
				person.fear = minf(person.fear + 0.05, 1.0)
				person.loyalty = maxf(person.loyalty - 0.02, 0.0)
			else:
				person.fear = maxf(person.fear - 0.02, 0.0)

func _pos_to_tile_id(pos: Vector2i) -> int:
	return pos.x * 1000 + pos.y
