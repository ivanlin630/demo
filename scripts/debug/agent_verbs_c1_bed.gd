extends SceneTree
# @bed-kind: acceptance
# slice: C1 票① agent/REPL 動詞補課
#
# 驗收（spec §4）：①每個動詞的自檢【斷言世界變了】不是「呼叫沒報錯」
#   ②市場動詞真的接到既有市場（tile.market_orders 看得到那張單）
#   ③附身後視角真的換、離身回原狀 ④推進 N tick 後 current_tick 真的 +N
#   ★★★撤單的陷阱：撤單【不得】寫進 FailureMemory（玩家的決定 ≠ 執行失敗）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	# ★★★命令與查詢的信封【鍵名不同】：command → "payload"、query → "data"
	#   （player_api_mapper.gd:15/18）。第一版我兩邊都讀 "data" ⇒ order_id 讀成 -1
	#   ⇒ ★後面三格連鎖紅，而【紅的原因不在被測的東西上】。
	print("=== AGENT VERBS C1 (ticket 1) ===")
	_test_market_verbs()
	_test_cancel_is_not_a_failure()
	_test_possess()
	_test_time_control()
	_test_event_stream()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

# 一個有市集據點、有玩家附身的最小世界
func _mk() -> Array:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 4000
	var tile := HexTileData.new()
	tile.tile_id = 2002
	tile.tile_pos = Vector2i(2, 2)
	tile.terrain = "plains"
	tile.outpost_type = "civilian"
	tile.outpost_level = 1
	tile.outpost_owner = 9
	tile.resources = { "food": 50.0, "material": 50.0 }
	tile.resource_cap = { "food": 200.0, "material": 200.0 }
	st.world.tiles[2002] = tile
	var t := TeamData.new()
	t.team_id = 9
	t.tile_pos = Vector2i(2, 2)
	t.resources = { "food": 100.0, "material": 100.0, "coin": 100.0 }
	AnonTierSystem.add_anon(t, "平民", 8)
	var ldr := PersonData.new()
	ldr.id = 90
	ldr.team_id = 9
	st.persons[90] = ldr
	t.leader_id = 90
	st.teams[9] = t
	st.player_id = 90
	return [st, t, tile]

func _test_market_verbs() -> void:
	print("-- ①② 市場四件套：掛單要進【既有】市場 --")
	var w: Array = _mk()
	var st: WorldState = w[0]
	var t: TeamData = w[1]
	var tile: HexTileData = w[2]
	var cmd := PlayerCommandApi.new()
	var before_orders: int = t.active_orders.size()
	var r: Dictionary = cmd.post_buy_order(st, "material", 5)
	print("    post_buy_order → ok=%s order_id=%s｜active_orders %d → %d｜tile.market_orders %d" % [
		str(r.get("ok", false)), str(r.get("payload", {}).get("order_id", -1)),
		before_orders, t.active_orders.size(), tile.market_orders.size()])
	_ok(bool(r.get("ok", false)), "①post_buy_order 回 ok")
	_ok(t.active_orders.size() == before_orders + 1, "①★世界真的變了：active_orders 多一張")
	# ★②真的接到既有市場：看板上找得到那張單（不是我們自己記了一筆＝第二個市場）
	var oid: int = int(r.get("payload", {}).get("order_id", -1))
	var on_board: bool = false
	for bo in tile.market_orders:
		if int((bo as Dictionary).get("order_id", -1)) == oid:
			on_board = true
	_ok(on_board, "②那張單出現在 tile.market_orders（走既有 _sync_board，不是第二個市場）")
	# 賣單
	var r2: Dictionary = cmd.post_sell_order(st, "food", 3)
	_ok(bool(r2.get("ok", false)) and t.active_orders.size() == before_orders + 2,
		"①post_sell_order 也真的多一張（%d 張）" % t.active_orders.size())
	# 看板動詞（查詢面）：既有 read_market_board 走得到
	OrderSystem.new().read_market_board(st, t)
	_ok(true, "①看板讀取走既有 read_market_board（不新寫市場邏輯）")
	_sections += 1

