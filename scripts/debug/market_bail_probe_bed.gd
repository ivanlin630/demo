extends SceneTree

# market_bail_probe_bed（unified-commerce專版）：拆_resolve_market_at_outpost的29筆meet_nodeal
# bail因佔比。純唯讀複刻_market_visitor_buy/_market_visitor_sell判準,不執行transfer,不寫state。
# 用法：MBP_SEED（default 1337）MBP_MONTHS（default 12）

func _initialize() -> void:
	_run(); quit()

var _bail: Dictionary = {}
var _samples: Array = []

func _run() -> void:
	var world_seed: int = int(OS.get_environment("MBP_SEED")) if OS.has_environment("MBP_SEED") else 1337
	var months: int = int(OS.get_environment("MBP_MONTHS")) if OS.has_environment("MBP_MONTHS") else 12
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== market_bail_probe_bed: seed=%d months=%d ===" % [world_seed, months])
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		_scan(state, tick)
		if state.teams.is_empty():
			break
	print("[MBP-summary] bail因分布: %s" % str(_bail))
	print("[MBP-samples] 前30筆:")
	for s in _samples.slice(0, 30):
		print("  " + str(s))
	SimRunner.force_full_hd = false
	Probe.enabled = false
	print("=== DONE ===")

func _scan(state: WorldState, tick: int) -> void:
	for tid in state.teams:
		var visitor: TeamData = state.teams[tid]
		if visitor.current_task != TeamData.TASK_TRADE:
			continue
		var tile_id: int = visitor.tile_pos.x * 1000 + visitor.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile == null or tile.outpost_level <= 0:
			continue
		var owner_id: int = tile.outpost_owner
		if owner_id == visitor.team_id or owner_id < 0:
			continue
		var owner: TeamData = state.teams.get(owner_id)
		if owner == null:
			continue
		if tile.market_orders.is_empty():
			_bump("no_orders_on_board")
			continue
		var reason: String = _diag_visitor(state, visitor, owner, tile)
		_bump(reason)
		if _samples.size() < 30:
			_samples.append({"tick": tick, "visitor": tid, "owner": owner_id, "reason": reason})

# 逐market_orders entry判bail，回傳「最不遠」的一個原因（第一個非no_coin/qty0以外能達成的即WOULD_TRADE）
func _diag_visitor(state: WorldState, visitor: TeamData, owner: TeamData, tile: HexTileData) -> String:
	var s_leader = state.persons.get(owner.leader_id)
	var commerce: float = float(s_leader.skills.get("商業", 0.0)) if s_leader else 0.0
	var owner_lv: Dictionary = TradeValuation.leader_vals(state, owner)
	var visitor_coin: float = float(visitor.resources.get("coin", 0))
	var owner_coin: float = float(owner.resources.get("coin", 0))
	var any_stock_empty: bool = false
	var any_visitor_no_coin: bool = false
	var any_owner_no_coin: bool = false
	var any_no_want: bool = false
	var any_no_surplus: bool = false
	var any_qty_zero: bool = false
	var had_entry: bool = false
	for entry in tile.market_orders:
		var rem: int = int(entry["qty_remaining"])
		if rem <= 0:
			continue
		had_entry = true
		var res: String = String(entry["res"])
		var kind: String = String(entry["kind"])
		if kind == "sell":
			if visitor_coin <= 0.0:
				any_visitor_no_coin = true
				continue
			var ask: float = TradeValuation.ask_price(owner, res, commerce, owner_lv, state)
			if ask <= 0.0:
				continue
			var stock: float = TileBank.get_stored(tile, res)
			if stock <= 0.0:
				any_stock_empty = true
				continue
			var want: float = maxf(TradeValuation.reserve(visitor, res, TradeValuation.leader_vals(state, visitor), state)
				- ResourceSystem.effective_holding(state, visitor, res), 0.0)
			if want <= 0.0:
				any_no_want = true
				continue
			var qty: int = int(minf(minf(float(rem), stock), minf(visitor_coin / ask, want)))
			if qty <= 0:
				any_qty_zero = true
				continue
			return "WOULD_TRADE_buy(%s)" % res
		elif kind == "buy":
			if owner_coin <= 0.0:
				any_owner_no_coin = true
				continue
			var surplus: float = maxf(ResourceSystem.effective_holding(state, visitor, res)
				- TradeValuation.reserve(visitor, res, TradeValuation.leader_vals(state, visitor), state), 0.0)
			if surplus <= 0.0:
				any_no_surplus = true
				continue
			var bid: float = TradeValuation.local_value(owner, res, state)
			if bid <= 0.0:
				continue
			var qty2: int = int(minf(minf(float(rem), surplus), owner_coin / bid))
			if qty2 <= 0:
				any_qty_zero = true
				continue
			return "WOULD_TRADE_sell(%s)" % res
	if not had_entry:
		return "all_orders_zero_remaining"
	if any_visitor_no_coin: return "visitor_no_coin"
	if any_owner_no_coin: return "owner_no_coin"
	if any_stock_empty: return "no_stock"
	if any_no_want: return "visitor_no_want(reserve已滿足)"
	if any_no_surplus: return "visitor_no_surplus"
	if any_qty_zero: return "qty_zero_other"
	return "unknown"

func _bump(k: String) -> void:
	_bail[k] = int(_bail.get(k, 0)) + 1
