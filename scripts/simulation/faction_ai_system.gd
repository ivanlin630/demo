class_name FactionAISystem

const COLLECT_INTERVAL:        int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
const FACTION_UPDATE_INTERVAL: int = 20 * WorldState.TICKS_PER_HOUR  # 每 20 小時
const DECISION_CADENCE: int = TimeScale.TICK_PER_DAY * 1   # TEST VALUE — 非-unified 週期重評（解 IDLE-lock）
const DISPATCH_DIST_THRESHOLD: int   = 2
# ★糧流 Slice B1 糧橋（解 A1 子隊餓死）：出發配糧 need=burn×ETA_total×safe_margin；母隊 food 撥得起才派。
const FOOD_BRIDGE_SAFE_MARGIN: float = 1.5   # TEST VALUE — 需糧餘裕（緩衝途中 harvest 不足/繞路）
const FOOD_BRIDGE_MOVE_PER_DAY: float = 2.0  # TEST VALUE — 移速估（ETA_travel=dist/此，鏡射 goal_resolver）

static var _a2b_remote_tribute_payers: Dictionary = {}   # A2b 守衛 B：遠距徵收 dispatch 的 payer id（settle 對帳）
const FOOD_EMERGENCY: float          = 3.0
# 戰爭基金：野心/好戰高 leader material 低於此 → 非缺糧也觸發特別稅徵收。TEST VALUE
const WAR_CHEST_MIN: float           = 200.0
const ESTABLISH_COMMAND: float       = 0.4
const ESTABLISH_AMBITION: float      = 0.7
const ESTABLISH_READINESS: float     = 0.7
const DIPLOMACY_READINESS_MIN: float = 0.6
const DISCIPLINE_FAIL_BASE: float    = 0.15
const MANUFACTURE_MATERIAL_MIN: float = 30.0
const GOVERN_MATERIAL_TARGET: float = 75.0   # TEST VALUE — 公庫建材達標就放手擴張
const TRADE_MIN_COIN: float           = 5.0    # 買方最低 coin 門檻
const MERCHANT_TRADE_BONUS: float     = 0.5    # WS-2 TEST VALUE：商隊-tag solo trade 分數加成(勝 CAMP，但 FLEE 仍優先)
const HONOR_INTERVAL_MULT: float  = 0.5   # honor=1.0 → 徵收週期 ×1.5（義氣高 → 少收稅）
const HONOR_EMERGENCY_DISC: float = 0.3   # honor=1.0 → emergency 門檻 ×0.7（義氣高 → 緊急門檻降低）
const LOOT_SCORE_THRESHOLD: float = 0.35  # TEST VALUE — 掠奪 goal 分數門檻
const LOOT_READINESS_MIN: float   = 0.6   # TEST VALUE — 掠奪需要的最低 readiness
const SMALL_TEAM_RATIO: float     = 0.3   # TEST VALUE — pop < cap×0.3 視為小隊
const SMALL_VS_LARGE: float       = 0.33  # TEST VALUE — pop < absorber.pop×0.33 才觸發合併
const CONSOLIDATE_MAX_DIST: int   = 3     # TEST VALUE — 戰前集結距離上限（hex）
const ABSORBER_MIN_SURVIVE_DAYS: float = 7.0  # TEST VALUE — S-A 餵養 gate#1：併後合隊最低餘命（防搬餓）
const ATTACK_SCORE_THRESHOLD:  float = 0.25  # TEST VALUE — ②b 稍寬（0.30→0.25，餬口狼偶爾動手；archetype gate 仍擋知足者）
# ②b 飢餓下修搶糧 readiness（僅獨立 prosperity raid 路；faction campaign/can_expand/directives 不吃）。TEST VALUE。
const HUNGER_SLIDE_DAYS: float = 7.0   # food_days ≥ 此 → hunger_relief=1.0（正常門檻）；越餓越低
const RELIEF_FLOOR: float      = 0.4   # hunger_relief 下限（餓兵搶糧最多把門檻降到 0.4×）
# ②c prey 濾改分：同弱者（pop_est 近似）food_est 高者優先的 tie 帶寬。TEST VALUE。
const PREY_POP_TIE_EPS: float  = 0.5
const ATTACK_READINESS_MIN:    float = 0.75  # readiness required for attack goal
const ATTACK_STRENGTH_RATIO:   float = 0.8   # own_armed must be >= enemy_armed * this
const DIPLOMACY_AMBITION_DISC: float = 0.2   # how much ambition shifts diplomacy readiness req
# commander-v2 means-end：意圖承諾 hysteresis 加成（戰略別每 cadence 翻；情勢不變則黏住）。TEST VALUE
const COMMANDER_COMMITMENT_BONUS: float = 0.15
# ── 獨立戰略層（野心獨立隊建國 intent；mirror commander-v2 _select_intent，輕量）──
# 統一決策 arc 第三塊：野心是普世驅力，不被 faction-gate。獨立 ambitious leader 也秤戰略意圖。
# 建國 = means-end 秤的 option（driver=野心），非「夠 pop→自動 create_faction」fiat。複用既有 create_faction
# （結盟 interaction:333 / 吞併 npc_combat:524）。意圖集只 {建國,守成}（征服等成 faction 後 commander-v2 給）。
const INDEP_STRATEGY_CADENCE: int = TimeScale.TICK_PER_DAY * 3   # 3 天評估一次（沿用 prosperity cadence 量級）
const AMBITION_FOUND_MIN: float = 0.55          # TEST VALUE — 建國野心門檻（對齊 ambition_cap STATE 門檻 0.55）
const FOUND_COMMITMENT_BONUS: float = 0.15      # TEST VALUE — 建國意圖承諾 hysteresis（mirror commander）
const FOUND_FOOD_SURPLUS_DAYS: float = 7.0      # TEST VALUE — 累積夠 = 有 ≥7 天糧盈餘（已達 EXPAND）
# ── ②a 信使外交（envoy）+ founding timeout（保險網）──
# timeout=保險網非死常數：按距離/移速估往返時間（新 invariant「凡 in-flight latch 必有 timeout」）。
# 往返裕度係數：單程 ETA × 此。信使追「移動」target（非靜止）→ 步行信使僅 named>anon 微速差，
# 收斂需遠多於直線 ETA（量測：3.0/2天 floor → delivery=0；6.0/12天 floor → accept>0）。
# 有馬則 3× 速→秒到，此裕度變寬鬆 slack。TEST VALUE（平衡 pass 調；mount 經濟成熟後可縮）。
const FOUNDING_TIMEOUT_MULT: float = 6.0
const FOUNDING_TIMEOUT_FLOOR_DAYS: int = 12       # TEST VALUE — 步行信使追移動 target 的收斂下限
const ENVOY_POP: int = 1                          # TEST VALUE — 信使子隊人數（最小分隊）
const ENVOY_REDUNDANCY_FOUNDING: int = 2          # TEST VALUE — 建國提案冗餘騎數（亂世信使會死，多騎首達生效）
const GIFT_FRACTION_MIN: float = 0.10             # TEST VALUE — 掏禮佔糧盈餘下限（低野心=保守掏）
const GIFT_FRACTION_MAX: float = 0.30             # TEST VALUE — 上限（高野心=急迫掏多）
# 統一戰略意圖菜單（統一矩陣首燒 F-D1/D2）：任何有 leader 的隊（faction leader / 獨立 team）
# 對同一菜單 argmax。實體型只決定 gate/scale（建國僅 fid==-1；擴張 Task3 折入），非另起菜單。
const STRATEGIC_INTENTS: Array = ["致富", "擴張", "征服", "防衛", "守成", "建國"]
# 意圖 = 目標 predicate（小集；立國=既有分離 gate 不在此）
const INTENTS: Dictionary = {
	"征服": {"main_action": "攻擊", "needs_target": true},   # target 不再獨立
	"致富": {"main_action": "",   "needs_target": false},  # treasury 增（多行動服務，無單一 main）
	"防衛": {"main_action": "徵收", "needs_target": false}, # 領土不失（備戰籌資）
	"守成": {"main_action": "",   "needs_target": false},  # default 維持
}
# 行動 schema：前提(precond) + 真 affordance（只掛 sim 真產出，孤兒不掛）
# affordance: {goal:服務的子需求, mode:語義模式}
const ACTIONS: Dictionary = {
	"攻擊": {"preconds": ["force_ge_target", "can_reach"],
		"affordances": [{"goal": "削敵", "mode": "combat"}]},
	"徵收": {"preconds": ["has_richer_member"],
		"affordances": [{"goal": "致富", "mode": "levy"}, {"goal": "補力", "mode": "fund_war"}]},
	"外交": {"preconds": [],
		"affordances": [{"goal": "補力", "mode": "ally"}]},
}
const SURVIVAL_TASKS: Array = [TeamData.TASK_RETURN_HOME, TeamData.TASK_BEG, TeamData.TASK_JOIN, TeamData.TASK_FORAGE, TeamData.TASK_CAMP]
# crisis-override（跨線危機安全網，泛化 ②）：committed 任何 task 深餓未緩 → force re-rank。
const CRISIS_FLOOR: float = 1.5   # TEST VALUE — 深餓門檻（★decouple SURVIVAL_BOOST_FLOOR 2.0，略深；避 boost tuning 誤動 crisis）
const CRISIS_DAYS: float = 6.0    # TEST VALUE — committed 未緩 N 天才 crisis（給 task 工作時間，非急打斷）
const CRISIS_IMMUNITY: int = WorldState.TICKS_PER_DAY * 2   # TEST VALUE — release 後禁重委派同 task 窗（橋接到 survival @80 commit，防 instant-recommit）
const FORAGE_VIABLE_POP: int = 15   # TEST VALUE — pop ≤ 此值覓食划算（income/burn 比的粗略 proxy，待量測 tune）
# P2b-1：LOOT_GATE/JOIN_GATE/CAMP_GATE + _loot_pref/_join_pref/_camp_pref 已刪
# （survival 選擇統一委派 DecisionEngine.rank_survival → DecisionTerms weight，消雙 owner）
const SOLO_COMMITMENT_BONUS: float = 0.15   # TEST VALUE — SoloAI 慣性加成（止 flip-flop，非鎖死）
const CRUDE_CAMP_FOOD_SEED: float = 40.0   # TEST VALUE — 紮營種子糧（+同抬 cap）
# stuck: task 仍是進攻型但 move_target 已被 movement 清掉（off-map / 無路徑）→ 視為 idle 允許重評
const STUCK_TASKS: Array = [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]

static func _is_stuck(team: TeamData) -> bool:
	return team.current_task in STUCK_TASKS and team.move_target == Vector2i(-1, -1)
const CONTACT_TIMEOUT_DAYS: int = 30
const OWNER_CHANGE_BUFFER_DAYS: int = 7
const URGENCY_DAYS: float = 1.0
const WARNING_DAYS: float = 3.0
const SURVIVAL_RECOVER_DAYS: float = 7.0   # 糧恢復到此 → 脫離 survival（hysteresis 防抖）
const GRADUAL_DECLINE_FLOW: float = -0.5   # Fix2-v2 TEST VALUE — 慢性糧滑坡 crisis 門檻（DEEP -2.0 與 0 間，漸進安全網）
const FLEE_TIMEOUT: int = TimeScale.TICK_PER_DAY * 5   # 逃跑逾時 5 天（修硬編 240，跟根）→ 釋放重評，小地圖防永逃

# ── Prosperity attack（野心驅動主動征服）──
const PROSPERITY_CADENCE: int = TimeScale.TICK_PER_DAY * 3            # 3 天 評估一次
const PROSPERITY_CADENCE_MILITARY: int = TimeScale.TICK_PER_DAY * 36 / 24  # 軍隊 tag 1.5 天 = 36h
const ANON_TREASURY_BONUS_THRESHOLD: float = 200.0  # 公庫滿 → attack_score +0.1

# ── Threat response（被動威脅反應）──
const THREAT_CADENCE: int = TimeScale.TICK_PER_DAY * 1   # 1 日 評估一次威脅
# A2b intent 重選 cadence（藍圖 #3：戰略每 tick 重秤=雜訊；1 日重評，cadence 內沿用 f.intent）。TEST VALUE。
const INTENT_CADENCE: int = TimeScale.TICK_PER_DAY * 1   # 1 日
# A2a 子隊決策 cadence（效能：全框架 gather+rank 非逐 tick，攤平 O(N²) LOD 成本，鏡射 THREAT_CADENCE）。
const SUBTEAM_CADENCE: int = TimeScale.TICK_PER_DAY * 1   # 1 日 子隊決策一次（TEST VALUE，平衡 pass 調）
const CONSOLIDATE_CADENCE: int = TimeScale.TICK_PER_DAY * 1   # S-A：整併 target 評估 cadence（鏡射 SUBTEAM_CADENCE，掐 churn）
# preempt：忙碌隊只有「壓境能傷你」威脅才打斷進行中 task（門檻 = threat_threshold + 此加成）。
# TEST VALUE=2.0（measured：逼近但弱敵 react≈1.5 須守住、壓境碾壓敵 react≈5.5 須觸發 → margin∈(1.1,5.2)，取 2.0 雙側留餘裕）。
# 天然實現「能傷你」語意：power_ratio 貢獻 (ratio-1)·0.5，須 ratio≳5 才把 react 推過此門檻（見 threat_assessment.gd:19）。
const PREEMPT_MARGIN: float = 2.0
const PREEMPTIBLE_TASKS: Array = [
	TeamData.TASK_PRODUCE, TeamData.TASK_MANUFACTURE, TeamData.TASK_BUILD, TeamData.TASK_TRADE,
	TeamData.TASK_GOVERN, TeamData.TASK_TRAIN, TeamData.TASK_FORAGE,
	TeamData.TASK_CAMP,
]   # 不含：ATTACK/LOOT(戰鬥)、FLEE/DEFEND/PREPARE/HOLD(已 threat)、REVOLT、JOIN/BEG(social)、survival。
    # TASK_PRODUCE：定居 resident 生產隊常態 task（interaction:1065 transition 進），非緊急可打斷（見
    # interruptible fai:2398）→ 藍圖「犁田遇劫匪放犁」核心 case 靠它接。
    # 註：無 TASK_MOVE 常數（移動走各 task 內 move_target）→ 不列（spec 誤列，實碼無此 task）。
const TRADE_TIMEOUT: int = TimeScale.TICK_PER_DAY * 6   # 貿易 task base timeout 6 日（防 zombie）
# timeout 按距離估（invariants：timeout 別死常數——按距離/移速估合理往返時間）：
# base + 殘距×per_hex。慢地形(forest 0.7×/mountain 0.4×)下 1 hex 最壞 ~0.7 日 → 0.5 日/hex 餘裕。TEST VALUE。
const TRADE_TIMEOUT_PER_HEX: int = TimeScale.TICK_PER_DAY * 12 / 24  # 12h/hex
# A1a 拆閥（spec 2026-07-07-A1a-arbiter-valve）：四 no-release 駐地 task timeout release——
# 原永不 release=永久 latch（bed no_release_latch 桶）。駐地原地 task 無距離項 → 純 base 額度；
# 到點 release 回 idle，下 cadence 重新競爭（腦仍最想做→重派同 task；不是→rank[0] 換手=閉迴路）。
# TEST VALUE（照妖鏡債，A1 spec 裁5：合理 test-value + measure 調）。
const STATION_TASKS: Array = [
	TeamData.TASK_TRAIN, TeamData.TASK_MANUFACTURE, TeamData.TASK_GOVERN, TeamData.TASK_PRODUCE,
]
const STATION_TIMEOUT: int = TimeScale.TICK_PER_DAY * 4

# ── Outpost 居民派駐 AI ──
const RESIDENCY_CADENCE: int = TimeScale.TICK_PER_DAY * 3    # 3 天 評估一次 outpost 居民派駐
const RESIDENCY_COOLDOWN: int = TimeScale.TICK_PER_DAY * 7   # 7 天 邀請被拒後冷卻
const MIN_PARENT_POP_AFTER_DISPATCH: int = 10
# 佔村 target 濾（打得到+守得住，防自殺圍城）
const OCCUPY_ETA_MAX: int = TimeScale.TICK_PER_DAY * 3   # TEST VALUE — 佔村目標最遠 eta（≈3 日；遠村久圍乾耗餓死→不選）
const OCCUPY_POP_RATIO: float = 0.6  # TEST VALUE — 目標 believed pop 須 < 我方 ×此（明顯小才圍，防小狼打大村）
const OCCUPY_WIN_MARGIN: float = 1.3        # TEST VALUE — 佔村勝算 margin：己方真 armed 須 ≥ 估村防下限 ×此
const OCCUPY_DEF_ARMED_FLOOR: float = 0.1   # TEST VALUE — 估村防武裝下限比（村全員守，mirror combat ARMED_RATIO_FLOOR）

const TRADEABLE_RES: Array = [
	"food", "material", "goods", "gem",
	"ore_gold", "ore_silver", "ore_iron", "ore_steel",
	"weapon_melee_low", "weapon_melee_high",
	"weapon_ranged_low", "weapon_ranged_high",
]

const OUTPOST_POP_CAP: Dictionary = {
	"civilian": [20, 50, 100],   # L1, L2, L3
	"military": [15, 35, 70],
}

# ── Prosperity helpers（static，純函數，可單測）──

# R1b logistics 因子常數（全 TEST VALUE）——連續因子乘進 score，非 filter/classifier
const TRIP_FOOD_FLOOR: float = 0.2      # TEST VALUE — ②路程糧下限：糧緊只壓權重，絕不歸零
const OWN_UNKNOWN_FACTION: float = 0.5  # TEST VALUE — ③歸屬欄缺席=未知→保守（盲 raid 壓、誘因 scout，Phase E 慣例）
const WAR_COST_BASE: float = 0.15       # TEST VALUE — ③believed 屬 faction 基準罰（獨立餬口隊幾乎不中選）
static func calc_readiness_threshold(team: TeamData, leader: PersonData) -> float:
	var ferocity: float = maxf(
		float(leader.values.get("殘忍", 0.5)),
		float(leader.values.get("好戰", 0.5))
	)
	var caution: float = float(leader.values.get("慎重", 0.5))
	var threshold: float = 0.55 - ferocity * 0.15 + caution * 0.15
	if "軍隊" in team.tags:
		threshold -= 0.1
	return clampf(threshold, 0.3, 0.85)

static func calc_readiness(state: WorldState, team: TeamData) -> float:
	var pop_factor: float = clampf(float(team.population) / 10.0, 0.0, 1.0)
	var skill: float = team.anon_combat_skill
	# WS-2c：有效糧(私產+自家糧倉)，否則定居隊 food 在糧倉→food_factor=0→誤判戰備不足。
	var food_days: float = ResourceSystem.effective_food(state, team) \
		/ maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	var food_factor: float = clampf(food_days / 14.0, 0.0, 1.0)
	var weapon: float = float(team.resources.get("weapon_melee_low", 0))
	var weapon_factor: float = clampf(weapon / maxf(float(team.population), 1.0), 0.0, 1.0)
	return (pop_factor + skill + food_factor + weapon_factor) / 4.0

# de-patch 閘7：calc_attack_score 刪除——production/征服 arc 零 caller 孤兒（攻擊決策已溶進引擎
# intent_fit/attack_drive，見 terms/ctx）。孤兒 score 公式退役。

static func find_prosperity_prey(state: WorldState, team: TeamData, leader: PersonData) -> int:
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var cruelty: float = float(leader.values.get("殘忍", 0.5))
	var ambition: float = float(leader.values.get("野心", 0.5))
	var best_id: int = -1
	var best_score: float = 0.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var prey: TeamData = state.teams.get(tid)
		if prey == null: continue
		if prey.faction_id != -1 and prey.faction_id == team.faction_id: continue
		# G3-targeting：無情報 → 不評估（禁 god-view；不知道的打不了）
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, team, tid, true)
		if not catch_result.reachable: continue
		# 價值/弱點從 belief 估（偽裝低報 armed → 看似弱 → 誘殺載體）
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		var pop_est: float = float(bel.get("population_est", 0.0))
		# 無 armed_est belief → 人格化迷霧 fallback（讀 leader 人格，非埋死「陌生=滿武裝」）
		var armed_est: float = BeliefSystem.estimate_armed(bel, pop_est, leader.values)
		var richness: float = _belief_richness(bel)
		# capability grounding（裁2）：弱點比 self ARMED 非 self POP → 無牙商隊 self_armed≈0 →
		# 任何有武裝 prey 皆非「相對弱」→ weakness→0（不再被誘攻；鎖來自戰力非 tag-label）。
		var self_armed_f: float = float(NpcCombatSystem.new().calc_armed(state, team))
		var weakness: float = clampf(
			1.0 - armed_est / maxf(self_armed_f, 1.0),
			0.0, 1.0)
		var border: float = 1.0 if _is_border_adjacent(team, prey) else 0.3
		var eta_days: float = maxf(float(catch_result.eta) / float(WorldState.TICKS_PER_DAY), 1.0)
		# R1b means-end logistics（②路程糧 × ③目標歸屬，單一連續因子乘進 score）
		# ②路程糧：單程到 prey 的糧需 vs 有效糧；夠→1.0，緊→往下滑但絕不歸零（既有信號讀取）
		var trip_need: float = eta_days * float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
		var trip: float = clampf(
			ResourceSystem.effective_food(state, team) / maxf(trip_need, 0.001),
			TRIP_FOOD_FLOOR, 1.0)
		# ③歸屬（belief claim 語意，可傳/可過時/可騙）：禁讀 prey.faction_id 真值——
		# belief 錯 → 照打（捅馬蜂窩）/被嚇阻 = G3 戲劇，不防呆。
		var own: float
		if not bel.has("faction_id"):
			own = OWN_UNKNOWN_FACTION   # 欄位缺席（tier0/1 無此欄）= 未知 → 保守
		elif int(bel.get("faction_id", -1)) == -1:
			own = 1.0                   # believed 獨立：一次 raid，可打
		else:
			# believed 屬 faction：基準罰 + 戰爭能力減免。
			# ★統領令語意（斷①B，非身分切路徑）：war_capability 減免只給「扛得起 faction 級戰爭後果的人」——
			# faction leader（統領本人，令即他出）或獨立隊（自家 stakes 自家扛）。非 leader 成員 day-op 對
			# believed-owned 恆 WAR_COST_BASE（幾乎不中選）＝打別家屬村＝拖全派系下水，須走統領令
			# （faction directive 指定 target，不經 find_prosperity_prey）。誰扛得起後果誰才減免＝
			# 連續 means-end 權重，非按身分切決策路徑。
			var can_bear_war: bool = team.faction_id == -1 \
				or (state.factions.has(team.faction_id) \
					and state.factions[team.faction_id].leader_team_id == team.team_id)
			if can_bear_war:
				var att_established: bool = team.faction_id != -1 \
					and state.factions.has(team.faction_id) \
					and state.factions[team.faction_id].is_established
				var war_capability: float = (0.3 if att_established else 0.0) \
					+ float(team.ambition_rung) / float(AmbitionLadder.RUNG_HEGEMON) * 0.3
				own = minf(WAR_COST_BASE + war_capability, 1.0)
			else:
				own = WAR_COST_BASE   # 非 leader 成員：無戰爭能力減免（day-op 幾乎不打屬村）
		var logistics: float = trip * own
		var score: float = (richness * greed + weakness * cruelty + border * ambition) \
			/ eta_days * logistics
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

# belief 財富估：tier2 有資源估 → sum/100；tier0/1 只有 resource_scale(0-3) → 粗估；皆無 → 0。TEST VALUE。
static func _belief_richness(bel: Dictionary) -> float:
	if bel.has("coin_est") or bel.has("food_est") or bel.has("material_est"):
		return (float(bel.get("coin_est", 0.0)) + float(bel.get("food_est", 0.0)) + float(bel.get("material_est", 0.0))) / 100.0
	if bel.has("resource_scale"):
		return float(bel.get("resource_scale", 0))
	return 0.0

static func _is_border_adjacent(attacker: TeamData, prey: TeamData) -> bool:
	var dx: int = prey.tile_pos.x - attacker.tile_pos.x
	var dy: int = prey.tile_pos.y - attacker.tile_pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= 2

# 追擊：攻擊/掠奪 中每 tick 依 intel 最後已知位置刷新 move_target（移動目標會跑）
# 與 strategic_ai 的 team_intel 追蹤同模式（strategic_ai_system.gd:107）
func _refresh_attack_pursuit(state: WorldState, team: TeamData) -> void:
	if team.combat_target != -1: return
	if team.current_task != TeamData.TASK_ATTACK and team.current_task != TeamData.TASK_LOOT:
		team.prosperity_target_id = -1
		return
	if team.prosperity_target_id == -1: return
	var prey: TeamData = state.teams.get(team.prosperity_target_id)
	if prey == null:   # 目標已滅 → 收手
		team.prosperity_target_id = -1
		TaskArbiter.release(team)
		return
	# Fix F 追擊 vision-gate（god-view 位置根治）：三態——①本 tick 可見 live 攔截 / ②斷視線去 belief
	# last-seen(prey 已移=撲空) / ③belief 過期或無位→放棄追擊 re-eval。★不退 prey 活值/自身。
	var snap: Dictionary = BeliefSystem.best_estimate(state, team.team_id, team.prosperity_target_id)
	var last_tick: int = int(snap.get("last_tick", -1))
	if last_tick == state.world.current_tick:
		# ①本 tick 可見 → live 攔截合法（在視線內；predict_intercept→observe_velocity randf 時機同 Fix C）
		team.move_target = PathSystem.predict_intercept(state, team, prey)
		return
	# 斷視線 → belief last-seen 搜（prey 已移=撲空）；belief 過期/無位 → 放棄追擊
	var stale: bool = last_tick < 0 or (state.world.current_tick - last_tick) > BeliefSystem.BELIEF_STALE_TICKS
	if stale or not snap.has("tile_pos"):
		team.prosperity_target_id = -1
		TaskArbiter.release(team)
		return
	team.move_target = snap["tile_pos"]   # ②last-seen 搜（撲空機制，非 prey 活值現址）

# ──────── 征服攻擊 dispatch-time scout-verify scaffolding（序5 溶入）────────
# cascade 決策已溶進引擎 攻擊 option（intent_fit 征服 × readiness/富 prey，見 terms/ctx）；
# 此 helper = 保留的 means-end 機制（世界規則非判斷器，合憲法「高風險行動前降不確定」如 threat trigger）。
# engine rank 出 攻擊(征服) → dispatch 前經此：對 prey 情報不確定且 leader 慎重 → 派斥候查證（延後攻擊，
# 純觀察不設 combat_target）；莽者(慎重低)→confident_enough 恆真→照衝→假情報誘殺(S4)保。confident → TASK_ATTACK。
# 回 true=已 dispatch（scout 或 attack），false=prey 無效/leader 缺/未派（呼叫端試次佳）。
func _commit_conquest_attack(state: WorldState, team: TeamData, prey_id: int) -> bool:
	if prey_id == -1 or not state.teams.has(prey_id): return false
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return false
	var _caution: float = float(leader.values.get("慎重", 0.5))
	# G3d-1/2 風險 gate：不確定 + 慎重 → 派斥候移向 prey best_estimate 位 → 親見壓謊 → 下次收斂。
	if not BeliefSystem.confident_enough(state, team.team_id, prey_id, _caution):
		var prey_t: TeamData = state.teams.get(prey_id)
		# F1 感知鐵律：缺 belief tile_pos → sentinel (-1,-1)（禁默認 live 真位=god-view 回潮）。
		var scout_pos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, prey_id).get("tile_pos", Vector2i(-1, -1)) if prey_t else Vector2i(-1, -1)
		if scout_pos == Vector2i(-1, -1):
			return false   # 無 belief 位 → 不 scout（不瞎追 live）
		if team.current_task == TeamData.TASK_SCOUT and team.prosperity_target_id == prey_id:
			team.move_target = scout_pos   # 追蹤刷新：prey 移動 → 朝最新 best_estimate（不重派/不 spam log）
			return true
		if TaskArbiter.try_set(state, team, TeamData.TASK_SCOUT, scout_pos, TaskArbiter.PRIO_DISPATCH, "scout"):
			team.prosperity_target_id = prey_id   # try_set 已設 move_target=scout_pos
			print("[Scout] team=%d → verify prey=%d" % [team.team_id, prey_id])
			Probe.bump("g3.scout_dispatch")
			return true
		return false
	# confident → 攻擊。若仍掛 scout（同 PRIO_DISPATCH 擋不住自身）→ 先 release 換手。
	# combat_target 不預設：移動凍結 + interaction 早退會擋交戰；由 interaction_system 到達 start_combat 設。
	var _was_scout: bool = (team.current_task == TeamData.TASK_SCOUT and team.task_reason == "scout")
	if _is_stuck(team) or _was_scout:
		TaskArbiter.release(team)
	# E1 感知鐵律：攻擊移動目標讀 belief last-seen（非 live god-view；prey 脫視野→照最後見位追=伏擊/佯動 intended）。
	var atk_pos_e1: Vector2i = BeliefSystem.belief_pos(state, team.team_id, prey_id)
	if atk_pos_e1 == Vector2i(-1, -1):
		return false   # 無 belief 位 → 不 dispatch（禁 fallback live）
	if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
			atk_pos_e1, TaskArbiter.PRIO_DISPATCH, "prosperity"):
		team.prosperity_target_id = prey_id
		if _was_scout: Probe.bump("g3.scout_converge")
		Probe.bump("conq.prosperity_reached")   # 征服鏈起點（prosperity-attack→失能-capture→吸收）走到
		if Probe.enabled:
			var _bel_own: Dictionary = BeliefSystem.best_estimate(state, team.team_id, prey_id)
			if _bel_own.has("faction_id") and int(_bel_own.get("faction_id", -1)) != -1:
				Probe.bump("conq.indep_atk_believed_owned" if team.faction_id == -1 \
					else "conq.member_atk_believed_owned")
		print("[ProsperityAttack] attacker=Team%d prey=Team%d" % [team.team_id, prey_id])
		return true
	return false

# 征服 scout 生命週期（序5：cascade 溶解後保留的 scout scaffolding tick，鏡射舊 cascade 的 scout timeout/
# 自家 scout 重評段）。只對「查證中」隊動作：prey 消失/逾時 → 釋放；否則重評（親見壓 uncertainty → 收斂轉攻，
# 或刷新 scout 位）。latch-timeout 不變量：scout 有 SCOUT_TIMEOUT release（防永 scout 卡死）。
func _tick_conquest_scout(state: WorldState, team: TeamData) -> void:
	if team.current_task != TeamData.TASK_SCOUT or team.task_reason != "scout": return
	if team.combat_target != -1: return
	var prey_id: int = team.prosperity_target_id
	if prey_id == -1 or not state.teams.has(prey_id):
		TaskArbiter.release(team)   # prey 已滅 → 收手回常規
		team.prosperity_target_id = -1
		return
	if state.world.current_tick - team.task_start_tick > BeliefSystem.SCOUT_TIMEOUT:
		TaskArbiter.release(team)   # 逾時未收斂 → 釋放（防永 scout 卡死）
		Probe.bump("g3.scout_timeout")
		return
	# 重評：confident（親見壓低 uncertainty）→ release+轉攻；仍不確定 → 刷新 scout 位追 prey。
	_commit_conquest_attack(state, team, prey_id)

# ──────── D: 被動威脅反應 ────────

# 威脅評估（cadence）：找視野內最高 threat，超門檻 → dispatch 反應。
# 已在反應 task 中則重評威脅是否仍在，無則回 idle。
func _evaluate_threat(state: WorldState, team: TeamData) -> void:
	if state.world.current_tick < team.threat_eval_next_tick: return
	team.threat_eval_next_tick = state.world.current_tick + THREAT_CADENCE
	if team.combat_target != -1: return
	if team.current_task == TeamData.TASK_REVOLT:
		# 起義（流亡路徑）是瞬時事件，結算已完成 → 釋放回常規 AI
		#（若有追兵，下次 cadence threat 評估會派逃跑）
		TaskArbiter.release(team)
		return
	# ★crisis-override（OUTCOME-based 安全網，泛化 ②）：committed 任何 task 深餓未緩 → release → 下 cadence
	#   re-rank → survival @80 preempt 卡住 task。放 FLEE/preempt gate 前=涵蓋 5 種 stuck-task（FLEE/建設/外交/
	#   等待新領主/併入-pending）。不特判 flee（survival 主宰 by engine THREAT<SURVIVAL 不變量；valid-flee 罕見角 deferred Arc5）。
	if _famine_crisis(state, team):
		team.crisis_released_task = team.current_task   # 免疫此 task（防同 cadence 立刻打回）→ 迫 re-rank 選別的 survival task
		team.crisis_released_until = state.world.current_tick + CRISIS_IMMUNITY
		TaskArbiter.release(team)
		team.previous_task = ""
		if Probe.enabled: Probe.bump("crisis.override_release")
		return
	if team.current_task in [TeamData.TASK_DEFEND, TeamData.TASK_PREPARE, TeamData.TASK_FLEE, TeamData.TASK_HOLD]:
		# 威脅消失 → 釋放；或逃跑逾時（小地圖逃不到 5 格脫離 → 靠 timeout 重評，否則永逃）
		var fled_too_long: bool = team.current_task == TeamData.TASK_FLEE \
			and state.world.current_tick - team.task_start_tick > FLEE_TIMEOUT
		if not _has_active_threat(state, team) or fled_too_long:
			TaskArbiter.release(team)
		return
	# 忙碌 gate（序3.5 preempt）：idle → 原路；busy-preemptible + 壓境威脅 → 打斷 task 反應；
	# busy-urgent（戰鬥/social/緊急）→ 不評（原行為）。
	var _busy_preemptible: bool = team.current_task in PREEMPTIBLE_TASKS
	if team.current_task != TeamData.TASK_IDLE and not _busy_preemptible:
		return   # 忙且不可 preempt → 原行為
	# 手算 argmax 撕除 → 引擎 rank_threat 秤（融合非刪）。threat_react/threshold 由 ctx 鏡射舊掃描。
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	if team.current_task == TeamData.TASK_IDLE:
		# unified 隊（商隊/生產）idle threat 反應由 _decide_unified 主 rank 處理（鏡射 survival unified 排除，
		# 見 _evaluate_survival:3023）→ 不雙觸發。release 檢查（上方 DEFEND/PREPARE/FLEE）仍對其成立。
		if uses_unified(team): return
		if ctx.threat_react < ctx.threat_threshold: return   # 一般門檻
	else:
		# busy-preemptible：高門檻，只壓境「能傷你」威脅才打斷工作（unified 忙碌隊亦走此——
		# _decide_unified 忙碌時不重跑 rank，preempt 是唯一即時感知路）。
		if ctx.threat_react < ctx.threat_threshold + PREEMPT_MARGIN: return
	# ★threat-oracle S3 收斂（真統一 finale）：撕除 rank_threat 手派 argmax → threat 決策走 _decide_unified
	# 全 pool rank_scored（severity-scaled threat option 全 pool 競秤=北極星「一 encounter eval」）。
	# preempt 語意保（上方 busy gate + 門檻=trigger）；決策 route unified（非 rank_threat）。
	# force reeval：threat 觸發即反應（繞 _decide_unified cadence 節流——threat 非 _should_reeval 內建 trigger）。
	# side-effect（_wire_threat_task/flee_from_pos/threat.dispatch tap/specimen）由 _decide_unified commit loop 承（DRY）。
	team.decision_eval_next_tick = state.world.current_tick
	_decide_unified(state, team)

# 融合 threat：threat option 的 aux target 接線（DEFEND=prosperity_target / 求和=order_target+order_task）。
# _evaluate_threat（non-unified）與 _decide_unified（unified）共用 → 兩路 threat 反應接線一致（DRY）。
func _wire_threat_task(team: TeamData, td: Dictionary) -> void:
	if td.has("prosperity_target"): team.prosperity_target_id = int(td["prosperity_target"])
	if td.has("order_target"): team.order_target_id = int(td["order_target"])
	if td.has("order_task"): team.order_task = td["order_task"]

# flee 位移根治：FLEE 威脅來源 belief 位（★感知鐵律：belief 非活值；斷視線朝最後已知威脅位反向逃）。
# 掃 discovered 取最大 ThreatAssessment.score → belief_pos。3 FLEE 派發站派 FLEE 後呼，設 team.flee_from_pos。
# 無威脅/belief 過期 → (-1,-1)（mover 不設 target，靠 release 收）。純讀零 randf。
func _flee_threat_pos(state: WorldState, team: TeamData) -> Vector2i:
	var best_id: int = -1
	var best_t: float = 0.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > best_t:
			best_t = t; best_id = tid
	if best_id == -1: return Vector2i(-1, -1)
	return BeliefSystem.belief_pos(state, team.team_id, best_id)

