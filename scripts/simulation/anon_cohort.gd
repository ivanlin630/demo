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
