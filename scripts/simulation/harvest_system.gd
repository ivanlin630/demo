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
	_regen_wild_horses(state)
	_regen_herb(state)
	# 每日 outpost 鄰格 wild_horses 批採進公庫（tick_all 每 6 小時跑，日邊界才採）
	if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
		_collect_wild_horses_by_outposts(state)

const WILD_HORSE_REGEN_CHANCE: float = 0.05   # 每月 5% chance +1（極慢）
const WILD_HORSE_TILE_CAP: int = 3
const WILD_HORSE_TILE_CAP_RICH: int = 8   # 野馬草原 cap（resource_cap["wild_horses"]>=4 標記富點）

# 每月（month 邊界）平原/森林 tile 5% 機率 +1 野馬，上限 cap（一般 3 / 野馬草原 8）
func _regen_wild_horses(state: WorldState) -> void:
	if state.world.current_tick % WorldState.TICKS_PER_MONTH != 0:
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.terrain != "plains" and tile.terrain != "forest":
			continue
		var cap: int = WILD_HORSE_TILE_CAP_RICH if int(tile.resource_cap.get("wild_horses", 0)) >= 4 else WILD_HORSE_TILE_CAP
		if int(tile.resources.get("wild_horses", 0)) >= cap:
			continue
		if randf() < WILD_HORSE_REGEN_CHANCE:
			tile.resources["wild_horses"] = int(tile.resources.get("wild_horses", 0)) + 1

# 每月（month 邊界）herb +1 至 resource_cap["herb"]（生成初始值）
func _regen_herb(state: WorldState) -> void:
	if state.world.current_tick % WorldState.TICKS_PER_MONTH != 0:
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var cap: int = int(tile.resource_cap.get("herb", 0))
		if cap <= 0:
			continue
		var cur: int = int(tile.resources.get("herb", 0))
		if cur < cap:
			tile.resources["herb"] = cur + 1

# hex 軸座標六方向
const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, -1), Vector2i(-1, 1),
]

# 每日：所有 outpost 對鄰格 wild_horses 批採進自家公庫（受 mount cap 限制）
func _collect_wild_horses_by_outposts(state: WorldState) -> void:
	var os := OutpostSystem.new()
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner == -1 or tile.outpost_level == 0:
			continue
		var cap: float = os._get_storage_cap(tile, "mounts")
		var stored: float = float(tile.public_storage.get("mounts", 0))
		for d in HEX_DIRS:
			var npos: Vector2i = tile.tile_pos + d
			var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
			if ntile == null:
				continue
			var wh: int = int(ntile.resources.get("wild_horses", 0))
			if wh <= 0:
				continue
			var space: float = maxf(cap - stored, 0.0)
			var taken: int = mini(wh, int(space))
			if taken > 0:
				stored += float(taken)
				ntile.resources["wild_horses"] = wh - taken
				tile.public_storage["mounts"] = stored
				print("[Mount] Outpost %s 採野馬 +%d" % [str(tile.tile_pos), taken])

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
