class_name TradeValuation

# ──────── trade 估值唯一真值源 ────────
# 消 interaction_system / player_trade_system 兩份漂移副本：canonical 表 + 唯一 local_value。
# 表取自 interaction_system 現值（NPC market，含「# in」原料成本調過值）；player_trade 舊副本是 drift 出的 stale。
# 定價規則：成品價 ≥ 原料價值（Σ in × BASE_PRICE）× 1.2（工藝品 gem 路線豁免）
const BASE_PRICE: Dictionary = {
	"food":               2.0,
	"material":           4.0,
	"herb":               3.0,
	"goods":             15.0,   # in 12
	"gem":               20.0,
	"ore_gold":          10.0,
	"ore_silver":         5.0,
	"ore_iron":           8.0,
	"ore_steel":         24.0,   # in 20
	"weapon_melee_low":  34.0,   # in 28
	"weapon_melee_high": 72.0,   # in 60
	"weapon_ranged_low": 39.0,   # in 32
	"weapon_ranged_high": 77.0,  # in 64
	"tools":             20.0,   # in 16
	"arrows":             4.0,   # in 3.2
	"armor_low":         30.0,   # in 24
	"armor_high":        72.0,   # in 60
	"horses":            15.0,
	"mounts":            45.0,   # horses + 草料 + 軍設施 margin
	"wagons":            72.0,   # in 59
	"medicine":          12.0,   # in 6
}
const TARGET_PER_POP: Dictionary = {
	"food":              10.0,
	"material":           5.0,
	"goods":              3.0,
	"gem":                1.0,
	"ore_gold":           2.0,
	"ore_silver":         3.0,
	"ore_iron":           3.0,
	"ore_steel":          1.5,
	"weapon_melee_low":   1.0,
	"weapon_melee_high":  0.5,
	"weapon_ranged_low":  0.8,
	"weapon_ranged_high": 0.4,
	"tools":              0.5,
	"arrows":             2.0,
	"armor_low":          0.3,
	"armor_high":         0.15,
	"horses":             0.5,
	"medicine":           1.0,
	"herb":               1.0,
	"mounts":             0.2,
	"wagons":             0.2,
}
const SURVIVAL_GOODS: Array = ["food", "medicine"]   # 飢荒不對稱 clamp 適用；★活命糧 reserve 不液化(絕境不甩)
const FOOD_RESERVE_TICKS: float = 20.0   # TEST VALUE — food 最低自留（pop × 0.1 × N ticks）；單一源

# ── 市場液化（unified-commerce M3/M5，收 market-liquidize）：非活命品 reserve 降底+人格化 = 流動為底 ──
# ★只非活命品；SURVIVAL_GOODS(food/medicine) 走各自 survival-floor，不液化不甩活命糧。
const RESERVE_BASE: float = 0.6          # TEST VALUE — 非活命品 reserve 降底基準(<1.0→願賣方變多)
const RESERVE_HOARD_K: float = 0.5       # TEST VALUE — 貪婪/慎重守貨斜率(高→reserve 高守貨)
const RESERVE_URGENCY_K: float = 0.4     # TEST VALUE — 急迫/絕境鬆手斜率(高 urgency→reserve 低賣)
const RESERVE_FACTOR_MIN: float = 0.1    # TEST VALUE — 液化下限(絕境也留一點非活命品緩衝)
const RESERVE_FACTOR_MAX: float = 1.2    # TEST VALUE — 守貨上限(貪婪囤)
const URGENCY_COIN_COMFORT: float = 10.0 # TEST VALUE — 人均 coin 舒適線(低於→缺幣壓力升 urgency)
# ── ask/bid 液化：折扣人格化(急鬆手/貪守價)，willing 對閉合邊際價差 ──
const COMMERCE_DISCOUNT_K: float = 0.1   # TEST VALUE — 商業技能折扣斜率
const URGENCY_DISCOUNT_K: float = 0.3    # TEST VALUE — 急迫賣方折扣加深(鬆手賣)
const GREED_HOLD_K: float = 0.2          # TEST VALUE — 貪婪賣方守價(折扣收窄→部分談崩=摩擦質感)
const DISCOUNT_MAX: float = 0.5          # TEST VALUE — 折扣上限(不倒貼)
const SPREAD_TOL: float = 0.05           # TEST VALUE — willing 對成交容差(閉合邊際價差)

# 留底（不賣掉自己需要的）：food 按人格安全天數、coin 半留、非活命品液化人格化。單一源。
# 候選1 helper：從 state 取隊領袖人格值(供 reserve 人格化)。null/無領袖→{}→BASE 目標。
static func leader_vals(state: WorldState, team: TeamData) -> Dictionary:
	if state == null or team.leader_id == -1:
		return {}
	var l: PersonData = state.persons.get(team.leader_id)
	return l.values if l != null else {}

# M4：storage-aware stock（state 給→effective_holding 算糧倉貨，null→team.resources 私產）。
static func _stock(state: WorldState, team: TeamData, res: String) -> float:
	if state != null:
		return ResourceSystem.effective_holding(state, team, res)
	return float(team.resources.get(res, 0))

