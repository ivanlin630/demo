class_name HarvestSystem

const SEASON_LENGTH: int = WorldState.TICKS_PER_SEASON   # 1季 = 90天
const SEASON_BASE: Array  = [1.1, 1.5, 1.2, 0.3]      # 春夏秋冬
const SEASON_NAMES: Array = ["春", "夏", "秋", "冬"]

func tick_all(state: WorldState) -> void:
	var season: int  = (state.world.current_tick / SEASON_LENGTH) % 4
	var base: float  = SEASON_BASE[season]
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		tile.harvest_factor = clampf(base + randf_range(-0.25, 0.25), 0.1, 2.0)
	print("[Harvest] Tick%d 季節=%s base=%.1f" % [
		state.world.current_tick, SEASON_NAMES[season], base])
	_check_famine_warnings(state)

func _check_famine_warnings(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.harvest_factor >= 0.5 or tile.outpost_level == 0 or tile.outpost_type != "civilian":
			continue
		var owner_team: TeamData = state.teams.get(tile.outpost_owner)
		if owner_team == null:
			continue
		SimMessageSystem.new().emit_message(state, "famine_warning",
			TextBank.fmt("famine_warning", "default", {"origin": str(owner_team.team_id), "harvest": "%.2f" % tile.harvest_factor}),
			owner_team,
			{"origin": str(owner_team.team_id), "tile_pos": tile.tile_pos, "harvest_factor": tile.harvest_factor})
