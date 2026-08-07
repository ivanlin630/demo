extends SceneTree

# material-hold-protection TDD（spec 2026-07-23）。脫貧第三腿:decouple 兩 urgency。
# 根:reserve(material)=need_keep×_reserve_factor,_urgency=max(food,coin)→coin_urg 壓→construction-material
# 賣掉不累積→afford×1.5 湊不到。修:①_reserve_factor_food_only(coin 免疫)②reserve(material)construction→food-only
# ③acute food 天然釋放(food_urg 項,守護防抱料餓死)④coin_need material 對齊 cost×1.5-holding。

var _fail: int = 0

func _initialize() -> void:
	_test_construction_coin_immune()  # ①construction+coin_urg 高+food OK→reserve 高(不被 coin 壓)
	_test_acute_food_releases()       # ★②construction+acute food→reserve 降可賣(守護:餓隊能賣不抱料餓死)
	_test_nonconstruction_unchanged() # ③非-construction material→照舊(max 兩 urgency)
	_test_coin_need_afford()          # ④coin_need material=cost×1.5-holding
	_test_conservation()              # ⑤extraction 守恆(coin+treasury 不變)
	_test_urgency_decouple()          # ⑥_reserve_factor_food_only 對 coin 免疫 vs _reserve_factor 受 coin
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# construction team：military outpost weaponsmith 未建(→_construction_facility_need material>0)。
func _mk(with_outpost: bool, food: float, coin: float, mat: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 8):
		for y in range(3, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	state.player_id = -999
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)
	team.armed_anon_ratio = 0.0
	team.resources["food"] = food; team.resources["coin"] = coin; team.resources["material"] = mat
	var l := PersonData.new(); l.id = 10; l.values = {"好戰": 0.9, "貪婪": 0.5, "慎重": 0.5}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	if with_outpost:
		var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
		tile.outpost_owner = 1; tile.outpost_type = "military"; tile.outpost_level = 1
		tile.set("weaponsmith_level", 0)
	return [state, team]

func _lv(w: Array) -> Dictionary:
	return w[1].leader_id != -1 and w[0].persons.has(10) and w[0].persons[10].values or {}

# ① construction-material + coin_urg 高(coin 0) + food OK → reserve 高（food-only factor，不被 coin 壓）
func _test_construction_coin_immune() -> void:
	print("--- ①construction+coin poor+food OK→reserve 高 ---")
	var w: Array = _mk(true, 1000.0, 0.0, 0.0)   # food 足、coin 0(coin_urg 高)、想蓋 weaponsmith
	var lv: Dictionary = w[0].persons[10].values
	var r: float = TradeValuation.reserve(w[1], "material", lv, w[0])
	var f_food: float = TradeValuation._reserve_factor_food_only(w[1], lv, w[0])
	var f_max: float = TradeValuation._reserve_factor(w[1], lv, w[0])
	_ok(f_food > f_max, "food-only factor(%.2f) > max-urgency factor(%.2f)（coin_urg 免疫，守料不賣）" % [f_food, f_max])
	var nk: float = NeedOracle.need_keep(w[0], w[1], "material", lv)
	_ok(r > nk * f_max + 0.01, "reserve(material)=%.1f 用 food-only（>coin 壓的 %.1f，守要蓋的料）" % [r, nk * f_max])

# ★② construction-material + acute food(food_days<DESPERATION) → reserve 降 → 可賣（守護:餓隊能賣不抱料餓死）
func _test_acute_food_releases() -> void:
	print("--- ★②acute food→reserve 降釋放（守護）---")
	var w_ok: Array = _mk(true, 1000.0, 0.0, 0.0)     # food 足
	var w_acute: Array = _mk(true, 0.0, 0.0, 0.0)      # food 0=acute
	var lv: Dictionary = w_ok[0].persons[10].values
	var r_ok: float = TradeValuation.reserve(w_ok[1], "material", lv, w_ok[0])
	var r_acute: float = TradeValuation.reserve(w_acute[1], "material", w_acute[0].persons[10].values, w_acute[0])
	_ok(r_acute < r_ok, "acute food reserve(%.1f) < food OK reserve(%.1f)（food_urg 降 factor→protected material 釋放賣糧求生，不抱料餓死）" % [r_acute, r_ok])

