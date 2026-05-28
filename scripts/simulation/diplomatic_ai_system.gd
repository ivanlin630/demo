# scripts/simulation/diplomatic_ai_system.gd
class_name DiplomaticAiSystem

const BETRAY_CHECK_INTERVAL: int = 50   # TEST VALUE

func _calc_diplomacy_score(state: WorldState,
		self_team: TeamData, other_team: TeamData) -> float:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return 0.0

	var food_ratio: float = float(self_team.resources.get("food", 0)) / \
		maxf(self_team.population * 5.0, 1.0)
	var resource_need: float = clampf(1.0 - food_ratio, 0.0, 1.0)

	var power_gap: float = clampf(
		float(other_team.population - self_team.population) / \
		maxf(self_team.population, 1.0), -1.0, 1.0)

	var rep: float = float(self_team.known_reputations.get(other_team.team_id, 0.5))

	var other_leader_id: int = other_team.leader_id
	var relation: float = float(self_leader.relations.get(other_leader_id, 0.0))

	var self_peace: float = self_leader.values.get("義氣", 0.5) * \
		self_leader.values.get("信義", 0.5)

	return clampf(
		resource_need * 0.3 +
		power_gap     * 0.2 +
		rep           * 0.2 +
		relation      * 0.15 +
		self_peace    * 0.15,
		0.0, 1.0)

func try_proactive_diplomacy(state: WorldState, self_team: TeamData) -> void:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return
	if randf() > self_leader.values.get("慎重", 0.5) * 0.5 + 0.2: return

	for other_id in state.team_discovered.get(self_team.team_id, []):
		var other: TeamData = state.teams.get(other_id)
		if other == null: continue
		if other.faction_id == self_team.faction_id and self_team.faction_id != -1: continue
		var score: float = _calc_diplomacy_score(state, self_team, other)

		if score > 0.6 and self_team.faction_id != -1:
			_send_diplomacy_message(state, self_team, other, "propose_alliance")
			return
		elif score > 0.4:
			_send_diplomacy_message(state, self_team, other, "propose_trade")
			return

		var power_gap: float = float(other.population - self_team.population) / \
			maxf(self_team.population, 1.0)
		if power_gap > 0.5 and self_leader.values.get("貪婪", 0.5) > 0.6:
			_send_diplomacy_message(state, self_team, other, "demand_tribute")
			return

func _send_diplomacy_message(state: WorldState, sender: TeamData,
		target: TeamData, action: String) -> void:
	print("[Diplomacy] Team%d → Team%d: %s" % [sender.team_id, target.team_id, action])
	# 透過 MessageSystem 發送（簡化：直接呼叫 handle）
	var response: String = call("handle_diplomacy_message", state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