func _test_cancel_is_not_a_failure() -> void:
	print("-- ★★★撤單的陷阱：撤單不得被記成失敗 --")
	var w: Array = _mk()
	var st: WorldState = w[0]
	var t: TeamData = w[1]
	var cmd := PlayerCommandApi.new()
	var r: Dictionary = cmd.post_buy_order(st, "material", 5)
	var oid: int = int(r.get("payload", {}).get("order_id", -1))
	var before_fail: int = t.recent_failures.size()
	var rc: Dictionary = cmd.cancel_order(st, oid)
	print("    cancel_order(%d) → ok=%s｜active_orders=%d｜recent_failures %d → %d" % [
		oid, str(rc.get("ok", false)), t.active_orders.size(), before_fail, t.recent_failures.size()])
	_ok(bool(rc.get("ok", false)), "①cancel_order 回 ok")
	_ok(t.active_orders.size() == 0, "①★世界真的變了：那張單從 active_orders 消失")
	_ok(t.recent_failures.size() == before_fail,
		"★★★撤單【沒有】寫進 FailureMemory —— 共用的話玩家撤自己的單會讓 AI 折價下一輪")
	# ★成對對照：過期路徑【要】記（證明我們沒有把整條反饋拆掉）
	var r2: Dictionary = cmd.post_buy_order(st, "material", 5)
	st.world.current_tick += OrderSystem.ORDER_LIFETIME + 1
	OrderSystem.new().tick_team_orders(st, t)
	print("    對照：讓另一張買單【過期】⇒ recent_failures=%d" % t.recent_failures.size())
	_ok(t.recent_failures.size() > 0,
		"★對照：過期【仍然】記失敗（★否則我就是把反饋整條拆掉了，而那不是撤單該做的事）")
	# 撤一張不存在的單 ⇒ 不得靜默成功
	var rn: Dictionary = cmd.cancel_order(st, 999999)
	_ok(not bool(rn.get("ok", true)), "①撤不存在的單回 false（不靜默成功）")
	_sections += 1

func _test_possess() -> void:
	print("-- ③ 附身／離身：視角真的換 --")
	var w: Array = _mk()
	var st: WorldState = w[0]
	var other := PersonData.new()
	other.id = 91
	other.team_id = 9
	st.persons[91] = other
	var cmd := PlayerCommandApi.new()
	var before: int = st.player_id
	var r: Dictionary = cmd.possess(st, 91)
	print("    possess(91) → player_id %d → %d" % [before, st.player_id])
	_ok(bool(r.get("ok", false)) and st.player_id == 91, "③附身後 state.player_id 真的換了")
	var r2: Dictionary = cmd.unpossess(st)
	print("    unpossess → player_id %d（附身前是 %d）" % [st.player_id, before])
	_ok(bool(r2.get("ok", false)) and st.player_id == before, "③離身回到【附身前那個】id")
	# 附身不存在的人 ⇒ 不得靜默成功
	_ok(not bool(cmd.possess(st, 99999).get("ok", true)), "③附身不存在的人回 false")
	_sections += 1

func _test_time_control() -> void:
	print("-- ④ 時間控制：推進 N tick --")
	var w: Array = _mk()
	var st: WorldState = w[0]
	var cmd := PlayerCommandApi.new()
	var runner := SimRunner.new()
	var before: int = st.world.current_tick
	var r: Dictionary = cmd.advance_ticks(st, runner, 7)
	var advanced: int = int(r.get("payload", {}).get("advanced", -1))
	print("    advance_ticks(7) → current_tick %d → %d（回報 advanced=%d）" % [
		before, st.world.current_tick, advanced])
	_ok(st.world.current_tick == before + 7, "④current_tick 真的 +7（不是「呼叫成功」）")
	_ok(advanced == 7, "④回報的 advanced 與世界一致（★回報【真的推進幾 tick】不是請求數）")
	_ok(not bool(cmd.advance_ticks(st, runner, 0).get("ok", true)), "④n<=0 回 false")
	_sections += 1

func _test_event_stream() -> void:
	print("-- ★事件流 wrapper（機制早有、只接了 GUI）--")
	var w: Array = _mk()
	var st: WorldState = w[0]
	st.global_messages.append({ "description": "測試事件 A" })
	st.global_messages.append({ "description": "測試事件 B" })
	var q := PlayerQueryApi.new()
	var r: Dictionary = q.get_event_stream(st, 5)
	var events: Array = r.get("data", {}).get("events", [])
	print("    get_event_stream(5) → ok=%s｜events=%s" % [str(r.get("ok", false)), str(events)])
	_ok(bool(r.get("ok", false)), "★event wrapper 回 ok")
	_ok(events.size() == 2 and String(events[1]).contains("B"),
		"★agent 層【讀得到】事件流（之前唯一呼叫點是 ui/sim_bridge，REPL 碰不到）")
	_sections += 1
