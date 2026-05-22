class_name SkillSystem

const BASE_GROWTH: float = 0.005
const MAX_SKILL: float = 1.0

const REACTION_SKILL_MAP: Dictionary = {
	"P2_produce": { "skill": "生產",  "attr": "智力" },
	"P3_recruit": { "skill": "統領",  "attr": "魅力" },
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
	var attr_val: float = float(person.attributes.get(attr_key, 0.5))
	var endurance: float = float(person.attributes.get("毅力", 0.5))
	var growth: float = BASE_GROWTH * attr_val * (0.5 + endurance * 0.5)
	var current: float = float(person.skills.get(skill_key, 0.0))
	person.skills[skill_key] = minf(current + growth, MAX_SKILL)
