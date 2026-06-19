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
const TASK_TRAIN       := "訓練"
const TASK_DEFEND      := "迎戰"
const TASK_PREPARE     := "備戰"
const TASK_FORAGE      := "覓食"
const TASK_CAMP        := "紮營"
const TASK_SETTLE      := "安頓"
const TASK_PACIFY      := "安撫"
const TASK_BEG         := "乞食"
const TASK_JOIN        := "投靠"
const TASK_RETURN_HOME := "return_home"
const TASK_REVOLT      := "起義"
const TASK_REST        := "rest"
const TASK_GOVERN      := "治理"
const TASK_HOLD        := "守城"
const TASK_MIGRATE     := "遷徙"
const TASK_CONSTRUCT   := "建造"
const TASK_UPGRADE     := "升級"
const TASK_EXPAND      := "擴建"
const TASK_TRIBUTE_OFFER := "tribute_offer"   # order_task（提供納貢），非 current_task

const TAG_COMMAND  := "統領"
const TAG_MILITARY := "軍隊"
const TAG_MERCHANT := "商隊"
const TAG_PRODUCE  := "生產"
const TAG_RELIGION := "宗教"
const TAG_EXILE    := "流亡"
const TAG_SUBTEAM  := "子團"
const TAG_BEAST    := "野獸"

static func pop_cap_from_leadership(skill: float) -> int:
	return clampi(int(round(49.0 * minf(skill / 0.8, 1.0))) + 1, 1, 50)

var team_id: int = 0
var leader_id: int = -1
var named_members: Array = []
# 衍生：leader(0/1) + named + anon(含 wounded 桶)。唯讀，不可 drift。
var population: int:
	get:
		return (1 if leader_id != -1 else 0) + named_members.size() + AnonTierSystem.total_pop(self)
	set(_value):
		pass
var minor_population: int = 0
var prisoner_population: int = 0   # 俘虜（上限 = population；不計入戰鬥 spawn）
var famine_days: float = 0.0   # 連續斷糧（satisfaction<0.3）累積天數；飢餓致死鏈用（型別 float，語意=天）
var forage_today: float = 0.0   # 當日覓食累積（episode 日彙整用，日邊界歸零）
var solo_intent: String = ""   # 上次 SoloAI 選的策略方向（承諾慣性用）
var beast_kind: String = ""       # 非空 = 此 team 為野獸 pseudo-team（鹿/野豬/熊/狼群）
var beast_strength: float = 0.0   # npc_combat 用：beast team 的整體戰鬥力
var resources: Dictionary = {
	"food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
	"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
	"weapon_melee_low": 0, "weapon_melee_high": 0,
	"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
	"armor_low": 0, "armor_high": 0,
}
var tags: Array = []
var current_task: String = TASK_IDLE
var task_priority: int = 0   # 現任 task 優先權；idle 時 0（TaskArbiter 管理）
var previous_task: String = ""   # survival override 前的原 task，回復用
var tax_rate: float = 0.3                    # 收稅率（PRODUCE team 用，0.1-0.7）
var merchant_inventory: Array = []           # 商隊 inventory，元素: {grade, qty, bought_at, bought_from}
var occupying_outpost_since: int = -1        # 駐留無人 outpost 起始 tick，達 3 天接管
var pending_owner_change_tick: int = -1      # 偵測 owner 異動緩衝倒數（7 天）
var unrest_turns: int = 0
var work_morale: float = 1.0   # 工作態度係數 [0.5,1.5]，reaction 統計寫入，產出系統消費
var faction_id: int = -1
var tile_pos: Vector2i = Vector2i.ZERO
var move_target: Vector2i = Vector2i(-1, -1)  # -1,-1 = 無目標，不移動
var last_tile_pos: Vector2i = Vector2i(-999, -999)   # 上一移動步位置（observe_velocity 用）
var move_tick_acc: int = 0
var combat_target: int = -1
var encounter_initial_pop: int = 0   # 遭遇戰開始時人口快照（mount loot kill_ratio 用）
var prosperity_eval_next_tick: int = 0   # 下次 prosperity 評估 tick（cadence + 事件重評）
# G2 野心階梯（leader values 衍生，單一真值源；見 AmbitionLadder）
var ambition_archetype: String = ""   # 武力/商業/定居
var ambition_cap: int = 0             # 終極野心封頂 rung
var ambition_rung: int = 0            # 當前實際 rung（0 生存…4 稱霸）
var ambition_eval_next_tick: int = 0
# G1 訂單系統：權威訂單（message 為可失真傳播副本）。{order_id, kind, res, qty_remaining, expire_tick}
var active_orders: Array = []
var order_eval_next_tick: int = 0   # 下次訂單 cadence 評估 tick
var prosperity_target_id: int = -1       # prosperity 攻擊/掠奪 追擊目標 team（move_target 每 tick 依 intel 刷新）
var threat_eval_next_tick: int = 0       # 下次威脅評估 tick（cadence）
var residency_eval_next_tick: int = 0    # 下次 outpost 居民派駐評估 tick（cadence）
var invite_cooldown: Dictionary = {}     # { tid: tick_until } 邀請流亡安頓的冷卻
var diplomacy_reject_cooldown: Dictionary = {}   # { target_tid: tick_until } 被拒後同對象外交冷卻
var trade_task_start_tick: int = 0       # 貿易 task 起始 tick（timeout 防 zombie）
var task_reason: String = ""             # 最近一次 task 設定來源（TaskArbiter _source；遙測用）
var task_start_tick: int = 0             # 最近一次 task 設定 tick（逃跑/survival timeout 用）
var readiness: float   = 1.0
# 傷兵數 = cohort wounded 桶投影（取代舊 int 累加器；唯讀，舊寫入走 AnonTierSystem wound/heal/kill_wounded）
var wounded: int:
	get:
		return AnonCohort.by_health(anon_cohorts, "wounded")
	set(_value):
		pass
