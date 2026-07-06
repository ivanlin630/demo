extends SceneTree

# ★ 序8 灰項 dispatch 溶入引擎 融合驗（憲法溶入 arc 最後一張，8 違憲末張）。
#   溶=融合非刪：strategic_ai._dispatch_trade_net（繞引擎 TaskArbiter.try_set TASK_TRADE）撕除 →
#   致富 faction 商隊成員走引擎（貿易/買糧/囤貨 option）交易。
#
#   baseline（seed 1337 6月 trade_funnel_bed 實測）：
#     站4 dispatch=68：ambient=32 solo=36 **trade.dispatch.trade_net=0 unified_貿易=0**
#     → _dispatch_trade_net 6月零派發＝已冗餘死路（引擎 ambient/solo 承接全 trade dispatch）。刪＝零漂移。
#
#   融合驗錨：
#     ① repertoire：致富商隊 ctx → 貿易/買糧/囤貨 引擎可達（rank_scored_ctx applicable，非靠 _dispatch_trade_net）。
#     ② ★冗餘證（world-based）：餓商隊+coin+鄰市集 → _decide_unified → TASK_TRADE
#        （引擎已派 trade，_dispatch_trade_net 的 TASK_TRADE 重複=刪不損 repertoire；鏡射 buyfood integration）。
#     ③ gap 檢：純買家（coin 無 goods 無 arb）致富商隊 → 引擎承接分析（囤貨 market+surplus 覆蓋 / 買糧 hungry 覆蓋 /
#        僅市場全不可達 case 無 option＝與 trade_net 需 outpost partner 同限，非新 gap）。
#   ①②任一破 = 融合失敗；③純記錄（gap 分析）。

var _fails: int = 0

func _initialize() -> void:
	print("=== 序8 灰項 dispatch 溶入引擎 融合驗 ===")
	_check_repertoire()   # ①
	_check_redundancy()   # ②
	_check_buyer_gap()    # ③
	if _fails == 0:
		print("[greylist-dissolution] ALL PASS")
	else:
		print("[greylist-dissolution] FAIL count=%d" % _fails)
	quit()

# ─────────── ① repertoire（致富商隊 貿易/買糧/囤貨 引擎可達）───────────
func _check_repertoire() -> void:
	print("--- ① repertoire（貿易/買糧/囤貨 引擎 applicable，非靠 trade_net）---")
	# 貿易：商隊 + 有貨 → 貿易 option 可達（economic_opp 路，_merchant_trade_target 承接原 trade_net outpost 派）
	var ct := _mk_ctx({"貪婪": 0.8, "野心": 0.4})
	ct.is_merchant = true; ct.has_goods = true; ct.intent = "致富"
	ct.leader_values["_is_merchant"] = true
	_assert_in("商隊+有貨 → 貿易", "貿易", _opts(ct))
	# 囤貨：致富 intent + 餘糧（food_days≥SURPLUS 7）+ 貿易機會（arb）→ 囤貨 option 可達
	var ch := _mk_ctx({"貪婪": 0.8, "野心": 0.4})
	ch.is_merchant = true; ch.intent = "致富"; ch.food_days = 14.0; ch.has_arb = true
	_assert_in("致富+餘糧+arb → 囤貨", "囤貨", _opts(ch))
	# 買糧：餓（food_days<DESPERATION 3）+ 有市集 + 有錢 → 買糧 option 可達（純買家餓路）
	var cb := _mk_ctx({"貪婪": 0.6})
	cb.is_merchant = true; cb.food_days = 1.0; cb.has_food_market = true; cb.has_specie = true
	cb.leader_values["_is_merchant"] = true
	_assert_in("餓+市集+有錢 → 買糧", "買糧", _opts(cb))

# ─────────── ② ★冗餘證（world-based：引擎已派 TASK_TRADE，trade_net 重複）───────────
# 餓商隊 + coin + 鄰市集 → _decide_unified → TASK_TRADE（引擎路實派）。
# 改前 _dispatch_trade_net 亦把 idle 商隊派 TASK_TRADE 到 outpost = 同一 team 同一 task 重複派 → 刪不損 repertoire。
func _check_redundancy() -> void:
	print("--- ② ★冗餘證（引擎 _decide_unified 已派 TASK_TRADE，trade_net 重複）---")
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	var m := _mk_merchant(s, Vector2i(0, 0), 500.0)   # 餓商隊 coin=500
	_mk_market_outpost(s, Vector2i(1, 0))             # 鄰市集 outpost（owner 99，售糧）
	var fai := FactionAISystem.new()
	fai._decide_unified(s, m)
	if m.current_task == TeamData.TASK_TRADE:
		print("[redundancy] 餓商隊+coin+市集 → 引擎 _decide_unified 派 TASK_TRADE OK（trade_net 派同 task=重複，刪不損）")
	else:
		_fails += 1
		print("[FAIL redundancy] 引擎未派 TASK_TRADE 得 %s（冗餘證不成立）" % m.current_task)

