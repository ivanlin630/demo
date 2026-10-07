extends SceneTree
# @bed-kind: invariant
# slice: A2c（spec 2026-10-08-a2c-trade-target-lands-on-non-market-tile-HOW）——「貿易」的目標落在非市集格
#
# ★病（R① 0c37cdbd5＋systems 追到的真寫者）：一般買賣單的 origin_pos＝_market_pos（沒有自家 outpost ⇒ 下單隊當下站的格）
#   ——那是給【同格碰面傳播】用的位置快照，套利選單（best_arbitrage_order）卻拿它當市集去導航
#   ⇒ 商人走到空地、站在上面；_step3c 整段包在 outpost_level > 0 裡 ⇒ 沒有出口
#
# P1 走真世界（先量）：seed 7、30 天，「貿易」到場（具體目標格、站在上面）而人不在市集格的事件數；
#    trade.arb_kill_not_market／trade.arrived_off_market 次數；★P4b 真世界：被放手的隊裡 move_target＝(-1,-1) 的筆數＝0
# P2 佈置：商人 belief 裡一張漫遊隊的單（pos＝空地、更便宜）＋一張市集單 ⇒ 選市集那張；只有漫遊單 ⇒ 回空
# P4 佈置：TRADE 隊有具體目標格、站在上面、腳下非 outpost ⇒ market 步那一拍放手
# P4b 佈置：登記居民人不在家、TRADE＋move_target＝(-1,-1)、腳下非 outpost ⇒ 不放手（resident 擺攤的合法形狀）
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a2c_trade_target_off_market_bed.gd

var _errors: int = 0


