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
		# 只移 healthy（wounded 不在此死）→ roll 必須只按 healthy 桶加權，
		# 且 killed 記實際移除數（remove 回傳），否則 caller 依虛報數扣純量 → drift。
		var healthy_total: int = AnonCohort.by_health(team.anon_cohorts, "healthy")
		if healthy_total <= 0:
			break
		var roll: int = randi() % healthy_total
		var acc: int = 0
		for tier in TIER_ORDER:
			acc += int(team.anon_cohorts.get(AnonCohort._key(tier, "healthy"), 0))
			if roll < acc:
				killed[tier] += AnonCohort.remove(team.anon_cohorts, tier, "healthy", 1)
				break
	return killed

# 依某 health 桶各 tier count 加權隨機選一 tier（無人回 ""）
static func _weighted_tier(team: TeamData, health: String) -> String:
	var tot: int = AnonCohort.by_health(team.anon_cohorts, health)
	if tot <= 0:
		return ""
	var roll: int = randi() % tot
	var acc: int = 0
	for tier in TIER_ORDER:
		acc += int(team.anon_cohorts.get(AnonCohort._key(tier, health), 0))
		if roll < acc:
			return tier
	return ""

# 受傷 n 人：weighted 從 healthy 移到 wounded。回實際受傷數（受 healthy 池上限約束→不膨脹）
static func wound_random(team: TeamData, n: int) -> int:
	var done: int = 0
	for _i in range(n):
		var tier: String = _weighted_tier(team, "healthy")
		if tier == "":
			break
		AnonCohort.move(team.anon_cohorts, tier, "healthy", tier, "wounded", 1)
		done += 1
	return done

# 治癒 n 人：weighted 從 wounded 移回 healthy。回實際治癒數
static func heal_random(team: TeamData, n: int) -> int:
	var done: int = 0
	for _i in range(n):
		var tier: String = _weighted_tier(team, "wounded")
		if tier == "":
			break
		AnonCohort.move(team.anon_cohorts, tier, "wounded", tier, "healthy", 1)
		done += 1
	return done

# 傷兵死亡 n 人：weighted 從 wounded 桶移除。回實際移除數
static func kill_wounded(team: TeamData, n: int) -> int:
	var done: int = 0
	for _i in range(n):
		var tier: String = _weighted_tier(team, "wounded")
		if tier == "":
			break
		AnonCohort.remove(team.anon_cohorts, tier, "wounded", 1)
		done += 1
	return done

# 按比例從 from 抽 count 人到 to（戰俘 / 投靠 / 拆團）。health-aware：兩桶都搬，保 tier+health。回各 tier 轉移數
static func transfer_proportional(from: TeamData, to: TeamData, count: int) -> Dictionary:
	var moved: Dictionary = {}
	for tier in TIER_ORDER:
		moved[tier] = 0
	var total: int = AnonCohort.total(from.anon_cohorts)
	if total <= 0 or count <= 0:
		return moved
	var actual: int = mini(count, total)
	var remaining: int = actual
	# 兩輪 × 兩 health：按比例搬，保各 tier|health 桶
	for health in AnonCohort.HEALTH_ORDER:
		for tier in TIER_ORDER:
			if remaining <= 0:
				break
			var avail: int = int(from.anon_cohorts.get(AnonCohort._key(tier, health), 0))
			if avail <= 0:
				continue
			var n: int = mini(mini(int(round(float(avail) / float(total) * float(actual))), avail), remaining)
			var real: int = AnonCohort.remove(from.anon_cohorts, tier, health, n)
			AnonCohort.add(to.anon_cohorts, tier, health, real)
			moved[tier] += real
			remaining -= real
	# 補滿剩餘（順序）
	if remaining > 0:
		for health in AnonCohort.HEALTH_ORDER:
			for tier in TIER_ORDER:
				if remaining <= 0:
					break
				var avail2: int = int(from.anon_cohorts.get(AnonCohort._key(tier, health), 0))
				if avail2 > 0:
					var take: int = mini(avail2, remaining)
					var real2: int = AnonCohort.remove(from.anon_cohorts, tier, health, take)
					AnonCohort.add(to.anon_cohorts, tier, health, real2)
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
