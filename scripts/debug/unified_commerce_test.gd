extends SceneTree

# 統一商業框架 TDD（unified-commerce，market-as-place）
# spec: docs/superpowers/specs/2026-07-15-unified-commerce-framework.md
# M2 到場 resolver _resolve_market_at_outpost：owner-mediated，訪客買 owner sell 單(coin→owner)/
# 賣入 owner buy 單(owner.coin→visitor)；order_id 直沖；min(單餘,現貨);無單不賣;SURVIVAL 有單才賣;守恆。

var _fail: int = 0

func _initialize() -> void:
	_test_visitor_buy_from_stock()
	_test_visitor_sell_to_buyorder()
	_test_order_id_direct_settle()
	_test_survival_no_order_no_sell()
	_test_conservation()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_person(state: WorldState, id: int, vals: Dictionary = {}) -> void:
	var p := PersonData.new(); p.id = id; p.values = vals; p.skills = {}
	state.persons[id] = p

func _mk_team(state: WorldState, tid: int, leader_id: int, pop: int, res: Dictionary) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.leader_id = leader_id
	t.resources = res.duplicate()
	for i in range(pop - 1):
		t.named_members.append(tid * 100 + i)
	state.teams[tid] = t
	return t

# owner outpost tile：public_storage stock + board sell/buy 單（＝owner active_orders 鏡像）。
func _mk_outpost(state: WorldState, owner_id: int, pos: Vector2i, storage: Dictionary, orders: Array) -> HexTileData:
	var tile := HexTileData.new()
	tile.tile_pos = pos; tile.outpost_level = 1; tile.outpost_owner = owner_id
	tile.public_storage = storage.duplicate()
	tile.market_orders = orders.duplicate(true)
	state.world.tiles[pos.x * 1000 + pos.y] = tile
	return tile

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 0
	return s

