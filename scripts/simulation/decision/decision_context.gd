class_name DecisionContext

# 統一決策引擎：一隊一次蒐集的唯讀快照。
# term 函式從這裡讀驅力輸入；leader 人格 values 是 w_term 權重來源。
# 簽名對齊真實 code：effective_food/own_granary_tile（static, ResourceSystem）、
# best_arbitrage_order/team_strength（instance）、RelationGraph.strongest（讀 leader.relation_edges）。

var leader_values: Dictionary = {}
var desperation_entry_threshold: float = DecisionTerms.DESPERATION_DAYS   # ★F1 靶A：人格化 survival-entry 門檻（單一計算點、5+ applicable 共讀）
var food_days: float = 0.0
var can_rescue_build: bool = false      # ★復甦 R2 §2B.1：料備妥產糧設施自救建設 viable（build-as-survival）
var rescue_build_util: float = 0.0      # ★同上 genuine util（食安價值 frac × P(survive_to_harvest)）
var population: int = 0
var has_goods: bool = false
var has_arb: bool = false
var team_strength: float = 0.0
var threat: float = 0.0
# 序7 reaction 溶入：團潰散信號（兵卒集體恐慌）。= 高 stress 低 loyalty named 成員比例聚合。
# ctx 首讀 person stress/loyalty state（決策模型情緒腳首個接線起步；memory 腳完整接=backlog）。
# threat_pressure term 疊 team_panic × PANIC_WEIGHT → survival option（FLEE）util 升 → 潰散壓過 leader 勇氣。
# 鏡射舊 bridge panic-flee（flee_count/pop≥PANIC_RATIO）但取 state 聚合，非跑 reaction argmax。
var team_panic: float = 0.0
const PANIC_STRESS: float = 0.6   # TEST VALUE — 成員 stress 過此才算恐慌源
const PANIC_LOY: float = 0.4      # TEST VALUE — 成員 loyalty 低於此才算恐慌源（高忠不潰）
const SLACK_COMFORT_DAYS: float = 7.0   # §HOW-8 TEST VALUE — resource_slack 舒適門檻（=SURVIVAL_RECOVER_DAYS）
const YIELD_NORM: float = 20.0          # §HOW-8 TEST VALUE — absorb_yield 淨產能正規化
const YIELD_LAND_BONUS: float = 0.3     # §HOW-8 TEST VALUE — target 帶 granary/outpost 加分
var ambition_gap: int = 0
var strongest_feud: float = 0.0
# 序4 vendetta 溶入：血仇仇敵 team id（NpcAiSystem.vendetta_target 回值，鏡射舊 hand dispatch 掃描）。
# 攻擊 applicable 血仇路 + to_task 血仇 target fallback 讀此。內含衝動 gate + 可見/存在守衛。
var feud_target_id: int = -1
var has_own_outpost: bool = false
var has_manufacturing_facility: bool = false   # S1：本格有製造設施+生產權（「生產」applicable precondition，A2 補缺）
var produce_pull: float = 0.0   # ★製造 bootstrap 子根②：自家可造 outputs 的 belief demand-responsive worst-shortfall（0-1；替死常數 produce_need）
# ★B idle-labor→建設 genuine 激勵（治 §8 領導軸 size-matter）：閒 PRODUCE 勞力（pool−Σ設施 demand-cap）=真浪費。
var idle_labor: float = 0.0          # 超現產能吸納的閒 PRODUCE 勞力（手數；team 所在 tile；只 PRODUCE=軍隊天然不算）
var idle_employ_value: float = 0.0   # 雇用閒勞力於待建 mfg 設施的真 need-weighted 期望產出（anti-crank：全因子從 manufacturing 真公式反推；只加建設 util）
var is_merchant: bool = false
var has_home_outpost: bool = false
var current_task: String = ""   # ★GATE-A 二刀 touch0：team 自身 current_task（返家 hysteresis 用；自身欄非 god-view）
var has_weak_prey: bool = false
# capability grounding（藍圖 tag-soft-ruling 裁2）：self 有效武裝比（armed / pop）。
# attack/loot eval 讀此→「打得動嗎」的世界事實（無牙商隊 attack eval 趨 0=送死沒人幹，非被禁）。
# Task2 於 gather 填值（_calc_own_armed / pop）；terms.gd loot_drive/_intent_fit 疊 capability_factor。
var self_armed_ratio: float = 0.0
# 佔村（means-end：要根據地的狼打「有據點的弱村」而非追流浪隊）：可據 stationary 弱村。
var has_occupy_target: bool = false
var occupy_target_id: int = -1
var has_strong_neighbor: bool = false
var strong_neighbor_id: int = -1
var has_farmable_tile: bool = false
var farmable_pos: Vector2i = Vector2i(-1, -1)
# ★A1 紮營價值=MarginalEconomy 真帳：靶 farmable tile 的純 est（terrain=belief 地理、outpost1/farming0、pop）+ 覓食餬口日產 floor。
var camp_target_est: VillageEstimate = null   # 無靶→null（保守不行動）
var camp_forage_floor: float = 0.0
var has_aid_target: bool = false
var aid_target_id: int = -1
# 買糧（Phase 1）：最近市集 outpost + 是否有錢（specie）。
var has_food_market: bool = false
var food_market_pos: Vector2i = Vector2i(-1, -1)
var food_market_dist: int = -1
# ★買料（material means-end，Gate B）：有 material stock 的已知市集 + material 缺口。
var has_material_market: bool = false
var material_shortfall: float = 0.0
var material_build_urgency: float = 0.0   # ★v2a：max material-facility 建設迫切（買料 util 繫此=建設前置）
# Fix4 覓食可達性：本格/鄰格有可覓食 tile（無→覓食不 applicable，防 forage-to-nowhere churn）。
var has_forage_tile: bool = false
var forage_pos: Vector2i = Vector2i(-1, -1)
var has_specie: bool = false
# Fix A 買糧 look-before-leap（守感知鐵律，不濾 stale）：隊「聽過」≤MERCHANT_MAX_RANGE 的 food 賣單（received，team_known）
# 才把買糧當慾望目標——從沒聽過任何食物賣單=不追純幻覺。撲空(stale)由 Fix B 遷移/Fix C 連貫死承接。
var has_buyable_food: bool = false
# Fix B 遷移找糧 target（視野內可達 wild_game[繼承 pop 守衛] / 已知食物賣單 pos，皆過 PathSystem 可達）；(-1,-1)=真無可達已知糧源。
var food_seek_target: Vector2i = Vector2i(-1, -1)
# ★資訊網 S-herald（求援→TASK_HERALD）：有未滿足 need（食糧 runway 低/缺料/受威脅）+ 知潛在施助者（belief）。
# applicable=need+knowledge-based（非死常數門檻）；要不要真派信使=util 秤（人格 modulate）。
var help_need_severity: float = 0.0   # 未滿足 need 嚴重度 0-1（食糧缺口為主；genuine base 給 help util）
var help_target_id: int = -1          # 潛在施助者 team（自家 faction 領主，belief-pos 已知可達）；-1=無對象
var help_target_pos: Vector2i = Vector2i(-1, -1)   # 施助者 belief last-seen 位（herald travel 目標；感知鐵律）
# ★資訊網 S-scout（偵察→TASK_SCOUT）：對在乎的事有 stale/absent belief（自家子民久沒訊息）+ 可負擔斥候。
# applicable=有 info-gap+在乎（非「沉默>N」死常數）；util base=info_staleness×info_value 人格 modulate。
var scout_staleness: float = 0.0        # 最在乎實體的 belief 陳舊度 0-1（age/norm；genuine info_value base）
var scout_target_id: int = -1           # 待查實體（自家 faction 子民 belief 最陳舊者）；-1=無 info-gap
var scout_target_pos: Vector2i = Vector2i(-1, -1)   # 待查實體 belief last-seen 位（scout travel 目標）
# ★資訊網 Part2 dispatch gate（look-before-leap、治 seed regression + option 誠實）：能否真派信使/斥候。
var can_send_herald: bool = false   # pop>=2 可分 1 anon 當信使（1 人隊自己走=relocate 路）
var can_send_scout: bool = false    # named_members>=2 有 spare named（leader 外）派斥候 subteam
# Fix A-2 v2（rejection-learning）：有可達且未近期被拒的 host 才把併入當出路——破「餓世界恆拒→重選併入→又拒」loop。
# host 鏡射 to_task:200 優先序（strong_neighbor else consolidate，非 OR）；cooldown 過期可再試（非永久黑名單）。
var has_acceptable_join_host: bool = false
const JOIN_REJECT_COOLDOWN_TICKS: int = 480   # TEST VALUE — 被拒後 N tick 內不重選此 host（跨多 cadence 破 loop，過期再試）
# 經濟底：自家糧倉 food（含遠端家，team 不在家也讀得到）→ 返家補給 home-empty gate 用。
var home_food: float = 0.0
# ★GATE-A 食糧 keystone：家 outpost tile 食物再生≥燃燒率 = 產糧家（返家可採飽脫餓，非空 granary trap）。
# harvest positional→離 food-rich home 買糧=home regen 沒人採→餓死 surplus 平原。此信號讓返家補給認「產糧潛力」非只 granary stock。
var home_food_productive: bool = false
# ★F4：STAKES_SET const 已刪、單源 REGISTRY[opt].sets.stakes（options_in_set("stakes") 讀、插入序=攻擊/徵收/外交）。
# P3/P4 混合協調：派系 stakes directive 集合（攻擊/徵收/外交）。立國=leader-level（非 member option）；掠奪=非 stakes。
var faction_stakes: Array = []
var faction_attack_target: int = -1
var faction_tribute_target: int = -1
var faction_diplo_target: int = -1
# diplomacy grounded look-before-leap：求和 target(threat_id)/外交 target(faction_diplo_target) 在
# team.diplomacy_reject_cooldown 內 → 不當慾望目標（被拒不再纏 loop，鏡射 A-2 rejection-learning）。
var pacify_target_on_cooldown: bool = false
var diplo_target_on_cooldown: bool = false
var leader_loyalty: float = 0.5
# means-end 戰術層（2026-07-01）：team 自己戰略 intent 進 ctx（mirror faction_stakes）。
# 獨立=solo_intent.type / faction leader=f.intent.type（member 已有 faction_stakes → 不重覆）。
# intent_fit term 讀此把「意圖→子需求」reshape 戰術 option util（斷點：獨立隊 solo reshape 零）。
var intent: String = ""
var intent_target: int = -1
# 融合 threat（序1 溶入）：鏡射舊 _evaluate_threat 掃描（raw score over ALL discovered，
# 含 approach/power 非純 hostility；≠ ctx.threat 的 reputation-filtered _max_threat）。
# threat option（備戰/迎戰/求和）的 applicable gate + eval 讀此。
# ★失聯帳本 defensive：警覺期威脅門檻降幅（≈半個 caution×0.3 範圍、meaningful vigilance、非 fire-crank）。
const CONTACT_VIGILANCE_THREAT_DROP: float = 0.15
var threat_react: float = 0.0
var threat_id: int = -1
var threat_pos: Vector2i = Vector2i(-1, -1)
var threat_threshold: float = 0.0
# threat-oracle S1.5：純戰力比（belief-based，god-view-free）供 S2 winnable。★≠threat_react
# （threat_react=approach+hostility+power blend；此=純 other_power/self_power）。無 threat→0。
var perceived_power_ratio: float = 0.0
# threat-oracle S2：可勝性 [0,1] = self 真戰力(自知) / 感知敵戰力(belief ppr)。隨 ppr↓(敵強→難勝→低)。
# 感知鐵律:self_armed_ratio(自知真值) × 1/perceived_power_ratio(belief 敵)→虛張生效(不偷看敵真戰力)。
const WINNABLE_PPR_FLOOR: float = 0.5   # TEST VALUE — ppr 下限(避除小爆;ppr<此=我遠強→winnable 飽和)
var winnable: float = 0.0
var is_resident: bool = false
# 野心階梯（序3 rung_task 溶入）：archetype/rung 當 weight 驅動 option（非查表塞 task）。
# ambient_train_drive = FORCE-archetype 累積/擴張階練兵 base（低 magnitude 讓位緊急決策）。
var archetype: String = ""
var rung: int = 0
var has_trainable: bool = false
var ambient_train_drive: float = 0.0
# 需求金字塔重構：五層急迫度快照（gather 更新後的 team.need_urgency 拷貝，供 rank_scored 算 coeff）。
var need_urgency: PackedFloat32Array = PackedFloat32Array()
# 征服溶入（序5 prosperity）：軍力就緒度（pop/skill/food/weapon mean）+ 有效門檻（含慎重 + hunger_relief 滑降）
# + 富 prey target（find_prosperity_prey：richness×貪婪 + weakness×殘忍 + border×野心 / eta×logistics）。
# intent_fit 征服路 × readiness_factor（沒本錢趨0=readiness 閘，合憲法權重非硬閘）；攻擊 target 用 prosperity_prey_id。
# 三者鏡射舊 cascade G3/G4（calc_readiness/calc_readiness_threshold/find_prosperity_prey 已 static，ctx 呼）。
var readiness: float = 0.0
var readiness_thr_eff: float = 0.0
var prosperity_prey_id: int = -1
# A2a 子隊旗（一旗兩用）：parent_team_id != -1 → ①服從母團(歸建 duty option) ②不自主發起戰略 option(戰略-gate)。
# 非子隊 is_subteam=false → 歸建 option/戰略-gate 對其無效（零成員/solo 行為變）。
var is_subteam: bool = false
# A2c-1（FA5 折入）：整併 target（容量吸收優先，否則戰前向 leader 集結）。非-leader faction 成員
# + 非子隊才算（鏡射 _try_consolidate_merge 兩支，保真）。-1 = 無整併 target。
var consolidate_target_id: int = -1
var absorb_target_id: int = -1   # §HOW-7 吸納：capacity-bound 可吸弱鄰（強方擴張 pull）
var resource_slack: float = 0.0  # §HOW-8：養得起更多 pop 的餘裕（統領 pop_cap 空額×資源 buffer，★≠food_days 餘命）
var absorb_yield: float = 0.0    # §HOW-8：吸 absorb_target 淨收益（產能/據點 − pop 負擔，★≠richness 貪婪值）
var host_protector_rep: float = 0.5   # 名聲磁鐵 §3：本隊對 併入 host 的 protector_rep（道德聲望，主觀 per-observer）
var best_protector_rep: float = 0.5   # 名聲磁鐵 §3b：rep-選中 strong_neighbor host 的 protector_rep
# ② 絕境階梯：現在 active 的 survival stall cooldown option（applicable() 單一源排除讀此）。gather 純讀 team dict 零 RNG。
var survival_stall_active: Array = []

