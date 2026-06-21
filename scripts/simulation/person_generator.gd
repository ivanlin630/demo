class_name PersonGenerator

const SURNAMES: Array = [
	"趙", "錢", "孫", "李", "周", "吳", "鄭", "王",
	"馮", "陳", "褚", "衛", "蔣", "沈", "韓", "楊",
	"朱", "秦", "尤", "許", "何", "呂", "施", "張"
]
const GIVEN_NAMES: Array = [
	"明", "華", "強", "勇", "剛", "毅", "智", "誠",
	"信", "義", "禮", "仁", "孝", "忠", "和", "平",
	"風", "雷", "雲", "山", "海", "天", "玄", "靈"
]

# 戲劇性尾巴：多數凡人窄帶 + 少數 archetype 狂人（連貫人格簇）。全 TEST VALUE。
const OUTLIER_RATE := 0.18          # TEST VALUE：member 成狂人機率
const OUTLIER_RATE_LEADER := 0.45   # TEST VALUE：leader 更高（leader 驅動戲劇）
const NORMAL_LO := 0.35             # 凡人窄帶
const NORMAL_HI := 0.65
const EXTREME_HI_LO := 0.85         # 極端高帶
const EXTREME_LO_HI := 0.15         # 極端低帶
const SKILL_TAIL_LO := 0.5          # outlier/宿將 高起點 skill
const SKILL_TAIL_HI := 0.9

# archetype 簇：高 values / 低 values / 高 skills（連貫人格；hi_s 為 skill 鍵）
const ARCHETYPES := {
	"霸主": { "hi_v": ["野心", "好戰"],        "lo_v": [],        "hi_s": ["統領"] },
	"屠夫": { "hi_v": ["殘忍", "好戰"],        "lo_v": ["信義"],  "hi_s": ["戰鬥"] },
	"謀士": { "hi_v": ["慎重"],                "lo_v": [],        "hi_s": ["計謀", "偵查"] },
	"懦夫": { "hi_v": ["求生欲"],              "lo_v": ["好戰", "野心"], "hi_s": [] },
}

# #0b 升 named 忠於 tier：晉升偏好抽高 tier + 新 named 戰鬥簇技能讀來源 tier。
const PROMOTE_TIER_WEIGHT := {"平民": 0.2, "新兵": 0.6, "老兵": 1.5, "菁英": 3.0}  # TEST VALUE
const PROMOTE_TIER_SKILLS := {              # TEST VALUE：來源 tier → 戰鬥簇技能帶
	"平民": {},
	"新兵": {"戰鬥": [0.30, 0.50]},
	"老兵": {"戰鬥": [0.50, 0.70], "戰術": [0.30, 0.50], "統領": [0.30, 0.50]},
	"菁英": {"戰鬥": [0.70, 0.90], "戰術": [0.50, 0.70], "統領": [0.50, 0.70]},
}

# 生成一個 PersonData，seed_offset 決定隨機結果
# role: "leader" / "member"（leader 技能 +0.1 bonus）
static func generate(state: WorldState, seed_offset: int,
		role: String = "member") -> PersonData:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_offset

	var p := PersonData.new()
	p.id = _next_id(state)
	p.person_name = _random_name(rng, state)
	p.role = role
	p.age = rng.randi_range(18, 50)
	p.sex = "female" if rng.randf() < 0.5 else "male"   # 50/50（seeded，可重現）
	p.loyalty = 1.0 if role == "leader" else rng.randf_range(0.5, 1.0)
	p.stress = 0.0
	p.fear = 0.0

	# Values：多數窄帶凡人
	for v in p.values.keys():
		p.values[v] = rng.randf_range(NORMAL_LO, NORMAL_HI)

	# Attributes 0.4~0.8（PersonData 預設 4 鍵：體力/智力/魅力/毅力）
	for a in p.attributes.keys():
		p.attributes[a] = rng.randf_range(0.4, 0.8)

	# Skills：多數低；leader +0.1
	for sk in p.skills.keys():
		var base: float = rng.randf_range(0.0, 0.3)
		if role == "leader": base += 0.1
		p.skills[sk] = clampf(base, 0.0, 1.0)

	# 戲劇尾巴：per-person outlier roll → archetype 簇推極端（連貫人格）
	var rate: float = OUTLIER_RATE_LEADER if role == "leader" else OUTLIER_RATE
	if rng.randf() < rate:
		var names: Array = ARCHETYPES.keys()
		var arch: Dictionary = ARCHETYPES[names[rng.randi() % names.size()]]
		for v in arch["hi_v"]:
			p.values[v] = rng.randf_range(EXTREME_HI_LO, 1.0)
		for v in arch["lo_v"]:
			p.values[v] = rng.randf_range(0.0, EXTREME_LO_HI)
		for sk in arch["hi_s"]:
			p.skills[sk] = rng.randf_range(SKILL_TAIL_LO, SKILL_TAIL_HI)

	return p

