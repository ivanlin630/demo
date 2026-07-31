extends SceneTree

# 後勤 SLICE A convoy TDD（HOW spec 2026-07-31 訂正版）。
# 驗:①_load_convoy_cargo cargo 守恆(owner+sub+vault total 不變、sub=exact load)
#    ②_deliver_candidates:surplus holder + 知 demand 市場(belief order_buy)→生 TASK_CONVOY deliver candidate。
# 純算術零 RNG。integration(convoy 真派/deposit/fulfilled>0/貨真離賣方) 由和平床 measured 驗(dump)。

var _fail: int = 0

func _initialize() -> void:
	_test_cargo_conservation_topup()
	_test_cargo_conservation_excess_return()
	_test_deliver_candidate_generated()
	_test_no_deliver_when_no_surplus()
	_test_deliver_cargo_sells_capped_conserving()
	_test_inflight_claim_spreads_to_unfilled_order()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

# ── ① cargo 守恆：topup（sub 補到 exact load，from owner inv + vault）──
func _test_cargo_conservation_topup() -> void:
	var owner := TeamData.new(); owner.team_id = 0; owner.tile_pos = Vector2i(0, 0)
	ResourceBank.set_amt(owner, "material", 100.0, "t")
	var sub := TeamData.new(); sub.team_id = 1
	ResourceBank.set_amt(sub, "material", 10.0, "t")
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 0
	tile.public_storage["material"] = 50.0
	var before: float = 100.0 + 10.0 + 50.0
	FactionAISystem.new()._load_convoy_cargo(owner, sub, tile, "material", 80.0)
	var after: float = float(owner.resources.get("material", 0)) + float(sub.resources.get("material", 0)) \
		+ float(tile.public_storage.get("material", 0))
	if abs(float(sub.resources.get("material", 0)) - 80.0) < 0.001 and abs(after - before) < 0.001:
		_ok("cargo topup 守恆:sub=80(exact) total %.0f→%.0f 不變" % [before, after])
	else:
		_bad("cargo topup 破:sub=%.1f total %.0f→%.0f" % [float(sub.resources.get("material", 0)), before, after])

# ── ① cargo 守恆：excess return（sub 有超量 → 退母隊）──
func _test_cargo_conservation_excess_return() -> void:
	var owner := TeamData.new(); owner.team_id = 0; owner.tile_pos = Vector2i(0, 0)
	ResourceBank.set_amt(owner, "material", 20.0, "t")
	var sub := TeamData.new(); sub.team_id = 1
	ResourceBank.set_amt(sub, "material", 100.0, "t")   # 超量
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.outpost_owner = 0
	var before: float = 20.0 + 100.0
	FactionAISystem.new()._load_convoy_cargo(owner, sub, tile, "material", 30.0)
	var after: float = float(owner.resources.get("material", 0)) + float(sub.resources.get("material", 0))
	if abs(float(sub.resources.get("material", 0)) - 30.0) < 0.001 and abs(after - before) < 0.001:
		_ok("cargo excess-return 守恆:sub 100→30 退 70 給母隊 total %.0f 不變" % before)
	else:
		_bad("cargo excess 破:sub=%.1f total %.0f→%.0f" % [float(sub.resources.get("material", 0)), before, after])

# ── ② deliver candidate 生成（surplus + 知 demand 市場）──
func _test_deliver_candidate_generated() -> void:
	var setup: Array = _mk_seller_state(400.0)   # material=400 surplus + 知 buy material 單@(5,5)
	var state: WorldState = setup[0]; var team: TeamData = setup[1]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var cands: Array = GoalResolver._deliver_candidates(state, team, ctx, lv)
	var found: Dictionary = {}
	for c in cands:
		if String(c.get("label", "")).begins_with("deliver_material"):
			found = c; break
	if not found.is_empty() and found.get("to_task", {}).get("task", "") == TeamData.TASK_CONVOY \
			and found["to_task"].get("kind", "") == "deliver" \
			and found["to_task"].get("target", Vector2i.ZERO) == Vector2i(5, 5):
		_ok("deliver_material candidate 生成:TASK_CONVOY→(5,5) util=%.3f" % float(found.get("util", 0)))
	else:
		_bad("deliver_material candidate 未生成(cands=%d)" % cands.size())

# ── ② 無 surplus → 無 deliver candidate ──
func _test_no_deliver_when_no_surplus() -> void:
	var setup: Array = _mk_seller_state(2.0)   # material=2（低於 reserve+margin，無真餘量）
	var state: WorldState = setup[0]; var team: TeamData = setup[1]
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var cands: Array = GoalResolver._deliver_candidates(state, team, ctx, lv)
	var has_mat: bool = false
	for c in cands:
		if String(c.get("label", "")).begins_with("deliver_material"): has_mat = true
	if not has_mat:
		_ok("無 surplus(material=2)→無 deliver_material candidate(不噪音派空車)")
	else:
		_bad("無 surplus 卻生 deliver candidate(空車)")

