extends BaseEvent

func check(state: WorldState, team: TeamData) -> bool:
	return _should_gain_military(state, team) \
		or _should_gain_exile(team) \
		or _should_lose_exile(team)

func execute(state: WorldState, team: TeamData) -> Array:
	if _should_gain_military(state, team) and not team.tags.has("軍隊"):
		team.tags.append("軍隊")
		team.tags.erase("生產")
		print("[Tag] Team%d +軍隊 -生產" % team.team_id)
	if _should_gain_exile(team) and not team.tags.has("流亡"):
		team.tags.append("流亡")
		team.tags.erase("軍隊")
		print("[Tag] Team%d +流亡 -軍隊" % team.team_id)
	if _should_lose_exile(team):
		team.tags.erase("流亡")
		print("[Tag] Team%d -流亡（恢復）" % team.team_id)
	return []

func _should_gain_military(state: WorldState, team: TeamData) -> bool:
	if team.tags.has("軍隊"): return false
	# 子隊（建造/安頓/升級）不得切換軍隊 tag：會破壞生產身份 + 解鎖不應有的攻擊路徑。
	if team.tags.has(TeamData.TAG_SUBTEAM): return false
	var lp = state.persons.get(team.leader_id)
	if lp == null: return false
	return float(lp.values.get("好戰", 0.5)) > 0.7 \
		and float(lp.values.get("野心", 0.5)) > 0.6

func _should_gain_exile(team: TeamData) -> bool:
	if team.tags.has("流亡"): return false
	return team.population > 0 \
		and float(team.wounded) / float(team.population) > 0.5

func _should_lose_exile(team: TeamData) -> bool:
	if not team.tags.has("流亡"): return false
	var food_pc: float = float(team.resources.get("food", 0)) / maxf(team.population, 1)
	return food_pc > 5.0 and team.wounded == 0 and team.unrest_turns < 5
