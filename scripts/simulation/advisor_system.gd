class_name AdvisorSystem

const SITUATION_SKILL_MAP: Dictionary = {
	"assess_enemy":  "戰術",
	"diplomatic":    "交涉",
	"resources":     "生產",
	"strategic":     "計謀",
	"intel_read":    "偵查",
}

func get_advice(advisor: PersonData, situation: String,
		situation_data: Dictionary, state: WorldState) -> String:
	if advisor == null:
		return TextBank.fmt("advisor_" + situation, "default", situation_data)
	var skill: String  = SITUATION_SKILL_MAP.get(situation, "計謀")
	var accurate: bool = _advice_is_accurate(advisor, skill)
	var variant: String = _pick_variant(advisor, situation, accurate, situation_data)
	var params: Dictionary = _build_params(advisor, situation, situation_data, state)
	return TextBank.fmt("advisor_" + situation, variant, params)

func _advice_is_accurate(advisor: PersonData, skill: String) -> bool:
	return randf() < float(advisor.skills.get(skill, 0.0))

func _advisor_tone(advisor: PersonData) -> String:
	if float(advisor.values.get("計謀", 0.5)) > 0.7 \
			and float(advisor.values.get("義氣", 0.5)) < 0.3:
		return "sarcastic"
	if float(advisor.values.get("好戰", 0.5)) > 0.7: return "blunt"
	if float(advisor.values.get("信義", 0.5)) > 0.6: return "formal"
	return "default"

func _pick_variant(advisor: PersonData, situation: String,
		accurate: bool, data: Dictionary) -> String:
	var hawkish: bool  = float(advisor.values.get("好戰", 0.5)) > 0.7
	var cautious: bool = float(advisor.values.get("慎重", 0.5)) > 0.7
	if not accurate:
		return "wrong_underestimate" if randf() < 0.5 else "wrong_overestimate"
	match situation:
		"assess_enemy":
			var enemy_strong: bool = int(data.get("enemy_pop", 0)) > int(data.get("self_pop", 0))
			if hawkish:  return "biased_attack"
			if cautious: return "biased_retreat"
			return "accurate_strong" if enemy_strong else "accurate_weak"
		"diplomatic":
			var hostile: bool = data.get("hostile", false)
			if hawkish:  return "biased_war"
			if cautious: return "biased_peace"
			return "accurate_hostile" if hostile else "accurate_friendly"
		"resources":
			var days: float = float(data.get("days_left", 99.0))
			return "accurate_critical" if days < 5.0 else "accurate_stable"
		_:
			return _advisor_tone(advisor)

func _build_params(advisor: PersonData, situation: String,
		data: Dictionary, _state: WorldState) -> Dictionary:
	var p: Dictionary = data.duplicate()
	if not p.has("advisor_name"): p["advisor_name"] = advisor.person_name if advisor else "副官"
	return p