# ③ 非-construction material（無 outpost 無 construction-need）→ 照舊 max 兩 urgency
func _test_nonconstruction_unchanged() -> void:
	print("--- ③非-construction→照舊 ---")
	var w: Array = _mk(false, 1000.0, 0.0, 100.0)   # 無 outpost→無 construction-need；coin 0
	var lv: Dictionary = w[0].persons[10].values
	var r: float = TradeValuation.reserve(w[1], "material", lv, w[0])
	var nk: float = NeedOracle.need_keep(w[0], w[1], "material", lv)
	var f_max: float = TradeValuation._reserve_factor(w[1], lv, w[0])
	_ok(is_equal_approx(r, nk * f_max), "無 construction-need → reserve=need_keep×_reserve_factor（照舊 max 兩 urgency，got %.2f）" % r)

# ④ coin_need material 分量 = cost×1.5 − holding（對齊 afford，非 need_keep shortfall）
func _test_coin_need_afford() -> void:
	print("--- ④coin_need material=cost×1.5-holding ---")
	# holding 90：使 afford×1.5 缺口(cost 100×1.5-90=60)與 shortfall(need_keep 100-90=10)差異在 CAP 內可辨。
	var w: Array = _mk(true, 1000.0, 0.0, 90.0)
	var lv: Dictionary = w[0].persons[10].values
	var fai := FactionAISystem.new()
	var mat_cost: float = NeedOracle._construction_facility_need(w[0], w[1], "material", lv)
	var price: float = TradeValuation.local_value(w[1], "material", w[0])
	var expect_afford: float = maxf(mat_cost * 1.5 - 90.0, 0.0) * price   # afford×1.5 缺口
	var old_shortfall: float = maxf(NeedOracle.need_keep(w[0], w[1], "material", lv) - 90.0, 0.0) * price   # 舊 need_keep 缺口
	var cn: float = minf(CoinTreasury.coin_need(w[0], w[1]), CoinTreasury.COIN_NEED_CAP)
	_ok(mat_cost > 0.0, "有 construction material cost（想蓋 weaponsmith，got %.0f）" % mat_cost)
	_ok(is_equal_approx(cn, minf(expect_afford, CoinTreasury.COIN_NEED_CAP)), "coin_need=%.0f=afford×1.5 缺口(cost×1.5-90=%.0f 對齊 afford，非舊 shortfall %.0f)" % [cn, expect_afford, old_shortfall])

# ⑤ 守恆：construction team extraction，coin+treasury 前後不變
func _test_conservation() -> void:
	print("--- ⑤守恆 ---")
	var w: Array = _mk(true, 0.0, 0.0, 0.0)   # 食壓+想蓋→coin_need 大→extract
	w[1].anon_treasury = 200.0
	var before: float = float(w[1].resources.get("coin", 0)) + w[1].anon_treasury
	CoinTreasury.consider_extraction(w[0], w[1])
	var after: float = float(w[1].resources.get("coin", 0)) + w[1].anon_treasury
	_ok(is_equal_approx(before, after), "coin+treasury 前 %.1f == 後 %.1f（守恆）" % [before, after])

# ⑥ decouple 硬驗：_reserve_factor_food_only 對 coin 免疫；_reserve_factor 受 coin
func _test_urgency_decouple() -> void:
	print("--- ⑥urgency decouple ---")
	var w_poor: Array = _mk(true, 1000.0, 0.0, 0.0)      # food OK、coin 0(coin_urg 高)
	var w_rich: Array = _mk(true, 1000.0, 10000.0, 0.0)  # food OK、coin 多(coin_urg 0)
	var lv: Dictionary = w_poor[0].persons[10].values
	var ff_poor: float = TradeValuation._reserve_factor_food_only(w_poor[1], lv, w_poor[0])
	var ff_rich: float = TradeValuation._reserve_factor_food_only(w_rich[1], w_rich[0].persons[10].values, w_rich[0])
	var fm_poor: float = TradeValuation._reserve_factor(w_poor[1], lv, w_poor[0])
	var fm_rich: float = TradeValuation._reserve_factor(w_rich[1], w_rich[0].persons[10].values, w_rich[0])
	_ok(is_equal_approx(ff_poor, ff_rich), "food-only factor coin 免疫（poor %.2f == rich %.2f，decouple）" % [ff_poor, ff_rich])
	_ok(fm_poor < fm_rich, "max-urgency factor 受 coin（poor %.2f < rich %.2f，coin 焦慮壓賣）" % [fm_poor, fm_rich])
