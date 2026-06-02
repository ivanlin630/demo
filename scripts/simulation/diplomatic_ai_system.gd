# scripts/simulation/diplomatic_ai_system.gd
class_name DiplomaticAiSystem

const BETRAY_CHECK_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時

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
	var response: String = handle_diplomacy_message(state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])

func handle_diplomacy_message(state: WorldState, self_team: TeamData,
		sender_team: TeamData, action: String) -> String:
	var score: float = _calc_diplomacy_score(state, self_team, sender_team)
	match action:
		"propose_alliance":
			if score > 0.55:
				_form_alliance(state, self_team, sender_team)
				return "accept"
			return "reject"
		"propose_trade":
			if score > 0.4:
				_update_reputation(self_team, sender_team.team_id, 0.05)
				_update_reputation(sender_team, self_team.team_id, 0.05)
				return "accept"
			return "reject"
		"demand_tribute":
			var leader: PersonData = state.persons.get(self_team.leader_id) if self_team.leader_id != -1 else null
			var pride:   float = float(leader.values.get("義氣", 0.5)) if leader else 0.5
			var caution: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
			var power_r: float = float(sender_team.population) / maxf(float(self_team.population), 1.0)
			# 接受分：強弱差大 + 謹慎 → 傾向接受；義氣高 → 傾向拒絕
			var d_score: float = (power_r - 1.0) * 0.4 + caution * 0.3 - pride * 0.3
			print("[DiplomacyAI] demand_tribute score=%.2f (power_r=%.2f, caution=%.2f, pride=%.2f)" % [d_score, power_r, caution, pride])
			return "accept" if d_score > 0.0 else "refuse"
		"offer_surrender":
			if score > 0.3:
				return "accept"
			return "reject"
	return "reject"

func _form_alliance(state: WorldState,
		team_a: TeamData, team_b: TeamData) -> void:
	if team_a.faction_id != -1:
		team_b.faction_id = team_a.faction_id
		var f: FactionData = state.factions.get(team_a.faction_id)
		if f and not f.member_team_ids.has(team_b.team_id):
			f.member_team_ids.append(team_b.team_id)
		state.snapshot_faction_member(team_b.team_id, state.world.current_tick)
	elif team_b.faction_id != -1:
		team_a.faction_id = team_b.faction_id
		var f: FactionData = state.factions.get(team_b.faction_id)
		if f and not f.member_team_ids.has(team_a.team_id):
			f.member_team_ids.append(team_a.team_id)
		state.snapshot_faction_member(team_a.team_id, state.world.current_tick)
	_update_reputation(team_a, team_b.team_id, 0.2)
	_update_reputation(team_b, team_a.team_id, 0.2)
	print("[Diplomacy] Team%d 與 Team%d 結盟" % [team_a.team_id, team_b.team_id])

func _update_reputation(team: TeamData, other_id: int, delta: float) -> void:
	var cur: float = float(team.known_reputations.get(other_id, 0.5))
	team.known_reputations[other_id] = clampf(cur + delta, 0.0, 1.0)

func consider_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> bool:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return false
	var betrayal_score: float = \
		self_leader.values.get("野心", 0.5) * 0.4 + \
		(1.0 - self_leader.values.get("信義", 0.5)) * 0.4 + \
		(1.0 - self_leader.values.get("義氣", 0.5)) * 0.2
	var power_gap: float = float(ally_team.population - self_team.population) / \
		maxf(self_team.population, 1.0)
	if power_gap > 0.5: betrayal_score -= 0.3
	if betrayal_score > 0.65 and randf() < 0.1:
		_execute_betrayal(state, self_team, ally_team)
		return true
	return false

func _execute_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> void:
	self_team.faction_id = -1
	_update_reputation(ally_team, self_team.team_id, -0.5)
	var ally_leader: PersonData = state.persons.get(ally_team.leader_id)
	if ally_leader:
		ally_leader.memory.append({
			"type": "betrayal", "subject_id": self_team.leader_id,
			"tick": state.world.current_tick, "intensity": 0.8
		})
	print("[Diplomacy] Team%d 背叛 Team%d" % [self_team.team_id, ally_team.team_id])