# ── TDD1：訪客到市場 outpost → 向 stock 買（deal fire，扣 storage，coin→owner，守恆）──
func _test_visitor_buy_from_stock() -> void:
	print("--- TDD1：訪客買 owner sell 單/stock（coin→owner）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0, "material": 100.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	# owner 掛 sell material ×80（board + active_orders 權威）
	var sell_order := {"order_id": 42, "kind": "sell", "res": "material", "qty_remaining": 80}
	owner.active_orders.append(sell_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"material": 100.0}, [sell_order])
	var owner_coin0: float = float(owner.resources.get("coin", 0))
	var vis_mat0: float = float(visitor.resources.get("material", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(float(visitor.resources.get("material", 0)) > vis_mat0, "訪客得 material（%.0f→%.0f）" % [vis_mat0, float(visitor.resources.get("material", 0))])
	_ok(float(owner.resources.get("coin", 0)) > owner_coin0, "owner 得 coin（%.0f→%.0f，coin→owner）" % [owner_coin0, float(owner.resources.get("coin", 0))])
	_ok(float(tile.public_storage.get("material", 0)) < 100.0, "public_storage material 扣減（%.0f）" % float(tile.public_storage.get("material", 0)))

# ── TDD2：★訪客賣 → 向 owner buy 單賣（貨入 storage，owner.coin→visitor，套利閉合）──
func _test_visitor_sell_to_buyorder() -> void:
	print("--- TDD2：★訪客賣入 owner buy 單（owner.coin→visitor）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 500.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 0.0, "goods": 60.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	var buy_order := {"order_id": 43, "kind": "buy", "res": "goods", "qty_remaining": 40}
	owner.active_orders.append(buy_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {}, [buy_order])
	var vis_coin0: float = float(visitor.resources.get("coin", 0))
	var owner_coin0: float = float(owner.resources.get("coin", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(float(visitor.resources.get("coin", 0)) > vis_coin0, "★訪客賣得 coin（%.0f→%.0f，套利閉合）" % [vis_coin0, float(visitor.resources.get("coin", 0))])
	_ok(float(owner.resources.get("coin", 0)) < owner_coin0, "owner.coin 付出（%.0f→%.0f）" % [owner_coin0, float(owner.resources.get("coin", 0))])
	_ok(float(tile.public_storage.get("goods", 0)) > 0.0, "貨入 public_storage（%.0f）" % float(tile.public_storage.get("goods", 0)))

# ── TDD3：履約 order_id 直沖（成交即沖 active_orders + board，不掛幽靈）──
func _test_order_id_direct_settle() -> void:
	print("--- TDD3：order_id 直沖 active_orders + board ---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	var sell_order := {"order_id": 42, "kind": "sell", "res": "material", "qty_remaining": 30}
	owner.active_orders.append(sell_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"material": 100.0}, [sell_order])
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	# 權威 active_orders qty_remaining 直沖（減少）
	var oid_rem: int = -1
	for o in owner.active_orders:
		if int(o["order_id"]) == 42: oid_rem = int(o["qty_remaining"])
	var board_rem: int = 999
	for e in tile.market_orders:
		if int(e["order_id"]) == 42: board_rem = int(e["qty_remaining"])
	_ok(oid_rem < 30 or oid_rem == -1, "active_orders order_id=42 直沖（qty_remaining=%d，<30 或已移除）" % oid_rem)
	_ok(board_rem < 30, "board entry order_id=42 同步直沖（qty_remaining=%d）" % board_rem)

# ── TDD4：SURVIVAL_GOODS 無單不賣（活命糧不買穿：storage 有 food 但無 sell 單 → 不成交）──
func _test_survival_no_order_no_sell() -> void:
	print("--- TDD4：SURVIVAL 無單不賣（食物不買穿）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	# storage 有 food 但 board 無 food sell 單（只有 material sell 單）
	var mat_order := {"order_id": 50, "kind": "sell", "res": "material", "qty_remaining": 10}
	owner.active_orders.append(mat_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"food": 200.0, "material": 20.0}, [mat_order])
	var food0: float = float(tile.public_storage.get("food", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(absf(float(tile.public_storage.get("food", 0)) - food0) < 0.001, "★food 無 sell 單 → 不賣（storage food %.0f 不動）" % float(tile.public_storage.get("food", 0)))

# ── TDD5：守恆——成交總 coin + 總 goods 不生不滅 ──
func _test_conservation() -> void:
	print("--- TDD5：市場成交守恆（coin↔goods 只搬）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 200.0, "material": 100.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0, "goods": 50.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	var sell_o := {"order_id": 60, "kind": "sell", "res": "material", "qty_remaining": 50}
	var buy_o := {"order_id": 61, "kind": "buy", "res": "goods", "qty_remaining": 30}
	owner.active_orders.append(sell_o.duplicate()); owner.active_orders.append(buy_o.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"material": 100.0}, [sell_o, buy_o])
	var coin0: float = _tot_coin(owner, visitor, tile)
	var mat0: float = float(owner.resources.get("material", 0)) + float(visitor.resources.get("material", 0)) + float(tile.public_storage.get("material", 0))
	var goods0: float = float(owner.resources.get("goods", 0)) + float(visitor.resources.get("goods", 0)) + float(tile.public_storage.get("goods", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	var coin1: float = _tot_coin(owner, visitor, tile)
	var mat1: float = float(owner.resources.get("material", 0)) + float(visitor.resources.get("material", 0)) + float(tile.public_storage.get("material", 0))
	var goods1: float = float(owner.resources.get("goods", 0)) + float(visitor.resources.get("goods", 0)) + float(tile.public_storage.get("goods", 0))
	_ok(absf(coin1 - coin0) < 0.001, "★總 coin 守恆（%.2f→%.2f）" % [coin0, coin1])
	_ok(absf(mat1 - mat0) < 0.001, "★總 material 守恆（%.2f→%.2f）" % [mat0, mat1])
	_ok(absf(goods1 - goods0) < 0.001, "★總 goods 守恆（%.2f→%.2f）" % [goods0, goods1])

func _tot_coin(owner: TeamData, visitor: TeamData, tile: HexTileData) -> float:
	return float(owner.resources.get("coin", 0)) + float(visitor.resources.get("coin", 0)) + float(tile.public_storage.get("coin", 0))
