extends SceneTree

# 後勤 SLICE B 領主分配政策 dev-verify（HOW spec 2026-08-01 §3）。
# 統一光譜:給免費(義氣)←賣公道→賣高價(貪)→拋棄。★三人格同一機制 seed 出 + 連續非 gate + coin 守恆。
# 純算術零 RNG（determinism 保）。unit 級（機制驗）；emergence(unrest→defection) 走 §5 一次合量 warring。

var _fail: int = 0

func _initialize() -> void:
	_test_price_factor_spectrum()
	_test_price_factor_continuous_not_gate()
	_test_distribute_candidate_fires_persona()
	_test_descan_no_runway_gate()          # ★資訊網 de-scan：憑送達 belief(buy-order)fire、不讀 resident live runway/死常數門檻
	_test_free_distribute_coin_conserving()
	_test_paid_distribute_coin_conserving()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

# price_factor = clamp((0.5+greed)/(0.5+honor),0,CAP)：仁君→0 免費 / neutral→1 公道 / 貪→markup 高價。
func _pf(greed: float, honor: float) -> float:
	return clampf((0.5 + greed) / (0.5 + honor), 0.0, GoalResolver.PRICE_MARKUP_CAP)

func _test_price_factor_spectrum() -> void:
	var benev: float = _pf(0.0, 1.0)   # 仁君:義氣 max、貪 0
	var neutral: float = _pf(0.5, 0.5)  # 公道
	var greedy: float = _pf(1.0, 0.0)   # 貪 max、義氣 0
	if benev < neutral and abs(neutral - 1.0) < 0.001 and greedy > neutral:
		_ok("price 光譜:仁君=%.2f<公道=%.2f(=1.0)<貪=%.2f(markup)" % [benev, neutral, greedy])
	else:
		_bad("price 光譜錯:仁君=%.2f 公道=%.2f 貪=%.2f" % [benev, neutral, greedy])

func _test_price_factor_continuous_not_gate() -> void:
	# 掃 greed 0→1（honor 反向 1→0）→ price_factor 單調連續（無階梯跳=WEIGH 非 GATE）。
	var prev: float = -1.0
	var max_step: float = 0.0
	for i in range(21):
		var g: float = float(i) / 20.0
		var pf: float = _pf(g, 1.0 - g)
		if prev >= 0.0:
			max_step = maxf(max_step, absf(pf - prev))
		prev = pf
	# 連續:相鄰步 < 明顯階梯(CAP/4)；單調非硬 gate 跳。
	if max_step < GoalResolver.PRICE_MARKUP_CAP / 4.0:
		_ok("price_factor 連續(掃 greed 0→1 max step=%.3f<CAP/4)=WEIGH 非 GATE" % max_step)
	else:
		_bad("price_factor 有階梯跳 max_step=%.3f=疑硬 gate" % max_step)

# _distribute_candidates:仁君 fire(relief 大)、貪 fire(coin 大);deficit 居民 buy-order。
func _test_distribute_candidate_fires_persona() -> void:
	for persona in [{"n": "仁君", "g": 0.0, "h": 1.0}, {"n": "貪剝", "g": 1.0, "h": 0.0}]:
		var setup: Array = _mk_lord_state(float(persona["g"]), float(persona["h"]))
		var state: WorldState = setup[0]; var lord: TeamData = setup[1]
		var ctx: DecisionContext = DecisionContext.gather(state, lord)
		var lv: Dictionary = TradeValuation.leader_vals(state, lord)
		var cands: Array = GoalResolver._distribute_candidates(state, lord, ctx, lv)
		var fired: Dictionary = {}
		for c in cands:
			if String(c.get("label", "")) == "distribute_food":
				fired = c; break
		if not fired.is_empty() and fired.get("to_task", {}).get("kind", "") == "distribute" \
				and int(fired["to_task"].get("terminus_team_id", -1)) == 2:
			_ok("%s distribute candidate fire:util=%.3f price_factor=%.2f target=居民" % [
				persona["n"], float(fired.get("util", 0)), float(fired["to_task"].get("price_factor", -1))])
		else:
			_bad("%s distribute candidate 未 fire(cands=%d)" % [persona["n"], cands.size()])

