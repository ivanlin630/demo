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
var named_members: Array = []
var population: int = 1
var minor_population: int = 0
var prisoner_population: int = 0   # 俘虜（上限 = population；不計入戰鬥 spawn）
var resources: Dictionary = {
	"food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
	"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
	"weapon_melee_low": 0, "weapon_melee_high": 0,
	"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
	"armor_low": 0, "armor_high": 0,
}
var tags: Array = []
var current_task: String = "idle"
var previous_task: String = ""   # survival override 前的原 task，回復用
var tax_rate: float = 0.3                    # 收稅率（PRODUCE team 用，0.1-0.7）
var merchant_inventory: Array = []           # 商隊 inventory，元素: {grade, qty, bought_at, bought_from}
var occupying_outpost_since: int = -1        # 駐留無人 outpost 起始 tick，達 3 天接管
var pending_owner_change_tick: int = -1      # 偵測 owner 異動緩衝倒數（7 天）
var unrest_turns: int = 0
var faction_id: int = -1
var tile_pos: Vector2i = Vector2i.ZERO
var move_target: Vector2i = Vector2i(-1, -1)  # -1,-1 = 無目標，不移動
var last_tile_pos: Vector2i = Vector2i(-999, -999)   # 上一移動步位置（observe_velocity 用）
var move_tick_acc: int = 0
var combat_target: int = -1
var prosperity_eval_next_tick: int = 0   # 下次 prosperity 評估 tick（cadence + 事件重評）
var readiness: float   = 1.0
var wounded: int       = 0
var equip_order: Dictionary = {
	"melee_low": 0, "melee_high": 0,
	"ranged_low": 0, "ranged_high": 0,
}
var anon_combat_skill: float = 0.2
var armed_anon_ratio: float = 0.0
var anon_wage: float = 1.0
var anon_treasury: float = 0.0   # 匿名兵 wage 沉澱
var fatigue: float = 0.0
var guard_ratio: float = 0.2
var armor_config: Dictionary = {
	"head":       "none",
	"torso":      "low",
	"right_arm":  "none",
	"left_arm":   "none",
	"right_leg":  "none",
	"left_leg":   "none",
}
var known_reputations: Dictionary = {}
var strategic_assignments: Dictionary = {}
var parent_team_id: int  = -1
var subteam_ids:    Array = []
var order_target_id: int  = -1
var order_task:     String = ""
var player_commanded_task: String = ""
# 玩家對此 team 的直接指令；"" = 無指令（faction_ai 自動計算）；由 herald 抵達後寫入
var task_extra_data: Dictionary = {}   # 子隊任務附加數據（build_type/level/facility_type/target_level 等）
