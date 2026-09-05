extends SceneTree

# 統一商業框架 TDD（unified-commerce，market-as-place）
# spec: docs/superpowers/specs/2026-07-15-unified-commerce-framework.md
# M2 到場 resolver _resolve_market_at_outpost：owner-mediated，訪客買 owner sell 單(coin→owner)/
# 賣入 owner buy 單(owner.coin→visitor)；order_id 直沖；min(單餘,現貨);無單不賣;SURVIVAL 有單才賣;守恆。

var _fail: int = 0

func _initialize() -> void:
	_test_visitor_buy_from_stock()
	_test_visitor_sell_to_buyorder()
	_test_order_id_direct_settle()
	_test_survival_no_order_no_sell()
	_test_conservation()
	_test_integration_step3c_fires()
	_test_probe_full_funnel()
	_test_member_tax_conservation()
	_test_combo_taxed_buyer_deals()
	_test_no_stock_seizure_path()   # ★★★新增反向斷言：存量沒收走廊【不得存在】
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

# ★★★⑦（2026-09-05）之後 `SalarySystem.tick` 的閘不再是 `current_tick % SALARY_INTERVAL == 0`，
#   而是【與 `team.salary_eval_next_tick` 比較】(CadenceStagger)。★第一次呼叫【只排程不發薪】
#   （沒有工作過的那一週），所以「呼一次就期待發薪」的舊寫法會拿到 0。
#   ★★而那個 0 【不是稅壞了也不是薪資壞了】—— 是【測試用了舊的觸發方式】。
#   ⇒ ★★★這支 helper 把「排程 → 跳到到期 → 再呼一次」寫死，讓每個呼叫端都走同一條路，
#     免得下一個人各自寫一份、而其中一份忘了跳。
func _salary_due_tick(s: WorldState, sal: SalarySystem, tid: int) -> void:
	var team: TeamData = s.teams[tid]
	sal.tick(s, [tid])                                   # ①只排程
	assert(team.salary_eval_next_tick > 0, "⑦：第一次呼叫必須排程")
	s.world.current_tick = team.salary_eval_next_tick    # ②跳到到期那一刻
	sal.tick(s, [tid])                                   # ③真的發

func _mk_person(state: WorldState, id: int, vals: Dictionary = {}) -> void:
	var p := PersonData.new(); p.id = id; p.values = vals; p.skills = {}
	state.persons[id] = p

func _mk_team(state: WorldState, tid: int, leader_id: int, pop: int, res: Dictionary) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.leader_id = leader_id
	t.resources = res.duplicate()
	for i in range(pop - 1):
		t.named_members.append(tid * 100 + i)
	state.teams[tid] = t
	return t

# owner outpost tile：public_storage stock + board sell/buy 單（＝owner active_orders 鏡像）。
func _mk_outpost(state: WorldState, owner_id: int, pos: Vector2i, storage: Dictionary, orders: Array) -> HexTileData:
	var tile := HexTileData.new()
	tile.tile_pos = pos; tile.outpost_level = 1; tile.outpost_owner = owner_id
	tile.public_storage = storage.duplicate()
	tile.market_orders = orders.duplicate(true)
	state.world.tiles[pos.x * 1000 + pos.y] = tile
	return tile

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 0
	return s

# ★★★買方的【需求】必須是真的（不是把 want 調大）。
#   ★`_market_visitor_buy` 的可購量含一項 `want = reserve(res) - holding`
#     （`interaction_system.gd::_market_visitor_buy`），而 material 的 reserve 走
#     `TradeValuation.reserve` → `NeedOracle.need_keep` → `_construction_facility_need`：
#     ★★沒有【自家據點】就 return 0 ⇒ material 的 reserve 恆 0 ⇒ want 0 ⇒ 這一單永遠不成交。
#   ⇒ ★★★所以修法不是放寬那道閘，是【把買方的需求建起來】：
#     給它一個自家 civilian 據點、facility 全 0 級 ⇒ farming 等的 build-cost 含 material
#     ⇒ 需求由【真實的想蓋】導出，而不是由 fixture 直接塞一個數字。
#   ★而 desire 那一關（CONSTRUCTION_DESIRE_MIN=0.3）也得是真的：farming 的 deficit 由
#     `need_keep(food) vs 持有 food` 導出 ⇒ 買方 food=0 且有人口 ⇒ deficit≈1 ⇒ 真的想蓋。
func _give_construction_demand(state: WorldState, team: TeamData, pos: Vector2i) -> HexTileData:
	var home := HexTileData.new()
	home.tile_pos = pos
	home.outpost_level = 1
	home.outpost_type = "civilian"     # farming/workshop/apothecary/mint 的 allowed_outpost
	home.outpost_owner = team.team_id
	home.terrain = "plains"
	state.world.tiles[pos.x * 1000 + pos.y] = home
	OwnerOutpostIndex.invalidate()     # ★直接寫 outpost_owner 繞過 bank ⇒ 索引要失效，否則查不到自家據點
	return home

