class_name DecisionContext

# 統一決策引擎：一隊一次蒐集的唯讀快照。
# term 函式從這裡讀驅力輸入；leader 人格 values 是 w_term 權重來源。
# 簽名對齊真實 code：effective_food/own_granary_tile（static, ResourceSystem）、
# best_arbitrage_order/team_strength（instance）、RelationGraph.strongest（讀 leader.relation_edges）。

var leader_values: Dictionary = {}
var food_days: float = 0.0
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
var is_merchant: bool = false
var has_home_outpost: bool = false
var has_weak_prey: bool = false
var weak_prey_pos: Vector2i = Vector2i(-1, -1)
# capability grounding（藍圖 tag-soft-ruling 裁2）：self 有效武裝比（armed / pop）。
# attack/loot eval 讀此→「打得動嗎」的世界事實（無牙商隊 attack eval 趨 0=送死沒人幹，非被禁）。
# Task2 於 gather 填值（_calc_own_armed / pop）；terms.gd loot_drive/_intent_fit 疊 capability_factor。
var self_armed_ratio: float = 0.0
# 佔村（means-end：要根據地的狼打「有據點的弱村」而非追流浪隊）：可據 stationary 弱村。
var has_occupy_target: bool = false
var occupy_target_id: int = -1
var occupy_target_pos: Vector2i = Vector2i(-1, -1)
var has_strong_neighbor: bool = false
var strong_neighbor_id: int = -1
var strong_neighbor_pos: Vector2i = Vector2i(-1, -1)
var has_farmable_tile: bool = false
var farmable_pos: Vector2i = Vector2i(-1, -1)
var has_aid_target: bool = false
var aid_target_id: int = -1
var aid_target_pos: Vector2i = Vector2i(-1, -1)
# 買糧（Phase 1）：最近市集 outpost + 是否有錢（specie）。
var has_food_market: bool = false
var food_market_pos: Vector2i = Vector2i(-1, -1)
var food_market_dist: int = -1
var has_specie: bool = false
# 經濟底：自家糧倉 food（含遠端家，team 不在家也讀得到）→ 返家補給 home-empty gate 用。
var home_food: float = 0.0
# P3/P4 混合協調：派系 stakes directive 集合（攻擊/徵收/外交）。
# 立國=leader-level（_declare_established，非 member option）；掠奪=日常個體（非 stakes）。
const STAKES_SET: Array = ["攻擊", "徵收", "外交"]
var faction_stakes: Array = []
var faction_attack_target: int = -1
var faction_attack_target_pos: Vector2i = Vector2i(-1, -1)
var faction_tribute_target: int = -1
var faction_tribute_target_pos: Vector2i = Vector2i(-1, -1)
var faction_diplo_target: int = -1
var faction_diplo_target_pos: Vector2i = Vector2i(-1, -1)
var leader_loyalty: float = 0.5
# means-end 戰術層（2026-07-01）：team 自己戰略 intent 進 ctx（mirror faction_stakes）。
# 獨立=solo_intent.type / faction leader=f.intent.type（member 已有 faction_stakes → 不重覆）。
# intent_fit term 讀此把「意圖→子需求」reshape 戰術 option util（斷點：獨立隊 solo reshape 零）。
var intent: String = ""
var intent_target: int = -1
var intent_target_pos: Vector2i = Vector2i(-1, -1)
# 融合 threat（序1 溶入）：鏡射舊 _evaluate_threat 掃描（raw score over ALL discovered，
# 含 approach/power 非純 hostility；≠ ctx.threat 的 reputation-filtered _max_threat）。
# threat option（備戰/迎戰/求和）的 applicable gate + eval 讀此。
var threat_react: float = 0.0
var threat_id: int = -1
var threat_pos: Vector2i = Vector2i(-1, -1)
var threat_threshold: float = 0.0
var is_resident: bool = false
# 野心階梯（序3 rung_task 溶入）：archetype/rung 當 weight 驅動 option（非查表塞 task）。
# ambient_train_drive = FORCE-archetype 累積/擴張階練兵 base（低 magnitude 讓位緊急決策）。
var archetype: String = ""
var rung: int = 0
var has_trainable: bool = false
var ambient_train_drive: float = 0.0
# 計畫層 S2：中長期 phase（缺口×個性×隊形導出）→ option 承諾偏置。讀 S1 rung 不碰 rung。
const PHASE_NONE := ""
const PHASE_SEEK_FOOD := "求糧"   # 缺糧
const PHASE_GROW := "成長"        # 缺人
const PHASE_GATHER := "聚勢"      # 缺勢（結盟/整併/立國前置）
const PHASE_ESTABLISH := "立國"   # 立國傾向
const PLAN_PHASE_DRIVE_MAG: float = 0.4   # TEST VALUE — phase 偏置 magnitude（低，讓位 survival/緊急）
var plan_phase: String = ""
var plan_phase_drive_map: Dictionary = {}   # {option: mag} 當前 phase 對齊 option 加成
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

