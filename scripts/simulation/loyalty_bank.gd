class_name LoyaltyBank

# Pattern B 所有權 banker：loyalty 單一 owner。delta 走 adjust(cap 保各 site 上限)，
# lifecycle 基線(split/defect/recruit/init)走 set_baseline(唯一蓄意絕對路徑,有 reason)。
static func adjust(p: PersonData, delta: float, reason: String = "", cap: float = 1.0) -> void:
	p.loyalty = clampf(p.loyalty + delta, 0.0, cap)

static func set_baseline(p: PersonData, value: float, reason: String = "") -> void:
	p.loyalty = clampf(value, 0.0, 1.0)
