class_name CoinAudit

# 全 coin 池求和（純 coin，不含 ore）。
# ore_gold/ore_silver 是「採集產出」(productivity×skill 乘數 → 非守恆量，見 resource_system 採集)，
# 不可當 coin-equivalent；coin 唯一來源 = 鑄幣(mint)。
# 守恆律：CoinAudit.total(end) − CoinAudit.total(start) == Σ minted（本 run 鑄出 coin）。
# 池：team.resources.coin + team.anon_treasury + person.coin + tile.public_storage.coin + tile.abandoned_coin。
static func total(state: WorldState) -> float:
	var sum: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		sum += float(t.resources.get("coin", 0)) + t.anon_treasury
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		sum += float(p.coin)
	for tkey in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tkey]
		sum += float(tile.public_storage.get("coin", 0)) + float(tile.abandoned_coin)
	return sum
