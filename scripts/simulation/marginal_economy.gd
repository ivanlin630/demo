class_name MarginalEconomy
extends RefCounted

# ★復甦路徑 §1 邊際經濟計算層（三動詞共讀 substrate）。純算術、零 RNG、類 FoodFlow。
# ★★命門①（god-view 結構防線）：禁呼 FoodFlow._sustainable_inflow(state, live_target)——
#   結構上只吃純 struct VillageEstimate、內部 _inflow_est(est) 重算（鏡射 food_flow.gd:39-47 公式非直呼）。
#   _inflow_est 簽名只吃 est、拿不到 state.teams[target] → 結構上不可能違憲（非道德勸說）。
# ★命門②：三態（plains 收/forest·mountain 不收）由 terrain REGEN 主導湧現、零 if-terrain 分支。

const OUTPOST_MULT: Array = [1.0, 1.4, 2.0]   # 鏡射 FoodFlow.OUTPOST_MULT（level 1/2/3）
const MIGRANT_UPKEEP: float = ResourceSystem.FOOD_PER_PERSON_PER_DAY   # 每移民日食耗（DERIVED 食物常數、非 fire-crank）

# ★可持續 inflow 估算（純 est、鏡射 food_flow.gd:39-47、禁呼 live _sustainable_inflow）。
# = REGEN[terrain].food × harvest_factor × outpost_mult × pop_mult(sqrt clamp) × (1+farming×0.5) × (1+prod_skill×0.3)
static func _inflow_est(est: VillageEstimate) -> float:
	var regen: Dictionary = ResourceSystem.REGEN_RATE.get(est.terrain, {"food": 2.0})
	var sustainable: float = float(regen.get("food", 2.0)) * est.harvest_factor
	var lvl: int = clampi(est.outpost_level, 1, OUTPOST_MULT.size())
	var outpost_mult: float = OUTPOST_MULT[lvl - 1]
	var pop_mult: float = clampf(sqrt(float(est.pop) / 5.0), 0.5, 2.0)
	var farming_bonus: float = 1.0 + float(est.farming_level) * 0.5
	return sustainable * outpost_mult * pop_mult * farming_bonus * (1.0 + est.prod_skill * 0.3)

# ★移民邊際：加 k 人到該村的淨可持續產能增量（pop_mult concave+封頂 → 邊際遞減）。
# = _inflow_est(pop+k) − _inflow_est(pop) − k×MIGRANT_UPKEEP。
# ≤0 → 引擎不移（森林/山地村加人加速惡化=三態湧現、REGEN 主導、零 if-terrain）。
static func migrant_marginal(est: VillageEstimate, k: int) -> float:
	if k <= 0:
		return 0.0
	var before: float = _inflow_est(est)
	var est_after := VillageEstimate.make(est.terrain, est.outpost_level, est.farming_level, est.pop + k)
	est_after.harvest_factor = est.harvest_factor
	est_after.prod_skill = est.prod_skill
	var after: float = _inflow_est(est_after)
	return after - before - float(k) * MIGRANT_UPKEEP