static func generate_for_team(state: WorldState, team: TeamData,
		role: String = "member", seed_offset: int = 0) -> PersonData:
	var named_count: int = (1 if team.leader_id != -1 else 0) + team.named_members.size()
	var anon_pop: int = team.population - named_count
	if anon_pop <= 0:
		return null

	var p := generate(state, _team_seed(state, team, seed_offset), role)
	p.team_id = team.team_id
	# 升 anon → named 帶 treasury share ×3
	if anon_pop > 0 and team.anon_treasury > 0.0:
		var per_share: float = team.anon_treasury / float(anon_pop)
		var bonus: float = minf(per_share * 3.0, team.anon_treasury)
		p.coin += bonus
		team.anon_treasury -= bonus
	state.persons[p.id] = p
	# 晉升：抽 1 anon（偏高 tier = 提拔精銳）→ 轉 named；記實際來源 tier
	var killed: Dictionary = AnonTierSystem.kill_random(team, 1, "promote", PROMOTE_TIER_WEIGHT)
	var src_tier: String = ""
	for tier in AnonCohort.TIER_ORDER:
		if int(killed.get(tier, 0)) > 0:
			src_tier = tier
			break
	if src_tier != "":
		_apply_promotion_skills(p, src_tier, _team_seed(state, team, seed_offset))
	return p

# 來源 tier → 新 named 戰鬥簇技能下限（maxf 不蓋 archetype 尾巴）
static func _apply_promotion_skills(p: PersonData, src_tier: String, seed: int) -> void:
	var bands: Dictionary = PROMOTE_TIER_SKILLS.get(src_tier, {})
	if bands.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 31 + 7   # 與 generate 內部 rng 區隔，保可重現
	for sk in bands:
		var band: Array = bands[sk]
		var v: float = rng.randf_range(float(band[0]), float(band[1]))
		p.skills[sk] = maxf(float(p.skills.get(sk, 0.0)), v)

static func _next_id(state: WorldState) -> int:
	var max_id: int = -1
	for pid in state.persons:
		if int(pid) > max_id: max_id = int(pid)
	return max_id + 1

static func _random_name(rng: RandomNumberGenerator, state: WorldState) -> String:
	var attempts: int = 10
	while attempts > 0:
		var s: String = SURNAMES[rng.randi() % SURNAMES.size()]
		var g: String = GIVEN_NAMES[rng.randi() % GIVEN_NAMES.size()]
		var name: String = s + g
		var dup := false
		for pid in state.persons:
			if state.persons[pid].person_name == name:
				dup = true; break
		if not dup: return name
		attempts -= 1
	return "%s%s%d" % [SURNAMES[rng.randi() % SURNAMES.size()],
					   GIVEN_NAMES[rng.randi() % GIVEN_NAMES.size()],
					   state.persons.size()]

static func _team_seed(state: WorldState, team: TeamData, seed_offset: int) -> int:
	var base: int = 17
	base = base * 31 + state.world.current_tick
	base = base * 31 + team.team_id
	base = base * 31 + team.population
	base = base * 31 + team.leader_id
	base = base * 31 + team.named_members.size()
	base = base * 31 + state.persons.size()
	base = base * 31 + seed_offset
	return abs(base)
