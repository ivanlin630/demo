class_name AnonCohort

# 匿名人口統一容器：cohorts: Dictionary，鍵 "tier|health" → count（稀疏，只存非零桶）。
# tier 數值沿用 AnonTierSystem.TIER_STATS（單一來源）。全 static 純函數，不持有狀態。

const TIER_ORDER: Array   = ["平民", "新兵", "老兵", "菁英"]
const HEALTH_ORDER: Array = ["healthy", "wounded"]

# ───── 鍵編解碼 ─────

static func _key(tier: String, health: String) -> String:
	return "%s|%s" % [tier, health]

static func _parse(key: String) -> Array:
	return key.split("|")   # [tier, health]

# ───── 增減（維持稀疏 + 非負）─────

static func add(cohorts: Dictionary, tier: String, health: String, n: int) -> void:
	if n <= 0:
		return
	var k: String = _key(tier, health)
	cohorts[k] = int(cohorts.get(k, 0)) + n

static func remove(cohorts: Dictionary, tier: String, health: String, n: int) -> int:
	if n <= 0:
		return 0
	var k: String = _key(tier, health)
	var cur: int = int(cohorts.get(k, 0))
	var removed: int = mini(cur, n)
	var left: int = cur - removed
	if left <= 0:
		cohorts.erase(k)
	else:
		cohorts[k] = left
	return removed

static func move(cohorts: Dictionary, from_tier: String, from_health: String,
		to_tier: String, to_health: String, n: int) -> int:
	var moved: int = remove(cohorts, from_tier, from_health, n)
	add(cohorts, to_tier, to_health, moved)
	return moved

# ───── 計數投影（純衍生）─────

static func total(cohorts: Dictionary) -> int:
	var s: int = 0
	for k in cohorts:
		s += int(cohorts[k])
	return s

static func by_health(cohorts: Dictionary, health: String) -> int:
	var s: int = 0
	for k in cohorts:
		if _parse(k)[1] == health:
			s += int(cohorts[k])
	return s

static func by_tier(cohorts: Dictionary, tier: String) -> int:
	var s: int = 0
	for k in cohorts:
		if _parse(k)[0] == tier:
			s += int(cohorts[k])
	return s

# ───── 數值投影（沿用 AnonTierSystem.TIER_STATS）─────

static func avg_combat(cohorts: Dictionary) -> float:
	var tot: int = total(cohorts)
	if tot <= 0:
		return 0.1
	var s: float = 0.0
	for k in cohorts:
		var tier: String = _parse(k)[0]
		s += float(cohorts[k]) * float(AnonTierSystem.TIER_STATS[tier]["combat"])
	return s / float(tot)

static func avg_speed(cohorts: Dictionary) -> float:
	var tot: int = total(cohorts)
	if tot <= 0:
		return 1.0
	var s: float = 0.0
	for k in cohorts:
		var tier: String = _parse(k)[0]
		s += float(cohorts[k]) * float(AnonTierSystem.TIER_STATS[tier]["speed"])
	return s / float(tot)

static func total_wage(cohorts: Dictionary) -> float:
	var w: float = 0.0
	for k in cohorts:
		var tier: String = _parse(k)[0]
		w += float(cohorts[k]) * float(AnonTierSystem.TIER_STATS[tier]["base_wage"])
	return w
