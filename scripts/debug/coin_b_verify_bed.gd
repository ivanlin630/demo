extends SceneTree

# coin_b_verify_bed（unified-commerce branch專版）：absorb/spill_back已被統一框架移除
# （_resolve_market_at_outpost取代），本版拿掉依賴那兩個函式的bail掃描，只留headline：
# coin census雙向流動 + funnel deal/order_fulfilled + 死亡安全 + 守恆。純觀測不寫state。
# 用法：CBV_SEED（default 1337）CBV_MONTHS（default 6）

func _initialize() -> void:
	_run(); quit()

var _prev_probe: Dictionary = {}

func _run() -> void:
	var world_seed: int = int(OS.get_environment("CBV_SEED")) if OS.has_environment("CBV_SEED") else 1337
	var months: int = int(OS.get_environment("CBV_MONTHS")) if OS.has_environment("CBV_MONTHS") else 6
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== coin_b_verify_bed(unified-commerce專版): seed=%d months=%d ===" % [world_seed, months])
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var coin_start: float = CoinAudit.total(state)
	print("[CoinAudit] start total=%.4f" % coin_start)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			_print_month(state, (tick + 1) / WorldState.TICKS_PER_MONTH)
		if state.teams.is_empty():
			print("[bed] tick=%d 全滅提早結束" % tick)
			break
	var coin_end: float = CoinAudit.total(state)
	print("[CoinAudit] end total=%.4f delta=%.4f（無鑄幣機制應=0）" % [coin_end, coin_end - coin_start])
	var inv: Array = InvariantAudit.check(state)
	print("[InvariantAudit] violations=%d %s" % [inv.size(), str(inv)])
	print("[funnel-final] order_fulfilled=%d arb_hit=%d deal=%d deal_market=%d deal_merchant=%d deal_resident=%d barter_deal=%d meet=%d meet_nodeal=%d" % [
		_c("g1.order_fulfilled"), _c("g1.arb_hit"), _c("trade.deal"), _c("trade.deal_market"), _c("trade.deal_merchant"), _c("trade.deal_resident"),
		_c("trade.barter_deal"), _c("trade.meet"), _c("trade.meet_nodeal")])
	var bail_final: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("trade.market_bail."):
			bail_final[k] = int(Probe.counts[k])
	print("[market_bail-final] %s" % str(bail_final))
	print("[death-final] starve_minor=%d starve_anon=%d combat_pop=%d combat_named=%d defect_leave=%d" % [
		_c("death.starve_minor"), _c("death.starve_anon"), _c("death.combat_pop"), _c("death.combat_named"), _c("death.defect_leave")])
	SimRunner.force_full_hd = false
	Probe.enabled = false
	print("=== DONE ===")

func _print_month(state: WorldState, month: int) -> void:
	var cur: Dictionary = Probe.counts.duplicate(true)
	var delta: Dictionary = {}
	for k in cur:
		if String(k).begins_with("trade.") or String(k).begins_with("g1."):
			var d: int = int(cur[k]) - int(_prev_probe.get(k, 0))
			if d != 0:
				delta[k] = d
	_prev_probe = cur
	var team_pool: float = 0.0
	var treasury: float = 0.0
	var person_pool: float = 0.0
	var tile_pool: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		team_pool += float(t.resources.get("coin", 0))
		treasury += t.anon_treasury
	for pid in state.persons:
		person_pool += state.persons[pid].coin
	for tkey in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tkey]
		tile_pool += float(tile.public_storage.get("coin", 0)) + tile.abandoned_coin
	print("[月%d coin_census] team_pool=%.2f treasury=%.2f person_pool=%.2f tile_pool=%.2f total=%.2f" % [
		month, team_pool, treasury, person_pool, tile_pool, team_pool + treasury + person_pool + tile_pool])
	print("[月%d trade_delta] %s" % [month, str(delta)])

func _c(key: String) -> int:
	return int(Probe.counts.get(key, 0))