# 序4 vendetta 溶入：引擎純血仇攻擊 dispatch → bump g2.vendetta_trigger（framework S2b 驗魂 + 融合驗率表）。
# 純血仇 = feud 過門檻 且 非 faction directive 攻擊 且 非征服 intent（後二者有各自 driver，非私仇脫軌）。
# 於 _evaluate_solo/_decide_unified 派「攻擊」成功後呼。
func _probe_vendetta_dispatch(state: WorldState, team: TeamData) -> void:
	var ldr: PersonData = state.persons.get(team.leader_id)
	if ldr == null: return
	var fe: Dictionary = RelationGraph.strongest(ldr.relation_edges, "feud")
	var feud: float = float(fe.get("intensity", 0.0)) if not fe.is_empty() else 0.0
	if feud < DecisionOptions.FEUD_ATTACK_MIN: return
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null and "攻擊" in f.goals: return   # faction directive 驅（非私仇）
	if _solo_type(team) == "征服": return              # 征服 intent 驅（非私仇）
	Probe.bump("g2.vendetta_trigger")

func _has_active_threat(state: WorldState, team: TeamData) -> bool:
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > ThreatAssessment.THREAT_BASE_THRESHOLD:
			return true
	return false

# _dispatch_threat_response / _flee_target 已溶入引擎（序1）：
#   4 反應（逃跑/備戰/迎戰/求和）→ REGISTRY option（survival/備戰/迎戰/求和），DecisionEngine.rank_threat 秤。
#   FLEE target 由 mover 算：3 派發站設 team.flee_from_pos=威脅 belief 位 → movement_system._flee_away_tile
#   朝遠離該位算 away-tile（flee 位移根治 2026-07-15，恢復序1 遺留的 dead flee-movement）。

func _is_prosperity_candidate(_state: WorldState, team: TeamData) -> bool:
	# 打草穀（斷①A）：faction 成員也過候選（部將個體 raid=五代常態）。子隊(parent≠-1)仍擋——
	# 子隊非自主 leader。領導/成員之別不切候選路徑；stakes 歸屬語意在 find_prosperity_prey 的 ③own 權重管
	# （非 leader 成員 day-op 對 believed-owned 恆 WAR_COST_BASE=幾乎不中選，打屬村須走統領令 directive）。
	return team.parent_team_id == -1

# 事件觸發立即重評（新發現 / pop 暴跌 / 性格改變）
static func mark_prosperity_recheck(state: WorldState, observer_team_id: int) -> void:
	var t: TeamData = state.teams.get(observer_team_id)
	if t != null:
		t.prosperity_eval_next_tick = state.world.current_tick

func _outpost_pop_cap(state: WorldState, pos: Vector2i) -> int:
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0: return 0
	var arr: Array = OUTPOST_POP_CAP.get(tile.outpost_type, [10, 20, 40])
	return int(arr[clampi(tile.outpost_level - 1, 0, 2)])

func _is_resident_team(state: WorldState, team: TeamData) -> bool:
	return FactionAISystem.is_resident_static(state, team)

# static 版供 DecisionContext.gather 呼叫（避免 ctx 依賴 FactionAISystem 實例）。
# 本體 = 舊 _is_resident_team（居民 = 生產隊 + 站自家/同 faction outpost）。
static func is_resident_static(state: WorldState, team: TeamData) -> bool:
	if not team.tags.has(TeamData.TAG_PRODUCE):
		return false
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		return false
	var owner_id: int = tile.outpost_owner
	if owner_id == team.team_id:
		return true
	if owner_id == -1:
		return false
	var owner: TeamData = state.teams.get(owner_id)
	if owner == null:
		return false
	return owner.faction_id == team.faction_id and team.faction_id != -1

# ──────── Outpost 居民派駐 AI ────────

# tile 上是否已有 PRODUCE（居民）team（任一 faction）
func _has_resident_team_on_tile(state: WorldState, tile: HexTileData) -> bool:
	# 空間索引：同格查取代全掃。live 復驗 has + tile_pos 保零行為變。
	for tid in state.teams_on_tile(tile.tile_pos):
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		if t.tile_pos != tile.tile_pos: continue
		if "生產" in t.tags: return true
	return false

# 是否已有 in-flight 子隊朝該 outpost 安頓中（避免重派 spam）
func _has_inflight_settler(state: WorldState, owner: TeamData, tile: HexTileData) -> bool:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.team_id == owner.team_id: continue
		if t.faction_id != owner.faction_id: continue
		if not (TeamData.TAG_SUBTEAM in t.tags): continue
		if t.current_task != TeamData.TASK_SETTLE: continue
		if t.move_target != tile.tile_pos: continue
		return true
	return false

# cadence 評估：掃自家無居民 outpost，依個性派子隊或邀流亡
func _evaluate_outpost_residency(state: WorldState, team: TeamData) -> void:
	if state.world.current_tick < team.residency_eval_next_tick: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	team.residency_eval_next_tick = state.world.current_tick + RESIDENCY_CADENCE
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != team.team_id: continue
		if _has_resident_team_on_tile(state, tile): continue
		if _has_inflight_settler(state, team, tile): continue   # 新增
		_try_dispatch_or_invite(state, team, tile, leader)

# 個性決定管道：野心/好戰 → 派子隊；商業/慎重 → 邀流亡
func _try_dispatch_or_invite(state: WorldState, team: TeamData,
		tile: HexTileData, leader: PersonData) -> void:
	var ambition: float = float(leader.values.get("野心", 0.5))
	var military: float = float(leader.values.get("好戰", 0.5))
	var commerce: float = float(leader.skills.get("商業", 0.0))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var dispatch_score: float = ambition * 0.5 + military * 0.3
	var invite_score: float = commerce * 0.4 + caution * 0.3
	if tile.outpost_type == "military":
		# 軍屯：只信任自己人（軍火庫不交給流民），無 invite fallback
		if dispatch_score > invite_score and team.population >= 8:
			_dispatch_subteam_settle(state, team, tile)
		return
	if dispatch_score > invite_score and team.population >= 8:
		_dispatch_subteam_settle(state, team, tile)
	else:
		_try_invite_nearby_exile(state, team, tile)

# 派子隊安頓：抵達 outpost → interaction "安頓" handler → _convert_to_resident
func _dispatch_subteam_settle(state: WorldState, owner: TeamData, tile: HexTileData) -> void:
	var settler_count: int = clampi(owner.population / 4, 2, 5)
	if owner.population - settler_count < MIN_PARENT_POP_AFTER_DISPATCH: return
	var sub_leader_id: int = -1
	if owner.named_members.size() > 2:
		sub_leader_id = int(owner.named_members[0])
	else:
		# 無多餘 named → 升一名 anon 為 sub leader（dispatch 要求 leader ∈ named_members）
		var new_leader: PersonData = PersonGenerator.generate_for_team(
			state, owner, "member")
		if new_leader != null:
			state.add_member(owner, new_leader.id)   # 拔擢 anon→named
			sub_leader_id = new_leader.id
	if sub_leader_id == -1: return
	var subteam_id: int = SubteamSystem.new().dispatch(
		state, owner.team_id, sub_leader_id, settler_count, TeamData.TASK_SETTLE, tile.tile_pos)
	if subteam_id == -1: return
	print("[Residency] Team%d 派子隊 Team%d 安頓 outpost (%d,%d) pop=%d" % [
		owner.team_id, subteam_id, tile.tile_pos.x, tile.tile_pos.y, settler_count])

