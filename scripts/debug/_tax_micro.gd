extends SceneTree
func _initialize() -> void:
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.outpost_owner = 1
	tile.public_storage = {"material": 0.0}
	state.world.tiles[0] = tile
	var ot := TeamData.new(); ot.team_id = 1; ot.tax_rate = 0.5; ot.tile_pos = Vector2i(9, 9)
	state.teams[1] = ot
	var ct := TeamData.new(); ct.team_id = 0; ct.tile_pos = Vector2i(0, 0)
	ct.resources = {"material": 5.0}
	state.teams[0] = ct
	print("rate_for(owner)=", ResourceSystem.tax_rate_for(state, ot))
	ResourceSystem.new()._apply_normal_tax(state, ct, tile, {"material": 5.0})
	print("pub=", tile.public_storage.get("material", 0), " priv=", ct.resources.get("material", 0))
	quit()
