class_name FoodFlow

# ★糧流感知 Slice A（HOW spec 2026-07-29 §2）：存活持守糧流感官。
# net = inflow − burn；runway = 現有 food / max(−net, ε)（net≥0=不缺→大值）。
# ★inflow = 可持續 harvest-only 內生（自家 outpost 被動產 + 當前 tile 可持續採；★外生施捨/貿易/掠奪不算=解「賭施捨」）。
# ★每日 cadence 算 1 次 + 快取 team.food_runway（非每 tick；staleness≤1 日可接受）。純算術零 RNG。
# 打獵 EV / 假設 tile / 遠征 ETA = Slice B（延後）。

const EPSILON: float = 0.01              # net→0 防除零
const RUNWAY_CAP: float = 9999.0         # runway 上界（net≥0=不缺→此大值，避 inf）
# outpost level → 被動產倍率（鏡射 resource_system collect：[1.0,1.4,2.0]）
const OUTPOST_MULT: Array = [1.0, 1.4, 2.0]

# 每日呼（collect/consumption cadence）：算 runway 快取 team.food_runway。tap 禁 RNG。
static func update(state: WorldState, team: TeamData) -> void:
	if state == null or team == null:
		return
	var inflow: float = _sustainable_inflow(state, team)
	var burn: float = float(team.population + team.minor_population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	var net: float = inflow - burn
	var runway: float
	if net >= 0.0:
		runway = RUNWAY_CAP   # 不缺糧（inflow≥burn）→ 大值
	else:
		var food: float = ResourceSystem.effective_food(state, team)   # 私產+自家糧倉
		runway = clampf(food / maxf(-net, EPSILON), 0.0, RUNWAY_CAP)
	team.food_runway = runway
	if Probe.enabled:
		Probe.bump("foodflow.update")
		Probe.note("foodflow.runway_min", -runway)   # note=peak(max);存 -runway → 讀回取最小 runway（最危）

# ★可持續 harvest-only 內生 inflow（每日食物）：自家 outpost tile 被動產（sustainable=regen-bound）。
# 鏡射 resource_system collect food modifiers（outpost_mult×pop_mult×farming×prod_skill×harvest_factor），
# 但用 tile food REGEN（可持續穩態，非耗盡 stock）→ 「可持續採」。無自家 outpost=0（狩獵延後 B）。
static func _sustainable_inflow(state: WorldState, team: TeamData) -> float:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != team.team_id:
		return 0.0   # 無自家 outpost 被動產（狩獵 EV=Slice B）
	var regen: Dictionary = ResourceSystem.REGEN_RATE.get(tile.terrain, {"food": 2.0})
	var sustainable: float = float(regen.get("food", 2.0)) * tile.harvest_factor   # 每日穩態可再生食物
	var lvl: int = clampi(tile.outpost_level, 1, OUTPOST_MULT.size())
	var outpost_mult: float = OUTPOST_MULT[lvl - 1]
	var pop_mult: float = clampf(sqrt(float(team.population) / 5.0), 0.5, 2.0)
	var leader = state.persons.get(team.leader_id)
	var prod_skill: float = float(leader.skills.get("生產", 0.0)) if leader != null else 0.0
	# ★labor v2 T3：移原始 farming_bonus(1+level×0.5 乘性 boost)、改 farm_contribution=新 production 式
	# (level×FUY×harvest×farm_labor、level 生效+勞力飽和誠實、estimator==production 同源)。感知鐵律 own-tile self。
	var gather_inflow: float = sustainable * outpost_mult * pop_mult * (1.0 + prod_skill * 0.3)
	var farm_contribution: float = float(tile.farming_level) * ResourceSystem.FARM_UNIT_YIELD * tile.harvest_factor * LaborSystem.farm_labor(tile)
	return gather_inflow + farm_contribution
