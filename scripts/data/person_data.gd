class_name PersonData

var id: int = 0
var person_name: String = ""
var role: String = "civilian"
var team_id: int = -1
var is_dead: bool = false   # 死亡留屍標記：named 死後 person 仍留 state.persons + team_id 不清（供 get_player_team_id），此 flag 供反向 roster audit 跳過（不誤報屍）
var age: int = 20
var sex: String = "male"   # "male"/"female"（④Trait 前置資料；anon 用 team.anon_female_ratio）

var needs: Dictionary = { "food": 1.0, "safety": 1.0, "belonging": 1.0 }
var stress: float = 0.0
var fear: float = 0.0
var loyalty: float = 1.0
var goals: Array = []

var attributes: Dictionary = {
	"體力": 0.5,   # 影響 戰鬥/弓箭/求生 成長
	"智力": 0.5,   # 影響 生產/製造/工程/醫療/戰術/計謀 成長
	"魅力": 0.5,   # 影響 統領/交涉/商業 成長
	"毅力": 0.5,   # 所有技能成長乘數
}

var skills: Dictionary = {
	"統領": 0.0, "戰鬥": 0.0, "弓箭": 0.0, "求生": 0.0,
	"生產": 0.0, "製造": 0.0, "工程": 0.0, "醫療": 0.0,
	"戰術": 0.0, "計謀": 0.0, "交涉": 0.0, "商業": 0.0,
	"偵查": 0.0, "潛行": 0.0,
}

# 慎重是跨系統關鍵字：所有涉及風險決策的系統（交涉/戰術/戰略/戰鬥/訊息失真）
# 必須讀取此值。高慎重 → 壓低激進選項；低慎重 → 壓低保守選項。
var values: Dictionary = {
	"野心": 0.5,   # 高 → 偏好擴張/統領目標
	"求生欲": 0.5, # 高 → 受威脅時偏好逃亡
	"義氣": 0.5,   # 高 → 忠誠難降，不輕易分裂
	"貪婪": 0.5,   # 高 → 偏好勒索/積累資源
	"慎重": 0.5,   # 高 → 壓低所有風險行為（跨系統）
	"好戰": 0.5,   # 高 → 主動尋求戰鬥（區別野心的擴張傾向）
	"殘忍": 0.5,   # 高 → 戰後屠殺；低 → 接受投降
	"信義": 0.5,   # 高 → 遵守協議；低 → 容易背叛
}

var equipment: Dictionary = {
	"head":       { "type": "none", "grade": "" },
	"torso":      { "type": "none", "grade": "" },
	"right_arm":  { "type": "none", "grade": "" },
	"left_arm":   { "type": "none", "grade": "" },
	"right_leg":  { "type": "none", "grade": "" },
	"left_leg":   { "type": "none", "grade": "" },
	"hand_1":     { "type": "none", "grade": "" },
	"hand_2":     { "type": "none", "grade": "" },
}

var memory: Array = []
var last_reaction: String = ""   # diff print 用

var salary: float = 0.0
var coin: float = 0.0
var blood: float = 100.0
var hunger: float = 0.0   # 個人飢餓累積 [0,1]；跟人走不跟團（中途加入不繼承團時鐘）；飢餓致死鏈用
var relations: Dictionary = {}
var relation_edges: Array = []   # G2 typed-edge 關係圖（feud/killed/protect/gratitude；見 RelationGraph）

var body_parts: Dictionary = {
	"head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy",
	               "poisoned": false, "bleeding": "none", "fracture": false },
	"torso":     { "hp": 50.0, "max_hp": 50.0, "status": "healthy",
	               "poisoned": false, "bleeding": "none", "fracture": false },
	"right_arm": { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
	               "poisoned": false, "bleeding": "none", "fracture": false },
	"left_arm":  { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
	               "poisoned": false, "bleeding": "none", "fracture": false },
	"right_leg": { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
	               "poisoned": false, "bleeding": "none", "fracture": false },
	"left_leg":  { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
	               "poisoned": false, "bleeding": "none", "fracture": false },
}

# status: "healthy"(×1.0) / "wounded"(×0.7) / "critical"(×0.3) / "severed"(×0.0)
const STATUS_MULT: Dictionary = {
	"healthy": 1.0, "wounded": 0.7, "critical": 0.3, "severed": 0.0
}

func get_effective_speed() -> float:
	var base: float = 0.5 + float(attributes.get("體力", 0.5)) * 0.5
	var r: float = 1.0 if not body_parts["right_leg"].get("fracture", false) else 0.5
	var l: float = 1.0 if not body_parts["left_leg"].get("fracture", false) else 0.5
	var leg_mult: float = 1.0
	if r < 1.0 and l < 1.0: leg_mult = 0.1
	elif r < 1.0 or l < 1.0: leg_mult = 0.5
	return base * leg_mult

func get_skill_mult(skill: String) -> float:
	var arm_skills: Array = ["戰鬥", "弓箭", "製造", "工程", "醫療"]
	if skill in arm_skills:
		var r: float = STATUS_MULT.get(body_parts["right_arm"]["status"], 1.0)
		var l: float = STATUS_MULT.get(body_parts["left_arm"]["status"], 1.0)
		return (r + l) / 2.0
	return 1.0

func get_attribute_mult(attr: String) -> float:
	if attr in ["智力", "魅力"]:
		return STATUS_MULT.get(body_parts["head"]["status"], 1.0)
	if attr in ["體力", "毅力"]:
		return STATUS_MULT.get(body_parts["torso"]["status"], 1.0)
	return 1.0