# ── TDD1：訪客到市場 outpost → 向 stock 買（deal fire，扣 storage，coin→owner，守恆）──
func _test_visitor_buy_from_stock() -> void:
	print("--- TDD1：訪客買 owner sell 單/stock（coin→owner）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0, "material": 100.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0, "food": 0.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	# ★★★買方要有【真的想買 material 的理由】——見 `_give_construction_demand` 的註解。
	#   ★這張 fixture 原本沒有它 ⇒ material 的 want 恆 0 ⇒ 「交易整條沒發生」
	#   ⇒ ★★而那看起來跟【撮合壞掉】一模一樣（第一次 triage 就是那樣讀的）。
	_give_construction_demand(s, visitor, Vector2i(7, 7))
	# owner 掛 sell material ×80（board + active_orders 權威）
	var sell_order := {"order_id": 42, "kind": "sell", "res": "material", "qty_remaining": 80}
	owner.active_orders.append(sell_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"material": 100.0}, [sell_order])
	var owner_coin0: float = float(owner.resources.get("coin", 0))
	var vis_mat0: float = float(visitor.resources.get("material", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(float(visitor.resources.get("material", 0)) > vis_mat0, "訪客得 material（%.0f→%.0f）" % [vis_mat0, float(visitor.resources.get("material", 0))])
	_ok(float(owner.resources.get("coin", 0)) > owner_coin0, "owner 得 coin（%.0f→%.0f，coin→owner）" % [owner_coin0, float(owner.resources.get("coin", 0))])
	_ok(float(tile.public_storage.get("material", 0)) < 100.0, "public_storage material 扣減（%.0f）" % float(tile.public_storage.get("material", 0)))

# ── TDD2：★訪客賣 → 向 owner buy 單賣（貨入 storage，owner.coin→visitor，套利閉合）──
func _test_visitor_sell_to_buyorder() -> void:
	print("--- TDD2：★訪客賣入 owner buy 單（owner.coin→visitor）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 500.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 0.0, "goods": 60.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	var buy_order := {"order_id": 43, "kind": "buy", "res": "goods", "qty_remaining": 40}
	owner.active_orders.append(buy_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {}, [buy_order])
	var vis_coin0: float = float(visitor.resources.get("coin", 0))
	var owner_coin0: float = float(owner.resources.get("coin", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(float(visitor.resources.get("coin", 0)) > vis_coin0, "★訪客賣得 coin（%.0f→%.0f，套利閉合）" % [vis_coin0, float(visitor.resources.get("coin", 0))])
	_ok(float(owner.resources.get("coin", 0)) < owner_coin0, "owner.coin 付出（%.0f→%.0f）" % [owner_coin0, float(owner.resources.get("coin", 0))])
	_ok(float(tile.public_storage.get("goods", 0)) > 0.0, "貨入 public_storage（%.0f）" % float(tile.public_storage.get("goods", 0)))

# ── TDD3：履約 order_id 直沖（成交即沖 active_orders + board，不掛幽靈）──
func _test_order_id_direct_settle() -> void:
	print("--- TDD3：order_id 直沖 active_orders + board ---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	# ★同一個因（★量過才寫，不是套用）：修前這一格的 bail 分因＝`trade.market_bail.buy_no_want = 1`，
	#   而 `mkfill.attempt.buy = 1` ⇒ ★★撮合【有】被走到，是買方沒有需求 —— 跟 TDD1 同因。
	_give_construction_demand(s, visitor, Vector2i(7, 7))
	var sell_order := {"order_id": 42, "kind": "sell", "res": "material", "qty_remaining": 30}
	owner.active_orders.append(sell_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"material": 100.0}, [sell_order])
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	# 權威 active_orders qty_remaining 直沖（減少）
	var oid_rem: int = -1
	for o in owner.active_orders:
		if int(o["order_id"]) == 42: oid_rem = int(o["qty_remaining"])
	var board_rem: int = 999
	for e in tile.market_orders:
		if int(e["order_id"]) == 42: board_rem = int(e["qty_remaining"])
	_ok(oid_rem < 30 or oid_rem == -1, "active_orders order_id=42 直沖（qty_remaining=%d，<30 或已移除）" % oid_rem)
	_ok(board_rem < 30, "board entry order_id=42 同步直沖（qty_remaining=%d）" % board_rem)

# ── TDD4：SURVIVAL_GOODS 無單不賣（活命糧不買穿：storage 有 food 但無 sell 單 → 不成交）──
func _test_survival_no_order_no_sell() -> void:
	print("--- TDD4：SURVIVAL 無單不賣（食物不買穿）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	# storage 有 food 但 board 無 food sell 單（只有 material sell 單）
	var mat_order := {"order_id": 50, "kind": "sell", "res": "material", "qty_remaining": 10}
	owner.active_orders.append(mat_order.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"food": 200.0, "material": 20.0}, [mat_order])
	var food0: float = float(tile.public_storage.get("food", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(absf(float(tile.public_storage.get("food", 0)) - food0) < 0.001, "★food 無 sell 單 → 不賣（storage food %.0f 不動）" % float(tile.public_storage.get("food", 0)))

# ── TDD5：守恆——成交總 coin + 總 goods 不生不滅 ──
func _test_conservation() -> void:
	print("--- TDD5：市場成交守恆（coin↔goods 只搬）---")
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 200.0, "material": 100.0})
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0, "goods": 50.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	var sell_o := {"order_id": 60, "kind": "sell", "res": "material", "qty_remaining": 50}
	var buy_o := {"order_id": 61, "kind": "buy", "res": "goods", "qty_remaining": 30}
	owner.active_orders.append(sell_o.duplicate()); owner.active_orders.append(buy_o.duplicate())
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"material": 100.0}, [sell_o, buy_o])
	var coin0: float = _tot_coin(owner, visitor, tile)
	var mat0: float = float(owner.resources.get("material", 0)) + float(visitor.resources.get("material", 0)) + float(tile.public_storage.get("material", 0))
	var goods0: float = float(owner.resources.get("goods", 0)) + float(visitor.resources.get("goods", 0)) + float(tile.public_storage.get("goods", 0))
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	var coin1: float = _tot_coin(owner, visitor, tile)
	var mat1: float = float(owner.resources.get("material", 0)) + float(visitor.resources.get("material", 0)) + float(tile.public_storage.get("material", 0))
	var goods1: float = float(owner.resources.get("goods", 0)) + float(visitor.resources.get("goods", 0)) + float(tile.public_storage.get("goods", 0))
	_ok(absf(coin1 - coin0) < 0.001, "★總 coin 守恆（%.2f→%.2f）" % [coin0, coin1])
	_ok(absf(mat1 - mat0) < 0.001, "★總 material 守恆（%.2f→%.2f）" % [mat0, mat1])
	_ok(absf(goods1 - goods0) < 0.001, "★總 goods 守恆（%.2f→%.2f）" % [goods0, goods1])

func _tot_coin(owner: TeamData, visitor: TeamData, tile: HexTileData) -> float:
	return float(owner.resources.get("coin", 0)) + float(visitor.resources.get("coin", 0)) + float(tile.public_storage.get("coin", 0))

# ── ★整合測（wiring-fix）：SimRunner._step3c_read_market_board → 新 resolver 真 fire（非死碼）──
func _test_integration_step3c_fires() -> void:
	print("--- ★整合：SimRunner._step3c → market-as-place resolver 真 fire ---")
	Probe.enabled = true; Probe.reset()
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	# owner b：market outpost，food sell 單於 board + storage
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0})
	owner.tile_pos = Vector2i(3, 3)
	owner.active_orders = [{"order_id": 80, "kind": "sell", "res": "food", "qty_remaining": 100}]
	var tile := _mk_outpost(s, 1, Vector2i(3, 3), {"food": 500.0},
		[{"order_id": 80, "kind": "sell", "res": "food", "qty_remaining": 100, "origin_team": 1, "expire_tick": 99999}])
	# hungry visitor a：TASK_TRADE 站在 market tile（＝arrived），有 coin、低 food
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0, "food": 0.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(3, 3)
	var food0: float = float(visitor.resources.get("food", 0))
	var sr := SimRunner.new()
	sr._step3c_read_market_board(s, [2])   # arrived = [visitor]
	_ok(float(visitor.resources.get("food", 0)) > food0, "★整合：step3c→resolver 真 fire，visitor 買到 food（%.0f）" % float(visitor.resources.get("food", 0)))
	_ok(int(Probe.counts.get("trade.deal_market", 0)) > 0, "★deal_market probe 動（=%d，非死碼）" % int(Probe.counts.get("trade.deal_market", 0)))
	Probe.enabled = false

# ── ★probe 全 funnel 可觀測（observability-fix）：成交 bump deal/deal_market/order_fulfilled；bail 分因可觀測 ──
func _test_probe_full_funnel() -> void:
	print("--- ★probe 全 funnel：成交計數口徑 + bail 分因 ---")
	# (a) 成交 → order_fulfilled + deal + deal_market bump（鏡射舊路口徑）
	Probe.enabled = true; Probe.reset()
	var s := _mk_state()
	_mk_person(s, 100); _mk_person(s, 200)
	var owner := _mk_team(s, 1, 100, 10, {"coin": 0.0})
	owner.active_orders = [{"order_id": 90, "kind": "sell", "res": "food", "qty_remaining": 5}]
	var tile := _mk_outpost(s, 1, Vector2i(1, 1), {"food": 500.0},
		[{"order_id": 90, "kind": "sell", "res": "food", "qty_remaining": 5, "origin_team": 1, "expire_tick": 99999}])
	var visitor := _mk_team(s, 2, 200, 10, {"coin": 500.0, "food": 0.0})
	visitor.current_task = TeamData.TASK_TRADE; visitor.tile_pos = Vector2i(1, 1)
	InteractionSystem.new()._resolve_market_at_outpost(s, visitor, tile)
	_ok(int(Probe.counts.get("trade.deal", 0)) > 0, "trade.deal bump（=%d）" % int(Probe.counts.get("trade.deal", 0)))
	_ok(int(Probe.counts.get("trade.deal_market", 0)) > 0, "trade.deal_market bump（=%d）" % int(Probe.counts.get("trade.deal_market", 0)))
	_ok(int(Probe.counts.get("g1.order_fulfilled", 0)) > 0, "★order_fulfilled bump（單填滿=%d，鏡射舊路）" % int(Probe.counts.get("g1.order_fulfilled", 0)))
	_ok(int(Probe.counts.get("trade.meet", 0)) > 0, "trade.meet bump（到市場會合=%d）" % int(Probe.counts.get("trade.meet", 0)))
	# (b) bail 分因可觀測：無 coin → buy_no_coin
	Probe.reset()
	var s2 := _mk_state()
	_mk_person(s2, 100); _mk_person(s2, 200)
	var o2 := _mk_team(s2, 1, 100, 10, {"coin": 0.0})
	o2.active_orders = [{"order_id": 91, "kind": "sell", "res": "food", "qty_remaining": 5}]
	var tile2 := _mk_outpost(s2, 1, Vector2i(1, 1), {"food": 500.0},
		[{"order_id": 91, "kind": "sell", "res": "food", "qty_remaining": 5, "origin_team": 1, "expire_tick": 99999}])
	var v2 := _mk_team(s2, 2, 200, 10, {"coin": 0.0, "food": 0.0})   # 無 coin
	v2.current_task = TeamData.TASK_TRADE; v2.tile_pos = Vector2i(1, 1)
	InteractionSystem.new()._resolve_market_at_outpost(s2, v2, tile2)
	_ok(int(Probe.counts.get("trade.market_bail.buy_no_coin", 0)) > 0, "★bail 分因可觀測: buy_no_coin bump（=%d）" % int(Probe.counts.get("trade.market_bail.buy_no_coin", 0)))
	Probe.enabled = false

# ── coin combo：成員稅守恆（person.coin→team.coin 池間搬，留 floor）──
func _test_member_tax_conservation() -> void:
	# ★★★改測【所得稅守恆】（spec §4 #1：改測不刪 —— 刪測試＝把閘變綠）
	#   ★舊測驗的是「存量稅：person.coin → team.coin，且留 floor」——★★而那條路已整支退場。
	#   ★★★新規則是【源扣繳】：team 只淨支出 net，稅額【從未離開團庫】
	#     ⇒ 守恆的形狀也跟著變：不是「兩池間搬」，是【團庫少流出】。
	print("--- ★所得稅守恆：源扣繳＝團庫少流出（不是兩池間搬）---")
	var s := _mk_state()
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"貪婪": 0.9, "慎重": 0.1}
	ldr.skills = {"統領": 0.5}
	s.persons[100] = ldr
	var team := TeamData.new(); team.team_id = 1; team.leader_id = 100
	team.resources = {"coin": 1000.0}
	for i in range(3):
		var p := PersonData.new(); p.id = 200 + i; p.coin = 0.0
		p.skills = {"戰鬥": 0.5}
		s.persons[200 + i] = p; team.named_members.append(200 + i)
	s.teams[1] = team
	var tc0: float = float(team.resources.get("coin", 0))
	var mc0: float = 0.0
	for pid in team.named_members: mc0 += s.persons[pid].coin
	var sal := SalarySystem.new()
	_salary_due_tick(s, sal, 1)
	var tc1: float = float(team.resources.get("coin", 0))
	var mc1: float = 0.0
	for pid in team.named_members: mc1 += s.persons[pid].coin
	var out: float = tc0 - tc1        # 團庫實際流出
	var got: float = mc1 - mc0        # 成員實際收到
	_ok(out > 0.0 and got > 0.0, "有發薪：團庫流出 %.2f、成員收到 %.2f" % [out, got])
	# ★★★關鍵斷言：★團庫流出【等於】成員收到（源扣繳 ⇒ 稅額根本沒動）
	#   ★★而【不是】「流出 gross、再抽回稅」——後者會讓 out > got
	_ok(absf(out - got) < 0.001, "★源扣繳：團庫流出(%.3f) ＝ 成員收到(%.3f)（稅額從未離開團庫）" % [out, got])
	# ★人格梯度：貪婪 leader 的稅率要【高於】慎重 leader，而兩邊【不得都貼在 clamp 上界】
	var r_greedy: float = clampf(0.9 * CoinTreasury.INCOME_TAX_K - 0.1 * CoinTreasury.INCOME_TAX_K2,
		0.0, CoinTreasury.INCOME_TAX_MAX)
	var r_prudent: float = clampf(0.1 * CoinTreasury.INCOME_TAX_K - 0.9 * CoinTreasury.INCOME_TAX_K2,
		0.0, CoinTreasury.INCOME_TAX_MAX)
	_ok(r_greedy > r_prudent, "★人格梯度：貪婪 rate(%.3f) > 慎重 rate(%.3f)" % [r_greedy, r_prudent])
	_ok(r_greedy < CoinTreasury.INCOME_TAX_MAX - 0.0001,
		"★★而貪婪那端【沒有貼在 clamp 上界】(%.3f < %.3f) —— 否則梯度是假的"
		% [r_greedy, CoinTreasury.INCOME_TAX_MAX])

