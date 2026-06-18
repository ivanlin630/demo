class_name EventSystem

var _events: Array = []

func _init() -> void:
	# 分裂優先於替換（分裂後 unrest_turns 歸零，替換事件不再觸發）
	_events.append(load("res://scripts/simulation/events/event_unrest_split.gd").new())
	_events.append(load("res://scripts/simulation/events/event_unrest_replace.gd").new())
	_events.append(load("res://scripts/simulation/events/event_faction_defect.gd").new())
	_events.append(load("res://scripts/simulation/events/event_tag_shift.gd").new())

func process_events(state: WorldState, team_ids: Array) -> Array:
	var new_teams: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		for event in _events:
			if event.check(state, team):
				new_teams.append_array(event.execute(state, team))
	return new_teams

# 由外部呼叫（Leader 死亡/失效後繼承）。繼承邏輯單一 owner。
func on_leader_death(state: WorldState, team: TeamData) -> bool:
	# TODO(Task3): player team → _handle_player_succession
	# NPC: best named 無門檻晉升
	var best_successor: PersonData = null
	var best_command: float = -1.0
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var cmd: float = float(p.skills.get("統領", 0.0))
		if cmd > best_command:
			best_command = cmd
			best_successor = p
	if best_successor != null:
		team.leader_id = best_successor.id
		best_successor.role = "leader"
		team.named_members.erase(best_successor.id)
		print("[Succession] Team %d 新 leader: P%d（統領=%.2f）" % [
			team.team_id, best_successor.id, best_command])
		PopulationSystem.new().check_overflow_for_team(state, team.team_id)
		return true
	# 無 named → 從 anon 晉升
	var promoted := PersonGenerator.generate_for_team(state, team, "member")
	if promoted != null:
		team.leader_id = promoted.id
		promoted.role = "leader"
		print("[Succession] Team %d 從匿名晉升新領袖 P%d（統領=%.2f）" % [
			team.team_id, promoted.id, float(promoted.skills.get("統領", 0.0))])
		PopulationSystem.new().check_overflow_for_team(state, team.team_id)
		return true
	print("[Succession] Team %d 無繼承人，崩潰中（無匿名人口）" % team.team_id)
	return false
