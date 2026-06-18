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
const SURVIVAL_GOODS: Array = ["food", "medicine"]   # 飢荒不對稱 clamp 適用

# 唯一 local_value：
#   - coin 恆 face value（player_trade 的 coin guard，trade 守恆與單價無關，硬閘）
#   - survival 不對稱（interaction 版）：food/medicine shortage>0.5 → 急速攀升，饑荒價最高 5×
#   - 非 survival：clamp sr 至 [-0.5, 1.0]（最低 0.5× 過剩、最高 2× 短缺）
static func local_value(team: TeamData, res: String) -> float:
	if res == "coin":
		return 1.0   # currency: always face value, no supply/demand modulation
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = float(team.resources.get(res, 0))
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var shortage: float = (target - stock) / maxf(target, 1.0)   # ≤ 1.0
	if res in SURVIVAL_GOODS and shortage > 0.5:
		# 生存品短缺過半 → 急速攀升：0.5→1.0 區間映射 sr 1.0→4.0（饑荒價最高 5×）
		shortage = 1.0 + (shortage - 0.5) * 6.0
	var sr: float = clampf(shortage, -0.5, 4.0 if res in SURVIVAL_GOODS else 1.0)
	return float(BASE_PRICE[res]) * (1.0 + sr)