static func reserve(team: TeamData, res: String, leader_values: Dictionary = {}, state: WorldState = null) -> float:
	# need-oracle S4b：reserve = 保留向 need_keep（R² 核心兩量落點）。coin 特例保留。
	if res == "coin":
		return float(team.resources.get("coin", 0)) * 0.5
	# food/medicine（SURVIVAL）：need_keep 已含 food 自用/medicine 終端自用＝survival floor，不液化（絕境不甩活命糧）。
	if res == "food" or res in SURVIVAL_GOODS:
		return NeedOracle.need_keep(state, team, res, leader_values)
	# ★material-hold-protection（脫貧第三腿）：material 有 active construction-need（想蓋 facility 缺料）
	# → 用 food-only factor（對 coin_urg 免疫）→ 守住要蓋的料不被 coin 焦慮逼賣（本 case 病治）；acute food 仍釋放(守護)。
	if res == "material" and state != null \
			and NeedOracle._construction_facility_need(state, team, "material", leader_values) > 0.0:
		return NeedOracle.need_keep(state, team, res, leader_values) * _reserve_factor_food_only(team, leader_values, state)
	# 非活命品：need_keep（自用+供應鏈）× 液化（貪婪守/絕境鬆手＝可賣餘量轉換層安全網）。
	# goods need_keep=0 → reserve=0 → 可賣餘量=holding（有 demand 才賣，死鎖解）。
	return NeedOracle.need_keep(state, team, res, leader_values) * _reserve_factor(team, leader_values, state)

# 非活命品 reserve 人格化液化係數：貪婪/慎重↑守貨(高)、急迫/絕境↓鬆手賣(低)。純算術零 randf。
static func _reserve_factor(team: TeamData, leader_values: Dictionary, state: WorldState = null) -> float:
	var hoard: float = (float(leader_values.get("貪婪", 0.5)) + float(leader_values.get("慎重", 0.5))) * 0.5
	var factor: float = RESERVE_BASE + (hoard - 0.5) * RESERVE_HOARD_K - _urgency(team, state) * RESERVE_URGENCY_K
	return clampf(factor, RESERVE_FACTOR_MIN, RESERVE_FACTOR_MAX)

# ★material-hold-protection：construction-material reserve 用「只食急迫」液化係數（對 coin_urg 免疫）。
# =_reserve_factor 但 urgency 只用 food_urg 非 max(food,coin)→coin 焦慮不逼賣要蓋的料；acute food 仍降 factor 可賣(守護)。
static func _reserve_factor_food_only(team: TeamData, leader_values: Dictionary, state: WorldState = null) -> float:
	var hoard: float = (float(leader_values.get("貪婪", 0.5)) + float(leader_values.get("慎重", 0.5))) * 0.5
	var factor: float = RESERVE_BASE + (hoard - 0.5) * RESERVE_HOARD_K - _food_urgency(team, state) * RESERVE_URGENCY_K
	return clampf(factor, RESERVE_FACTOR_MIN, RESERVE_FACTOR_MAX)

# 只食急迫 [0,1]：食物天數低→鬆手賣（decouple coin_urg，供 material-hold food-only factor + acute 守護）。純狀態零 randf。
static func _food_urgency(team: TeamData, state: WorldState = null) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	var food_days: float = _stock(state, team, "food") / (pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY)
	return clampf((DecisionTerms.DESPERATION_DAYS - food_days) / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)

# 隊急迫度 [0,1]：食物天數低 + 人均 coin 缺 → 鬆手賣非活命品換 coin/糧。純狀態，零 randf。
static func _urgency(team: TeamData, state: WorldState = null) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	var coin_urg: float = clampf(1.0 - float(team.resources.get("coin", 0)) / (pop * URGENCY_COIN_COMFORT), 0.0, 1.0)
	return maxf(_food_urgency(team, state), coin_urg)

# ask 售價：折扣人格化——商業技能 + 急迫鬆手(折扣深)，貪婪守價(折扣收窄→部分談崩)。零 randf。
static func ask_price(seller: TeamData, res: String, commerce: float, leader_values: Dictionary, state: WorldState = null) -> float:
	var greed: float = float(leader_values.get("貪婪", 0.5))
	var discount: float = clampf(
		commerce * COMMERCE_DISCOUNT_K + _urgency(seller, state) * URGENCY_DISCOUNT_K - (greed - 0.5) * GREED_HOLD_K,
		0.0, DISCOUNT_MAX)
	return local_value(seller, res, state) * (1.0 - discount)

# 唯一 local_value：coin 恆 face value；survival 不對稱(饑荒最高 5×)；非 survival clamp[-0.5,1.0]。
# M4：state 給→stock 算 effective_holding(糧倉貨算進,不誤判短缺)；null→team.resources 私產。
static func local_value(team: TeamData, res: String, state: WorldState = null) -> float:
	if res == "coin":
		return 1.0   # currency: always face value, no supply/demand modulation
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = _stock(state, team, res)
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var shortage: float = (target - stock) / maxf(target, 1.0)   # ≤ 1.0
	if res in SURVIVAL_GOODS and shortage > 0.5:
		shortage = 1.0 + (shortage - 0.5) * 6.0
	var sr: float = clampf(shortage, -0.5, 4.0 if res in SURVIVAL_GOODS else 1.0)
	return float(BASE_PRICE[res]) * (1.0 + sr)