# ── ★★★反向斷言（spec §4 #1b）：把「這條路是【故意】拿掉的」焊成可執行的測試 ──
#   ★未來有人重新引入【存量抽取】（team.coin 低就抽 named 成員 p.coin）會【自動變紅】
func _test_no_stock_seizure_path() -> void:
	print("--- ★★★反向斷言：team.coin=0 而成員有私產 ⇒ 不存在把存量拉回團庫的機制 ---")
	var s := _mk_state()
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"貪婪": 0.9, "慎重": 0.1}
	s.persons[100] = ldr
	var team := TeamData.new(); team.team_id = 1; team.leader_id = 100
	team.resources = {"coin": 0.0}          # ★團庫見底
	team.anon_treasury = 0.0                # ★★匿名池也見底 ⇒ 真正的「卡死」形狀
	for i in range(3):
		var p := PersonData.new(); p.id = 200 + i; p.coin = 100.0   # ★★★成員有私產
		s.persons[200 + i] = p; team.named_members.append(200 + i)
	s.teams[1] = team
	var mc0: float = 0.0
	for pid in team.named_members: mc0 += s.persons[pid].coin
	# ★跑一輪【所有】可能碰到 coin 的既有路徑
	CoinTreasury.consider_extraction(s, team)
	var sal := SalarySystem.new()
	_salary_due_tick(s, sal, 1)
	var mc1: float = 0.0
	for pid in team.named_members: mc1 += s.persons[pid].coin
	var tc1: float = float(team.resources.get("coin", 0))
	_ok(absf(mc1 - mc0) < 0.001,
		"★成員私產【未被動用】(%.1f → %.1f) —— ★★這條路是【故意】拿掉的（spec §5b 硬禁令）" % [mc0, mc1])
	_ok(tc1 <= 0.001,
		"★★★團庫仍是 0（%.3f）—— ★而那是【genuine 貧困】不是 bug：正路只有賣貨／anon 池／領袖徵收" % tc1)
	print("     ★★若這兩條變紅 ⇒ 有人重新引入了【存量沒收】走廊 —— 那是禁令，不是優化")

