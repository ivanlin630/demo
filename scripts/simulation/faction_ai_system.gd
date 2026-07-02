class_name FactionAISystem

const COLLECT_INTERVAL:        int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
const FACTION_UPDATE_INTERVAL: int = 20 * WorldState.TICKS_PER_HOUR  # 每 20 小時
const DISPATCH_DIST_THRESHOLD: int   = 2
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
const TRADE_MIN_STOCK: float          = 10.0   # 商隊最低持貨（有貨才出門）
const TRADE_MIN_COIN: float           = 5.0    # 買方最低 coin 門檻
const MERCHANT_TRADE_BONUS: float     = 0.5    # WS-2 TEST VALUE：商隊-tag solo trade 分數加成(勝 CAMP，但 FLEE 仍優先)
const HONOR_INTERVAL_MULT: float  = 0.5   # honor=1.0 → 徵收週期 ×1.5（義氣高 → 少收稅）
const HONOR_EMERGENCY_DISC: float = 0.3   # honor=1.0 → emergency 門檻 ×0.7（義氣高 → 緊急門檻降低）
const LOOT_SCORE_THRESHOLD: float = 0.35  # TEST VALUE — 掠奪 goal 分數門檻
const LOOT_READINESS_MIN: float   = 0.6   # TEST VALUE — 掠奪需要的最低 readiness
const DEVIATION_RATE: float       = 0.05  # TEST VALUE — 子團偏離基礎概率
const SMALL_TEAM_RATIO: float     = 0.3   # TEST VALUE — pop < cap×0.3 視為小隊
const SMALL_VS_LARGE: float       = 0.33  # TEST VALUE — pop < absorber.pop×0.33 才觸發合併
const CONSOLIDATE_MAX_DIST: int   = 3     # TEST VALUE — 戰前集結距離上限（hex）
const ATTACK_SCORE_THRESHOLD:  float = 0.3   # minimum attack_score to pursue 攻擊 goal
const ATTACK_READINESS_MIN:    float = 0.75  # readiness required for attack goal
const ATTACK_STRENGTH_RATIO:   float = 0.8   # own_armed must be >= enemy_armed * this
const DIPLOMACY_AMBITION_DISC: float = 0.2   # how much ambition shifts diplomacy readiness req
# commander-v2 means-end：意圖承諾 hysteresis 加成（戰略別每 cadence 翻；情勢不變則黏住）。TEST VALUE
const COMMANDER_COMMITMENT_BONUS: float = 0.15
# ── 獨立戰略層（野心獨立隊建國 intent；mirror commander-v2 _select_intent，輕量）──
# 統一決策 arc 第三塊：野心是普世驅力，不被 faction-gate。獨立 ambitious leader 也秤戰略意圖。
# 建國 = means-end 秤的 option（driver=野心），非「夠 pop→自動 create_faction」fiat。複用既有 create_faction
# （結盟 interaction:333 / 吞併 npc_combat:524）。意圖集只 {建國,守成}（征服等成 faction 後 commander-v2 給）。
const INDEP_STRATEGY_CADENCE: int = 720         # 3 天評估一次（沿用 prosperity cadence 量級）
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
const FLEE_TIMEOUT: int = 5 * 240          # 逃跑逾時（5 天無戰鬥 → 釋放重評，小地圖防永逃）

# ── Prosperity attack（野心驅動主動征服）──
const PROSPERITY_CADENCE: int = 720           # 3 天 評估一次
const PROSPERITY_CADENCE_MILITARY: int = 360  # 軍隊 tag 1.5 天
const ANON_TREASURY_BONUS_THRESHOLD: float = 200.0  # 公庫滿 → attack_score +0.1

# ── Threat response（被動威脅反應）──
const THREAT_CADENCE: int = 240   # 1 日 評估一次威脅
const TRADE_TIMEOUT: int = 1440   # 貿易 task 6 日未成交 → 放棄（防 zombie）

# ── Outpost 居民派駐 AI ──
const RESIDENCY_CADENCE: int = 720    # 3 天 評估一次 outpost 居民派駐
const RESIDENCY_COOLDOWN: int = 1680  # 7 天 邀請被拒後冷卻
const MIN_PARENT_POP_AFTER_DISPATCH: int = 10

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

static func calc_attack_score(team: TeamData, leader: PersonData) -> float:
	var ambition: float = float(leader.values.get("野心", 0.5))
	var martial: float = float(leader.values.get("好戰", 0.5))
	var honor: float = float(leader.values.get("信義", 0.5))
	var base: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if team.anon_treasury > ANON_TREASURY_BONUS_THRESHOLD:
		base += 0.1
	return base

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
		var armed_est: float = float(bel.get("armed_est", pop_est))
		var richness: float = _belief_richness(bel)
		var weakness: float = clampf(
			1.0 - armed_est / maxf(float(team.population), 1.0),
			0.0, 1.0)
		var border: float = 1.0 if _is_border_adjacent(team, prey) else 0.3
		var eta_days: float = maxf(float(catch_result.eta) / 240.0, 1.0)
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
			# believed 屬 faction：基準罰 + 攻擊者戰爭能力減免（全既有信號讀取，無新後勤 state）
			var att_established: bool = team.faction_id != -1 \
				and state.factions.has(team.faction_id) \
				and state.factions[team.faction_id].is_established
			var war_capability: float = (0.3 if att_established else 0.0) \
				+ float(team.ambition_rung) / float(AmbitionLadder.RUNG_HEGEMON) * 0.3
			own = minf(WAR_COST_BASE + war_capability, 1.0)
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

