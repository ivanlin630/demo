class_name OutpostOwnerBank

# Pattern B 所有權 banker：tile.outpost_owner 單一 owner(集中化+審計)。
# 本塊保 last-writer-wins(不改 race);race-policy 解析=後續 refinement(有 chokepoint 才好掛)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
static func set_owner(tile: HexTileData, owner: int, reason: String = "") -> void:
	if tile.outpost_owner == owner:
		return
	tile.outpost_owner = owner
	OwnerOutpostIndex.invalidate()   # ★效能 arc B chokepoint①：owner 真變 → owner→outpost 索引失效
	WorldState.record_driver(tile, "outpost_owner", float(owner), reason)
	Probe.bump("g1.outpost_change")
