class_name OutpostOwnerBank

# Pattern B 所有權 banker：tile.outpost_owner 單一 owner(集中化+審計)。
# 本塊保 last-writer-wins(不改 race);race-policy 解析=後續 refinement(有 chokepoint 才好掛)。
static func set_owner(tile: HexTileData, owner: int, reason: String = "") -> void:
	if tile.outpost_owner == owner:
		return
	tile.outpost_owner = owner
	Probe.bump("g1.outpost_change")
