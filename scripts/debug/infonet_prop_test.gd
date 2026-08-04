extends SceneTree

# 資訊網 S-prop TDD（spec 2026-08-04-information-network-whole-HOW Part 1a）。
# 看板 relay hub：訪客抵市集 deposit 自己 team_known 的 order copy→累積異地消息再輻射給後續訪客。
# 修 :79 dead-end（兩隊不需同時共位、先後訪同市集即經看板交換）。守感知鐵律（物理抵 outpost 才 deposit/read）。
# decay 錨既有 SimMessageSystem 公式；純算術零新 randf。

var _fail: int = 0

func _initialize() -> void:
	_test_deposit_known_to_board()      # ①訪客 deposit 自己知的異地單→看板 relayed entry
	_test_second_visitor_reads_relay()  # ②後續訪客讀到 relayed→進 team_known（先後訪即交換、非共位）
	_test_perception_gate_no_outpost()  # ③非市集 outpost→不 deposit/read（感知鐵律）
	_test_expired_relay_pruned()        # ④過期 relayed entry 讀時被 prune
	_test_relay_cap_fifo()              # ⑤relayed 超 cap→FIFO 淘汰最舊
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 市集 outpost tile @(5,5) owner=owner_id；visitor 站上面。
func _mk(owner_id: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.terrain = "plains"
	tile.outpost_type = "civilian"; tile.outpost_level = 1; tile.outpost_owner = owner_id
	state.world.tiles[5 * 1000 + 5] = tile
	return [state, tile]

# 給 team 注入一則親知的 order_buy 消息（模擬別處聽來的異地單）。
func _inject_known_order(state: WorldState, tid: int, oid: int, res: String, origin_team: int, strength: float = 1.0, expire: int = 99999, origin_tick: int = 1000) -> void:
	var m := MessageData.new(); m.id = state.global_messages.size(); m.type = "order_buy"
	m.origin_team_id = origin_team; m.origin_tick = origin_tick; m.strength = strength
	m.params = {"order_id": oid, "res": res, "qty": 50, "origin_team": origin_team, "origin_pos": Vector2i(9, 9), "expire_tick": expire}
	state.global_messages.append(m)
	state.team_known[tid] = state.team_known.get(tid, []) + [m]

func _count_relayed(tile: HexTileData) -> int:
	var n: int = 0
	for e in tile.market_orders:
		if bool(e.get("relayed", false)): n += 1
	return n

# ① 訪客 deposit：visitor(team2) 知道遠方 team9 的 food 買單 → 抵 team1 市集 → 看板出現 relayed entry。
func _test_deposit_known_to_board() -> void:
	print("--- ①deposit 異地單到看板 ---")
	var a := _mk(1); var state: WorldState = a[0]; var tile: HexTileData = a[1]
	var v := TeamData.new(); v.team_id = 2; v.tile_pos = Vector2i(5, 5); state.teams[2] = v
	_inject_known_order(state, 2, 700, "food", 9)
	OrderSystem.new().read_market_board(state, v)
	_ok(_count_relayed(tile) == 1, "訪客 deposit 異地 food 單 → 看板 relayed entry=1（got %d）" % _count_relayed(tile))

# ② 後續訪客讀 relayed：team3 稍後訪同市集 → 讀到 team9 的單進 team_known（先後訪即交換、非共位）。
func _test_second_visitor_reads_relay() -> void:
	print("--- ②後續訪客讀 relayed（非共位交換）---")
	var a := _mk(1); var state: WorldState = a[0]; var tile: HexTileData = a[1]
	var v2 := TeamData.new(); v2.team_id = 2; v2.tile_pos = Vector2i(5, 5); state.teams[2] = v2
	_inject_known_order(state, 2, 700, "food", 9)
	OrderSystem.new().read_market_board(state, v2)   # v2 deposit
	var v3 := TeamData.new(); v3.team_id = 3; v3.tile_pos = Vector2i(5, 5); state.teams[3] = v3
	OrderSystem.new().read_market_board(state, v3)   # v3 讀到 relayed
	var got: int = 0
	for m in state.team_known.get(3, []):
		if m.type == "order_buy" and int(m.params.get("order_id", -1)) == 700: got += 1
	_ok(got == 1, "v3 先後訪同市集 → 讀到 v2 帶來的 team9 異地單（got %d）=修 :79 共位 dead-end" % got)

# ③ 感知鐵律：不在市集 outpost → 不 deposit/read。
func _test_perception_gate_no_outpost() -> void:
	print("--- ③感知鐵律：非 outpost 不 deposit ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 0   # 非 outpost
	state.world.tiles[5 * 1000 + 5] = tile
	var v := TeamData.new(); v.team_id = 2; v.tile_pos = Vector2i(5, 5); state.teams[2] = v
	_inject_known_order(state, 2, 700, "food", 9)
	OrderSystem.new().read_market_board(state, v)
	_ok(_count_relayed(tile) == 0, "非市集 outpost → 不 deposit（無在場、感知鐵律；got %d）" % _count_relayed(tile))

# ④ 過期 relayed entry 讀時 prune。
func _test_expired_relay_pruned() -> void:
	print("--- ④過期 relayed prune ---")
	var a := _mk(1); var state: WorldState = a[0]; var tile: HexTileData = a[1]
	# 手放一個過期 relayed entry
	tile.market_orders.append({"order_id": 800, "kind": "buy", "res": "food", "qty_remaining": 50,
		"origin_team": 9, "expire_tick": 500, "origin_tick": 400, "strength": 1.0, "relayed": true})   # expire 500 < now 1000
	var v := TeamData.new(); v.team_id = 3; v.tile_pos = Vector2i(5, 5); state.teams[3] = v
	OrderSystem.new().read_market_board(state, v)
	_ok(_count_relayed(tile) == 0, "過期 relayed entry 讀時被 prune（got %d）" % _count_relayed(tile))

# ⑤ relayed 超 cap → FIFO 淘汰最舊。
func _test_relay_cap_fifo() -> void:
	print("--- ⑤relay cap FIFO ---")
	var a := _mk(1); var state: WorldState = a[0]; var tile: HexTileData = a[1]
	var v := TeamData.new(); v.team_id = 2; v.tile_pos = Vector2i(5, 5); state.teams[2] = v
	# 注入 CAP+5 則異地單
	for i in range(OrderSystem.BOARD_RELAY_CAP + 5):
		_inject_known_order(state, 2, 1000 + i, "goods", 9)
	OrderSystem.new().read_market_board(state, v)
	_ok(_count_relayed(tile) == OrderSystem.BOARD_RELAY_CAP, "relayed cap=%d（超額 FIFO 淘汰；got %d）" % [OrderSystem.BOARD_RELAY_CAP, _count_relayed(tile)])