# 計畫層 S2 plan_phase 已退役（決策引擎重構 S2.5）→ 五層急迫度 coeff 取代；team.plan_phase
# 純顯示欄由 §6 narrative_label 寫（S2.4），不再 derive。

static func gather(state: WorldState, team: TeamData) -> DecisionContext:
	var c := DecisionContext.new()
	var _tg: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	var ldr: PersonData = state.persons.get(team.leader_id)
	c.leader_values = ldr.values.duplicate() if ldr != null else {}
	c.desperation_entry_threshold = DecisionTerms.desperation_entry_threshold(c.leader_values)   # ★F1 靶A 單一計算點（5+ survival-entry applicable 共讀；HOW §2.5.1）
	var ef: float = ResourceSystem.effective_food(state, team)
	c.food_days = ef / maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	c.population = team.population
	c.is_subteam = team.parent_team_id != -1   # A2a：子隊旗（歸建 directive + 戰略-gate）
	c.has_goods = float(team.resources.get("goods", 0)) >= 10.0
	c.has_arb = not OrderSystem.new().best_arbitrage_order(state, team).is_empty()
	c.team_strength = NpcCombatSystem.new().team_strength(state, team.team_id)
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.head", _tg)
	c.ambition_gap = maxi(team.ambition_cap - team.ambition_rung, 0)
	# feud 邊掛 leader person（relation_edges 屬 PersonData，非 TeamData）。
	var fe: Dictionary = {}
	if ldr != null:
		fe = RelationGraph.strongest(ldr.relation_edges, "feud")
	c.strongest_feud = float(fe.get("intensity", 0.0)) if not fe.is_empty() else 0.0
	# 序4：仇敵 id（衝動 gate + 可見/存在守衛在 vendetta_target 內）。攻擊 applicable/to_task 血仇路用。
	var _vfoe: int = NpcAiSystem.new().vendetta_target(state, ldr) if ldr != null else -1
	c.feud_target_id = _vfoe if (_vfoe != -1 and state.teams.has(_vfoe)) else -1
	c.has_own_outpost = ResourceSystem.own_granary_tile(state, team) != null
	c.has_manufacturing_facility = FactionAISystem.has_manufacturing_facility(state, team)   # S1 製造 precondition
	# ★復甦 R2 §2B.1：料備妥產糧設施自救建設（build-as-survival）——viable + genuine util 供「自救建田」option。
	var _rescue: Dictionary = FactionAISystem.new()._food_rescue_eval(state, team)
	c.can_rescue_build = bool(_rescue["viable"])
	c.rescue_build_util = float(_rescue["util"])
	# ★製造 bootstrap 子根②：produce_pull=自家可造 outputs 的 worst-shortfall ratio（belief demand-responsive，
	# 替 produce_need 死常數 0.3/0.6）。★感知鐵律:demand()=_trade_demand 讀 team_known 親聞單（非 global order book）。
	c.produce_pull = 0.0
	if c.has_manufacturing_facility:
		var _ptile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		if _ptile != null:
			var _best: float = 0.0
			for level_key in ManufacturingSystem.RECIPE_GROUPS:
				if int(_ptile.get(level_key)) <= 0:
					continue   # 無此設施
				for recipe in ManufacturingSystem.RECIPE_GROUPS[level_key]:
					var out: String = recipe["out"]
					var target: float = NeedOracle.need_keep(state, team, out, c.leader_values) \
						+ NeedOracle.demand(state, team, out, c.leader_values)   # 自用+★belief 親聞買單
					if target <= 0.001:
						continue   # 該 out 無 need+demand → 不驅生產
					var hold: float = float(team.resources.get(out, 0)) + float(_ptile.public_storage.get(out, 0))   # 對齊 manufacturing:139 target
					_best = maxf(_best, clampf((target - hold) / target, 0.0, 1.0))
			c.produce_pull = _best
	# ★B idle-labor→建設：閒 PRODUCE 勞力（pool−Σ workstation demand-cap）→ 雇用於待建產能=genuine 期望產出。
	# 只在 team 站自家 outpost 才算（建設落自家據點）。idle=0 或無需求 → idle_employ_value=0（不亂建）。
	c.idle_labor = 0.0
	c.idle_employ_value = 0.0
	var _btile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if _btile != null and _btile.outpost_owner == team.team_id and _btile.outpost_level > 0:
		LaborSystem.ensure_fresh(state, _btile)   # lazy：直讀 labor_alloc（勞力池 cadence 已存、頻率解耦）
		var _pool: float = LaborSystem.pool_of(state, _btile)
		var _dcap: float = 0.0
		for _lk in _btile.labor_alloc:
			_dcap += float(_btile.labor_alloc[_lk].get("demand", 0.0))   # 現 active workstation 吸得掉的手數
		c.idle_labor = maxf(_pool - _dcap, 0.0)
		if c.idle_labor > 0.0:
			# ★perf：_idle_employ_value 遞迴呼 NeedOracle（supply_chain/construction tile-scan）昂貴 → cadence-gate 快取
			# （單寫者=本 owner 隊；LABOR_CADENCE 同勞力池，staleness 有界；決策每 tick 只 O(1) 讀）。
			if state.world.current_tick < _btile.idle_employ_next_tick:
				c.idle_employ_value = _btile.idle_employ_cached
			else:
				c.idle_employ_value = DecisionContext._idle_employ_value(state, team, _btile, c.idle_labor, c.leader_values)
				_btile.idle_employ_cached = c.idle_employ_value
				_btile.idle_employ_next_tick = state.world.current_tick + LaborSystem.LABOR_CADENCE
	c.is_merchant = team.tags.has(TeamData.TAG_MERCHANT)
	c.has_home_outpost = FactionAISystem.new()._find_own_outpost(state, team) != Vector2i(-1, -1)
	c.current_task = team.current_task   # ★GATE-A 二刀 touch0：自身 current_task（返家 hysteresis；自身欄非 god-view）
	# threat（F-D6 un-stub）：視野內最高敵威脅（belief-based ThreatAssessment，含逼近/敵意/距離衰減）。
	# 餵 threat_pressure term → unified 隊(商隊/生產)遇逼近敵會 FLEE（威脅真驅動非死 stub）。
	c.threat = DecisionContext._max_threat(state, team)
	# 序7 reaction 溶入：team_panic = 高 stress 低 loyalty named 成員比例（anon 無個體 state 不計；
	# 迭 named_members 非全 persons=O(named) 非 O(N²)）。集體潰散→survival option 自然驅動 FLEE。
	var _panic_n: int = 0
	for _ppid in team.named_members:
		var _pp: PersonData = state.persons.get(int(_ppid))
		if _pp == null: continue
		if _pp.stress > PANIC_STRESS and _pp.loyalty < PANIC_LOY:
			_panic_n += 1
	c.team_panic = clampf(float(_panic_n) / maxf(float(team.population), 1.0), 0.0, 1.0)
	# 融合 threat：鏡射舊 _evaluate_threat 掃描（raw score over ALL discovered，含 approach/power 非純 hostility）。
	var _caution: float = float(c.leader_values.get("慎重", 0.5))
	c.threat_threshold = ThreatAssessment.THREAT_BASE_THRESHOLD + _caution * 0.3
	# ★失聯帳本 defensive 真 consumer：警覺期內→威脅門檻降（餵既有 threat gate、備戰/防衛更易 fire；非新平行旋鈕）。
	if team.contact_vigilant_until > state.world.current_tick:
		c.threat_threshold = maxf(c.threat_threshold - CONTACT_VIGILANCE_THREAT_DROP, 0.0)
	var _best_t: float = 0.0
	var _best_id: int = -1
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var _other: TeamData = state.teams.get(tid)
		if _other == null: continue
		var _t: float = ThreatAssessment.score(state, team, _other)
		if _t > _best_t:
			_best_t = _t; _best_id = tid
	c.threat_react = _best_t
	c.threat_id = _best_id
	if _best_id != -1:
		var _ot: TeamData = state.teams.get(_best_id)
		if _ot != null:
			# A1 感知鐵律：threat DEFEND/求和 move target = belief last-seen（敵脫視→追 last-seen 非瞬鎖 live 真位）。
			# 鏡射攻擊 options.gd:194 belief_pos；threat_pos 無其他消費者（只 :294/:305 move target）故全域改此源。
			c.threat_pos = BeliefSystem.belief_pos(state, team.team_id, _best_id)
			# S1.5：純戰力比（belief-based，god-view-free）供 S2 winnable（禁拿 threat_react 當 proxy）。
			c.perceived_power_ratio = ThreatAssessment._power_ratio(state, team, _ot)
	c.is_resident = FactionAISystem.is_resident_static(state, team)
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.threat", _tg)
	var _fa := FactionAISystem.new()
	var _prey: int = _fa._find_weakest_prey(state, team)
	c.has_weak_prey = _prey != -1
	# capability grounding（裁2）：self 有效武裝比 → attack/loot「打得動嗎」世界事實。
	# 無牙商隊 armed≈0 → ratio≈0 → loot_drive/intent_fit capability_factor 壓平（送死沒人幹，非被禁）。
	c.self_armed_ratio = float(_fa._calc_own_armed(state, team)) / maxf(float(team.population), 1.0)
	# threat-oracle S2：可勝性（self_armed 自知 × 1/perceived_power belief 敵；ppr 需先算=threat 段已設）。
	c.winnable = clampf(c.self_armed_ratio / maxf(c.perceived_power_ratio, WINNABLE_PPR_FLOOR), 0.0, 1.0)
	# 佔村 target（可據 stationary 弱村；belief-driven weakness，可見性物理判可據）
	var _occ: int = _fa._find_occupy_target(state, team)
	c.has_occupy_target = _occ != -1
	c.occupy_target_id = _occ
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.weak_prey", _tg)
	# 名聲磁鐵 §3b：strong_neighbor 用 rep 軸選（投奔高 protector_rep 保護傘，喂-讀對齊）。
	var _sn: int = _fa._find_strong_neighbor(state, team, "rep")
	c.has_strong_neighbor = _sn != -1
	c.strong_neighbor_id = _sn
	c.best_protector_rep = team.get_protector_rep(_sn) if _sn != -1 else 0.5   # 選中 host rep 供 join_drive 磁鐵
	if Probe.enabled and _sn != -1 and absf(c.best_protector_rep - 0.5) > 0.01:
		Probe.bump("rep.host_nonneutral")   # DIAG：磁鐵有差別（strong_neighbor protector_rep 脫 0.5）
	var _ft: Vector2i = _fa._find_unowned_farmable_tile(state, team)
	c.has_farmable_tile = _ft != Vector2i(-1, -1)
	c.farmable_pos = _ft
	# ★A1：紮營靶 est（terrain=靶 tile 地理 belief、outpost1/farming0/pop）+ 覓食餬口日產 floor（camp_marginal 用）。
	if c.has_farmable_tile:
		var _ftile: HexTileData = state.world.tiles.get(ResourceSystem._pos_to_tile_id(_ft))
		if _ftile != null:
			c.camp_target_est = VillageEstimate.make(_ftile.terrain, 1, 0, team.population)
	c.camp_forage_floor = ResourceSystem._forage_subsist_buffer(team) / ResourceSystem.FORAGE_FLOOR_DAYS   # 日產同源
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.strong_farm", _tg)
	var _aid: int = _fa._find_aid_target(state, team)
	c.has_aid_target = _aid != -1
	c.aid_target_id = _aid
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.aid", _tg)
	# P3 混合協調：loyalty 注入 leader_values（weight("faction_duty") 讀，避擴 weight 簽名；
	# `_` 前綴非人格值，既有 term match 不誤讀，leader_values 已 duplicate 不污染 PersonData）。
	c.leader_loyalty = ldr.loyalty if ldr != null else 0.5
	c.leader_values["_loyalty"] = c.leader_loyalty
	# 買糧（Phase 1）：注入 _is_merchant（weight("buyfood") 讀，同 _loyalty 法）+ 最近市集 + 有錢。
	c.leader_values["_is_merchant"] = c.is_merchant
	# ★perf slice A：refresh market cache 一次(call-scoped)、下兩 finder skip_refresh 讀 cache（去 _harvest_market_known 100% 冗餘二刷）。
	_fa._harvest_market_known(state, team)
	var _mkt: Vector2i = _fa._nearest_market_outpost(state, team, true)
	c.has_food_market = _mkt != Vector2i(-1, -1)
	c.food_market_pos = _mkt
	c.food_market_dist = _fa._hex_dist(team.tile_pos, _mkt) if c.has_food_market else -1
	# ★買料信號（material means-end，Gate B）：有 material stock 的已知市集 + material 缺口（need_keep 含 construction need）。
	c.has_material_market = _fa._nearest_market_outpost_with(state, team, "material", true) != Vector2i(-1, -1)
	c.material_shortfall = maxf(NeedOracle.need_keep(state, team, "material", c.leader_values) \
		- ResourceSystem.effective_holding(state, team, "material"), 0.0)
	c.material_build_urgency = NeedOracle.max_material_facility_desire(state, team)   # ★v2a：買料 util 繫建設迫切
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.market", _tg)
	# Fix4 覓食可達性：本格/鄰格有 wild_game tile 才可覓食（鏡射 market 一次性 gather，避每 option 重跑）。
	var _fg: Vector2i = _fa._find_forage_tile(state, team)
	c.has_forage_tile = _fg != Vector2i(-1, -1)
	c.forage_pos = _fg
	# has_specie 廣義納可交易特產：coin / goods / material / ore（forest=木材 mountain=礦 換糧籌碼）。
	# Fix3c 償付能力認全部家當：武器超出戰備留底=可變現換糧（barter 已支援武器,見 _attempt_barter+BASE_PRICE 含 weapon_*）。
	# 修「滿手武器卻機械判定買不起糧餓死」——用 reserve 只認超留底(不逼賣光防身武器)。
	var _weapon_liquid: bool = false
	for _w in ["weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high"]:
		if float(team.resources.get(_w, 0)) - TradeValuation.reserve(team, _w) > 0.0:
			_weapon_liquid = true
			break
	c.has_specie = float(team.resources.get("coin", 0)) > 0.0 \
		or float(team.resources.get("goods", 0)) >= 10.0 \
		or float(team.resources.get("material", 0)) >= DecisionTerms.MATERIAL_TRADE_MIN \
		or float(team.resources.get("ore_iron", 0)) + float(team.resources.get("ore_gold", 0)) >= DecisionTerms.MATERIAL_TRADE_MIN \
		or _weapon_liquid
	# home_food：自家糧倉 food（掃自有 outpost tile，team 不在家也讀得到 → 空家判定）。
	c.home_food = DecisionContext._home_granary_food(state, team)
	# ★GATE-A：home_food_productive=家 outpost tile 食物再生≥燃燒率（產糧潛力，非只 granary stock）。
	# ★感知鐵律 clean：自家 outpost terrain=自家知識，非 god-view 世界。
	c.home_food_productive = false
	if c.has_home_outpost:
		var _hp: Vector2i = _fa._find_own_outpost(state, team)
		var _htile: HexTileData = state.world.tiles.get(_hp.x * 1000 + _hp.y)
		if _htile != null:
			var _regen: float = float(ResourceSystem.REGEN_RATE.get(_htile.terrain, {}).get("food", 0.0)) * _htile.harvest_factor
			var _burn: float = float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			c.home_food_productive = _regen >= _burn
	# Fix A 買糧 look-before-leap：隊「聽過」≤MERCHANT_MAX_RANGE 的 food 賣單才追買糧
	# （received=team_known 物理在場/傳播，守感知鐵律；★不濾 stale=血訓 G1d/r3，撲空由 B/C 承接）。
	c.has_buyable_food = false
	for _so in OrderSystem.new().received_sell_orders(state, team):
		if String(_so.get("res", "")) == "food" \
				and _fa._hex_dist(team.tile_pos, _so.get("pos", Vector2i.ZERO)) <= OrderSystem.MERCHANT_MAX_RANGE:
			c.has_buyable_food = true
			break
	# Fix B 遷移找糧 target（視野內可達 wild_game[pop 守衛] / 已知食物賣單 pos，皆過 PathSystem 可達）。
	c.food_seek_target = _fa._find_food_seek_target(state, team)
	# ★資訊網 S-herald：未滿足 need severity（食糧 runway 缺口為主 genuine base）+ 知潛在施助者（自家 faction 領主 belief-pos）。
	# severity=真 runway 缺口（deficit_severity），非死常數；help_target=領主（belief 已知位、非自己、非子隊已 pin）。
	c.help_need_severity = clampf((DecisionTerms.DESPERATION_DAYS - c.food_days) / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	c.help_target_id = -1
	c.help_target_pos = Vector2i(-1, -1)
	if team.faction_id != -1 and c.help_need_severity > 0.0:
		var _hf = state.factions.get(team.faction_id)
		if _hf != null and _hf.leader_team_id != -1 and _hf.leader_team_id != team.team_id:
			# 施助者=自家領主；位 fresh belief 優先→無→★名冊 fallback（組織常識:知自家領主固定據點位，破 bootstrap 死結）。
			var _hpos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, _hf.leader_team_id).get("tile_pos", Vector2i(-1, -1))
			if _hpos == Vector2i(-1, -1):
				_hpos = FactionAISystem._faction_roster_pos(state, team, _hf.leader_team_id)   # ★名冊 fallback（只位置零 live-state）
				if _hpos != Vector2i(-1, -1) and Probe.enabled: Probe.bump("help.roster_fallback")
			if _hpos != Vector2i(-1, -1):
				c.help_target_id = _hf.leader_team_id
				c.help_target_pos = _hpos
	# ★資訊網 S-scout：領主對自家子民 belief 陳舊 → 派斥候查（active 版求援；症1/famine 領主主動探子民 need）。
	# staleness = belief age / norm（錨 BeliefSystem.SCOUT_TIMEOUT，非死常數）；target=最陳舊且知位的子民。
	c.scout_staleness = 0.0; c.scout_target_id = -1; c.scout_target_pos = Vector2i(-1, -1)
	if team.faction_id != -1:
		var _sf = state.factions.get(team.faction_id)
		if _sf != null and _sf.leader_team_id == team.team_id:   # 只領主探子民（在乎自家人）
			var _norm: float = float(BeliefSystem.SCOUT_TIMEOUT)
			for _mid in state.teams:
				if _mid == team.team_id: continue
				var _mt: TeamData = state.teams[_mid]
				if _mt.faction_id != team.faction_id: continue
				var _be: Dictionary = BeliefSystem.best_estimate(state, team.team_id, _mid)
				var _mpos = _be.get("tile_pos", Vector2i(-1, -1))
				var _st: float
				if _mpos == Vector2i(-1, -1):
					# ★名冊 fallback（破 bootstrap:從沒親聞子民→查其固定據點位）；無固定據點(移動子民)→跳。
					_mpos = FactionAISystem._faction_roster_pos(state, team, _mid)
					if _mpos == Vector2i(-1, -1): continue
					_st = 1.0   # 從沒親聞=最陳舊=最該查（genuine：無資訊=max staleness）
					if Probe.enabled: Probe.bump("scout.roster_fallback")
				else:
					var _age: int = state.world.current_tick - int(_be.get("last_tick", 0))
					_st = clampf(float(_age) / maxf(_norm, 1.0), 0.0, 1.0)
				if _st > c.scout_staleness:
					c.scout_staleness = _st; c.scout_target_id = _mid; c.scout_target_pos = _mpos
	# ★資訊網 Part2 dispatch gate：能否真派（look-before-leap，unexecutable option 不進 rank=治 regression+誠實）。
	c.can_send_herald = team.population >= 2   # 可分 1 anon 信使（pop 1 自己走 relocate）
	c.can_send_scout = team.named_members.size() >= 2   # spare named（leader 外）派斥候 subteam
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.home_food", _tg)
	# 派系 stakes directive 集合（攻擊/徵收/外交；mirror P3 攻擊）。
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null:
			for g in DecisionOptions.options_in_set("stakes"):
				if g in f.goals: c.faction_stakes.append(g)
			if "攻擊" in c.faction_stakes:
				var _at: int = _fa._nearest_independent(state, team)
				c.faction_attack_target = _at
			if "徵收" in c.faction_stakes:
				var _rt: int = _fa._richest_member(state, f)
				if _rt == team.team_id: _rt = -1   # 不對自己徵收（_richest_member 未排自身）
				c.faction_tribute_target = _rt
			if "外交" in c.faction_stakes:
				var _dt: int = _fa._nearest_independent(state, team)
				c.faction_diplo_target = _dt
	# diplomacy grounded look-before-leap：求和(threat_id)/外交(faction_diplo_target) target 在
	# reject_cooldown 內 → flag（被拒不再纏；純讀自隊記憶，非 god-view）。
	var _now: int = state.world.current_tick
	c.pacify_target_on_cooldown = c.threat_id != -1 \
		and int(team.diplomacy_reject_cooldown.get(c.threat_id, 0)) > _now
	c.diplo_target_on_cooldown = c.faction_diplo_target != -1 \
		and int(team.diplomacy_reject_cooldown.get(c.faction_diplo_target, 0)) > _now
	# team 自己戰略 intent（means-end 戰術層）：獨立=solo_intent / faction leader=f.intent。
	# member 已由 faction_stakes 供 tactical 訊號 → 不重覆注入（避雙寫同義）。
	if team.faction_id == -1:
		c.intent = FactionAISystem._solo_type(team)
	else:
		var fi = state.factions.get(team.faction_id)
		if fi != null and fi.leader_team_id == team.team_id and fi.intent is Dictionary:
			c.intent = String(fi.intent.get("type", ""))
			c.intent_target = int(fi.intent.get("target_id", -1))
	# 征服意圖 target fallback（F2：死欄 intent_target_pos 已刪；保留 intent_target 賦值=真消費 by intent_fit）。
	# 無 faction target（或 target 不存在）+ 有 weak_prey → intent_target 用 prey（intent_fit 攻擊路徑用）。
	if c.intent == "征服" and c.has_weak_prey \
			and (c.intent_target == -1 or not state.teams.has(c.intent_target)):
		c.intent_target = _prey
	# 野心階梯（序3 rung_task 溶入）：archetype/rung 成 weight context；FORCE 累積/擴張階 → 練兵 base。
	c.archetype = team.ambition_archetype
	c.rung = team.ambition_rung
	c.has_trainable = not team.anon_cohorts.is_empty()   # 有 anon 可練
	# ★named-scarcity B（真根修）：訓練 util = f(officer-need)——取代舊 flat 0.5 死常數（跟 officer-need 脫鉤的
	#   fake number、缺 officer 領主照樣不練=硬數據 0.33 永輸 build）。缺 officer(記名<desired)→訓練值高贏 argmax
	#   →練兵→tier-up→promote 好 officer；officer 夠/非領主→officer_need=0→訓練值 0 不練（bounded 非 always-train）。
	c.ambient_train_drive = FactionAISystem.officer_need(state, team) * FactionAISystem.TRAIN_OFFICER_MAG
	# plan_phase 退役（S2.5）：team.plan_phase 由 §6 narrative_label 於 gather 尾寫（S2.4），此處不再 derive。
	# 征服溶入（序5）：readiness/thr_eff/富 prey（鏡射舊 cascade G3/G4，helper 已 static）。
	# readiness_thr_eff = threshold × hunger_relief（越餓門檻越低=豁出去搶糧；連續信號零新閘）。
	if ldr != null:
		c.readiness = FactionAISystem.calc_readiness(state, team)
		var _thr: float = FactionAISystem.calc_readiness_threshold(team, ldr)
		var _hunger_relief: float = clampf(c.food_days / FactionAISystem.HUNGER_SLIDE_DAYS, \
			FactionAISystem.RELIEF_FLOOR, 1.0)
		c.readiness_thr_eff = _thr * _hunger_relief
		# 富 prey target（find_prosperity_prey：has_belief/reachable 守衛在內；征服攻擊 target 用此非 _nearest）。
		c.prosperity_prey_id = FactionAISystem.find_prosperity_prey(state, team, ldr)
		# 征服攻擊 target 改用富 prey（取代 weak_prey fallback；faction leader 指定 target 不覆蓋）。
		# 4b：richness/border/logistics 富選勝「只挑最弱」。無富 prey → 保留 weak_prey fallback（intent 段已設）。
		if c.intent == "征服" and c.prosperity_prey_id != -1 \
				and (c.intent_target == -1 or c.intent_target == _prey):
			c.intent_target = c.prosperity_prey_id
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.readiness_prey", _tg)
	# 併入/吸納 target（cadence gate 1 日共用，防每 tick O(N) finder churn）。非子隊才算。
	c.consolidate_target_id = -1
	c.absorb_target_id = -1
	if team.parent_team_id == -1:
		if state.world.current_tick >= team.consolidate_eval_next_tick:
			# §HOW-6 併入 target（faction 成員 push）
			var ct: int = -1
			if team.faction_id != -1:
				var _f = state.factions.get(team.faction_id)
				if _f != null and team.team_id != _f.leader_team_id:
					ct = FactionAISystem.consolidate_target_of(state, team, _f)
			team.consolidate_target_cache = ct
			# §HOW-7 吸納 target（強方 pull，capacity-bound 弱鄰）
			team.absorb_target_cache = FactionAISystem.new()._find_absorb_target(state, team)
			team.consolidate_eval_next_tick = state.world.current_tick + FactionAISystem.CONSOLIDATE_CADENCE
		c.consolidate_target_id = team.consolidate_target_cache
		c.absorb_target_id = team.absorb_target_cache
		# 名聲磁鐵 §3：本隊對 host 的 protector_rep（主觀 per-observer，禁全域真值）
		if c.consolidate_target_id != -1:
			c.host_protector_rep = team.get_protector_rep(c.consolidate_target_id)
		if Probe.enabled and team.absorb_target_cache != -1:
			Probe.bump("absorb.target_found")   # DIAG：有 capacity-bound 弱鄰可吸（finder 非空）
	# §HOW-8 resource_slack（systems 公式）：空 pop 容量 × 舒適度（≠food_days 餘命；spare 主軸、comfort gate）。
	var _cmd: float = float(ldr.skills.get("統領", 0.0)) if ldr != null else 0.0
	var _cap: int = TeamData.pop_cap_from_leadership(_cmd)
	var _spare: float = clampf(float(_cap - team.population) / maxf(float(_cap), 1.0), 0.0, 1.0)
	var _comfort: float = clampf(c.food_days / SLACK_COMFORT_DAYS, 0.0, 1.0)
	c.resource_slack = _spare * _comfort
	# §HOW-8 absorb_yield（systems 公式）：target 自養能力=產能−pop 負擔+帶地（≠richness 貪婪值）。
	if c.absorb_target_id != -1:
		var _tgt: TeamData = state.teams.get(c.absorb_target_id)
		# A2 感知鐵律：yield 禁 god-view 直讀 target effective_food/population。belief schema 無 food_est → 降級：
		# gate on has_belief（無 belief→yield 0，不 god-view）；有 belief→population_est proxy（保守，無食估→用規模；
		# measurer 驗併入 known-target 仍 fire）。帶地 bonus 走 belief-gate 內（已見過→約略知其據點）。
		if _tgt != null and BeliefSystem.has_belief(state, team.team_id, c.absorb_target_id):
			var _pop_est: float = float(BeliefSystem.best_estimate(state, team.team_id, c.absorb_target_id).get("population_est", 0.0))
			var _land: float = YIELD_LAND_BONUS if ResourceSystem.own_granary_tile(state, _tgt) != null else 0.0
			c.absorb_yield = clampf(_pop_est / YIELD_NORM + _land, -1.0, 1.0)
		# DIAG §HOW-8：吸納 utility 組件分布（證 decision-到位 vs formula-always-0）
		if Probe.enabled:
			Probe.bump("absorb.util_n")
			Probe.add_amount("absorb.slack_sum", c.resource_slack)
			Probe.add_amount("absorb.yield_sum", c.absorb_yield)
			if c.resource_slack > 0.05: Probe.bump("absorb.slack_pos")
			if c.absorb_yield > 0.0: Probe.bump("absorb.yield_pos")
	# Fix A-2 v2（rejection-learning）：有可達且未近期被拒的 host 才把併入當出路（破恆拒 loop）。
	# host 鏡射 to_task:200 優先序（strong_neighbor else consolidate，非 OR）；純讀 memory/PathSystem。
	c.has_acceptable_join_host = false
	var _jhost: int = c.strong_neighbor_id if c.strong_neighbor_id != -1 else c.consolidate_target_id
	if _jhost != -1 and state.teams.has(_jhost):
		# ★god-view follow-up：jhost 位讀 belief（同 1119/Slice D position 範式）。無 belief（positionless/斷視線太舊）
		# →(-1,-1)→_reachable false（不知對方在哪=無法算 join 可達，不讀 live god-view）。team.tile_pos=自身合法。
		var _jpos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, _jhost)
		var _reachable: bool = _jpos != Vector2i(-1, -1) \
			and not PathSystem.find_path(state, team.tile_pos, _jpos).path.is_empty()
		var _recently_rejected: bool = false
		if ldr != null:
			for _m in ldr.memory:
				if String(_m.get("type", "")) == "join_rejected" \
						and int(_m.get("subject_id", -1)) == _jhost \
						and state.world.current_tick - int(_m.get("tick", 0)) < JOIN_REJECT_COOLDOWN_TICKS:
					_recently_rejected = true
					break
		c.has_acceptable_join_host = _reachable and not _recently_rejected
	# 需求金字塔（決策引擎重構 S1）：五層急迫度 EWMA 更新（inert——本 slice 不接 rank_scored）。
	# compute_raw 讀 food_days/threat(已算) + team/state；ewma_update 累積進持久 team.need_urgency。
	var _raw_need: PackedFloat32Array = NeedHierarchy.compute_raw(state, team, c.food_days, c.threat)
	team.need_urgency = NeedHierarchy.ewma_update(team.need_urgency, _raw_need)
	c.need_urgency = team.need_urgency
	# §6 主敘事標籤：team.plan_phase 來源改接五層急迫度衍生(argmax)，非 derive_plan_phase 自算。
	# GUI(observer_query_api/observer_inspect_panel)讀 team.plan_phase 不變，來源改接。
	team.plan_phase = NeedHierarchy.narrative_label(team.need_urgency)
	# ② 絕境階梯：蒐 active stall cooldown option（applicable() 排除單一源；純讀 dict 零 RNG）。
	var _stall_now: int = state.world.current_tick
	for _sopt in team.survival_stall_cooldown:
		if _stall_now < int(team.survival_stall_cooldown[_sopt]):
			c.survival_stall_active.append(_sopt)
	return c

