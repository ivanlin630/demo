class_name TeamData

const TASK_IDLE        := "idle"
const TASK_TRIBUTE     := "徵收"
const TASK_SCOUT       := "偵查"
const TASK_HERALD      := "信使"
const TASK_ATTACK      := "攻擊"
const TASK_LOOT        := "掠奪"
const TASK_DIPLOMACY   := "外交"
const TASK_ESCORT      := "護衛"
const TASK_FLEE        := "逃跑"
const TASK_PRODUCE     := "生產"
const TASK_MANUFACTURE := "製造"
const TASK_TRADE       := "貿易"
const TASK_PATROL      := "巡邏"
const TASK_BUILD       := "建設"
const TASK_MERGE       := "合併"

const TAG_COMMAND  := "統領"
const TAG_MILITARY := "軍隊"
const TAG_MERCHANT := "商隊"
const TAG_PRODUCE  := "生產"
const TAG_RELIGION := "宗教"
const TAG_EXILE    := "流亡"
const TAG_SUBTEAM  := "子團"

static func pop_cap_from_leadership(skill: float) -> int:
	return clampi(int(round(49.0 * minf(skill / 0.8, 1.0))) + 1, 1, 50)

var team_id: int = 0
var leader_id: int = -1
var advisors: Array = []
var members: Array = []
var named_members: Array = []   # 合併 advisors+members；遷移完成後移除舊欄位
var population: int = 1
var minor_population: int = 0
var resources: Dictionary = {
	"food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
	"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
	"weapon_melee_low": 0, "weapon_melee_high": 0,
	"weapon_ranged_low": 0, "weapon_ranged_high": 0,
}
var tags: Array = []
var current_task: String = "idle"
var unrest_turns: int = 0
var faction_id: int = -1
var tile_pos: Vector2i = Vector2i.ZERO
var move_target: Vector2i = Vector2i(-1, -1)  # -1,-1 = 無目標，不移動
var move_tick_acc: int = 0
var combat_target: int = -1
var readiness: float   = 1.0
var wounded: int       = 0
var equip_order: Dictionary = {
	"melee_low": 0, "melee_high": 0,
	"ranged_low": 0, "ranged_high": 0,
}
var armed_anon_ratio: float = 0.0
var parent_team_id: int  = -1
var subteam_ids:    Array = []
var order_target_id: int  = -1
var order_task:     String = ""
