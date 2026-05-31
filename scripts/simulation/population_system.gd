class_name PopulationSystem

const OVERFLOW_CHECK_INTERVAL: int = WorldState.TICKS_PER_DAY   # 每天檢查

func check_overflow(state: WorldState) -> void:
	for tid in state.teams.keys():
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var leader = state.persons.get(team.leader_id)
		var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
		var cap: int = TeamData.pop_cap_from_leadership(cmd)
		var overflow: int = team.population - cap
		if overflow <= 0:
			continue
		var spare_id: int = -1
		for nid in team.named_members:
			if nid != team.leader_id:
				spare_id = nid
				break
		if spare_id != -1:
			SubteamSystem.new().dispatch(state, tid, spare_id, overflow, "idle", team.tile_pos)
			print("[PopMgmt] Team%d 超額 %d 人，advisor Team%d 帶走" % [tid, overflow, spare_id])
		else:
			_create_overflow_team(state, team, overflow)

func _create_overflow_team(state: WorldState, origin: TeamData, overflow_pop: int) -> void:
	var ot := TeamData.new()
	ot.team_id      = _next_team_id(state)
	ot.tile_pos     = origin.tile_pos
	ot.faction_id   = -1
	ot.tags         = ["流亡"]
	ot.population   = overflow_pop
	ot.current_task = TeamData.TASK_IDLE
	var frac: float = float(overflow_pop) / float(origin.population)
	for res in origin.resources:
		var amt: float = float(origin.resources.get(res, 0)) * frac
		ot.resources[res]     = amt
		origin.resources[res] = float(origin.resources.get(res, 0)) - amt
	origin.population -= overflow_pop
	state.teams[ot.team_id]           = ot
	state.team_known[ot.team_id]      = []
	state.team_discovered[ot.team_id] = []
	var gen := PersonGenerator.new()
	var promoted := gen.generate_from_team(ot, state)
	if promoted != null:
		ot.leader_id  = promoted.id
		promoted.role = "leader"
	print("[PopMgmt] Team%d 超額 %d 人無 advisor，獨立流亡 Team%d" % [
		origin.team_id, overflow_pop, ot.team_id])

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
