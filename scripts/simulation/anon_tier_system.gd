class_name AnonTierSystem

# 匿名人口分 4 階：平民 / 新兵 / 老兵 / 菁英。
# 集中 tier 屬性表、查詢、變動、升等、死亡分配。
# team.anon_tiers / anon_exp 取代舊 scalar anon_combat_skill / anon_wage。

const TIER_ORDER: Array = ["平民", "新兵", "老兵", "菁英"]

const TIER_STATS: Dictionary = {
	"平民": { "combat": 0.1, "speed": 0.7, "base_wage": 0.5 },
	"新兵": { "combat": 0.3, "speed": 0.8, "base_wage": 1.0 },
	"老兵": { "combat": 0.5, "speed": 0.9, "base_wage": 1.5 },
	"菁英": { "combat": 0.7, "speed": 1.0, "base_wage": 2.5 },
}

# 升等所需 exp（tier 內累積到此值 × count → 可升）
const PROMOTION_EXP_THRESHOLD: Dictionary = {
	"平民": 50.0,
	"新兵": 100.0,
	"老兵": 200.0,
}

# 升等扣物資（per anon 升上來）
const PROMOTION_COST: Dictionary = {
	"平民": { "coin": 5, "food": 10, "material": 2 },
	"新兵": { "coin": 15, "food": 20, "material": 5 },
	"老兵": { "coin": 50, "food": 50, "material": 10 },
}

# 菁英額外條件：team 持有 weapon_melee_high >= 菁英總數
const ELITE_WEAPON_REQ: String = "weapon_melee_high"

# leader 戰術 skill → 訓練可達最高 tier（戰場升等不受此 cap）
const TRAINING_CAP_THRESHOLDS: Dictionary = {
	0.0: "新兵",
	0.4: "老兵",
	0.7: "菁英",
}

# ───── 查詢 ─────

static func total_pop(team: TeamData) -> int:
	return AnonCohort.total(team.anon_cohorts)

static func total_wage(team: TeamData) -> float:
	return AnonCohort.total_wage(team.anon_cohorts)

static func avg_speed(team: TeamData) -> float:
	return AnonCohort.avg_speed(team.anon_cohorts)

static func avg_combat_skill(team: TeamData) -> float:
	return AnonCohort.avg_combat(team.anon_cohorts)

static func tier_count(team: TeamData, tier: String) -> int:
	return AnonCohort.by_tier(team.anon_cohorts, tier)

static func tier_breakdown(team: TeamData) -> Dictionary:
	var d: Dictionary = {}
	for tier in TIER_ORDER:
		d[tier] = AnonCohort.by_tier(team.anon_cohorts, tier)
	return d

# ───── 變動 ─────

static func add_anon(team: TeamData, tier: String, count: int) -> void:
	if count <= 0 or tier not in TIER_ORDER:
		return
	AnonCohort.add(team.anon_cohorts, tier, "healthy", count)

static func remove_anon(team: TeamData, tier: String, count: int) -> int:
	if count <= 0 or tier not in TIER_ORDER:
		return 0
	return AnonCohort.remove(team.anon_cohorts, tier, "healthy", count)

static func add_exp(team: TeamData, tier: String, exp: float) -> void:
	if tier == "菁英":
		return    # 無下一階
	if not team.anon_exp.has(tier):
		return
	team.anon_exp[tier] = float(team.anon_exp[tier]) + exp

# weighted random 依各 tier count 抽，不減 named。回 { tier: 死亡數 }
static func kill_random(team: TeamData, count: int, _source: String) -> Dictionary:
	var killed: Dictionary = {}
	for tier in TIER_ORDER:
		killed[tier] = 0
	for _i in range(count):
		var total: int = AnonCohort.total(team.anon_cohorts)
		if total <= 0:
			break
		var roll: int = randi() % total
		var acc: int = 0
		for tier in TIER_ORDER:
			acc += AnonCohort.by_tier(team.anon_cohorts, tier)
			if roll < acc:
				AnonCohort.remove(team.anon_cohorts, tier, "healthy", 1)
				killed[tier] += 1
				break
	return killed

