extends SceneTree

# god-view Slice C TDD（spec 2026-07-20-godview-slice-C）。
# 市場全圖掃(_nearest_market_outpost)=god-view → market-discovery belief store(team_market_known)+belief-gate。
# 三源：創世-nearby / 直接親見(vision) / relay harvest(order/outpost_built 訊息,濾 outpost_level>0)。
# 貿易 to_task：roaming 無市集→IDLE;resident 擺攤(-1,-1)保 TASK_TRADE。cleanup 只 demolish 清、capture 不清。

var _fail: int = 0

func _initialize() -> void:
	_test_creation_nearby_known()      # ① 創世-nearby 市集 known
	_test_direct_vision_known()        # ② 直接親見 outpost→known
	_test_relay_harvest_known()        # ③ relay harvest（濾 outpost_level>0）
	_test_belief_gate_nearest()        # ④ _nearest 只回 known、未知不回
	_test_demolish_clears_capture_keeps() # ⑤ demolish 清、capture 不清
	_test_trade_guard_roaming_vs_resident() # ⑥ roaming→IDLE / resident 保 TRADE
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

func _grid(state: WorldState) -> void:
	for x in range(-2, 14):
		for y in range(-2, 14):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl

func _outpost(state: WorldState, pos: Vector2i, owner: int, level: int = 1) -> HexTileData:
	var tid: int = pos.x * 1000 + pos.y
	var t: HexTileData = state.world.tiles[tid]
	t.outpost_level = level; t.outpost_owner = owner
	return t

func _team(state: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5); state.teams[tid] = t
	return t

# ① 創世-nearby：team @0,0；市集 @2,0(近≤3) known、@10,0(遠>3) 不
func _test_creation_nearby_known() -> void:
	print("--- ① 創世-nearby 市集 known ---")
	var s := WorldState.new(); s.world = WorldData.new(); _grid(s)
	_team(s, 1, Vector2i(0, 0))
	_outpost(s, Vector2i(2, 0), 9)    # 近市集（他人 owner）
	_outpost(s, Vector2i(10, 0), 9)   # 遠市集
	GameSetup._seed_creation_market_known(s)
	var known: Dictionary = s.team_market_known.get(1, {})
	_ok(known.has(2 * 1000 + 0), "近市集(2,0)創世 known（proximity≤3）")
	_ok(not known.has(10 * 1000 + 0), "遠市集(10,0)不 known（>3，非全知）")

# ② 直接親見：team 移到市集 vision 半徑內 → harvest 加 known
func _test_direct_vision_known() -> void:
	print("--- ② 直接親見 outpost→known ---")
	var s := WorldState.new(); s.world = WorldData.new(); _grid(s)
	var t := _team(s, 1, Vector2i(5, 5))
	_outpost(s, Vector2i(6, 5), 9)   # vision 半徑(3)內
	FactionAISystem.new()._harvest_market_known(s, t)
	_ok(s.team_market_known.get(1, {}).has(6 * 1000 + 5), "vision 半徑內 outpost→直接親見 known")

# ③ relay harvest：team_known 有 order 訊息帶 origin_pos(真市集) → known;無 outpost 的 pos noise 不 harvest
func _test_relay_harvest_known() -> void:
	print("--- ③ relay harvest（濾 outpost_level>0）---")
	var s := WorldState.new(); s.world = WorldData.new(); _grid(s)
	var t := _team(s, 1, Vector2i(0, 0))
	_outpost(s, Vector2i(9, 9), 5)   # 遠市集（relay 得知）
	# order 訊息帶 origin_pos=真市集(9,9)
	var m1 := MessageData.new(); m1.type = "order_buy"; m1.params = {"origin_pos": Vector2i(9, 9)}
	# order 訊息 origin_pos=(3,3) 但該 tile 無 outpost → noise 不 harvest
	var m2 := MessageData.new(); m2.type = "order_sell"; m2.params = {"origin_pos": Vector2i(3, 3)}
	s.team_known[1] = [m1, m2]
	FactionAISystem.new()._harvest_market_known(s, t)
	var known: Dictionary = s.team_market_known.get(1, {})
	_ok(known.has(9 * 1000 + 9), "relay order origin_pos 真市集(9,9)→known")
	_ok(not known.has(3 * 1000 + 3), "無 outpost 的 origin_pos(3,3)→noise 不 harvest（濾 outpost_level>0）")