# ── refine：deliver_cargo 路賣 full cargo（繞 reserve）+ cap 到實有(守恆,不超賣)──
func _test_deliver_cargo_sells_capped_conserving() -> void:
	# porter material=50；owner buy material×100 + coin 充；deliver_cargo=200(>holding)→cap 到 50、守恆。
	var state := WorldState.new()
	var porter := TeamData.new(); porter.team_id = 5
	ResourceBank.set_amt(porter, "material", 50.0, "t")
	state.teams[5] = porter
	var owner := TeamData.new(); owner.team_id = 1; owner.tile_pos = Vector2i(5, 5)
	ResourceBank.set_amt(owner, "coin", 100000.0, "t")
	owner.active_orders = [{"order_id": 42, "res": "material", "kind": "buy", "qty_remaining": 100}]
	state.teams[1] = owner
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.outpost_owner = 1; tile.outpost_level = 1
	tile.resource_cap["material"] = 100000.0
	tile.market_orders = [{"order_id": 42, "res": "material", "kind": "buy", "qty_remaining": 100}]
	state.world.tiles[5005] = tile
	var pmat0: float = float(porter.resources.get("material", 0))
	var gmat0: float = float(tile.public_storage.get("material", 0))
	var ok: bool = InteractionSystem.new()._market_visitor_sell(state, porter, owner, tile, 42, "material", 100, {}, 200.0)
	var sold: float = pmat0 - float(porter.resources.get("material", 0))
	var deposited: float = float(tile.public_storage.get("material", 0)) - gmat0
	# deliver_cargo=200>holding 50 → 賣≤50(cap 實有,不超賣);守恆:porter 減 == tile granary 增
	if ok and sold > 0.0 and sold <= 50.0 + 0.001 and abs(sold - deposited) < 0.001:
		_ok("deliver_cargo 賣 full cargo cap 實有:sold=%.0f(≤50)、porter−==granary+ 守恆" % sold)
	else:
		_bad("deliver_cargo 賣/守恆破:ok=%s sold=%.1f deposited=%.1f" % [str(ok), sold, deposited])

# ── flow-fix：in-flight LIVE-SCAN 認領滿的單被跳過，deliver candidate 散到未填單 ──
func _test_inflight_claim_spreads_to_unfilled_order() -> void:
	# seller material=400；兩 buy material 單:X@(5,5) qty=64、Y@(7,7) qty=64。
	# 一在途 convoy porter 認領 X（order_id=X, cargo_qty=64=填滿）→ candidate 應散到 Y（非再堆 X）。
	var setup: Array = _mk_seller_state(400.0)   # team_known 已含 X@(5,5) order_id=42
	var state: WorldState = setup[0]; var team: TeamData = setup[1]
	# 加第二買單 Y@(7,7) order_id=43
	var msgY := MessageData.new()
	msgY.type = "order_buy"
	msgY.params = {"res": "material", "qty": 64, "origin_team": 2,
		"origin_pos": Vector2i(7, 7), "order_id": 43}
	state.team_known[0].append(msgY)
	# 在途 convoy porter 認領 X（order_id=42, cargo_qty=64 填滿 X）
	var porter := TeamData.new(); porter.team_id = 99; porter.parent_team_id = 0
	porter.current_task = TeamData.TASK_CONVOY
	porter.task_extra_data = {"convoy_phase": "OUTBOUND", "cargo_res": "material",
		"cargo_qty": 64.0, "order_id": 42}
	state.teams[99] = porter
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var cands: Array = GoalResolver._deliver_candidates(state, team, ctx, lv)
	# X(42) 被在途認領滿(eff_rem=64−64=0)→跳;candidate 應 target Y@(7,7)
	var tgt := Vector2i(-999, -999); var toid := -1
	for c in cands:
		if String(c.get("label", "")).begins_with("deliver_material"):
			tgt = c.get("to_task", {}).get("target", Vector2i(-999, -999))
			toid = int(c.get("to_task", {}).get("order_id", -1))
	if tgt == Vector2i(7, 7) and toid == 43:
		_ok("in-flight 認領滿的 X(42) 跳過 → candidate 散到未填 Y@(7,7) order 43（LIVE-SCAN 散單）")
	else:
		_bad("未散到未填單:target=%s oid=%d（應 (7,7)/43）" % [str(tgt), toid])

# 建賣方 state：team0 material=X + team_known 有 buy material 單@(5,5) origin_team=1。
func _mk_seller_state(mat: float) -> Array:
	var state := WorldState.new()
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(1, 1)
	ResourceBank.set_amt(team, "material", mat, "t")
	ResourceBank.set_amt(team, "coin", 200.0, "t")
	var leader := PersonData.new(); leader.id = 1; leader.team_id = 0
	leader.values = {"慎重": 0.5, "野心": 0.5, "貪婪": 0.5}
	team.leader_id = leader.id
	state.persons[leader.id] = leader
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)   # pop=leader1+anon5=6 ≥ CONVOY_MIN_PARENT_POP(4) 過 perf 前閘
	state.teams[0] = team
	# demand 市場 belief：team_known 注 buy material 單@(5,5)
	var msg := MessageData.new()
	msg.type = "order_buy"
	msg.params = {"res": "material", "qty": 64, "origin_team": 1,
		"origin_pos": Vector2i(5, 5), "order_id": 42}
	state.team_known[0] = [msg]
	return [state, team]

func _ok(m: String) -> void: print("  [PASS] " + m)
func _bad(m: String) -> void:
	_fail += 1
	print("  [FAIL] " + m)
