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
	p.loyalty = 1.0 if role == "leader" else rng.randf_range(0.5, 1.0)
	p.stress = 0.0
	p.fear = 0.0

	# Values（直接 iterate PersonData 預設 8 鍵）
	for v in p.values.keys():
		p.values[v] = rng.randf_range(0.2, 0.8)

	# Attributes 0.4~0.8（PersonData 預設 4 鍵：體力/智力/魅力/毅力）
	for a in p.attributes.keys():
		p.attributes[a] = rng.randf_range(0.4, 0.8)

	# Skills 0.0~0.3（leader +0.1）
	for s in p.skills.keys():
		var base: float = rng.randf_range(0.0, 0.3)
		if role == "leader": base += 0.1
		p.skills[s] = clampf(base, 0.0, 1.0)

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
	return p

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