# 邀視野內流亡團安頓；個性接受 → task=安頓 + 長 cooldown，拒絕 → 7 天 cooldown
const INVITE_RANGE: int = 8   # TEST VALUE — 邀請近距門檻（≥ max vision range=VISION_RADIUS 3+scout+terrain，涵蓋 in-vision 流亡；擋 cross-map；measurer 校 seed1337 team19）
func _try_invite_nearby_exile(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	for tid in state.team_discovered.get(team.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not ("流亡" in t.tags): continue
		if t.current_task == TeamData.TASK_SETTLE: continue   # 已在路上，不重邀
		if state.world.current_tick < int(team.invite_cooldown.get(tid, 0)): continue
		# A3 感知鐵律：邀請距離 gate 用 belief last-seen 非 live（跨圖不邀；無 belief/過期→belief_pos(-1,-1)→擋）。
		# 禁 live t.tile_pos（用 live=修 god-view 卻讀 god-view=cosmetic，belief 該拒卻照發跨圖 settle）。
		var _bp: Vector2i = BeliefSystem.belief_pos(state, team.team_id, tid)
		if _bp == Vector2i(-1, -1) or _hex_dist(team.tile_pos, _bp) > INVITE_RANGE: continue
		var dipl := DiplomaticAiSystem.new()
		var resp: String = dipl.handle_diplomacy_message(
			state, t, team, "invite_settle")
		if resp == "accept" and TaskArbiter.try_set(state, t, TeamData.TASK_SETTLE,
				tile.tile_pos, TaskArbiter.PRIO_DISPATCH, "invite_settle"):
			team.invite_cooldown[tid] = state.world.current_tick + RESIDENCY_COOLDOWN * 4   # 等 settle 流程
			print("[Residency] Team%d 邀請 Team%d 安頓 outpost (%d,%d)" % [
				team.team_id, tid, tile.tile_pos.x, tile.tile_pos.y])
			return
		team.invite_cooldown[tid] = state.world.current_tick + RESIDENCY_COOLDOWN

const MOUNT_TARGET_RATIO: float = 0.5

# NPC 出征前自動從自家 outpost 公庫拉 mount 至 population × ratio
# 註：spec 原列 TASK_PREPARE，但 TeamData 無此 task，改以 idle 為唯一不出征狀態
func _auto_withdraw_mounts(state: WorldState, team: TeamData) -> void:
	if team.current_task == TeamData.TASK_IDLE:
		return
	var tile: HexTileData = state.world.tiles.get(
		team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_owner != team.team_id:
		return
	var available: int = int(tile.public_storage.get("mounts", 0))
	if available <= 0:
		return
	var current: int = int(team.resources.get("mounts", 0))
	var target: int = int(float(team.population) * MOUNT_TARGET_RATIO)
	var need: int = maxi(target - current, 0)
	var take: int = mini(need, available)
	if take > 0:
		TileBank.set_amt(tile, "mounts", available - take, "auto_withdraw_mounts_out")
		ResourceBank.set_amt(team, "mounts", current + take, "auto_withdraw_mounts")
		print("[Mount] Team%d auto-withdraw %d mounts" % [team.team_id, take])

# ── evaluate_all 子相位計時（opt-in 掛 SimRunner.phase_timing;cadence spike 歸因 zoom）──
static var _fai_ph: Dictionary = {}
func _fai_pht(name: String, t0: int) -> int:
	var now: int = Time.get_ticks_usec()
	_fai_ph[name] = int(_fai_ph.get(name, 0)) + (now - t0)
	return now

# static 版（DecisionContext.gather 等 static callee 標相位用）
static func _fai_pht_s(name: String, t0: int) -> int:
	var now: int = Time.get_ticks_usec()
	_fai_ph[name] = int(_fai_ph.get(name, 0)) + (now - t0)
	return now

func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	var _zt: int = 0
	var _zoom: bool = SimRunner.phase_timing
	if _zoom:
		_fai_ph.clear()
		_zt = Time.get_ticks_usec()
	_evaluate_all_body(state, _team_ids)
	if _zoom:
		var total: int = Time.get_ticks_usec() - _zt
		if total > 100_000:   # 同 PHASE_SPIKE_US 量級
			var parts: Array = []
			for ph in _fai_ph:
				parts.append({"n": ph, "us": int(_fai_ph[ph])})
			parts.sort_custom(func(a, b): return int(a["us"]) > int(b["us"]))
			var top: String = ""
			for i in range(mini(8, parts.size())):
				top += "%s=%dus " % [parts[i]["n"], parts[i]["us"]]
			print("[FaiPhase] tick=%d total=%d us | %s" % [state.world.current_tick, total, top])
	# Fix 2 時間維 heartbeat sweep（末尾）：specimen 無決策 entry 且超 HEARTBEAT_CADENCE → 補心跳，timeline 無洞。
	# specimen-gated（enabled + 只迭代 specimen_team_ids）→ tracer off 零成本、byte-identical。
	SpecimenTracer.heartbeat_sweep(state)

func _evaluate_all_body(state: WorldState, _team_ids: Array) -> void:
	var _t: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	for fid in state.factions:
		var f = state.factions[fid]
		var _tf: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
		for mid in f.member_team_ids:
			var snap: Dictionary = BeliefSystem.best_estimate(state, f.leader_team_id, mid)
			if not snap.is_empty():
				f.known_member_states[mid] = snap
		if SimRunner.phase_timing: _tf = _fai_pht("loop1.member_snap", _tf)
		_update_goals(state, f)
		if SimRunner.phase_timing: _tf = _fai_pht("loop1.update_goals", _tf)
		_assign_tasks(state, f)
		if SimRunner.phase_timing: _tf = _fai_pht("loop1.assign_tasks", _tf)
		# C: 每 INFRA_INTERVAL 評估一次基建（蓋/升級/擴建）
		if state.world.current_tick % INFRA_INTERVAL == 0:
			_evaluate_infrastructure(state, f)
		if SimRunner.phase_timing: _tf = _fai_pht("loop1.infra", _tf)
		# 每 20 小時評估一次主動外交
		if state.world.current_tick % FACTION_UPDATE_INTERVAL == 0:
			var _leader_team: TeamData = state.teams.get(f.leader_team_id)
			if _leader_team != null:
				DiplomaticAiSystem.new().try_proactive_diplomacy(state, _leader_team)
		if SimRunner.phase_timing: _tf = _fai_pht("loop1.diplo", _tf)
		# 每 BETRAY_CHECK_INTERVAL tick 評估結盟 team 背叛
		if state.world.current_tick % DiplomaticAiSystem.BETRAY_CHECK_INTERVAL == 0:
			var leader_team_b: TeamData = state.teams.get(f.leader_team_id)
			if leader_team_b == null: continue
			for tid in f.member_team_ids.duplicate():  # duplicate: _execute_betrayal may erase during iteration
				if tid == f.leader_team_id: continue
				var member_team: TeamData = state.teams.get(tid)
				if member_team == null: continue
				# 子隊（TAG_SUBTEAM）不評估背叛：在途建造/安頓子隊若被叛出會廢棄任務且造成孤立 zombie。
				if member_team.tags.has(TeamData.TAG_SUBTEAM): continue
				DiplomaticAiSystem.new().consider_betrayal(state, member_team, leader_team_b)
		if SimRunner.phase_timing: _fai_pht("loop1.betray", _tf)

	if SimRunner.phase_timing: _t = _fai_pht("loop1.factions", _t)
	var merge_queue: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		# 野獸(beast_kind!="")不進決策迴圈：非-agent 無「腦」不該經引擎的秤（憲法決策模型）。
		# 生命週期(spawn/combat/reward/cleanup)全在 encounter/npc_combat/beast_system，不評 strategy/solo/infra。
		if team.beast_kind != "": continue
		if team.parent_team_id != -1:
			_evaluate_subteam(state, team, merge_queue)
		elif team.faction_id == -1:
			# 獨立戰略層（統一決策第三塊）：野心獨立隊秤建國 intent，**置於 _evaluate_solo 前**——
			# 戰略意圖（建國）優先於個體日常（SoloAI 貿易/紮營）。建國 dispatch(PRIO_DISPATCH) 後
			# SoloAI 見非 idle 自動跳過（不雙寫）；守成(不 dispatch)則 SoloAI 照常跑既有個體決策。
			# 不另設 cadence gate：與 SoloAI 同「每 idle tick 評估」節奏（否則 SoloAI 每 tick 搶走 idle
			# →戰略層 cadence tick 永遠撞非 idle=漏觸發）。內部三閘(野心+累積+路徑)+hysteresis 自限稀有。
			if SimRunner.phase_timing:
				var _ts: int = Time.get_ticks_usec()
				_evaluate_independent_strategy(state, team)
				_ts = _fai_pht("loop2.indep_strategy", _ts)
				_evaluate_solo(state, team)
				_fai_pht("loop2.solo", _ts)
			else:
				_evaluate_independent_strategy(state, team)
				_evaluate_solo(state, team)
			# S3 means-end 統一：獨立定居隊自家 outpost 建設施（同 _pick_facility argmax，閉合想 goods→需設施→去蓋）。
			if state.world.current_tick % INFRA_INTERVAL == 0:
				_evaluate_independent_infrastructure(state, team)
		else:
			# faction 成員（非子隊，斷①C「入勢力不換腦」）：個人戰略層對每個 leader 永遠跑——
			# faction 身分=context/term（faction_duty），非決策路徑開關。只跑戰略 intent 層
			# （建國 gate 對成員 can_found=false；征服 intent 只宣告），**不呼
			# _evaluate_solo**（個人日常全域=後續 F-D 矩陣格，避與 _assign_tasks 派工大面積互搏，一次一縫）。
			# 序5 dissolve：舊 loop3 cascade 成員打草穀 raid 路已刪；成員征服 intent 現無獨立 dispatch 路
			# （不呼 _evaluate_solo）→ 打草穀 raid 待 序6 loop3 全溶接回（框架債縫#3）。
			if SimRunner.phase_timing:
				var _ts: int = Time.get_ticks_usec()
				_evaluate_independent_strategy(state, team)
				_fai_pht("loop2.member_strategy", _ts)
			else:
				_evaluate_independent_strategy(state, team)

	if SimRunner.phase_timing: _t = Time.get_ticks_usec()
	var sub_sys := SubteamSystem.new()
	for sub_id in merge_queue:
		if not state.teams.has(sub_id):
			continue
		var sub: TeamData = state.teams[sub_id]
		if sub.parent_team_id == -1:
			continue
		var parent: TeamData = state.teams.get(sub.parent_team_id)
		if parent != null and parent.tile_pos == sub.tile_pos:
			sub_sys.try_merge_back(state, sub_id)   # convoy.return telemetry 移入 try_merge_back（真 merge 點對齊 [Merge]）
		else:
			TaskArbiter.release(sub)
			if parent != null:
				sub.move_target = parent.tile_pos

	if SimRunner.phase_timing: _t = _fai_pht("loop2b.merge", _t)
	for tid in state.teams.keys():   # keys() 快照 → 滅團可安全 erase
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# 野獸不進決策迴圈：不 succession 晉升領袖(leader_id=-1 非「死領袖」)、不 ambition/survival/threat。
		# beast husk 清理由 combat cleanup(reward_and_cleanup/_cleanup) 擁有，非 loop3 generic _on_team_extinct。
		if team.beast_kind != "": continue
		# 滅團：population<=0 → 遺財轉公庫/abandoned + 移除空殼團（餓死路徑原只清資產不 erase → husk）
		if team.population <= 0:
			_on_team_extinct(state, team)
			continue
		var _t3: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
		# leader 失效 → 繼承單一 owner（含 anon fallback / player choose_heir）。唯一偵測點。
		if team.leader_id == -1:
			EventSystem.new().on_leader_death(state, team)
		# G2b：野心階梯狀態更新（cadence）
		if team.leader_id != -1 and state.world.current_tick >= team.ambition_eval_next_tick:
			AmbitionLadder.update(state, team)
		# G1b：訂單 cadence（餘發賣盤 / 過期清）
		if team.leader_id != -1 and state.world.current_tick >= team.order_eval_next_tick:
			OrderSystem.new().tick_team_orders(state, team)
			team.order_eval_next_tick = state.world.current_tick + OrderSystem.ORDER_POST_CADENCE
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.orders_ambition", _t3)
		# B: 生存決策（在其他 update 前評估，task 改完後 strategic_ai 看到 sticky 不蓋）
		_evaluate_survival(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.survival", _t3)
		# 獨立戰略層（建國 intent）已在前段 solo 迴圈評估（_evaluate_solo 前，不雙寫）。
		# 序5 dissolve：prosperity attack 決策已溶進主 rank（solo/unified 攻擊 option）——loop3 cascade invoke 刪。
		# 保留的 scout scaffolding 生命週期（逾時釋放 / prey 消失 / 收斂轉攻）走 _tick_conquest_scout。
		_tick_conquest_scout(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.prosperity", _t3)
		# 追擊刷新（攻擊/掠奪 中移動目標會跑，每 tick 對齊 intel）
		_refresh_attack_pursuit(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.pursuit", _t3)
		# D: 被動威脅評估（cadence 內部控管）
		_evaluate_threat(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.threat", _t3)
		# G2d：私人脫軌（血仇）已溶入引擎——hand dispatch 撕除（序4 vendetta 溶入）。
			# feud_pull term 掛進 攻擊 option → 血仇成攻擊的 weight 驅力（衝動 leader 血仇高→攻擊贏 rank，
			# 走 _evaluate_solo/_decide_unified 主 rank@PRIO_DISPATCH）。優先序保：威脅反應同在 rank 競秤
			# （survival_pressure 碾壓 feud）+ loop3 PRIO_THREAT(70)>engine PRIO_DISPATCH(50)。
			# g2.vendetta_trigger probe 移至引擎純血仇攻擊 dispatch（_probe_vendetta_dispatch）。
		# W2: 貿易 task timeout 防 zombie（追不到 / 對方消失）。
		# 起算讀 TaskArbiter 單源 task_start_tick（try_set 恆蓋章）——舊平行欄位 trade_task_start_tick
		# 只有 member_trade/trade_net/舊 solo 三路寫，unified/ambient 派 TRADE 拿 stale 0 → 派出即被
		# 此檢查秒殺（漏斗兩 seed 定罪：dispatch 5.6萬、arrive=0、timeout=3.7萬）。欄位已廢。
		# 額度按殘距估（死常數 6 日 ≈ 20 hex 平原上限，慢地形必死）；到點/擺攤（move_target 清）= base。
		if team.current_task == TeamData.TASK_TRADE:
			var _trade_allow: int = TRADE_TIMEOUT
			if team.move_target != Vector2i(-1, -1):
				_trade_allow += _hex_dist(team.tile_pos, team.move_target) * TRADE_TIMEOUT_PER_HEX
			if state.world.current_tick - team.task_start_tick > _trade_allow:
				Probe.bump("trade.timeout")   # 漏斗站5：timeout 放棄
				TaskArbiter.release(team)
		# A1a: 四 no-release 駐地 task timeout（transition 進場已由 arbiter 蓋 task_start_tick）。
		# PLAYER@60 現任豁免（護欄：引擎 timeout 不清玩家命令；四 task 現無 player command 入口，防未來）。
		elif team.current_task in STATION_TASKS and team.task_priority < TaskArbiter.PRIO_PLAYER:
			if state.world.current_tick - team.task_start_tick > STATION_TIMEOUT:
				Probe.bump("station.timeout")
				TaskArbiter.release(team)
		# 公庫徵用：每月一次依 leader 貪婪評估
		if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
			_consider_extraction(state, team)
			_collect_member_tax(state, team)   # unified-commerce coin combo：成員稅回補 team.coin 池（買方要有錢買市場）
		# D B2: 無人 outpost 駐留接管
		_evaluate_outpost_takeover(state, team)
		# 居民派駐：自家無居民 outpost → 派子隊/邀流亡（cadence 內控）
		_evaluate_outpost_residency(state, team)
		if _is_resident_team(state, team):
			_evaluate_uprising(state, team)
			_evaluate_owner_contact(state, team)
			_tick_resident_unrest(state, team)   # ★SLICE B D:deficit→unrest / fed→relief（餵現成 defection≥20）
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.outpost", _t3)
		_update_equip_order(state, team)
		# anon_combat_skill / anon_wage 改 computed（AnonTierSystem），不再主動更新
		_update_armor_config(team)
		_update_guard_ratio(team, state)
		# 出征前自動從自家 outpost 公庫拉 mount
		_auto_withdraw_mounts(state, team)
		# G2c：野心階梯常態行為（最低優先，只填 idle）。
		# 序3：rung_task 查表撕除 → 引擎 rank（archetype/rung 當 weight，train_drive 讀之）。
		# 序3 follow-up：rank_scored_ctx → rank_ambient（收窄至 AMBIENT_OPTION_SET）。ambient 不二次猜
		# survival/threat（team 到此已過 loop3 survival/threat/prosperity）→ 除次門檻 FLEE churn。
		# 取首個 dispatchable option（非 IDLE）走 PRIO_AMBIENT；貿易 target 已在 to_task「貿易」內
		# （_merchant_trade_target：arb 單→巡市集→fallback）→ ambient 語意保。
		if team.current_task == TeamData.TASK_IDLE:
			var _ctx := DecisionContext.gather(state, team)
			for _opt in DecisionEngine.rank_ambient(_ctx):
				var _td: Dictionary = DecisionOptions.to_task(state, team, String(_opt))
				var _tk: String = String(_td.get("task", TeamData.TASK_IDLE))
				if _tk == TeamData.TASK_IDLE: continue
				if TaskArbiter.try_set(state, team, _tk, _td.get("target", Vector2i(-1, -1)), TaskArbiter.PRIO_AMBIENT, "ambition"):
					if _tk == TeamData.TASK_TRADE:
						Probe.bump("trade.dispatch.ambient")   # 漏斗站4
					break
		if SimRunner.phase_timing: _fai_pht("loop3.misc", _t3)

# ──────── Tag 權限 ────────

func _tag_weight(team: TeamData, task: String) -> float:
	if task in [TeamData.TASK_IDLE, TeamData.TASK_FLEE]: return 1.0
	if team.tags.has("統領") or team.tags.has(TeamData.TAG_SUBTEAM): return 1.0
	if team.tags.has("流亡"): return 0.0
	var task_tags: Dictionary = {
		TeamData.TASK_ATTACK:      ["軍隊"],
		TeamData.TASK_LOOT:        ["軍隊"],
		TeamData.TASK_TRIBUTE:     ["軍隊", "統領"],
		TeamData.TASK_ESCORT:      ["軍隊", "商隊"],
		TeamData.TASK_SCOUT:       ["軍隊", "商隊"],
		TeamData.TASK_DIPLOMACY:   ["商隊", "宗教"],
		TeamData.TASK_HERALD:      ["軍隊", "商隊", "生產", "宗教"],
		TeamData.TASK_PRODUCE:     ["生產"],
		TeamData.TASK_MANUFACTURE: ["生產"],
		TeamData.TASK_TRADE:       ["商隊"],
		TeamData.TASK_PATROL:      ["軍隊", "統領"],
	}
	var required: Array = task_tags.get(task, [])
	if required.is_empty(): return 1.0
	for tag in required:
		if team.tags.has(tag): return 1.0
	return 0.0 if team.tags.size() > 0 else 0.5

# ──────── commander-v2 means-end：意圖選擇（人格×belief×viability×hysteresis）────────

# 人格意圖 raw 分（4 項；不含 hysteresis / argmax）。統一 scorer 與 _score_intents 共用（DRY）。
# weak_enemy = belief 認為最近獨立 target 可打贏（征服 viable）。
func _intent_scores(values: Dictionary, established: bool, weak_enemy: bool,
		can_levy: bool) -> Dictionary:
	# R2 共源：人格層 = AmbitionLadder.disposition_scores（intent/archetype 單一公式），此處只疊 viability。
	var scores: Dictionary = AmbitionLadder.disposition_scores(values)
	# viability：征服只在 established + 能湊出實打力(weak_enemy)；湊不出 → 壓到地板(resource-aware 退更小意圖)
	if not established or not weak_enemy:
		scores["征服"] = -1.0
	# 致富主手段=徵收 levy；湊不出 richer member → 仍可（守成/貿易 fallback），不壓死
	if not can_levy:
		scores["致富"] = scores["致富"] * 0.6
	return scores

# argmax + hysteresis：committed 情勢未變時黏住。共用於 _score_intents / select_strategic_intent。
func _argmax_intent(scores: Dictionary, committed: String, persist_bonus: float = COMMANDER_COMMITMENT_BONUS) -> Dictionary:
	if committed != "" and scores.has(committed) and scores[committed] > -0.5:
		# ★持守統一 Slice 1：live 路傳 persist_strength（人格加權沉沒成本，取代 flat 0.15）；純函式/測用 flat default。
		scores[committed] += persist_bonus
	var best_type: String = "守成"
	var best_score: float = -INF
	for t in scores:
		if scores[t] > best_score:
			best_score = scores[t]; best_type = t
	return {"type": best_type, "score": best_score}

# 從 leader values + 世界量出意圖適性 + 可行性 → argmax 主意圖（單一，不並行）。
# committed = 上次承諾意圖（hysteresis）。純函式（保留單測入口）。
func _score_intents(values: Dictionary, established: bool, weak_enemy: bool,
		can_levy: bool, committed: String) -> Dictionary:
	return _argmax_intent(_intent_scores(values, established, weak_enemy, can_levy), committed)

# ──────── 統一戰略 scorer（首燒 F-D2：任何有 leader 的隊一套菜單）────────
# 泛化 _select_intent/_score_intents：輸入 leader values + ctx(gate/scale/viability/建國) → argmax 全菜單。
# ctx 欄位：leader_values, established, weak_enemy, can_levy, committed,
#   can_found(bool, 僅 fid==-1), found_score(float), target_id(int)。
# 輸出 {type, target_id, why}（type = 選中意圖；target_id 僅征服帶）。
func select_strategic_intent(state: WorldState, team: TeamData, ctx: Dictionary) -> Dictionary:
	var values: Dictionary = ctx.get("leader_values", {})
	var scores: Dictionary = _intent_scores(values,
		bool(ctx.get("established", false)), bool(ctx.get("weak_enemy", false)),
		bool(ctx.get("can_levy", false)))
	# 建國（實體型 gate）：僅 fid==-1 可選；score = found_score（累積+路徑+人格 已由 caller 折入）。
	if bool(ctx.get("can_found", false)):
		scores["建國"] = float(ctx.get("found_score", 0.0))
	# 擴張（F-D3 折入 strategic_ai expand）：force archetype + rung≥EXPAND + 有 target 才可選。
	# 征服(可打贏弱敵)通常勝擴張；無 viable 弱敵時擴張補位(領土 pressure)→ strategic_ai 包圍。
	if bool(ctx.get("can_expand", false)):
		scores["擴張"] = 0.3 + float(values.get("野心", 0.5)) * 0.3
	# ★持守統一 Slice 1：committed 戰略意圖 hysteresis 讀 persist_strength（人格加權沉沒成本，取代 flat COMMANDER bonus）。
	var picked: Dictionary = _argmax_intent(scores, String(ctx.get("committed", "")),
		PersistStrength.compute(state, team) if team != null else COMMANDER_COMMITMENT_BONUS)
	var target_id: int = int(ctx.get("target_id", -1))
	var needs_target: bool = picked["type"] == "征服" or picked["type"] == "擴張"
	return {
		"type": picked["type"],
		"target_id": target_id if needs_target else -1,
		"why": _intent_why(picked["type"], target_id),
	}

func _intent_why(itype: String, target_id: int) -> String:
	match itype:
		"征服": return "野心/好戰驅動，belief 評 target%d 可打贏" % target_id
		"擴張": return "武力階梯≥擴張，領土 pressure target%d(包圍)" % target_id
		"致富": return "貪婪驅動，treasury 增"
		"防衛": return "慎重/威脅驅動，備戰守土"
		"建國": return "野心驅動，累積夠+路徑可達→立勢力"
		"守成": return "無強驅動，維持現狀"
	return ""

# 統領意圖選擇（接 state）：量 viability(belief 敵力 vs 我力)、can_levy(富 member)、hysteresis(f.intent)。
func _select_intent(state: WorldState, f) -> Dictionary:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null: return {"type": "守成", "target_id": -1, "why": ""}
	var leader_p = state.persons.get(leader_team.leader_id)
	var values: Dictionary = leader_p.values if leader_p else {}
	# 征服 target + viability（複用既有 attack readiness/strength gate + belief 敵力）
	var target_id: int = _nearest_independent(state, leader_team)
	var weak_enemy: bool = false
	if target_id != -1 and leader_team.readiness >= ATTACK_READINESS_MIN \
			and _tag_weight(leader_team, TeamData.TASK_ATTACK) > 0.0:
		weak_enemy = _conquest_viable(state, f, leader_team, target_id)
	# 擴張 gate（F-D3）：武力 archetype + rung≥擴張 + 有 target → 可選擴張（折入 strategic_ai expand）。
	var can_expand: bool = leader_team.ambition_archetype == AmbitionLadder.ARCHETYPE_FORCE \
		and leader_team.ambition_rung >= AmbitionLadder.RUNG_EXPAND and target_id != -1
	# faction leader 走統一 scorer（established faction 已立國 → can_found=false，不重複建國）。
	var ctx: Dictionary = {
		"leader_values": values,
		"established": f.is_established,
		"weak_enemy": weak_enemy,
		"can_levy": _richest_member(state, f) != -1,
		"committed": f.intent.get("type", ""),
		"can_found": false,
		"can_expand": can_expand,
		"target_id": target_id,
	}
	return select_strategic_intent(state, leader_team, ctx)

# 征服 viability：我力(含可補力餘裕粗估) >= belief 敵力 × strength ratio。複用既有 attack gate。
func _conquest_viable(state: WorldState, f, leader_team: TeamData, target_id: int) -> bool:
	var tgt_snap: Dictionary = BeliefSystem.best_estimate(state, f.leader_team_id, target_id)
	var tgt_armed: int = int(tgt_snap.get("armed_est", 999))  # 未知視為強敵 → 不 viable
	var own_armed: int = _calc_own_armed(state, leader_team)
	# 可補力餘裕：同 faction member 在攻擊 task 的 armed（既有 _update_goals 邏輯）
	for mid in f.known_member_states:
		if mid == f.leader_team_id: continue
		var ms: Dictionary = f.known_member_states[mid]
		if ms.get("current_task", "") == TeamData.TASK_ATTACK:
			own_armed += int(ms.get("armed_est", 0))
	return float(own_armed) >= float(tgt_armed) * ATTACK_STRENGTH_RATIO

# ──────── 目標評估 ────────

# commander-v2 means-end 重構：意圖 predicate → 子需求現算(深度1) → 真 affordance 匹配 → 每令帶 driver。
# 北極星：凡 named 意圖必有可解釋驅動（f.goal_drivers[goal]={intent,why,mode}）。
func _update_goals(state: WorldState, f) -> void:
	f.goals.clear()
	f.goal_drivers.clear()
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null:
		return

	# G-09：玩家設定 override → 跳過自動計算，直接套用
	if not f.player_goal_override.is_empty():
		f.goals.append(f.player_goal_override)
		return

	var leader_p = state.persons.get(leader_team.leader_id)
	var ambition: float = float(leader_p.values.get("野心",   0.5)) if leader_p else 0.5
	var survival: float = float(leader_p.values.get("求生欲", 0.5)) if leader_p else 0.5
	var honor:    float = float(leader_p.values.get("義氣",   0.5)) if leader_p else 0.5

	# ── 步驟 1：survival override（意圖前）＋立國 gate（既有分離）──
	# WS-2c：有效糧(私產+自家糧倉)，否則定居 leader 隊 food 在糧倉→永誤判缺糧→恆觸急徵稅。
	var food_per_cap: float = ResourceSystem.effective_food(state, leader_team) / maxf(leader_team.population, 1)
	var effective_emergency: float = FOOD_EMERGENCY * (0.7 + survival * 0.6) \
		* clampf(1.0 - honor * HONOR_EMERGENCY_DISC, 0.5, 1.0)
	if food_per_cap < effective_emergency:
		f.strategy = "緊急徵收"
		_emit_goal(state, f, "徵收", "守成", "缺糧 survival override", "survival")  # driver mode=survival
		return

	# 立國 gate（既有分離，非意圖集；不在 means-end argmax）
	if not f.is_established and f.member_team_ids.size() >= 2 and leader_p != null:
		var cmd: float = float(leader_p.skills.get("統領", 0.0))
		var ambition_discount: float = (ambition - 0.5) * 0.2
		if cmd >= ESTABLISH_COMMAND - ambition_discount \
				and ambition >= ESTABLISH_AMBITION - 0.1 \
				and leader_team.readiness >= ESTABLISH_READINESS:
			_emit_goal(state, f, "立國", "守成", "稱號擴張(既有 gate)", "establish")

	# ── 步驟 2：意圖選擇（cadence-gate，藍圖 #3：1 日重選，cadence 內沿用 f.intent）──
	if state.world.current_tick >= f.intent_eval_next_tick:
		f.intent = _select_intent(state, f)
		f.intent_eval_next_tick = state.world.current_tick + INTENT_CADENCE
	# else：沿用上次 f.intent（committed hysteresis 已在 _select_intent，cadence 再加穩定層）
	var intent: Dictionary = f.intent if f.intent is Dictionary and not f.intent.is_empty() \
		else {"type": "守成", "target_id": -1, "why": ""}
	f.strategy = intent["type"]
	var itype: String = intent["type"]
	if Probe.enabled and itype != "": Probe.bump("intent.sel_" + itype)

	# 戰爭基金（跨意圖籌餉 sub-need）：野心/好戰高 + 建材枯 → 特別稅備戰（driver=備戰籌餉）。
	# 非缺糧 survival；意圖無關（想武裝起來）。保留既有經濟行為，附 driver 連回意圖。
	var martial: float = float(leader_p.values.get("好戰", 0.5)) if leader_p else 0.5
	var war_chest_need: bool = (ambition > 0.6 or martial > 0.6) \
		and float(leader_team.resources.get("material", 0)) < WAR_CHEST_MIN
	if war_chest_need:
		f.strategy = "戰爭基金"
		_emit_goal(state, f, "徵收", itype, "備戰籌餉(建材枯)", "fund_war")

	# ── 步驟 3+4：分解子需求(深度1) + 匹配 filler + emit（每令 driver）──
	match itype:
		"征服":
			# 主行動=攻擊 target；補力肢從未滿足前提(force_ge_target)現算
			_emit_goal(state, f, "攻擊", "征服", "主手段取 target%d" % intent["target_id"], "combat")
			var open_needs: Array = _decompose_needs(state, f, leader_team, "攻擊", intent["target_id"])
			_match_fillers(state, f, leader_team, open_needs, "征服")
		"致富":
			# 無單一 main_action → 最高 util 致富行動（徵收 levy；無富 member 則守成）
			if _richest_member(state, f) != -1:
				_emit_goal(state, f, "徵收", "致富", "籌資增 treasury", "levy")
			# 致富亦可外交結盟拓商路（真 affordance ally；輔助，從人格餘裕）
			if _has_independent(state, f.leader_team_id) and leader_team.readiness >= DIPLOMACY_READINESS_MIN:
				_emit_goal(state, f, "外交", "致富", "結盟拓勢", "ally")
		"擴張":
			# 領土 pressure（F-D3）：空間包圍由 strategic_ai encirclement 執行（讀 f.intent）；
			# commander 層備戰籌餉（徵收 fund_war），不發直接攻擊令（擴張≠殲滅，靠包圍施壓吸收）。
			if _richest_member(state, f) != -1:
				_emit_goal(state, f, "徵收", "擴張", "備戰籌餉(領土 pressure)", "fund_war")
		"防衛":
			# 領土不失 → 備戰籌資（徵收 fund_war）
			if _richest_member(state, f) != -1:
				_emit_goal(state, f, "徵收", "防衛", "備戰籌餉", "fund_war")
		"守成":
			# default：無 stakes 令；僅維持經濟 cadence（定期徵收，仍帶 driver）
			var greed_s: float = float(leader_p.values.get("貪婪", 0.5)) if leader_p else 0.5
			var effective_interval: int = maxi(
				int(COLLECT_INTERVAL * (1.5 - greed_s) * (1.0 + honor * HONOR_INTERVAL_MULT)), 10)
			if state.world.current_tick % effective_interval == 0 and _richest_member(state, f) != -1:
				_emit_goal(state, f, "徵收", "守成", "定期維持 treasury", "levy")
	# 掠奪 = team option（P1）非統領令；war-priority 移除（單意圖後 moot）。

# 子需求分解（深度1）：主行動未滿足前提 vs live 世界 → open needs（每 need = 子目標 String）。
# 只回推主行動前提，不遞迴填補行動自己的前提。
func _decompose_needs(state: WorldState, f, leader_team: TeamData, main_action: String, target_id: int) -> Array:
	var open: Array = []
	var schema: Dictionary = ACTIONS.get(main_action, {})
	for pre in schema.get("preconds", []):
		if not _precond_met(state, f, leader_team, pre, target_id):
			match pre:
				"force_ge_target": open.append("補力")   # 軍力不足 → 需補力
				# can_reach 失敗=擋敵盟需「欺敵」filler→孤兒(無真 affordance)→不開該 need(spec 欺敵孤兒洞)
				_: pass
	return open

# 前提 check（複用既有 gate）。深度1：只查主行動自身前提。
func _precond_met(state: WorldState, f, leader_team: TeamData, pre: String, target_id: int) -> bool:
	match pre:
		"force_ge_target":
			# 嚴格：leader 隊「當前」獨力軍力已 ≥ 敵（不含補力餘裕）→ 滿足，不開補力肢。
			# 不足但 intent 仍 viable（含餘裕）→ 開「補力」need 抽輔助肢（這正是 means-end 思考）。
			if target_id == -1: return true
			var snap: Dictionary = BeliefSystem.best_estimate(state, f.leader_team_id, target_id)
			var tgt_armed: int = int(snap.get("armed_est", 999))
			var own_armed: int = _calc_own_armed(state, leader_team)
			return float(own_armed) >= float(tgt_armed) * ATTACK_STRENGTH_RATIO
		"can_reach":
			# ★god-view 1119（arc 最後 leak）：target 位讀 belief（可見→live/斷視線→belief last-seen/
			# positionless→can_reach false），同 Slice D position 範式（不瞬鎖真位算可達）。observer=f.leader_team_id
			# 與旁 force_ge_target 的 best_estimate 一致。★<999 near-vacuous(真可達語意)=另評,記 known_issues,不擴本刀。
			if target_id == -1 or not state.teams.has(target_id):
				return false
			var tgt_pos: Vector2i = BeliefSystem.belief_pos(state, f.leader_team_id, target_id)
			if tgt_pos == Vector2i(-1, -1):
				return false   # 無 belief 位=無法算可達（不讀 live god-view）
			return _hex_dist(leader_team.tile_pos, tgt_pos) < 999
		"has_richer_member":
			return _richest_member(state, f) != -1
	return true

# filler 匹配：util = affordance∩need × 人格適性 × viable；從人格餘裕抽輔助肢（非硬塞）。
# 補力 need ← 結盟(外交 ally) / 徵收(fund_war)；命中即 emit driver。
func _match_fillers(state: WorldState, f, leader_team: TeamData, open_needs: Array, intent_type: String) -> void:
	var leader_p = state.persons.get(leader_team.leader_id)
	var honor: float = float(leader_p.values.get("義氣", 0.5)) if leader_p else 0.5
	var greed: float = float(leader_p.values.get("貪婪", 0.5)) if leader_p else 0.5
	for need in open_needs:
		if need == "補力":
			# 結盟(外交 ally)：義氣高 leader 偏好；需有獨立鄰可結盟
			var ally_ok: bool = _has_independent(state, f.leader_team_id) \
				and leader_team.readiness >= DIPLOMACY_READINESS_MIN
			var ally_util: float = (0.3 + honor * 0.5) if ally_ok else -1.0
			# 徵收(fund_war 籌餉練兵)：貪婪/務實 leader 偏好；需富 member
			var levy_ok: bool = _richest_member(state, f) != -1
			var levy_util: float = (0.3 + greed * 0.4) if levy_ok else -1.0
			if ally_util >= levy_util and ally_util > 0.0:
				_emit_goal(state, f, "外交", intent_type, "補力(結盟拖住/壯盟)", "ally")
			elif levy_util > 0.0:
				_emit_goal(state, f, "徵收", intent_type, "補力(籌餉練兵)", "fund_war")

# emit 一令 + 記 driver（北極星：每令連回意圖）。goal token 用既有消費詞彙(攻擊/徵收/外交/立國)。
func _emit_goal(state: WorldState, f, goal: String, intent_type: String, why: String, mode: String) -> void:
	if goal not in f.goals:
		f.goals.append(goal)
	f.goal_drivers[goal] = {"intent": intent_type, "why": why, "mode": mode}
	# ⑦ 統一重評 stamp（單一 choke point，涵蓋全 11 呼叫點）：faction 命令變化 → 成員 directive_fresh 即重評。
	f.directive_change_tick = state.world.current_tick
	if Probe.enabled: Probe.bump("intent.goal_emit")
	# specimen tap：commander goal → capture intent（leader team 是 specimen 時）
	SpecimenTracer.capture_intent(state, f.leader_team_id, intent_type, why, mode)

# ──────── 獨立戰略層（野心獨立隊建國 intent）────────

# F-D4：solo_intent 統一 intent struct 讀/寫 helper（廢一槽兩義；driver-complete parity）。
static func _solo_type(team: TeamData) -> String:
	return String(team.solo_intent.get("type", "")) if team.solo_intent is Dictionary else ""

func _set_solo(state: WorldState, team: TeamData, itype: String, why: String, mode: String) -> void:
	state.set_solo_intent(team, itype, why, mode, "solo:" + itype)   # S6 chokepoint：每令帶 driver（連回意圖，北極星）
	if Probe.enabled and itype != "": Probe.bump("intent.sel_" + itype)
	SpecimenTracer.capture_intent(state, team.team_id, itype, why, mode)

# mirror commander-v2 _select_intent（輕量）：fid=-1 野心獨立隊秤「建國 vs 守成」→ means-end 子行動
# 結盟(primary)/吞併(機會) → 複用既有 create_faction（不新 founding 機制）。守成=不 dispatch（繼續既有個體決策）。
# 觸發 gate：fid=-1 + 野心≥AMBITION_FOUND_MIN + 累積夠（pop≥EXPAND_MIN_POP + 食盈餘）+ founding 路徑可達。
# 稀有 by construction：野心高 + 累積 + 路徑三閘 → 多數獨立隊守成（非建國潮）。
func _evaluate_independent_strategy(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	# 斷①C「入勢力不換腦」：個人戰略層對每個 leader 永遠跑（含 faction 成員）——身分=權重非路徑切換。
	# 成員的建國由 can_found=false 擋（fid≠-1 不重複建國）；征服 intent 只宣告。
	# 序5 dissolve：成員打草穀 raid 舊走 loop3 cascade（已刪）；征服 intent 現無獨立 dispatch 路 → 待 序6 loop3 全溶。
	if team.parent_team_id != -1: return        # 子隊不自建國   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if team.combat_target != -1: return         # 戰鬥中不重評   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var lv: Dictionary = leader.values

	# 建國 in-flight guard（②a 保險網：凡 in-flight latch 必有 timeout/release）。
	# A. 結盟提案在途（信使送信中，權威 pending_proposal）→ 等結果；逾時清 pending + cooldown（信使死/迷路）。
	if not team.pending_proposal.is_empty():
		var pp: Dictionary = team.pending_proposal
		if state.world.current_tick - int(pp.get("issued_tick", 0)) > int(pp.get("timeout", 2 * WorldState.TICKS_PER_DAY)):
			var tgt: int = int(pp.get("target_id", -1))
			if tgt != -1:
				team.diplomacy_reject_cooldown[tgt] = state.world.current_tick + DiplomaticAiSystem.REJECT_COOLDOWN
			team.pending_proposal = {}
			Probe.bump("envoy.timeout")
			Probe.bump("indep.found_timeout")
		return   # 提案在途/剛清 → 本 cadence 不重評（等信使結果或下 cadence 重來）
	# B. 吞併 task 在途（TASK_ATTACK 建國）→ 逾時 release（此分支 prey 已 defer 至 prosperity，殘留 symmetry）。
	if team.current_task != TeamData.TASK_IDLE and team.task_reason == "found_subjugate":
		if state.world.current_tick - team.task_start_tick \
				> _founding_timeout(_hex_dist(team.tile_pos, team.move_target)):
			TaskArbiter.release(team)
			Probe.bump("indep.found_timeout")
		return

	# ── 征服 affordance（獨立 solo-scale = prosperity attack，G3d scout-gated）──
	# 有 belief-弱 prey + prosperity 候選 → 讓 prosperity-attack 執行（慎重者對不確定 prey 先 scout，
	# 勝→npc_combat subjugate→create_faction 也達建國）。此處 defer + capture 征服 anchor
	# （首燒：好戰獨立 → 征服 intent 顯化，CONQUER 分布不再恆 0）。避 建國-吞併 繞過 scout gate（S3 回歸）。
	var _tw: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	var _prey_probe: int = _find_weakest_prey(state, team) if _is_prosperity_candidate(state, team) else -1
	if SimRunner.phase_timing: _tw = _fai_pht("indep.weakest_prey", _tw)
	if _prey_probe != -1:
		var prey0: int = _prey_probe   # 單呼（原雙呼 _find_weakest_prey 同 tick 同結果,zoom 順手收）
		# 統一 scorer 秤：給 viable 弱敵，此 leader 是否戰略偏好征服（一致複用菜單，非另判斷）
		var conq: Dictionary = select_strategic_intent(state, team, {
			"leader_values": lv, "established": true, "weak_enemy": true,
			"can_levy": true, "target_id": prey0, "committed": _solo_type(team)})
		if conq["type"] == "征服":
			_set_solo(state, team, "征服", String(conq["why"]), "prosperity")   # driver：獨立征服→prosperity 攻擊 affordance
			# 征服名實探針：征服 intent 宣告 + 該隊是否走 _decide_unified（uses_unified）→ 解釋名實斷點路徑。
			if Probe.enabled:
				Probe.bump("conq.declared")
				Probe.bump("conq.declared_unified" if uses_unified(team) else "conq.declared_nonunified")
		return   # defer to prosperity（scout-gated；不在此 dispatch 攻擊）

	# ── 全菜單 scorer（征服已由 prosperity 處理 → weak_enemy=false；建國 gate 折入 can_found）──
	var ambition: float = float(lv.get("野心", 0.5))
	var busy: bool = team.current_task in SURVIVAL_TASKS \
		or team.task_priority > TaskArbiter.PRIO_DISPATCH
	# 建國子行動候選（結盟 primary；吞併已由 prosperity 收 → 此分支 prey 恆 -1）：
	var ally_id: int = _nearest_independent(state, team)   # 結盟候選（可達獨立鄰）
	var prey_id: int = _find_weakest_prey(state, team)     # 恆 -1（上面 return），保留 symmetry
	var honor:   float = float(lv.get("義氣", 0.5))
	var cruelty: float = float(lv.get("殘忍", 0.5))
	var martial: float = float(lv.get("好戰", 0.5))
	var ally_util: float = (0.3 + honor * 0.5) if ally_id != -1 else -1.0
	var subj_util: float = (0.2 + cruelty * 0.4 + martial * 0.3) if prey_id != -1 else -1.0
	var best_sub_util: float = maxf(ally_util, subj_util)
	var found_score: float = best_sub_util * (0.6 + ambition * 0.6)
	if _solo_type(team) == "建國":
		# ★持守統一 Slice 1：建國意圖 hysteresis 讀 persist_strength（取代 flat FOUND bonus）。
		found_score += PersistStrength.compute(state, team)
	# 建國 gate（fid==-1 + 野心 + 累積[pop+7日食盈餘] + 路徑[ally] + 非危時）→ can_found
	var accum_ok: bool = team.population >= AmbitionLadder.EXPAND_MIN_POP \
		and ResourceSystem.effective_food(state, team) >= float(team.population) \
			* ResourceSystem.FOOD_PER_PERSON_PER_DAY * FOUND_FOOD_SURPLUS_DAYS
	var path_ok: bool = ally_id != -1 or prey_id != -1
	# 成員 can_found=false（fid≠-1 不重複建國，雙保險；建國 = 獨立隊專屬 gate）
	var can_found: bool = team.faction_id == -1 and ambition >= AMBITION_FOUND_MIN and accum_ok and path_ok and not busy
	# Probe funnel（保 warring/bed 診斷語意）
	if ambition >= AMBITION_FOUND_MIN:
		Probe.bump("indep.gate_ambitious")
		if not accum_ok:
			Probe.bump("indep.gate_fail_pop" if team.population < AmbitionLadder.EXPAND_MIN_POP else "indep.gate_fail_food")
		elif busy:
			Probe.bump("indep.gate_fail_busy")
		elif not path_ok:
			Probe.bump("indep.gate_fail_nopath")
		else:
			Probe.bump("indep.gate_path_ok")

	# ── 全菜單 argmax（致富/建國/防衛/守成；征服已 defer）──
	var intent: Dictionary = select_strategic_intent(state, team, {
		"leader_values": lv, "established": false, "weak_enemy": false,
		"can_levy": true, "committed": _solo_type(team),
		"can_found": can_found, "found_score": found_score, "target_id": -1})
	var itype: String = intent["type"]
	match itype:
		"建國":
			_set_solo(state, team, "建國", "野心建國(found_score=%.2f)" % found_score,
				"found_ally" if ally_util >= subj_util else "found_subjugate")
			if ally_util >= subj_util and ally_id != -1:
				# 結盟（primary）：②a 改派信使——不再自己整隊追（追移動隊永談不成=荒謬）。
				# 派信使子隊送提案 → 對方按 belief 回覆 → 母隊 release 回日常等結果（pending_proposal 權威）。
				if _dispatch_envoy(state, team, ally_id, "alliance"):
					print("[IndepStrategy] Team%d 野心建國→派信使結盟 Team%d (野心=%.2f)" % [
						team.team_id, ally_id, ambition])
					Probe.bump("indep.found_ally")
			elif prey_id != -1:
				# 讓位日常 task（busy 已濾高優先；此處只剩 idle/日常 @≤DISPATCH）→ founding @PRIO_DISPATCH 設得進
				if team.current_task != TeamData.TASK_IDLE:
					TaskArbiter.release(team)
				# 吞併 fallback（此分支現不觸；weak prey 已由 prosperity defer 收）。保留 symmetry。
				if not team.tags.has("統領"):
					state.add_tag(team, "統領", "found_subjugate")
				# E3 感知鐵律：建國吞併攻擊移動目標讀 belief last-seen（非 live god-view）。無 belief→不 dispatch。
				var fs_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, prey_id)
				if fs_pos != Vector2i(-1, -1) and TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
						fs_pos, TaskArbiter.PRIO_DISPATCH, "found_subjugate"):
					team.prosperity_target_id = prey_id
					print("[IndepStrategy] Team%d 野心建國→吞併 Team%d (野心=%.2f)" % [
						team.team_id, prey_id, ambition])
					Probe.bump("indep.found_subjugate")
		"致富":
			# 致富 anchor：獨立商隊致富 intent → 委由既有貿易 affordance（SoloAI/unified 貿易 option）。
			# 不 dispatch（不搶 task）→ SoloAI/_decide_unified 接手成交（首燒：致富→貿易 錨接上）。
			_set_solo(state, team, "致富", String(intent["why"]), "trade")
		_:
			# 守成/防衛/擴張 = 不 dispatch，繼續既有個體決策（SoloAI/survival/ambient）
			_set_solo(state, team, itype, String(intent["why"]), "hold")

# ──────── ②a 信使外交（envoy）helpers ────────

# timeout=保險網（非死常數）：單程 hex 距離 × 每格 tick 成本估（BASE_MOVE_TICKS，speed=1 基準）
# × 往返裕度係數；下限 2 天（防近距離秒 release）。信使 task 與母隊 pending 共用此估算。
func _founding_timeout(dist: int) -> int:
	return maxi(int(float(dist) * float(MovementSystem.BASE_MOVE_TICKS) * FOUNDING_TIMEOUT_MULT),
		FOUNDING_TIMEOUT_FLOOR_DAYS * WorldState.TICKS_PER_DAY)

# 派信使子隊送提案（復用 SubteamSystem/herald/mounts/movement/belief 既有信號，零新系統）。
# 提案權威存母隊 pending_proposal；信使帶 proposal_id ref（task_extra_data）。冗餘多騎首達生效。
# 回 true = 至少派出 1 信使（母隊 release 回日常等結果）；false = 無法派（無 spare named）。
func _dispatch_envoy(state: WorldState, mother: TeamData, target_id: int, ptype: String) -> bool:
	var target: TeamData = state.teams.get(target_id)
	if target == null:
		return false
	# 目標位讀 belief best_estimate（非上帝視角真位；對齊決策讀情報總則）
	# F1 感知鐵律：缺 belief → sentinel (-1,-1)（禁默認 live）；無位不派 envoy。
	var target_pos: Vector2i = BeliefSystem.best_estimate(state, mother.team_id, target_id).get("tile_pos", Vector2i(-1, -1))
	if target_pos == Vector2i(-1, -1):
		return false   # 無 belief 位 → 不派 envoy（不瞎追 live）
	var dist: int = _hex_dist(mother.tile_pos, target_pos)
	var budget: int = _founding_timeout(dist)
	var proposal_id: String = "%d_%d_%d" % [mother.team_id, target_id, state.world.current_tick]
	var sub_sys := SubteamSystem.new()
	var sent: int = 0
	for _i in range(ENVOY_REDUNDANCY_FOUNDING):
		if mother.population <= 1:
			break   # 不掏空母隊（保 leader + ≥1）
		var sub_leader: int = sub_sys._pick_subteam_leader(state, mother, TeamData.TASK_HERALD)
		if sub_leader == -1 or sub_leader == mother.leader_id:
			break   # 無 spare named → 無法派信使（稀有 by construction，退守成）
		var envoy_id: int = sub_sys.dispatch(state, mother.team_id, sub_leader, ENVOY_POP,
			TeamData.TASK_HERALD, target_pos, target_id, "")
		if envoy_id == -1:
			break
		var envoy: TeamData = state.teams[envoy_id]
		envoy.task_reason = "envoy_proposal"
		envoy.task_start_tick = state.world.current_tick   # dispatch 直賦 task 未設 → timeout 基準
		envoy.task_extra_data = {"proposal_id": proposal_id, "timeout": budget}
		_equip_envoy_mounts(state, mother, envoy)   # 馬：撥至 pop×1（有幾配幾，無馬照走）
		sent += 1
		Probe.bump("envoy.dispatched")
	if sent == 0:
		return false
	# 誘因（糧禮先行）：急迫（野心）×付得起（effective_food 盈餘）→ 掏禮，發起即扣（守恆:送達轉移目標）。
	# 窮狼掏不出（無盈餘）→ gift 空 → 白嘴照舊難。禮沉沒風險=亂世押鏢（信使死/reject 不退，Task2）。
	# 結構通用 {res: amount}（聯姻槽未來直插）；本 slice 僅糧。dispatch 後算（母隊剩糧為準）。
	var gift: Dictionary = {}
	var mleader: PersonData = state.persons.get(mother.leader_id)
	if mleader != null and ptype == "alliance":
		var amb: float = float(mleader.values.get("野心", 0.5))
		var reserve: float = float(mother.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * FOUND_FOOD_SURPLUS_DAYS
		var surplus: float = maxf(ResourceSystem.effective_food(state, mother) - reserve, 0.0)
		var frac: float = lerpf(GIFT_FRACTION_MIN, GIFT_FRACTION_MAX, amb)
		var want: int = int(surplus * frac)
		if want > 0:
			# remove 從 team.resources 扣（clamp 至實有→不透支；granary 糧不在此扣=保守）
			var paid: float = ResourceBank.remove(mother, "food", float(want), "alliance_gift")
			if paid > 0.0:
				gift = {"food": paid}
				Probe.bump("envoy.gift_sent")
	# 提案權威存母隊（對齊 active_orders pattern）
	mother.pending_proposal = {
		"type": ptype, "target_id": target_id, "target_pos": target_pos,
		"issued_tick": state.world.current_tick, "proposal_id": proposal_id, "timeout": budget,
		"gift": gift,
	}
	# 母隊不再自己追（release 回日常，等結果；pending 期間不重派）
	if mother.current_task != TeamData.TASK_IDLE and mother.task_priority <= TaskArbiter.PRIO_DISPATCH:
		TaskArbiter.release(mother)
	return true

# 馬：從母隊 resources 撥 mounts 至信使 pop×1（有幾配幾，無馬走路=慢但能送）。守恆（母隊扣、信使加）。
func _equip_envoy_mounts(state: WorldState, mother: TeamData, envoy: TeamData) -> void:
	var want: int = envoy.population
	var have_envoy: int = int(envoy.resources.get("mounts", 0))
	var need: int = maxi(want - have_envoy, 0)
	if need <= 0:
		return
	var from_mother: int = mini(need, int(mother.resources.get("mounts", 0)))
	if from_mother <= 0:
		return
	ResourceBank.add(mother, "mounts", -from_mother, "envoy_mount_out")
	ResourceBank.add(envoy, "mounts", from_mother, "envoy_mount_in")

# 信使每 tick：追蹤刷新 target best_estimate（對齊 scout pursuit）+ 自配 timeout + target 死偵測。
func _tick_envoy(state: WorldState, envoy: TeamData, merge_queue: Array) -> void:
	if state.teams.get(envoy.parent_team_id) == null:   # 母隊已亡 → 脫離成獨立（非 zombie）
		_recall_envoy(state, envoy)
		return
	var target_id: int = envoy.order_target_id
	var target: TeamData = state.teams.get(target_id)
	if target == null:   # 目標已滅 → 提案落空，信使歸隊
		Probe.bump("envoy.target_dead")
		_recall_envoy(state, envoy)
		return
	var budget: int = int(envoy.task_extra_data.get("timeout", 2 * WorldState.TICKS_PER_DAY))
	if state.world.current_tick - envoy.task_start_tick > budget:
		Probe.bump("envoy.timeout")
		_recall_envoy(state, envoy)
		return
	# 追蹤刷新：攔截預測（朝 target 移動方向提前，破 pursuit-lag 永 1 格差）+ best_estimate fallback。
	# 對齊 _refresh_attack_pursuit（攻擊追擊 land combat 同機制）：可見且動→lead，靜/不可見→最後已知位。
	# F1 感知鐵律：缺 belief → sentinel (-1,-1)（禁默認 live）。無 belief 位 → 不用 (-1,-1) 當 move（保持現 move_target=pursuit-only，
	# 下 tick timeout/recall 承接），非瞎追 live 真位。
	# ★Slice D envoy lockstep：predict_intercept 已 belief-gate（可見→攔截/live、斷視線→belief last-seen、
	# 無 belief→sentinel (-1,-1)）。★別靠 `!= target.tile_pos` 判 fallback（新 sentinel 會誤過→誤寫 (-1,-1) 進
	# move_target 繞 belief-fallback）→ 改明確 sentinel 判：非 (-1,-1) 才設（攔截 or belief last-seen 位）。
	var predicted: Vector2i = PathSystem.predict_intercept(state, envoy, target)
	if predicted != Vector2i(-1, -1):
		envoy.move_target = predicted   # 攔截預測 or belief last-seen 位（predict_intercept 已 belief-gate）
	# else: 無 belief 位 → 保持現 move_target（不設 (-1,-1)/live），下 tick timeout/recall 承接

# 信使歸隊：釋放 task + 朝母隊移動 → 到母格 try_merge_back（復用 merge）。母隊 pending 靠自身 timeout 清。
func _recall_envoy(state: WorldState, envoy: TeamData) -> void:
	TaskArbiter.release(envoy)   # → IDLE, move_target=-1
	envoy.task_reason = "envoy_recall"
	var parent: TeamData = state.teams.get(envoy.parent_team_id)
	if parent != null:
		envoy.move_target = parent.tile_pos   # 下 tick _decide_subteam 路由回家/併回
	else:
		state.detach_subteam(envoy)            # 母隊已亡 → 脫離成獨立（正常 AI 接手，非 zombie）
		state.remove_tag(envoy, TeamData.TAG_SUBTEAM, "envoy_orphan")

# ★資訊網 S-herald：求援信使 tick——朝施助者 belief-pos 走；co-located→deposit 母隊 need（食糧買單）訊進
# 施助者 team_known（honest intra-faction）→ 領主經傳到的 belief 得知子民餓 → distribute 匹配。timeout/target 亡→recall。
func _tick_help_herald(state: WorldState, herald: TeamData, merge_queue: Array) -> void:
	if state.teams.get(herald.parent_team_id) == null:
		_recall_envoy(state, herald); return
	var target_id: int = herald.order_target_id
	var target: TeamData = state.teams.get(target_id)
	if target == null:
		Probe.bump("help.target_dead"); _recall_envoy(state, herald); return
	var budget: int = int(herald.task_extra_data.get("timeout", 2 * WorldState.TICKS_PER_DAY))
	if state.world.current_tick - herald.task_start_tick > budget:
		Probe.bump("help.timeout"); _recall_envoy(state, herald); return
	# 抵達施助者（co-located）→ deposit need 訊 → 完成 recall。
	if herald.tile_pos == target.tile_pos:
		_deposit_help_need(state, int(herald.task_extra_data.get("help_origin", -1)), target)
		Probe.bump("help.delivered")
		_recall_envoy(state, herald); return
	# 追蹤刷新（同 _tick_envoy：belief-gate predict_intercept、無 belief→保持現 move_target）。
	var predicted: Vector2i = PathSystem.predict_intercept(state, herald, target)
	if predicted != Vector2i(-1, -1):
		herald.move_target = predicted


# ★資訊網 S-scout：斥候 tick——朝子民 belief-pos 走；co-located→查得子民 need（食糧買單）帶回領主 team_known
# + 刷新領主對子民 belief（firsthand fresh）→ 領主 received_buy_orders 得子民 need（active 版症1 解）。timeout→recall。
func _tick_info_scout(state: WorldState, scout: TeamData, merge_queue: Array) -> void:
	var mother: TeamData = state.teams.get(scout.parent_team_id)
	if mother == null:
		_recall_envoy(state, scout); return
	var target_id: int = scout.order_target_id
	var target: TeamData = state.teams.get(target_id)
	if target == null:
		Probe.bump("scout.target_dead"); _recall_envoy(state, scout); return
	var budget: int = int(scout.task_extra_data.get("timeout", 2 * WorldState.TICKS_PER_DAY))
	if state.world.current_tick - scout.task_start_tick > budget:
		Probe.bump("scout.timeout"); _recall_envoy(state, scout); return
	# 抵達子民（co-located）→ 查得 need + 刷新領主 belief → recall。
	if scout.tile_pos == target.tile_pos:
		# 刷新領主對子民 belief（firsthand fresh：scout 是領主 agent 親見）
		BeliefSystem.record_claim(state, mother.team_id, target_id, mother.team_id, "親見",
			{"tile_pos": target.tile_pos}, 1.0, false)
		_deposit_help_need(state, target_id, mother)   # 帶子民 food 買單回領主 team_known（同 herald deposit 機制）
		Probe.bump("scout.info_returned")
		_recall_envoy(state, scout); return
	var predicted: Vector2i = PathSystem.predict_intercept(state, scout, target)
	if predicted != Vector2i(-1, -1):
		scout.move_target = predicted

# ★資訊網 S-herald：把 need-origin 隊的食糧買單 deposit 進施助者 team_known（honest firsthand intra-faction，
# 感知鐵律：信使物理送達才傳；無買單→送最近 runway 缺口 proxy 訊）。→ 領主 received_buy_orders 得知子民 need。
func _deposit_help_need(state: WorldState, origin_id: int, helper: TeamData) -> void:
	var origin: TeamData = state.teams.get(origin_id)
	if origin == null: return
	if not state.team_known.has(helper.team_id):
		state.team_known[helper.team_id] = []
	# 已知 order_id（去重）
	var known: Dictionary = {}
	for m in state.team_known[helper.team_id]:
		if m.type == "order_buy": known[int(m.params.get("order_id", -1))] = true
	# deposit origin 的 food 買單（active_orders 權威）；無則不 deposit（無正式 need 訊）。
	for o in origin.active_orders:
		if String(o.get("kind", "")) != "buy" or String(o.get("res", "")) != "food":
			continue
		var oid: int = int(o.get("order_id", -1))
		if known.has(oid): continue
		var msg := MessageData.new()
		msg.id = state.global_messages.size(); msg.type = "order_buy"
		msg.origin_team_id = origin_id; msg.origin_tick = state.world.current_tick; msg.strength = 1.0
		msg.is_distorted = false   # 信使親送 intra-faction = honest
		msg.params = {"order_id": oid, "res": "food", "qty": int(o.get("qty_remaining", 0)),
			"origin_team": origin_id, "origin_pos": origin.tile_pos, "expire_tick": int(o.get("expire_tick", 0))}
		state.global_messages.append(msg)
		state.team_known[helper.team_id].append(msg)
		known[oid] = true
		Probe.bump("help.need_deposited")

# ──────── ★資訊網 Part2 (a) side-action：求援/偵察 平行 side-dispatch（脫主 argmax、mini-util cost-benefit）────────
# de-patch 精神（同勞力池 facility 脫 current_task）：派 1 anon 跑腿=平行 side-action（派信使≠放棄自救）。
# ★calibration-anchor（R² ①、同 idle-labor PER_HAND 紀律）：RELIEF_EXPECT/ANON_COST 皆 DERIVED 自食物常數、非 invent fire-crank。
const INFO_RELIEF_EXPECT: float = DecisionTerms.DESPERATION_DAYS * ResourceSystem.FOOD_PER_PERSON_PER_DAY   # 求助期望紓困≈買回到絕境門檻的食物價值（3×0.8=2.4）
const INFO_ANON_COST: float = ResourceSystem.FOOD_PER_PERSON_PER_DAY   # 1 anon 邊際成本≈其每日食耗/產出 proxy（0.8）
# ★scope 硬限：只 herald/scout 兩條 1-anon 資訊跑腿（非泛化 side-task 框架繞 argmax）。

const INFO_DISPATCH_CADENCE: int = WorldState.TICKS_PER_DAY   # 求援/偵察=慢策略,每日評一次即可(per-team 錯開防每 tick O(teams²) 掃)

func info_side_dispatch_all(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null or team.parent_team_id != -1 or team.combat_target != -1:
			continue   # 子隊/戰鬥中不 side-dispatch
		# ★perf：cadence-gate（per-team 錯開）——side-dispatch 每日評一次非每 tick（scout O(teams) 掃 per leader 昂貴）。
		if state.world.current_tick < team.info_eval_next_tick:
			continue
		team.info_eval_next_tick = state.world.current_tick + INFO_DISPATCH_CADENCE
		_try_herald_side(state, team)
		_try_scout_side(state, team)

# 求援 side：餓 + 知施助者 + mini-util>0（cost-benefit）→ 派 anon 信使（不佔主任務、平行）。
func _try_herald_side(state: WorldState, team: TeamData) -> void:
	if team.population < 2:
		return   # can_send_herald（pop 1 自己走）
	if _has_inflight_info(state, team, "help_call"):
		return   # throttle 一隊一 in-flight herald
	var food_days: float = ResourceSystem.effective_food(state, team) \
		/ maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	var severity: float = clampf((DecisionTerms.DESPERATION_DAYS - food_days) / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	if severity <= 0.0:
		return   # 不絕境不求援（need-gated）
	var tgt: Dictionary = _resolve_help_target(state, team)
	if int(tgt["id"]) == -1:
		return   # 無施助者（belief/名冊皆無）
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var mini: float = severity * _help_pmult(lv) * INFO_RELIEF_EXPECT - INFO_ANON_COST
	if Probe.enabled: Probe.note("help.mini_util", mini)
	if mini <= 0.0:
		return   # cost-benefit 不划算（傲慢撐/輕度餓不值 1 anon）
	var dist: int = _hex_dist(team.tile_pos, tgt["pos"])
	var hid: int = SubteamSystem.new().dispatch_anon_messenger(state, team.team_id,
		TeamData.TASK_HERALD, "help_call", tgt["pos"], int(tgt["id"]),
		{"help_origin": team.team_id, "timeout": _founding_timeout(dist)})
	if hid != -1:
		_equip_envoy_mounts(state, team, state.teams[hid])
		Probe.bump("help.herald_dispatched")

# 偵察 side：領主 + 子民 belief 陳舊 + mini-util>0 → 派 anon 斥候（亦 anon 化、不再 named subteam）。
func _try_scout_side(state: WorldState, team: TeamData) -> void:
	if team.population < 2:
		return
	var f = state.factions.get(team.faction_id)
	if f == null or f.leader_team_id != team.team_id:
		return   # 只領主探子民
	if _has_inflight_info(state, team, "info_scout"):
		return   # throttle 一隊一 in-flight scout
	var tgt: Dictionary = _resolve_scout_target(state, team)
	if int(tgt["id"]) == -1 or float(tgt["staleness"]) <= 0.0:
		return
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var mini: float = float(tgt["staleness"]) * _scout_pmult(lv) * INFO_RELIEF_EXPECT - INFO_ANON_COST
	if Probe.enabled: Probe.note("scout.mini_util", mini)
	if mini <= 0.0:
		return
	var dist: int = _hex_dist(team.tile_pos, tgt["pos"])
	var sid: int = SubteamSystem.new().dispatch_anon_messenger(state, team.team_id,
		TeamData.TASK_SCOUT, "info_scout", tgt["pos"], int(tgt["id"]),
		{"scout_mother": team.team_id, "timeout": _founding_timeout(dist)})
	if sid != -1:
		_equip_envoy_mounts(state, team, state.teams[sid])
		Probe.bump("scout.dispatched")

# in-flight throttle：已有 task_reason 的 side-messenger 子隊 → 不重派（鏡射 convoy 一隊一）。
func _has_inflight_info(state: WorldState, team: TeamData, reason: String) -> bool:
	for tid in team.subteam_ids:
		var s: TeamData = state.teams.get(tid)
		if s != null and s.task_reason == reason:
			return true
	return false

# 求助對象解析（fresh belief 優先→名冊 fallback，同 ctx 舊邏輯；side-dispatch 自足）。
func _resolve_help_target(state: WorldState, team: TeamData) -> Dictionary:
	if team.faction_id == -1:
		return {"id": -1, "pos": Vector2i(-1, -1)}
	var f = state.factions.get(team.faction_id)
	if f == null or f.leader_team_id == -1 or f.leader_team_id == team.team_id:
		return {"id": -1, "pos": Vector2i(-1, -1)}
	var lid: int = f.leader_team_id
	var pos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, lid).get("tile_pos", Vector2i(-1, -1))
	if pos == Vector2i(-1, -1):
		pos = _faction_roster_pos(state, team, lid)
	return {"id": (lid if pos != Vector2i(-1, -1) else -1), "pos": pos}

# 待查子民解析（領主對自家最陳舊 belief 子民；fresh belief age→norm、無 belief→名冊 staleness=1）。
func _resolve_scout_target(state: WorldState, team: TeamData) -> Dictionary:
	var best_id: int = -1; var best_pos: Vector2i = Vector2i(-1, -1); var best_st: float = 0.0
	var norm: float = float(BeliefSystem.SCOUT_TIMEOUT)
	for mid in state.teams:
		if mid == team.team_id: continue
		var mt: TeamData = state.teams[mid]
		if mt.faction_id != team.faction_id: continue
		var be: Dictionary = BeliefSystem.best_estimate(state, team.team_id, mid)
		var mpos = be.get("tile_pos", Vector2i(-1, -1))
		var st: float
		if mpos == Vector2i(-1, -1):
			mpos = _faction_roster_pos(state, team, mid)
			if mpos == Vector2i(-1, -1): continue
			st = 1.0
		else:
			st = clampf(float(state.world.current_tick - int(be.get("last_tick", 0))) / maxf(norm, 1.0), 0.0, 1.0)
		if st > best_st:
			best_st = st; best_id = mid; best_pos = mpos
	return {"id": best_id, "pos": best_pos, "staleness": best_st}

# 人格 mult（鏡射 terms help_drive/scout_drive；求援/偵察脫 argmax 後 side-dispatch 用）。
func _help_pmult(lv: Dictionary) -> float:
	return clampf((0.4 + float(lv.get("求生欲", 0.5)) * 0.6) \
		* (1.0 - float(lv.get("野心", 0.5)) * DecisionTerms.HELP_PRIDE_SUPPRESS) \
		* (0.5 + float(lv.get("義氣", 0.5)) * 0.5), 0.0, 1.5)

func _scout_pmult(lv: Dictionary) -> float:
	return clampf((0.4 + float(lv.get("統領", 0.5)) * 0.6) \
		* (1.0 - float(lv.get("野心", 0.5)) * DecisionTerms.SCOUT_AMBITION_NEGLECT), 0.0, 1.5)

# ──────── 任務指派 ────────

func _assign_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	if leader_team == null or leader_team.combat_target != -1:
		return
	# 生存 sticky：leader 在 survival task 中不蓋過（仍跑 member 指派）
	if leader_team.current_task in SURVIVAL_TASKS:
		var _tas: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
		_assign_member_tasks(state, f)
		if SimRunner.phase_timing: _fai_pht("assign.members", _tas)
		return

	var _ta: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	# G-09：檢查 player_commanded_task（loyalty 門檻）
	for tid_cmd in f.member_team_ids:
		var t_cmd: TeamData = state.teams.get(tid_cmd)
		if t_cmd == null or t_cmd.player_commanded_task.is_empty(): continue
		var leader_cmd: PersonData = state.persons.get(t_cmd.leader_id)
		var loyalty_cmd: float = leader_cmd.loyalty if leader_cmd else 0.5
		if loyalty_cmd >= 0.4:
			TaskArbiter.try_set(state, t_cmd, t_cmd.player_commanded_task,
				t_cmd.move_target, TaskArbiter.PRIO_PLAYER, "player_command")
		else:
			UnrestBank.add(t_cmd, 1, "faction")
			print("[FactionAI] Team%d 抗拒玩家指令（loyalty=%.2f）" % [tid_cmd, loyalty_cmd])
	if SimRunner.phase_timing: _ta = _fai_pht("assign.player_cmd", _ta)

	# A2b：立國=結構性 lifecycle gate（非戰術 option，不入引擎；同 A2a 戰略足跡=leader/faction 決定）。
	if "立國" in f.goals:
		_declare_established(state, f, leader_team)
	if SimRunner.phase_timing: _ta = _fai_pht("assign.leader_lifecycle", _ta)
	# A2b：leader 隊戰術執行走統一引擎（取代 徵收/外交/攻擊/掠奪 手 cascade + note_bypass）。
	# 徵收/外交(faction_duty)+攻擊(faction_duty+intent_fit 加成)+貿易/囤貨/生產/駐守/survival/threat 全 rank_scored 競秤。
	# 立國(上)已 pre-empt；player_cmd(上)PRIO_PLAYER 已蓋。conquest scaffolding faction_id==-1 leader 不觸。
	_decide_unified(state, leader_team)
	if SimRunner.phase_timing: _ta = _fai_pht("assign.leader_unified", _ta)
	_assign_member_tasks(state, f)
	if SimRunner.phase_timing: _fai_pht("assign.members", _ta)

func _assign_member_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	for mid in f.member_team_ids:
		if mid == f.leader_team_id: continue
		var mt: TeamData = state.require_team(mid)
		# ★序6 subteam guard（現缺補上）：parent_team_id!=-1 = subteam → 走 loop2 _evaluate_subteam。
		# 不入成員 dispatch（防 loop1/loop2 雙寫同一 subteam）。
		if mt.parent_team_id != -1: continue
		if mt.combat_target != -1: continue          # 戰鬥覆蓋(全隊)
		if not mt.player_commanded_task.is_empty(): continue  # 玩家(全隊)
		# ── ★A2c-1：consolidate pre-gate 拆除（FA5 折入引擎「整併」option 競秤）──
		# ── ★序6 gate：全非-subteam 成員走引擎 macro（_decide_unified 每 cadence 重評，退 latch）──
		# 撕除舊 goal→task if/elif cascade（含 V2-cmd 徵收 shadow）；徵收/攻擊/掠奪/生產/貿易/生存
		# 引擎 rank_scored 競秤（tag 只影響 weight 非路徑）。★不動全域 uses_unified → 成員仍走 loop3
		# threat/preempt/survival scaffolding（序3.5 反龜縮保）。掠奪 option → 成員 raid 接回（縫#3 結清）。
		if SimRunner.phase_timing:
			var _tu: int = Time.get_ticks_usec()
			_decide_unified(state, mt)
			_fai_pht("member.unified", _tu)
		else:
			_decide_unified(state, mt)

# A2c-1：consolidate target 決策抽出（非 dispatch，供 DecisionContext.gather 算 consolidate_target_id）。
# 逐條件鏡射 _try_consolidate_merge:1421-1442（target 兩支）；回 absorber_id / leader_team_id / -1。
static func consolidate_target_of(state: WorldState, mt: TeamData, f) -> int:
	var fai := FactionAISystem.new()
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	var absorber_id: int = fai._find_absorber(state, mt, f)
	if absorber_id != -1:
		var mt_leader = state.persons.get(mt.leader_id)
		var mt_cmd: float = float(mt_leader.skills.get("統領", 0.0)) if mt_leader else 0.0
		var mt_cap: int = TeamData.pop_cap_from_leadership(mt_cmd)
		var small_b: bool = mt.population < int(float(mt_cap) * SMALL_TEAM_RATIO)
		var small_c: bool = float(mt.population) < float(state.teams[absorber_id].population) * SMALL_VS_LARGE
		if small_b and small_c:
			return absorber_id
	if "攻擊" in f.goals and leader_team != null:
		var d: int = fai._hex_dist(mt.tile_pos, leader_team.tile_pos)
		if d > 1 and d <= CONSOLIDATE_MAX_DIST:
			var ldr_leader = state.persons.get(leader_team.leader_id)
			var ldr_cmd: float = float(ldr_leader.skills.get("統領", 0.0)) if ldr_leader else 0.0
			var ldr_cap: int = TeamData.pop_cap_from_leadership(ldr_cmd) - leader_team.population
			if ldr_cap > 0:
				return f.leader_team_id
	return -1

# ──────── 統一決策引擎切片 seam ────────
# 切片 = 商隊 + 生產 tag 隊：macro 決策走 DecisionEngine（舊 member hoist / solo 生產者跳過，單一 owner）。
# 非切片隊（軍隊/統領/宗教…）舊系統原封不動（零影響 = de-risk）。後續域遷入逐擴 tag。
func uses_unified(team: TeamData) -> bool:
	return team.tags.has(TeamData.TAG_MERCHANT) or team.tags.has(TeamData.TAG_PRODUCE)

# 切片隊走引擎決策 → 設 task（取代舊 member/solo 派工）。
func _decide_unified(state: WorldState, team: TeamData) -> void:
	# ⑦ 統一重評 gate（修每小時過頻）：IDLE/stuck/crisis/命令新仍即時，否則 cadence 節流。
	if not _should_reeval(state, team):
		return
	team.decision_eval_next_tick = state.world.current_tick \
		+ (DECISION_CADENCE / 4 if _decision_crisis(state, team) else DECISION_CADENCE)
	team.last_decision_tick = state.world.current_tick   # 命令 freshness 比對基準（截斷 directive_fresh 死循環）
	_detect_survival_stall(state, team)   # ② 絕境階梯 DETECT（單一源全 5 路決策 entry 之一：latch 隊 reason=unified 在此）
	if team.current_task in SURVIVAL_TASKS and team.current_task != TeamData.TASK_IDLE:
		pass   # 生存 sticky 仍尊重；引擎的 survival option 會自然續（承諾）
	var _tr: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	var ranked: Array = DecisionEngine.rank_scored(state, team)
	ranked = DecisionEngine.reorder_same_need_first(ranked)   # 同需求 fallthrough：rank[0]不可派→同層次佳(非跨層落生產)
	if SimRunner.phase_timing: _tr = _fai_pht("unified.rank", _tr)
	# 征服名實探針（純觀測）：solo_intent=征服 的隊在此實際 winner 分類（想征服 vs 做掠奪）。
	var _conq: bool = Probe.enabled and _solo_type(team) == "征服"
	if _conq: Probe.bump("conq.intent")
	# 序6 probe 遷移：faction 成員征服 dispatch（舊 hand-cascade conq.member_atk_* 已刪 → 引擎路重掛）。
	# eligible = 成員 + faction 攻擊令 intent=征服 + 攻擊 option 在 ranked（可攻路徑存在，供 sufficiency_bed 征服「想=做」）。
	var _fac = state.factions.get(team.faction_id) if team.faction_id != -1 else null
	var _mconq: bool = Probe.enabled and _fac != null \
		and String((_fac.goal_drivers.get("攻擊", {}) as Dictionary).get("intent", "")) == "征服"
	if _mconq:
		for _e in ranked:
			if _e["opt"] == "攻擊":
				Probe.bump("conq.member_atk_eligible"); break
	for e in ranked:
		var opt: String = e["opt"]
		# means-end 統一攻擊：征服 intent 驅動的攻擊 → dispatch-time scout-verify scaffolding
		# （_commit_conquest_attack：不確定→斥候、confident→打；削敵→俘虜→守乾淨鏈）。序5 dissolve：
		# cascade 決策已溶進 攻擊 option（intent_fit 征服 × readiness/富prey）→ 此處只走 scaffolding。
		# faction directive 攻擊維持指定 target 路徑（非征服 intent，不入此分支）。
		if opt == "攻擊" and _solo_type(team) == "征服" and team.faction_id == -1:
			if _is_prosperity_candidate(state, team):
				var _pid: int = int(DecisionOptions.to_task(state, team, opt).get("combat_target", -1))
				SpecimenTracer.capture_decision(state, team, opt, TeamData.TASK_ATTACK, team.tile_pos)
				var _tp: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
				_commit_conquest_attack(state, team, _pid)
				if SimRunner.phase_timing: _fai_pht("unified.prosp", _tp)
				# 憲法（融合非刪）：引擎選 攻擊 → 驗證攻擊路徑（斥候/攻擊/prey 消失暫緩）獨佔此決策。
				# 舊 `continue` 於 scaffolding 未派時落次佳 option（建設…）＝dispatch 層替 NPC 否決統一秤 #1，
				# 已撕除；未派＝暫緩本 cadence，下輪重評（prey 真消失→攻擊 option 自然退榜，秤選次佳非 dispatch 替換）。
				return
			continue   # 非候選（子隊=非自主 leader）→ 試次佳
		var _t2: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
		# ★means-end S2：goal frontier candidate 用其 cand.to_task（label 非 static REGISTRY key）；static option 走既有。
		var td: Dictionary = (e["cand"]["to_task"] as Dictionary) if e.has("cand") else DecisionOptions.to_task(state, team, opt)
		if SimRunner.phase_timing: _fai_pht("unified.to_task", _t2)
		# ★means-end S5 委派：delegate candidate 贏 → 派子隊執行 action，母隊留守（本 cadence 畢）；派失敗→試次佳。
		if td.get("delegate", false):
			if _dispatch_goal_delegate(state, team, td):
				team.current_option = String(e["opt"])   # 承諾追蹤(label:delegate)
				return
			continue
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue   # 不可派 → 試次佳(修凍死)
		# 投靠玩家：走 forced_event（玩家決定收留），不自動 merge（對稱 + UX）
		if opt == "併入" and td.has("social_target"):
			var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
			if pp != null and int(td["social_target"]) == pp.team_id:
				if _maybe_request_join_player(state, team):
					return
		team.current_option = opt   # 承諾追蹤實際派出
		if opt == "返家補給": Probe.bump("g1.restock_chosen")
		elif opt in ["覓食", "survival"]: Probe.bump("g1.engine_survival")
		elif opt == "佔村": Probe.bump("occupy.dispatch")
		# threat-oracle S1（seam#1 finding5）：統一路 threat option commit tap（收斂前補盲點；
		# 現況唯一 threat.dispatch tap 在 preempt loop :405，統一隊 rank_scored 選中 threat option=無 tap）。
		if Probe.enabled and opt in ["備戰", "迎戰", "求和"]: Probe.bump("threat.dispatch." + opt)
		# 序6 probe 遷移：成員征服攻擊實派 + 徵收實派（舊 hand-cascade 探針已刪 → 引擎路重掛，供驗魂）。
		if _mconq and opt == "攻擊": Probe.bump("conq.member_atk_dispatch")
		if team.faction_id != -1 and Probe.enabled and opt == "徵收": Probe.bump("tribute.dispatch.member")
		# full_probe（診斷）：fold 路 merge 實派 + merge-applicable 隊 option 去向（B 鐵證：該併卻選別的）。
		if opt == "併入": Probe.bump("merge.consolidate_dispatch")
		if Probe.enabled and opt == "吸納": Probe.bump("absorb.dispatch")   # §HOW-7 強方吸納實派
		if Probe.enabled and team.faction_id != -1 and team.parent_team_id == -1:
			var _fc2 = state.factions.get(team.faction_id)
			if _fc2 != null and team.team_id != _fc2.leader_team_id and consolidate_target_of(state, team, _fc2) != -1:
				Probe.bump("merge_appl.total")
				Probe.bump("merge_appl.chose_併入" if opt == "併入" else "merge_appl.chose_other")
				# DIAG C1：有 target 隊的食壓分布（證 consolidate-eligible 是否恆絕境<3，band[3,6)撲空）
				var _fd: float = ResourceSystem.effective_food(state, team) \
					/ maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
				if _fd < DecisionTerms.DESPERATION_DAYS: Probe.bump("merge_appl.food_lt3")
				elif _fd < 6.0: Probe.bump("merge_appl.food_3to6")   # gate-ok: probe bookkeeping (merge_appl food bucket，非決策)
				else: Probe.bump("merge_appl.food_ge6")
		if _conq: _probe_conq_winner(opt, ranked)   # winner 分類 + util 排序根
		# ★threat-oracle S3：threat 反應(備戰/迎戰/求和)commit @PRIO_THREAT 70(finding3 黏性——收斂後不被
		# 高值經濟 @50 換掉；task_arbiter self-replace 已擴認 70 同層 threat option 可換 迎戰→求和)。其餘 @50。
		# ★絕境經濟 ① 單一源：option→priority 收 DecisionOptions.priority_for（survival 保序不看 dispatch 路）。
		var _set_ok: bool = TaskArbiter.try_set(state, team, td["task"], tgt, DecisionOptions.priority_for(opt), "unified")
		if _set_ok: _stamp_survival_commit(state, team, opt)   # ② 蓋章 committed survival option baseline（單一源全 5 路之一）
		SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "committed" if _set_ok else "try_set_noop")   # Fix2a：挪 try_set 後帶真 result（修虛高 committed）
		if _set_ok and td["task"] == TeamData.TASK_FLEE: team.flee_from_pos = _flee_threat_pos(state, team)   # flee 位移根治：設逃離位
		if Probe.enabled and opt == "併入":   # DIAG：整併 try_set 成敗（priority-gate 擋？）
			Probe.bump("merge.set_ok" if _set_ok else "merge.set_fail")
		# 漏斗站4探針（純觀測）：unified 路徑 TRADE 實派計數（分 opt）。
		# timeout 起算已改讀 try_set 蓋章的 task_start_tick（單源），此路不需另外蓋章。
		if _set_ok and td["task"] == TeamData.TASK_TRADE:
			Probe.bump("trade.dispatch.unified_" + opt)
		# 掠奪/攻擊 設 combat_target 才交戰；投靠/乞食 設 social_target（社交 resolver 讀）
		if td.has("combat_target"):
			state.set_combat_target(team, int(td["combat_target"]))
		if td.has("social_target"):
			state.set_social_target(team, int(td["social_target"]))
		if opt == "攻擊": _probe_vendetta_dispatch(state, team)   # 序4：純血仇攻擊驗魂
		# A2b 守衛 A：leader 隊經引擎發起攻擊計數（稀有非零；成員不計）。
		if _set_ok and opt == "攻擊" and team.faction_id != -1 \
				and state.factions.has(team.faction_id) \
				and state.factions[team.faction_id].leader_team_id == team.team_id:
			Probe.bump("a2b.leader_attack")
		# A2b 守衛 B：leader 遠距徵收 dispatch → 記 payer，settle 對帳（證遠距貢真收到）。
		if _set_ok and opt == "徵收" and team.faction_id != -1 \
				and state.factions.has(team.faction_id) \
				and state.factions[team.faction_id].leader_team_id == team.team_id:
			var _rt: int = _richest_member(state, state.factions[team.faction_id])
			if _rt != -1 and _rt != team.team_id \
					and _hex_dist(team.tile_pos, state.teams[_rt].tile_pos) > DISPATCH_DIST_THRESHOLD:   # gate-ok: probe bookkeeping: DISPATCH_DIST_THRESHOLD 記帳非決策
				Probe.bump("a2b.remote_tribute_dispatch")
				_a2b_remote_tribute_payers[_rt] = true
		# 融合 threat：unified 隊選 迎戰/求和 時亦接 aux target（prosperity/order），與 non-unified 路徑一致。
		_wire_threat_task(team, td)
		# 手聽腦單點同-tick 探針（純觀測，env-gated 預設關 → byte-identical）：敲定 winner + try_set + 副作用後、
		# return 前，同 state 比腦(ranked[0]/winner)vs 手(current_task)。
		HandBrainProbe.capture(state, team, "unified", String(ranked[0]["opt"]), opt, td["task"], _set_ok)
		return
	# 全不可派 → 保持現行(no-op)
	if _conq: Probe.bump("conq.winner_none")   # 征服 intent 但無可派 winner

# 征服名實探針：分類 _decide_unified 的實際 winner + 記 util 排序根（no-op unless enabled）。
# 掠奪 = 機會搶資源（非奪地/俘虜）；攻擊 = faction directive（獨立隊不觸）；其餘 = other。
# prosperity-attack 不是 _decide_unified option（分離 gate 路徑，跑在此之後）→ winner_prosperity ≈ 0
# 由 construction，恰證「_decide_unified 無征服 option、掠奪搶排序」= 名實斷點根。
func _probe_conq_winner(winner_opt: String, ranked: Array) -> void:
	match winner_opt:
		"掠奪": Probe.bump("conq.winner_loot")
		"攻擊": Probe.bump("conq.winner_prosperity")
		_:      Probe.bump("conq.winner_other")
	# util 排序根：掠奪 option util vs 最佳非掠奪 option util（掠奪領先多少 = 搶排序證據）。
	var loot_u: float = 0.0
	var best_other_u: float = 0.0
	var has_loot: bool = false
	var has_other: bool = false
	for e in ranked:
		if String(e["opt"]) == "掠奪":
			loot_u = float(e["u"]); has_loot = true
		else:
			best_other_u = maxf(best_other_u, float(e["u"])) if has_other else float(e["u"])
			has_other = true
	if has_loot:
		Probe.note("conq.loot_util", loot_u)
		if has_other:
			Probe.note("conq.loot_lead", loot_u - best_other_u)   # 掠奪領先次佳的最大幅度

func _find_absorber(state: WorldState, mt: TeamData, f) -> int:
	var best_id: int = -1
	var best_score: float = -9999.0   # 名聲磁鐵 §3：偏好高 protector_rep host（主觀 mt 視角）；dist 次序 tiebreak
	for tid in f.member_team_ids:
		if tid == mt.team_id:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null or t.combat_target != -1:
			continue
		var t_leader = state.persons.get(t.leader_id)
		var t_cmd: float = float(t_leader.skills.get("統領", 0.0)) if t_leader else 0.0
		var t_cap: int = TeamData.pop_cap_from_leadership(t_cmd) - t.population
		if t_cap <= 0:
			continue
		# S-A 靶A 餵養 gate#1（防搬餓）：吸附者須有糧 + 併後合隊真能撐 ABSORBER_MIN_SURVIVE_DAYS。
		# 不過=不選（非把餓稀釋進更大隊）。consolidate_target_of 同呼此路→context target 一致。
		var ef_t: float = ResourceSystem.effective_food(state, t)
		if ef_t <= 0.0:
			continue   # 吸附者自身無糧→無餵養能力
		var ef_mt: float = ResourceSystem.effective_food(state, mt)
		var combined_days: float = (ef_t + ef_mt) \
			/ maxf(float(t.population + mt.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		if combined_days < ABSORBER_MIN_SURVIVE_DAYS:
			continue   # 併後撐不住→不選
		var d: int = _hex_dist(mt.tile_pos, t.tile_pos)
		if d <= 1 or d > CONSOLIDATE_MAX_DIST:
			continue
		# 名聲磁鐵 §3：score = protector_rep 主導（避投奔強暴君）− dist 懲罰（近者次選）。
		var score: float = mt.get_protector_rep(tid) * 10.0 - float(d)
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

# ──────── 子團自主 AI ────────

func _evaluate_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	# ②a 信使外交：envoy_proposal 子隊追蹤刷新 target best_estimate + 自配 timeout（新 invariant 自守）
	if sub.current_task == TeamData.TASK_HERALD and sub.task_reason == "envoy_proposal":
		_tick_envoy(state, sub, merge_queue)
		return
	# ★資訊網 S-herald：求援信使子隊（belief-pos travel→抵達 deposit need 訊→recall）。
	if sub.current_task == TeamData.TASK_HERALD and sub.task_reason == "help_call":
		_tick_help_herald(state, sub, merge_queue)
		return
	# ★資訊網 S-scout：偵察斥候子隊（belief-pos travel→抵達查子民 need 帶回領主→recall）。
	if sub.current_task == TeamData.TASK_SCOUT and sub.task_reason == "info_scout":
		_tick_info_scout(state, sub, merge_queue)
		return
	if sub.current_task == TeamData.TASK_BUILD:
		return  # C: 施工中（建設），不打斷、不召回
	# S7 建造/升級/擴建子隊在途：TASK_CONSTRUCT/UPGRADE/EXPAND = 正前往目標格；不得紀律檢查或召回
	# 例外：抵達後（move_target==-1）長時間仍未轉 TASK_BUILD → start_build 必曾失敗 → zombie 恢復
	if sub.current_task in [TeamData.TASK_CONSTRUCT, TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND]:
		if sub.move_target == Vector2i(-1, -1):
			# 已到目標但未轉 BUILD：給一次重試，再逾時才 release
			const CONSTRUCT_TRANSIT_TIMEOUT: int = 10 * WorldState.TICKS_PER_DAY  # TEST VALUE — 10 天
			if state.world.current_tick - sub.task_start_tick > CONSTRUCT_TRANSIT_TIMEOUT:
				print("[FactionAI] CONSTRUCT 子隊 Team%d 抵達後逾時未開工 → 強制 release/merge" % sub.team_id)
				TaskArbiter.release(sub)
				merge_queue.append(sub.team_id)
		return
	# ★後勤 SLICE A：convoy 各階段專屬分支（防 generic fallback :1753 攔截半路棄貨；子隊 sticky 免 persist-hold）。
	if sub.current_task == TeamData.TASK_CONVOY:
		_tick_convoy(state, sub, merge_queue)
		return
	if sub.current_task == TeamData.TASK_SETTLE:
		# 抵達自家 faction outpost → 就地安頓（無需 co-located team；獨自抵達即轉居民）
		# 未到則保持 移動/安頓 task，不進 merge_queue（避免被召回母團）
		var settle_tile: HexTileData = state.world.tiles.get(
			sub.tile_pos.x * 1000 + sub.tile_pos.y)
		if settle_tile != null and settle_tile.outpost_owner != -1:
			var o: TeamData = state.teams.get(settle_tile.outpost_owner)
			if o != null and o.faction_id == sub.faction_id:
				InteractionSystem.new()._convert_to_resident(state, sub)
		return
	if sub.current_task == TeamData.TASK_ESCORT:
		_update_escort(state, sub)
		_check_discipline(state, sub)
		return
	if _check_discipline(state, sub):
		return
	# 抵達目標格 → 歸建（lifecycle，不進引擎/probe）
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
		return
	# idle → 引擎決策（cadence-gated；A2a 取代 _evaluate_idle_subteam 手 argmax + _check_deviation randf）
	if sub.current_task == TeamData.TASK_IDLE:
		_decide_subteam(state, sub, merge_queue)
	# active-transit 已派 task → sticky（執行命令中 duty 壓制投機＝任務優先；到達自歸建 / discipline 自 detach）

# ★後勤 SLICE A（spec §3）：convoy 生命週期 OUTBOUND→DELIVER→RETURN（porter 物理送貨結買單）。純算術零 RNG。
# FETCH 在 dispatch 已撥載；此處 OUTBOUND(travel)→抵市場 DELIVER(_resolve_market_at_outpost=visitor_sell deposit+
# settle buy 單→order_fulfilled++)→掉頭 RETURN→到家歸建釋放 pop（merge_back，非 settle/整隊消失）。
func _tick_convoy(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	var xd: Dictionary = sub.task_extra_data
	var phase: String = String(xd.get("convoy_phase", "OUTBOUND"))
	var market_pos: Vector2i = xd.get("market_pos", Vector2i(-1, -1))
	var home_pos: Vector2i = xd.get("home_pos", Vector2i(-1, -1))
	if phase == "OUTBOUND":
		if sub.move_target != Vector2i(-1, -1):
			return   # 還在前往 demand 市場（sticky，不打斷不召回）
		# 抵達 demand 市場 → DELIVER：visitor_sell deposit cargo 入 buyer tile + settle buy 單 → fulfilled++
		var tile: HexTileData = state.world.tiles.get(market_pos.x * 1000 + market_pos.y)
		if tile != null:
			var res: String = String(xd.get("cargo_res", ""))
			var before: float = float(sub.resources.get(res, 0))
			# ★DELIVER 成交結果 instrument（分清真 settle vs bail 分因；deliver_bail_* 讀 visitor_sell 的 sell_* bail 差量）。
			var bail_before: Dictionary = _convoy_sell_bail_snapshot()
			var dealt: bool = InteractionSystem.new()._resolve_market_at_outpost(state, sub, tile)
			Probe.bump("convoy.deliver")   # 抵達市場（DELIVER 嘗試）
			if Probe.enabled:
				Probe.add_amount("convoy.cargo_delivered", maxf(before - float(sub.resources.get(res, 0)), 0.0))
				var reason: String = "settled" if dealt else _convoy_bail_reason(bail_before)
				if dealt:
					Probe.bump("convoy.deliver_settled")   # ★真成交 fulfilled++（make-or-break 真值）
				else:
					Probe.bump("convoy.deliver_bail_" + reason)
				# ★per-convoy DELIVER trajectory（定 bail 根:載 0 vs 載了丟 vs 買方飽和；+全 sell bail delta 真因，不只 first-in-list）
				Probe.bump_sample("convoy.deliver_traj", {
					"porter": sub.team_id, "res": res, "loaded": float(xd.get("cargo_qty", 0)),
					"material_at_deliver": before, "sold": maxf(before - float(sub.resources.get(res, 0)), 0.0),
					"result": reason, "bail_delta": _convoy_bail_delta(bail_before),
				}, 16)
		xd["convoy_phase"] = "RETURN"
		sub.move_target = home_pos   # 掉頭回家
		sub.task_start_tick = state.world.current_tick
		return
	if phase == "RETURN":
		if sub.move_target != Vector2i(-1, -1):
			return   # 還在回程
		# 到家歸建 → 釋放抽出 pop（merge_back，非 settle）。convoy.return telemetry 在真 merge 點(try_merge_back)認
		# convoy_phase 統一計（對齊 [Merge]；porter 可能經 CONVOY 或被 release→IDLE 併回路，皆準確）。
		merge_queue.append(sub.team_id)
		return
	# 未知 phase 保險：歸建
	merge_queue.append(sub.team_id)

# ★convoy DELIVER bail 分因（讀 _market_visitor_sell 的 sell_* bail 差量歸因 convoy，不改 interaction）。
const _CONVOY_SELL_BAILS: Array = ["sell_no_surplus", "sell_owner_no_coin", "sell_no_price",
	"sell_zero_qty", "sell_storage_full", "sell_ownerless", "sell_owner_cant_afford", "no_board_order"]
func _convoy_sell_bail_snapshot() -> Dictionary:
	var s: Dictionary = {}
	for b in _CONVOY_SELL_BAILS:
		s[b] = int(Probe.counts.get("trade.market_bail." + b, 0))
	return s
func _convoy_bail_reason(before: Dictionary) -> String:
	for b in _CONVOY_SELL_BAILS:
		if int(Probe.counts.get("trade.market_bail." + b, 0)) > int(before.get(b, 0)):
			return b   # DELIVER 期間升的 sell bail = 本 convoy 失敗因
	return "other"   # 無 sell bail 升（板上無此 res buy 單/其他）
# ★全 sell bail delta（DELIVER 期間所有升的 sell bail，非只 first-in-list——真因 disambiguate:買方飽和 vs porter surplus）
func _convoy_bail_delta(before: Dictionary) -> Dictionary:
	var d: Dictionary = {}
	for b in _CONVOY_SELL_BAILS:
		var rise: int = int(Probe.counts.get("trade.market_bail." + b, 0)) - int(before.get(b, 0))
		if rise > 0:
			d[b] = rise
	return d

func _update_escort(state: WorldState, team: TeamData) -> void:
	if team.order_target_id == -1:
		return
	var target: TeamData = state.teams.get(team.order_target_id)
	if target == null:
		TaskArbiter.release(team)   # 護衛對象消失 → 任務結束
		team.order_target_id = -1
		return
	team.move_target = target.tile_pos

func _check_discipline(state: WorldState, sub: TeamData) -> bool:
	var leader = state.persons.get(sub.leader_id)
	if leader == null:
		return false
	var total_loyalty: float = leader.loyalty
	var total_stress: float  = leader.stress
	var count: int = 1
	for aid in sub.named_members:
		var a = state.persons.get(aid)
		if a != null:
			total_loyalty += a.loyalty
			total_stress  += a.stress
			count         += 1
	var fail_chance: float = (1.0 - total_loyalty / count) * (total_stress / count) * DISCIPLINE_FAIL_BASE
	if randf() < fail_chance:
		state.detach_subteam(sub)   # 紀律失效脫離母團（雙向同步）
		state.remove_tag(sub, TeamData.TAG_SUBTEAM, "discipline_fail")
		TaskArbiter.release(sub)
		print("[SubAI] Team%d 紀律失效，脫離成獨立" % sub.team_id)
		return true
	return false

# A2a 子隊決策（引擎 dispatch，cadence-gated，鏡射 _decide_unified 尾）。
# 取代 _check_deviation(randf 中途叛離) + _evaluate_idle_subteam(手 argmax)：子隊 idle 走全框架
# rank_scored（含 faction_stakes/threat/掠奪/歸建），歸建(duty)↔掠奪(greed) loyalty-gated 競秤湧現。
func _decide_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	# ★D5 cadence gate（效能）：子隊決策非逐 tick，比照 threat cadence，攤平 gather+rank 成本。
	if state.world.current_tick < sub.subteam_eval_next_tick:
		return
	sub.subteam_eval_next_tick = state.world.current_tick + SUBTEAM_CADENCE
	_detect_survival_stall(state, sub)   # ② 絕境階梯 DETECT（單一源全 5 路決策 entry 之一：subteam）
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null:
		return
	var leader_p = state.persons.get(sub.leader_id)
	if leader_p == null:
		sub.move_target = parent.tile_pos   # 無腦 → 回家（lifecycle，不 capture）
		return
	var ranked: Array = DecisionEngine.rank_scored(state, sub)   # 全框架 rank
	for e in ranked:
		var opt: String = e["opt"]
		# ★歸建 = 服從母團 = lifecycle move（回母團集結/歸建），不進 obey/violation 統計（量測特判）。
		if opt == "歸建":
			sub.current_option = opt
			sub.move_target = parent.tile_pos
			merge_queue.append(sub.team_id)   # 到家由 loop2b try_merge_back
			return
		# ★means-end S2：goal frontier candidate 用其 cand.to_task。
		var td: Dictionary = (e["cand"]["to_task"] as Dictionary) if e.has("cand") else DecisionOptions.to_task(state, sub, opt)
		if td.get("delegate", false):
			continue   # ★S5:子隊不再委派(避 sub-sub nesting)→試次佳(自己做)
		if td.get("task", TeamData.TASK_IDLE) == TeamData.TASK_IDLE:
			continue
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue
		# ★投靠走新 helper：玩家 target→forced_event 請求（★return 不 fallthrough，防 P2a W2 自動併）；NPC→try_set JOIN。
		if opt == "併入":
			if _try_join_target(state, sub, int(td.get("social_target", -1))):
				sub.current_option = opt
				# ★量測特判（round-5）：只有 NPC 投靠真 try_set(JOIN) 才 capture；玩家 forced_event 分支
				# 未 try_set → current_task 仍 IDLE(≠winner) → 若 capture 會誤記 violation，故比照歸建不 capture 直接 return。
				if sub.current_task == TeamData.TASK_JOIN:
					HandBrainProbe.capture(state, sub, "subteam", String(ranked[0]["opt"]), opt, td["task"], true)
				return
			continue   # 投靠不可派/已寫 forced_event → 次佳（不 fallthrough 到 try_set）
		if not TaskArbiter.try_set(state, sub, td["task"], tgt, DecisionOptions.priority_for(opt), "subteam"):   # ★① 單一源(subteam survival @80 preempt,team19 換子隊 bug 收)
			continue
		_stamp_survival_commit(state, sub, opt)   # ② 蓋章 committed survival option baseline（單一源全 5 路之一）
		if td.has("combat_target"): state.set_combat_target(sub, int(td["combat_target"]))
		if td.has("social_target"): state.set_social_target(sub, int(td["social_target"]))
		_wire_threat_task(sub, td)   # 迎戰/求和 aux target（threat repertoire 保留）
		sub.current_option = opt      # 承諾慣性（COMMITMENT_BONUS 讀，防抖動）
		HandBrainProbe.capture(state, sub, "subteam", String(ranked[0]["opt"]), opt, td["task"], true)
		print("[SubAI] Team%d 引擎→%s (%s)" % [sub.team_id, td["task"], opt])
		return
	# 全不可派 → 回母團（lifecycle，不 capture）
	sub.move_target = parent.tile_pos

# A2a 子隊 join-player guard（scope B：只給 _decide_subteam 新路呼；既有 3 處 join 路不碰）。
# 玩家 target → forced_event 請求（玩家決定收留），★不 try_set、caller 不 fallthrough；
# NPC target → try_set TASK_JOIN + social_target。回 true=已處理(caller return)；false=不可派/已請求(caller continue)。
func _try_join_target(state: WorldState, team: TeamData, target_id: int) -> bool:
	if target_id == -1 or not state.teams.has(target_id):
		return false
	var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
	if pp != null and target_id == pp.team_id:
		return _maybe_request_join_player(state, team)   # 寫 forced_event，★不 try_set、caller 不 fallthrough
	# E2 感知鐵律：JOIN 移動目標讀 belief last-seen（非 live god-view）。無 belief→不 dispatch。
	var join_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, target_id)
	if join_pos == Vector2i(-1, -1):
		return false   # 無 belief 位 → 不 JOIN dispatch（禁 fallback live）
	if not TaskArbiter.try_set(state, team, TeamData.TASK_JOIN, join_pos, \
			DecisionOptions.priority_for("併入"), "subteam"):   # ★① 單一源第5路(grep 抓:JOIN=併入 survival-class @80,非 @50)
		return false
	_stamp_survival_commit(state, team, "併入")   # ② 蓋章 committed survival option baseline（單一源全 5 路之一）
	state.set_social_target(team, target_id)
	return true

# ──────── 獨立 Team 自主 AI ────────

# 重評 cadence 重構：劇變事件→提前重評（複用 S3 crash-bypass 門檻）。純讀 team 已存欄，零 randf、零 gather
# （避每 tick 全 gather perf）。pop 驟降/food 深負；威脅由既有 threat_eval cadence 路徑覆蓋，不在此重算。
func _decision_crisis(_state: WorldState, team: TeamData) -> bool:
	if team.rung_pop_last > 0 \
			and float(team.rung_pop_last - team.population) / float(team.rung_pop_last) > AmbitionLadder.RUNG_CRASH_POP_DROP_PCT:
		return true
	if team.food_flow_avg < AmbitionLadder.RUNG_CRASH_FOOD_DEEP:
		return true
	# Fix2-v2：慢性糧滑坡(輕負 flow，非暴跌<DEEP)=漸進安全網→糧一開始流失就週期性拉回確認補糧。
	# 不 revert edge：crisis_latched 節流仍在→漸進 crisis edge fire 一次+持續落 /4 cadence(非每 tick)。
	if team.food_flow_avg < GRADUAL_DECLINE_FLOW:
		return true
	return false

# ⑦ faction 命令即時響應（R①#1）：成員 faction 命令在其上次決策後才變 → 即重評（不等 cadence，守協同紅線）。
func _directive_fresh(state: WorldState, team: TeamData) -> bool:
	if team.faction_id == -1 or not state.factions.has(team.faction_id):
		return false
	return state.factions[team.faction_id].directive_change_tick > team.last_decision_tick

# ⑦ 統一「何時重評」predicate（唯一判斷點，架構紀律）：IDLE/stuck/crisis/命令新→即時；否則 cadence 節流。
func _should_reeval(state: WorldState, team: TeamData) -> bool:
	if team.current_task == TeamData.TASK_IDLE:
		if Probe.enabled: Probe.bump("reeval.idle")
		return true      # 空閒/剛釋放→即重評
	if _is_stuck(team):
		if Probe.enabled: Probe.bump("reeval.stuck")
		return true                              # 卡住→重評
	# Fix2 crisis edge-trigger：level-trigger(每 tick trip crisis 繞過 cadence, reeval.crisis=13087=93%)→ 邊緣化。
	# 進 crisis 當下 fire 一次(latch)；持續 crisis 落下方 cadence 閘(crisis 排程已 /4)；離開解 latch 供下次 edge。
	var in_crisis: bool = _decision_crisis(state, team)
	if in_crisis:
		if not team.crisis_latched:
			team.crisis_latched = true
			if Probe.enabled: Probe.bump("reeval.crisis")
			return true           # edge：進入 crisis 當下反射提前一次
		# 持續 crisis → 不每 tick，落下方 cadence 閘
	else:
		team.crisis_latched = false   # 離開 crisis → 解 latch
	if _directive_fresh(state, team):
		if Probe.enabled: Probe.bump("reeval.directive")
		return true               # faction 新命令→即時響應
	if state.world.current_tick >= team.decision_eval_next_tick:
		if Probe.enabled: Probe.bump("reeval.cadence")
		return true
	return false   # 否則 cadence 節流

func _evaluate_solo(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return   # 玩家隊不受 SoloAI 控制
	if team.combat_target != -1: return
	var leader_p = state.persons.get(team.leader_id)
	if leader_p == null: return
	# 統一決策引擎切片：商隊-tag solo 隊走 DecisionEngine（取代舊 solo 計分 + MERCHANT_TRADE_BONUS）。
	if uses_unified(team):                          # ← hoist 到 IDLE gate 前(unified 退 latch)
		_decide_unified(state, team)
		return
	# ⑦ 統一重評 gate（收斂到單一 _should_reeval predicate；IDLE/stuck/crisis/命令新即時，否則 cadence 節流）。
	if not _should_reeval(state, team):
		return
	# 排下次重評：crisis 短 cadence（反射），常態全 cadence
	team.decision_eval_next_tick = state.world.current_tick \
		+ (DECISION_CADENCE / 4 if _decision_crisis(state, team) else DECISION_CADENCE)
	team.last_decision_tick = state.world.current_tick   # 命令 freshness 比對基準
	_detect_survival_stall(state, team)   # ② 絕境階梯 DETECT（單一源全 5 路決策 entry 之一：non-unified solo）

	# 序5 dissolve：舊「FORCE 隊 cadence tick 讓給 loop3 prosperity_attack」yield 閘已刪——
	# 征服攻擊決策溶進主 rank（攻擊 option: intent_fit 征服 × readiness/富prey），FORCE 隊直接主 rank
	# 選攻擊 → _commit_conquest_attack scout-verify（下方迴圈）。cascade 雙路徑消除（框架債縫#3 部分結清）。

	# 序2 solo 溶入：手算 argmax 撕除 → 引擎 rank_scored（融合非刪；鏡射 _decide_unified）。
	# 去 _tag_weight hard-gate（tag 不硬鎖，藍圖裁1）；attack/loot 由 capability grounding（裁2）
	# + 人格 weight 承載傾向。9 反應 repertoire 全走 REGISTRY option（無新 option）。
	# scaffolding 保留：idle-gate（上面）、承諾慣性（引擎 COMMITMENT_BONUS 讀 current_option）、
	# solo_task_last、征服名實 Probe（_probe_conq_winner，保 winner+loot_lead 語意）。
	if _is_stuck(team):
		TaskArbiter.release(team)   # stuck 釋放讓位，同層才能重評（保留舊 solo 行為）
	var _conq: bool = Probe.enabled and _solo_type(team) == "征服"
	if _conq: Probe.bump("conq.intent")
	var ranked: Array = DecisionEngine.rank_scored(state, team)
	ranked = DecisionEngine.reorder_same_need_first(ranked)   # 同需求 fallthrough：rank[0]不可派→同層次佳(非跨層落生產)
	for e in ranked:
		var opt: String = e["opt"]
		# 序5 dissolve：征服 intent 攻擊 → dispatch-time scout-verify scaffolding（不確定→斥候、confident→打；
		# 削敵→俘虜→守乾淨鏈）。純血仇攻擊(非征服 intent)照走下方 raw dispatch（confidence 脫軌，不 scout-gate）。
		if opt == "攻擊" and _solo_type(team) == "征服" and team.faction_id == -1 \
				and _is_prosperity_candidate(state, team):
			var _pid: int = int(DecisionOptions.to_task(state, team, opt).get("combat_target", -1))
			if _commit_conquest_attack(state, team, _pid):
				if _conq: _probe_conq_winner(opt, ranked)
			# 憲法（融合非刪）：引擎選 攻擊 → 驗證攻擊路徑獨佔此決策，未派＝暫緩本 cadence 下輪重評，
			# 不落次佳 option 替換 NPC 選擇（舊 `continue`＝dispatch 層否決統一秤 #1）。
			return
		# ★means-end S2：goal frontier candidate 用其 cand.to_task。
		var td: Dictionary = (e["cand"]["to_task"] as Dictionary) if e.has("cand") else DecisionOptions.to_task(state, team, opt)
		# ★means-end S5 委派（solo）：delegate candidate 贏 → 派子隊，母隊留守。
		if td.get("delegate", false):
			if _dispatch_goal_delegate(state, team, td):
				team.current_option = String(e["opt"])
				return
			continue
		if td.get("task", TeamData.TASK_IDLE) == TeamData.TASK_IDLE:
			SpecimenTracer.capture_decision(state, team, opt, TeamData.TASK_IDLE, Vector2i(-1, -1), "idle_skip")   # Fix2b 早退 tap
			continue
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "finder_miss")   # Fix2b 早退 tap
			continue   # 不可派 → 試次佳（修凍死，鏡射 _decide_unified）
		if not TaskArbiter.try_set(state, team, td["task"], tgt, DecisionOptions.priority_for(opt), "solo"):   # ★① 單一源(solo survival @80 preempt 安頓)
			SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "try_set_noop")   # Fix2b 早退 tap
			continue
		_stamp_survival_commit(state, team, opt)   # ② 蓋章 committed survival option baseline（單一源全 5 路之一）
		# 掠奪/佔村/攻擊 設 combat_target 才交戰；投靠/乞食 設 social_target（鏡射 _decide_unified）
		if td.has("combat_target"): state.set_combat_target(team, int(td["combat_target"]))
		if td.has("social_target"): state.set_social_target(team, int(td["social_target"]))
		if opt == "攻擊": _probe_vendetta_dispatch(state, team)   # 序4：純血仇攻擊驗魂
		_wire_threat_task(team, td)   # 迎戰/求和 aux target（prosperity/order）
		if td["task"] == TeamData.TASK_FLEE: team.flee_from_pos = _flee_threat_pos(state, team)   # flee 位移根治：設逃離位
		team.solo_task_last = td["task"]   # F-D4：task 承諾記此槽（solo_intent 保留戰略 intent）
		team.current_option = opt          # 承諾慣性：引擎 COMMITMENT_BONUS 讀
		if _conq: _probe_conq_winner(opt, ranked)   # winner 分類 + util 排序根
		if td["task"] == TeamData.TASK_TRADE:
			Probe.bump("trade.dispatch.solo")   # 漏斗站4（timeout 起算由 try_set 蓋章 task_start_tick）
		# 手聽腦單點探針（此路 try_set 已成功→set_ok 恆真；rank[0] 被跳→次佳=subset_fallthrough）
		HandBrainProbe.capture(state, team, "solo", String(ranked[0]["opt"]), opt, td["task"], true)
		# 序① solo capture_decision 可見性（鏡射 _decide_unified）：純觀測 specimen tap，非 specimen 零成本。
		SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "committed")   # Fix2b：顯式 committed（早退已 gated，此路真成功）
		print("[SoloAI] Team%d → %s (%s)" % [team.team_id, td["task"], opt])
		return
	if _conq: Probe.bump("conq.winner_none")   # 征服 intent 但無可派 winner

func _update_equip_order(state: WorldState, team: TeamData) -> void:
	# 已裝備武器離開 storage pool；target 若只看 storage 會隨裝備行為縮放
	# → equip/unequip 每 tick 振盪（[Equip] spam 根因），故計入已裝備量
	var equipped_units: Dictionary = {
		"melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0
	}
	var named_ids: Array = team.named_members.duplicate()
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		if grade.begins_with("weapon_"):
			var wtype: String = grade.replace("weapon_", "")
			if equipped_units.has(wtype):
				equipped_units[wtype] += EquipmentSystem.UNITS_PER_EQUIP
	var total_weapons: int = 0
	for wtype in ["melee_low", "melee_high", "ranged_low", "ranged_high"]:
		total_weapons += int(team.resources.get("weapon_" + wtype, 0)) + int(equipped_units[wtype])
	if total_weapons <= 0:
		return
	team.equip_order = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0 }
	var can_equip: int = total_weapons / 2
	if team.tags.has(TeamData.TAG_MILITARY) or team.current_task == TeamData.TASK_LOOT \
			or team.current_task == TeamData.TASK_ATTACK:
		var pool_mh: int = (int(team.resources.get("weapon_melee_high", 0)) + int(equipped_units["melee_high"])) / 2
		var pool_rh: int = (int(team.resources.get("weapon_ranged_high", 0)) + int(equipped_units["ranged_high"])) / 2
		var pool_ml: int = (int(team.resources.get("weapon_melee_low", 0)) + int(equipped_units["melee_low"])) / 2
		var pool_rl: int = (int(team.resources.get("weapon_ranged_low", 0)) + int(equipped_units["ranged_low"])) / 2
		team.equip_order["melee_high"]  = mini(pool_mh, can_equip)
		can_equip -= team.equip_order["melee_high"]
		team.equip_order["ranged_high"] = mini(pool_rh, can_equip)
		can_equip -= team.equip_order["ranged_high"]
		team.equip_order["melee_low"]   = mini(pool_ml, can_equip)
		can_equip -= team.equip_order["melee_low"]
		team.equip_order["ranged_low"]  = mini(pool_rl, can_equip)
	elif team.tags.has(TeamData.TAG_MERCHANT):
		var guard_count: int = mini(team.population * 3 / 10, can_equip)
		team.equip_order["melee_low"] = mini(
			(int(team.resources.get("weapon_melee_low", 0)) + int(equipped_units["melee_low"])) / 2, guard_count)
	else:
		var guard_count: int = mini(team.population / 2, can_equip)
		team.equip_order["melee_low"] = mini(
			(int(team.resources.get("weapon_melee_low", 0)) + int(equipped_units["melee_low"])) / 2, guard_count)

func _get_player_team_id(state: WorldState) -> int:
	return state.get_player_team_id()

func _update_armor_config(team: TeamData) -> void:
	var pop_threshold: float = maxf(team.population * 0.3, 1.0)
	var has_high: bool = int(team.resources.get("armor_high", 0)) >= pop_threshold
	var has_low:  bool = int(team.resources.get("armor_low", 0))  >= pop_threshold
	# 重設全 none，再依條件填值
	team.armor_config = {
		"head": "none", "torso": "none",
		"right_arm": "none", "left_arm": "none",
		"right_leg": "none", "left_leg": "none",
	}
	var is_mil: bool = team.tags.has(TeamData.TAG_MILITARY)
	var is_mer: bool = team.tags.has(TeamData.TAG_MERCHANT)
	if is_mil and has_high:
		team.armor_config["torso"]     = "high"
		team.armor_config["head"]      = "low"
		team.armor_config["right_arm"] = "low"
		team.armor_config["left_arm"]  = "low"
		team.armor_config["right_leg"] = "low"
		team.armor_config["left_leg"]  = "low"
	elif is_mil and has_low:
		team.armor_config["torso"] = "low"
		team.armor_config["head"]  = "low"
	elif is_mer and has_low:
		team.armor_config["torso"] = "low"
	elif has_low:
		team.armor_config["torso"] = "low"

func _has_hostile_within(state: WorldState, team: TeamData, range_hex: int) -> bool:
	# 空間索引：只掃鄰域候選（超集）取代全隊掃 → 收 O(N²)/hr。live 復驗 has + hex_dist 保零行為變。
	for tid in state.teams_within(team.tile_pos, range_hex):
		if tid == team.team_id: continue
		if not state.teams.has(tid): continue
		var other: TeamData = state.teams[tid]
		if other.faction_id == team.faction_id and team.faction_id != -1: continue
		# 高聲望盟友過濾（rep >= 0.7 視為友軍，預設 0.5；結盟後 +0.2 → 達標）
		var rep: float = float(team.known_reputations.get(other.team_id, 0.5))
		if rep >= 0.7: continue
		var d: int = _hex_dist(team.tile_pos, other.tile_pos)
		if d <= range_hex:
			return true
	return false

func _update_guard_ratio(team: TeamData, state: WorldState) -> void:
	var ratio: float = 0.2  # default
	if team.current_task == TeamData.TASK_ATTACK or team.current_task == TeamData.TASK_LOOT:
		ratio = 0.1
	else:
		var threat: bool = _has_hostile_within(state, team, 3)
		if team.tags.has(TeamData.TAG_MILITARY) and threat:
			ratio = 0.4
		elif threat:
			ratio = 0.35
		elif team.tags.has(TeamData.TAG_PRODUCE):
			ratio = 0.15
	team.guard_ratio = clampf(ratio, 0.05, 0.5)

# ──────── 輔助函數 ────────

# unified-commerce M4：貿易總閘走 effective_holding + 人格 reserve（廢殭屍公式 pop×0.1×FOOD_RESERVE_TICKS
# 與 TRADE_MIN_STOCK 死常數）。有任一 res 餘量（effective_holding − reserve > 0）＝有貨可賣 → 可貿易。
func _can_trade(state: WorldState, team: TeamData) -> bool:
	if _tag_weight(team, TeamData.TASK_TRADE) == 0.0:
		return false
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	for res in TRADEABLE_RES:
		var surplus: float = ResourceSystem.effective_holding(state, team, res) \
			- TradeValuation.reserve(team, res, lv, state)
		if surplus > 0.0:
			return true
	return false

# G1d：商業 archetype 隊優先讀「收到的訂單」(殘缺/可失真情報) 定貿易目標，
# 非 team_discovered 上帝視角（接「目標決策讀殘缺情報」總則）。回目標格；無回 (-1,-1)。
# _find_trade_target(team_discovered) 降為無訂單時的 fallback。
# unified-commerce M1：目標收斂單一「選市場地方」（market-as-place）。三路 fallback 收斂為
# arb 單原點市場 → 最近市集 outpost（公開地標豁免）。廢 _find_trade_target team-chase（漫遊追人，
# 由 market-as-place 到場 resolver 取代）。市集＝固定地標，到達穩定（解 65% 漫遊撲空）。
func _merchant_trade_target(state: WorldState, team: TeamData) -> Vector2i:
	if team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE:
		var ord: Dictionary = OrderSystem.new().best_arbitrage_order(state, team)
		if not ord.is_empty():
			Probe.bump("g1.arb_attempt")
			return ord["pos"]   # 單原點=下單隊自家市集 outpost（固定市場地方）
	# 無 arb（沒讀過任何別隊單）→ 巡最近市集 outpost（公開地標）→ 抵達親讀看板取得 arb。
	var mkt: Vector2i = _nearest_market_outpost(state, team)
	if mkt != Vector2i(-1, -1):
		Probe.bump("g1.seek_market")
	return mkt   # (-1,-1) = 無市場可去

# ★god-view Slice C：找最近「已知市集 outpost」（belief-gate，非全圖 god-view）。
# 只掃 team_market_known（三源習得：創世/親見/relay），非全 state.world.tiles。無已知市集→(-1,-1)。
# 確定性（無 RNG）：harvest 讀既有 entry/tile，不加 dice。
func _nearest_market_outpost(state: WorldState, team: TeamData) -> Vector2i:
	_harvest_market_known(state, team)   # 更新 known（直接親見 vision 半徑內 + relay harvest team_known 訊息）
	var known: Dictionary = state.team_market_known.get(team.team_id, {})
	var best_pos: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	for tile_id in known:
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile == null or tile.outpost_level <= 0:
			continue   # demolish/失效市集 → 略（demolish hook 亦清 known，此 re-validate 保險）
		if tile.outpost_owner == team.team_id:
			continue   # 自家據點看板只有自己的單，去也無跨隊 arb
		var d: int = _hex_dist(team.tile_pos, tile.tile_pos)
		if d < best_d:
			best_d = d
			best_pos = tile.tile_pos
	return best_pos

# 找最近「已知市集 outpost 且有指定 res stock」（買料 action 用；belief-gate 同 _nearest_market_outpost）。
# res 濾 public_storage>0（有貨可買）。無 → (-1,-1)。確定性（無 RNG）。
func _nearest_market_outpost_with(state: WorldState, team: TeamData, res: String) -> Vector2i:
	_harvest_market_known(state, team)
	var known: Dictionary = state.team_market_known.get(team.team_id, {})
	var best_pos: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	for tile_id in known:
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile == null or tile.outpost_level <= 0:
			continue
		if tile.outpost_owner == team.team_id:
			continue
		if float(tile.public_storage.get(res, 0)) <= 0.0:
			continue   # ★需有該 res stock（有貨可買）
		var d: int = _hex_dist(team.tile_pos, tile.tile_pos)
		if d < best_d:
			best_d = d
			best_pos = tile.tile_pos
	return best_pos

# market-discovery 兩源 harvest（★無新 RNG）：①直接親見（vision 半徑內 outpost，bounded local scan 非全圖）
# ②relay harvest（team_known 的 order/outpost_built 訊息 market pos，★濾 outpost_level>0 避無 outpost 隊 live pos noise）。
# 創世-nearby 源在 game_setup（開局 seed）。
func _harvest_market_known(state: WorldState, team: TeamData) -> void:
	var known: Dictionary = state.team_market_known.get(team.team_id, {})
	# ① 直接親見：vision 半徑內 outpost tile（bounded=vision，非全圖 god-view）
	var vr: int = VisionSystem.VISION_RADIUS
	for dx in range(-vr, vr + 1):
		for dy in range(-vr, vr + 1):
			var p: Vector2i = team.tile_pos + Vector2i(dx, dy)
			if _hex_dist(team.tile_pos, p) > vr:
				continue
			var tid: int = p.x * 1000 + p.y
			var t: HexTileData = state.world.tiles.get(tid)
			if t != null and t.outpost_level > 0:
				known[tid] = true
	# ② relay harvest：team_known 訊息（order/outpost_built）market pos → known（濾真市集 outpost_level>0）
	for msg in state.team_known.get(team.team_id, []):
		var mpos: Vector2i = _msg_market_pos(msg)
		if mpos == Vector2i(-999, -999):
			continue
		var mtid: int = mpos.x * 1000 + mpos.y
		var mt: HexTileData = state.world.tiles.get(mtid)
		if mt != null and mt.outpost_level > 0:   # ★濾無 outpost 隊 fallback live pos noise
			known[mtid] = true
	state.team_market_known[team.team_id] = known

# 從 relay 訊息取市集 pos：order_buy/sell → params.origin_pos（下單隊市集）；outpost_built → source_pos（outpost tile）。
func _msg_market_pos(msg) -> Vector2i:
	if msg.type == "order_buy" or msg.type == "order_sell":
		var op = msg.params.get("origin_pos", null)
		if op is Vector2i:
			return op
	elif msg.type == "outpost_built":
		return msg.source_pos
	return Vector2i(-999, -999)

func _find_trade_target(state: WorldState, merchant: TeamData) -> int:
	var best_id: int = -1
	var best_score: float = -1e9
	for tid in state.team_discovered.get(merchant.team_id, []):
		if tid == merchant.team_id: continue
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, merchant, tid, true)
		if not catch_result.reachable: continue
		var snap: Dictionary = BeliefSystem.best_estimate(state, merchant.team_id, tid)
		var max_gap: float = 0.0
		for res in TradeValuation.BASE_PRICE:
			var my_val: float = TradeValuation.local_value(merchant, res)
			var their_val_est: float = my_val
			if snap.has(res) and res in ["food", "material"]:
				var pop: int = int(snap.get("population", 10))
				var stk: float = float(snap.get(res, 0))
				var target: float = float(pop) * float(TradeValuation.TARGET_PER_POP.get(res, 1.0))
				var sr: float = clampf((target - stk) / maxf(target, 1.0), -0.5, 1.0)
				their_val_est = float(TradeValuation.BASE_PRICE[res]) * (1.0 + sr)
			var gap: float = absf(their_val_est - my_val)
			if gap > max_gap: max_gap = gap
		var score: float = max_gap / float(maxi(int(catch_result.eta) / 60, 1))
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

# S1：製造 precondition 規則（本格任一製造設施 level>0 + 生產權）。無 material 查（材料不足=另條 no-op tap）。
# 死碼 _can_manufacture 設施查邏輯抽此 static，供 DecisionContext.gather「生產」applicable 規則重用（A2 補缺）。
static func has_manufacturing_facility(state: WorldState, team: TeamData) -> bool:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		return false
	var has_facility: bool = false
	for level_key in ManufacturingSystem.RECIPE_GROUPS:
		if int(tile.get(level_key)) > 0:
			has_facility = true
			break
	if not has_facility:
		return false
	# 生產權：owner 本人或同 faction 居民團
	if tile.outpost_owner != team.team_id:
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null or owner.faction_id != team.faction_id or team.faction_id == -1:
			return false
	return true

func _can_manufacture(state: WorldState, team: TeamData) -> bool:
	if not has_manufacturing_facility(state, team):
		return false
	return float(team.resources.get("material", 0)) >= MANUFACTURE_MATERIAL_MIN

func _is_known(state: WorldState, from_id: int, target_id: int) -> bool:
	return state.team_discovered.get(from_id, []).has(target_id)

func _has_independent(state: WorldState, from_team_id: int) -> bool:
	for tid in state.team_discovered.get(from_team_id, []):
		if state.teams.has(tid) and state.teams[tid].faction_id == -1:
			return true
	return false

func _nearest_independent(state: WorldState, from_team: TeamData) -> int:
	var best_id: int = -1
	var best_d: int  = 999
	for tid in state.team_discovered.get(from_team.team_id, []):
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.team_id == from_team.team_id:
			continue
		# god-view 位置根治（Fix D）：補 has_belief gate——只選有情報目標，用 belief last-seen 位置估距（非活值）。
		var bpos: Vector2i = BeliefSystem.belief_pos(state, from_team.team_id, tid)
		if bpos == Vector2i(-1, -1): continue   # 無 belief/過期→不選
		var d: int = _hex_dist(from_team.tile_pos, bpos)
		if d < best_d:
			best_d  = d
			best_id = tid
	return best_id

func _calc_own_armed(state: WorldState, team: TeamData) -> int:
	var named_armed: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid) as PersonData
		if p and p.equipment["hand_1"].get("type", "none") != "none":
			named_armed += 1
	var named_count: int = 1 + team.named_members.size()
	var anon_pop: int    = maxi(team.population - named_count, 0)
	return named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

# ──────── 基建設施需求評估（FACILITY_DEF.trigger_check 指向）────────

func _check_food_shortage(state: WorldState, faction) -> float:
	var total_food: float = 0.0
	var total_pop: int = 0
	for tid in faction.member_team_ids:
		var t: TeamData = state.require_team(tid)
		# WS-2c：有效糧(私產+自家糧倉)，否則定居 faction 成員 food 在糧倉→整勢力誤判缺糧→過建農。
		total_food += ResourceSystem.effective_food(state, t)
		total_pop += t.population
	var per_capita: float = total_food / maxf(total_pop, 1)
	# 缺糧（< 10 天份）→ 高 priority
	return clampf((10.0 - per_capita) / 10.0, 0.0, 1.0) * 100.0

func _check_goods_shortage(state: WorldState, faction) -> float:
	var total_goods: float = 0.0
	for tid in faction.member_team_ids:
		var t: TeamData = state.require_team(tid)
		total_goods += float(t.resources.get("goods", 0))
	# goods < 100 → 觸發
	return clampf((100.0 - total_goods) / 100.0, 0.0, 1.0) * 50.0

func _check_mount_demand(state: WorldState, faction) -> float:
	# 軍隊/商隊團多 + mount/pop 比偏低 → 高 priority 蓋馬廄
	var total_pop: int = 0
	var total_mounts: int = 0
	var has_demand_tag: bool = false
	for tid in faction.member_team_ids:
		var t: TeamData = state.require_team(tid)
		total_pop += t.population
		total_mounts += int(t.resources.get("mounts", 0))
		if "軍隊" in t.tags or "商隊" in t.tags:
			has_demand_tag = true
	if not has_demand_tag: return 0.0
	var ratio: float = float(total_mounts) / maxf(float(total_pop), 1.0)
	return clampf((0.5 - ratio) / 0.5, 0.0, 1.0) * 60.0

func _check_ore_surplus(state: WorldState, faction) -> float:
	var total: float = 0.0
	for tid in faction.member_team_ids:
		for tile_id in state.world.tiles:
			var tile: HexTileData = state.world.tiles[tile_id]
			if tile.outpost_owner != tid: continue
			total += float(tile.public_storage.get("ore_gold", 0)) * 5.0
			total += float(tile.public_storage.get("ore_silver", 0))
	return 80.0 if total > 50.0 else 0.0

# ──────── 公庫徵用 ────────

func _extract_treasury(state: WorldState, team: TeamData, ratio: float, reason: String) -> void:
	if team.anon_treasury <= 0.0 or ratio <= 0.0: return
	ratio = clampf(ratio, 0.0, 1.0)
	var amt: float = team.anon_treasury * ratio
	if amt < 1.0: return   # 忽略可忽略額度，避免空徵用噪音 + 虛增 unrest
	AnonTreasuryBank.withdraw(team, amt, "extract")
	ResourceBank.add(team, "coin", amt, "extract_treasury")
	var is_emergency: bool = (reason == "飢餓緊急")
	var stress_pen: float = (0.05 if is_emergency else 0.15) * ratio
	var loyalty_pen: float = (0.02 if is_emergency else 0.08) * ratio
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		p.stress = minf(p.stress + stress_pen, 1.0)
		LoyaltyBank.adjust(p, -loyalty_pen, "faction_strain")
	if not is_emergency:
		UnrestBank.add(team, 1, "faction")
	print("[Extract] Team%d 徵用 %.0f coin (%s)" % [team.team_id, amt, reason])

# ★extraction de-patch：coin_need 信號（means-end 延伸，reuse 既有 buy-intent 架構）。
# 隊真 coin-用途估算=要 spendable coin 才做得成的 buy-intent（material-buy 建設 + food-buy 食壓）。
# ★無遞迴：讀 material/food need（resource need，非 facility-output）→ 不回呼 coin/extraction（reviewer R² 驗）。
const COIN_NEED_CAP: float = 500.0        # TEST VALUE — coin_need clamp 上限防爆
const EXTRACT_BUFFER_MIN: float = 5.0     # TEST VALUE — 貪婪 leader extract 後留 treasury 下限（>0=非清空）
const EXTRACT_BUFFER_MAX: float = 30.0    # TEST VALUE — 慎重 leader 留厚 buffer 上限
func coin_need(state: WorldState, team: TeamData) -> float:
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var need: float = 0.0
	# ★material-hold ④：material-buy 對齊 afford×1.5 缺口（非只 need_keep shortfall）→ extraction 拉夠 coin 買足量
	# 到能 afford（cost×1.5）。cost=想蓋 facility 的 material build-need（_construction_facility_need）。
	var mat_cost: float = NeedOracle._construction_facility_need(state, team, "material", lv)
	if mat_cost > 0.0:
		var mat_afford_short: float = maxf(mat_cost * 1.5 \
			- ResourceSystem.effective_holding(state, team, "material"), 0.0)
		if mat_afford_short > 0.0:
			need += mat_afford_short * TradeValuation.local_value(team, "material", state)   # coin ≈ afford 缺料量 × 料價
	# food-buy（食壓）：food_days<DESPERATION → 需 coin 買糧
	var pop: float = maxf(float(team.population), 1.0)
	var eff_food: float = ResourceSystem.effective_food(state, team)
	var food_days: float = eff_food / (pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY)
	if food_days < DecisionTerms.DESPERATION_DAYS:
		var food_short: float = maxf(DecisionTerms.DESPERATION_DAYS * pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY - eff_food, 0.0)
		need += food_short * TradeValuation.local_value(team, "food", state)   # coin ≈ 缺糧量 × 糧價
	return minf(need, COIN_NEED_CAP)

# ★persona buffer texture（extract 後留 treasury margin）：慎重↑留厚、貪婪↑留薄。
# ★下限 EXTRACT_BUFFER_MIN>0（reviewer R² 必補）：貪婪只降到正下限非 0=非清空 treasury（人格=補多夠用非抽不抽）。
func _extract_buffer(leader: PersonData) -> float:
	var prudence: float = float(leader.values.get("慎重", 0.5))
	return lerpf(EXTRACT_BUFFER_MIN, EXTRACT_BUFFER_MAX, prudence)

func _consider_extraction(state: WorldState, team: TeamData) -> void:
	if team.anon_treasury <= 0.0: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if team.leader_id == state.player_id: return   # 玩家手動   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	# ★de-patch:砍 flat `greed-prud×0.5>0.4` 死常數門檻 → need-driven（有真 coin-用途才取回自己 treasury coin）。
	var spendable: float = float(team.resources.get("coin", 0))
	var shortfall: float = coin_need(state, team) - spendable
	if shortfall <= 0.0: return   # gate-ok: guard: spendable 已夠→不亂徵(need-guard 非人格閘)
	# ★need 決定「抽不抽」(有真缺才抽);人格 buffer=texture「補到多夠用」(非清空 treasury)。
	var amt: float = minf(shortfall + _extract_buffer(leader), team.anon_treasury)
	_extract_treasury(state, team, amt / team.anon_treasury, "need_driven")

# unified-commerce coin combo（fold coin-B 成員稅回收，破 salary 單向枯竭補 team.coin 池）。
# 鏡射 _consider_extraction：月 cadence、玩家隊不自動、稅率掛領袖人格。★守恆：person.coin→team.coin 池間搬。
# ★tune 強（coin now load-bearing：買方要有錢買市場 ask ~3.4+）：rate 高/MIN 保底/FLOOR 低（TEST VALUE，measurer 校）。
const MEMBER_TAX_K: float        = 0.6    # TEST VALUE — 貪婪→稅率係數（單刀 0.3 太弱→強化）
const MEMBER_TAX_K2: float       = 0.2    # TEST VALUE — 慎重→減稅係數
const MEMBER_TAX_MIN: float      = 0.15   # TEST VALUE — 保底稅（連中性領袖也抽，全隊回補 coin 池）
const MEMBER_TAX_MAX: float      = 0.7    # TEST VALUE — 上限（貪婪深抽）
const PERSONAL_COIN_FLOOR: float = 2.0    # TEST VALUE — 留個人燃料不收乾（單刀 5.0 太保守→降）
func _collect_member_tax(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return   # 玩家手動（同 extraction）
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var tax_rate: float = clampf(greed * MEMBER_TAX_K - prudence * MEMBER_TAX_K2, MEMBER_TAX_MIN, MEMBER_TAX_MAX)
	if tax_rate <= 0.0: return
	for pid in team.named_members:
		var p: PersonData = state.persons.get(int(pid))
		if p == null: continue
		var levy: float = minf(p.coin * tax_rate, p.coin - PERSONAL_COIN_FLOOR)   # 留 floor 不收乾
		if levy <= 0.0: continue
		ResourceBank.adjust_person_coin(p, -levy, "member_tax")   # 守恆 chokepoint：person.coin−
		ResourceBank.add(team, "coin", levy, "member_tax")        # team.coin+（池間搬，CoinAudit=0）

# 滅團標記：清 faction 引用 + 排入延遲清除（資產路由延到 erase 當下，捕捉時序間加回的 coin）
func _on_team_extinct(state: WorldState, team: TeamData) -> void:
	# defense-in-depth（systems addendum 2026-07-19）：野獸死=狩獵結果非隊死因統計，不計入 extinct.* 死因計數器。
	# loop3 beast-skip 已令 beast 正常走不到此（combat cleanup 擁有 beast 清理）→ 此守衛冗餘但防未來別條 extinct 路誤計。
	if Probe.enabled and team.beast_kind == "":
		# 滅團死因分類（盡力，無完美標記→extinct.other 兜底）：餓死計時>0=餓主因，否則戰鬥標記，否則其他
		if team.famine_days > 0.0: Probe.bump("extinct.starve")
		elif team.combat_target != -1: Probe.bump("extinct.combat")
		else: Probe.bump("extinct.other")
		# 死隊 forage 斷點定位（blueprint 2026-07-12）：死亡當下 task 是否為覓食/求生 + owner 狀態
		var _has_home: bool = ResourceSystem.own_granary_tile(state, team) != null
		if team.famine_days > 0.0:   # 只在餓死組分類，非本次判準的戰鬥/其他死不混入
			if team.current_task == TeamData.TASK_FORAGE:
				Probe.bump("extinct.starve_while_foraging_owner" if _has_home else "extinct.starve_while_foraging_nonowner")
			elif team.current_task == TeamData.TASK_FLEE:
				Probe.bump("extinct.starve_while_fleeing_owner" if _has_home else "extinct.starve_while_fleeing_nonowner")
			else:
				Probe.bump("extinct.starve_no_forage_owner" if _has_home else "extinct.starve_no_forage_nonowner")
	if team.faction_id != -1 and state.factions.has(team.faction_id):
		var f = state.factions[team.faction_id]
		f.member_team_ids.erase(team.team_id)
		if f.leader_team_id == team.team_id:
			state.disband_faction(team.faction_id)
	if not state.teams_pending_erase.has(team.team_id):
		state.teams_pending_erase.append(team.team_id)

# tick 末單點：路由遺財（守恆）+ erase。中途 erase 不安全（多系統持 team_ids 快照）
# die-off 潮批次：遺財路由迴圈照舊逐隊（守恆），結尾一次 erase_teams（K 趟 O(N) 全掃 → 單趟）。
# route 只讀 team 資產+tile、erase 只清 ref → route-all→erase-all 與逐隊交錯語意等價。
func cleanup_extinct_teams(state: WorldState) -> void:
	if state.teams_pending_erase.is_empty():
		return
	var routed: Array = []
	for tid in state.teams_pending_erase:
		if not state.teams.has(tid):
			continue
		_route_extinct_assets(state, state.teams[tid])
		routed.append(tid)
	state.erase_teams(routed)   # 批次清光所有 ref（含 detach、registry、交叉）
	for tid in routed:
		print("[Extinct] Team%d 滅團清除（遺財已路由）" % tid)
	state.teams_pending_erase.clear()

# 從 pos 擴環找最近有效 tile（地圖外滅團遺財路由用）
func _nearest_valid_tile(state: WorldState, pos: Vector2i) -> HexTileData:
	for r in range(1, 12):
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				var t: HexTileData = state.world.tiles.get((pos.x + dx) * 1000 + (pos.y + dy))
				if t != null:
					return t
	return null

# 遺財路由：有 outpost → 資源進公庫(coin/ore 溢出→abandoned/地面 守恆)；無 outpost → coin→abandoned、ore→地面
func _route_extinct_assets(state: WorldState, team: TeamData) -> void:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	# 死在地圖外格（config 可能 spawn 超出 radius）→ 改路由到最近有效格（守恆，不清空丟失）
	if tile == null:
		tile = _nearest_valid_tile(state, team.tile_pos)
		if tile == null:
			# 地圖全無有效格(radius 12) → coin 無處落地 → 記顯性 off-map sink（守恆閉合，非靜默丟失）。
			var lost_coin: float = team.anon_treasury + float(team.resources.get("coin", 0))
			state.offmap_extinct_coin += lost_coin
			WorldState.record_driver(team, "coin", -lost_coin, "extinct_no_tile")
			AnonTreasuryBank.reset(team, "extinct_no_tile")
			ResourceBank.clear_all(team, "extinct_no_tile")
			return
	if tile.outpost_level > 0:
		var os := OutpostSystem.new()
		# coin = resources.coin + treasury：進公庫至 cap，溢出 → abandoned_coin（守恆）
		var coin_total: float = float(team.resources.get("coin", 0)) + team.anon_treasury
		var coin_cap: float = os._get_storage_cap(tile, "coin")
		var coin_room: float = maxf(coin_cap - float(tile.public_storage.get("coin", 0)), 0.0)
		var coin_in: float = minf(coin_total, coin_room)
		TileBank.set_amt(tile, "coin", float(tile.public_storage.get("coin", 0)) + coin_in, "extinct_route_coin")
		tile.abandoned_coin += coin_total - coin_in
		# 其他資源：進公庫至 cap。ore_gold/silver 溢出落地面（coin_eq 守恆）；非有限資源溢出消失
		for res in team.resources:
			if res == "coin": continue
			var amt: float = float(team.resources[res])
			if amt <= 0.0: continue
			var cap: float = os._get_storage_cap(tile, res)
			var stored: float = float(tile.public_storage.get(res, 0))
			var room: float = maxf(cap - stored, 0.0)
			var put: float = minf(amt, room)
			TileBank.set_amt(tile, res, stored + put, "extinct_route_res")
			if res in ["ore_gold", "ore_silver"]:
				TileBank.pool_set(tile, res, float(tile.resources.get(res, 0)) + (amt - put), "extinct_route_ore_ground")
	else:
		# 無 outpost → coin+treasury 進 abandoned、ore 落地面（守恆：coin_eq 全算）；其他無容器消失
		tile.abandoned_coin += team.anon_treasury + float(team.resources.get("coin", 0))
		TileBank.pool_set(tile, "ore_gold", float(tile.resources.get("ore_gold", 0)) \
			+ float(team.resources.get("ore_gold", 0)), "extinct_ore_ground")
		TileBank.pool_set(tile, "ore_silver", float(tile.resources.get("ore_silver", 0)) \
			+ float(team.resources.get("ore_silver", 0)), "extinct_ore_ground")
	# coin 已先路由(public_storage/abandoned_coin) → 此 reset 為合法歸零(非洩漏)
	AnonTreasuryBank.reset(team, "extinct_routed")
	ResourceBank.clear_all(team, "extinct_routed")

# ──────── NPC 自動領存公庫 ────────

func _calc_team_need(team: TeamData, res: String) -> float:
	match res:
		"food": return float(team.population) * 14.0
		"material": return 50.0 + float(team.population) * 2.0
		"coin": return float(team.population) * 10.0
		"weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high":
			return float(team.named_members.size()) * 2.0
		"armor_low", "armor_high":
			return float(team.named_members.size())
		_:
			return 0.0

func _evaluate_storage_visit(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	if tile.outpost_owner != team.team_id: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if tile.public_storage.is_empty(): return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var os := OutpostSystem.new()
	for res in tile.public_storage.keys():
		var stored: float = float(tile.public_storage[res])
		var team_have: float = float(team.resources.get(res, 0))
		var needed: float = _calc_team_need(team, res)
		if team_have < needed:
			var take: float = minf(stored, needed - team_have)
			if take > 0.0:   # gate-ok: housekeeping: take>0 正量守衛
				TileBank.set_amt(tile, res, stored - take, "npc_withdraw_vault_out")
				ResourceBank.set_amt(team, res, team_have + take, "npc_withdraw_vault")
		elif team_have > needed * 2.0:
			var cap: float = os._get_storage_cap(tile, res)
			var deposit_max: float = cap - stored
			var deposit: float = minf(team_have - needed, deposit_max)
			if deposit > 0.0:   # gate-ok: housekeeping: deposit>0 正量守衛
				TileBank.set_amt(tile, res, stored + deposit, "npc_deposit_vault_in")
				ResourceBank.set_amt(team, res, team_have - deposit, "npc_deposit_vault")

# ──────── 基建 dispatch ────────

# 選址 diff print：同 faction 同址不重印（{ faction_id: "x_y" }）
var _last_site_sig: Dictionary = {}
# 派工失敗原因 diff print：同 faction 同原因連續不重印（{ faction_id: reason }）
var _last_dispatch_fail: Dictionary = {}

func _log_dispatch_fail(faction_id: int, reason: String, cost: Dictionary) -> void:
	if _last_dispatch_fail.get(faction_id, "") == reason:
		return
	_last_dispatch_fail[faction_id] = reason
	print("[Site] Faction%d 派工失敗: %s (需 %s)" % [faction_id, reason, str(cost)])

# 選一名非 leader 的記名成員當子隊 leader（建造/升級/擴建 crew）
func _pick_advisor(team: TeamData) -> int:
	for pid in team.named_members:
		if pid != team.leader_id:
			return pid
	return -1

# 派建造子隊前往 target_pos，task="建造"，附 build_type/level。
# 資源以 1.5x 安全餘量檢查（子隊抵達後 start_build 才實際扣款）。
func _dispatch_builder(state: WorldState, leader_team: TeamData, target_pos: Vector2i,
		outpost_type: String, level: int) -> bool:
	# S4 防重複派遣：leader_team 已有 TASK_CONSTRUCT 子隊（在途或施工）→ 跳過
	# 移動中子隊 tile_pos ≠ 目的地，故用「任一 CONSTRUCT 子隊存在」gate 代替精確目標比對
	for cid in leader_team.subteam_ids:
		var ct: TeamData = state.teams.get(cid)
		if ct == null: continue
		if ct.current_task == TeamData.TASK_CONSTRUCT or ct.current_task == TeamData.TASK_BUILD:
			return false
	# 也檢查 tile.construction_team_id（已抵達且施工中）
	var target_tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if target_tile != null and target_tile.construction_team_id != -1:
		return false
	var cost: Dictionary = OutpostSystem.OUTPOST_COST[outpost_type][level - 1]
	# 腳下公庫 caravan-load：leader 站自家 outpost → 公庫+私產合併池 gate（W4 B）
	var home_tile: HexTileData = state.world.tiles.get(
		leader_team.tile_pos.x * 1000 + leader_team.tile_pos.y)
	var vault: Dictionary = {}
	if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
		vault = home_tile.public_storage
	for k in cost:
		if k == "ticks": continue
		var avail: float = float(vault.get(k, 0)) + float(leader_team.resources.get(k, 0))
		if avail < float(cost[k]) * 1.5:
			_log_dispatch_fail(leader_team.faction_id,
				"資源不足 1.5x: %s 有 %.0f(公庫%.0f+私%.0f)" % [k, avail,
				float(vault.get(k, 0)), float(leader_team.resources.get(k, 0))], cost)
			return false
	var advisor_id: int = _pick_or_promote_advisor(state, leader_team)
	if advisor_id == -1:
		_log_dispatch_fail(leader_team.faction_id, "無 advisor 可派可升", cost)
		return false
	var pop: int = maxi(6, level * 4)   # TEST VALUE — 建造隊最小 6 人；pop*2 門檻=12(lv1)
	if leader_team.population < pop * 2:
		_log_dispatch_fail(leader_team.faction_id,
			"pop 不足: %d < %d" % [leader_team.population, pop * 2], cost)
		return false
	# ★糧流 Slice B1 糧橋 go/no-go（解 A1 子隊餓死真 victim）：子隊遠地跋涉+建程需糧 burn×ETA_total。
	# 母隊(公庫+私產)food 撥得起才派→出發配糧到夠（下方 top-up）；不豐→no-go（別派餓死途中 dissolve）。
	# ★ETA_total=去程(dist/移速)+建程(BUILD_TICKS/pop)（§5）；純算術零 RNG。收編取代礦山 ad-hoc food bootstrap。
	var _eta_travel: float = float(_hex_dist(leader_team.tile_pos, target_pos)) / FOOD_BRIDGE_MOVE_PER_DAY
	var _eta_build: float = float(OutpostSystem.BUILD_TICKS[outpost_type][level - 1]) / maxf(float(pop), 1.0)
	var _need_food: float = float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY \
		* (_eta_travel + _eta_build) * FOOD_BRIDGE_SAFE_MARGIN
	var _avail_food: float = float(vault.get("food", 0)) + float(leader_team.resources.get("food", 0))
	if _avail_food < _need_food:
		_log_dispatch_fail(leader_team.faction_id,
			"糧橋不足: food %.0f < 需 %.0f(burn×ETA %.1f 天)" % [_avail_food, _need_food, _eta_travel + _eta_build], cost)
		if Probe.enabled: Probe.bump("bridge.no_go_food")
		return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, leader_team.team_id, advisor_id, pop, TeamData.TASK_CONSTRUCT, target_pos)
	if sub_id == -1:
		_log_dispatch_fail(leader_team.faction_id, "subteam dispatch 失敗", cost)
		return false
	_last_dispatch_fail.erase(leader_team.faction_id)
	# caravan-load：從腳下公庫優先撥付，差額補私產（守恆：公庫減 == 子隊增）
	_fund_subteam_from_vault(state, leader_team, state.teams[sub_id], home_tile, cost)
	state.teams[sub_id].task_extra_data = {
		"build_type": outpost_type, "level": level
	}
	# ★糧流 Slice B1 通用 food top-up（第5真新建，收編取代礦山 ad-hoc food bootstrap）：撥母隊 food 給子隊
	# 到夠 burn×ETA（去程+建程 dissolve 不了）→ 解 A1 forest founding 子隊遠地跋涉餓死真 victim（非只礦山）。
	# go/no-go 已確保 avail≥need→此 top-up 撥得足；公庫優先差額補私產（守恆：純轉移）。
	var _sub: TeamData = state.teams[sub_id]
	var _gap: float = _need_food - float(_sub.resources.get("food", 0))
	if _gap > 0.0:
		if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
			var _fv: float = minf(_gap, float(home_tile.public_storage.get("food", 0)))
			if _fv > 0.0:
				TileBank.set_amt(home_tile, "food", float(home_tile.public_storage.get("food", 0)) - _fv, "bridge_topup_vault_out")
				ResourceBank.add(_sub, "food", _fv, "bridge_topup_vault_in")
				_gap -= _fv
		if _gap > 0.0:
			var _fo: float = minf(_gap, float(leader_team.resources.get("food", 0)))
			if _fo > 0.0:
				ResourceBank.add(leader_team, "food", -_fo, "bridge_topup_owner_out")
				ResourceBank.add(_sub, "food", _fo, "bridge_topup_owner_in")
		if Probe.enabled: Probe.bump("bridge.topup")
	# 礦村 material+tools bootstrap（定居後立起鑄幣廠 mint cost×1.5；food 已由上方通用糧橋涵蓋）：
	var tgt_tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if tgt_tile != null and tgt_tile.terrain == "mountain" \
			and (float(tgt_tile.resource_cap.get("ore_gold", 0)) > 0.0 \
				or float(tgt_tile.resource_cap.get("ore_silver", 0)) > 0.0):
		var sub: TeamData = state.teams[sub_id]
		# S3b 礦村 bootstrap material+tools：定居後能立即起建鑄幣廠（mint cost×1.5倍）
		# material 需 150（mint cost 100 × 1.5）；tools 需 8（mint cost 5 × 1.5 四捨上整）
		const MINT_MAT_BOOTSTRAP: float = 150.0    # TEST VALUE
		const MINT_TOOLS_BOOTSTRAP: float = 8.0    # TEST VALUE
		for res_pair in [["material", MINT_MAT_BOOTSTRAP], ["tools", MINT_TOOLS_BOOTSTRAP]]:
			var rname: String = res_pair[0]
			var rtgt: float = res_pair[1]
			var rneed: float = rtgt - float(sub.resources.get(rname, 0))
			if rneed <= 0.0: continue
			var rfrom_vault: float = 0.0
			if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
				rfrom_vault = minf(rneed, float(home_tile.public_storage.get(rname, 0)))
				if rfrom_vault > 0.0:
					TileBank.set_amt(home_tile, rname, float(home_tile.public_storage.get(rname, 0)) - rfrom_vault, "mine_bootstrap_vault_out")
					ResourceBank.add(sub, rname, rfrom_vault, "mine_bootstrap_vault")
					rneed -= rfrom_vault
			if rneed > 0.0:
				var rfrom_owner: float = minf(rneed, float(leader_team.resources.get(rname, 0)))
				if rfrom_owner > 0.0:
					ResourceBank.add(leader_team, rname, -rfrom_owner, "mine_bootstrap_owner_out")
					ResourceBank.add(sub, rname, rfrom_owner, "mine_bootstrap_owner_in")
	print("[Infra] Team%d 派建造子隊 Team%d → (%d,%d) %s Lv%d" % [
		leader_team.team_id, sub_id, target_pos.x, target_pos.y, outpost_type, level])
	return true

# 派升級子隊（task="升級"，附 target_level）
func _dispatch_upgrader(state: WorldState, owner_team: TeamData, outpost_pos: Vector2i,
		target_level: int) -> bool:
	var tile: HexTileData = state.world.tiles.get(outpost_pos.x * 1000 + outpost_pos.y)
	if tile == null or tile.outpost_owner != owner_team.team_id: return false
	if target_level <= tile.outpost_level or target_level > 3: return false
	if tile.construction_team_id != -1: return false
	var cost: Dictionary = OutpostSystem.OUTPOST_COST[tile.outpost_type][target_level - 1]
	# 公庫+私產合併池（升級在自有 tile，公庫本地可用 → W4 解）
	for k in cost:
		if k == "ticks": continue
		var avail: float = float(tile.public_storage.get(k, 0)) + float(owner_team.resources.get(k, 0))
		if avail < float(cost[k]) * 1.5: return false
	var advisor_id: int = _pick_or_promote_advisor(state, owner_team)
	if advisor_id == -1: return false
	if owner_team.population < 10: return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, owner_team.team_id, advisor_id, 5, TeamData.TASK_UPGRADE, outpost_pos)
	if sub_id == -1: return false
	_fund_subteam_cost(owner_team, state.teams[sub_id], tile, cost)
	state.teams[sub_id].task_extra_data = { "target_level": target_level }
	# S5 升級子隊 bootstrap food：升 Lv2 需 720 ticks=30天，比例分配食物不足撐完工
	var up_sub: TeamData = state.teams[sub_id]
	const UPGRADE_BOOTSTRAP_DAYS: float = 35.0   # TEST VALUE — 升級隊補糧天數（多備5天緩衝）
	var up_need: float = float(up_sub.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY \
		* UPGRADE_BOOTSTRAP_DAYS - float(up_sub.resources.get("food", 0))
	if up_need > 0.0:
		var up_home_tile: HexTileData = state.world.tiles.get(
			owner_team.tile_pos.x * 1000 + owner_team.tile_pos.y)
		var up_from_vault: float = 0.0
		if up_home_tile != null and up_home_tile.outpost_owner == owner_team.team_id:
			up_from_vault = minf(up_need, float(up_home_tile.public_storage.get("food", 0)))
			if up_from_vault > 0.0:
				TileBank.set_amt(up_home_tile, "food", float(up_home_tile.public_storage.get("food", 0)) - up_from_vault, "upgrade_bootstrap_vault_out")
				ResourceBank.add(up_sub, "food", up_from_vault, "upgrade_bootstrap_vault")
				up_need -= up_from_vault
		if up_need > 0.0:
			var up_from_owner: float = minf(up_need, float(owner_team.resources.get("food", 0)))
			if up_from_owner > 0.0:
				ResourceBank.add(owner_team, "food", -up_from_owner, "upgrade_bootstrap_owner_out")
				ResourceBank.add(up_sub, "food", up_from_owner, "upgrade_bootstrap_owner_in")
	print("[Infra] Team%d 派升級子隊 Team%d → (%d,%d) Lv%d" % [
		owner_team.team_id, sub_id, outpost_pos.x, outpost_pos.y, target_level])
	return true

# 施工中斷（survival 等劫持後未復工）→ 在場居民復工，否則召回 owner 回工地
func _try_resume_construction(state: WorldState, tile: HexTileData, leader_team: TeamData) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and t.current_task == TeamData.TASK_BUILD:
			return   # 已有人施工
	var interruptible: Array = [TeamData.TASK_IDLE, TeamData.TASK_PRODUCE,
		TeamData.TASK_MANUFACTURE, TeamData.TASK_TRADE]
	var candidates: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.combat_target != -1:
			if Probe.enabled: Probe.bump("resume.reject_combat")   # ★純觀測
			continue
		if t.leader_id == state.player_id and state.player_id != -1: continue
		# 糧 < 3 天不復工（餓肚子不搬磚 — 否則和 survival 搶人 ping-pong）
		# WS-2c：有效糧(私產+自家糧倉)，否則定居隊 food 在糧倉→誤判餓→永不復工建造。
		var days_left: float = ResourceSystem.effective_food(state, t) \
			/ maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		if days_left < 3.0:
			if Probe.enabled: Probe.bump("resume.reject_starving")   # ★純觀測
			continue
		var is_owner: bool = t.team_id == tile.outpost_owner
		var resident_here: bool = t.tile_pos == tile.tile_pos \
			and t.faction_id == leader_team.faction_id and t.faction_id != -1 \
			and TeamData.TAG_PRODUCE in t.tags
		if not (is_owner or resident_here):
			# ★純觀測:非 owner 亦非 resident（founding 荒地 owner==-1 恆假=#4 二階候選）
			if Probe.enabled:
				Probe.bump("resume.reject_owner" if not is_owner else "resume.reject_resident")
			continue
		# 已在工地的 return_home 殭屍態（到家但飢餓 sticky）也可復工
		var at_site_stuck: bool = t.tile_pos == tile.tile_pos \
			and t.current_task == TeamData.TASK_RETURN_HOME
		if not (t.current_task in interruptible or at_site_stuck):
			if Probe.enabled: Probe.bump("resume.reject_busy")   # ★純觀測
			continue
		if t.tile_pos == tile.tile_pos:
			candidates.push_front(t)   # 在場優先
		else:
			candidates.append(t)
	# ★resume attempt tap（純觀測）：候選數揭召回為何失效（0=無人可召=#4 坐實）。
	if Probe.enabled:
		Probe.bump("resume.attempt")
		Probe.bump_sample("resume.attempt", {
			"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
			"ct_id": tile.construction_team_id, "candidates": candidates.size(),
			"outpost_owner": tile.outpost_owner,
		})
	if candidates.is_empty(): return
	var worker: TeamData = candidates[0]
	if Probe.enabled:
		Probe.bump("resume.success")   # ★純觀測
		Probe.bump_sample("resume.success", {
			"tick": state.world.current_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
			"worker": worker.team_id,
		})
	# release-first：zombie 現任常 RETURN_HOME survival@80，先 release→IDLE@0 過 transition guard，再 set BUILD（正當復工退場）。
	TaskArbiter.release(worker)
	TaskArbiter.transition(state, worker, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
	worker.move_target = tile.tile_pos
	print("[Infra] Team%d 復工 at (%d,%d)%s" % [worker.team_id,
		tile.tile_pos.x, tile.tile_pos.y,
		"" if worker.tile_pos == tile.tile_pos else "（趕路中）"])

# tile 上可施工的居民團（PRODUCE、閒置非戰鬥；擁有權由 _subteam_upgrade_facility 驗證）
func _resident_team_for_construction(state: WorldState, tile: HexTileData) -> TeamData:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != tile.tile_pos: continue
		if not (TeamData.TAG_PRODUCE in t.tags): continue
		if t.combat_target != -1: continue
		if t.current_task == TeamData.TASK_BUILD: continue
		return t
	return null

# 無多餘 named → 升一名 anon 為工頭（同 residency dispatch 機制）
func _pick_or_promote_advisor(state: WorldState, team: TeamData) -> int:
	var advisor_id: int = _pick_advisor(team)
	if advisor_id != -1:
		return advisor_id
	var new_advisor: PersonData = PersonGenerator.generate_for_team(state, team, "member")
	if new_advisor == null:
		return -1
	state.add_member(team, new_advisor.id)   # 拔擢 anon→named 工頭
	return new_advisor.id

# ★means-end S5 委派：goal delegate candidate 贏 → 派子隊執行其 action（build/settle），母隊留守本業。
# 接既有 SubteamSystem.dispatch（advisor+settler pop+action task/target）。回 true=派出成功。
func _dispatch_goal_delegate(state: WorldState, team: TeamData, td: Dictionary) -> bool:
	var target: Vector2i = td.get("target", Vector2i(-1, -1))
	# ★後勤 SLICE A/B：deliver（賣外）/distribute（領主分配子民）convoy 分支 → 派 porter 子隊（同脊椎）。
	if String(td.get("kind", "")) == "deliver" or String(td.get("kind", "")) == "distribute":
		return _dispatch_convoy(state, team, td)
	# ★資訊網 Part2 (a)：求援/偵察 已脫離主 argmax/delegate → 移到 _info_side_dispatch 平行步（此處無 help/scout 分支）。
	# ★A1 founding 分支：新建 outpost → 複用 _dispatch_builder（含 afford/pop/advisor gate + TASK_CONSTRUCT 子隊 consumer）。
	if td.has("build_type"):
		return _dispatch_builder(state, team, target, String(td["build_type"]), 1)
	# ★A1 裁①(二裁意圖「接 infra path 非另立子隊路」)：facility 分支只走 owner-不在場 remote 子隊。
	# same-tile(owner 在場)facility 已在 _resolve_build_facility defer 給 infra path（infra desire-based
	# _pick_facility 選最想建的+就地建=較 goal REGISTRY-order 聰明+單一 build slot 不撞），此處不再生同格 candidate。
	if td.has("facility"):
		return _dispatch_facility_builder(state, team, target, String(td["facility"]))   # owner 遠離 own outpost → remote 子隊真移動→抵達→建
	# 既有 build/settle 委派（S5）→ generic subteam dispatch。
	var advisor_id: int = _pick_or_promote_advisor(state, team)
	if advisor_id == -1:
		return false
	var settler: int = int(td.get("settler", clampi(team.population / 4, 2, 5)))
	var action_task: String = String(td.get("task", TeamData.TASK_BUILD))
	var sub_id: int = SubteamSystem.new().dispatch(state, team.team_id, advisor_id, settler, action_task, target)
	return sub_id != -1

# ★後勤 SLICE A（spec 2026-07-31 訂正版 §3）：派 porter 子隊送 surplus 到 demand 市場（FETCH cargo=exact load，conserving）。
const UNREST_STARVE_DAYS: float = 2.0     # ★SLICE B D — 居民 runway < 此=持續 deficit→unrest+（餵 defection≥20）
# ★SLICE B D：居民 deficit→unrest / 受補回升→relief（per-cadence，餵現成 unrest_turns≥20 defection）。純算術零 RNG。
func _tick_resident_unrest(state: WorldState, team: TeamData) -> void:
	var runway: float = GoalResolver._resident_food_runway(state, team)
	if runway < UNREST_STARVE_DAYS:
		UnrestBank.add(team, 1, "領主斷糧/剝削")   # 持續斷糧/剝削買不夠 → 民怨↑
		if Probe.enabled: Probe.bump("distribute.unrest_add")
	elif runway > GoalResolver.DISTRIB_DEFICIT_DAYS and team.unrest_turns > 0:
		UnrestBank.reduce(team, 1, "領主施捨")   # 受補回升安全線 → 民怨↓
		if Probe.enabled: Probe.bump("distribute.unrest_reduce")

const CONVOY_PORTER_POP: int = 2          # TEST VALUE — porter 子隊 pop（小，只搬貨）
const CONVOY_MIN_PARENT_POP: int = 4      # TEST VALUE — 母隊抽 porter 後留守下限（比 build gate 10 輕，porter 小）
const CONVOY_CARGO_CAP: float = 200.0     # TEST VALUE — 單趟載重上限
func _dispatch_convoy(state: WorldState, team: TeamData, td: Dictionary) -> bool:
	var target: Vector2i = td.get("target", Vector2i(-1, -1))
	if target == Vector2i(-1, -1) or target == team.tile_pos:
		return false
	if team.population < CONVOY_MIN_PARENT_POP:
		return false
	var cargo: Dictionary = td.get("cargo", {})
	if cargo.is_empty():
		return false
	# ★throttle：一隊同時只一 convoy 在飛（防 surplus 每 cadence 重派 porter storm→warring 49 隊 porter 爆炸 perf 死）。
	for tid in state.teams:
		var pt: TeamData = state.teams[tid]
		if pt.parent_team_id == team.team_id and pt.current_task == TeamData.TASK_CONVOY:
			return false
	var res: String = String(cargo.keys()[0])
	var want_qty: float = minf(float(cargo[res]), CONVOY_CARGO_CAP)
	var home_tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var vault: float = float(home_tile.public_storage.get(res, 0)) if (home_tile != null \
		and home_tile.outpost_owner == team.team_id) else 0.0
	var load: float = minf(want_qty, float(team.resources.get(res, 0)) + vault)
	if load < 1.0:
		return false   # 母隊實無貨可載
	var advisor_id: int = _pick_or_promote_advisor(state, team)
	if advisor_id == -1:
		return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, team.team_id, advisor_id, CONVOY_PORTER_POP, TeamData.TASK_CONVOY, target)
	if sub_id == -1:
		return false
	var sub: TeamData = state.teams[sub_id]
	# ★重診 instrument：FETCH 前源分佈（母隊私產 vs vault）——split 後 porter 已帶 frac×res。
	var parent_priv_after_split: float = float(team.resources.get(res, 0))
	var porter_after_split: float = float(sub.resources.get(res, 0))
	_load_convoy_cargo(team, sub, home_tile, res, load)   # ★FETCH：cargo 設 exact load（conserving）
	sub.task_extra_data = {
		"convoy_phase": "OUTBOUND", "cargo_res": res, "cargo_qty": load,
		"market_pos": target, "home_pos": team.tile_pos, "order_id": int(td.get("order_id", -1)),
		# ★SLICE B：distribute convoy 帶 kind + price_factor（DELIVER 注入 override_ask=local_value×price_factor）。deliver 走 -1 現行。
		"convoy_kind": String(td.get("kind", "deliver")),
		"price_factor": float(td.get("price_factor", -1.0)),
	}
	Probe.bump("convoy.dispatch")
	if String(td.get("kind", "")) == "distribute": Probe.bump("distribute.dispatch")   # SLICE B tap
	Probe.bump("convoy.fetch")
	if Probe.enabled:
		Probe.add_amount("convoy.cargo_out", load)
		# ★per-convoy FETCH trajectory（純觀測，定 26% 根:載 0 vs 載了丟）
		Probe.bump_sample("convoy.fetch_traj", {
			"porter": sub_id, "res": res, "load_target": load,
			"parent_vault_pre": vault, "parent_priv_post_split": parent_priv_after_split,
			"porter_post_split": porter_after_split, "porter_loaded": float(sub.resources.get(res, 0)),
		}, 16)
	print("[Convoy] Team%d 派運輸子隊 Team%d 送 %s×%.0f → demand 市場(%d,%d)" % [
		team.team_id, sub_id, res, load, target.x, target.y])
	return true

# FETCH cargo 撥載：porter 設 exact load（dispatch 已帶 frac×res；調整 delta 從母隊 inventory→vault 補、或退多餘）。守恆。
func _load_convoy_cargo(owner: TeamData, sub: TeamData, home_tile: HexTileData, res: String, load: float) -> void:
	var cur: float = float(sub.resources.get(res, 0))
	var delta: float = load - cur
	if delta > 0.0:
		var from_inv: float = minf(delta, float(owner.resources.get(res, 0)))
		if from_inv > 0.0:
			ResourceBank.add(owner, res, -from_inv, "convoy_load_inv_out")
			ResourceBank.add(sub, res, from_inv, "convoy_load_in")
			delta -= from_inv
		if delta > 0.0 and home_tile != null and home_tile.outpost_owner == owner.team_id:
			var v: float = float(home_tile.public_storage.get(res, 0))
			var from_vault: float = minf(delta, v)
			if from_vault > 0.0:
				home_tile.public_storage[res] = v - from_vault
				ResourceBank.add(sub, res, from_vault, "convoy_load_vault_in")
	elif delta < 0.0:
		ResourceBank.add(sub, res, delta, "convoy_unload_excess_out")       # delta<0 → 減 porter
		ResourceBank.add(owner, res, -delta, "convoy_unload_excess_in")     # 退母隊

# 撥付建造款：公庫優先。目標 tile 公庫足 → 子隊不需補（抵達後 _deduct_cost 自扣公庫）；
# 僅當「公庫 + 子隊私產」不足時，owner 私產補差額（守恆：純轉移）。
# tile 可能為 null（無 outpost 目標格）→ 退化為純 owner 私產補足。
func _fund_subteam_cost(owner_team: TeamData, sub: TeamData, tile, cost: Dictionary) -> void:
	for k in cost:
		if k == "ticks": continue
		var vault: float = float(tile.public_storage.get(k, 0)) if tile != null else 0.0
		var have: float = vault + float(sub.resources.get(k, 0))
		var need: float = maxf(float(cost[k]) - have, 0.0)
		if need <= 0.0: continue
		var transfer: float = minf(need, float(owner_team.resources.get(k, 0)))
		ResourceBank.add(sub, k, transfer, "fund_sub_in")
		ResourceBank.add(owner_team, k, -transfer, "fund_sub_out")

# 腳下公庫撥付（caravan-load 新據點）：home_tile 公庫優先裝車，差額補 owner 私產。
# 新據點目標格無公庫 → 子隊背 cost 上路，抵達後 start_build fallback 子隊私產扣款。守恆純轉移。
func _fund_subteam_from_vault(_state: WorldState, owner: TeamData, sub: TeamData,
		home_tile: HexTileData, cost: Dictionary) -> void:
	var vault: Dictionary = home_tile.public_storage if (home_tile != null \
		and home_tile.outpost_owner == owner.team_id) else {}
	for k in cost:
		if k == "ticks": continue
		var need: float = maxf(float(cost[k]) - float(sub.resources.get(k, 0)), 0.0)
		if need <= 0.0: continue
		var from_vault: float = minf(need, float(vault.get(k, 0)))
		if from_vault > 0.0:
			vault[k] = float(vault.get(k, 0)) - from_vault
			ResourceBank.add(sub, k, from_vault, "fund_vault_in")
			need -= from_vault
		if need > 0.0:
			var t: float = minf(need, float(owner.resources.get(k, 0)))
			ResourceBank.add(owner, k, -t, "fund_vault_owner_out")
			ResourceBank.add(sub, k, t, "fund_vault_owner_in")

# 派擴建子隊（task="擴建"，附 facility_type）
func _dispatch_facility_builder(state: WorldState, owner_team: TeamData, outpost_pos: Vector2i,
		facility_type: String) -> bool:
	var tile: HexTileData = state.world.tiles.get(outpost_pos.x * 1000 + outpost_pos.y)
	if tile == null or tile.outpost_owner != owner_team.team_id: return false
	if tile.construction_team_id != -1: return false
	var def: Dictionary = OutpostSystem.FACILITY_DEF[facility_type]
	var cur_lvl: int = int(tile.get(def["current_level_key"]))
	var cost: Dictionary = OutpostSystem.upgrade_cost(facility_type, cur_lvl + 1)
	# 公庫+私產合併池（擴建在自有 tile，公庫本地可用 → W4 解）
	for k in cost:
		if k == "ticks": continue
		var avail: float = float(tile.public_storage.get(k, 0)) + float(owner_team.resources.get(k, 0))
		if avail < float(cost[k]) * 1.5: return false
	var advisor_id: int = _pick_or_promote_advisor(state, owner_team)
	if advisor_id == -1: return false
	if owner_team.population < 6: return false
	var sub_id: int = SubteamSystem.new().dispatch(
		state, owner_team.team_id, advisor_id, 3, TeamData.TASK_EXPAND, outpost_pos)
	if sub_id == -1: return false
	_fund_subteam_cost(owner_team, state.teams[sub_id], tile, cost)
	state.teams[sub_id].task_extra_data = { "facility_type": facility_type }
	print("[Infra] Team%d 派擴建子隊 Team%d → (%d,%d) %s" % [
		owner_team.team_id, sub_id, outpost_pos.x, outpost_pos.y, facility_type])
	return true

# ──────── 新據點選址評分 ────────

const MIN_BUILD_SCORE: float = 50.0

const TERRAIN_BUILD_BONUS: Dictionary = {
	"plains": 20.0, "forest": 10.0, "mountain": -10.0,
}

const MINING_GREED_WEIGHT: float = 2.5   # TEST VALUE — 礦村建址貪婪加權；過頻調低/魂不 fire 調高
const MINING_GREED_THRESHOLD: float = 1.1  # TEST VALUE — 貪婪+野心 >= 此值才觸發礦山首選（普通 leader 不建礦=稀有擬真）
const ORE_MOUNTAIN_MAX_DIST: int = 7    # TEST VALUE — 貪婪 leader 搜索礦山距離（大地圖 r=8 礦山可能遠於普通 dist=5）

# 選址資源權重（候選格本格 + 鄰 6 格，每點資源出現一次加一次）TEST VALUES
const SITE_RES_BONUS: Dictionary = {
	"herb": 30.0, "wild_horses": 25.0, "ore_iron": 20.0,
	"ore_gold": 35.0, "ore_silver": 35.0,
}

# 回傳最佳候選 { "pos": Vector2i, "score": float, "tile": HexTileData }，無則 {}。
# 多中心滾動拓殖：候選 = 任一 center（leader 所在 + faction 所有 outpost）dist 2-5。
# S2 修：貪婪/野心 leader（greed+ambition >= MINING_GREED_THRESHOLD）搜索距離擴至 ORE_MOUNTAIN_MAX_DIST。
func _evaluate_new_outpost_location(state: WorldState, leader_team: TeamData) -> Dictionary:
	var candidates: Array = []
	var centers: Array = [leader_team.tile_pos]
	for tile_id in state.world.tiles:
		var t: HexTileData = state.world.tiles[tile_id]
		if t.outpost_owner == -1 or t.outpost_level == 0: continue
		var o: TeamData = state.teams.get(t.outpost_owner)
		if o != null and o.faction_id == leader_team.faction_id and leader_team.faction_id != -1:
			if not centers.has(t.tile_pos):
				centers.append(t.tile_pos)
	# 預計算 leader 貪婪+野心（決定是否擴大礦山搜索範圍）
	var ldr: PersonData = state.persons.get(leader_team.leader_id)
	var ldr_greed: float = float(ldr.values.get("貪婪", 0.5)) if ldr != null else 0.5
	var ldr_ambition: float = float(ldr.values.get("野心", 0.5)) if ldr != null else 0.5
	var is_greedy_leader: bool = (ldr_greed + ldr_ambition) >= MINING_GREED_THRESHOLD
	# 敵 outpost 位置一次收集（hoist：原每 candidate 全圖掃 = O(tiles²) → 500-tick infra spike 根）
	var enemy_outposts: Array = _enemy_outpost_positions(state, leader_team)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0: continue
		var dist: int = 9999
		for c in centers:
			var d: int = _hex_dist(c, tile.tile_pos)
			if d < dist: dist = d
		# S2 礦村：含礦山地允 dist=1（山地常緊鄰既有據點，dist<2 過濾會排除 ore mountain）
		# resource_cap 記初始礦量（永不清零），比 resources 更可靠（施工期已被採集可能=0）
		var is_ore_mountain: bool = tile.terrain == "mountain" \
			and (float(tile.resource_cap.get("ore_gold", 0)) > 0.0 \
				or float(tile.resource_cap.get("ore_silver", 0)) > 0.0)
		var min_dist: int = 1 if is_ore_mountain else 2
		# S2 礦村搜索擴距：貪婪 leader 對礦山搜索 dist 擴至 ORE_MOUNTAIN_MAX_DIST（r=8 礦山常在邊陲）
		var max_dist: int = ORE_MOUNTAIN_MAX_DIST if (is_ore_mountain and is_greedy_leader) else 5
		if dist > max_dist or dist < min_dist: continue
		var score: float = float(tile.productivity) * 100.0
		score += float(TERRAIN_BUILD_BONUS.get(tile.terrain, 0))
		score -= float(dist) * 5.0
		score += clampf(10.0 - float(dist), 0.0, 10.0) * 2.0
		score += _site_resource_bonus(state, tile.tile_pos)
		# S2 礦村：含礦山地對貪婪/野心 leader 加權 ore bonus（壓過山地懲罰=蓄意富裕擴張；普通 leader 不選=稀有擬真）
		# 門檻 MINING_GREED_THRESHOLD：greed+ambition 須達此值才觸發（避免凡人 leader 也選礦山）
		if tile.terrain == "mountain" and is_greedy_leader:
			var ore_here: float = _site_resource_bonus_ore_only(state, tile.tile_pos)
			if ore_here > 0.0:
				score += ore_here * (ldr_greed + ldr_ambition) * MINING_GREED_WEIGHT   # TEST VALUE
		var min_enemy_dist: int = 9999
		for ep in enemy_outposts:
			var ed: int = _hex_dist(tile.tile_pos, ep)
			if ed < min_enemy_dist: min_enemy_dist = ed
		if min_enemy_dist < 5: score -= float(5 - min_enemy_dist) * 10.0
		if score >= MIN_BUILD_SCORE:
			candidates.append({ "pos": tile.tile_pos, "score": score, "tile": tile })
	if candidates.is_empty(): return {}   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	candidates.sort_custom(func(a, b): return a.score > b.score)
	var best: Dictionary = candidates[0]
	var sig: String = "%d_%d" % [best.pos.x, best.pos.y]
	if _last_site_sig.get(leader_team.faction_id, "") != sig:
		_last_site_sig[leader_team.faction_id] = sig
		print("[Site] 選址 %s score=%.0f 周邊資源=%s terrain=%s" % [
			str(best.pos), best.score, str(_site_resources_nearby(state, best.pos)), best.tile.terrain])
	return best

func _site_resource_bonus(state: WorldState, pos: Vector2i) -> float:
	var bonus: float = 0.0
	# S2 修：ore_gold/silver 改用 resource_cap（永不清零），避免採集後相鄰 plains 評分大幅掉分
	# 其他資源（herb/wild_horses/ore_iron）仍用 resources（現存量影響農業選址合理）
	var ore_res: Array = ["ore_gold", "ore_silver"]
	for d in ([Vector2i.ZERO] as Array) + PathSystem.HEX_DIRS:
		var npos: Vector2i = pos + d
		var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
		if ntile == null: continue
		for res in SITE_RES_BONUS:
			var amt: float = float(ntile.resource_cap.get(res, 0)) \
				if res in ore_res else float(ntile.resources.get(res, 0))
			if amt > 0:
				bonus += float(SITE_RES_BONUS[res])
	return bonus

# S2 礦村：只計 ore_gold/silver（避免 herb/horse 干擾礦村加權判定）
func _site_resource_bonus_ore_only(state: WorldState, pos: Vector2i) -> float:
	var bonus: float = 0.0
	for d in ([Vector2i.ZERO] as Array) + PathSystem.HEX_DIRS:
		var npos: Vector2i = pos + d
		var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
		if ntile == null: continue
		for res in ["ore_gold", "ore_silver"]:
			# resource_cap 記初始礦量（永不清零），避免礦耗盡後選址加分消失
			if float(ntile.resource_cap.get(res, 0)) > 0:
				bonus += float(SITE_RES_BONUS.get(res, 0))
	return bonus

# 選址 log 用：本格+鄰 6 格的權重資源彙總
func _site_resources_nearby(state: WorldState, pos: Vector2i) -> Dictionary:
	var found: Dictionary = {}
	for d in ([Vector2i.ZERO] as Array) + PathSystem.HEX_DIRS:
		var npos: Vector2i = pos + d
		var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
		if ntile == null: continue
		for res in SITE_RES_BONUS:
			var amt: float = float(ntile.resources.get(res, 0))
			if amt > 0:
				found[res] = float(found.get(res, 0)) + amt
	return found

# 敵 outpost 位置集（非同 faction 的有主據點）。選址迴圈 hoist 用：候選 tile 對此小集取
# min-dist，取代原 per-candidate 全圖掃（同集合同 min 值 = 行為不變，純複雜度收斂）。
func _enemy_outpost_positions(state: WorldState, leader_team: TeamData) -> Array:
	var out: Array = []
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null: continue
		if owner.faction_id == leader_team.faction_id and owner.faction_id != -1: continue
		# ★god-view follow-up（belief-gate，store-free proxy）：只納「觀察者對 owner 有 belief（見過/聞得）」的敵據點
		# →只避已知敵、未見敵不避（更多衝突湧現，合鐵律）。belief-about-owner=imperfect proxy（belief_pos 給 owner 隊
		# last-seen 非據點位；owner 可 roam），但軟 penalty 容忍高、免建 team_outpost_known 大 store（R² 判 proxy 可接受）。
		# 全圖 loop 結構保留（hoist perf：候選對此集取 min-dist），belief filter 加 loop 內。
		if BeliefSystem.belief_pos(state, leader_team.team_id, owner.team_id) == Vector2i(-1, -1): continue
		out.append(tile.tile_pos)
	return out

# ──────── 基建主決策 ────────

const INFRA_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時評估一次

const ORE_CIVILIAN_PULL: float = 1.0   # S4.4 TEST VALUE：礦脈→貪婪領袖偏採礦村(mint)的人格加分

# leader values 決定新據點傾向（軍用 vs 民用）。S4.4：ore 機會融入人格秤（非硬 override）。
func _pick_outpost_type(state: WorldState, leader_team: TeamData, leader: PersonData,
		loc_tile: HexTileData = null) -> String:
	# 文明階梯：軍鎮需 tools；無 tools 來源 → 只能蓋民村（個性想軍鎮也買不起）
	var has_tools: bool = float(leader_team.resources.get("tools", 0)) >= 3.0 \
		or _faction_has_workshop(state, leader_team)
	if not has_tools:
		return "civilian"
	var military: float = float(leader.values.get("好戰", 0.5)) + float(leader.values.get("野心", 0.5))
	var civilian: float = float(leader.values.get("慎重", 0.5)) + float(leader.values.get("貪婪", 0.5))
	# S4.4 de-patch（§R² 補裁 1）：礦脈→採礦村(mint)機會融入人格秤——貪婪/mint-inclined 領袖偏 civilian
	# 採礦鑄幣；好戰領袖仍可選軍鎮防守。移除「含礦→硬改 civilian」override，決策交人格。
	if loc_tile != null and loc_tile.terrain == "mountain":
		var ore: float = float(loc_tile.resource_cap.get("ore_gold", 0)) \
			+ float(loc_tile.resource_cap.get("ore_silver", 0))
		if ore > 0.0:   # gate-ok: world-mechanic: 礦脈存在→貪婪加 civilian 分(資源存在檢,非硬閾決策)
			civilian += float(leader.values.get("貪婪", 0.5)) * ORE_CIVILIAN_PULL
	return "military" if military > civilian else "civilian"

func _faction_has_workshop(state: WorldState, leader_team: TeamData) -> bool:
	for tile_id in state.world.tiles:
		var t: HexTileData = state.world.tiles[tile_id]
		if t.outpost_level > 0 and int(t.manufacturing_level) > 0:
			if t.outpost_owner == leader_team.team_id:
				return true
			var o: TeamData = state.teams.get(t.outpost_owner)
			if o != null and o.faction_id == leader_team.faction_id and leader_team.faction_id != -1:
				return true
	return false

# S3 means-end 統一發起（涵蓋 faction_id=-1）：獨立定居隊對自家 outpost 走**同** `_pick_facility` argmax
# 自評估 + 建造 dispatch（非另開平行路）。閉合「想 goods→需設施→去蓋」回路（獨立隊 has_facility 成長路）。
# ★行為層待 measurer 坐實：統一路徑真讓獨立隊 has_facility 成長（full-HD 驗，非篤定）。
func _evaluate_independent_infrastructure(state: WorldState, team: TeamData) -> void:
	if team.combat_target != -1: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if team.leader_id == state.player_id and state.player_id != -1: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var own_pos: Vector2i = _find_own_outpost(state, team)
	if own_pos == Vector2i(-1, -1): return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
	if tile == null or tile.outpost_level == 0 or tile.construction_team_id != -1: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var pick: Dictionary = _pick_facility(state, team, tile, leader)   # 同 faction 隊 argmax 決策
	if pick.is_empty(): return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if pick.has("demolish_first"):
		OutpostSystem.new().demolish_facility(state, tile, pick["demolish_first"])
	# owner 在場就地開工，否則派 builder（同 _evaluate_infrastructure 施工路徑）
	if team.tile_pos == tile.tile_pos and team.current_task != TeamData.TASK_BUILD:
		if OutpostSystem.new()._subteam_upgrade_facility(state, team, tile, pick["facility"]):
			return
	else:
		_dispatch_facility_builder(state, team, tile.tile_pos, pick["facility"])

func _evaluate_infrastructure(state: WorldState, faction) -> void:
	var leader_team: TeamData = state.teams.get(faction.leader_team_id)
	if leader_team == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if leader_team.combat_target != -1: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var leader: PersonData = state.persons.get(leader_team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	# 玩家 leader → 不自動決策（後續用 AdvisorSystem.push_outpost_advice）
	if leader_team.leader_id == state.player_id and state.player_id != -1:
		return
	var _ti: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	# (1) 升級既有 outpost
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != leader_team.team_id: continue
		if tile.outpost_level >= 3 or tile.construction_team_id != -1: continue   # gate-ok: world-mechanic: outpost level cap (>=3)
		if _dispatch_upgrader(state, leader_team, tile.tile_pos, tile.outpost_level + 1):
			if SimRunner.phase_timing: _fai_pht("infra.upgrade", _ti)
			return
	if SimRunner.phase_timing: _ti = _fai_pht("infra.upgrade", _ti)
	# (2) 擴建設施（faction 內所有 outpost；owner 以自身 local 資料評估，
	#     就地施工優先：owner 在場 > 居民團 > 派擴建子隊）
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		if tile.construction_team_id != -1:
			if OutpostSystem.new().check_construction_timeout(state, tile):
				continue
			_try_resume_construction(state, tile, leader_team)
			continue
		var owner_team: TeamData = state.teams.get(tile.outpost_owner)
		if owner_team == null: continue
		if owner_team.team_id != leader_team.team_id \
				and (owner_team.faction_id != leader_team.faction_id or owner_team.faction_id == -1):
			continue
		# 玩家 team 不自動決策
		if owner_team.leader_id == state.player_id and state.player_id != -1: continue
		var owner_leader: PersonData = state.persons.get(owner_team.leader_id)
		if owner_leader == null: continue
		var pick: Dictionary = _pick_facility(state, owner_team, tile, owner_leader)
		if pick.is_empty(): continue
		if pick.has("demolish_first"):
			OutpostSystem.new().demolish_facility(state, tile, pick["demolish_first"])
		# owner 在場 → 就地開工（居民村長 / 領主駐地）
		if owner_team.tile_pos == tile.tile_pos and owner_team.combat_target == -1 \
				and owner_team.current_task != TeamData.TASK_BUILD:
			if OutpostSystem.new()._subteam_upgrade_facility(state, owner_team, tile, pick["facility"]):
				if SimRunner.phase_timing: _fai_pht("infra.facility", _ti)
				return
		# tile 上同 faction 居民團出工出料
		var resident: TeamData = _resident_team_for_construction(state, tile)
		if resident != null:
			if OutpostSystem.new()._subteam_upgrade_facility(state, resident, tile, pick["facility"]):
				print("[Infra] Team%d 令居民 Team%d 就地擴建 %s at (%d,%d)" % [
					owner_team.team_id, resident.team_id, pick["facility"],
					tile.tile_pos.x, tile.tile_pos.y])
				if SimRunner.phase_timing: _fai_pht("infra.facility", _ti)
				return
		if _dispatch_facility_builder(state, owner_team, tile.tile_pos, pick["facility"]):
			if SimRunner.phase_timing: _fai_pht("infra.facility", _ti)
			return
	if SimRunner.phase_timing: _ti = _fai_pht("infra.facility", _ti)
	# S4.3 de-patch（§R² 補裁 4）：移除 infra 層強制 GOVERN 攢公庫——govern 單一 owner = 引擎既有「駐守」
	# option（人格秤發起）；infra 層不派/不秤 govern，避 Team10 雙決策生產者互蓋 livelock 前科。
	# (3) 蓋新 outpost
	var loc: Dictionary = _evaluate_new_outpost_location(state, leader_team)
	if SimRunner.phase_timing: _ti = _fai_pht("infra.new_loc", _ti)
	if loc.is_empty(): return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	# S4.4：ore 機會已融入 _pick_outpost_type 人格秤（傳 loc_tile），移除硬 civilian override。
	var outpost_type: String = _pick_outpost_type(state, leader_team, leader, loc.get("tile", null))
	_dispatch_builder(state, leader_team, loc.pos, outpost_type, 1)

# ──────── 設施需求迴路（score = 地利 × (1+缺口) × 個性）────────

# 回傳 { "facility": name, "demolish_first"?: name }；{} = 不蓋
func _pick_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> Dictionary:
	var slot_full: bool = OutpostSystem.slots_used(tile) >= OutpostSystem.slot_cap(tile)
	# S4：移除飢餓 override——S2 survival-crush 已讓餓隊 farming score 主導(S2 gate 驗過)，override 冗餘。
	# 統一 argmax：未建設施中 _facility_score 最高者（farming 餓時經 survival-crush 自然勝出）。
	var best: String = ""
	var best_score: float = 0.05   # 門檻：score 太低不蓋（TEST VALUE）
	for f in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[f]
		if not (tile.outpost_type in def["allowed_outpost"]): continue
		if def.has("required_terrain") and tile.terrain != def["required_terrain"]: continue
		if int(tile.get(def["current_level_key"])) > 0: continue   # 已有 → 升級走另一路徑   # gate-ok: guard: 已有設施→升級 skip(selection)
		var s: float = _facility_score(state, team, tile, leader, f)
		if s > best_score:
			best_score = s
			best = f
	if best == "": return {}   # gate-ok: guard: best empty
	if not slot_full:
		return { "facility": best }
	# S4 demolish 泛化（全設施通用，非 farming 專屬）：slot 滿→best 遠勝最低 score 設施則拆建。
	# ★farming 受規則保護不列拆遷候選（_lowest_score_facility 排除）＝命脈食物設施不拆（§R² 補裁 2）。
	var lowest: String = _lowest_score_facility(state, team, tile, leader)
	if lowest == "":
		return {}
	if best_score > _facility_score(state, team, tile, leader, lowest) * DEMOLISH_MARGIN:
		return { "facility": best, "demolish_first": lowest }
	return {}

# S2 survival-crush（TEST VALUE）：餓→農田 score 壓過發展設施。urgency² 軟連續(非 cliff/binary tier)。
# crossover 交叉點合理範圍待 measurer tune；量級須讓中性餓隊 farming>workshop(直答 R① 駁表)。
const SURVIVAL_CRUSH: float = 5.0
const DEMOLISH_MARGIN: float = 1.5   # S4 TEST VALUE：slot 滿時 best 須 > 最低 score×此才拆建（避 thrash）
# S4.5 rule（§R² 補裁 3）：產糧設施集合（規則層，未來新增產糧設施加此）+ 短工期門檻。
const FOOD_FACILITIES: Array = ["farming"]   # 當前唯一產糧設施
const SURVIVAL_BUILD_MAX_TICKS: int = 120    # 短工期(farming 72 符合;workshop 168/mint 更高不符→照常中斷)

# S4.5：腳下正蓋產糧設施且短工期 → 建設即自救不中斷（means-end 規則，取代硬編 =="farming"）。
func _is_food_facility_short(facility: String) -> bool:
	if not (facility in FOOD_FACILITIES):
		return false
	var cost: Dictionary = OutpostSystem.FACILITY_DEF.get(facility, {}).get("cost", {})
	return int(cost.get("ticks", 9999)) <= SURVIVAL_BUILD_MAX_TICKS

func _facility_score(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData, facility: String) -> float:
	var base: float = _facility_terrain_fit(state, facility, tile) \
		* (1.0 + _facility_deficit(state, team, facility, tile)) \
		* _facility_personality(leader, OutpostSystem.FACILITY_DEF[facility])
	# S2：食物設施(farming)survival-crush——餓時人格化壓過發展。urgency 讀據點局部糧(granary seam)。
	if facility == "farming":
		var urgency: float = _facility_food_urgency(state, team, tile, leader)
		base *= (1.0 + SURVIVAL_CRUSH * urgency * urgency)
	return base

# S2 granary seam：facility-eval 食物天數讀**據點局部**（本 tile 糧倉 + 私產），非 wandering leader positional
# effective_food（隊不站自家 outpost→positional 退私產≈0→誤 hungry）。只改 facility-eval reader。
func _facility_food_days(state: WorldState, team: TeamData, tile: HexTileData) -> float:
	var granary: float = float(tile.public_storage.get("food", 0))
	var priv: float = float(team.resources.get("food", 0))
	var burn: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)   # ×0.8 flat 代謝(禁人格化)
	return (granary + priv) / burn

# S2 食安 urgency [0,1]：人格安全天視野(food_security_target,×7 死常數退役)−據點局部 food_days，軟連續。
func _facility_food_urgency(state: WorldState, team: TeamData, tile: HexTileData, leader: PersonData) -> float:
	var tgt: float = DecisionTerms.food_security_target(leader.values)   # 人格化安全天(慎重 buffer 大→餓更晚仍發展)
	var fdays: float = _facility_food_days(state, team, tile)
	return clampf((tgt - fdays) / maxf(tgt, 0.001), 0.0, 1.0)

# 拆遷候選：已建設施中 score 最低者。
# ★rule（§R² 補裁 2，非殘留 override）：farming＝受保護命脈食物設施，不為蓋他物拆除（世界規則）。
# 拆糧倉→下 tick 又餓→重蓋 thrash 風險，故農田恆不列拆遷候選。
func _lowest_score_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> String:
	var lowest: String = ""
	var lowest_score: float = INF
	for f in OutpostSystem.FACILITY_DEF:
		if f == "farming": continue   # rule：命脈食物設施不拆
		var def: Dictionary = OutpostSystem.FACILITY_DEF[f]
		if int(tile.get(def["current_level_key"])) == 0: continue
		var s: float = _facility_score(state, team, tile, leader, f)
		if s < lowest_score:
			lowest_score = s
			lowest = f
	return lowest

# 地利（本格+鄰 6 格觀察，不全知）。TEST VALUES
func _facility_terrain_fit(state: WorldState, facility: String, tile: HexTileData) -> float:
	match facility:
		"farming":
			return clampf(tile.harvest_factor, 0.1, 2.0)
		"workshop":
			return 2.0 if _nearby_has_terrain(state, tile, "forest") else 1.0
		"apothecary":
			return 3.0 if _nearby_resource(state, tile, ["herb"]) > 0.0 else 0.0   # gate-ok: world-mechanic: resource-presence geography(terrain fit)
		"smeltery", "weaponsmith", "armorsmith":
			return 3.0 if _nearby_resource(state, tile, ["ore_iron"]) > 0.0 else 0.5   # gate-ok: world-mechanic: resource-presence geography(terrain fit)
		"mint":
			return 3.0 if _nearby_resource(state, tile, ["ore_gold", "ore_silver"]) > 0.0 else 0.3   # gate-ok: world-mechanic: resource-presence geography(terrain fit)
		"stable":
			# required_terrain=plains 已 gate；鄰格野馬 → ×3
			return 3.0 if _nearby_resource(state, tile, ["wild_horses"]) > 0.0 else 1.0   # gate-ok: world-mechanic: resource-presence geography(terrain fit)
	return 1.0

# ★seam#2 S1 registry 化（byte-identical 純重構）：facility deficit 資料驅動。
# 加 A 類設施 = 加 FACILITY_DEFICIT_DEF 1 entry（泛型 evaluator 自動處理）。
# A 類（NeedOracle-gap）：{outputs, use_demand, agg_mode, output_scale, militancy_scaled, gating?}。
#   agg_mode="min_per_res"(workshop worst bottleneck) | "pooled_sum"(多資源加總，單資源等價)。
# C 類（非 res-gap，語意真異質不硬併=seam#1 threat 教訓）：{special:"<method>"} dispatch 專屬 evaluator。
# ★命名 FACILITY_DEFICIT_DEF（非 spec 字面 FACILITY_DEF）：避與同檔 OutpostSystem.FACILITY_DEF(build 元資料)混淆。
# ★const→static var：擴充 proof 需 runtime 加 entry（entry 純資料，非 Callable）。
static var FACILITY_DEFICIT_DEF: Dictionary = {
	# C 類特殊 evaluator（granary 局部糧 / armed_ratio / tile ore）——不泛型化
	"farming":     {"special": "_deficit_farming"},
	"weaponsmith": {"special": "_deficit_weaponsmith"},
	"mint":        {"special": "_deficit_mint"},
	# A 類泛型（NeedOracle-gap）
	"workshop":    {"outputs": ["goods", "tools", "arrows"], "use_demand": true,  "agg_mode": "min_per_res", "output_scale": 1.0, "militancy_scaled": false},
	"apothecary":  {"outputs": ["medicine"],                 "use_demand": false, "agg_mode": "pooled_sum",  "output_scale": 0.5, "militancy_scaled": false},
	"armorsmith":  {"outputs": ["armor_low", "armor_high"],  "use_demand": false, "agg_mode": "pooled_sum",  "output_scale": 1.0, "militancy_scaled": true},
	"smeltery":    {"outputs": ["ore_steel"],                "use_demand": false, "agg_mode": "pooled_sum",  "output_scale": 1.0, "militancy_scaled": false, "gating": "smeltery"},
	"stable":      {"outputs": ["mounts"],                   "use_demand": false, "agg_mode": "pooled_sum",  "output_scale": 1.0, "militancy_scaled": false},
}

# 缺口（自身庫存 threshold，0–1）。TEST VALUES。★registry dispatch：A 類泛型 evaluator + C 類 special。
# S6：non-food QUANTITY-target 讀 NeedOracle need（與生產/商業共讀同源）；farming granary/weaponsmith(armed_ratio)/mint(ore-tile)=C 特殊。
func _facility_deficit(state: WorldState, team: TeamData, facility: String,
		tile: HexTileData) -> float:
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var entry: Dictionary = FACILITY_DEFICIT_DEF.get(facility, {})
	if entry.is_empty(): return 0.0   # gate-ok: guard: entry empty
	# C 類：專屬 evaluator（非 NeedOracle res-gap，語意真異質不硬併）。
	if entry.has("special"):
		return float(call(entry["special"], state, team, tile, lv))
	# B facility-gating（smeltery 需 weapon/armorsmith 存在）。
	if entry.get("gating", "") == "smeltery":
		if tile.weaponsmith_level == 0 and tile.armorsmith_level == 0: return 0.0   # gate-ok: world-mechanic: smeltery gating(weapon/armorsmith 存在)
	# A 類泛型 evaluator（NeedOracle-gap）。
	var outputs: Array = entry["outputs"]
	var use_demand: bool = entry["use_demand"]
	var deficit: float
	if entry["agg_mode"] == "min_per_res":
		# worst bottleneck：逐資源算比取最差（某資源夠≠整體夠）。goods=demand 驅、tools/arrows=need_keep。
		var worst: float = 1.0
		for res in outputs:
			var tgt: float = NeedOracle.need_keep(state, team, res, lv)
			if use_demand:
				tgt += NeedOracle.demand(state, team, res, lv)
			if tgt <= 0.001:   # gate-ok: guard: tgt<=0.001(該 res 無 need→不驅 deficit)
				continue   # 該 res 無 need(+demand) → 不驅 deficit
			worst = minf(worst, float(team.resources.get(res, 0)) / tgt)
		deficit = clampf(1.0 - worst, 0.0, 1.0)
	else:
		# pooled_sum：多資源先加總持有 vs 加總目標再算比（可互抵；單資源等價 min_per_res）。
		var total_hold: float = 0.0
		var total_tgt: float = 0.0
		for res in outputs:
			total_hold += float(team.resources.get(res, 0))
			var tgt: float = NeedOracle.need_keep(state, team, res, lv)
			if use_demand:
				tgt += NeedOracle.demand(state, team, res, lv)
			total_tgt += tgt
		if total_tgt <= 0.001: return 0.0   # gate-ok: guard: total_tgt<=0.001(pooled 目標 0→不驅)
		deficit = clampf((total_tgt - total_hold) / total_tgt, 0.0, 1.0)
	deficit *= float(entry["output_scale"])
	if entry["militancy_scaled"]:
		deficit *= _militancy(team, lv)   # 閘1 de-patch：軍備由人格 militancy 秤（armorsmith）
	return deficit

# ── C 類 special evaluator（非 NeedOracle res-gap，語意真異質，registry special dispatch）──
# farming：granary 局部糧缺口（S2 granary seam，非 positional effective_food：隊不在家→誤缺口恆滿）。
func _deficit_farming(_state: WorldState, team: TeamData, tile: HexTileData, _lv: Dictionary) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	var target: float = pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 14.0
	var local_food: float = float(tile.public_storage.get("food", 0)) + float(team.resources.get("food", 0))
	return clampf((target - local_food) / target, 0.0, 1.0)

# weaponsmith：de-patch 閘1，armed_ratio 缺口 × militancy（軍備由人格秤，非反應式 threat gate）。
func _deficit_weaponsmith(_state: WorldState, team: TeamData, _tile: HexTileData, lv: Dictionary) -> float:
	return clampf(0.6 - team.armed_anon_ratio, 0.0, 1.0) * _militancy(team, lv)

# mint：TILE-bound ore 二元（public_storage 採後入庫 + resource_cap 礦脈標記；不含 team.resources：
# 持有 looted/traded ore 的非礦村 outpost 不應觸發 mint 建造）。
func _deficit_mint(_state: WorldState, _team: TeamData, tile: HexTileData, _lv: Dictionary) -> float:
	var ore_pub: float = float(tile.public_storage.get("ore_gold", 0)) \
		+ float(tile.public_storage.get("ore_silver", 0))
	var ore_cap: float = float(tile.resource_cap.get("ore_gold", 0)) \
		+ float(tile.resource_cap.get("ore_silver", 0))
	var ore: float = maxf(ore_pub, ore_cap * 0.5)
	return 1.0 if ore > 10.0 else 0.0

# 個性：1.0 + Σ values × pref
func _facility_personality(leader: PersonData, def: Dictionary) -> float:
	var mult: float = 1.0
	var pref: Dictionary = def.get("leader_pref", {})
	for k in pref:
		mult += float(leader.values.get(k, 0.5)) * float(pref[k])
	return mult

# 近期威脅：戰鬥中 / 有攻擊意圖 / 已知低評價 team
# de-patch 閘1：軍備傾向 militancy [0,1]——主動軍閥(好戰/征服 archetype)+交戰中 → 備戰；和平農夫低。
# 取代反應式 _threat_recent 硬 gate（拆「近期被打才備」）。純人格+狀態，零 randf。
func _militancy(team: TeamData, leader_values: Dictionary) -> float:
	var martial: float = float(leader_values.get("好戰", 0.5))
	var force_arch: float = 1.0 if team.ambition_archetype == AmbitionLadder.ARCHETYPE_FORCE else 0.0
	var in_combat: float = 1.0 if team.combat_target != -1 else 0.0
	return clampf(martial * 0.7 + force_arch * 0.4 + in_combat * 0.5, 0.0, 1.0)

func _nearby_resource(state: WorldState, tile: HexTileData, keys: Array) -> float:
	var total: float = 0.0
	var positions: Array = [tile.tile_pos]
	for d in PathSystem.HEX_DIRS:
		positions.append(tile.tile_pos + d)
	for pos in positions:
		var t: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
		if t == null: continue
		for k in keys:
			total += float(t.resources.get(k, 0))
	return total

func _nearby_has_terrain(state: WorldState, tile: HexTileData, terrain: String) -> bool:
	for d in PathSystem.HEX_DIRS:
		var pos: Vector2i = tile.tile_pos + d
		var t: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
		if t != null and t.terrain == terrain:
			return true
	return false

func _richest_member(state: WorldState, f) -> int:
	var best_tid: int    = -1
	var best_food: float = 0.0
	for mid in f.member_team_ids:
		if mid == f.leader_team_id or not state.teams.has(mid):
			continue
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var mfood: float = float(snap.get("food_est", 0.0))
		if mfood > best_food:
			best_food = mfood
			best_tid  = mid
	return best_tid

func _evaluate_survival(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1:
		return
	# 紮營到達結算（W1 hoist）：在 TASK_CAMP 途中，腳下若為無主可農地即立 crude camp + 釋放。
	# 移到 unified gate 前 → unified 隊（引擎派 TASK_CAMP）到達亦能立營。不依賴 days_left，
	# 對所有持 TASK_CAMP 隊成立；non-unified 隊行為不變（原即走到此）。
	if team.current_task == TeamData.TASK_CAMP:
		if establish_crude_camp(state, team):
			TaskArbiter.release(team)
			team.previous_task = ""
			return
		# 主動紮營到達目標格卻無法立營（該格已被占/變更）→ 釋放重評，避免凍結
		# （invariant：進得去出得來；主動 camp 免糧恢復釋放，故須補此到達兜底）
		if team.task_priority == TaskArbiter.PRIO_DISPATCH and team.tile_pos == team.move_target:
			TaskArbiter.release(team)
			team.previous_task = ""
			return
	# Fix1 退役非-unified 非子隊 legacy override（Team10 thrash 根：solo rank vs legacy override 雙決策生產者互蓋 livelock）。
	# 非子隊(parent_team_id==-1)有引擎求生路徑(_evaluate_solo→rank_scored, survival option 在 repertoire)→求生走引擎。
	# ★只退非子隊；子隊(parent_team_id!=-1)保留下方 legacy body——子隊 TASK_BUILD/CONSTRUCT 提前 return 不進引擎，
	#   全退會無求生評估→餓死 zombie(reviewer 抓的 regression)。
	if uses_unified(team) or team.parent_team_id == -1:
		return   # unified 任隊 / 非子隊 → 求生走引擎(DecisionEngine);舊系統不雙觸發
	# S2 礦村：建造子隊在途或施工中（TASK_CONSTRUCT/TASK_BUILD + parent 存在）→ 豁免求生打斷。
	# 背景：礦山偏遠、FAR 區 LOD 移動慢，bootstrap food 在途中耗盡；famine grace 7天。
	# builder 到達後立即起建（BUILD），山地 ore harvest 可快速補糧，不會死亡殭屍。
	# 限制：僅當建築地點有礦（ore mountain）時才豁免；普通 civilian 建造仍正常觸發求生。
	if team.parent_team_id != -1 \
			and team.current_task in [TeamData.TASK_CONSTRUCT, TeamData.TASK_BUILD]:
		var my_tile: HexTileData = state.world.tiles.get(
			team.tile_pos.x * 1000 + team.tile_pos.y)
		var tgt_tile: HexTileData = null
		if team.move_target != Vector2i(-1, -1):
			tgt_tile = state.world.tiles.get(team.move_target.x * 1000 + team.move_target.y)
		else:
			tgt_tile = my_tile   # 已到達，在建設格
		if tgt_tile != null and tgt_tile.terrain == "mountain" \
				and (float(tgt_tile.resource_cap.get("ore_gold", 0)) > 0.0 \
					or float(tgt_tile.resource_cap.get("ore_silver", 0)) > 0.0):
			return   # 礦山 builder/施工隊：豁免所有求生打斷（famine grace 保護）
	var pop_eff: int = team.population
	if pop_eff <= 0: return
	# WS-2c：讀有效糧（私產+自家糧倉），否則定居隊 food 在糧倉→誤判餓→永卡 survival。
	# 釋放檢查(下方 days_left>=RECOVER)同變數自動受惠。真絕境(皆空)仍正確進 survival。
	var food: float = ResourceSystem.effective_food(state, team)
	var food_per_day: float = float(pop_eff) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	var days_left: float = food / maxf(food_per_day, 0.001)
	# 已在 survival task：糧恢復(hysteresis)→ 釋放回 idle，讓建造/生產/攻擊接手
	# （核心修：原本 early-return 永不釋放 → return_home/乞食 永久 p80 凍結）
	# 例外：SoloAI 主動紮營（PRIO_DISPATCH）本就在不缺糧時觸發，不可被「糧足」釋放 →
	#   否則往鄰格 farmable 移動途中即被釋放、到不了 → 永遠重派 churn（移動 1 格即可結算）。
	if team.current_task in SURVIVAL_TASKS:
		var proactive_camp: bool = team.current_task == TeamData.TASK_CAMP \
			and team.task_priority == TaskArbiter.PRIO_DISPATCH
		if days_left >= SURVIVAL_RECOVER_DAYS and not proactive_camp:
			TaskArbiter.release(team)
			return
		# survival-latch 重選：仍餓 + 重評 cadence 到(或 crisis) → 重跑 survival 選擇(forage 失效換
		# 買糧/掠奪/併入)，非死鎖首選。proactive_camp 豁免(在途不打斷)。
		# ★R② 坐實 try_set 同-prio no-op → 必 release-then-retrigger(先 release→IDLE→_trigger_survival 成立)。
		if not proactive_camp and days_left < WARNING_DAYS \
				and (state.world.current_tick >= team.decision_eval_next_tick or _decision_crisis(state, team)):
			team.decision_eval_next_tick = state.world.current_tick \
				+ (DECISION_CADENCE / 4 if _decision_crisis(state, team) else DECISION_CADENCE)
			# ★churn 防抖：release 前存 previous_task 供 rank_survival COMMITMENT 比對（release→IDLE 破基準）
			team.previous_task = team.current_task
			TaskArbiter.release(team)
			var severity: String = "urgent" if days_left < URGENCY_DAYS else "warning"
			_trigger_survival(state, team, severity)
		return
	if days_left < URGENCY_DAYS or days_left < WARNING_DAYS:
		var severity: String = "urgent" if days_left < URGENCY_DAYS else "warning"
		var prev_task: String = team.current_task
		_trigger_survival(state, team, severity)
		if team.current_task != prev_task:
			print("[Survival] Team%d %s days_left=%.1f %s→%s" % [
				team.team_id, severity, days_left, prev_task, team.current_task])

# NPC 主動獵獸：腳下有 predator + 戰力足 + 缺糧 → npc_combat 起獵。回傳是否發起。
func try_hunt_predator(state: WorldState, team: TeamData) -> bool:
	if team.beast_kind != "" or team.combat_target != -1:
		return false
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
		return false
	var leader = state.persons.get(team.leader_id)
	var combat: float = float(leader.skills.get("戰鬥", 0.0)) if leader else 0.0
	# 戰力門檻（TEST VALUE）：人多 + 有戰技才獵，弱隊不送死
	if team.population < 8 or combat < 0.3:
		return false
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	TileBank.pool_set(tile, "predator_density", int(tile.resources["predator_density"]) - 1, "hunt_predator")
	var bid: int = BeastSystem.new().build_beast_team(state, kind, team.tile_pos)
	NpcCombatSystem.new().start_combat(state, team.team_id, bid)
	return true

# 找本格+鄰格 無主(owner==-1, level==0) 可農(plains/forest) tile；無 → (-1,-1)。
func _find_unowned_farmable_tile(state: WorldState, team: TeamData) -> Vector2i:
	var dirs: Array = [Vector2i.ZERO, Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
		Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	for d in dirs:
		var p: Vector2i = team.tile_pos + d
		var tile: HexTileData = state.world.tiles.get(p.x*1000 + p.y)
		if tile == null: continue
		if tile.outpost_level > 0 or tile.outpost_owner != -1: continue
		if tile.terrain == "mountain": continue   # 山不可農（見山村特化待 spec）
		return p
	return Vector2i(-1, -1)

# 在腳下無主可農地即時立 crude civilian L1 camp（求生豁免，免建材/免工期）。回傳成功否。
func establish_crude_camp(state: WorldState, team: TeamData) -> bool:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x*1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level > 0 or tile.outpost_owner != -1:
		return false
	if tile.terrain == "mountain":
		return false
	var leader: PersonData = state.persons.get(team.leader_id)
	var martial: float = float(leader.values.get("好戰", 0.5)) if leader else 0.5
	var ambition: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
	var is_military: bool = (martial > 0.6 or ambition > 0.7)   # TEST VALUE 門檻
	tile.outpost_type = "military" if is_military else "civilian"
	tile.outpost_level = 1
	if Probe.enabled: Probe.bump("worldgen.build_outpost")   # world-gen variety 靶B：新開局 build-outpost 實測 fire
	OutpostOwnerBank.set_owner(tile, team.team_id, "camp")
	# 只抬 food cap（regen 才產糧）,不送即時糧。2026-06-16 A/B 量測:即時糧非 load-bearing
	# （拿掉後 2yr×4config died=0、pop 不掉）→ 移除以恢復絕境稀缺,與玩家紮營版一致。
	tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), CRUDE_CAMP_FOOD_SEED)
	# 身分躍遷（比照 _auto_settle_builder）：升軍/生產 tag、清流亡（流浪→定居，非一律生產）
	var new_tag: String = TeamData.TAG_MILITARY if is_military else TeamData.TAG_PRODUCE
	if not team.tags.has(new_tag):
		state.add_tag(team, new_tag, "crude_camp_settle")
	state.remove_tag(team, "流亡", "crude_camp_settle")
	print("[CrudeCamp] Team%d 紮營 @(%d,%d) → %s" % [
		team.team_id, team.tile_pos.x, team.tile_pos.y, tile.outpost_type])
	return true

func _trigger_survival(state: WorldState, team: TeamData, severity: String) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)

	# churn 防抖：relatch 路已 release→current_task=IDLE，勿以 IDLE 覆蓋 previous_task
	# （其保留 release 前的 survival task 供 rank_survival COMMITMENT 比對）。
	if team.current_task != TeamData.TASK_IDLE:
		team.previous_task = team.current_task

	# S4.5 rule 泛化（§R² 補裁 3，非硬編 =="farming"）：腳下正蓋**產糧設施 + 短工期**→建設即自救不中斷
	# （完工才是糧食出路，means-end 規則）。其他設施（鑄幣廠 30 天等）照常被飢餓中斷—不會蓋到餓死。
	if team.current_task == TeamData.TASK_BUILD:
		var cur_tile: HexTileData = state.world.tiles.get(
			team.tile_pos.x * 1000 + team.tile_pos.y)
		if cur_tile != null and cur_tile.construction_team_id == team.team_id \
				and _is_food_facility_short(str(cur_tile.construction_target.get("facility", ""))):
			team.previous_task = ""
			return

	# === 委派 engine survival-option scoring（單一 owner = DecisionTerms/DecisionOptions）===
	# 取代舊手寫 desperation×values branch（Path1 return/remote-loot + homeless loot/join/camp
	# + fallback forage/beg）。選擇全經 rank_survival → DecisionTerms weight × drive。
	# severity 不再對選擇加 gate（食物量級由 drive 自然表達）；entry gate(_evaluate_survival)
	# 仍用 WARNING/URGENCY 判何時進。承諾比對 current_task（non-unified 無 current_option 語意）。
	# ② 絕境階梯失敗回饋：偵測現承諾 option 是否 stall → 硬排除換次格（rank_survival 帶單一 option 豁免）。
	#   ★食 inline 算（effective_food，零 gather 零 RNG——避第二 gather 岔世界 seed42 regression）。
	_detect_survival_stall(state, team)
	for opt in DecisionEngine.rank_survival(state, team):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "finder_miss")   # 路徑維 tap：finder 撲空 attempt（churn 現形）
			continue   # finder 撲空（無可派目標）→ 試次佳 option
		# 投靠對象是玩家隊 → 改走 forced_event（玩家決定收留/婉拒），不自動 merge（同 P2a W2）
		if opt == "併入" and td.has("social_target"):
			var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
			if pp != null and int(td["social_target"]) == pp.team_id:
				if _maybe_request_join_player(state, team):
					return
		var _surv_ok: bool = TaskArbiter.try_set(state, team, td["task"], tgt, DecisionOptions.priority_for(opt), "survival")   # ★① 單一源(收 @80)
		if Probe.enabled and opt == "併入":   # DIAG C2：survival 路整併 dispatch（PRIO_SURVIVAL，正確路）
			Probe.bump("merge.surv_ok" if _surv_ok else "merge.surv_fail")
		if not _surv_ok:
			SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "try_set_noop")   # 路徑維 tap：try_set no-op fail attempt
		if _surv_ok:
			SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "committed")   # specimen tap（顯式 committed）
			_stamp_survival_commit(state, team, opt)   # ② 蓋章 committed option baseline（單一源全 5 路之一）
			if td.has("combat_target"):
				state.set_combat_target(team, int(td["combat_target"]))
			if td.has("social_target"):
				state.set_social_target(team, int(td["social_target"]))
			if td.has("order_target"):
				# S-A C2：整併 survival-class 需 order_target（此 survival 路無 _wire_threat_task→真缺口）
				team.order_target_id = int(td["order_target"])
			match opt:   # 保留分流診斷 marker（world_sim 量測 homeless 分流）
				"掠奪":
					Probe.bump("surv.loot_dispatch")   # R1 驗收哨：絕境仍搏（拔閘後 survival loot 不降）
					print("[SurvivalLoot] team=Team%d → 掠 Team%d" % [team.team_id, int(td.get("combat_target", -1))])
				"佔村":
					team.current_option = "佔村"   # capture 歸因用（survival 路不設 current_option → 補）
					Probe.bump("occupy.dispatch"); Probe.bump("occupy.dispatch_survival")
					print("[SurvivalOccupy] team=Team%d → 佔 Team%d" % [team.team_id, int(td.get("combat_target", -1))])
				"併入": print("[SurvivalMergeIn] team=Team%d → 併入 Team%d" % [team.team_id, int(td.get("social_target", -1))])
				"紮營": print("[SurvivalCamp] team=Team%d → 紮營 @(%d,%d)" % [team.team_id, tgt.x, tgt.y])
				"覓食": print("[SurvivalForage] team=Team%d pop=%d → 覓食 @(%d,%d)" % [team.team_id, team.population, tgt.x, tgt.y])
			return
	# 全不可派（無 spendable option）→ hunt fallback（無 TASK 不能 option 化，留 wrapper）→ release
	if try_hunt_predator(state, team):
		print("[BeastHunt] team=Team%d 主動獵腳下掠食者" % team.team_id)
		return
	# 全失敗 → 釋放回 idle（避空轉 latch；solo AI 接手或 famine 收場）
	TaskArbiter.release(team)
	team.previous_task = ""

# ② 絕境階梯：food_days inline 算（effective_food/pop×FPPD）——零 gather 零 RNG（STAMP/DETECT 共用，避第二 gather 岔世界）。
func _survival_food_days(state: WorldState, team: TeamData) -> float:
	var pop: int = team.population
	if pop <= 0: return 0.0
	return ResourceSystem.effective_food(state, team) \
		/ maxf(float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)

# crisis-override（OUTCOME-based 安全網，泛化 ② 到任何 committed task）：深餓（food<CRISIS_FLOOR）+ committed N 天未緩
# （food 沒回升 ≥RELIEF_MIN）→ true → caller release → 下 cadence re-rank → survival @80 preempt 卡住 task。
# baseline lazy 蓋（crisis_committed_tick != task_start_tick=新 task episode → 重蓋）；task 變自動重置=進度隊（② 換格/
# 正常完工）task_start_tick 變 → 計時歸零 → 不誤 fire。只讀自身 food_days（合憲，非 god-view）；零 RNG。
func _famine_crisis(state: WorldState, team: TeamData) -> bool:
	if team.current_task == TeamData.TASK_IDLE:
		return false   # 無 committed task → 自然 re-rank，無可 release
	var cur_food: float = _survival_food_days(state, team)
	# lazy baseline：新 task episode（task_start_tick 變）→ 重蓋，本 tick 不判（還沒累積 committed 時間）。
	if team.crisis_committed_tick != team.task_start_tick:
		team.crisis_committed_tick = team.task_start_tick
		team.crisis_committed_food = cur_food
		return false
	if cur_food >= CRISIS_FLOOR:
		return false   # 非深餓（淺餓由 SURVIVAL_BOOST/② 承接）
	if state.world.current_tick - team.task_start_tick < int(CRISIS_DAYS * float(WorldState.TICKS_PER_DAY)):
		return false   # committed 未到 N 天（給 task 工作時間，非急打斷 build 快完成）
	return cur_food - team.crisis_committed_food < DecisionEngine.STALL_RELIEF_MIN   # 未緩（reuse ② relief）→ crisis

# ② 絕境階梯 STAMP（單一源全 5 路 try_set 成功站呼）：蓋章真 option 字串 + tick + food baseline。
#   換到新 survival option 才重蓋（同 option 續承諾則 baseline 保留累積時間=stall 計時不 reset）。非 survival option 不蓋。
func _stamp_survival_commit(state: WorldState, team: TeamData, opt: String) -> void:
	if opt not in DecisionOptions.SURVIVAL_OPTION_SET: return
	if team.survival_committed_option == opt: return   # 同 option 續承諾：保留 baseline 累積 stall 時間
	team.survival_committed_option = opt
	team.survival_committed_tick = state.world.current_tick
	team.survival_committed_food = _survival_food_days(state, team)

# ② 絕境階梯 DETECT（全 5 路決策 entry per cadence 呼）：committed survival option stall 偵測。
#   committed N 天（耐性人格 scaled）後看 relief-magnitude：足→resolving（清 stall，X 起作用留它）；
#   不足/plateau→stall（硬排除該 option bounded window→ applicable() 排除→argmax 換次格；rank_survival 帶單一 option 豁免）。
#   ★食 inline（零 gather 零 RNG）。只讀自身 food_days（合憲，非 god-view）。
func _detect_survival_stall(state: WorldState, team: TeamData) -> void:
	if team.survival_committed_option == "":
		return   # 未承諾 → 無可偵（待 try_set 蓋章）
	var leader: PersonData = state.persons.get(team.leader_id)
	var vals: Dictionary = leader.values if leader != null else {}
	var patience: float = DecisionEngine.stall_patience_factor(vals)
	var stall_ticks: int = int(DecisionEngine.STALL_BASE_DAYS * patience * float(WorldState.TICKS_PER_DAY))
	var cur_food: float = _survival_food_days(state, team)
	# recover-restarve 邊界：committed 過久（曾食足離 survival 又回）→ baseline 陳舊 → 重置視為新 episode，不誤判 STALL。
	# （連續 latch 在 stall_ticks 就 fire 並清 committed；committed!="" 且 elapsed 遠超 stall_ticks+window = 必為 stale 再進。）
	if state.world.current_tick - team.survival_committed_tick > stall_ticks + DecisionEngine.STALL_EXCLUDE_WINDOW:
		team.survival_committed_tick = state.world.current_tick
		team.survival_committed_food = cur_food
		return
	var verdict: int = DecisionEngine.stall_verdict(team.survival_committed_tick, team.survival_committed_food,
		state.world.current_tick, cur_food, stall_ticks, DecisionEngine.STALL_RELIEF_MIN)
	match verdict:
		DecisionEngine.STALL_RESOLVING:
			team.survival_stall_cooldown.erase(team.survival_committed_option)   # relief expiry：清該 option cooldown
			team.survival_committed_option = ""   # 解承諾 → 下 cadence 正常重蓋
		DecisionEngine.STALL_STALLED:
			team.survival_stall_cooldown[team.survival_committed_option] = \
				state.world.current_tick + DecisionEngine.STALL_EXCLUDE_WINDOW   # 硬排除 bounded window
			team.survival_committed_option = ""   # 清蓋章 → applicable() 排除後選次格 → 新格重蓋
			if Probe.enabled: Probe.bump("survival.stall_exclude")
		# STALL_WAITING：耐性未耗盡，保持承諾續等

# 找最佳狩獵格：本格+鄰格 wild_game 最多的無 outpost tile；皆無 game → (-1,-1)（掉去乞食/loot）。
func _find_forage_tile(state: WorldState, team: TeamData) -> Vector2i:
	var best_pos: Vector2i = Vector2i(-1, -1)
	var best_game: int = 0
	var dirs: Array = [Vector2i.ZERO, Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
		Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	for d in dirs:
		var p: Vector2i = team.tile_pos + d
		var tile: HexTileData = state.world.tiles.get(p.x*1000 + p.y)
		if tile == null or tile.outpost_level > 0:
			continue
		var g: int = int(tile.resources.get("wild_game", 0))
		if g > best_game:
			best_game = g
			best_pos = p
	return best_pos

# Fix B 遷移找糧 finder：視野內可達 wild_game（pop 守衛）/ 已知食物賣單 pos（可達）取最近。
# 守感知鐵律：wild_game 只掃 VisionSystem 視野內（bounding box，非全圖 god-view）；賣單只讀 received（team_known）。
# 皆過 PathSystem 可達過濾（防選回不可達 target → dispatch→timeout→dispatch 永動死循環）。純確定性讀，零 randf。
func _find_food_seek_target(state: WorldState, team: TeamData) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var best_dist: int = 999999
	# (1) 視野內 wild_game（僅 pop <= FORAGE_VIABLE_POP 才算——否則 pop>15 追不到野味死＝新型不連貫死，正犯 C）
	if team.population <= FORAGE_VIABLE_POP:
		var vrange: int = VisionSystem.vision_range(state, team)
		for dx in range(-vrange, vrange + 1):
			for dy in range(-vrange, vrange + 1):
				var p: Vector2i = team.tile_pos + Vector2i(dx, dy)
				var d: int = _hex_dist(team.tile_pos, p)
				if d > vrange or d >= best_dist: continue
				var tile: HexTileData = state.world.tiles.get(p.x * 1000 + p.y)
				if tile == null or tile.outpost_level > 0: continue
				if int(tile.resources.get("wild_game", 0)) <= 0: continue
				if PathSystem.find_path(state, team.tile_pos, p).path.is_empty(): continue   # 不可達排除
				best = p; best_dist = d
	# (2) 已知食物賣單 pos（received=team_known，同 Fix A honest 來源；可達過濾）
	for _so in OrderSystem.new().received_sell_orders(state, team):
		if String(_so.get("res", "")) != "food": continue
		var sp: Vector2i = _so.get("pos", Vector2i.ZERO)
		if sp == Vector2i(-1, -1) or sp == Vector2i.ZERO: continue
		var d2: int = _hex_dist(team.tile_pos, sp)
		if d2 >= best_dist: continue
		if PathSystem.find_path(state, team.tile_pos, sp).path.is_empty(): continue
		best = sp; best_dist = d2
	return best

func _should_abandon_current_task(team: TeamData, survival_target: Vector2i) -> bool:
	if team.move_target == Vector2i(-1, -1):
		return true
	var cur_dist: int = _hex_dist(team.tile_pos, team.move_target)
	var surv_dist: int = _hex_dist(team.tile_pos, survival_target)
	return surv_dist <= cur_dist + 2

func _find_own_outpost(state: WorldState, team: TeamData) -> Vector2i:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
			return tile.tile_pos
	return Vector2i(-1, -1)

# ★資訊網 bootstrap-fix 名冊 fallback（組織常識：faction 成員天生知自家勢力固定據點位）。守 5 硬界：
# ①只回 tile_pos 零 live-state（runway/resources/pop 不讀，content 仍靠信使物理送）②只固定 outpost（移動隊無→-1 落 belief）
# ③同勢力 gate（他勢力/無 faction→-1）④MVP=當下 faction_id（分裂後 ex-faction→-1 零資訊；★非用戶 frozen-snapshot ④、known gap 未實作、non-blocking 現無 ex-faction 消費者）⑤隱匿據點旗（not outpost_hidden）。
# 感知鐵律：自家 faction 結構 outpost 位=靜態組織常識，非 indexed 他隊 live 態；constitution_gate legit intra-faction 結構。
static func _faction_roster_pos(state: WorldState, member: TeamData, target_id: int) -> Vector2i:
	if member.faction_id == -1:
		return Vector2i(-1, -1)   # ③無 faction 無名冊
	var target: TeamData = state.teams.get(target_id)
	if target == null or target.faction_id != member.faction_id:
		return Vector2i(-1, -1)   # ③他勢力/④分裂後 ex-faction（當下 faction_id gate；known gap:非 frozen snapshot）
	# ②只固定 outpost（inline _find_own_outpost 邏輯，static 免 new instance；移動 target 無 outpost→-1）
	for tile_id in state.world.tiles:   # gate-ok: own-faction infra 位掃（同 _find_own_outpost 地理型；讀 static outpost_owner 結構非 indexed 他隊 live 態，③faction gate 已限同勢力，感知鐵律 legit）
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == target_id:
			if tile.outpost_hidden:
				return Vector2i(-1, -1)   # ⑤隱匿據點不上名冊
			return tile.tile_pos          # ①只位置零 live-state
	return Vector2i(-1, -1)

func _estimate_eta_to(state: WorldState, team: TeamData, target: Vector2i) -> int:
	var path: Dictionary = PathSystem.find_path(state, team.tile_pos, target)
	if path.path.is_empty(): return 9999999
	return PathSystem.eta_ticks(team, path.cost)

func _find_weakest_prey(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: float = 999999.0
	var best_food: float = -1.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue   # 無情報→不選
		if not PathSystem.estimate_catch_up(state, team, tid, true).reachable: continue
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		var pop_est: float = float(bel.get("population_est", 0.0))
		if pop_est >= float(team.population) * 0.7: continue   # belief 看似不夠弱→跳
		# ②c：刪 food<20 硬濾（餓世界目標仍可俘——raid 收益=糧+人力+coin+裝備，窮村仍有人可俘）。
		# 弱點主排序不變（pop_est 最低）；同弱者（pop 近似，PREY_POP_TIE_EPS 帶寬內）food_est 高者優先（輕 tie-break，不蓋 pop 主序）。
		var food_est: float = float(bel.get("food_est", 0.0))
		if pop_est < best_pop - PREY_POP_TIE_EPS \
				or (absf(pop_est - best_pop) <= PREY_POP_TIE_EPS and food_est > best_food):
			best_pop = pop_est
			best_food = food_est
			best_id = tid
	return best_id

# §HOW-7 吸納 target：adapt _find_weakest_prey + ★capacity-bound（統領餘裕裝得下才吸，非直接複用攻擊 target）。
# 弱(pop_est<本隊*0.7)+近(reachable)+裝得下(pop_est <= pop_cap_from_leadership(統領)-本隊 pop)。回弱鄰 id / -1。
func _find_absorb_target(state: WorldState, team: TeamData) -> int:
	var ldr: PersonData = state.persons.get(team.leader_id)
	var cmd: float = float(ldr.skills.get("統領", 0.0)) if ldr else 0.0
	var slack: int = TeamData.pop_cap_from_leadership(cmd) - team.population
	if slack <= 0:
		return -1   # 無統領餘裕 → 吸不下
	var best_id: int = -1
	var best_pop: float = 999999.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue
		if not PathSystem.estimate_catch_up(state, team, tid, true).reachable: continue
		var pop_est: float = float(BeliefSystem.best_estimate(state, team.team_id, tid).get("population_est", 0.0))
		if pop_est >= float(team.population) * 0.7: continue   # 不夠弱
		if pop_est > float(slack): continue                    # ★capacity-bound：裝不下不吸
		if pop_est < best_pop:
			best_pop = pop_est
			best_id = tid
	return best_id

# 佔村 target 選擇（means-end：要據點的狼打「有據點的弱村」而非追流浪隊 → 戰落村格=capture 可翻+可據）。
# 可據信號=目標站在自家 outpost（村格；可見性物理，capture 落點=此格）；weakness 讀 belief（非 god-view）。
# 回最弱（belief pop_est 最低）可據村 team_id，無則 -1。
func _find_occupy_target(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: float = 999999.0
	var _occ_leader: PersonData = state.persons.get(team.leader_id)
	var leader_values: Dictionary = _occ_leader.values if _occ_leader != null else {}
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == team.faction_id: continue
		# 可據=站在自家 outpost 的定居村（村格）；已是自己的不算
		var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		if tile == null or tile.outpost_level == 0 or tile.outpost_owner != tid: continue
		if tile.outpost_owner == team.team_id: continue
		Probe.bump("occupy.scan_outpost_target")   # DIAG：站自家 outpost 的候選
		if not BeliefSystem.has_belief(state, team.team_id, tid):
			Probe.bump("occupy.scan_kill_nobel"); continue   # 無情報→不選（禁 god-view）
		# 近才佔：eta 超 OCCUPY_ETA_MAX 的遠村不選（久圍=乾耗餓死；佔村要打得到守得住）。
		var reach: Dictionary = PathSystem.estimate_catch_up(state, team, tid, true)
		if not reach.reachable or int(reach.get("eta", 999999)) > OCCUPY_ETA_MAX:
			Probe.bump("occupy.scan_kill_unreach"); continue
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		var pop_est: float = float(bel.get("population_est", 0.0))
		# 真守得住才佔：村防守用全 pop（civilian armed_floor）→ 用 pop_est 嚴格比（非只 armed_est）。
		# 需明顯小於我方（OCCUPY_POP_RATIO）→ 小狼不圍打不過的大村（防自殺圍城）。armed_est 為次濾。
		if pop_est >= float(team.population) * OCCUPY_POP_RATIO:
			Probe.bump("occupy.scan_kill_notweak"); continue
		# 無 armed_est belief → 人格化迷霧 fallback（讀 leader 人格，非埋死「陌生=滿武裝」）
		var armed_est: float = BeliefSystem.estimate_armed(bel, pop_est, leader_values)
		if armed_est >= float(team.population) * 0.5:
			Probe.bump("occupy.scan_kill_notweak"); continue
		# Task2 B：真打得贏 margin（解循環依賴）——己方真 armed ≥ 估村防下限 × margin。
		# 村防下限估 = believed pop_est × 武裝下限比（村全員守，用 belief pop 非 armed_est 表象）。
		# 弱狼（真 armed 不足）不自殺圍城；狼走成長序列（captive→同化→armed 長）過此才 fire。
		var own_armed: int = _calc_own_armed(state, team)
		if float(own_armed) < pop_est * OCCUPY_DEF_ARMED_FLOOR * OCCUPY_WIN_MARGIN:
			Probe.bump("occupy.scan_kill_margin"); continue
		Probe.bump("occupy.scan_passed")   # DIAG：通過全 gate 的可據可勝弱村
		if pop_est < best_pop:   # 挑最弱（pop_est 最低）可據村
			best_pop = pop_est
			best_id = tid
	return best_id

# 絕境團投靠對象是玩家 → 不自動 merge,寫 forced_event 讓玩家決定（對稱:NPC 投靠 NPC 仍自動）
# 需同格才求（co-located）；已有待處理 forced_event 則跳過。回 true=已寫事件。
func _maybe_request_join_player(state: WorldState, team: TeamData) -> bool:
	var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
	if pp == null: return false
	var ptid: int = pp.team_id
	var ppt: TeamData = state.teams.get(ptid)
	if ppt == null or ppt.tile_pos != team.tile_pos: return false   # 同格才求
	if not state.player_forced_event.is_empty(): return false        # 已有待處理 event
	state.player_forced_event = { "action": "join_request", "from_id": team.team_id }
	state.player_forced_event_id = str(randi())
	print("[JoinRequest] 流民 Team%d 求投靠玩家 Team%d" % [team.team_id, ptid])
	return true

# axis="pop"（投降找最強，defection 原行為）/ "rep"（名聲磁鐵：找最高 protector_rep 保護傘，避投奔強暴君）。
# 共用 filter/scan/reachability/跨 faction/belief/known_reputations>0.3 sanity 全不變；只換 select 準則。
func _find_strong_neighbor(state: WorldState, team: TeamData, axis: String = "pop") -> int:
	var best_id: int = -1
	var best_pop: int = 0
	var best_rep: float = -1.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not PathSystem.estimate_catch_up(state, team, tid, true).reachable: continue
		if t.faction_id != -1 and t.faction_id == team.faction_id: continue
		var rep: float = float(team.known_reputations.get(tid, 0.5))
		if rep <= 0.3: continue
		# G3-E leak 1b：強鄰實力讀 belief 非真值；無情報→不列 candidate（禁 god-view fallback）
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue
		var pop_est: int = int(BeliefSystem.best_estimate(state, team.team_id, tid).get("population_est", 0))
		if pop_est <= int(float(team.population) * 1.5): continue
		if axis == "rep":
			# 名聲磁鐵：argmax protector_rep（主觀 per-observer 道德聲望），tie-break pop。
			var prot: float = team.get_protector_rep(tid)
			if prot > best_rep or (is_equal_approx(prot, best_rep) and pop_est > best_pop):
				best_rep = prot
				best_pop = pop_est
				best_id = tid
		elif pop_est > best_pop:
			best_pop = pop_est
			best_id = tid
	return best_id

func _find_aid_target(state: WorldState, team: TeamData) -> int:
	var candidates: Array = []
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		# G3-E leak 1c：施援目標 pop+food 讀 belief 非真值；無情報 / 無 food_est→保守跳過
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		if not bel.has("food_est"): continue   # 不知有無餘糧 → 保守不列
		var reserve: float = float(bel.get("population_est", 0.0)) * 14.0
		if float(bel.get("food_est", 0.0)) <= reserve: continue
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, team, tid, true)
		if not catch_result.reachable: continue
		var same_faction: bool = (t.faction_id != -1 and t.faction_id == team.faction_id)
		var rep: float = float(team.known_reputations.get(tid, 0.5))
		var score: float = 0.0
		if same_faction: score += 1000.0
		if rep >= 0.5: score += 100.0
		score -= float(int(catch_result.eta) / 60)
		candidates.append({ "tid": tid, "score": score })
	if candidates.is_empty():
		return -1
	candidates.sort_custom(func(a, b): return a["score"] > b["score"])
	return int(candidates[0]["tid"])

func _declare_established(state: WorldState, f, leader_team: TeamData) -> void:
	f.is_established = true
	f.faction_name   = "勢力%d" % f.faction_id
	f.goals.erase("立國")
	SimMessageSystem.new().emit_message(state, "faction_establish",
		TextBank.fmt("faction_establish", "honest", {
			"origin": str(f.leader_team_id), "name": f.faction_name
		}),
		leader_team,
		{ "origin": str(f.leader_team_id), "name": f.faction_name })
	print("[Faction] 立國：%s（leader=Team%d，%d teams）" % [
		f.faction_name, f.leader_team_id, f.member_team_ids.size()])
	Probe.bump("g2.faction_found")

const OUTPOST_TAKEOVER_DAYS: int = 3

# D B2: 任何 team 駐留無人 outpost 滿 3 天 → 自動接管
func _evaluate_outpost_takeover(state: WorldState, team: TeamData) -> void:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		team.occupying_outpost_since = -1
		return
	if tile.outpost_owner == team.team_id:
		team.occupying_outpost_since = -1
		return
	if tile.outpost_owner != -1:
		team.occupying_outpost_since = -1
		return
	if team.occupying_outpost_since == -1:
		team.occupying_outpost_since = state.world.current_tick
		return
	if state.world.current_tick - team.occupying_outpost_since >= OUTPOST_TAKEOVER_DAYS * WorldState.TICKS_PER_DAY:   # gate-ok: world-mechanic: OUTPOST_TAKEOVER_DAYS 占領 timer
		OutpostOwnerBank.set_owner(tile, team.team_id, "takeover")
		team.occupying_outpost_since = -1
		print("[Takeover] Team%d 接管無人 outpost (%d,%d)" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y])

func _evaluate_uprising(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	if team.current_task in [TeamData.TASK_REVOLT, TeamData.TASK_HOLD]: return
	if team.current_task in SURVIVAL_TASKS: return
	var avg_loy: float = _avg_named_loyalty(state, team)
	if avg_loy >= 0.2: return
	if team.unrest_turns < 60: return
	if _count_stress_sources(state, team) < 2: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var old_owner_id: int = tile.outpost_owner if tile else -1
	var ambition: float = float(leader.values.get("野心", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var stand_score: float = ambition * 0.5 + prudence * 0.3 + honor * 0.2
	var flee_score: float  = survival * 0.5 + (1.0 - honor) * 0.3
	var stand: bool = stand_score > flee_score
	# 起義 = PRIO_THREAT (70)：反抗行為，玩家命令 (60) 壓不住；被擋（combat lock）→ 不執行後續副作用
	if stand:
		if not TaskArbiter.try_set(state, team, TeamData.TASK_HOLD, team.move_target,
				TaskArbiter.PRIO_THREAT, "uprising"):
			return
	else:
		if not TaskArbiter.try_set(state, team, TeamData.TASK_REVOLT, Vector2i(-1, -1),
				TaskArbiter.PRIO_THREAT, "uprising"):
			return
	# C: 起義 → 取消進行中施工（無論守城/流亡路徑）
	if tile and tile.construction_team_id != -1:
		tile.construction_team_id    = -1
		tile.construction_ticks_left = 0
		tile.construction_target     = {}
		print("[Uprising] cancel construction at (%d,%d)" % [team.tile_pos.x, team.tile_pos.y])
	if stand:
		# Path A 守城：奪取 outpost、自立（保留 PRODUCE 身分）
		state.clear_team_faction(team)   # 起義脫離 faction（雙向同步）
		if tile: OutpostOwnerBank.set_owner(tile, team.team_id, "takeover")
		print("[Uprising A] Team%d 守城（野心=%.2f，old owner=Team%d）" % [
			team.team_id, ambition, old_owner_id])
	else:
		# Path B 流亡（原 spec E 邏輯）
		state.clear_team_faction(team)   # 起義流亡脫離 faction（雙向同步）
		state.remove_tag(team, TeamData.TAG_PRODUCE, "uprising_exile")
		state.add_tag(team, "流亡", "uprising_exile")
		print("[Uprising B] Team%d 流亡（求生=%.2f，old owner=Team%d）" % [
			team.team_id, survival, old_owner_id])
	if old_owner_id != -1:
		NpcAiSystem.new().write_memory(leader, "enemy", old_owner_id,
			state.world.current_tick, 1.0)
	# 鄰格 PRODUCE team cascade fear
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.tags.has(TeamData.TAG_PRODUCE): continue
		if _hex_dist(team.tile_pos, t.tile_pos) > 2: continue
		for pid in ([t.leader_id] as Array) + t.named_members:
			var p = state.persons.get(pid)
			if p: p.fear = minf(p.fear + 0.1, 1.0)
	# 玩家是 owner → forced event
	if old_owner_id != -1 and state.teams.has(old_owner_id):
		var oid_team: TeamData = state.teams[old_owner_id]
		if oid_team.leader_id == state.player_id and state.player_id != -1:
			state.player_forced_event = {
				"from_id": team.team_id, "action": "uprising_alert",
				"outpost_pos": team.tile_pos,
			}

func _avg_named_loyalty(state: WorldState, team: TeamData) -> float:
	var sum: float = 0.0
	var cnt: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p = state.persons.get(pid)
		if p:
			sum += p.loyalty
			cnt += 1
	return sum / maxf(cnt, 1)

func _count_stress_sources(state: WorldState, team: TeamData) -> int:
	var sources: int = 0
	if team.tax_rate > 0.5: sources += 1
	# WS-2c：有效糧(私產+自家糧倉)，否則定居隊 food 在糧倉→恆計缺糧 stress 源。
	if ResourceSystem.effective_food(state, team) < float(team.population) * 7.0: sources += 1
	if team.unrest_turns > 40: sources += 1
	return sources

func _trigger_defection_evaluation(state: WorldState, team: TeamData, reason: String) -> void:
	var leader = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var honor: float = float(leader.values.get("義氣", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var ambition: float = float(leader.values.get("野心", 0.5))
	var has_benefactor_memory: float = 0.3 if _has_memory_type(leader, "benefactor") else 0.0
	var a_score: float = honor + has_benefactor_memory
	var b_score: float = prudence
	var c_score: float = ambition - honor * 0.3
	if a_score >= b_score and a_score >= c_score:
		print("[Defection] Team%d path A: 留 faction (原因=%s)" % [team.team_id, reason])
		# faction_id 不變，task=待命新領主（隨時可被高層蓋 → AMBIENT 就地轉換）
		TaskArbiter.transition(state, team, "等待新領主", TaskArbiter.PRIO_AMBIENT)
	elif b_score >= c_score:
		print("[Defection] Team%d path B: 投降強鄰" % team.team_id)
		var strong_id: int = _find_strong_neighbor(state, team)
		if strong_id != -1:
			state.set_team_faction(team, state.teams[strong_id].faction_id)   # 投降強鄰 faction（雙向同步）
		else:
			state.clear_team_faction(team)
	else:
		print("[Defection] Team%d path C: 獨立" % team.team_id)
		state.clear_team_faction(team)

func _has_memory_type(person: PersonData, type: String) -> bool:
	for m in person.memory:
		if m is Dictionary and m.get("type") == type:
			return true
	return false

func _evaluate_owner_contact(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var owner_id: int = tile.outpost_owner if tile else -1
	if owner_id == -1 or not state.teams.has(owner_id):
		_trigger_defection_evaluation(state, team, "owner_gone")
		return
	var snap: Dictionary = BeliefSystem.best_estimate(state, team.team_id, owner_id)
	var last_tick: int = int(snap.get("last_tick", -1))
	if last_tick == -1:
		return   # 從未接觸（剛建立可能）
	var days_since: int = (state.world.current_tick - last_tick) / WorldState.TICKS_PER_DAY
	if days_since > CONTACT_TIMEOUT_DAYS:   # gate-ok: world-mechanic: CONTACT_TIMEOUT_DAYS cadence
		_trigger_defection_evaluation(state, team, "no_contact")
		return
	# owner leader 異動 → 7 天緩衝
	var owner_leader_now: int = int(snap.get("leader_id", -1))
	var cached_key: String = "_cached_owner_leader_%d" % owner_id
	var cached_owner_leader: int = int(team.known_reputations.get(cached_key, -2))
	if cached_owner_leader != -2 and cached_owner_leader != owner_leader_now:
		if team.pending_owner_change_tick == -1:
			team.pending_owner_change_tick = state.world.current_tick + OWNER_CHANGE_BUFFER_DAYS * WorldState.TICKS_PER_DAY
		elif state.world.current_tick >= team.pending_owner_change_tick:
			_trigger_defection_evaluation(state, team, "owner_changed")
			team.pending_owner_change_tick = -1
	elif team.pending_owner_change_tick != -1:
		team.pending_owner_change_tick = -1
	team.known_reputations[cached_key] = owner_leader_now