# 計畫層 S2：phase 導出 = 缺口偵測（低階缺口優先：糧>人>勢>立國）× 隊形（子隊無獨立計畫）。
# 讀 S1 rung/state，純機械+人格（複用 AmbitionLadder milestone 門檻），零新 scorer、零 randf。
static func derive_plan_phase(state: WorldState, team: TeamData) -> String:
	if team.parent_team_id != -1: return PHASE_NONE   # 子隊服母團
	if team.food_flow_avg < AmbitionLadder.ACCUMULATE_FLOW_MIN:
		return PHASE_SEEK_FOOD
	if team.population < AmbitionLadder.EXPAND_MIN_POP:
		return PHASE_GROW
	var ft: int = 0
	if team.faction_id != -1 and state.factions.has(team.faction_id):
		ft = state.factions[team.faction_id].member_team_ids.size()
	if ft < AmbitionLadder.STATE_MIN_FACTION_TEAMS:
		return PHASE_GATHER   # 缺勢→聚勢（結盟/整併/立國前置）
	return PHASE_ESTABLISH

# phase → 對齊 option 加成 map（option 實名對齊 REGISTRY；「併入」= S-A 統一 join+整併）。
static func _phase_option_bias(phase: String) -> Dictionary:
	match phase:
		# 貿易 移除（裁決 B）：貿易=致富 intent 主表達（intent_fit 致富→貿易 已驅）；
		# phase map 只含 phase 內在選項，排除他 intent 主表達 → 防個性分歧 collapse（TC7）+ 化解貿易雙偏置。
		PHASE_SEEK_FOOD: return {"覓食": PLAN_PHASE_DRIVE_MAG, "買糧": PLAN_PHASE_DRIVE_MAG}
		PHASE_GROW:      return {"返家補給": PLAN_PHASE_DRIVE_MAG, "紮營": PLAN_PHASE_DRIVE_MAG}
		PHASE_GATHER:    return {"外交": PLAN_PHASE_DRIVE_MAG, "併入": PLAN_PHASE_DRIVE_MAG}
	return {}

