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
var ambition_gap: int = 0
var strongest_feud: float = 0.0
var has_own_outpost: bool = false
var is_merchant: bool = false
var has_home_outpost: bool = false
var has_weak_prey: bool = false
var weak_prey_pos: Vector2i = Vector2i(-1, -1)
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

static func gather(state: WorldState, team: TeamData) -> DecisionContext:
	var c := DecisionContext.new()
	var ldr: PersonData = state.persons.get(team.leader_id)
	c.leader_values = ldr.values.duplicate() if ldr != null else {}
	var ef: float = ResourceSystem.effective_food(state, team)
	c.food_days = ef / maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	c.population = team.population
	c.has_goods = float(team.resources.get("goods", 0)) >= 10.0
	c.has_arb = not OrderSystem.new().best_arbitrage_order(state, team).is_empty()
	c.team_strength = NpcCombatSystem.new().team_strength(state, team.team_id)
	c.ambition_gap = maxi(team.ambition_cap - team.ambition_rung, 0)
	# feud 邊掛 leader person（relation_edges 屬 PersonData，非 TeamData）。
	var fe: Dictionary = {}
	if ldr != null:
		fe = RelationGraph.strongest(ldr.relation_edges, "feud")
	c.strongest_feud = float(fe.get("intensity", 0.0)) if not fe.is_empty() else 0.0
	c.has_own_outpost = ResourceSystem.own_granary_tile(state, team) != null
	c.is_merchant = team.tags.has(TeamData.TAG_MERCHANT)
	c.has_home_outpost = FactionAISystem.new()._find_own_outpost(state, team) != Vector2i(-1, -1)
	# threat（F-D6 un-stub）：視野內最高敵威脅（belief-based ThreatAssessment，含逼近/敵意/距離衰減）。
	# 餵 threat_pressure term → unified 隊(商隊/生產)遇逼近敵會 FLEE（威脅真驅動非死 stub）。
	c.threat = DecisionContext._max_threat(state, team)
	var _fa := FactionAISystem.new()
	var _prey: int = _fa._find_weakest_prey(state, team)
	c.has_weak_prey = _prey != -1
	c.weak_prey_pos = state.teams[_prey].tile_pos if c.has_weak_prey else Vector2i(-1, -1)
	# P2a 絕境目標欄（複用 finder，仿 _find_weakest_prey 風格）
	var _sn: int = _fa._find_strong_neighbor(state, team)
	c.has_strong_neighbor = _sn != -1
	c.strong_neighbor_id = _sn
	c.strong_neighbor_pos = state.teams[_sn].tile_pos if _sn != -1 else Vector2i(-1, -1)
	var _ft: Vector2i = _fa._find_unowned_farmable_tile(state, team)
	c.has_farmable_tile = _ft != Vector2i(-1, -1)
	c.farmable_pos = _ft
	var _aid: int = _fa._find_aid_target(state, team)
	c.has_aid_target = _aid != -1
	c.aid_target_id = _aid
	c.aid_target_pos = state.teams[_aid].tile_pos if _aid != -1 else Vector2i(-1, -1)
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
	# has_specie 廣義納可交易特產：coin / goods / material / ore（forest=木材 mountain=礦 換糧籌碼）。
	c.has_specie = float(team.resources.get("coin", 0)) > 0.0 \
		or float(team.resources.get("goods", 0)) >= 10.0 \
		or float(team.resources.get("material", 0)) >= DecisionTerms.MATERIAL_TRADE_MIN \
		or float(team.resources.get("ore_iron", 0)) + float(team.resources.get("ore_gold", 0)) >= DecisionTerms.MATERIAL_TRADE_MIN
	# home_food：自家糧倉 food（掃自有 outpost tile，team 不在家也讀得到 → 空家判定）。
	c.home_food = DecisionContext._home_granary_food(state, team)
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