# 視野內最高敵威脅（F-D6）：掃 discovered，取 ThreatAssessment.score 最大值。
# belief-based（認知非全知）；dist≥5 衰減 0（遠敵不算）。
# **只算 distrusted(rep<neutral) 敵**：neutral/盟(投靠對象)不算威脅 → threat 不壓過 join/camp。
# **clamp 上限 1**：threat = 次要 survival 信號（threat_pressure term），不碾壓 starvation/join/camp 絕境。
static func _max_threat(state: WorldState, team: TeamData) -> float:
	var best: float = 0.0
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		if other.faction_id == team.faction_id and team.faction_id != -1: continue
		if float(team.known_reputations.get(tid, ThreatAssessment.REPUTATION_NEUTRAL)) \
				>= ThreatAssessment.REPUTATION_NEUTRAL:
			continue   # neutral/盟不算威脅（避 threat 壓過 join/camp 絕境）
		var t: float = ThreatAssessment.score(state, team, other)
		if t > best: best = t
	return clampf(best, 0.0, 1.0)

# ★B idle-labor→建設 genuine 激勵值：雇用閒 PRODUCE 勞力於「待建 mfg 設施」的真 need-weighted 期望產出。
# ★★anti-crank（reviewer 追蹤項、乙教訓）：禁發明 PER_HAND 常數——全因子從 manufacturing 真 worker_rate 反推：
#   d_new              = 候選 facility 新增 demand = level × K_MFG（level=cur+1）
#   facility_full_output = level × LABOR_SCALE × (0.5+avg_skill×0.5) × RATES[recipe]  # manufacturing:94,150 代 fill=1
#   employ_value       = min(idle_labor/d_new, 1.0) × facility_full_output × need_weight(產物)
# = 雇用閒勞力的真 need-weighted 期望產出。取所有可建 mfg 設施×配方 max（最值得雇用機會）。
# idle=0 或無需求（need_weight=0）→ 0（不亂建）；self-limit（idle 隨 facility 吸收遞減）。
static func _idle_employ_value(state: WorldState, team: TeamData, tile: HexTileData, idle_labor: float, lv: Dictionary) -> float:
	var avg_skill: float = ManufacturingSystem.new()._avg_skill(state, team, "製造")
	var best: float = 0.0
	for facility in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[facility]
		var lkey: String = String(def["current_level_key"])
		if not ManufacturingSystem.RECIPE_GROUPS.has(lkey):
			continue   # 只 mfg 設施（有配方）；gather/mint 非本 MVP
		if not (tile.outpost_type in def.get("allowed_outpost", [])):
			continue   # 該格能建型（civilian/military gate）
		var cur: int = int(tile.get(lkey))
		if cur >= 3:
			continue   # 已滿級無新產能可建
		var level: int = cur + 1
		var d_new: float = float(level) * LaborSystem.K_MFG
		if d_new <= 0.0:
			continue
		var fill_frac: float = minf(idle_labor / d_new, 1.0)   # 閒勞力能填新工位的比例（self-limit）
		for recipe in ManufacturingSystem.RECIPE_GROUPS[lkey]:
			var out: String = String(recipe["out"])
			var need_weight: float = NeedOracle.need_keep(state, team, out, lv) + NeedOracle.demand(state, team, out, lv)
			if need_weight <= 0.0:
				continue   # 無需求產物 → 不建（genuine 非亂建）
			var rate: float = float(ManufacturingSystem.RATES[recipe["rate_const"]])
			var full_output: float = float(level) * LaborSystem.LABOR_SCALE * (0.5 + avg_skill * 0.5) * rate
			best = maxf(best, fill_frac * full_output * need_weight)
	return best

# 自家糧倉 food：掃自有 outpost tile（owner==team_id）取 public_storage food。
# own_granary_tile 只在 team 站在自家據點時回傳；返家補給 gate 須在「離家」時也讀得到家糧 →
# 仿 _find_own_outpost 掃法（不限本格），無自家 outpost → 0。
static func _home_granary_food(state: WorldState, team: TeamData) -> float:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
			return float(tile.public_storage.get("food", 0))
	return 0.0
