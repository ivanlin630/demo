class_name EventSystem

const COMMAND_SKILL_MIN: float = 0.3

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

# 由外部呼叫（Leader 死亡後繼承檢查）
func on_leader_death(state: WorldState, team: TeamData) -> bool:
	var best_successor: PersonData = null
	var best_command: float = 0.0
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id != team.team_id or p.id == team.leader_id:
			continue
		var cmd: float = float(p.skills.get("統領", 0.0))
		if cmd > best_command:
			best_command = cmd
			best_successor = p
	if best_successor != null and best_command >= COMMAND_SKILL_MIN:
		print("[Event] Team %d 新領袖：Person %d（統領=%.2f）" % [
			team.team_id, best_successor.id, best_command
		])
		team.leader_id = best_successor.id
		best_successor.role = "leader"
		# 新 leader 統領不足時，溢出人口強制分團
		var new_cap: int  = TeamData.pop_cap_from_leadership(best_command)
		var overflow: int = team.population - new_cap
		if overflow > 0:
			var spare_id: int = -1
			for aid in team.advisors:
				if aid != team.leader_id:
					spare_id = aid
					break
			if spare_id == -1:
				for mid in team.members:
					if mid != team.leader_id:
						spare_id = mid
						break
			if spare_id != -1:
				var sub_id: int = SubteamSystem.new().dispatch(
					state, team.team_id, spare_id, overflow, "idle", team.tile_pos)
				if sub_id != -1:
					print("[Split] Leader 死亡，統領不足，溢出 %d 人分團 Team%d" % [overflow, sub_id])
			else:
				team.population = new_cap
				print("[Split] Leader 死亡，無 advisor，溢出 %d 人視為逃亡" % overflow)
		return true
	else:
		print("[Event] Team %d 無繼承人，崩潰中（統領不足）" % team.team_id)
		return false