var equip_order: Dictionary = {
	"melee_low": 0, "melee_high": 0,
	"ranged_low": 0, "ranged_high": 0,
}
# ── Anon Tier 系統（取代舊 scalar anon_combat_skill / anon_wage）──
# Anon Cohort 統一容器（取代舊 anon_tiers）：鍵 "tier|health" → count，稀疏。
# Phase 2a：只用 health="healthy" 桶；wounded 維度 Phase 2b 啟用。
var anon_cohorts: Dictionary = {}
# 向後相容唯讀 getter：回 4-tier breakdown（{tier: 該 tier 跨 health 總數}）。
# 舊「讀」零改；舊「寫」（= / []=）走 set no-op → 強迫改走 AnonCohort 入口。
var anon_tiers: Dictionary:
	get:
		var d: Dictionary = {}
		for tier in AnonCohort.TIER_ORDER:
			d[tier] = AnonCohort.by_tier(anon_cohorts, tier)
		return d
	set(_value):
		pass
var anon_exp: Dictionary = {
	"平民": 0.0, "新兵": 0.0, "老兵": 0.0,
}
# 向後相容 computed getter（read-only；舊 set 點為 no-op）
var anon_combat_skill: float:
	get:
		return AnonTierSystem.avg_combat_skill(self)
	set(_value):
		pass
var anon_wage: float:
	get:
		var total: int = AnonTierSystem.total_pop(self)
		if total <= 0:
			return 1.0
		return AnonTierSystem.total_wage(self) / float(total)
	set(_value):
		pass
var armed_anon_ratio: float = 0.0
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

# 對 other_id 隊的口碑增減（clamp 0~1，預設 0.5 中立）；外交/施捨/勒索共用
func update_reputation(other_id: int, delta: float) -> void:
	known_reputations[other_id] = clampf(float(known_reputations.get(other_id, 0.5)) + delta, 0.0, 1.0)
