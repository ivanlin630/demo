class_name AnonTierSystem

# 匿名人口分 4 階：平民 / 新兵 / 老兵 / 菁英。
# 集中 tier 屬性表、查詢、變動、升等、死亡分配。
# team.anon_tiers / anon_exp 取代舊 scalar anon_combat_skill / anon_wage。

const TIER_ORDER: Array = AnonCohort.TIER_ORDER

# 戰鬥敗方損耗的 tier 死亡權重（存活反比）。TEST VALUE。
const SURVIVAL_KILL_WEIGHT: Dictionary = {"平民": 1.0, "新兵": 0.6, "老兵": 0.3, "菁英": 0.15}

# ───── 受控人力 Phase 1：征服吸收常數（全 TEST VALUE）─────
const CAPTURE_RATE: float        = 0.5    # 征服吸收敗方殘餘 anon 比例
const CAPTIVE_INIT_MORALE: float = 0.25   # 吸收 captive 初始 morale（低忠，entry=吸收 強迫類）

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

# weighted random 依各 tier count（× 選用 tier_weight）抽，不減 named。回 { tier: 死亡數 }
# tier_weight 空 = 現行 count 比例（不破既有 caller）；非空 = 各 tier 抽中權重 ∝ count × tier_weight[tier]。
static func kill_random(team: TeamData, count: int, _source: String, tier_weight: Dictionary = {}) -> Dictionary:
	var killed: Dictionary = {}
	for tier in TIER_ORDER:
		killed[tier] = 0
	for _i in range(count):
		# 只移 healthy；按 healthy 桶 count×weight 加權
		var weighted: Array = []   # [[tier, w_float], ...]
		var total_w: float = 0.0
		for tier in TIER_ORDER:
			var c: int = int(team.anon_cohorts.get(AnonCohort._key(tier, "healthy"), 0))
			if c <= 0:
				continue
			var w: float = float(c) * float(tier_weight.get(tier, 1.0))
			if w <= 0.0:
				continue
			weighted.append([tier, w])
			total_w += w
		if total_w <= 0.0:
			break
		var roll: float = randf() * total_w
		var acc: float = 0.0
		for pair in weighted:
			acc += pair[1]
			if roll < acc:
				killed[pair[0]] += AnonCohort.remove(team.anon_cohorts, pair[0], "healthy", 1)
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

# ───── 受控人力 Phase 1：吸收 / 同化（守恆轉移，純 anon）─────

# 征服吸收：按 rate 從 loser.anon_cohorts remove → 組成 captive_group append 到 holder.captive_groups。
# 守恆：loser anon 移除量 == captive_group cohorts 總量（轉移非憑空）。captive 不入 holder.anon_cohorts（非戰力）。
# 保留來源 tier|health 鍵。回擄走總數。
static func absorb_as_captive(_state: WorldState, holder: TeamData, loser: TeamData, rate: float) -> int:
	if holder == null or loser == null or rate <= 0.0:
		return 0
	var captured: Dictionary = {}   # "tier|health" → count
	var total_captured: int = 0
	# 逐桶按 rate 取整 remove（health-aware，保 tier+health）
	for key in loser.anon_cohorts.keys():
		var parts: Array = AnonCohort._parse(key)
		var tier: String = parts[0]
		var health: String = parts[1]
		var avail: int = int(loser.anon_cohorts[key])
		if avail <= 0:
			continue
		var take: int = int(floor(float(avail) * rate))
		if take <= 0:
			continue
		var real: int = AnonCohort.remove(loser.anon_cohorts, tier, health, take)
		if real > 0:
			captured[key] = int(captured.get(key, 0)) + real
			total_captured += real
	if total_captured <= 0:
		return 0
	holder.captive_groups.append({
		"cohorts": captured,
		"morale": CAPTIVE_INIT_MORALE,
		"origin_faction": loser.faction_id,
		"entry": "吸收",
		"treatment_history": [],
	})
	return total_captured

# 同化：captive_group.cohorts 各桶 AnonCohort.add 進 holder.anon_cohorts（captive → free pop，守恆）。
# 解 (a)：同化後 holder.population getter 漲（captive 轉戰力 pop）。erase 該 group。回同化總數。
static func assimilate_captives(holder: TeamData, group: Dictionary) -> int:
	if holder == null or group == null:
		return 0
	var moved: int = 0
	var cohorts: Dictionary = group.get("cohorts", {})
	for key in cohorts.keys():
		var parts: Array = AnonCohort._parse(key)
		var tier: String = parts[0]
		var health: String = parts[1]
		var n: int = int(cohorts[key])
		if n <= 0:
			continue
		AnonCohort.add(holder.anon_cohorts, tier, health, n)
		moved += n
	holder.captive_groups.erase(group)
	return moved

# 暴動/逃：captive_group 部分（fraction）脫離 holder（從 group.cohorts remove）。
# 守恆：回脫離的 cohorts dict（caller 路由成獨立隊/流民/戰損，非憑空消）。group 清空則 erase。
static func detach_captives(holder: TeamData, group: Dictionary, fraction: float) -> Dictionary:
	var detached: Dictionary = {}
	if holder == null or group == null or fraction <= 0.0:
		return detached
	var cohorts: Dictionary = group.get("cohorts", {})
	for key in cohorts.keys():
		var avail: int = int(cohorts[key])
		if avail <= 0:
			continue
		var take: int = int(ceil(float(avail) * minf(fraction, 1.0)))
		take = mini(take, avail)
		if take <= 0:
			continue
		var left: int = avail - take
		if left <= 0:
			cohorts.erase(key)
		else:
			cohorts[key] = left
		detached[key] = int(detached.get(key, 0)) + take
	if AnonCohort.total(cohorts) <= 0:
		holder.captive_groups.erase(group)
	return detached

# 受控人力查詢：holder 全 captive 群總人數（不入 population；遙測/guard-cap 用）。
static func total_captives(team: TeamData) -> int:
	var s: int = 0
	for g in team.captive_groups:
		s += AnonCohort.total(g.get("cohorts", {}))
	return s

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
		ResourceBank.add(team, res, -amt, "train_cost")
		if res == "coin":
			AnonTreasuryBank.deposit(team, amt, "train_salary")   # 守恆：訓練餉銀入公庫，不蒸發
	AnonCohort.move(team.anon_cohorts, from_tier, "healthy", to_tier, "healthy", count)
	team.anon_exp[from_tier] = float(team.anon_exp[from_tier]) - threshold * float(count)
	return count

static func _training_cap(tact: float) -> String:
	var cap: String = AnonCohort.TIER_SOLDIER   # floor=新兵（門檻 0.0）
	var best: float = -1.0
	for threshold in TRAINING_CAP_THRESHOLDS:
		var th: float = float(threshold)
		if tact > th and th > best:
			best = th
			cap = TRAINING_CAP_THRESHOLDS[threshold]
	return cap
