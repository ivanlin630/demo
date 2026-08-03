extends SceneTree

# 資訊網 S-trade TDD（spec Part 3 交易面 broaden）。
# 病:_resolve_market_at_outpost 只 owner public_storage 可交易;同格非 owner 私產不可（症 iv 賣不掉）。
# 修:訪客與同格非 owner 隊 peer 交易（任何 store 私產、keep-line=reserve 不空掏、willingness 自 gate）。
# 純算術;keep-line 守經濟不爆。

var _fail: int = 0

func _initialize() -> void:
	_test_peer_trade_private_store()   # ①同格 peer 私產成交（交易面 broaden、症 iv 解）
	_test_keepline_protects()          # ②keep-line：無真剩餘(≤reserve)不賣（經濟不空掏）
	_test_owner_excluded_no_double()   # ③owner 排除（board 已處理、不雙 fire）
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 市集 tile(owner=9 第三方) + 訪客 V(coin、缺 food) + peer P(food 私產剩餘)。
func _mk(p_food: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.terrain = "plains"
	tile.outpost_type = "civilian"; tile.outpost_level = 1; tile.outpost_owner = 9
	state.world.tiles[5*1000+5] = tile
	var V := TeamData.new(); V.team_id = 1; V.faction_id = 0; V.tile_pos = Vector2i(5,5)
	V.current_task = TeamData.TASK_TRADE; V.resources = {"coin": 500.0, "food": 3.0}
	AnonCohort.add(V.anon_cohorts, "平民", "healthy", 10)
	var lv := PersonData.new(); lv.id = 11; lv.values = {"貪婪": 0.5, "慎重": 0.5}; state.persons[11] = lv; V.leader_id = 11
	state.teams[1] = V
	var P := TeamData.new(); P.team_id = 2; P.faction_id = 1; P.tile_pos = Vector2i(5,5)
	P.resources = {"food": p_food, "coin": 0.0}
	AnonCohort.add(P.anon_cohorts, "平民", "healthy", 5)
	var lp := PersonData.new(); lp.id = 12; lp.values = {"貪婪": 0.5, "慎重": 0.5}; state.persons[12] = lp; P.leader_id = 12
	state.teams[2] = P
	return [state, V, P, tile]

# ① 同格 peer 私產成交：P 有 food 剩餘 → V 買到（V.coin↓、food 轉移）=交易面含私產（症 iv 解）。
func _test_peer_trade_private_store() -> void:
	print("--- ①peer 私產成交 ---")
	var a := _mk(1000.0)   # P food 1000（遠超 reserve→大剩餘）
	var state: WorldState = a[0]; var V: TeamData = a[1]; var P: TeamData = a[2]; var tile: HexTileData = a[3]
	var v_food0: float = float(V.resources.get("food", 0)); var v_coin0: float = float(V.resources.get("coin", 0))
	var dealt: bool = InteractionSystem.new()._market_peer_trade(state, V, tile, 9)
	var got_food: bool = float(V.resources.get("food", 0)) > v_food0
	var paid: bool = float(V.resources.get("coin", 0)) < v_coin0
	_ok(dealt and got_food and paid, "V 向同格 peer P 買到 food（Δfood=%.1f Δcoin=%.1f dealt=%s）=交易面含私產" % [
		float(V.resources.get("food",0))-v_food0, float(V.resources.get("coin",0))-v_coin0, str(dealt)])

# ② keep-line：P food 少（≤reserve survival floor）→ 無真剩餘 → 不賣（經濟不空掏活命糧）。
func _test_keepline_protects() -> void:
	print("--- ②keep-line 守 ---")
	var a := _mk(2.0)   # P food 2（pop5 survival floor 內、無剩餘）
	var state: WorldState = a[0]; var V: TeamData = a[1]; var P: TeamData = a[2]; var tile: HexTileData = a[3]
	var p_food0: float = float(P.resources.get("food", 0))
	InteractionSystem.new()._market_peer_trade(state, V, tile, 9)
	_ok(absf(float(P.resources.get("food", 0)) - p_food0) < 0.01, "P food≤reserve → 不賣（keep-line 守活命糧、經濟不空掏；P food %.1f→%.1f）" % [p_food0, float(P.resources.get("food",0))])

# ③ owner 排除：peer pass 跳 owner_id（board 已處理、不雙 fire）。
func _test_owner_excluded_no_double() -> void:
	print("--- ③owner 排除 ---")
	var a := _mk(1000.0)
	var state: WorldState = a[0]; var V: TeamData = a[1]; var P: TeamData = a[2]; var tile: HexTileData = a[3]
	# 把 P 設為 owner → peer pass 應跳過它（不與 owner peer-trade）
	var v_coin0: float = float(V.resources.get("coin", 0))
	var dealt: bool = InteractionSystem.new()._market_peer_trade(state, V, tile, 2)   # owner_id=2=P
	_ok(not dealt and absf(float(V.resources.get("coin",0)) - v_coin0) < 0.01, "owner(P)被 peer pass 排除→不雙 fire（dealt=%s）" % str(dealt))