# ★資訊網 de-scan（arc 最後一哩）：領主憑「聽到的」buy-order(belief) fire distribute，
# 不再直讀 resident live runway/死常數門檻。RED=舊碼 resident food 高(runway>DISTRIB_DEFICIT_DAYS)→continue skip。
func _test_descan_no_runway_gate() -> void:
	var setup: Array = _mk_lord_state(0.5, 0.5)   # neutral persona
	var state: WorldState = setup[0]; var lord: TeamData = setup[1]
	# resident food 拉高（runway 遠超舊 DISTRIB_DEFICIT_DAYS=4.0）——舊碼會 skip；de-scan 憑 buy-order belief 仍 fire。
	var resident: TeamData = state.teams[2]
	ResourceBank.set_amt(resident, "food", 999.0, "descan")   # runway 999/(5×0.8)≈250 >> 4.0
	var ctx: DecisionContext = DecisionContext.gather(state, lord)
	var lv: Dictionary = TradeValuation.leader_vals(state, lord)
	var cands: Array = GoalResolver._distribute_candidates(state, lord, ctx, lv)
	var fired: bool = false
	for c in cands:
		if String(c.get("label", "")) == "distribute_food": fired = true; break
	if fired:
		_ok("de-scan:resident runway≈250(遠>舊門檻4.0)仍 fire distribute=憑送達 belief(buy-order)非讀 live runway/死常數")
	else:
		_bad("de-scan 破:resident food 高→未 fire=仍讀 live runway god-view 或死常數門檻殘留")

# 免費分配(override_ask=0):食物轉入居民、居民 coin 不變、coin 守恆(lord+resident 總 coin 不變)。
func _test_free_distribute_coin_conserving() -> void:
	var st: Array = _mk_sell_fixture()
	var state: WorldState = st[0]; var porter: TeamData = st[1]; var resident: TeamData = st[2]; var tile: HexTileData = st[3]
	var rcoin0: float = float(resident.resources.get("coin", 0))
	var rfood0: float = float(tile.public_storage.get("food", 0))
	var pfood0: float = float(porter.resources.get("food", 0))
	var ok: bool = InteractionSystem.new()._market_visitor_sell(state, porter, resident, tile, 77, "food", 100, {}, 40.0, 0.0)
	var deposited: float = float(tile.public_storage.get("food", 0)) - rfood0
	var rcoin_delta: float = float(resident.resources.get("coin", 0)) - rcoin0
	if ok and deposited > 0.0 and abs(rcoin_delta) < 0.001 and abs((pfood0 - float(porter.resources.get("food", 0))) - deposited) < 0.001:
		_ok("免費分配:食物轉 %.0f 入居民、居民 coin 不變(δ=%.1f)、porter−==granary+ 守恆" % [deposited, rcoin_delta])
	else:
		_bad("免費分配破:ok=%s deposited=%.1f coinδ=%.1f" % [str(ok), deposited, rcoin_delta])

# 付費分配(override_ask>0):居民付 coin→lord(porter)、coin 守恆(居民付=porter 收)。
func _test_paid_distribute_coin_conserving() -> void:
	var st: Array = _mk_sell_fixture()
	var state: WorldState = st[0]; var porter: TeamData = st[1]; var resident: TeamData = st[2]; var tile: HexTileData = st[3]
	var rcoin0: float = float(resident.resources.get("coin", 0))
	var pcoin0: float = float(porter.resources.get("coin", 0))
	var ask: float = 3.0   # 付費
	var ok: bool = InteractionSystem.new()._market_visitor_sell(state, porter, resident, tile, 77, "food", 100, {}, 40.0, ask)
	var rcoin_paid: float = rcoin0 - float(resident.resources.get("coin", 0))
	var pcoin_got: float = float(porter.resources.get("coin", 0)) - pcoin0
	if ok and rcoin_paid > 0.0 and abs(rcoin_paid - pcoin_got) < 0.001:
		_ok("付費分配:居民付 %.0f coin==porter 收 %.0f(coin 守恆,領主抽 coin)" % [rcoin_paid, pcoin_got])
	else:
		_bad("付費分配 coin 破:ok=%s 付=%.1f 收=%.1f" % [str(ok), rcoin_paid, pcoin_got])

