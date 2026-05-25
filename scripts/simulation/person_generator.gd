# scripts/simulation/person_generator.gd
class_name PersonGenerator

const TAG_ATTR_BIAS: Dictionary = {
	"軍隊": { "體力": 0.1 },
	"生產": { "智力": 0.1 },
	"商隊": { "魅力": 0.1 },
	"宗教": { "魅力": 0.1 },
	"統領": { "體力": 0.05, "魅力": 0.05 },
	"流亡": { "毅力": 0.1 },
}

const TAG_SKILL_BIAS: Dictionary = {
	"軍隊": { "戰鬥": 0.05, "弓箭": 0.05 },
	"生產": { "生產": 0.05, "製造": 0.05 },
	"商隊": { "交涉": 0.05, "商業": 0.05 },
	"宗教": { "交涉": 0.05 },
	"統領": { "統領": 0.05 },
	"流亡": { "求生": 0.05 },
}

func generate(team: TeamData, state: WorldState) -> PersonData:
	var named_count: int = (1 if team.leader_id != -1 else 0) \
		+ team.advisors.size() + team.members.size()
	var anon_pop: int = team.population - named_count
	if anon_pop <= 0:
		return null

	var p := PersonData.new()
	p.id          = _next_id(state)
	p.person_name = "NPC_%d" % p.id
	p.role        = "civilian"
	p.team_id     = team.team_id
	p.age         = randi_range(18, 40)
	p.loyalty     = 0.5
	p.stress      = 0.0

	for attr in p.attributes:
		p.attributes[attr] = randf_range(0.2, 0.8)
	for v in p.values:
		p.values[v] = randf_range(0.2, 0.8)
	for skill in p.skills:
		p.skills[skill] = randf_range(0.0, 0.2)

	for tag in team.tags:
		if TAG_ATTR_BIAS.has(tag):
			for attr in TAG_ATTR_BIAS[tag]:
				p.attributes[attr] = clampf(
					p.attributes[attr] + float(TAG_ATTR_BIAS[tag][attr]), 0.2, 0.8)
		if TAG_SKILL_BIAS.has(tag):
			for skill in TAG_SKILL_BIAS[tag]:
				p.skills[skill] = clampf(
					p.skills[skill] + float(TAG_SKILL_BIAS[tag][skill]), 0.0, 0.2)

	state.persons[p.id] = p
	return p

func _next_id(state: WorldState) -> int:
	if state.persons.is_empty():
		return 0
	return state.persons.keys().max() + 1
