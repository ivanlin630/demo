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
var anon_female_ratio: float = 0.5   # anon 女性占比(metadata,不影響 pop count);戰損可扭斜(combat他域後)
var prisoner_population: int = 0   # 俘虜（上限 = population；不計入戰鬥 spawn）
# 受控人力 Phase 1：captive 群（征服吸收敗方 anon）。元素 Dict:
#   { cohorts: { "tier|health": count }, morale: float, origin_faction: int, entry: String, treatment_history: Array }
# 隔離持有（非戰力，不入 population getter，直到同化）。守恆轉移只經 AnonTierSystem.absorb_as_captive/assimilate_captives。
var captive_groups: Array = []
# ③ asm 看守強度：holder 撥多少比例 anon 當看守（連續 0..0.5，ManpowerSystem 每日決策寫）。
# 驅動 flee 機率 + guard-cap（captive 上限 ∝ guard_n）。TEST VALUE 公式見 ManpowerSystem。
var captive_guard_ratio: float = 0.0
var famine_days: float = 0.0   # 連續斷糧（satisfaction<0.3）累積天數；飢餓致死鏈用（型別 float，語意=天）
var forage_today: float = 0.0   # 當日覓食累積（episode 日彙整用，日邊界歸零）
# R2 食物流訊號（flow-not-stock 成長）：日均淨食物流 (income − consumption) EMA。
# 成長 gate（生育/野心 accumulate）讀此，非 stale 滿倉 stock → 爆倉不再驅動成長。
# 由 ResourceSystem.resolve_consumption 每 cadence 更新（見 _update_food_flow）。
var food_flow_avg: float = 0.0    # 日均淨食物流 EMA（食物/天）
var food_flow_last: float = -1.0   # 上次取樣 effective_food（sentinel -1 = 未初始化，首取樣不計流）
var rung_stall_count: int = 0   # 計畫層：連續失守當前 rung milestone 次數（達 K 降 rung）
var plan_phase: String = ""   # 計畫層 S2：中長期 phase（求糧/成長/聚勢/立國），gather 導出持久（GUI/hysteresis）
var rung_pop_last: int = 0   # 計畫層 S3：上期 pop（算單期驟降，survival-bypass 劇變偵測）
# 需求金字塔（決策引擎重構）：五層急迫度 EWMA 持久狀態（生存/安全/歸屬/尊重/自我實現）。
# 感測器非決策者，gather 每 cadence 更新；rank_scored 讀此算一致性係數。size 5 或 0(冷啟)。
var need_urgency: PackedFloat32Array = PackedFloat32Array()
# 統一戰略意圖 struct {type,why,mode}（F-D4：廢一槽兩義）。戰略層(獨立建國/致富/征服/守成)寫；
# 空 {} = 無戰略意圖。SoloAI 日常 task 承諾改用 solo_task_last（下方），不再共用此槽。
var solo_intent: Dictionary = {}
var solo_task_last: String = ""   # SoloAI 上次選的 task（承諾慣性；與戰略 intent 分離，F-D4）
var current_option: String = ""   # 統一決策引擎承諾用（現行 option 名）
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
# flee 位移根治：FLEE 派出時設=威脅 belief 位（感知鐵律）；mover 朝遠離此位算 away-tile。release 清。(-1,-1)=無威脅可逃離。
var flee_from_pos: Vector2i = Vector2i(-1, -1)
var last_tile_pos: Vector2i = Vector2i(-999, -999)   # 上一移動步位置（observe_velocity 用）
var move_tick_acc: int = 0
var combat_target: int = -1
# 社交互動目標（投靠/乞食），語意 ≠ combat_target（戰鬥中 flag）。
# BEG/JOIN dispatch 設此、interaction resolver 讀此；_try_interact:197 早退只看 combat_target
# → 社交隊 combat_target=-1 過 197 到 resolver。走 WorldState.set/clear_social_target chokepoint。
var social_target: int = -1
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
var decision_eval_next_tick: int = 0     # 重評 cadence 重構：下次決策重評 tick（週期閘，非-unified 解 IDLE-lock）
var last_decision_tick: int = 0          # ⑦ 統一重評：上次跑決策 tick（directive_fresh 比對基準，截斷死循環）
var crisis_latched: bool = false         # Fix2 crisis edge-trigger：進 crisis fire 一次(latch)，持續期落 cadence，離開解 latch
var subteam_eval_next_tick: int = 0      # 下次子隊決策 tick（cadence，鏡射 threat_eval_next_tick，A2a）
var consolidate_target_cache: int = -1   # S-A：整併 target 快取（cadence 節流，防每 tick O(N) _find_absorber）
var absorb_target_cache: int = -1        # §HOW-7：吸納弱鄰 target 快取（同 cadence 節流）
var consolidate_eval_next_tick: int = 0  # S-A：下次整併 target 評估 tick（cadence，鏡射 subteam_eval_next_tick）
var residency_eval_next_tick: int = 0    # 下次 outpost 居民派駐評估 tick（cadence）
var invite_cooldown: Dictionary = {}     # { tid: tick_until } 邀請流亡安頓的冷卻
var diplomacy_reject_cooldown: Dictionary = {}   # { target_tid: tick_until } 被拒後同對象外交冷卻
# ② 絕境階梯失敗回饋（stall→硬排除換格）。committed=_trigger_survival 蓋章真 option 字串(分辨掠奪/佔村皆TASK_ATTACK)。
var survival_committed_option: String = ""   # 現承諾的 survival option 字串（"" = 未承諾/待重蓋）
var survival_committed_tick: int = 0         # 蓋章 tick（stall 計時 baseline）
var survival_committed_food: float = 0.0     # 蓋章時 food_days baseline（relief before/after 比基準）
var survival_stall_cooldown: Dictionary = {}  # { option字串: tick_until } stall 硬排除窗（reject_cooldown idiom）
# crisis-override（跨線危機安全網，泛化 ②）：committed 任何 task 深餓未緩 → force re-rank。
# baseline lazy 蓋（crisis_committed_tick != task_start_tick → 新 episode 重置）；auto-reset on task change。
var crisis_committed_food: float = 0.0   # 現 task 蓋章時 food_days baseline
var crisis_committed_tick: int = -1      # 蓋章對應的 task_start_tick（≠ 則新 task episode，重蓋）
# crisis release 後免疫窗：剛 released 的 task 短時間禁重委派（防同 cadence release-then-instant-recommit）
# → 迫 re-rank 選別的(survival)task 接住餓死隊。measurer 揭 team1/19 等待新領主/team13 FLEE 立刻打回原 task。
var crisis_released_task: String = ""    # 剛被 crisis-override release 的 task（""=無）
var crisis_released_until: int = 0        # 免疫窗到期 tick（try_set 內禁此 task 重委派至此）
# 信使外交提案（權威存發起隊，對齊 active_orders pattern）。空 {} = 無在途提案。
# {type:"alliance", target_id, target_pos, issued_tick, proposal_id, timeout, gift} — 信使帶 proposal_id ref。
# gift = 誘因 payload 通用 {res: amount}（發起時已扣，送達轉移目標；本 slice 僅 food，聯姻/財槽未來直插）。
var pending_proposal: Dictionary = {}
var task_reason: String = ""             # 最近一次 task 設定來源（TaskArbiter _source；遙測用）
var task_start_tick: int = 0             # 最近一次 task 設定 tick（逃跑/survival/貿易 timeout 用）
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

# 名聲磁鐵：對 protector_id 隊的「值不值託付/道德聲望」（★語意獨立 known_reputations 情報信任軸，別混）。
# key=protector team_id，default 0.5 中立，clamp 0~1。道德事件(護/恩→升、仇/殺→跌)喂。
var protector_rep: Dictionary = {}
func get_protector_rep(protector_id: int) -> float:
	return float(protector_rep.get(protector_id, 0.5))
# source = 更新來源（"direct"=道德事件親歷／未來 "gossip"=傳聞 decay）。單一可擴充入口，source-agnostic 內部只記/clamp。
func update_protector_rep(protector_id: int, delta: float, _source: String = "direct") -> void:
	protector_rep[protector_id] = clampf(float(protector_rep.get(protector_id, 0.5)) + delta, 0.0, 1.0)
