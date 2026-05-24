class_name SubteamSystem

func dispatch(state: WorldState, parent_id: int, sub_leader_id: int,
		pop_count: int, task: String, move_target: Vector2i,
		order_target_id: int = -1, order_task: String = "",
		extra_advisor_ids: Array = []) -> int:
	var parent: TeamData = state.teams.get(parent_id)
	if parent == null:
		return -1
	var sub_leader = state.persons.get(sub_leader_id)
	if sub_leader == null:
		return -1
	if not (parent.advisors.has(sub_leader_id) or parent.members.has(sub_leader_id)):
		return -1
	var cmd: float   = float(sub_leader.skills.get("統領", 0.0))
	var sub_cap: int = TeamData.pop_cap_from_leadership(cmd)
	pop_count = mini(pop_count, sub_cap)
	if parent.population - pop_count < 1:
		pop_count = parent.population - 1
	if pop_count <= 0 and extra_advisor_ids.is_empty():
		return -1
	pop_count = maxi(pop_count, 0)

	var sub := TeamData.new()
	sub.team_id          = _next_team_id(state)
	sub.tile_pos         = parent.tile_pos
	sub.faction_id       = parent.faction_id
	sub.parent_team_id   = parent_id
	sub.current_task     = task
	sub.move_target      = move_target
	sub.order_target_id  = order_target_id
	sub.order_task       = order_task
	sub.leader_id        = sub_leader_id
	sub.population       = pop_count
	sub.readiness        = parent.readiness
	sub.tags             = ["子團"]

	var frac: float = float(pop_count) / float(parent.population)
	for res in parent.resources:
		var amt: float = float(parent.resources[res]) * frac
		sub.resources[res]    = amt
		parent.resources[res] = float(parent.resources.get(res, 0)) - amt

	parent.advisors.erase(sub_leader_id)
	parent.members.erase(sub_leader_id)
	sub_leader.team_id = sub.team_id
	for aid in extra_advisor_ids:
		if aid == sub_leader_id:
			continue
		if not (parent.advisors.has(aid) or parent.members.has(aid)):
			continue
		var advisor = state.persons.get(aid)
		if advisor == null:
			continue
		parent.advisors.erase(aid)
		parent.members.erase(aid)
		advisor.team_id = sub.team_id
		sub.advisors.append(aid)
	parent.population -= pop_count
	parent.subteam_ids.append(sub.team_id)
	state.teams[sub.team_id]      = sub
	state.team_known[sub.team_id] = []
	print("[Sub] Team%d 派出子隊 Team%d leader=P%d advisors=%s (pop=%d cap=%d task=%s)" % [
		parent_id, sub.team_id, sub_leader_id, str(sub.advisors), pop_count, sub_cap, task])
	return sub.team_id

func try_merge_back(state: WorldState, sub_id: int) -> bool:
	var sub: TeamData = state.teams.get(sub_id)
	if sub == null or sub.parent_team_id == -1:
		return false
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null or parent.tile_pos != sub.tile_pos:
		return false
	_merge_into(state, sub.parent_team_id, sub_id)
	return true

func merge_teams(state: WorldState, absorber_id: int, absorbed_id: int) -> void:
	_merge_into(state, absorber_id, absorbed_id)

func _merge_into(state: WorldState, absorber_id: int, absorbed_id: int) -> void:
	var absorber: TeamData = state.teams[absorber_id]
	var absorbed: TeamData = state.teams[absorbed_id]
	var absorber_leader = state.persons.get(absorber.leader_id)
	var absorber_cmd: float = float(absorber_leader.skills.get("統領", 0.0)) if absorber_leader else 0.0
	var absorber_cap: int   = TeamData.pop_cap_from_leadership(absorber_cmd)
	var capacity: int       = absorber_cap - absorber.population

	# 子隊回歸但母團已滿 → 獨立分團，不重試
	if capacity <= 0 and absorbed.parent_team_id == absorber_id:
		absorbed.parent_team_id = -1
		absorbed.tags.erase("子團")
		absorber.subteam_ids.erase(absorbed_id)
		print("[Split] Team%d 回歸失敗（母團滿員），獨立為新分團" % absorbed_id)
		return

	# 子隊回歸：歸還 sub_leader 給 parent
	if absorbed.parent_team_id == absorber_id and absorbed.leader_id != -1:
		var sub_leader = state.persons.get(absorbed.leader_id)
		if sub_leader != null:
			sub_leader.team_id = absorber_id
			if not absorber.advisors.has(absorbed.leader_id):
				absorber.advisors.append(absorbed.leader_id)
	# 歸還 sub.advisors
	if absorbed.parent_team_id == absorber_id:
		for aid in absorbed.advisors:
			var advisor = state.persons.get(aid)
			if advisor != null:
				advisor.team_id = absorber_id
				if not absorber.advisors.has(aid):
					absorber.advisors.append(aid)
		absorbed.advisors.clear()

	var transfer: int = mini(absorbed.population, capacity)
	var frac: float   = float(transfer) / float(absorbed.population) if absorbed.population > 0 else 0.0
	absorber.population += transfer
	absorber.wounded    += int(round(float(absorbed.wounded) * frac))
	for res in absorbed.resources:
		var amt: float = float(absorbed.resources.get(res, 0)) * frac
		absorber.resources[res] = float(absorber.resources.get(res, 0)) + amt
		absorbed.resources[res] = float(absorbed.resources.get(res, 0)) - amt
	absorbed.population -= transfer
	absorbed.wounded     = maxi(absorbed.wounded - int(round(float(absorbed.wounded) * frac)), 0)
	absorber.subteam_ids.erase(absorbed_id)
	if absorbed.population <= 0:
		state.teams.erase(absorbed_id)
		state.team_known.erase(absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (pop=%d)" % [absorber_id, absorbed_id, absorber.population])
	else:
		print("[Merge] Team%d ← Team%d 部分合併 (absorber=%d absorbed=%d)" % [
			absorber_id, absorbed_id, absorber.population, absorbed.population])

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
