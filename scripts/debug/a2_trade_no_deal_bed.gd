extends SceneTree
# @bed-kind: invariant
# ══ 票 A2：貿易等不到對手要記成失敗＋自家市集可與別人的單成交（spec 2026-10-07-a2-trade-that-finds-no-deal-fails-and-releases-HOW.md）══
# 格：P1 Team40（fp 世界 warring_states seed 20260922、無玩家）t9000 之後一天內：不再「帶貿易卡在自家市集、不交易也不放手」
#     P2 自家市集：板上有【別人】的單 ⇒ 成交；★反向：只有【自己】的單 ⇒ 不成交
#     P3 承諾貿易抵達空板市集 ⇒ 同一刻失敗記號＋放手（兩種抵達：move_target＝這格／已被清成 (-1,-1)）；★反向：路過（目的地不是這格）⇒ 不記
#     P4 同一市集連撞兩次無單 ⇒ 「貿易」對那個市集的折價第二次比第一次更低（失敗記憶生效）
#     P6 單一路徑：claim_on_arrival 在模擬碼裡的呼叫點 ＝ 1（入口的自家市集分支拿掉）
# ★走真入口 SimRunner._step3c_read_market_board（不直呼 resolver 判 P3）

const FP_CFG: String = "warring_states"
const FP_SEED: int = 20260922
const P1_TICK: int = 9000
const P1_TEAM: int = 40
const CFG: String = "res://config/default.json"
const SEED: int = 1337

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P3", "P4", "P6"]


func _initialize() -> void:
	print("=== a2_trade_no_deal：貿易等不到對手＝失敗＋自家市集只禁自己的單 ===")
	_p6_single_path()
	_p2_own_market()
	_p3_p4_no_deal()
	_p1_team40()
	var missing: Array = EXPECTED_CELLS.filter(func(c): return not _cells_ran.has(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== a2_trade_no_deal DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


# 找一個有市集的格（outpost_level > 0）與它的主人
static func _market_of(st: WorldState, owner_tid: int) -> HexTileData:
	for k in st.world.tiles:
		var t: HexTileData = st.world.tiles[k]
		if t.outpost_level > 0 and t.outpost_owner == owner_tid:
			return t
	return null


static func _any_market(st: WorldState) -> HexTileData:
	var keys: Array = st.world.tiles.keys()
	keys.sort()
	for k in keys:
		var t: HexTileData = st.world.tiles[k]
		if t.outpost_level > 0 and t.outpost_owner != -1 and st.teams.has(t.outpost_owner):
			return t
	return null


# 把同格的其他隊搬走（避免 peer 交易混進「有沒有成交」）
static func _clear_tile(st: WorldState, tile: HexTileData, keep: Array) -> void:
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if keep.has(int(tid)):
			continue
		if t.tile_pos == tile.tile_pos:
			t.tile_pos = tile.tile_pos + Vector2i(3, 3)


# ══ P6 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p6_single_path() -> void:
	print("\n── P6 claim_on_arrival 的呼叫點 ──")
	var hits: Array = []
	for f in ["res://scripts/simulation/sim_runner.gd", "res://scripts/simulation/interaction_system.gd"]:
		var lines: PackedStringArray = FileAccess.get_file_as_string(f).split("\n")
		for i in range(lines.size()):
			var l: String = lines[i].strip_edges()
			if l.begins_with("#") or l.contains("func claim_on_arrival"):
				continue
			if l.contains("claim_on_arrival("):
				hits.append("%s:%d" % [f.get_file(), i + 1])
	print("   呼叫點：%s" % str(hits))
	_check("P6 claim_on_arrival 呼叫點 ＝ 1（%d）" % hits.size(), hits.size() == 1)
	_cells_ran.append("P6")


# ══ P2 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p2_own_market() -> void:
	print("\n── P2 自家市集：別人的單成交、自己的單不成交 ──")
	var rows: Array = []
	for whose in ["other", "own"]:
		seed(SEED)
		var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, true)
		var tile: HexTileData = _any_market(st)
		if tile == null:
			_check("★不可判：找不到有主人的市集", false)
			_cells_ran.append("P2")
			return
		var owner: TeamData = st.teams[tile.outpost_owner]
		var other_id: int = -1
		for tid in st.teams:
			if int(tid) != owner.team_id:
				other_id = int(tid)
				break
		owner.tile_pos = tile.tile_pos
		owner.current_task = TeamData.TASK_TRADE
		owner.current_option = "貿易"
		owner.move_target = tile.tile_pos
		owner.resources["food"] = 2000.0
		owner.resources["coin"] = 500.0
		_clear_tile(st, tile, [owner.team_id])
		tile.market_orders.clear()
		tile.market_orders.append({"order_id": 990001, "kind": "buy", "res": "food", "qty_remaining": 20,
			"origin_team": other_id if whose == "other" else owner.team_id, "expire_tick": st.world.current_tick + 9999,
			"origin_tick": st.world.current_tick, "strength": 1.0, "relayed": whose == "other", "price": 2.0})
		var dealt: bool = InteractionSystem.new()._resolve_market_at_outpost(st, owner, tile)
		print("   板上只有【%s】的收購單 ⇒ 成交 %s" % ["別人" if whose == "other" else "自己", str(dealt)])
		rows.append(dealt)
	_check("P2 自家市集、板上有別人的單 ⇒ 成交", bool(rows[0]))
	_check("P2【反向】只有自己的單 ⇒ 不成交", not bool(rows[1]))
	_cells_ran.append("P2")


# ══ P3／P4 ════════════════════════════════════════════════════════════════════════════════════════
func _p3_p4_no_deal() -> void:
	print("\n── P3 承諾貿易抵達空板市集 ⇒ 失敗記號＋放手；★路過不記 ──")
	var results: Array = []
	for form in ["target_here", "target_cleared", "passing_by"]:
		seed(SEED)
		var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, true)
		var runner := SimRunner.new()
		var tile: HexTileData = _any_market(st)
		var v: TeamData = null
		for tid in st.teams:
			if int(tid) != tile.outpost_owner and (st.teams[tid] as TeamData).leader_id != -1:
				v = st.teams[tid]
				break
		v.tile_pos = tile.tile_pos
		v.current_task = TeamData.TASK_TRADE
		v.current_option = "貿易"
		v.move_target = {"target_here": tile.tile_pos, "target_cleared": Vector2i(-1, -1),
			"passing_by": tile.tile_pos + Vector2i(4, 0)}[form]
		_clear_tile(st, tile, [v.team_id, tile.outpost_owner])
		tile.market_orders.clear()
		var key: String = FailureMemory.key("貿易", str(tile.tile_id))
		runner._step3c_read_market_board(st, [v.team_id])
		var rec: bool = v.recent_failures.has(key)
		var released: bool = v.current_task != TeamData.TASK_TRADE
		print("   %s：失敗記號 %s｜放手 %s（task＝%s）" % [form, str(rec), str(released), v.current_task])
		results.append({"form": form, "rec": rec, "released": released})
		if form == "target_here":
			# P4：同一市集再撞一次 ⇒ 折價更低
			var ctx := DecisionContext.new()
			ctx.set("trade_target_tile_id", tile.tile_id)
			var m1: float = FailureMemory.mult_for_option(st, v, "貿易", ctx)
			v.current_task = TeamData.TASK_TRADE
			v.current_option = "貿易"
			v.move_target = tile.tile_pos
			st.world.current_tick += 60
			runner._step3c_read_market_board(st, [v.team_id])
			var m2: float = FailureMemory.mult_for_option(st, v, "貿易", ctx)
			print("   P4 同一市集撞第 1 次後折價 %.3f｜第 2 次後 %.3f" % [m1, m2])
			_check("P4 連撞兩次 ⇒ 貿易對那個市集的折價下降（%.3f → %.3f，且 < 1）" % [m1, m2], m1 < 1.0 and m2 < m1)
			_cells_ran.append("P4")
	_check("P3 move_target＝這格 ⇒ 失敗記號＋放手", bool(results[0]["rec"]) and bool(results[0]["released"]))
	_check("P3 move_target 已清成 (-1,-1) ⇒ 失敗記號＋放手", bool(results[1]["rec"]) and bool(results[1]["released"]))
	_check("P3【反向】路過（目的地不是這格）⇒ 不記", not bool(results[2]["rec"]))
	_cells_ran.append("P3")


