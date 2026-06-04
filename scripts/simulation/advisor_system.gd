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
		return "（無顧問）"
	var skill: String  = SITUATION_SKILL_MAP.get(situation, "計謀")
	var accurate: bool = _advice_is_accurate(advisor, skill)
	var tone: String   = _advisor_tone(advisor)
	if not accurate:
		return "（%s 判斷失誤，建議不可靠）" % advisor.person_name
	var advice_prefix: String = "%s 建議：" % advisor.person_name
	match situation:
		"attack":
			return advice_prefix + ("果斷出擊，速戰速決" if tone == "blunt" else "評估敵情後再行動")
		"diplomacy":
			return advice_prefix + ("以利誘之，廣結善緣" if tone == "formal" else "謹慎外交，觀察形勢")
		"resource":
			return advice_prefix + ("儲糧備戰，未雨綢繆" if tone == "default" else "加緊生產，充實資源")
		_:
			return advice_prefix + "當前形勢需審慎應對"

func _advice_is_accurate(advisor: PersonData, skill: String) -> bool:
	return randf() < float(advisor.skills.get(skill, 0.0))

func _advisor_tone(advisor: PersonData) -> String:
	if float(advisor.values.get("計謀", 0.5)) > 0.7 \
			and float(advisor.values.get("義氣", 0.5)) < 0.3:
		return "sarcastic"
	if float(advisor.values.get("好戰", 0.5)) > 0.7: return "blunt"
	if float(advisor.values.get("信義", 0.5)) > 0.6: return "formal"
	return "default"