# ── ★combo：市場有 sell stock + 買方經稅有 coin → deal fire（no_coin binding 破）──
func _test_combo_taxed_buyer_deals() -> void:
	# ★★★改測不刪（spec §4 #1b）：原場景「team.coin=0 起手 → 抽成員【既有】私產 → 買得成」
	#   ★在新規則下【結構上不成立】—— 而那不是這支測試壞了，是【那條路被刻意拿掉了】。
	#   ★★所以正向改成：**發薪後 team.coin 的增量來自【本次薪資流量的扣繳】**。
	print("--- ★所得稅：team.coin 的保留額來自【本次薪資流量】的扣繳 ---")
	var s := _mk_state()
	var vldr := PersonData.new(); vldr.id = 200; vldr.values = {"貪婪": 0.9, "慎重": 0.1}
	vldr.skills = {"統領": 0.5}
	s.persons[200] = vldr
	var visitor := TeamData.new(); visitor.team_id = 2; visitor.leader_id = 200
	visitor.resources = {"coin": 500.0, "food": 0.0}
	for i in range(9):
		var p := PersonData.new(); p.id = 300 + i; p.coin = 0.0
		p.skills = {"戰鬥": 0.5}
		s.persons[300 + i] = p; visitor.named_members.append(300 + i)
	s.teams[2] = visitor
	var tc0: float = float(visitor.resources.get("coin", 0))
	# ★★★儀器要【先開】：`incometax.amount` 是唯一能證明「稅真的發生了」的那一格 ——
	#   ★其餘斷言（團庫流出＝成員收到）在【稅率為 0 時也成立】⇒ 沒有這一格，
	#   ★★整套測試在稅完全沒生效時【照樣全綠】。
	#   ★★★而第一次跑它回 0.00 —— 那不是「稅沒發生」，是【Probe 沒開】：同一個 0 兩種意思。
	Probe.arm()
	var sal := SalarySystem.new()
	_salary_due_tick(s, sal, 2)
	var tc1: float = float(visitor.resources.get("coin", 0))
	var got: float = 0.0
	for pid in visitor.named_members: got += s.persons[pid].coin
	var withheld: float = Probe.amount("incometax.amount")
	var gross: float = Probe.amount("incometax.gross")
	_ok(got > 0.0, "有發薪：成員共收到 %.2f" % got)
	_ok(tc1 < tc0, "團庫有流出：%.1f → %.1f" % [tc0, tc1])
	# ★★★關鍵：**團庫【少流出】的那一份 ＝ 扣繳額**（而不是「先付再收回」）
	_ok(withheld > 0.0, "★扣繳額 = %.2f（★★非 0 才證明稅真的發生了）" % withheld)
	_ok(gross > 0.0 and absf(gross - withheld - got) < 0.001,
		"★★gross(%.3f) − 扣繳(%.3f) ＝ 成員收到(%.3f) ⇒ 三者對得起來" % [gross, withheld, got])
	_ok(absf((tc0 - tc1) - got) < 0.001,
		"★★★團庫流出(%.3f) ＝ 成員收到(%.3f) ⇒ 稅額從未離開團庫" % [tc0 - tc1, got])