static func gather(state: WorldState, team: TeamData) -> DecisionContext:
	var c := DecisionContext.new()
	var _tg: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0
	var ldr: PersonData = state.persons.get(team.leader_id)
	c.leader_values = ldr.values.duplicate() if ldr != null else {}
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
	c.is_merchant = team.tags.has(TeamData.TAG_MERCHANT)
	c.has_home_outpost = FactionAISystem.new()._find_own_outpost(state, team) != Vector2i(-1, -1)
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
		if _ot != null: c.threat_pos = _ot.tile_pos
	c.is_resident = FactionAISystem.is_resident_static(state, team)
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.threat", _tg)
	var _fa := FactionAISystem.new()
	var _prey: int = _fa._find_weakest_prey(state, team)
	c.has_weak_prey = _prey != -1
	c.weak_prey_pos = state.teams[_prey].tile_pos if c.has_weak_prey else Vector2i(-1, -1)
	# capability grounding（裁2）：self 有效武裝比 → attack/loot「打得動嗎」世界事實。
	# 無牙商隊 armed≈0 → ratio≈0 → loot_drive/intent_fit capability_factor 壓平（送死沒人幹，非被禁）。
	c.self_armed_ratio = float(_fa._calc_own_armed(state, team)) / maxf(float(team.population), 1.0)
	# 佔村 target（可據 stationary 弱村；belief-driven weakness，可見性物理判可據）
	var _occ: int = _fa._find_occupy_target(state, team)
	c.has_occupy_target = _occ != -1
	c.occupy_target_id = _occ
	c.occupy_target_pos = state.teams[_occ].tile_pos if _occ != -1 else Vector2i(-1, -1)
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.weak_prey", _tg)
	# 名聲磁鐵 §3b：strong_neighbor 用 rep 軸選（投奔高 protector_rep 保護傘，喂-讀對齊）。
	var _sn: int = _fa._find_strong_neighbor(state, team, "rep")
	c.has_strong_neighbor = _sn != -1
	c.strong_neighbor_id = _sn
	c.strong_neighbor_pos = state.teams[_sn].tile_pos if _sn != -1 else Vector2i(-1, -1)
	c.best_protector_rep = team.get_protector_rep(_sn) if _sn != -1 else 0.5   # 選中 host rep 供 join_drive 磁鐵
	if Probe.enabled and _sn != -1 and absf(c.best_protector_rep - 0.5) > 0.01:
		Probe.bump("rep.host_nonneutral")   # DIAG：磁鐵有差別（strong_neighbor protector_rep 脫 0.5）
	var _ft: Vector2i = _fa._find_unowned_farmable_tile(state, team)
	c.has_farmable_tile = _ft != Vector2i(-1, -1)
	c.farmable_pos = _ft
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.strong_farm", _tg)
	var _aid: int = _fa._find_aid_target(state, team)
	c.has_aid_target = _aid != -1
	c.aid_target_id = _aid
	c.aid_target_pos = state.teams[_aid].tile_pos if _aid != -1 else Vector2i(-1, -1)
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.aid", _tg)
	# P3 混合協調：loyalty 注入 leader_values（weight("faction_duty") 讀，避擴 weight 簽名；
	# `_` 前綴非人格值，既有 term match 不誤讀，leader_values 已 duplicate 不污染 PersonData）。
	c.leader_loyalty = ldr.loyalty if ldr != null else 0.5
	c.leader_values["_loyalty"] = c.leader_loyalty
	# 買糧（Phase 1）：注入 _is_merchant（weight("buyfood") 讀，同 _loyalty 法）+ 最近市集 + 有錢。
	c.leader_values["_is_merchant"] = c.is_merchant
	var _mkt: Vector2i = _fa._nearest_market_outpost(state, team)
	c.has_food_market = _mkt != Vector2i(-1, -1)
	c.food_market_pos = _mkt
	c.food_market_dist = _fa._hex_dist(team.tile_pos, _mkt) if c.has_food_market else -1
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.market", _tg)
	# has_specie 廣義納可交易特產：coin / goods / material / ore（forest=木材 mountain=礦 換糧籌碼）。
	c.has_specie = float(team.resources.get("coin", 0)) > 0.0 \
		or float(team.resources.get("goods", 0)) >= 10.0 \
		or float(team.resources.get("material", 0)) >= DecisionTerms.MATERIAL_TRADE_MIN \
		or float(team.resources.get("ore_iron", 0)) + float(team.resources.get("ore_gold", 0)) >= DecisionTerms.MATERIAL_TRADE_MIN
	# home_food：自家糧倉 food（掃自有 outpost tile，team 不在家也讀得到 → 空家判定）。
	c.home_food = DecisionContext._home_granary_food(state, team)
	if SimRunner.phase_timing: _tg = FactionAISystem._fai_pht_s("gather.home_food", _tg)
	# 派系 stakes directive 集合（攻擊/徵收/外交；mirror P3 攻擊）。
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null:
			for g in STAKES_SET:
				if g in f.goals: c.faction_stakes.append(g)
			if "攻擊" in c.faction_stakes:
				var _at: int = _fa._nearest_independent(state, team)
				c.faction_attack_target = _at
				c.faction_attack_target_pos = state.teams[_at].tile_pos if _at != -1 else Vector2i(-1, -1)
			if "徵收" in c.faction_stakes:
				var _rt: int = _fa._richest_member(state, f)
				if _rt == team.team_id: _rt = -1   # 不對自己徵收（_richest_member 未排自身）
				c.faction_tribute_target = _rt
				c.faction_tribute_target_pos = state.teams[_rt].tile_pos if _rt != -1 else Vector2i(-1, -1)
			if "外交" in c.faction_stakes:
				var _dt: int = _fa._nearest_independent(state, team)
				c.faction_diplo_target = _dt
				c.faction_diplo_target_pos = state.teams[_dt].tile_pos if _dt != -1 else Vector2i(-1, -1)
	# team 自己戰略 intent（means-end 戰術層）：獨立=solo_intent / faction leader=f.intent。
	# member 已由 faction_stakes 供 tactical 訊號 → 不重覆注入（避雙寫同義）。
	if team.faction_id == -1:
		c.intent = FactionAISystem._solo_type(team)
	else:
		var fi = state.factions.get(team.faction_id)
		if fi != null and fi.leader_team_id == team.team_id and fi.intent is Dictionary:
			c.intent = String(fi.intent.get("type", ""))
			c.intent_target = int(fi.intent.get("target_id", -1))
	# 征服意圖 target 位（faction leader 帶 target_id；獨立 fallback weak_prey）→ intent_fit 攻擊路徑用。
	if c.intent == "征服":
		if c.intent_target != -1 and state.teams.has(c.intent_target):
			c.intent_target_pos = state.teams[c.intent_target].tile_pos
		elif c.has_weak_prey:
			c.intent_target = _prey
			c.intent_target_pos = c.weak_prey_pos
	# 野心階梯（序3 rung_task 溶入）：archetype/rung 成 weight context；FORCE 累積/擴張階 → 練兵 base。
	c.archetype = team.ambition_archetype
	c.rung = team.ambition_rung
	c.has_trainable = not team.anon_cohorts.is_empty()   # 有 anon 可練
	if c.archetype == AmbitionLadder.ARCHETYPE_FORCE \
			and team.ambition_rung in [AmbitionLadder.RUNG_ACCUMULATE, AmbitionLadder.RUNG_EXPAND]:
		c.ambient_train_drive = 0.5   # TEST VALUE — 低 magnitude 讓位緊急決策
	# 計畫層 S2：導出 phase + 偏置 map（讀 rung/state，純算術零 randf）；持久 team.plan_phase 供 GUI/hysteresis
	c.plan_phase = derive_plan_phase(state, team)
	team.plan_phase = c.plan_phase
	c.plan_phase_drive_map = _phase_option_bias(c.plan_phase)
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
			c.intent_target_pos = state.teams[c.prosperity_prey_id].tile_pos
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
		if _tgt != null:
			var _net: float = ResourceSystem.effective_food(state, _tgt) \
				- float(_tgt.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			var _land: float = YIELD_LAND_BONUS if ResourceSystem.own_granary_tile(state, _tgt) != null else 0.0
			c.absorb_yield = clampf(_net / YIELD_NORM + _land, -1.0, 1.0)
		# DIAG §HOW-8：吸納 utility 組件分布（證 decision-到位 vs formula-always-0）
		if Probe.enabled:
			Probe.bump("absorb.util_n")
			Probe.add_amount("absorb.slack_sum", c.resource_slack)
			Probe.add_amount("absorb.yield_sum", c.absorb_yield)
			if c.resource_slack > 0.05: Probe.bump("absorb.slack_pos")
			if c.absorb_yield > 0.0: Probe.bump("absorb.yield_pos")
	# 需求金字塔（決策引擎重構 S1）：五層急迫度 EWMA 更新（inert——本 slice 不接 rank_scored）。
	# compute_raw 讀 food_days/threat(已算) + team/state；ewma_update 累積進持久 team.need_urgency。
	var _raw_need: PackedFloat32Array = NeedHierarchy.compute_raw(state, team, c.food_days, c.threat)
	team.need_urgency = NeedHierarchy.ewma_update(team.need_urgency, _raw_need)
	c.need_urgency = team.need_urgency
	# §6 主敘事標籤：team.plan_phase 來源改接五層急迫度衍生(argmax)，非 derive_plan_phase 自算。
	# GUI(observer_query_api/observer_inspect_panel)讀 team.plan_phase 不變，來源改接。
	team.plan_phase = NeedHierarchy.narrative_label(team.need_urgency)
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

# 自家糧倉 food：掃自有 outpost tile（owner==team_id）取 public_storage food。
# own_granary_tile 只在 team 站在自家據點時回傳；返家補給 gate 須在「離家」時也讀得到家糧 →
# 仿 _find_own_outpost 掃法（不限本格），無自家 outpost → 0。
static func _home_granary_food(state: WorldState, team: TeamData) -> float:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
			return float(tile.public_storage.get("food", 0))
	return 0.0
