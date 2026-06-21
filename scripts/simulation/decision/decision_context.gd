class_name DecisionContext

# 統一決策引擎：一隊一次蒐集的唯讀快照。
# term 函式從這裡讀驅力輸入；leader 人格 values 是 w_term 權重來源。
# 簽名對齊真實 code：effective_food/own_granary_tile（static, ResourceSystem）、
# best_arbitrage_order/team_strength（instance）、RelationGraph.strongest（讀 leader.relation_edges）。

var leader_values: Dictionary = {}
var food_days: float = 0.0
var has_goods: bool = false
var has_arb: bool = false
var team_strength: float = 0.0
var threat: float = 0.0
var ambition_gap: int = 0
var strongest_feud: float = 0.0
var has_own_outpost: bool = false

static func gather(state: WorldState, team: TeamData) -> DecisionContext:
	var c := DecisionContext.new()
	var ldr: PersonData = state.persons.get(team.leader_id)
	c.leader_values = ldr.values.duplicate() if ldr != null else {}
	var ef: float = ResourceSystem.effective_food(state, team)
	c.food_days = ef / maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
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
	# threat：商隊切片威脅 term 次要，初版 0；他域遷入時補（_find_strong_neighbor / 鄰敵 strength）。
	c.threat = 0.0
	return c