# ── fixtures ──
# lord(faction leader,food surplus)+resident(同 faction,deficit,持 coin,掛 food buy-order @自有 outpost)。
func _mk_lord_state(greed: float, honor: float) -> Array:
	var state := WorldState.new()
	# faction
	var fac := FactionData.new(); fac.faction_id = 1; fac.leader_team_id = 1
	state.factions[1] = fac
	# lord team1(領主,faction leader,food surplus,pop 足)
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 1; lord.tile_pos = Vector2i(1, 1)
	ResourceBank.set_amt(lord, "food", 500.0, "t"); ResourceBank.set_amt(lord, "coin", 500.0, "t")
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 9)   # pop≥CONVOY_MIN
	var ll := PersonData.new(); ll.id = 1; ll.team_id = 1; ll.values = {"貪婪": greed, "義氣": honor, "慎重": 0.5}
	lord.leader_id = ll.id; state.persons[1] = ll
	state.teams[1] = lord
	# resident team2(同 faction,居民=PRODUCE+站自有 outpost,deficit,持 coin)
	var res := TeamData.new(); res.team_id = 2; res.faction_id = 1; res.tile_pos = Vector2i(5, 5)
	res.tags = [TeamData.TAG_PRODUCE]
	ResourceBank.set_amt(res, "food", 2.0, "t"); ResourceBank.set_amt(res, "coin", 200.0, "t")   # deficit food
	AnonCohort.add(res.anon_cohorts, "平民", "healthy", 5)
	var rl := PersonData.new(); rl.id = 2; rl.team_id = 2; rl.values = {"慎重": 0.5}
	res.leader_id = rl.id; state.persons[2] = rl
	state.teams[2] = res
	# resident 自有 outpost tile @(5,5)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.outpost_owner = 2; tile.outpost_level = 1
	tile.resource_cap["food"] = 10000.0
	state.world.tiles[5005] = tile
	# resident 掛 food buy-order（belief 注入 lord team_known:order_buy food origin=2 @(5,5)）
	var msg := MessageData.new(); msg.type = "order_buy"
	msg.params = {"res": "food", "qty": 64, "origin_team": 2, "origin_pos": Vector2i(5, 5), "order_id": 77}
	state.team_known[1] = [msg]
	return [state, lord]

# _market_visitor_sell fixture:porter(帶 food cargo)、resident(owner,買方,持 coin)、tile(buy food order)。
func _mk_sell_fixture() -> Array:
	var state := WorldState.new()
	var porter := TeamData.new(); porter.team_id = 9
	ResourceBank.set_amt(porter, "food", 100.0, "t")
	state.teams[9] = porter
	var resident := TeamData.new(); resident.team_id = 2; resident.tile_pos = Vector2i(5, 5)
	ResourceBank.set_amt(resident, "coin", 1000.0, "t")
	resident.active_orders = [{"order_id": 77, "res": "food", "kind": "buy", "qty_remaining": 100}]
	state.teams[2] = resident
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5, 5); tile.outpost_owner = 2; tile.outpost_level = 1
	tile.resource_cap["food"] = 10000.0
	tile.market_orders = [{"order_id": 77, "res": "food", "kind": "buy", "qty_remaining": 100}]
	state.world.tiles[5005] = tile
	return [state, porter, resident, tile]

func _ok(m: String) -> void: print("  [PASS] " + m)
func _bad(m: String) -> void:
	_fail += 1
	print("  [FAIL] " + m)