# ─────────── ③ gap 檢（純買家：coin 無 goods 無 arb 致富商隊）───────────
# 純觀測分析，非 assert-fail：紀錄引擎覆蓋純買家的路徑。
func _check_buyer_gap() -> void:
	print("--- ③ gap 檢（純買家 coin/無goods/無arb 致富商隊 引擎承接分析）---")
	# case A：純買家 + 有市集 + 有餘糧（非餓）→ 囤貨 承接（致富+surplus+food_market）
	var ca := _mk_ctx({"貪婪": 0.8, "野心": 0.4})
	ca.is_merchant = true; ca.intent = "致富"; ca.has_specie = true
	ca.has_goods = false; ca.has_arb = false
	ca.food_days = 14.0; ca.has_food_market = true
	var opts_a: Array = _opts(ca)
	if "囤貨" in opts_a:
		print("[gap] 純買家+市集+餘糧 → 囤貨 承接 OK（引擎覆蓋，非 gap）opts=%s" % str(opts_a))
	else:
		_fails += 1
		print("[FAIL gap] 純買家+市集+餘糧 引擎無 囤貨/貿易 承接 opts=%s" % str(opts_a))
	# case B：純買家 + 有市集 + 餓 → 買糧 承接（① 已驗，此處交叉確認同 ctx 型態）
	var cb := _mk_ctx({"貪婪": 0.6})
	cb.is_merchant = true; cb.intent = "致富"; cb.has_specie = true
	cb.has_goods = false; cb.has_arb = false
	cb.food_days = 1.0; cb.has_food_market = true
	var opts_b: Array = _opts(cb)
	print("[gap] 純買家+市集+餓 → 買糧承接=%s opts=%s" % [str("買糧" in opts_b), str(opts_b)])
	# case C（記錄，非 fail）：純買家 + 全無市場可達（無 arb 無 food_market 無 goods）→ 引擎無 trade option。
	#   ＝ 與 _dispatch_trade_net 需 outpost partner 同限（無可達對象＝無交易），非本次刪除引入的新 gap。
	var cc := _mk_ctx({"貪婪": 0.8})
	cc.is_merchant = true; cc.intent = "致富"; cc.has_specie = true
	cc.food_days = 14.0
	var opts_c: Array = _opts(cc)
	var trade_reachable: bool = ("貿易" in opts_c) or ("囤貨" in opts_c) or ("買糧" in opts_c)
	print("[gap] 純買家+無市場可達 → trade option 可達=%s（記錄：與 trade_net 需 outpost 同限，非新 gap）opts=%s" % [
		str(trade_reachable), str(opts_c)])

# ─────────── helpers ───────────
func _assert_in(label: String, want: String, opts: Array) -> void:
	if want in opts:
		print("[repertoire] %s OK (opts=%s)" % [label, str(opts)])
	else:
		_fails += 1
		print("[FAIL repertoire] %s 缺 %s (opts=%s)" % [label, want, str(opts)])

func _mk_ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0
	c.population = 20
	c.threat_threshold = 999.0
	c.self_armed_ratio = 0.5
	return c

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(e["opt"])
	return out

# 餓商隊：TAG_MERCHANT、food 低使 food_days<3、pop>15（排覓食）、無 home、coin 參數。
func _mk_merchant(state: WorldState, pos: Vector2i, coin: float) -> TeamData:
	var m := TeamData.new(); m.team_id = 0; m.tile_pos = pos; m.faction_id = -1
	m.tags = [TeamData.TAG_MERCHANT]
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	ldr.values = {"貪婪": 0.7, "好戰": 0.2, "殘忍": 0.1, "野心": 0.4}; ldr.loyalty = 0.5
	state.persons[1] = ldr; m.leader_id = 1
	AnonCohort.add(m.anon_cohorts, "平民", "healthy", 20)
	m.resources = {"food": 5.0, "coin": coin, "goods": 5.0}
	state.teams[0] = m
	return m

# 鄰市集 outpost（level≥1 + 非該隊 owner + 售糧 + 有居民團）
func _mk_market_outpost(state: WorldState, pos: Vector2i) -> void:
	var key: int = pos.x * 1000 + pos.y
	if not state.world.tiles.has(key):
		var t := HexTileData.new(); t.tile_pos = pos; t.terrain = "plains"
		state.world.tiles[key] = t
	var mkt: HexTileData = state.world.tiles[key]
	mkt.outpost_level = 2; mkt.outpost_owner = 99
	mkt.public_storage = {"food": 5000.0}
	var seller := TeamData.new(); seller.team_id = 99; seller.tile_pos = pos; seller.faction_id = -1
	var s_ldr := PersonData.new(); s_ldr.id = 990; s_ldr.team_id = 99
	state.persons[990] = s_ldr; seller.leader_id = 990
	AnonCohort.add(seller.anon_cohorts, "平民", "healthy", 10)
	seller.resources = {"food": 5000.0, "coin": 100.0}
	state.teams[99] = seller
