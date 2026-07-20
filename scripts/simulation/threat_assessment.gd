class_name ThreatAssessment

# 威脅評估（static 純函數）：限視野 + reputation + intel 估算實力 + 朝我移動 + 距離衰減。
# 認知不等於真實：對方實力用觀察者 team_intel snapshot 估算，非全知。

const THREAT_BASE_THRESHOLD: float = 0.3
const REPUTATION_NEUTRAL: float = 0.5
const POWER_BASELINE: float = 1.0

static func score(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	if not state.team_discovered.get(self_team.team_id, []).has(other.team_id):
		return 0.0
	var approach: float = _approach_score(state, self_team, other)
	var rep: float = float(self_team.known_reputations.get(other.team_id,
		REPUTATION_NEUTRAL))
	var hostility: float = clampf(1.0 - rep, 0.0, 1.0)
	var power_ratio: float = _power_ratio(state, self_team, other)
	var raw: float = approach * 1.0 + hostility * 1.0 + (power_ratio - 1.0) * 0.5
	# ★Slice D fold（dist_factor 乘算主導 god-view）：dist 走 belief（position）——本 tick 可見→live 距、
	# 斷視線→belief last-seen 位算距、positionless/過期→dist_factor=0（威脅位置未知=無法算 proximity 威脅→不
	# proximate-threat；合 null-belief-flee「威脅無座標→不 flee」+ 既有「dist≥5 逃出生天→0」）。∴ 威脅評估全 belief。
	var other_pos: Vector2i = other.tile_pos
	if int(BeliefSystem.best_estimate(state, self_team.team_id, other.team_id).get("last_tick", -1)) != state.world.current_tick:
		other_pos = BeliefSystem.belief_pos(state, self_team.team_id, other.team_id)
		if other_pos == Vector2i(-1, -1):
			return 0.0   # positionless 威脅 → dist_factor 0 → 威脅分 0
	var dist: int = _hex_dist(self_team.tile_pos, other_pos)
	# 距離脫離：dist≥5 → factor 0（逃出生天）。原 floor 0.1 → 遠敵永遠算威脅 → 逃跑永不釋放
	var dist_factor: float = clampf(1.0 - float(dist) / 5.0, 0.0, 1.0)
	return maxf(raw * dist_factor, 0.0)

static func _approach_score(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	var obs: Dictionary = PathSystem.observe_velocity(state, self_team, other)
	if not obs.get("visible", false): return 0.0
	var dir: Vector2i = obs.get("direction", Vector2i.ZERO)
	if dir == Vector2i.ZERO: return 0.0
	var current_dist: int = _hex_dist(self_team.tile_pos, other.tile_pos)
	var future_pos: Vector2i = other.tile_pos + dir
	var future_dist: int = _hex_dist(self_team.tile_pos, future_pos)
	if current_dist == future_dist: return 0.0
	return clampf(float(current_dist - future_dist), -1.0, 1.0)

static func _power_ratio(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	var self_power: float = _team_power(self_team)
	# 對方用 team_intel snapshot（NPC 不全知）
	var intel: Dictionary = BeliefSystem.best_estimate(state, self_team.team_id, other.team_id)
	# ★god-view fix（invariants.md:171-173）：無 belief fallback 用 self_pop（視對方等強），禁讀 other.population
	# （真值=god-view，破虛張/偽裝）。鏡射 diplomatic _get_pop_est fallback=self_pop 模式。
	var pop_est: int = int(intel.get("population_est", self_team.population))
	# 無 combat skill in intel → 用 0.3 baseline 估算
	var other_power: float = float(pop_est) * 0.3
	return other_power / maxf(self_power, 0.1)

static func _team_power(team: TeamData) -> float:
	var combat: float = AnonTierSystem.avg_combat_skill(team)
	return float(team.population) * combat

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x; var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
