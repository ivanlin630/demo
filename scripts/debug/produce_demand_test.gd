extends SceneTree

# produce_need demand-responsive TDD（spec 2026-07-23-produce-need-demand-responsive）。
# 製造 bootstrap 子根②:「生產」util 死常數 0.3/0.6(不隨市場)→ workshop 隊沒選生產→產 0。
# 2 修:①decision_context c.produce_pull=自家可造 outputs 的 belief demand-responsive worst-shortfall
#   (target=need_keep+demand[★親聞單],hold=resources+public_storage,max ratio) ②terms produce_need→ctx.produce_pull。
# ★感知鐵律:demand()=_trade_demand 讀 team_known 親聞單(非 global order book)。

var _fail: int = 0

func _initialize() -> void:
	_test_heard_order_high()      # ①有 workshop+聽到 tools 買單→produce_pull 高
	_test_no_demand_zero()        # ②有 workshop+無需無市場→produce_pull=0
	_test_no_facility_zero()      # ③無 manufacturing facility→produce_pull=0
	_test_term_reads_pull()       # ④produce_need term=ctx.produce_pull(opt≠生產→0)
	_test_perception_gate()       # ★⑤god-view:他隊有單但本隊沒聽到→produce_pull 不含
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# workshop 隊（civilian outpost + manufacturing_level=1）。★所有 workshop output(tools/arrows/wagons)hold 灌高
# 蓋自用+construction baseline → baseline produce_pull=0；heard order 的 demand 才造 gap（隔離 demand-responsive）。
func _mk(with_workshop: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 8):
		for y in range(3, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 15)
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.5, "貪婪": 0.5, "野心": 0.5, "慎重": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	# workshop outputs 全灌高 hold → baseline(self_use+construction)ratio 0；tools 靠 heard order demand 才抬。
	team.resources["tools"] = 10000.0
	team.resources["arrows"] = 10000.0
	team.resources["wagons"] = 10000.0
	team.resources["food"] = 500.0       # 不餓（避 survival 干擾；本測只讀 produce_pull）
	state.teams[1] = team
	if with_workshop:
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = "civilian"; tile.outpost_level = 1
		tile.set("manufacturing_level", 1)
	return [state, team]

func _heard_tools_order(state: WorldState, hearer_team_id: int, qty: int) -> void:
	var m := MessageData.new(); m.type = "order_buy"
	m.params = {"res": "tools", "origin_team": 99, "expire_tick": 99999, "qty": qty}
	state.team_known[hearer_team_id] = [m]

# ① 有 workshop + 聽到 tools 買單（demand(tools) 大）→ produce_pull 高
func _test_heard_order_high() -> void:
	print("--- ①聽到 tools 單→produce_pull 高 ---")
	var w: Array = _mk(true)
	_heard_tools_order(w[0], 1, 100000)   # 本隊(1)親聞大 tools 買單 → demand >> hold → gap
	var c: DecisionContext = DecisionContext.gather(w[0], w[1])
	_ok(c.produce_pull > 0.5, "有 workshop+聽到 tools 買單 → produce_pull 高（demand-responsive，got %.2f）" % c.produce_pull)

# ② 有 workshop + 無需 + 無市場 → produce_pull=0
func _test_no_demand_zero() -> void:
	print("--- ②無需無市場→produce_pull=0 ---")
	var w: Array = _mk(true)   # 無 heard order；tools/arrows hold=self_use → baseline ratio 0
	var c: DecisionContext = DecisionContext.gather(w[0], w[1])
	_ok(c.produce_pull == 0.0, "有 workshop 但無 demand → produce_pull=0（goods 不亂產，got %.2f）" % c.produce_pull)

# ③ 無 manufacturing facility → produce_pull=0（生產 not applicable 不變）
func _test_no_facility_zero() -> void:
	print("--- ③無 facility→produce_pull=0 ---")
	var w: Array = _mk(false)   # 無 outpost/facility
	_heard_tools_order(w[0], 1, 50)   # 即使聽到單，無設施也不驅（不能造）
	var c: DecisionContext = DecisionContext.gather(w[0], w[1])
	_ok(c.produce_pull == 0.0, "無 manufacturing facility → produce_pull=0（沒設施聽到也不產，got %.2f）" % c.produce_pull)

# ④ produce_need term = ctx.produce_pull（opt≠生產→0）
func _test_term_reads_pull() -> void:
	print("--- ④produce_need term=ctx.produce_pull ---")
	var ctx := DecisionContext.new()
	ctx.produce_pull = 0.7
	_ok(is_equal_approx(DecisionTerms.eval("produce_need", ctx, "生產"), 0.7), "produce_need(生產)=ctx.produce_pull 0.7")
	_ok(DecisionTerms.eval("produce_need", ctx, "建設") == 0.0, "produce_need(建設)=0（opt≠生產）")

# ★⑤ god-view：他隊有 tools 買單但本隊 team_known 沒聽到 → produce_pull 不含（感知鐵律硬驗）
func _test_perception_gate() -> void:
	print("--- ★⑤感知鐵律:沒聽到→produce_pull 不含 ---")
	var w: Array = _mk(true)
	_heard_tools_order(w[0], 99, 50)   # 單只進「他隊(99)」的 team_known，本隊(1)沒聽到
	# 本隊 team_known[1] 空 → demand(tools)=0 → tools baseline ratio 0 → produce_pull 0（god-view 讀 global 會 >0）
	var c: DecisionContext = DecisionContext.gather(w[0], w[1])
	_ok(c.produce_pull == 0.0, "他隊有 tools 單但本隊沒聽到 → produce_pull=0（perception-gate，god-view 會 >0，got %.2f）" % c.produce_pull)