func _evaluate_prosperity_attack(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1: return
	if team.combat_target != -1: return
	# G3d-2：scout 逾時未收斂 → 釋放回常規（防永 scout 卡死）
	if team.current_task == TeamData.TASK_SCOUT and team.task_reason == "scout" \
			and state.world.current_tick - team.task_start_tick > BeliefSystem.SCOUT_TIMEOUT:
		TaskArbiter.release(team)
		Probe.bump("g3.scout_timeout")
	# stuck（task=攻擊/掠奪 但 move_target 已清）視為 idle，允許重評換目標。
	# G3d-2：自家 scout(查證中) 亦允許重評 → 親見壓低 uncertainty 後可收斂轉攻。
	if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team) \
			and not (team.current_task == TeamData.TASK_SCOUT and team.task_reason == "scout"):
		return
	if team.current_task in SURVIVAL_TASKS: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return

	if Probe.enabled: Probe.bump("prosp.entered")   # 漏斗探針：prosperity-attack 評估入口
	# R1a：只留人格 gate（武力傾向才主動征服）。rung-food 閘已拔——rung 職權收窄為
	# 立國/坐穩/擴編（can_expand/accum_ok/rung_task），餬口帶狼性隊可進 prey 評估。
	# R2 後 archetype 與 intent 共源 → 此 gate 殘量≈0（>入口 5% = desync 回歸）。
	if team.ambition_archetype != AmbitionLadder.ARCHETYPE_FORCE:
		if Probe.enabled:
			Probe.bump("prosp.gate_archetype")
			Probe.note("prosp.blocked_rung", float(team.ambition_rung))
			# 真 desync 回歸哨：征服 intent 隊被 archetype 擋 = R2 共源破（結構上應恆 0）。
			# gate_archetype 本身含 ambient 隊（TRADE/SETTLE 被正確擋）不能當哨。
			if _solo_type(team) == "征服": Probe.bump("prosp.desync_conq_blocked")
		return

	var score: float = calc_attack_score(team, leader)
	if score < ATTACK_SCORE_THRESHOLD:
		if Probe.enabled: Probe.bump("prosp.gate_score")
		return

	var threshold: float = calc_readiness_threshold(team, leader)
	var readiness: float = calc_readiness(state, team)
	if readiness < threshold:
		if Probe.enabled: Probe.bump("prosp.gate_readiness")
		return

	var prey_id: int = find_prosperity_prey(state, team, leader)
	if prey_id == -1:
		if Probe.enabled: Probe.bump("prosp.gate_noprey")
		return

	# G3d-1/2 風險 gate：對 prey 情報不確定且 leader 慎重 → 不直接攻，改主動派斥候查證。
	# 莽者門檻低→照衝→假情報誘殺（不入此分支）。下次 cadence 重評。
	var _caution: float = float(leader.values.get("慎重", 0.5))
	if not BeliefSystem.confident_enough(state, team.team_id, prey_id, _caution):
		if Probe.enabled: Probe.bump("prosp.gate_scout_defer")   # 情報不足 → 派斥候查證（延後攻擊）
		# G3d-2：不確定 → 派斥候移向 prey best_estimate 位 → 親見壓謊 → 下 cadence uncertainty 塌 → 攻。
		# 不設 combat_target（純觀察不交戰）。scout 與 attack 同 PRIO_DISPATCH，靠 release 換手。
		var prey_t: TeamData = state.teams.get(prey_id)
		var scout_pos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, prey_id).get("tile_pos", prey_t.tile_pos) if prey_t else team.tile_pos
		if team.current_task == TeamData.TASK_SCOUT and team.prosperity_target_id == prey_id:
			team.move_target = scout_pos   # 追蹤刷新：prey 移動 → 朝最新 best_estimate（不重派/不 spam log）
		elif TaskArbiter.try_set(state, team, TeamData.TASK_SCOUT, scout_pos, TaskArbiter.PRIO_DISPATCH, "scout"):
			team.prosperity_target_id = prey_id   # try_set 已設 move_target=scout_pos
			print("[Scout] team=%d → verify prey=%d" % [team.team_id, prey_id])
			Probe.bump("g3.scout_dispatch")
		return

	# combat_target 不預設：移動凍結 + interaction 早退會擋住交戰；
	# 由 interaction_system 到達時 start_combat 設定。只給 task + move_target + 追擊目標。
	# G3d-2：confident 後若仍掛 scout(同 PRIO_DISPATCH 擋不住自身) → 先 release 讓 attack 設得進。
	var _was_scout: bool = (team.current_task == TeamData.TASK_SCOUT and team.task_reason == "scout")
	if _is_stuck(team) or (team.current_task == TeamData.TASK_SCOUT and team.task_reason == "scout"):
		TaskArbiter.release(team)
	if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
			state.teams[prey_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "prosperity"):
		team.prosperity_target_id = prey_id
		if _was_scout: Probe.bump("g3.scout_converge")
		# 征服名實探針：真征服鏈起點（prosperity-attack→失能-capture→吸收）走到。
		Probe.bump("conq.prosperity_reached")
		# R1b 驗收哨：獨立隊攻 believed-faction-owned 目標（③own 罰應壓低此量，非歸零）
		if Probe.enabled and team.faction_id == -1:
			var _bel_own: Dictionary = BeliefSystem.best_estimate(state, team.team_id, prey_id)
			if _bel_own.has("faction_id") and int(_bel_own.get("faction_id", -1)) != -1:
				Probe.bump("conq.indep_atk_believed_owned")
		print("[ProsperityAttack] attacker=Team%d prey=Team%d score=%.2f" % [
			team.team_id, prey_id, score])

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
	# C: 攻擊追擊用攔截預測（朝 prey 移動方向提前 N 步），視野外/不動 fallback intel 最後已知
	var last_pos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, team.prosperity_target_id).get("tile_pos", prey.tile_pos)
	var predicted: Vector2i = PathSystem.predict_intercept(state, team, prey)
	team.move_target = predicted if predicted != prey.tile_pos else last_pos

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
	if team.current_task in [TeamData.TASK_DEFEND, TeamData.TASK_PREPARE, TeamData.TASK_FLEE, TeamData.TASK_HOLD]:
		# 威脅消失 → 釋放；或逃跑逾時（小地圖逃不到 5 格脫離 → 靠 timeout 重評，否則永逃）
		var fled_too_long: bool = team.current_task == TeamData.TASK_FLEE \
			and state.world.current_tick - team.task_start_tick > FLEE_TIMEOUT
		if not _has_active_threat(state, team) or fled_too_long:
			TaskArbiter.release(team)
		return
	# 不打斷其他進行中 task（只有 idle 才主動評威脅）
	if team.current_task != TeamData.TASK_IDLE: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var caution: float = float(leader.values.get("慎重", 0.5))
	var threshold: float = ThreatAssessment.THREAT_BASE_THRESHOLD + caution * 0.3
	var best_threat: float = 0.0
	var best_id: int = -1
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > best_threat:
			best_threat = t
			best_id = tid
	if best_threat < threshold: return
	_dispatch_threat_response(state, team, best_id, best_threat)

func _has_active_threat(state: WorldState, team: TeamData) -> bool:
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var t: float = ThreatAssessment.score(state, team, other)
		if t > ThreatAssessment.THREAT_BASE_THRESHOLD:
			return true
	return false

# 依 leader 性格評 4 反應（逃跑/備戰/求和/迎戰），居民團不可迎戰。
func _dispatch_threat_response(state: WorldState, team: TeamData,
		threat_id: int, threat_score: float) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var martial: float = float(leader.values.get("好戰", 0.5))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var honor: float = float(leader.values.get("信義", 0.5))
	var is_resident: bool = _is_resident_team(state, team)
	var scores: Dictionary = {
		TeamData.TASK_FLEE: survival * 0.8 + (threat_score - 0.5) * 0.3,
		TeamData.TASK_PREPARE: caution * 0.6 + martial * 0.3,
		"求和": greed * 0.5 + honor * 0.3 - martial * 0.3,
	}
	if not is_resident:
		scores[TeamData.TASK_DEFEND] = martial * 0.7 + (1.0 - threat_score) * 0.2
	var best: String = ""
	var best_score: float = -INF
	for action in scores:
		if scores[action] > best_score:
			best_score = scores[action]
			best = action
	var other: TeamData = state.teams.get(threat_id)
	if other == null: return
	match best:
		TeamData.TASK_FLEE:
			if not TaskArbiter.try_set(state, team, TeamData.TASK_FLEE,
					_flee_target(state, team, other), TaskArbiter.PRIO_THREAT, "threat"):
				return
		TeamData.TASK_DEFEND:
			if not TaskArbiter.try_set(state, team, TeamData.TASK_DEFEND,
					other.tile_pos, TaskArbiter.PRIO_THREAT, "threat"):
				return
			team.prosperity_target_id = threat_id
		TeamData.TASK_PREPARE:
			if not TaskArbiter.try_set(state, team, TeamData.TASK_PREPARE,
					Vector2i(-1, -1), TaskArbiter.PRIO_THREAT, "threat"):
				return
		"求和":
			if not TaskArbiter.try_set(state, team, TeamData.TASK_DIPLOMACY,
					other.tile_pos, TaskArbiter.PRIO_THREAT, "threat"):
				return
			team.order_target_id = threat_id
			team.order_task = TeamData.TASK_TRIBUTE_OFFER
	print("[ThreatResponse] Team%d → %s (threat=Team%d, score=%.2f)" % [
		team.team_id, best, threat_id, best_score])

func _flee_target(state: WorldState, team: TeamData, threat: TeamData) -> Vector2i:
	# 朝反方向走 3 hex
	var dir: Vector2i = team.tile_pos - threat.tile_pos
	var pos: Vector2i = team.tile_pos + Vector2i(sign(dir.x), sign(dir.y)) * 3
	if state.world.tiles.has(pos.x * 1000 + pos.y):
		return pos
	return team.tile_pos