# 按比例從 from 抽 count 人到 to（戰俘 / 投靠 / 拆團）。回各 tier 轉移數
static func transfer_proportional(from: TeamData, to: TeamData, count: int) -> Dictionary:
	var moved: Dictionary = {}
	for tier in TIER_ORDER:
		moved[tier] = 0
	var total: int = AnonCohort.total(from.anon_cohorts)
	if total <= 0 or count <= 0:
		return moved
	var actual: int = mini(count, total)
	var remaining: int = actual
	# 第一輪：按比例 round
	for tier in TIER_ORDER:
		if remaining <= 0:
			break
		var avail: int = AnonCohort.by_tier(from.anon_cohorts, tier)
		var n: int = mini(mini(int(round(float(avail) / float(total) * float(actual))), avail), remaining)
		var real: int = AnonCohort.remove(from.anon_cohorts, tier, "healthy", n)
		AnonCohort.add(to.anon_cohorts, tier, "healthy", real)
		moved[tier] = real
		remaining -= real
	# 第二輪：round 後剩餘，順序補滿
	if remaining > 0:
		for tier in TIER_ORDER:
			if remaining <= 0:
				break
			var avail2: int = AnonCohort.by_tier(from.anon_cohorts, tier)
			if avail2 > 0:
				var take: int = mini(avail2, remaining)
				var real2: int = AnonCohort.remove(from.anon_cohorts, tier, "healthy", take)
				AnonCohort.add(to.anon_cohorts, tier, "healthy", real2)
				moved[tier] += real2
				remaining -= real2
	return moved

# ───── 升等 ─────

# leader 命令升一波。回實際升等人數（失敗回 0，不部分扣）
static func try_promote(state: WorldState, team: TeamData, from_tier: String, count: int) -> int:
	if count <= 0:
		return 0
	if from_tier == "菁英":
		return 0
	var idx: int = TIER_ORDER.find(from_tier)
	if idx == -1 or idx + 1 >= TIER_ORDER.size():
		return 0
	var to_tier: String = TIER_ORDER[idx + 1]
	# 1. count 足
	if AnonCohort.by_tier(team.anon_cohorts, from_tier) < count:
		return 0
	# 2. exp 足（每升 1 人需 1 份 threshold；consume threshold × count）
	var threshold: float = float(PROMOTION_EXP_THRESHOLD[from_tier])
	if float(team.anon_exp.get(from_tier, 0.0)) < threshold * float(count):
		return 0
	# 3. 物資足
	var cost: Dictionary = PROMOTION_COST[from_tier]
	for res in cost:
		if float(team.resources.get(res, 0)) < float(cost[res]) * float(count):
			return 0
	# 4. leader 戰術 cap（訓練升等受限）
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader != null:
		var tact: float = float(leader.skills.get("戰術", 0.0))
		var cap: String = _training_cap(tact)
		if TIER_ORDER.find(to_tier) > TIER_ORDER.find(cap):
			return 0
	# 5. 菁英武器需求（check 不消耗）
	if to_tier == "菁英":
		var future_elite: int = AnonCohort.by_tier(team.anon_cohorts, "菁英") + count
		if int(team.resources.get(ELITE_WEAPON_REQ, 0)) < future_elite:
			return 0
	# 全過 → 執行
	for res in cost:
		var amt: float = float(cost[res]) * float(count)
		team.resources[res] = float(team.resources.get(res, 0)) - amt
		if res == "coin":
			team.anon_treasury += amt   # 守恆：訓練餉銀入公庫，不蒸發
	AnonCohort.move(team.anon_cohorts, from_tier, "healthy", to_tier, "healthy", count)
	team.anon_exp[from_tier] = float(team.anon_exp[from_tier]) - threshold * float(count)
	return count

static func _training_cap(tact: float) -> String:
	var cap: String = "新兵"
	if tact > 0.4:
		cap = "老兵"
	if tact > 0.7:
		cap = "菁英"
	return cap