# ══ P1 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p1_team40() -> void:
	print("\n── P1 Team%d（fp 世界）t%d 之後一天 ──" % [P1_TEAM, P1_TICK])
	seed(FP_SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % FP_CFG, true)
	var runner := SimRunner.new()
	while st.world.current_tick < P1_TICK:
		runner.advance_tick(st, Vector2i(-1, -1))
	var t: TeamData = st.teams.get(P1_TEAM)
	if t == null:
		print("   ★Team%d 在 t%d 不存在（A4 之後前提可能消失）" % [P1_TEAM, P1_TICK])
		_check("★P1 母體地板：Team%d 在 t%d 存在" % [P1_TEAM, P1_TICK], false)
		_cells_ran.append("P1")
		return
	var stuck_ticks: int = 0
	var tasks: Array = []
	for _i in range(WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
		var tile: HexTileData = st.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		var at_own: bool = tile != null and tile.outpost_level > 0 and tile.outpost_owner == t.team_id
		var arrived: bool = t.move_target == Vector2i(-1, -1) or t.tile_pos == t.move_target
		if t.current_task == TeamData.TASK_TRADE and at_own and arrived:
			stuck_ticks += 1
		if tasks.is_empty() or String(tasks[-1]) != t.current_task:
			tasks.append(t.current_task)
	var key_hits: Array = t.recent_failures.keys().filter(func(k): return String(k).begins_with("貿易|"))
	print("   一天內「帶貿易站在自家市集、已抵達」的 tick 數 %d｜task 序列 %s｜貿易失敗記號 %s" % [stuck_ticks, str(tasks), str(key_hits)])
	_check("P1 Team%d 不再帶貿易卡在自家市集（一天內那種 tick ＜ 1 小時：%d）" % [P1_TEAM, stuck_ticks], stuck_ticks < WorldState.TICKS_PER_HOUR)
	_cells_ran.append("P1")
