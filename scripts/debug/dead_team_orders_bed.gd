extends SceneTree
# @observe-pure
# ★★★族④#6【改票後】：死隊的看板單必須隨它一起走。
#
# ★真根（systems 坐實，file:line）：訂單生命週期是【owner 驅動】——
#   `order_system.gd:88`：「他隊 entry 不動（由各自 tick_team_orders 維護）」
#   而 `tick_team_orders` 只對【活著的隊】跑 ⇒ ★★隊死了它的單就沒有人維護
#   ⇒ ★★★在【任何活市集】上永久掛著（那些 tile 的 outpost_level > 0 ⇒ 讀得到）
#   ⇒ ★不需要拆除、也不需要易主就會發生 —— 原條目框成 capture/demolish，框窄了。
#
# ★★本床要能分辨的三件事（指標=0 三讀法）：
#   ①有沒有隊真的被 erase（entry counter）②清之前有幾筆（分母）③使用端讀不讀得到

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk_market_tile(state: WorldState, pos: Vector2i, owner_id: int) -> HexTileData:
	var t := HexTileData.new()
	t.tile_id = pos.x * 1000 + pos.y; t.tile_pos = pos; t.terrain = "plains"
	t.outpost_type = "civilian"; t.outpost_level = 1
	state.world.tiles[t.tile_id] = t
	OutpostOwnerBank.set_owner(t, owner_id, "bed")
	return t

func _mk_team(state: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var ldr := PersonData.new(); ldr.id = tid * 100 + 1; ldr.team_id = tid
	ldr.skills = {"統領": 0.4, "商業": 0.4}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id; team.tile_pos = pos
	state.teams[tid] = team
	state.add_member(team, ldr.id)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)
	return team

func _entry(oid: int, origin: int, relayed: bool) -> Dictionary:
	return {"order_id": oid, "kind": "sell", "res": "food", "qty_remaining": 10,
		"origin_team": origin, "expire_tick": 999999, "origin_tick": 0,
		"strength": 1.0, "relayed": relayed}

func _init() -> void:
	print("=== 族④#6：死隊的單必須跟著走 ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	var tile_a := _mk_market_tile(state, Vector2i(2, 2), 0)   # 活市集（A 的）
	var tile_b := _mk_market_tile(state, Vector2i(5, 5), 1)   # 活市集（B 的）
	var a := _mk_team(state, 0, Vector2i(2, 2))
	var _b := _mk_team(state, 1, Vector2i(5, 5))
	# B 的原生單掛在自己市集；★★★而 relay 讓它【也出現在 A 的市集上】——
	#   所以只清「死隊自己那格」是不夠的（本床同時驗這一點）
	tile_b.market_orders.append(_entry(11, 1, false))
	tile_a.market_orders.append(_entry(11, 1, true))    # relayed 副本
	tile_a.market_orders.append(_entry(22, 0, false))   # ★A 自己的單（不得被誤清）
	var seen_before: int = tile_a.market_orders.size() + tile_b.market_orders.size()
	_ok(seen_before == 3, "★清之前全世界看板 3 筆（分母；沒有它，『清了 N 筆』不知是多是少）")

	# ── B 死掉（走 A#14 已證的唯一窄口）──
	state.erase_team(1)

	var batches: int = int(Probe.counts.get("erase.batches", 0))
	var erased: float = float(Probe.amounts.get("erase.teams_erased", 0.0))
	var removed: float = float(Probe.amounts.get("erase.board_entries_removed", 0.0))
	var seen: float = float(Probe.amounts.get("erase.board_entries_seen", 0.0))
	_ok(batches == 1 and erased == 1.0,
		"★★entry counter：erase 批次 %d／死了 %.0f 隊（★0 ＝ 這窗裡根本沒隊死，那時下面的 0 沒意義）" % [batches, erased])
	print("  清之前看板 %.0f 筆 ／ 清掉 %.0f 筆" % [seen, removed])
	_ok(removed == 2.0, "★★★兩筆都清掉了：B 自己市集那筆 ＋ ★A 市集上的 relayed 副本")

	var a_ids: Array = []
	for e in tile_a.market_orders: a_ids.append(int(e["order_id"]))
	var b_ids: Array = []
	for e in tile_b.market_orders: b_ids.append(int(e["order_id"]))
	_ok(b_ids.is_empty(), "B 自己市集看板清空")
	_ok(a_ids == [22], "★A 自己的單【沒有被誤清】（互斥：只清死隊的）—— 實際 %s" % str(a_ids))

	# ── ★★★使用端證明：A 站上自己市集讀看板，讀不到死隊的單 ──
	var os2 := OrderSystem.new()
	os2.read_market_board(state, a)
	var leaked: int = 0
	for m in state.team_known.get(0, []):
		if int(m.params.get("origin_team", -1)) == 1: leaked += 1
	_ok(leaked == 0, "★★★使用端：read_market_board 之後，A 的 team_known 裡沒有死隊的單（leak=%d）" % leaked)

	print("  ★誠實限：①本床手工造世界／兩個 tile ⇒ 證的是【erase 這條路會清】")
	print("    ★★證不到【沒有別的路徑會產生死隊殘單】（例如 relay 在 erase 之後又補一份）")
	print("    ★★★而那條要長窗才測得到，本床沒跑")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
