extends "res://scripts/simulation/events/base_event.gd"

const DEFECT_UNREST_THRESHOLD: int   = 20
const DEFECT_HONOR_THRESHOLD: float  = 0.35

func check(state: WorldState, team: TeamData) -> bool:
	if team.faction_id == -1:
		return false
	if team.unrest_turns < DEFECT_UNREST_THRESHOLD:
		return false
	var leader = state.persons.get(team.leader_id)
	if leader == null:
		return false
	# ★cohesion：honor/trust 死 cliff → 連續 defect_util（distress 真 × 忠誠虧缺 連續 − stay_benefit 真好處）。
	#   保 unrest>=20 precondition（genuine distress gate、measurer 證、不動）；honor 0.35 cliff→distressed 中連續 weigh。
	var honor: float = float(leader.values.get("義氣",  0.5))
	var trust: float = float(leader.values.get("信義", 0.5))
	# distress_pressure：過 gate 後隨 unrest 連續↑（[0,1]、norm=threshold=剛過門 ~0.x、久壓→1）
	var distress_pressure: float = clampf(float(team.unrest_turns - DEFECT_UNREST_THRESHOLD) / float(DEFECT_UNREST_THRESHOLD), 0.0, 1.0) * 0.5 + 0.5
	# loyalty_deficit：honor/trust 低→虧缺高（取兩者較低者、[0,1] 連續、非 0.35 硬 bool）
	var loyalty_deficit: float = clampf((1.0 - minf(honor, trust)) , 0.0, 1.0)
	var stay_benefit: float = FactionAISystem.new()._faction_stay_benefit(state, team)
	var defect_util: float = distress_pressure * loyalty_deficit - stay_benefit
	if Probe.enabled and defect_util > 0.0: Probe.bump("cohesion.defect_fire")
	return defect_util > 0.0   # 真餓+忠誠虧缺 > 留下真好處 → 走（好領主/被救過 stay_benefit 高→忍）

func execute(state: WorldState, team: TeamData) -> Array:
	var fid: int = team.faction_id
	if not state.factions.has(fid):
		state.clear_team_faction(team)   # S11：faction 已不存在防禦路徑，走 chokepoint（語意等同 =-1，無懸空可修）
		return []
	var f = state.factions[fid]
	state.clear_team_faction(team)   # 脫離 faction（雙向同步）
	if f.member_team_ids.size() <= 1:
		state.disband_faction(fid)
	SimMessageSystem.new().emit_message(state, "faction_defect",
		"Team%d 脫離勢力%d" % [team.team_id, fid], team,
		{ "origin": str(team.team_id) })
	print("[Faction] Team%d 脫離勢力%d" % [team.team_id, fid])
	return []