# ④ belief-gate：_nearest 只回 known 中最近；未知市集不回
func _test_belief_gate_nearest() -> void:
	print("--- ④ _nearest 只回 known、未知不回 ---")
	var s := WorldState.new(); s.world = WorldData.new(); _grid(s)
	var t := _team(s, 1, Vector2i(0, 0))
	_outpost(s, Vector2i(5, 0), 9)   # 已知市集
	_outpost(s, Vector2i(1, 0), 9)   # ★未知市集（更近但不在 known）
	s.team_market_known[1] = {5 * 1000 + 0: true}   # 只知(5,0)（不含近的(1,0)）
	# harvest 會加 vision 半徑內(1,0)——為隔離測 belief-gate，把 team 放遠離(1,0)vision
	t.tile_pos = Vector2i(0, 8)
	s.team_market_known[1] = {5 * 1000 + 0: true}   # 重設（清 harvest 汙染）
	var mkt: Vector2i = FactionAISystem.new()._nearest_market_outpost(s, t)
	_ok(mkt == Vector2i(5, 0), "回 known 中(5,0)；未知(1,0)不選（belief-gate 非全圖，got %s）" % str(mkt))
	# 無任何 known → (-1,-1)
	var s2 := WorldState.new(); s2.world = WorldData.new(); _grid(s2)
	var t2 := _team(s2, 1, Vector2i(0, 9))
	_outpost(s2, Vector2i(5, 9), 9)   # 存在但未 known + 離 vision 遠
	var mkt2: Vector2i = FactionAISystem.new()._nearest_market_outpost(s2, t2)
	_ok(mkt2 == Vector2i(-1, -1), "無 known 市集→(-1,-1)（非全圖掃到，got %s）" % str(mkt2))

# ⑤ demolish 清所有隊 known;capture(owner 變)不清
func _test_demolish_clears_capture_keeps() -> void:
	print("--- ⑤ demolish 清、capture 不清 ---")
	var s := WorldState.new(); s.world = WorldData.new(); _grid(s)
	var tile := _outpost(s, Vector2i(4, 4), 9)
	var tid4: int = 4 * 1000 + 4
	s.team_market_known[1] = {tid4: true}
	s.team_market_known[2] = {tid4: true}
	# capture：owner 9→7（市集還在 level>0）→ known 不清（_nearest 仍回）
	tile.outpost_owner = 7
	var t1 := _team(s, 1, Vector2i(4, 6))
	_ok(FactionAISystem.new()._nearest_market_outpost(s, t1) == Vector2i(4, 4), "capture(換老闆)後市集仍 known/回（習得後穩定）")
	_ok(s.team_market_known.get(2, {}).has(tid4), "capture 不清 team2 known")
	# demolish：construction_target action=demolish → _complete_construction → 清所有隊 known
	tile.construction_target = {"action": "demolish"}
	var builder := _team(s, 9, Vector2i(4, 4))
	OutpostSystem.new()._complete_construction(s, tile, builder)
	_ok(not s.team_market_known.get(1, {}).has(tid4), "demolish→清 team1 known（市集拆了都該忘）")
	_ok(not s.team_market_known.get(2, {}).has(tid4), "demolish→清 team2 known（tile 級所有隊）")

# ⑥ 貿易 to_task：roaming 無市集→IDLE;resident 擺攤(-1,-1)保 TASK_TRADE
func _test_trade_guard_roaming_vs_resident() -> void:
	print("--- ⑥ roaming→IDLE / resident 保 TRADE ---")
	var to_task: Callable = DecisionOptions.REGISTRY["貿易"]["to_task"]
	# roaming merchant：無 PRODUCE、無 known 市集 → target -1 → 非-resident → IDLE
	var s := WorldState.new(); s.world = WorldData.new(); _grid(s)
	var rm := _team(s, 1, Vector2i(0, 9))
	var r1: Dictionary = to_task.call(s, rm)
	_ok(r1["task"] == TeamData.TASK_IDLE, "roaming 無市集→IDLE（got '%s')" % r1["task"])
	# resident 擺攤：PRODUCE + 站自家 outpost → is_resident → 即使 target -1 保 TASK_TRADE（村攤不關門）
	var s2 := WorldState.new(); s2.world = WorldData.new(); _grid(s2)
	var res := _team(s2, 1, Vector2i(3, 3))
	res.tags = [TeamData.TAG_PRODUCE]
	var ot := _outpost(s2, Vector2i(3, 3), 1)   # 自家 outpost（owner==team）
	var _unused = ot
	var r2: Dictionary = to_task.call(s2, res)
	_ok(r2["task"] == TeamData.TASK_TRADE, "resident 擺攤(-1,-1)保 TASK_TRADE（村攤不關門，got '%s')" % r2["task"])