func _is_prosperity_candidate(state: WorldState, team: TeamData) -> bool:
	if team.parent_team_id != -1: return false   # 子隊不主動發動
	if team.faction_id == -1: return true          # 獨立團
	var f = state.factions.get(team.faction_id)
	return f != null and f.leader_team_id == team.team_id

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
	if state.world.current_tick < team.residency_eval_next_tick: return
	team.residency_eval_next_tick = state.world.current_tick + RESIDENCY_CADENCE
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
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
func _try_invite_nearby_exile(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	for tid in state.team_discovered.get(team.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not ("流亡" in t.tags): continue
		if t.current_task == TeamData.TASK_SETTLE: continue   # 已在路上，不重邀
		if state.world.current_tick < int(team.invite_cooldown.get(tid, 0)): continue
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
		tile.public_storage["mounts"] = available - take
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
			sub_sys.try_merge_back(state, sub_id)
		else:
			TaskArbiter.release(sub)
			if parent != null:
				sub.move_target = parent.tile_pos

	if SimRunner.phase_timing: _t = _fai_pht("loop2b.merge", _t)
	for tid in state.teams.keys():   # keys() 快照 → 滅團可安全 erase
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
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
		# A: prosperity attack（野心驅動主動征服，cadence + 軍隊加速）
		if _is_prosperity_candidate(state, team) \
				and state.world.current_tick >= team.prosperity_eval_next_tick:
			_evaluate_prosperity_attack(state, team)
			var cad: int = PROSPERITY_CADENCE_MILITARY if "軍隊" in team.tags else PROSPERITY_CADENCE
			team.prosperity_eval_next_tick = state.world.current_tick + cad
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.prosperity", _t3)
		# 追擊刷新（攻擊/掠奪 中移動目標會跑，每 tick 對齊 intel）
		_refresh_attack_pursuit(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.pursuit", _t3)
		# D: 被動威脅評估（cadence 內部控管）
		_evaluate_threat(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.threat", _t3)
		# G2d：私人脫軌（強血仇+衝動 leader 拉隊打仇人；生存/威脅擋得住，prosperity 擋不住）
		# 置於 _evaluate_threat 後：threat 先在 idle 設 DEFEND/FLEE@70，vendetta@55 搶不動 → 威脅優先
		var _vleader: PersonData = state.persons.get(team.leader_id)
		if _vleader != null:
			var _vfoe: int = NpcAiSystem.new().vendetta_target(state, _vleader)
			if _vfoe != -1 and state.teams.has(_vfoe):
				if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
						state.teams[_vfoe].tile_pos, TaskArbiter.PRIO_VENDETTA, "vendetta"):
					team.prosperity_target_id = _vfoe   # 追擊刷新復用
					Probe.bump("g2.vendetta_trigger")
					print("[Vendetta] Team%d leader 脫軌攻擊仇人 Team%d" % [team.team_id, _vfoe])
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.vendetta", _t3)
		# W2: 貿易 task timeout 防 zombie（追不到 / 對方消失）
		if team.current_task == TeamData.TASK_TRADE \
				and state.world.current_tick - team.trade_task_start_tick > TRADE_TIMEOUT:
			TaskArbiter.release(team)
		# 公庫徵用：每月一次依 leader 貪婪評估
		if state.world.current_tick % WorldState.TICKS_PER_MONTH == 0:
			_consider_extraction(state, team)
		# D B2: 無人 outpost 駐留接管
		_evaluate_outpost_takeover(state, team)
		# 居民派駐：自家無居民 outpost → 派子隊/邀流亡（cadence 內控）
		_evaluate_outpost_residency(state, team)
		if _is_resident_team(state, team):
			_evaluate_uprising(state, team)
			_evaluate_owner_contact(state, team)
		if SimRunner.phase_timing: _t3 = _fai_pht("loop3.outpost", _t3)
		_update_equip_order(state, team)
		# anon_combat_skill / anon_wage 改 computed（AnonTierSystem），不再主動更新
		_update_armor_config(team)
		_update_guard_ratio(team, state)
		# 出征前自動從自家 outpost 公庫拉 mount
		_auto_withdraw_mounts(state, team)
		# G2c：野心階梯常態行為（最低優先，只填 idle）
		if team.current_task == TeamData.TASK_IDLE:
			var amb_task: String = AmbitionLadder.rung_task(state, team)
			if amb_task != "":
				TaskArbiter.try_set(state, team, amb_task, team.tile_pos, TaskArbiter.PRIO_AMBIENT, "ambition")
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
func _argmax_intent(scores: Dictionary, committed: String) -> Dictionary:
	if committed != "" and scores.has(committed) and scores[committed] > -0.5:
		scores[committed] += COMMANDER_COMMITMENT_BONUS
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
func select_strategic_intent(state: WorldState, _team: TeamData, ctx: Dictionary) -> Dictionary:
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
	var picked: Dictionary = _argmax_intent(scores, String(ctx.get("committed", "")))
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

	# ── 步驟 2：意圖選擇（resource-aware + 人格 + belief + hysteresis）──
	var intent: Dictionary = _select_intent(state, f)
	f.intent = intent
	f.strategy = intent["type"]
	var itype: String = intent["type"]

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
			return target_id != -1 and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
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
	# specimen tap：commander goal → capture intent（leader team 是 specimen 時）
	SpecimenTracer.capture_intent(state, f.leader_team_id, intent_type, why, mode)

# ──────── 獨立戰略層（野心獨立隊建國 intent）────────

# F-D4：solo_intent 統一 intent struct 讀/寫 helper（廢一槽兩義；driver-complete parity）。
static func _solo_type(team: TeamData) -> String:
	return String(team.solo_intent.get("type", "")) if team.solo_intent is Dictionary else ""

func _set_solo(state: WorldState, team: TeamData, itype: String, why: String, mode: String) -> void:
	team.solo_intent = {"type": itype, "why": why, "mode": mode}   # 每令帶 driver（連回意圖，北極星）
	SpecimenTracer.capture_intent(state, team.team_id, itype, why, mode)

# mirror commander-v2 _select_intent（輕量）：fid=-1 野心獨立隊秤「建國 vs 守成」→ means-end 子行動
# 結盟(primary)/吞併(機會) → 複用既有 create_faction（不新 founding 機制）。守成=不 dispatch（繼續既有個體決策）。
# 觸發 gate：fid=-1 + 野心≥AMBITION_FOUND_MIN + 累積夠（pop≥EXPAND_MIN_POP + 食盈餘）+ founding 路徑可達。
# 稀有 by construction：野心高 + 累積 + 路徑三閘 → 多數獨立隊守成（非建國潮）。
func _evaluate_independent_strategy(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id and state.player_id != -1: return
	if team.faction_id != -1: return            # 只獨立隊（成 faction 後 commander-v2 接手）
	if team.parent_team_id != -1: return        # 子隊不自建國
	if team.combat_target != -1: return         # 戰鬥中不重評
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
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
		found_score += FOUND_COMMITMENT_BONUS   # hysteresis（戰略別每 cadence 翻）
	# 建國 gate（fid==-1 + 野心 + 累積[pop+7日食盈餘] + 路徑[ally] + 非危時）→ can_found
	var accum_ok: bool = team.population >= AmbitionLadder.EXPAND_MIN_POP \
		and ResourceSystem.effective_food(state, team) >= float(team.population) \
			* ResourceSystem.FOOD_PER_PERSON_PER_DAY * FOUND_FOOD_SURPLUS_DAYS
	var path_ok: bool = ally_id != -1 or prey_id != -1
	var can_found: bool = ambition >= AMBITION_FOUND_MIN and accum_ok and path_ok and not busy
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
					team.tags.append("統領")
				if TaskArbiter.try_set(state, team, TeamData.TASK_ATTACK,
						state.teams[prey_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "found_subjugate"):
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
	var target_pos: Vector2i = BeliefSystem.best_estimate(state, mother.team_id, target_id).get("tile_pos", target.tile_pos)
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
	# 提案權威存母隊（對齊 active_orders pattern）
	mother.pending_proposal = {
		"type": ptype, "target_id": target_id, "target_pos": target_pos,
		"issued_tick": state.world.current_tick, "proposal_id": proposal_id, "timeout": budget,
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
	var est_pos: Vector2i = BeliefSystem.best_estimate(state, envoy.team_id, target_id).get("tile_pos", target.tile_pos)
	var predicted: Vector2i = PathSystem.predict_intercept(state, envoy, target)
	envoy.move_target = predicted if predicted != target.tile_pos else est_pos

# 信使歸隊：釋放 task + 朝母隊移動 → 到母格 try_merge_back（復用 merge）。母隊 pending 靠自身 timeout 清。
func _recall_envoy(state: WorldState, envoy: TeamData) -> void:
	TaskArbiter.release(envoy)   # → IDLE, move_target=-1
	envoy.task_reason = "envoy_recall"
	var parent: TeamData = state.teams.get(envoy.parent_team_id)
	if parent != null:
		envoy.move_target = parent.tile_pos   # 下 tick _evaluate_idle_subteam 路由回家/併回
	else:
		state.detach_subteam(envoy)            # 母隊已亡 → 脫離成獨立（正常 AI 接手，非 zombie）
		envoy.tags.erase(TeamData.TAG_SUBTEAM)

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

	if "徵收" in f.goals and leader_team.current_task != TeamData.TASK_TRIBUTE:
		var best_tid: int = _richest_member(state, f)
		if best_tid != -1:
			var target_pos: Vector2i = state.teams[best_tid].tile_pos
			var dist: int = _hex_dist(leader_team.tile_pos, target_pos)
			if dist > DISPATCH_DIST_THRESHOLD and leader_team.population >= 3 \
					and leader_team.named_members.size() > 0:
				var _sub_sys_pick := SubteamSystem.new()
				var sub_leader_id: int = _sub_sys_pick._pick_subteam_leader(state, leader_team, TeamData.TASK_TRIBUTE)
				if sub_leader_id == -1: sub_leader_id = leader_team.named_members[0]
				var pop_count: int = maxi(leader_team.population / 4, 2)
				_sub_sys_pick.dispatch(state, f.leader_team_id, sub_leader_id,
					pop_count, TeamData.TASK_TRIBUTE, target_pos)
			else:
				TaskArbiter.try_set(state, leader_team, TeamData.TASK_TRIBUTE, target_pos,
					TaskArbiter.PRIO_DISPATCH, "faction_tribute")
	if "立國" in f.goals:
		_declare_established(state, f, leader_team)
	if "外交" in f.goals and leader_team.current_task not in [TeamData.TASK_TRIBUTE, TeamData.TASK_DIPLOMACY, TeamData.TASK_ATTACK]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			TaskArbiter.try_set(state, leader_team, TeamData.TASK_DIPLOMACY,
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "faction_diplomacy")
	if "攻擊" in f.goals and leader_team.current_task not in [TeamData.TASK_TRIBUTE, TeamData.TASK_DIPLOMACY, TeamData.TASK_ATTACK]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1 and TaskArbiter.try_set(state, leader_team, TeamData.TASK_ATTACK,
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal"):
			print("[FactionAI] Team%d 主動攻擊 Team%d" % [f.leader_team_id, target_id])
	if "掠奪" in f.goals and leader_team.current_task not in [TeamData.TASK_TRIBUTE, TeamData.TASK_DIPLOMACY, TeamData.TASK_ATTACK, TeamData.TASK_LOOT]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1 and TaskArbiter.try_set(state, leader_team, TeamData.TASK_LOOT,
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal"):
			print("[FactionAI] Team%d 主動掠奪 Team%d" % [f.leader_team_id, target_id])
	if SimRunner.phase_timing: _ta = _fai_pht("assign.leader_goals", _ta)
	_assign_member_tasks(state, f)
	if SimRunner.phase_timing: _fai_pht("assign.members", _ta)

func _assign_member_tasks(state: WorldState, f) -> void:
	var leader_team: TeamData = state.teams.get(f.leader_team_id)
	for mid in f.member_team_ids:
		if mid == f.leader_team_id: continue
		var mt: TeamData = state.require_team(mid)
		if mt.combat_target != -1: continue          # 戰鬥覆蓋(全隊)
		if not mt.player_commanded_task.is_empty(): continue  # 玩家(全隊)
		if uses_unified(mt):                          # ← hoist:引擎每 cadence 重評(unified 退 latch)
			if SimRunner.phase_timing:
				var _tu: int = Time.get_ticks_usec()
				_decide_unified(state, mt)
				_fai_pht("member.unified", _tu)
			else:
				_decide_unified(state, mt)
			continue
		# ↓ 以下僅非 unified 隊(原邏輯原樣)
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var known_task: String = snap.get("current_task", TeamData.TASK_IDLE)
		if mt.combat_target != -1 or known_task != TeamData.TASK_IDLE:
			continue
		if mt.current_task in SURVIVAL_TASKS:
			continue  # 生存 sticky(非 unified)：不蓋過 survival task
		var _tm: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
		var absorber_id: int = _find_absorber(state, mt, f)
		if SimRunner.phase_timing: _tm = _fai_pht("member.absorber", _tm)
		if absorber_id != -1:
			var mt_leader = state.persons.get(mt.leader_id)
			var mt_cmd: float = float(mt_leader.skills.get("統領", 0.0)) if mt_leader else 0.0
			var mt_cap: int = TeamData.pop_cap_from_leadership(mt_cmd)
			var small_b: bool = mt.population < int(float(mt_cap) * SMALL_TEAM_RATIO)
			var small_c: bool = float(mt.population) < float(state.teams[absorber_id].population) * SMALL_VS_LARGE
			if small_b and small_c:
				if TaskArbiter.try_set(state, mt, TeamData.TASK_MERGE,
						state.teams[absorber_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "consolidate"):
					mt.order_target_id = absorber_id
				continue
		if "攻擊" in f.goals and leader_team != null:
			var dist_to_leader: int = _hex_dist(mt.tile_pos, leader_team.tile_pos)
			if dist_to_leader > 1 and dist_to_leader <= CONSOLIDATE_MAX_DIST:
				var ldr_leader = state.persons.get(leader_team.leader_id)
				var ldr_cmd: float = float(ldr_leader.skills.get("統領", 0.0)) if ldr_leader else 0.0
				var ldr_cap: int = TeamData.pop_cap_from_leadership(ldr_cmd) - leader_team.population
				if ldr_cap > 0:
					if TaskArbiter.try_set(state, mt, TeamData.TASK_MERGE,
							leader_team.tile_pos, TaskArbiter.PRIO_DISPATCH, "consolidate"):
						mt.order_target_id = f.leader_team_id
					continue
		if "徵收" in f.goals and _tag_weight(mt, "徵收") > 0.0:
			var best_tid: int = _richest_member(state, f)
			if best_tid != -1 and best_tid != mid:
				TaskArbiter.try_set(state, mt, TeamData.TASK_TRIBUTE,
					state.teams[best_tid].tile_pos, TaskArbiter.PRIO_DISPATCH, "member_tribute")
		elif "外交" in f.goals and _tag_weight(mt, "外交") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				TaskArbiter.try_set(state, mt, TeamData.TASK_DIPLOMACY,
					state.teams[target_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "member_diplomacy")
		elif "攻擊" in f.goals and _tag_weight(mt, "攻擊") > 0.0:
			var target_id: int = _nearest_independent(state, mt)
			if target_id != -1:
				TaskArbiter.try_set(state, mt, TeamData.TASK_ATTACK,
					state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal")
		elif _can_manufacture(state, mt):
			TaskArbiter.try_set(state, mt, TeamData.TASK_MANUFACTURE,
				mt.move_target, TaskArbiter.PRIO_DISPATCH, "member_manufacture")
		elif _can_trade(state, mt):
			var _tt: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
			var ttarget: Vector2i = _merchant_trade_target(state, mt)
			if SimRunner.phase_timing: _fai_pht("member.trade_target", _tt)
			if ttarget != Vector2i(-1, -1):
				if TaskArbiter.try_set(state, mt, TeamData.TASK_TRADE,
						ttarget, TaskArbiter.PRIO_DISPATCH, "member_trade"):
					mt.trade_task_start_tick = state.world.current_tick
		if SimRunner.phase_timing: _fai_pht("member.finders", _tm)

# ──────── 統一決策引擎切片 seam ────────
# 切片 = 商隊 + 生產 tag 隊：macro 決策走 DecisionEngine（舊 member hoist / solo 生產者跳過，單一 owner）。
# 非切片隊（軍隊/統領/宗教…）舊系統原封不動（零影響 = de-risk）。後續域遷入逐擴 tag。
func uses_unified(team: TeamData) -> bool:
	return team.tags.has(TeamData.TAG_MERCHANT) or team.tags.has(TeamData.TAG_PRODUCE)

# 切片隊走引擎決策 → 設 task（取代舊 member/solo 派工）。
func _decide_unified(state: WorldState, team: TeamData) -> void:
	if team.current_task in SURVIVAL_TASKS and team.current_task != TeamData.TASK_IDLE:
		pass   # 生存 sticky 仍尊重；引擎的 survival option 會自然續（承諾）
	var _tr: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	var ranked: Array = DecisionEngine.rank_scored(state, team)
	if SimRunner.phase_timing: _tr = _fai_pht("unified.rank", _tr)
	# 征服名實探針（純觀測）：solo_intent=征服 的隊在此實際 winner 分類（想征服 vs 做掠奪）。
	var _conq: bool = Probe.enabled and _solo_type(team) == "征服"
	if _conq: Probe.bump("conq.intent")
	for e in ranked:
		var opt: String = e["opt"]
		# means-end 統一攻擊：征服 intent 驅動的攻擊 → route 到 scout-gated prosperity（削敵→俘虜→守），
		# 非粗 _nearest_independent 直取。消「兩條攻擊路徑」（faction directive 攻擊維持指定 target 路徑）。
		if opt == "攻擊" and _solo_type(team) == "征服" and team.faction_id == -1:
			if _is_prosperity_candidate(state, team):
				SpecimenTracer.capture_decision(state, team, opt, TeamData.TASK_ATTACK, team.tile_pos)
				if SimRunner.phase_timing:
					var _tp: int = Time.get_ticks_usec()
					_evaluate_prosperity_attack(state, team)
					_fai_pht("unified.prosp", _tp)
				else:
					_evaluate_prosperity_attack(state, team)   # scout→打垮→capture 乾淨鏈
				return
			continue   # 無 prosperity 資格 → 試次佳（不落回粗攻擊）
		var _t2: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		if SimRunner.phase_timing: _fai_pht("unified.to_task", _t2)
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue   # 不可派 → 試次佳(修凍死)
		# 投靠玩家：走 forced_event（玩家決定收留），不自動 merge（對稱 + UX）
		if opt == "投靠" and td.has("social_target"):
			var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
			if pp != null and int(td["social_target"]) == pp.team_id:
				if _maybe_request_join_player(state, team):
					return
		team.current_option = opt   # 承諾追蹤實際派出
		if opt == "返家補給": Probe.bump("g1.restock_chosen")
		elif opt in ["覓食", "survival"]: Probe.bump("g1.engine_survival")
		if _conq: _probe_conq_winner(opt, ranked)   # winner 分類 + util 排序根
		SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt)
		TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "unified")
		# 掠奪/攻擊 設 combat_target 才交戰；投靠/乞食 設 social_target（社交 resolver 讀）
		if td.has("combat_target"):
			state.set_combat_target(team, int(td["combat_target"]))
		if td.has("social_target"):
			state.set_social_target(team, int(td["social_target"]))
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
	var best_d: int  = 999
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
		var d: int = _hex_dist(mt.tile_pos, t.tile_pos)
		if d <= 1 or d > CONSOLIDATE_MAX_DIST:
			continue
		if d < best_d:
			best_d = d
			best_id = tid
	return best_id

# ──────── 子團自主 AI ────────

func _evaluate_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	# ②a 信使外交：envoy_proposal 子隊追蹤刷新 target best_estimate + 自配 timeout（新 invariant 自守）
	if sub.current_task == TeamData.TASK_HERALD and sub.task_reason == "envoy_proposal":
		_tick_envoy(state, sub, merge_queue)
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
	if sub.current_task != TeamData.TASK_IDLE and sub.move_target != Vector2i(-1, -1):
		if _check_deviation(state, sub):
			return
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
	elif sub.current_task == TeamData.TASK_IDLE:
		_evaluate_idle_subteam(state, sub, merge_queue)

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
		sub.tags.erase(TeamData.TAG_SUBTEAM)
		TaskArbiter.release(sub)
		print("[SubAI] Team%d 紀律失效，脫離成獨立" % sub.team_id)
		return true
	return false

func _check_deviation(state: WorldState, sub: TeamData) -> bool:
	var leader = state.persons.get(sub.leader_id)
	if leader == null:
		return false
	var greed: float   = float(leader.values.get("貪婪", 0.5))
	var loyalty: float = leader.loyalty
	var deviation_chance: float = greed * (1.0 - loyalty) * DEVIATION_RATE
	if randf() < deviation_chance:
		var loot_target: int = _nearest_independent(state, sub)
		if loot_target != -1:
			if TaskArbiter.try_set(state, sub, TeamData.TASK_LOOT,
					state.teams[loot_target].tile_pos, TaskArbiter.PRIO_DISPATCH, "deviation"):
				print("[SubAI] Team%d 偏離掠奪 Team%d" % [sub.team_id, loot_target])
				return true
			return false
		TaskArbiter.release(sub)
	return false

func _evaluate_idle_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null:
		return
	if parent.tile_pos == sub.tile_pos:
		merge_queue.append(sub.team_id)
		return
	var leader_p = state.persons.get(sub.leader_id)
	if leader_p == null:
		sub.move_target = parent.tile_pos
		return
	var greed:   float = float(leader_p.values.get("貪婪", 0.5))
	var martial: float = float(leader_p.values.get("好戰", 0.5))
	var scores: Dictionary = { "回歸": 0.3 }
	scores[TeamData.TASK_LOOT] = (greed * 0.5 + martial * 0.2) * _tag_weight(sub, TeamData.TASK_LOOT)
	scores[TeamData.TASK_ATTACK] = (martial * 0.4 + greed * 0.2) * _tag_weight(sub, TeamData.TASK_ATTACK)
	var best_task := "回歸"
	var best_score: float = 0.0
	for t in scores:
		if float(scores[t]) > best_score:
			best_score = float(scores[t])
			best_task  = t
	if best_task == "回歸":
		sub.move_target = parent.tile_pos
	else:
		var tid: int = _nearest_independent(state, sub)
		if tid != -1:
			if TaskArbiter.try_set(state, sub, best_task,
					state.teams[tid].tile_pos, TaskArbiter.PRIO_DISPATCH, "subteam_idle"):
				print("[SubAI] Team%d idle→%s (Team%d)" % [sub.team_id, best_task, tid])
		else:
			sub.move_target = parent.tile_pos

# ──────── 獨立 Team 自主 AI ────────

func _evaluate_solo(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return   # 玩家隊不受 SoloAI 控制
	if team.combat_target != -1: return
	var leader_p = state.persons.get(team.leader_id)
	if leader_p == null: return
	# 統一決策引擎切片：商隊-tag solo 隊走 DecisionEngine（取代舊 solo 計分 + MERCHANT_TRADE_BONUS）。
	if uses_unified(team):                          # ← hoist 到 IDLE gate 前(unified 退 latch)
		_decide_unified(state, team)
		return
	# stuck 視為 idle，允許重評（task 保留意圖直到重新派發）
	if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return

	var martial:  float = float(leader_p.values.get("好戰",   0.5))
	var greed:    float = float(leader_p.values.get("貪婪",   0.5))
	var ambition: float = float(leader_p.values.get("野心",   0.5))
	var survival: float = float(leader_p.values.get("求生欲", 0.5))

	var scores: Dictionary = { TeamData.TASK_IDLE: 0.1 }
	scores[TeamData.TASK_ATTACK] = (ambition * 0.4 + martial * 0.4) * _tag_weight(team, TeamData.TASK_ATTACK)
	scores[TeamData.TASK_LOOT] = (greed * 0.5 + martial * 0.3)    * _tag_weight(team, TeamData.TASK_LOOT)
	scores[TeamData.TASK_DIPLOMACY] = maxf(ambition * 0.4 - martial * 0.2, 0.0) * _tag_weight(team, TeamData.TASK_DIPLOMACY)
	# WS-2c：有效糧(私產+自家糧倉)，否則定居商隊 food=0→food_pc=0→FLEE 分數爆高蓋過 trade
	# (商隊永逃不貿易元兇之一)。真絕境(皆空)food_pc 仍 0→FLEE，絕境不貿易不變。
	var food_pc: float = ResourceSystem.effective_food(state, team) / maxf(team.population, 1)
	if food_pc < 2.0:
		scores[TeamData.TASK_FLEE] = survival * 0.8
	if _can_manufacture(state, team):
		scores[TeamData.TASK_MANUFACTURE] = (greed * 0.4 + 0.2) * _tag_weight(team, TeamData.TASK_MANUFACTURE)
	if _can_trade(state, team):
		scores[TeamData.TASK_TRADE] = (greed * 0.5 + 0.3) * _tag_weight(team, TeamData.TASK_TRADE)
		# 統一決策引擎接管後，商隊-tag solo 隊已在函式開頭 return → 此處只剩非商隊隊。
		# 舊 MERCHANT_TRADE_BONUS hoist（商隊分支）由引擎的「貿易 option」取代，移除（不雙重觸發）。
	# W4 A：駐家治理傾向 — 慎重/野心高 leader 在自家 outpost 攢公庫（建材未達標才積極）
	var own_pos: Vector2i = _find_own_outpost(state, team)
	if own_pos != Vector2i(-1, -1):
		var caution: float = float(leader_p.values.get("慎重", 0.5))
		var amb_dev: float = float(leader_p.values.get("野心", 0.5))
		var home_tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
		var vault_mat: float = float(home_tile.public_storage.get("material", 0)) if home_tile else 0.0
		if vault_mat < GOVERN_MATERIAL_TARGET:
			scores[TeamData.TASK_GOVERN] = (caution * 0.4 + amb_dev * 0.2 + 0.15) * _tag_weight(team, TeamData.TASK_GOVERN)

	# 主動尋家（僅無 own outpost 的流浪團）：純 value 加權，與 roving 競爭。
	# 不乘 _tag_weight（該函數對「流亡」tag 回 0，會歸零最需尋家的流亡團）。
	if own_pos == Vector2i(-1, -1):
		if _find_unowned_farmable_tile(state, team) != Vector2i(-1, -1):
			scores[TeamData.TASK_CAMP] = survival * 0.3 \
				+ float(leader_p.values.get("慎重", 0.5)) * 0.3 + ambition * 0.3
		if _find_strong_neighbor(state, team) != -1:
			scores[TeamData.TASK_JOIN] = float(leader_p.values.get("義氣", 0.5)) * 0.4 + survival * 0.4

	# 承諾慣性：上次 task 加分（非明顯更優不換）。F-D4：用 solo_task_last（與戰略 intent 分離）。
	if team.solo_task_last != "" and scores.has(team.solo_task_last):
		scores[team.solo_task_last] = float(scores[team.solo_task_last]) + SOLO_COMMITMENT_BONUS

	var best_task := TeamData.TASK_IDLE
	var best_score: float = 0.0
	for t in scores:
		if float(scores[t]) > best_score:
			best_score = float(scores[t])
			best_task = t

	# 征服名實探針：警戒——好戰征服 intent 隊多為非 unified → 走此舊 solo path（非 _decide_unified）。
	# 這裡才是「想=征服 做=掠奪」真競場：TASK_LOOT vs TASK_ATTACK argmax。
	if Probe.enabled and _solo_type(team) == "征服":
		Probe.bump("conq.intent")
		match best_task:
			TeamData.TASK_LOOT:   Probe.bump("conq.winner_loot")
			TeamData.TASK_ATTACK: Probe.bump("conq.winner_prosperity")   # 舊 solo 的征服手段=TASK_ATTACK
			_:                    Probe.bump("conq.winner_other")
		if scores.has(TeamData.TASK_LOOT) and scores.has(TeamData.TASK_ATTACK):
			# util 排序根（舊 solo 計分）：掠奪領先攻擊多少 = 掠奪搶排序證據
			Probe.note("conq.loot_lead", float(scores[TeamData.TASK_LOOT]) - float(scores[TeamData.TASK_ATTACK]))

	if best_task == TeamData.TASK_IDLE: return
	var solo_target: Vector2i = team.move_target
	match best_task:
		TeamData.TASK_ATTACK, TeamData.TASK_LOOT, TeamData.TASK_DIPLOMACY:
			var tid: int = _nearest_independent(state, team)
			if tid == -1: return
			solo_target = state.teams[tid].tile_pos
		TeamData.TASK_FLEE:
			solo_target = Vector2i(-1, -1)
		TeamData.TASK_MANUFACTURE:
			pass  # 製造在原地進行
		TeamData.TASK_TRADE:
			var ttarget: Vector2i = _merchant_trade_target(state, team)
			if ttarget == Vector2i(-1, -1): return
			solo_target = ttarget
		TeamData.TASK_GOVERN:
			solo_target = own_pos
		TeamData.TASK_CAMP:
			var cpos: Vector2i = _find_unowned_farmable_tile(state, team)
			if cpos == Vector2i(-1, -1): return
			solo_target = cpos
		TeamData.TASK_JOIN:
			var ally: int = _find_strong_neighbor(state, team)
			if ally == -1: return
			solo_target = state.teams[ally].tile_pos
			state.set_social_target(team, ally)   # 社交意圖非戰鬥（resolver 讀 social_target）
	if _is_stuck(team):
		TaskArbiter.release(team)   # stuck 釋放讓位，同層才能重評
	if not TaskArbiter.try_set(state, team, best_task, solo_target,
			TaskArbiter.PRIO_DISPATCH, "solo"):
		return
	if best_task == TeamData.TASK_TRADE:
		team.trade_task_start_tick = state.world.current_tick
	team.solo_task_last = best_task   # F-D4：task 承諾記此槽（solo_intent 保留戰略 intent）
	print("[SoloAI] Team%d → %s" % [team.team_id, best_task])

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

func _can_trade(state: WorldState, team: TeamData) -> bool:
	if _tag_weight(team, TeamData.TASK_TRADE) == 0.0:
		return false
	for res in TRADEABLE_RES:
		var stock: float = float(team.resources.get(res, 0))
		if res == "food":
			stock = maxf(stock - float(team.population) * 0.1 \
				* InteractionSystem.FOOD_RESERVE_TICKS, 0.0)
		if stock >= TRADE_MIN_STOCK:
			return true
	return false

const MERCHANT_MAX_RANGE: int = 20

# G1d：商業 archetype 隊優先讀「收到的訂單」(殘缺/可失真情報) 定貿易目標，
# 非 team_discovered 上帝視角（接「目標決策讀殘缺情報」總則）。回目標格；無回 (-1,-1)。
# _find_trade_target(team_discovered) 降為無訂單時的 fallback。
func _merchant_trade_target(state: WorldState, team: TeamData) -> Vector2i:
	if team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE:
		var ord: Dictionary = OrderSystem.new().best_arbitrage_order(state, team)
		if not ord.is_empty():
			Probe.bump("g1.arb_attempt")
			return ord["pos"]   # 履約走既有 interaction 同格 trade（到場供需若已變→撲空 emergent）
	# WS-2b 破死鎖：無 arb（沒讀過任何別隊單）→ 巡最近市集 outpost（公開地標）→ 抵達親讀看板取得 arb。
	# 有理由出門 → 碰得到看板 → 下輪有 arb → 正常套利。市集是公開地標（非偷看他隊內部）。
	var mkt: Vector2i = _nearest_market_outpost(state, team)
	if mkt != Vector2i(-1, -1):
		Probe.bump("g1.seek_market")
		return mkt
	var pid: int = _find_trade_target(state, team)
	if pid == -1:
		return Vector2i(-1, -1)
	return state.teams[pid].tile_pos

# WS-2b：找最近「有看板的市集 outpost」（outpost_level>0、非自家）。
# scan tile = 公開地標（市集告示是公開），確定性（無 RNG）。無 → (-1,-1)。
func _nearest_market_outpost(state: WorldState, team: TeamData) -> Vector2i:
	var best_pos: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level <= 0:
			continue
		if tile.outpost_owner == team.team_id:
			continue   # 自家據點看板只有自己的單，去也無跨隊 arb
		var d: int = _hex_dist(team.tile_pos, tile.tile_pos)
		if d < best_d:
			best_d = d
			best_pos = tile.tile_pos
	return best_pos

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

func _can_manufacture(state: WorldState, team: TeamData) -> bool:
	var tile_id: int      = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tile_id)
	if tile == null or tile.outpost_level == 0:
		return false
	# 任一製造類設施（工坊/冶煉/武器/護甲）才可開工
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
		var d: int = _hex_dist(from_team.tile_pos, t.tile_pos)
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

func _consider_extraction(state: WorldState, team: TeamData) -> void:
	if team.anon_treasury <= 0.0: return
	if team.leader_id == state.player_id: return   # 玩家手動
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var extract_score: float = greed - prudence * 0.5
	if extract_score > 0.4:
		var ratio: float = greed * 0.3
		_extract_treasury(state, team, ratio, "貪婪驅動")

# 滅團標記：清 faction 引用 + 排入延遲清除（資產路由延到 erase 當下，捕捉時序間加回的 coin）
func _on_team_extinct(state: WorldState, team: TeamData) -> void:
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
			# 邊緣洩漏：地圖全無有效格(radius 12) → coin 無處可路由,憑空丟失(pre-existing)。
			AnonTreasuryBank.reset(team, "extinct_no_tile_LEAK")
			ResourceBank.clear_all(team, "extinct_no_tile_LEAK")
			return
	if tile.outpost_level > 0:
		var os := OutpostSystem.new()
		# coin = resources.coin + treasury：進公庫至 cap，溢出 → abandoned_coin（守恆）
		var coin_total: float = float(team.resources.get("coin", 0)) + team.anon_treasury
		var coin_cap: float = os._get_storage_cap(tile, "coin")
		var coin_room: float = maxf(coin_cap - float(tile.public_storage.get("coin", 0)), 0.0)
		var coin_in: float = minf(coin_total, coin_room)
		tile.public_storage["coin"] = float(tile.public_storage.get("coin", 0)) + coin_in
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
			tile.public_storage[res] = stored + put
			if res in ["ore_gold", "ore_silver"]:
				tile.resources[res] = float(tile.resources.get(res, 0)) + (amt - put)
	else:
		# 無 outpost → coin+treasury 進 abandoned、ore 落地面（守恆：coin_eq 全算）；其他無容器消失
		tile.abandoned_coin += team.anon_treasury + float(team.resources.get("coin", 0))
		tile.resources["ore_gold"] = float(tile.resources.get("ore_gold", 0)) \
			+ float(team.resources.get("ore_gold", 0))
		tile.resources["ore_silver"] = float(tile.resources.get("ore_silver", 0)) \
			+ float(team.resources.get("ore_silver", 0))
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
	if tile.outpost_owner != team.team_id: return
	if tile.public_storage.is_empty(): return
	var os := OutpostSystem.new()
	for res in tile.public_storage.keys():
		var stored: float = float(tile.public_storage[res])
		var team_have: float = float(team.resources.get(res, 0))
		var needed: float = _calc_team_need(team, res)
		if team_have < needed:
			var take: float = minf(stored, needed - team_have)
			if take > 0.0:
				tile.public_storage[res] = stored - take
				ResourceBank.set_amt(team, res, team_have + take, "npc_withdraw_vault")
		elif team_have > needed * 2.0:
			var cap: float = os._get_storage_cap(tile, res)
			var deposit_max: float = cap - stored
			var deposit: float = minf(team_have - needed, deposit_max)
			if deposit > 0.0:
				tile.public_storage[res] = stored + deposit
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
	# S3 礦村 bootstrap food：礦山格自給食物極低，需額外補糧撐到 market buy 閉環
	# 補至 SURVIVAL_RECOVER_DAYS+14 天份（TEST VALUE），從 home vault 優先，不足補私產。
	var tgt_tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if tgt_tile != null and tgt_tile.terrain == "mountain" \
			and (float(tgt_tile.resource_cap.get("ore_gold", 0)) > 0.0 \
				or float(tgt_tile.resource_cap.get("ore_silver", 0)) > 0.0):
		var sub: TeamData = state.teams[sub_id]
		const BOOTSTRAP_DAYS: float = 50.0   # TEST VALUE — 礦村補糧天數（含施工+設施全周期）
		var need: float = float(sub.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY \
			* BOOTSTRAP_DAYS - float(sub.resources.get("food", 0))
		if need > 0.0:
			var from_vault: float = 0.0
			if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
				from_vault = minf(need, float(home_tile.public_storage.get("food", 0)))
				if from_vault > 0.0:
					home_tile.public_storage["food"] = float(home_tile.public_storage.get("food", 0)) - from_vault
					ResourceBank.add(sub, "food", from_vault, "mine_bootstrap_vault")
					need -= from_vault
			if need > 0.0:
				var from_owner: float = minf(need, float(leader_team.resources.get("food", 0)))
				if from_owner > 0.0:
					ResourceBank.add(leader_team, "food", -from_owner, "mine_bootstrap_owner_out")
					ResourceBank.add(sub, "food", from_owner, "mine_bootstrap_owner_in")
		print("[Infra] 礦村 bootstrap 補糧 Team%d food=%.0f" % [sub_id, float(sub.resources.get("food", 0))])
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
					home_tile.public_storage[rname] = float(home_tile.public_storage.get(rname, 0)) - rfrom_vault
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
				up_home_tile.public_storage["food"] = float(up_home_tile.public_storage.get("food", 0)) - up_from_vault
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
		if t.combat_target != -1: continue
		if t.leader_id == state.player_id and state.player_id != -1: continue
		# 糧 < 3 天不復工（餓肚子不搬磚 — 否則和 survival 搶人 ping-pong）
		# WS-2c：有效糧(私產+自家糧倉)，否則定居隊 food 在糧倉→誤判餓→永不復工建造。
		var days_left: float = ResourceSystem.effective_food(state, t) \
			/ maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		if days_left < 3.0: continue
		var is_owner: bool = t.team_id == tile.outpost_owner
		var resident_here: bool = t.tile_pos == tile.tile_pos \
			and t.faction_id == leader_team.faction_id and t.faction_id != -1 \
			and TeamData.TAG_PRODUCE in t.tags
		if not (is_owner or resident_here): continue
		# 已在工地的 return_home 殭屍態（到家但飢餓 sticky）也可復工
		var at_site_stuck: bool = t.tile_pos == tile.tile_pos \
			and t.current_task == TeamData.TASK_RETURN_HOME
		if not (t.current_task in interruptible or at_site_stuck): continue
		if t.tile_pos == tile.tile_pos:
			candidates.push_front(t)   # 在場優先
		else:
			candidates.append(t)
	if candidates.is_empty(): return
	var worker: TeamData = candidates[0]
	TaskArbiter.transition(worker, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
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
	if candidates.is_empty(): return {}
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
		out.append(tile.tile_pos)
	return out

# ──────── 基建主決策 ────────

const INFRA_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時評估一次

# leader values 決定新據點傾向（軍用 vs 民用）
func _pick_outpost_type(state: WorldState, leader_team: TeamData, leader: PersonData) -> String:
	# 文明階梯：軍鎮需 tools；無 tools 來源 → 只能蓋民村（個性想軍鎮也買不起）
	var has_tools: bool = float(leader_team.resources.get("tools", 0)) >= 3.0 \
		or _faction_has_workshop(state, leader_team)
	if not has_tools:
		return "civilian"
	var military: float = float(leader.values.get("好戰", 0.5)) + float(leader.values.get("野心", 0.5))
	var civilian: float = float(leader.values.get("慎重", 0.5)) + float(leader.values.get("貪婪", 0.5))
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

func _evaluate_infrastructure(state: WorldState, faction) -> void:
	var leader_team: TeamData = state.teams.get(faction.leader_team_id)
	if leader_team == null: return
	if leader_team.combat_target != -1: return
	var leader: PersonData = state.persons.get(leader_team.leader_id)
	if leader == null: return
	# 玩家 leader → 不自動決策（後續用 AdvisorSystem.push_outpost_advice）
	if leader_team.leader_id == state.player_id and state.player_id != -1:
		return
	var _ti: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	# (1) 升級既有 outpost
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != leader_team.team_id: continue
		if tile.outpost_level >= 3 or tile.construction_team_id != -1: continue
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
	# (3) 蓋新 outpost 前：公庫不足 + leader 不在家 + idle → 回家治理攢公庫
	var own_pos: Vector2i = _find_own_outpost(state, leader_team)
	if own_pos != Vector2i(-1, -1) and leader_team.tile_pos != own_pos:
		var home_tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
		var vault_mat: float = float(home_tile.public_storage.get("material", 0)) if home_tile else 0.0
		if vault_mat < GOVERN_MATERIAL_TARGET and leader_team.current_task == TeamData.TASK_IDLE:
			if TaskArbiter.try_set(state, leader_team, TeamData.TASK_GOVERN, own_pos,
					TaskArbiter.PRIO_DISPATCH, "govern_accumulate"):
				return
	# (3) 蓋新 outpost
	var loc: Dictionary = _evaluate_new_outpost_location(state, leader_team)
	if SimRunner.phase_timing: _ti = _fai_pht("infra.new_loc", _ti)
	if loc.is_empty(): return
	var outpost_type: String = _pick_outpost_type(state, leader_team, leader)
	# S2 礦村：含礦山地 → 強制 civilian（mint 只允 civilian；軍鎮不採礦=無意義）
	var loc_tile: HexTileData = loc.get("tile", null)
	if loc_tile != null and loc_tile.terrain == "mountain":
		# resource_cap 記初始礦量（永不清零），避免執行期礦量已被採集導致誤判
		var ore_self: float = float(loc_tile.resource_cap.get("ore_gold", 0)) \
			+ float(loc_tile.resource_cap.get("ore_silver", 0))
		if ore_self > 0.0:
			outpost_type = "civilian"
	_dispatch_builder(state, leader_team, loc.pos, outpost_type, 1)

# ──────── 設施需求迴路（score = 地利 × (1+缺口) × 個性）────────

# 回傳 { "facility": name, "demolish_first"?: name }；{} = 不蓋
func _pick_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> Dictionary:
	var slot_full: bool = OutpostSystem.slots_used(tile) >= OutpostSystem.slot_cap(tile)
	# WS-2c：有效糧(私產+自家糧倉)，否則定居隊 food 在糧倉→恆 hungry→永優先建農。
	var hungry: bool = ResourceSystem.effective_food(state, team) \
		< float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 7.0
	# 飢餓 override：缺糧 → 農田最優先（slot 滿可拆遷搶 slot）
	if hungry and tile.outpost_type == "civilian" \
			and int(tile.farming_level) == 0:
		if not slot_full:
			return { "facility": "farming" }
		var lowest: String = _lowest_score_facility(state, team, tile, leader)
		if lowest != "":
			return { "facility": "farming", "demolish_first": lowest }
		return {}
	var best: String = ""
	var best_score: float = 0.05   # 門檻：score 太低不蓋（TEST VALUE）
	for f in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[f]
		if not (tile.outpost_type in def["allowed_outpost"]): continue
		if def.has("required_terrain") and tile.terrain != def["required_terrain"]: continue
		var current: int = int(tile.get(def["current_level_key"]))
		if current > 0: continue          # 已有 → 升級走另一路徑
		if slot_full: continue
		var s: float = _facility_score(state, team, tile, leader, f)
		if s > best_score:
			best_score = s
			best = f
	if best == "": return {}
	return { "facility": best }

func _facility_score(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData, facility: String) -> float:
	return _facility_terrain_fit(state, facility, tile) \
		* (1.0 + _facility_deficit(state, team, facility, tile)) \
		* _facility_personality(leader, OutpostSystem.FACILITY_DEF[facility])

# 拆遷候選：已建設施中 score 最低者（農田不拆）
func _lowest_score_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> String:
	var lowest: String = ""
	var lowest_score: float = INF
	for f in OutpostSystem.FACILITY_DEF:
		if f == "farming": continue
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
			return 3.0 if _nearby_resource(state, tile, ["herb"]) > 0.0 else 0.0
		"smeltery", "weaponsmith", "armorsmith":
			return 3.0 if _nearby_resource(state, tile, ["ore_iron"]) > 0.0 else 0.5
		"mint":
			return 3.0 if _nearby_resource(state, tile, ["ore_gold", "ore_silver"]) > 0.0 else 0.3
		"stable":
			# required_terrain=plains 已 gate；鄰格野馬 → ×3
			return 3.0 if _nearby_resource(state, tile, ["wild_horses"]) > 0.0 else 1.0
	return 1.0

# 缺口（自身庫存 threshold，0–1）。TEST VALUES
func _facility_deficit(state: WorldState, team: TeamData, facility: String,
		tile: HexTileData) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	match facility:
		"farming":
			var target: float = pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 14.0
			# WS-2c：有效糧(私產+自家糧倉)，否則定居隊 food 在糧倉→缺口恆滿→永想擴農。
			return clampf((target - ResourceSystem.effective_food(state, team)) / target, 0.0, 1.0)
		"workshop":
			var worst: float = 1.0
			for res in ["goods", "tools", "arrows"]:
				var tgt: float = float(TradeValuation.TARGET_PER_POP.get(res, 1.0)) * pop
				worst = minf(worst, float(team.resources.get(res, 0)) / maxf(tgt, 0.001))
			return clampf(1.0 - worst, 0.0, 1.0)
		"apothecary":
			var med_tgt: float = pop * 0.2
			return clampf((med_tgt - float(team.resources.get("medicine", 0))) \
				/ maxf(med_tgt, 0.001), 0.0, 1.0) * 0.5
		"weaponsmith":
			if not _threat_recent(state, team): return 0.0
			return clampf(0.6 - team.armed_anon_ratio, 0.0, 1.0)
		"armorsmith":
			if not _threat_recent(state, team): return 0.0
			var armor: float = float(team.resources.get("armor_low", 0)) \
				+ float(team.resources.get("armor_high", 0))
			var a_tgt: float = pop * 0.3
			return clampf((a_tgt - armor) / maxf(a_tgt, 0.001), 0.0, 1.0)
		"smeltery":
			# 武器/護甲坊存在且 steel 缺
			if tile.weaponsmith_level == 0 and tile.armorsmith_level == 0: return 0.0
			var s_tgt: float = pop * 0.75
			return clampf((s_tgt - float(team.resources.get("ore_steel", 0))) \
				/ maxf(s_tgt, 0.001), 0.0, 1.0)
		"mint":
			# TILE-bound ore only：public_storage（採後入庫）+ resource_cap（礦脈存在標記）。
			# 不含 team.resources：持有 looted/traded ore 的非礦村 outpost 不應觸發 mint 建造。
			var ore_pub: float = float(tile.public_storage.get("ore_gold", 0)) \
				+ float(tile.public_storage.get("ore_silver", 0))
			var ore_cap: float = float(tile.resource_cap.get("ore_gold", 0)) \
				+ float(tile.resource_cap.get("ore_silver", 0))
			var ore: float = maxf(ore_pub, ore_cap * 0.5)
			return 1.0 if ore > 10.0 else 0.0
		"stable":
			var m_tgt: float = pop * MOUNT_TARGET_RATIO
			return clampf((m_tgt - float(team.resources.get("mounts", 0))) \
				/ maxf(m_tgt, 0.001), 0.0, 1.0)
	return 0.0

# 個性：1.0 + Σ values × pref
func _facility_personality(leader: PersonData, def: Dictionary) -> float:
	var mult: float = 1.0
	var pref: Dictionary = def.get("leader_pref", {})
	for k in pref:
		mult += float(leader.values.get(k, 0.5)) * float(pref[k])
	return mult

# 近期威脅：戰鬥中 / 有攻擊意圖 / 已知低評價 team
func _threat_recent(state: WorldState, team: TeamData) -> bool:
	if team.combat_target != -1 or team.prosperity_target_id != -1:
		return true
	for tid in team.known_reputations:
		if float(team.known_reputations[tid]) < 0.3 and state.teams.has(tid):
			return true
	return false

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
	if uses_unified(team):
		return   # unified 隊求生改由 DecisionEngine 決(切片);舊系統不雙觸發
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
	tile.resources["predator_density"] = int(tile.resources["predator_density"]) - 1
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
	OutpostOwnerBank.set_owner(tile, team.team_id, "camp")
	# 只抬 food cap（regen 才產糧）,不送即時糧。2026-06-16 A/B 量測:即時糧非 load-bearing
	# （拿掉後 2yr×4config died=0、pop 不掉）→ 移除以恢復絕境稀缺,與玩家紮營版一致。
	tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), CRUDE_CAMP_FOOD_SEED)
	# 身分躍遷（比照 _auto_settle_builder）：升軍/生產 tag、清流亡（流浪→定居，非一律生產）
	var new_tag: String = TeamData.TAG_MILITARY if is_military else TeamData.TAG_PRODUCE
	if not team.tags.has(new_tag):
		team.tags.append(new_tag)
	team.tags.erase("流亡")
	print("[CrudeCamp] Team%d 紮營 @(%d,%d) → %s" % [
		team.team_id, team.tile_pos.x, team.tile_pos.y, tile.outpost_type])
	return true

func _trigger_survival(state: WorldState, team: TeamData, severity: String) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return

	team.previous_task = team.current_task

	# 正在腳下工地蓋「農田」→ 建設即自救，不中斷（農田完工才是糧食出路，工期僅 3 天）
	# 其他設施（鑄幣廠 30 天等）照常被飢餓中斷 — 不會蓋到餓死
	if team.current_task == TeamData.TASK_BUILD:
		var cur_tile: HexTileData = state.world.tiles.get(
			team.tile_pos.x * 1000 + team.tile_pos.y)
		if cur_tile != null and cur_tile.construction_team_id == team.team_id \
				and str(cur_tile.construction_target.get("facility", "")) == "farming":
			team.previous_task = ""
			return

	# === 委派 engine survival-option scoring（單一 owner = DecisionTerms/DecisionOptions）===
	# 取代舊手寫 desperation×values branch（Path1 return/remote-loot + homeless loot/join/camp
	# + fallback forage/beg）。選擇全經 rank_survival → DecisionTerms weight × drive。
	# severity 不再對選擇加 gate（食物量級由 drive 自然表達）；entry gate(_evaluate_survival)
	# 仍用 WARNING/URGENCY 判何時進。承諾比對 current_task（non-unified 無 current_option 語意）。
	for opt in DecisionEngine.rank_survival(state, team):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue   # finder 撲空（無可派目標）→ 試次佳 option
		# 投靠對象是玩家隊 → 改走 forced_event（玩家決定收留/婉拒），不自動 merge（同 P2a W2）
		if opt == "投靠" and td.has("social_target"):
			var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
			if pp != null and int(td["social_target"]) == pp.team_id:
				if _maybe_request_join_player(state, team):
					return
		if TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_SURVIVAL, "survival"):
			SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt)   # specimen tap
			if td.has("combat_target"):
				state.set_combat_target(team, int(td["combat_target"]))
			if td.has("social_target"):
				state.set_social_target(team, int(td["social_target"]))
			match opt:   # 保留分流診斷 marker（world_sim 量測 homeless 分流）
				"掠奪":
					Probe.bump("surv.loot_dispatch")   # R1 驗收哨：絕境仍搏（拔閘後 survival loot 不降）
					print("[SurvivalLoot] team=Team%d → 掠 Team%d" % [team.team_id, int(td.get("combat_target", -1))])
				"投靠": print("[SurvivalJoin] team=Team%d → 投靠 Team%d" % [team.team_id, int(td.get("social_target", -1))])
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

func _estimate_eta_to(state: WorldState, team: TeamData, target: Vector2i) -> int:
	var path: Dictionary = PathSystem.find_path(state, team.tile_pos, target)
	if path.path.is_empty(): return 9999999
	return PathSystem.eta_ticks(team, path.cost)

func _find_weakest_prey(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: float = 999999.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue   # 無情報→不選
		if not PathSystem.estimate_catch_up(state, team, tid, true).reachable: continue
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		var pop_est: float = float(bel.get("population_est", 0.0))
		if pop_est >= float(team.population) * 0.7: continue   # belief 看似不夠弱→跳
		# 食物門檻：tier2 有 food_est 才據；無估 → 不以食物擋（不知道→不排除，由 pop 弱點決定）
		if bel.has("food_est") and float(bel.get("food_est", 0.0)) < 20.0: continue
		if pop_est < best_pop:
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

func _find_strong_neighbor(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: int = 0
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
		if pop_est > best_pop:
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
	if state.world.current_tick - team.occupying_outpost_since >= OUTPOST_TAKEOVER_DAYS * WorldState.TICKS_PER_DAY:
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
		team.tags.erase(TeamData.TAG_PRODUCE)
		team.tags.append("流亡")
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
	if leader == null: return
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
		TaskArbiter.transition(team, "等待新領主", TaskArbiter.PRIO_AMBIENT)
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
	if not _is_resident_team(state, team): return
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
	if days_since > CONTACT_TIMEOUT_DAYS:
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
