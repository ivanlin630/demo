# scripts/data/encounter_templates.gd
class_name EncounterTemplates

const TEMPLATES: Dictionary = {
	"archer": {
		"fill": [
			{ "grade": "arrows",   "qty": 20 },
			{ "grade": "medicine", "qty": 2  },
		],
	},
	"melee": {
		"fill": [
			{ "grade": "medicine", "qty": 3 },
		],
	},
	"medic": {
		"fill": [
			{ "grade": "medicine", "qty": 6 },
		],
	},
	"default": {
		"fill": [
			{ "grade": "medicine", "qty": 2 },
		],
	},
}

static func select_template(unit: Dictionary, state: WorldState) -> String:
	if unit.get("person_id", -1) != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p and float(p.skills.get("醫療", 0.0)) > 0.5:
			return "medic"
	var equip: Dictionary = unit.get("equipment", {})
	var h1_grade: String  = equip.get("hand_1", {}).get("grade", "")
	if h1_grade.contains("ranged"): return "archer"
	for hand in ["hand_1", "hand_2"]:
		if equip.get(hand, {}).get("grade", "").begins_with("armor_"):
			return "melee"
	if h1_grade.contains("melee") or h1_grade == "unarmed":
		return "melee"
	return "default"

static func fill_inventory(unit: Dictionary, team: TeamData,
		state: WorldState) -> void:
	var tmpl_name: String = select_template(unit, state)
	var tmpl: Dictionary  = TEMPLATES.get(tmpl_name, TEMPLATES["default"])
	var inv: Array        = unit.get("inventory", [])
	for entry in tmpl["fill"]:
		var grade: String = entry["grade"]
		var want: int     = entry["qty"]
		var avail: int    = int(team.resources.get(grade, 0))
		var give: int     = mini(want, avail)
		if give <= 0: continue
		inv.append({ "grade": grade, "type": "pool", "qty": give })
		team.resources[grade] = avail - give
	unit["inventory"] = inv
