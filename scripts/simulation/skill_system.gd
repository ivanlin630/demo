class_name SkillSystem

const BASE_GROWTH: float = 0.005
const MAX_SKILL: float = 1.0

static func cap_add(person: PersonData, skill: String, delta: float) -> void:
	if person == null or delta <= 0.0:
		return
	person.skills[skill] = minf(float(person.skills.get(skill, 0.0)) + delta, MAX_SKILL)

const REACTION_SKILL_MAP: Dictionary = {
	"P2_produce": { "skill": "生產",  "attr": "智力" },
	"P4_expand":  { "skill": "統領",  "attr": "魅力" },
	"P5_breed":   { "skill": "醫療",  "attr": "智力" },
	"N1_flee":    { "skill": "求生",  "attr": "體力" },
	"N2_riot":    { "skill": "戰鬥",  "attr": "體力" },
	"N3_defect":  { "skill": "計謀",  "attr": "智力" },
	"N4_shirk":   { "skill": "求生",  "attr": "體力" },
	"N5_extort":  { "skill": "商業",  "attr": "魅力" },
}
# 戰術/工程/弓箭/製造/交涉 成長來源：戰鬥事件（後續戰鬥系統加入）

func on_reaction(person: PersonData, reaction: String) -> void:
	if not REACTION_SKILL_MAP.has(reaction):
		return
	var entry: Dictionary = REACTION_SKILL_MAP[reaction]
	var skill_key: String = entry["skill"]
	var attr_key: String = entry["attr"]
	var attr_val: float = float(person.attributes.get(attr_key, 0.5)) * person.get_attribute_mult(attr_key)
	var endurance: float = float(person.attributes.get("毅力", 0.5)) * person.get_attribute_mult("毅力")
	var growth: float = BASE_GROWTH * attr_val * (0.5 + endurance * 0.5) * person.get_skill_mult(skill_key)
	var current: float = float(person.skills.get(skill_key, 0.0))
	person.skills[skill_key] = minf(current + growth, MAX_SKILL)

func on_combat_round(state: WorldState, team: TeamData) -> void:
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
		if wtype in ["melee_low", "melee_high"]:
			_grow(p, "戰鬥", "體力")

func on_volley(state: WorldState, team: TeamData) -> void:
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
		if wtype in ["ranged_low", "ranged_high"]:
			_grow(p, "弓箭", "智力")

func on_combat_end(state: WorldState, team: TeamData) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null:
		return
	_grow(leader, "戰術", "智力")

func _grow(p: PersonData, skill: String, attr: String) -> void:
	var attr_val: float  = float(p.attributes.get(attr, 0.5)) * p.get_attribute_mult(attr)
	var endurance: float = float(p.attributes.get("毅力", 0.5)) * p.get_attribute_mult("毅力")
	var growth: float    = BASE_GROWTH * attr_val * (0.5 + endurance * 0.5) * p.get_skill_mult(skill)
	SkillSystem.cap_add(p, skill, growth)