class SpyRunner extends SimRunner:
	var released_cleared: int = 0   # 被 market 步放手、而放手前 move_target＝(-1,-1) 的隊（P4b 真世界）
	var released_off: int = 0
	func _step3c_read_market_board(state: WorldState, arrived_ids: Array) -> void:
		var watch: Dictionary = {}
		for tid in state.teams.keys():
			var t: TeamData = state.teams[tid]
			if t.current_task != TeamData.TASK_TRADE:
				continue
			var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
			if tile != null and tile.outpost_level > 0:
				continue
			watch[int(tid)] = t.move_target == Vector2i(-1, -1)
		super(state, arrived_ids)
		for tid2 in watch:
			var t2: TeamData = state.teams.get(tid2)
			if t2 != null and t2.current_task != TeamData.TASK_TRADE:
				released_off += 1
				if bool(watch[tid2]):
					released_cleared += 1


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _initialize() -> void:
	print("=== a2c：「貿易」目標不落在非市集格；站在非市集目標上就放手 ===")
	_p2_arbitrage_picks_known_market()
	_p4_release_off_market()
	_p1_real_world()
	print("\n=== a2c_trade_target_off_market DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _world() -> WorldState:
	seed(20261008)
	return MeasureBedHelper.arm_and_setup("res://config/default.json", false)


func _a_market(ws: WorldState) -> HexTileData:
	var ids: Array = ws.world.tiles.keys()
	ids.sort()
	for tid in ids:
		var t: HexTileData = ws.world.tiles[tid]
		if t.outpost_level > 0:
			return t
	return null


func _order_msg(kind: String, origin: int, pos: Vector2i, price: float, oid: int) -> MessageData:
	var m := MessageData.new()
	m.type = kind
	m.params = {"res": "food", "qty": 20, "origin_team": origin, "origin_pos": pos, "order_id": oid, "price": price}
	return m


# ══ P2：套利只考慮商人已知市集裡的單 ═══════════════════════════════════════════════════════
func _p2_arbitrage_picks_known_market() -> void:
	print("\n── P2 商人 belief 裡一張漫遊單（空地、更便宜）＋一張市集單 ⇒ 選市集那張；只有漫遊單 ⇒ 回空 ──")
	var ws: WorldState = _world()
	var mk: HexTileData = _a_market(ws)
	_check("★母體地板：世界裡有市集", mk != null)
	if mk == null:
		return
	var ids: Array = ws.teams.keys()
	ids.sort()
	var merchant: TeamData = ws.teams[ids[0]]
	var other: int = int(ids[1])
	merchant.tile_pos = mk.coord if "coord" in mk else Vector2i(int(mk.tile_id / 1000), int(mk.tile_id % 1000))
	var empty: Vector2i = merchant.tile_pos + Vector2i(1, 0)
	var et: HexTileData = ws.world.tiles.get(empty.x * 1000 + empty.y)
	_check("★空地真的不是市集", et == null or et.outpost_level <= 0)
	ws.team_market_known[merchant.team_id] = {mk.tile_id: true}
	ws.team_known[merchant.team_id] = [
		_order_msg("order_sell", other, empty, 0.01, 9001),
		_order_msg("order_sell", other, merchant.tile_pos, 0.5, 9002)]
	var os := OrderSystem.new()
	var pick: Dictionary = os.best_arbitrage_order(ws, merchant)
	print("   兩張都有 ⇒ 選到 pos %s（市集 %s、空地 %s）" % [str(pick.get("pos", "空")), str(merchant.tile_pos), str(empty)])
	_check("P2 選市集那張（不選更便宜的空地單）", not pick.is_empty() and pick.get("pos") == merchant.tile_pos)
	ws.team_known[merchant.team_id] = [_order_msg("order_sell", other, empty, 0.01, 9003)]
	var pick2: Dictionary = os.best_arbitrage_order(ws, merchant)
	print("   只有漫遊單 ⇒ %s" % ("回空" if pick2.is_empty() else "選到 " + str(pick2.get("pos"))))
	_check("P2 只有漫遊單 ⇒ 回空（_merchant_trade_target 會退到最近已知市集）", pick2.is_empty())


# ══ P4／P4b：market 步的出口 ════════════════════════════════════════════════════════════
func _p4_release_off_market() -> void:
	print("\n── P4 TRADE、具體目標格、站在上面、腳下非 outpost ⇒ 放手｜P4b move_target＝(-1,-1)（resident 擺攤）⇒ 不碰 ──")
	var ws: WorldState = _world()
	var ids: Array = ws.teams.keys()
	ids.sort()
	var spot: Vector2i = Vector2i(-1, -1)
	for tk in ws.world.tiles.keys():
		var tl: HexTileData = ws.world.tiles[tk]
		if tl.outpost_level <= 0:
			spot = Vector2i(int(tk / 1000), int(tk % 1000))
			break
	var a: TeamData = ws.teams[ids[0]]
	var b: TeamData = ws.teams[ids[1]]
	for t in [a, b]:
		t.tile_pos = spot
		t.current_task = TeamData.TASK_TRADE
		t.current_option = "貿易"
	a.move_target = spot
	b.move_target = Vector2i(-1, -1)
	ws.rebuild_team_tile_index()
	var runner := SimRunner.new()
	runner._step3c_read_market_board(ws, [])
	print("   具體目標隊 task＝%s｜(-1,-1) 隊 task＝%s" % [a.current_task, b.current_task])
	_check("P4 站在非市集目標上 ⇒ 當拍放手", a.current_task != TeamData.TASK_TRADE)
	_check("P4b move_target＝(-1,-1) 的 TRADE 隊（resident 擺攤形狀）⇒ 不放手", b.current_task == TeamData.TASK_TRADE)


# ══ P1：走真世界（先量）＋ P4b 真世界 ════════════════════════════════════════════════════
func _p1_real_world() -> void:
	print("\n── P1 走真世界：seed 7、30 天 ──")
	seed(7)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SpyRunner.new()
	var was: Dictionary = {}
	var off_events: int = 0
	for _i in range(30 * WorldState.TICKS_PER_DAY):
		runner.advance_tick(ws, Vector2i(-1, -1))
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			var now_on: bool = t.current_task == TeamData.TASK_TRADE and String(t.current_option) == "貿易" \
				and t.move_target != Vector2i(-1, -1) and t.tile_pos == t.move_target
			if now_on and not bool(was.get(tid, false)):
				var tile: HexTileData = ws.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
				if tile == null or tile.outpost_level <= 0:
					off_events += 1
			was[tid] = now_on
	print("   「貿易」站上具體目標而人不在市集格的事件 ＝ %d（改前量測：108，見 A2 修先查）" % off_events)
	print("   trade.arb_kill_not_market ＝ %d｜trade.arrived_off_market ＝ %d" % [
		int(Probe.counts.get("trade.arb_kill_not_market", 0)), int(Probe.counts.get("trade.arrived_off_market", 0))])
	print("   market 步放手的非市集格 TRADE 隊 %d 筆，其中放手前 move_target＝(-1,-1) ＝ %d" % [runner.released_off, runner.released_cleared])
	_check("P4b 真世界：被放手的隊裡沒有 move_target＝(-1,-1) 的（resident 擺攤不被放手）", runner.released_cleared == 0)
