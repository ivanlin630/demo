class_name InquirySystem

const MAX_OPTIONS: int = 5

const INQUIRY_RELATION_THRESHOLD: Dictionary = {
	"ask_team_location":  0.0,
	"ask_food_source":    0.0,
	"ask_enemy_movement": 0.3,
	"ask_recent_events":  0.0,
	"ask_faction_status": 0.4,
}

const ALL_INQUIRY_IDS: Array = [
	"ask_team_location",
	"ask_food_source",
	"ask_enemy_movement",
	"ask_recent_events",
	"ask_faction_status",
]

func get_options(state: WorldState, player_team: TeamData,
		npc_team: TeamData) -> Array:
	var options: Array = []
	var rel: float = _calc_relationship(state, player_team, npc_team)
	for id in ALL_INQUIRY_IDS:
		if not _passes_filter(id, state, player_team, npc_team): continue
		var req_rel: float = float(INQUIRY_RELATION_THRESHOLD.get(id, 0.0))
		if rel < req_rel: continue
		options.append({
			"id": id,
			"label": TextBank.fmt("ui_inquiry_" + id, "label", {}),
			"desc":  TextBank.fmt("ui_inquiry_" + id, "desc", {}),
			"relevance": _score_option(id, state, player_team, npc_team),
		})
	options.sort_custom(func(a, b): return a["relevance"] > b["relevance"])
	return options.slice(0, MAX_OPTIONS)

func resolve_inquiry(state: WorldState, player_team: TeamData,
		npc_team: TeamData, inquiry_id: String) -> Dictionary:
	var result: Dictionary = {}
	var rel: float  = _calc_relationship(state, player_team, npc_team)
	var honest: bool = rel > 0.5
	match inquiry_id:
		"ask_team_location":
			var intel: Dictionary = state.team_intel.get(npc_team.team_id, {})
			var locations: Array = []
			for tid in intel:
				var e: Dictionary = BeliefSystem.best_estimate(state, npc_team.team_id, tid)
				var pos: Vector2i = e.get("tile_pos", Vector2i(-1,-1))
				if not honest:
					pos += Vector2i(randi_range(-3,3), randi_range(-3,3))
				locations.append({ "team_id": tid, "tile_pos": pos,
					"pop_est": e.get("population_est", 0) })
			result["locations"] = locations
		"ask_food_source":
			var food_tiles: Array = _find_food_tiles(state, npc_team, honest)
			result["food_tiles"] = food_tiles
		"ask_enemy_movement":
			var enemy_intel: Array = []
			for tid in state.team_intel.get(npc_team.team_id, {}):
				var t: TeamData = state.teams.get(tid)
				if t and t.faction_id != player_team.faction_id:
					var e2: Dictionary = BeliefSystem.best_estimate(state, npc_team.team_id, tid)
					enemy_intel.append({ "team_id": tid,
						"tile_pos": e2.get("tile_pos", t.tile_pos),
						"last_tick": e2.get("last_tick", 0) })
			result["enemy_intel"] = enemy_intel
		"ask_recent_events":
			var known: Array = state.team_known.get(npc_team.team_id, [])
			var recent: Array = known.slice(maxi(known.size()-5, 0))
			if not recent.is_empty() and not honest and randf() < 0.3:
				var copy: MessageData = recent[0].duplicate()
				copy.is_distorted = true
				copy.description = TextBank.fmt(copy.type, "malicious", copy.params)
				recent[0] = copy
			result["events"] = recent
		"ask_faction_status":
			if player_team.faction_id != -1:
				var f: FactionData = state.factions.get(player_team.faction_id)
				if f:
					result["member_count"] = f.member_team_ids.size()
					result["tribute_rate"]  = f.tribute_rate
	return result

func _passes_filter(id: String, state: WorldState,
		player_team: TeamData, _npc_team: TeamData) -> bool:
	match id:
		"ask_team_location":
			var intel: Dictionary = state.team_intel.get(player_team.team_id, {})
			var fresh_count: int = 0
			for tid in intel:
				if int(BeliefSystem.best_estimate(state, player_team.team_id, tid).get("last_tick", 0)) > state.world.current_tick - WorldState.TICKS_PER_DAY * 10:
					fresh_count += 1
			return fresh_count < 3
		"ask_faction_status":
			return player_team.faction_id != -1
		_: return true

func _score_option(id: String, state: WorldState,
		player_team: TeamData, _npc_team: TeamData) -> float:
	match id:
		"ask_food_source":
			var food: float   = float(player_team.resources.get("food", 0))
			var daily: float  = float(player_team.population) * 2.4
			var days: float   = food / maxf(daily, 1.0)
			return clampf(2.0 - days * 0.1, 0.0, 2.0)
		"ask_enemy_movement":
			return 1.5 if not state.player_hostile_teams.is_empty() else 0.3
		"ask_faction_status":
			return 1.0
		"ask_recent_events":
			return 0.5
		_: return 0.4

func _calc_relationship(_state: WorldState, a: TeamData, b: TeamData) -> float:
	return float(a.known_reputations.get(b.team_id, 0.5))

func _find_food_tiles(state: WorldState, near_team: TeamData, honest: bool) -> Array:
	var results: Array = []
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if float(tile.resources.get("food", 0)) > 100.0:
			var pos: Vector2i = tile.tile_pos
			if not honest:
				pos += Vector2i(randi_range(-2,2), randi_range(-2,2))
			results.append({ "tile_pos": pos, "terrain": tile.terrain })
			if results.size() >= 3: break
	return results
