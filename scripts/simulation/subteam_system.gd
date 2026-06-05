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
	if not parent.named_members.has(sub_leader_id):
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

	parent.named_members.erase(sub_leader_id)
	sub_leader.team_id = sub.team_id
	for aid in extra_advisor_ids:
		if aid == sub_leader_id:
			continue
		if not parent.named_members.has(aid):
			continue
		var advisor = state.persons.get(aid)
		if advisor == null:
			continue
		parent.named_members.erase(aid)
		advisor.team_id = sub.team_id
		sub.named_members.append(aid)
	parent.population -= pop_count
	parent.subteam_ids.append(sub.team_id)
	state.teams[sub.team_id]          = sub
	state.team_known[sub.team_id]     = []
	state.team_discovered[sub.team_id] = []
	print("[Sub] Team%d 派出子隊 Team%d leader=P%d advisors=%s (pop=%d cap=%d task=%s)" % [
		parent_id, sub.team_id, sub_leader_id, str(sub.named_members), pop_count, sub_cap, task])
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

func merge_teams(state: WorldState, absorber_id: int, absorbed_id: int,
		transfer_npc_ids: Array = [], transfer_anon: int = -1) -> void:
	if transfer_npc_ids.is_empty() and transfer_anon == -1:
		_merge_into(state, absorber_id, absorbed_id)
		return
	var absorber: TeamData = state.teams.get(absorber_id)
	var absorbed: TeamData = state.teams.get(absorbed_id)
	if absorber == null or absorbed == null or absorbed.population <= 0:
		return
	var absorber_leader = state.persons.get(absorber.leader_id)
	var absorber_cmd: float = float(absorber_leader.skills.get("統領", 0.0)) if absorber_leader else 0.0
	var absorber_cap: int = TeamData.pop_cap_from_leadership(absorber_cmd)
	var capacity: int = absorber_cap - absorber.population
	if capacity <= 0:
		print("[Merge] Team%d 容量已滿，無法合併 Team%d" % [absorber_id, absorbed_id])
		return
	var named_cap: int = mini(transfer_npc_ids.size(), capacity)
	var actual_npcs: Array = transfer_npc_ids.slice(0, named_cap)
	# 計算匿民轉移數量
	var named_in_absorbed: int = (1 if absorbed.leader_id != -1 else 0) \
		+ absorbed.named_members.size()
	var anon_pop: int = maxi(absorbed.population - named_in_absorbed, 0)
	var anon_xfer: int
	if transfer_anon == -1:
		if named_in_absorbed > 0:
			anon_xfer = int(round(float(anon_pop) * float(actual_npcs.size()) / float(named_in_absorbed)))
		else:
			anon_xfer = anon_pop
	elif transfer_anon == 0:
		anon_xfer = 0
	else:
		anon_xfer = mini(transfer_anon, anon_pop)
	anon_xfer = mini(anon_xfer, maxi(capacity - actual_npcs.size(), 0))
	anon_xfer = maxi(anon_xfer, 0)
	var total_xfer: int = actual_npcs.size() + anon_xfer
	var frac: float = float(total_xfer) / float(absorbed.population) if absorbed.population > 0 else 0.0
	var absorbed_leader_moved: bool = false
	for pid in actual_npcs:
		var p: PersonData = state.persons.get(pid)
		if p == null or p.team_id != absorbed_id:
			continue
		p.team_id = absorber_id
		if pid == absorbed.leader_id:
			absorbed_leader_moved = true
			absorbed.leader_id = -1
			if not absorber.named_members.has(pid):
				absorber.named_members.append(pid)
		else:
			absorbed.named_members.erase(pid)
			if not absorber.named_members.has(pid):
				absorber.named_members.append(pid)
	absorber.population += total_xfer
	absorbed.population -= total_xfer
	absorber.wounded += int(round(float(absorbed.wounded) * frac))
	absorbed.wounded = maxi(absorbed.wounded - int(round(float(absorbed.wounded) * frac)), 0)
	for res in absorbed.resources:
		var amt: float = float(absorbed.resources.get(res, 0)) * frac
		absorber.resources[res] = float(absorber.resources.get(res, 0)) + amt
		absorbed.resources[res] = float(absorbed.resources.get(res, 0)) - amt
	if absorbed_leader_moved and absorbed.population > 0:
		var es := EventSystem.new()
		es.on_leader_death(state, absorbed)
	if absorbed.population <= 0:
		absorber.subteam_ids.erase(absorbed_id)
		state.teams.erase(absorbed_id)
		state.team_known.erase(absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (absorber_pop=%d)" % [
			absorber_id, absorbed_id, absorber.population])
	else:
		absorbed.parent_team_id = absorber_id
		absorbed.current_task = TeamData.TASK_IDLE
		if not absorbed.tags.has("子團"):
			absorbed.tags.append("子團")
		if not absorber.subteam_ids.has(absorbed_id):
			absorber.subteam_ids.append(absorbed_id)
		print("[Merge] Team%d ← Team%d 部分合併 (absorber=%d absorbed=%d)" % [
			absorber_id, absorbed_id, absorber.population, absorbed.population])

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
			if not absorber.named_members.has(absorbed.leader_id):
				absorber.named_members.append(absorbed.leader_id)
	# 歸還 sub.named_members
	if absorbed.parent_team_id == absorber_id:
		for aid in absorbed.named_members:
			var advisor = state.persons.get(aid)
			if advisor != null:
				advisor.team_id = absorber_id
				if not absorber.named_members.has(aid):
					absorber.named_members.append(aid)
		absorbed.named_members.clear()

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
		# Faction cleanup before erasing
		if absorbed.faction_id != -1:
			var f_merge: FactionData = state.factions.get(absorbed.faction_id)
			if f_merge != null:
				f_merge.member_team_ids.erase(absorbed_id)
				f_merge.known_member_states.erase(absorbed_id)
		state.teams.erase(absorbed_id)
		state.team_known.erase(absorbed_id)
		state.team_discovered.erase(absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (pop=%d)" % [absorber_id, absorbed_id, absorber.population])
	else:
		print("[Merge] Team%d ← Team%d 部分合併 (absorber=%d absorbed=%d)" % [
			absorber_id, absorbed_id, absorber.population, absorbed.population])

func _pick_subteam_leader(state: WorldState, team: TeamData, task: String) -> int:
	var skill_map: Dictionary = {
		"攻擊": "統領", "掠奪": "統領", "貿易": "商業",
		"外交": "交涉", "生產": "生產", "製造": "製造", "偵查": "偵查"
	}
	var skill: String = skill_map.get(task, "統領")
	var best_id: int = -1
	var best_val: float = -1.0
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var v: float = float(p.skills.get(skill, 0.0))
		if v > best_val:
			best_val = v; best_id = pid
	return best_id

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
