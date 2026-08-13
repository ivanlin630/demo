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

# ★紮營邊際（A1、Slice survival-access）：紮營落腳該 farmable tile 的淨可持續產能超出「原本覓食餬口日產」的增量。
#   = maxf(0, _inflow_est(est) − forage_floor)。純算術零新常數、鏡射 migrant_marginal（god-view 防線一致=只吃 est）。
#   低產 tile（森林 regen 3 + 高 pop → _inflow_est 邊際 → 0）→ maxf(0)=0 → 不值紮（anti-crank marginal 路徑）。
static func camp_marginal(est: VillageEstimate, forage_floor: float) -> float:
	return maxf(0.0, _inflow_est(est) - forage_floor)

# ★投資 ROI（§1.1.2、Slice R2）：升 farming 一級的淨回收（食產增益 × 有效視野 − 升級料價值）。
# ★★命門（survival-bounded、治 HORIZON 自打臉）：discrimination 非靠調 HORIZON、靠有效視野綁「殘存活窗」——
#   投資後仍赤字（net_after<0）→ effective_days 綁 food_est/−net_after（短）→ Δinflow×短窗 < cost → ROI 負 → 不投
#     （即使 HORIZON 大：山地投資後 REGEN 0.5×1.5 遠不夠 pop×0.8 → 永赤字 → 短窗 → ROI 負自我區辨、非 knife-edge tuned）。
#   投資後轉正（net_after>=0）→ full horizon → Δinflow×H 大幅越過 cost → ROI 正 → 投（森村 deficit→surplus）。
# upgrade_cost_value 由呼叫者算（OutpostSystem.upgrade_cost 純表 × TradeValuation.local_value(領主,res)），
#   傳入 float 保 MarginalEconomy 純算術零 state（god-view 結構防線一致）。
const PLANNING_HORIZON_DAYS: float = 90.0   # 季量級規劃視野（一季≈90 天、genuine 基建視野、非 fire-crank；measurer 驗 discrimination robust across [40,120]）
static func facility_roi(est: VillageEstimate, facility: String, next_lvl: int, upgrade_cost_value: float) -> float:
	# 目前唯一影響 _inflow_est 的 facility = farming（farming_bonus 1+lvl×0.5）；非 farming → Δinflow=0（只食產 ROI，R2 scope）。
	var before: float = _inflow_est(est)
	var est_after := VillageEstimate.make(est.terrain, est.outpost_level, next_lvl if facility == "farming" else est.farming_level, est.pop)
	est_after.harvest_factor = est.harvest_factor
	est_after.prod_skill = est.prod_skill
	var after: float = _inflow_est(est_after)
	var d_inflow: float = after - before                      # 恆正小量（farming 增食產）
	var need: float = float(est.pop) * MIGRANT_UPKEEP          # pop×0.8 每日食耗
	var net_after: float = after - need                        # 投資後淨（正=可持續、負=仍赤字）
	var effective_days: float = PLANNING_HORIZON_DAYS
	if net_after < 0.0:
		# 仍赤字 → 只惠及殘存活窗（現存糧撐幾天）；food_est NEUTRAL 0 → 窗 0 → ROI=−cost（山地自我區辨）。
		effective_days = minf(PLANNING_HORIZON_DAYS, est.food_est / maxf(-net_after, 0.001))
	return d_inflow * effective_days - upgrade_cost_value

# ★遷村價值（§1.1.3、Slice R3）：遷到 target 地的淨前景 − current 地前景 − 沉沒成本（persist_strength 沉沒、呼叫者算傳入）。
# = _inflow_est(target) − _inflow_est(current) − sunk_penalty。全 belief VillageEstimate（結構防線、_inflow_est 拿不到 live target）。
# 山地村 current 永赤字 + target 前景高 → 大正 → 遷；平原盈餘村 target 差/沉沒重 → ≤0 → 不遷（三態湧現、零 if-terrain）。
# ★sunk_penalty 由呼叫者算（PersistStrength.compute(state, team) 人格加權沉沒）傳 float → MarginalEconomy 純算術零 state。
static func relocate_value(current_est: VillageEstimate, target_est: VillageEstimate, sunk_penalty: float) -> float:
	return _inflow_est(target_est) - _inflow_est(current_est) - sunk_penalty
