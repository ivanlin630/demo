extends SceneTree

# ★★★board-declared-price 驗收（spec 2026-09-07 §5）
#
# ★本測守的是【價格能不能走完全程】：
#   掛單(order_system:78) → 板 entry → 親讀轉訊息(:286) → 隨隊移動 → relay deposit(:341) → 另一塊板
#   ⇒ ★★中間換了兩次載體（entry ↔ message.params），而每次換載體都是逐 key 明列
#     ⇒ 每一次都是【漏掉一個 key 就靜默失效】的機會
#
# ★★★而 §5① 那格（relayed entry 帶得到價的比例 == 1.0）如果只斷言比例，
#   它在【一張 relayed 單都沒有】時照樣是綠的（空集合的比例是 0/0）。
#   ⇒ 所以每一格都印【分母】，而分母為 0 時判【不可判】而不是判綠。

var _fail: int = 0

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_outpost(state: WorldState, pos: Vector2i, owner: int) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos
	t.outpost_level = 1
	t.outpost_owner = owner
	state.world.tiles[pos.x * 1000 + pos.y] = t
	return t

func _run() -> void:
	var state: WorldState = MeasureBedHelper.arm_and_new()
	var os := OrderSystem.new()

	# ── 佈局：seller(隊2) 在自家市集掛賣單；visitor(隊1) 去讀；再把消息 deposit 到隊3 的板 ──
	var seller := TeamData.new(); seller.team_id = 2; seller.tile_pos = Vector2i(2, 0)
	AnonTierSystem.add_anon(seller, "平民", 5)   # ★population 是 getter，直接賦值會被 set(_value): pass 吞掉
	# ★★★存量刻意選【不是深過剩】：若 goods 堆到自評值掉到 0，
	#   下面整條帶價鏈就是【拿 0 去比 0】——而一個【到處寫 0】的 bug 會全部通過。
	#   ★這是我第一版寫錄真的踩到的（native price 量出來就是 0.0000）。
	seller.resources = {"goods": 12.0, "coin": 50.0}
	var visitor := TeamData.new(); visitor.team_id = 1; visitor.tile_pos = Vector2i(2, 0)
	AnonTierSystem.add_anon(visitor, "平民", 5)   # ★population 是 getter，直接賦值會被 set(_value): pass 吞掉
	var third := TeamData.new(); third.team_id = 3; third.tile_pos = Vector2i(9, 0)
	AnonTierSystem.add_anon(third, "平民", 5)   # ★population 是 getter，直接賦值會被 set(_value): pass 吞掉
	state.teams[1] = visitor; state.teams[2] = seller; state.teams[3] = third
	var t_sell: HexTileData = _mk_outpost(state, Vector2i(2, 0), 2)
	var t_far: HexTileData = _mk_outpost(state, Vector2i(9, 0), 3)

	# ★★★前提驗證（寫在看任何價格之前）：
	#   TeamData.population 是 getter，而它的 setter 是 `set(_value): pass`――【靕默吞掉寫入】。
	#   ★我第一版直接賦值，而 pop 一直是 0
	#     ⇒ target = pop×3 = 0 ⇒ shortage 極負 ⇒【任何存量都算深過剩】⇒ 價格恒 0
	#   ★★而我第一次看到 0 時診斷成「存量開太大」，把 80 改成 12
	#     ⇒ ★★★改對了數字，而真正的原因一步都沒動。
	_ok(seller.population > 0, "前提：seller 真的有人（pop=%d）――沒這格，下面每一個價格都是在量一個空隣" % seller.population)
	var oid: int = os.post_order(state, seller, "sell", "goods", 10)
	_ok(oid >= 0, "掛單成功 oid=%d" % oid)

	# ── §5①-a：原生 entry 帶得到價 ──
	print("  ── ① 原生掛單 → 板 entry ──")
	print("     分母（板上原生 entry 數）= %d" % t_sell.market_orders.size())
	_ok(t_sell.market_orders.size() == 1, "板上恰有 1 筆原生 entry（★分母不是 0）")
	var native_price: float = float(t_sell.market_orders[0].get("price", -1.0))
	print("     native price = %.4f" % native_price)
	_ok(native_price >= 0.0, "原生 entry 的 price 欄存在且非哨兵（-1.0 ＝ 沒帶到）")
	_ok(native_price > 0.0, "★★★自報價 > 0：不能拿 0 去驗【值沒變】——否則一個【到處寫 0】的 bug 會全部通過")

	# ── §5②：出發前看到的價 == 到場用的價（同一張單，兩個時刻）──
	# 出發前＝visitor 親讀板得到的 message；到場用＝撮合時讀的 entry。
	print("  ── ② 出發前看到的價 vs 到場用的價 ──")
	os.read_market_board(state, visitor)   # ★它自己從 team.tile_pos 取 tile
	var seen: float = -999.0
	for m in state.team_known.get(1, []):
		if m.type == "order_sell" and int(m.params.get("order_id", -1)) == oid:
			seen = float(m.params.get("price", -1.0))
	print("     出發前(message.params.price) = %.4f ｜ 到場(entry.price) = %.4f" % [seen, native_price])
	_ok(seen >= 0.0, "訊息載體帶得到價（★這一格紅＝order_system:286 漏抄，spec §2 原本沒列到的那站）")
	_ok(is_equal_approx(seen, native_price), "兩個時刻同價（凍結語意）")

	# ── §5①-b：relay deposit 到【另一塊板】仍帶得到價 ──
	print("  ── ③ relay deposit → 遠處的板 ──")
	visitor.tile_pos = Vector2i(9, 0)
	os.read_market_board(state, visitor)   # ★同一支函式兼做 deposit（S-prop）
	var relayed: Array = []
	for e in t_far.market_orders:
		if bool(e.get("relayed", false)): relayed.append(e)
	print("     分母（relayed entry 數）= %d" % relayed.size())
	if relayed.is_empty():
		_fail += 1
		print("  [FAIL] ★不可判：relayed 母體為 0 ⇒ 這一格【沒有資格說通過】（不是綠）")
	else:
		var with_price: int = 0
		for e in relayed:
			if float(e.get("price", -1.0)) >= 0.0: with_price += 1
		print("     帶得到價 = %d / %d" % [with_price, relayed.size()])
		_ok(with_price == relayed.size(), "relayed entry 帶價比例 == 1.0（§5①）")
		_ok(is_equal_approx(float(relayed[0].get("price", -1.0)), native_price), "跨兩次載體轉換後價格未變")

	# ── §5③：套利兩邊各一格【正數】對照 ──
	print("  ── ④ 套利剩餘：兩邊各要有正數（★不是「有欄位」）──")
	# 賣邊正數：third 手上有 goods，而 buyer 掛的買單自報價高於 third 自評 ⇒ 剩餘 > 0
	var buyer := TeamData.new(); buyer.team_id = 4; buyer.tile_pos = Vector2i(10, 0)
	AnonTierSystem.add_anon(buyer, "平民", 5)   # ★population 是 getter，直接賦值會被 set(_value): pass 吞掉
	buyer.resources = {"goods": 0.0, "coin": 200.0}   # 缺 goods ⇒ local_value 高 ⇒ bid 高
	state.teams[4] = buyer
	var t_buy: HexTileData = _mk_outpost(state, Vector2i(10, 0), 4)
	var boid: int = os.post_order(state, buyer, "buy", "goods", 10)
	var bprice: float = -1.0
	for e in t_buy.market_orders:
		if int(e.get("order_id", -1)) == boid: bprice = float(e.get("price", -1.0))
	print("     buyer 自報 bid = %.4f（缺貨 ⇒ 該高）" % bprice)
	_ok(bprice > 0.0, "買單自報價 > 0（★缺貨方的估值不該是 0）")

	third.resources = {"goods": 60.0, "coin": 10.0}   # 過剩 ⇒ 自評低（⑩ 拆 clamp 後可能是 0）
	third.tile_pos = Vector2i(10, 1)
	for m in state.global_messages:
		if m.type == "order_buy" and int(m.params.get("order_id", -1)) == boid:
			state.team_known[3] = state.team_known.get(3, []) + [m]
	var best: Dictionary = os.best_arbitrage_order(state, third)
	var own_val: float = TradeValuation.local_value(third, "goods", state)
	print("     third 自評 goods = %.4f ｜ 剩餘 = (%.4f − %.4f) × qty" % [own_val, bprice, own_val])
	_ok(not best.is_empty(), "★賣邊：他報的價高於我的估值 ⇒ 套利單被選中（★而舊式子在 own_val==0 時 gain==0 ⇒ 選不出來）")
	if not best.is_empty():
		_ok(int(best.get("origin_team", -1)) == 4, "選中的是那張買單的發起隊")
	print("     tap: arb_surplus.buy=%d arb_proxy.buy=%d" % [
		int(Probe.counts.get("trade.arb_surplus.buy", 0)), int(Probe.counts.get("trade.arb_proxy.buy", 0))])
	_ok(int(Probe.counts.get("trade.arb_surplus.buy", 0)) > 0,
		"★走的是【剩餘】那條路，不是舊 proxy（★沒有這格，公式換了但沒被走到分不出來）")

	# ── ⑤ 鑑別力：把價格拿掉 ⇒ 上面那格必須紅 ──
	print("  ── ⑤ 鑑別力（★把機制關掉，這條還會綠嗎）──")
	for m in state.team_known.get(3, []):
		if m.type == "order_buy": m.params.erase("price")
	var before_proxy: int = int(Probe.counts.get("trade.arb_proxy.buy", 0))
	var best_noprice: Dictionary = os.best_arbitrage_order(state, third)
	var after_proxy: int = int(Probe.counts.get("trade.arb_proxy.buy", 0))
	print("     去價後 proxy 計數 %d → %d ｜ best 空? %s" % [before_proxy, after_proxy, str(best_noprice.is_empty())])
	_ok(after_proxy > before_proxy, "★沒有 price 就退回舊 proxy（哨兵 -1.0 真的在分辨「沒帶到」與「價是 0」）")
