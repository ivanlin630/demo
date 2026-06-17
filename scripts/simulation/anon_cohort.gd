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
