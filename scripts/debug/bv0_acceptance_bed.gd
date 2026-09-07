extends SceneTree

# ★★★B-v0 驗收（spec §5）——★一跑收齊 ①紅線 ②到期 3b款/貨分開 ④守恆 ⑤鑑別力 ⑥五個 tap
#
# ★★而本床每一格都印【分母】：spec §5③ 明寫「母體為空 ⇒ 判【不可判】不是判紅」。
#   ★★★而「不可判」在本床是【FAIL】—— 理由：一個沒有母體的驗收格【不能算通過】，
#     否則「機制沒被走到」與「機制正確」會拿到同一個判決。
#     ⇒ 它與「判紅」的差別在【訊息】，不在【顏色】：訊息要說得出是哪一種。
#
# 用法：BV0_MODE=normal|no_claim_account|no_claim_option（⑤鑑別力用）

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)
func _unjudgeable(m: String) -> void:
	_fail += 1; print("  [FAIL] ★不可判（母體為 0）：%s ―― 這不是紅燈，是【沒有資格說通過】" % m)

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _mk_outpost(state: WorldState, pos: Vector2i, owner: int) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos
	t.outpost_level = 1
	t.outpost_owner = owner
	state.world.tiles[pos.x * 1000 + pos.y] = t
	return t

func _run() -> void:
	var mode: String = OS.get_environment("BV0_MODE") if OS.has_environment("BV0_MODE") else "normal"
	print("=== bv0_acceptance_bed: mode=%s ===" % mode)
	if mode == "no_claim_option":
		print("  ★本床【測不到】這一格：「拿掉領取 option ⇒ 野外率掉到 0」")
		print("     需要的是【全世界長跑】的野外率，而本床是單元層 fixture。")
		print("     ★★而我【不假裝它測得到】――否則這一格會在一支根本沒有 option 迴圈的床上永遠綠。")
	var state: WorldState = MeasureBedHelper.arm_and_new()
	var os_ := OrderSystem.new()

	# ── 佈局：seller(隊2) 到【隊9 的市集】寄賣 ⇒ consign ⇒ 押貨 ──
	var host := TeamData.new(); host.team_id = 9; host.tile_pos = Vector2i(5, 5)
	AnonTierSystem.add_anon(host, "平民", 6)
	host.resources = {"coin": 500.0}
	var seller := TeamData.new(); seller.team_id = 2; seller.tile_pos = Vector2i(5, 5)
	AnonTierSystem.add_anon(seller, "平民", 5)
	# ★★★改用 food：run3 漏斗診斷指向 `trade.market_bail.buy_no_want`――
	#   `want = reserve(買家) − effective_holding`，而一個沒有任何需求的空隊
	#   對非生存品的 reserve 是 0 ⇒ ★它【不想要 goods】是正確行為，不是 bug。
	#   ⇒ ★★要測成交就要造一個【真的有需求】的買家：food 有真實的活命底線。
	# ★★★200 會讓自報價變 0：food target = pop×10 = 50，stock ≥ 2×target ⇒ 深過剩 ⇒ 價格 0
	#   ⇒ ★買家付 0 ⇒ 待領款 0 ⇒ ★★紅線那格【沒有錢可以追】，而那不是違憲
	#   （⑩ 裁過「爛大街＝白送」）。★★★選 60：shortage = (50−60)/50 = −0.2 ⇒ 價 = BASE×0.8 > 0
	seller.resources = {"food": 60.0, "coin": 0.0}
	state.teams[9] = host; state.teams[2] = seller
	var tile: HexTileData = _mk_outpost(state, Vector2i(5, 5), 9)

	var goods_before: float = float(seller.resources.get("food", 0))
	var oid: int = os_.post_order(state, seller, "sell", "food", 10)
	# ★★★第二張單：material――買家對它沒有需求（非生存品、reserve=0）
	#   ⇒ ★它【不會被買走】⇒ 留到到期 ⇒ ★★這才能同時測①成交與②到期。
	#   ★★★前一版只掛一張，而它全賣掉了 ⇒ ②【沒有母體】――
	#     而那不是②壞了，是一支床不能同時測【賣完】與【留著過期】。
	seller.resources["material"] = 40.0
	var oid2: int = os_.post_order(state, seller, "sell", "material", 8)
	_ok(oid2 >= 0 and oid2 != oid, "第二張單（material，無人要）oid=%d" % oid2)
	_ok(oid >= 0, "寄賣掛單成功 oid=%d" % oid)
	# ★★★前提斷言：紅線要追的是【錢】，而價格 0 的單沒有錢可以追。
	#   ★沒有這格，下面的「待領款 = 0」會看起來像違憲，而它只是【白送】。
	var _bp: float = -1.0
	for _e in tile.market_orders:
		if int(_e.get("order_id", -1)) == oid: _bp = float(_e.get("price", -1.0))
	_ok(_bp > 0.0, "前提：板上自報價 > 0（實際=%.4f）――否則紅線那格沒有錢可追" % _bp)

	# ── §5④ escrow 守恆：賣家 −qty ／ tile escrow +qty ──
	print("  ── ④ escrow 守恆 ──")
	var esc: Dictionary = tile.market_escrow.get(oid, {})
	print("     賣家 goods %.1f → %.1f ｜ tile escrow qty = %.1f"
		% [goods_before, float(seller.resources.get("food", 0)), float(esc.get("qty", 0.0))])
	_ok(not esc.is_empty(), "★押貨發生（寄賣才押；自家櫃檯不押）")
	_ok(is_equal_approx(goods_before - float(seller.resources.get("food", 0)), float(esc.get("qty", 0.0))),
		"★★賣家減量 == escrow 增量（零蒸發）")

	# ── §5① 紅線：外地賣家成交後 team.coin 不變、待領款帳 +額 ──
	print("  ── ① 紅線：成交後錢不得瞬移 ──")
	var buyer := TeamData.new(); buyer.team_id = 3; buyer.tile_pos = Vector2i(5, 5)
	AnonTierSystem.add_anon(buyer, "平民", 5)
	buyer.resources = {"coin": 300.0, "food": 0.0}   # ★空粮 ⇒ food 缺口真實存在
	state.teams[3] = buyer
	# ★★★紅線管的是【外地賣家不在場】――而我第一版把賣家留在同一格，
	#   ⇒ 走的是 `_market_peer_trade`（同格 peer），而【賣家在場時直接付款是合法的】。
	#   ★★實測：賣家 coin 0.00 → 39.20、待領款 0 ―― 而那不是違憲，是【我測了一個不是紅線的情境】。
	#   ★★★而它被抓到是因為那格印了【分母】與【賣家 coin 前後值】；
	#     若只斷言「待領款 > 0」，我會拿到一個紅燈然後去改 production。
	seller.tile_pos = Vector2i(30, 30)   # ★賣家離場：這才是【外地掛單】
	var seller_coin_before: float = float(seller.resources.get("coin", 0))
	var isys := InteractionSystem.new()
	var _dealt: bool = isys._resolve_market_at_outpost(state, buyer, tile)
	print("     撮合被走到：dealt=%s" % str(_dealt))
	# ★★★§5⑤ 鑑別力：把【待領帳】拿掉 ⇒ 判準①必須紅。
	#   ★血證：本檔檔頭從一開始就寫著 BV0_MODE，而它【只被讀進變數、從來沒被使用】――
	#     那是 money_genesis_bed 的 MG_HANDWRITTEN 的孫生兄弟，而我在批評完那一個之後自己又寫了一個。
	#   ★★誠實限：本模式是【模擬反事實】（把 claim 搬進賣家口袋），
	#     不是真的把 production 的待領帳拆掉 ⇒ 它證明的是【斷言有鑑別力】，
	#     而不是【production 拿掉待領帳之後會怎樣】。★★★兩者不同，我不混。
	if mode == "no_claim_account":
		var _moved: float = 0.0
		var _keep: Array = []
		for c in tile.pending_claims:
			if String(c.get("kind", "")) == "coin" and int(c.get("owner_team", -1)) == 2:
				_moved += float(c.get("amt", 0.0))
			else:
				_keep.append(c)
		tile.pending_claims = _keep
		if _moved > 0.0:
			ResourceBank.add(seller, "coin", _moved, "bv0_discriminator_direct_pay")
		print("     [⑤] 鑑別力模式 no_claim_account：把 %.2f 從待領帳搬進賣家口袋" % _moved)
	# ★★★claims_coin 必須在【鑑別力模式操作之後】算。
	#   ★血證：前一版先算再搬 ⇒ no_claim_account 模式下它印 11.20（舊值），
	#     於是【賣家 coin 不變】紅了、而【待領款 > 0】照樣綠――
	#     ★★一個對照只讓一半的斷言動，另一半在讀舊值，而那比完全沒有對照更難看出來。
	var claims_coin: float = 0.0
	for c in tile.pending_claims:
		if String(c.get("kind", "")) == "coin" and int(c.get("owner_team", -1)) == 2:
			claims_coin += float(c.get("amt", 0.0))
	print("     分母（tile 上的 pending_claims 條數）= %d" % tile.pending_claims.size())
	print("     賣家 coin %.2f → %.2f ｜ 待領款 = %.2f"
		% [seller_coin_before, float(seller.resources.get("coin", 0)), claims_coin])
	# ★★★【有沒有母體】要用 `_dealt`（成交有沒有發生）判，
	#   不能用【claims 是不是空的】――★因為鑑別力模式會把 claims 搞空，
	#   ⇒ ★★對照會把自己偽裝成【沒有母體】，而那正好讓它避開它要觸發的那條紅。
	if not _dealt:
		_unjudgeable("這一輪沒有任何成交發生 ⇒ 紅線沒有被測到（不是紅線沒被違反）")
	else:
		_ok(is_equal_approx(float(seller.resources.get("coin", 0)), seller_coin_before),
			"★賣家 team.coin 不變（錢沒有瞬移）")
		_ok(claims_coin > 0.0, "★★待領款帳 > 0（錢落在市場等他來領）")

	# ── §5② 到期：貨不回家，落待領貨帳 ──
	print("  ── ② 到期退貨 ──")
	var esc_now: Dictionary = tile.market_escrow.get(oid2, {})   # ★讀第二張（沒人要的那張）
	var esc_qty: float = float(esc_now.get("qty", 0.0))
	if esc_qty <= 0.0:
		_unjudgeable("escrow 已空（全成交）⇒ 到期路徑沒有母體可測")
	else:
		var g_before: float = float(seller.resources.get("material", 0))
		state.world.current_tick += OrderSystem.ORDER_LIFETIME + 1
		os_.tick_team_orders(state, seller)
		var goods_claim: float = 0.0
		for c in tile.pending_claims:
			if String(c.get("kind", "")) == "goods" and int(c.get("owner_team", -1)) == 2:
				goods_claim += float(c.get("amt", 0.0))
		print("     到期前 escrow=%.1f ｜ 賣家 goods %.1f → %.1f ｜ 待領貨 = %.1f"
			% [esc_qty, g_before, float(seller.resources.get("material", 0)), goods_claim])
		_ok(is_equal_approx(float(seller.resources.get("material", 0)), g_before),
			"★貨【沒有】回到賣家 resources（不瞬移）")
		_ok(is_equal_approx(goods_claim, esc_qty), "★★待領貨帳 == 原 escrow 量（零蒸發）")
		_ok(tile.market_escrow.get(oid2, {}).is_empty(), "★★★escrow 已搬空（不是兩邊都有＝重複計數）")

	# ── §5-3b 款與貨分開量 ──
	print("  ── 3b 款／貨分開量（★抽象共用不代表被同等使用）──")
	var n_coin: int = 0
	var n_goods: int = 0
	for c in tile.pending_claims:
		if String(c.get("kind", "")) == "coin": n_coin += 1
		elif String(c.get("kind", "")) == "goods": n_goods += 1
	print("     待領款條數 = %d ｜ 待領貨條數 = %d ｜ 合計 = %d" % [n_coin, n_goods, tile.pending_claims.size()])
	_ok(n_coin + n_goods == tile.pending_claims.size(), "★兩種 kind 窮盡（沒有第三種悄悄混進來）")

	# ── §5⑥ 五個 tap 全量 ──
	print("  ── ⑥ 五個 tap（掛單／成交／待領餘額／領取／到期）──")
	var taps: Array = ["mkt.post.consign", "mkt.escrow.post", "mkt.claim.add", "mkt.claim.take", "mkt.escrow.expire_to_claim"]
	for t in taps:
		print("     %-32s = %d" % [t, int(Probe.counts.get(t, 0))])
	# ★★★診斷欄：「dealt=false」有很多種成因，而【不印出來就只能猜】。
	#   ★母體 `mkfill.attempt.*` 先答【撮合有沒有被走到】，
	#     bail 逐種再答【走到了而在哪一關死】――兩個問題不能混成一個數。
	print("  ―― 診斷：撮合走到哪裡 ――")
	var diag: Array = []
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("mkfill.") or ks.begins_with("trade.market_bail.") or ks.begins_with("board.price.") or ks.begins_with("g1."):
			diag.append("%s=%d" % [ks, int(Probe.counts[k])])
	diag.sort()
	print("     " + (" ｜ ".join(diag) if not diag.is_empty() else "★一個相關 tap 都沒有 ⇒ 撮合迴圈連進都沒進"))
	print("     ★★而【待領餘額】是存量、上面那些是流量 —— 分開印，不混成一個數")
	var bal: float = 0.0
	for c in tile.pending_claims: bal += float(c.get("amt", 0.0))
	print("     待領餘額（存量）= %.2f" % bal)
