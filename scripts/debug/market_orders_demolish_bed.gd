extends SceneTree
# @observe-pure
# ★★★族④#6：outpost 拆除 ⇒ `tile.market_orders` 必須跟著消失（dangling state）。
#
# ★★而 systems 給的症狀描述【我實測發現不成立】，這張床把它證出來：
#   他寫：「隊站上那格 `read_market_board` 會讀到一個不存在的市集的單」
#   ★而 `order_system.gd:247` 一開頭就 `if tile.outpost_level <= 0: return`
#   ⇒ ★★拆除把 level 設成 0 ⇒ ★★★那個消費端【本來就讀不到】—— 症狀被擋住了
#   （其餘消費端同樣有 level 閘：`faction_ai_system.gd:1828`）
#
# ★★★所以真正的曝露是【重建】：同一格日後再蓋起 outpost ⇒ level 又 > 0
#   ⇒ ★舊主的鬼單【復活】，而它們的 origin_team 早就不在這裡了。
#   ⇒ 本床用【拆 → 重建 → 讀看板】把那條路走完，而不是只看欄位。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== 族④#6：拆除後看板不得殘留 ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	var pos := Vector2i(2, 2)
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	state.world.tiles[tile.tile_id] = tile
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	ldr.skills = {"統領": 0.5}
	state.persons[1] = ldr
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 1; team.tile_pos = pos
	state.teams[0] = team
	state.add_member(team, 1)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)
	OutpostOwnerBank.set_owner(tile, 0, "bed")

	# ── ①拆除【前】看板要有東西（★沒有這條，下面的 0 證不到是我清的）──
	tile.market_orders.append({"order_id": 1, "kind": "sell", "res": "food", "qty_remaining": 10,
		"origin_team": 0, "expire_tick": 999999, "origin_tick": 0, "strength": 1.0, "relayed": false})
	tile.market_orders.append({"order_id": 2, "kind": "buy", "res": "material", "qty_remaining": 5,
		"origin_team": 0, "expire_tick": 999999, "origin_tick": 0, "strength": 1.0, "relayed": false})
	var before: int = tile.market_orders.size()
	_ok(before > 0, "★拆除前看板有 %d 張單（對照：沒有這條，『拆完 0』證不到任何事）" % before)

	# ── ②走真拆除路徑（不是手動清欄位）──
	var os_sys := OutpostSystem.new()
	_ok(os_sys.start_demolish(state, team), "start_demolish 起工")
	var guard: int = 0
	while tile.construction_team_id != -1 and guard < 200000:
		os_sys._tick_construction(state, tile)
		state.world.current_tick += 1
		guard += 1
	var completed: int = int(Probe.counts.get("demolish.completed", 0))
	# ★entry counter：沒有它，「dangling=0」與「根本沒拆過」長得一模一樣
	_ok(completed == 1, "★★entry counter：demolish.completed = %d（★必須 1；0 ＝ 根本沒拆過，那時下面的 0 沒意義）" % completed)
	_ok(tile.outpost_level == 0, "前提：outpost 真的被拆掉了（level=0）")
	_ok(tile.market_orders.size() == 0, "★★★拆除後看板 = 0（清掉 %d 張，Probe: %d）"
		% [before, int(Probe.amounts.get("demolish.market_orders_cleared", 0.0))])

	# ── ③使用端證明：★而它必須走【重建】那條路 ──
	print("  ★systems 說的症狀（隊站上去 read_market_board 讀到鬼單）★實測不成立：")
	print("    `order_system.gd:247` 開頭就 `if tile.outpost_level <= 0: return` ⇒ 拆完 level=0 ⇒ 讀不到")
	print("  ★★★真正的曝露是【重建】：同一格再蓋起來 ⇒ level>0 ⇒ 鬼單復活")
	tile.outpost_type = "civilian"; tile.outpost_level = 1     # 重建
	OutpostOwnerBank.set_owner(tile, 0, "rebuild")
	var os2 := OrderSystem.new()
	os2.read_market_board(state, team)
	_ok(tile.market_orders.size() == 0,
		"★★★重建之後看板仍然 0 ＝ 鬼單沒有復活（★這一條才是使用端的證明）")

	print("  ★誠實限：①本床手工造世界、單 tile；★★證的是【拆除這條路會清】，")
	print("    ★★★證不到【全世界沒有別的路徑會留下 dangling 看板】（例如易主那半不在本票）")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
