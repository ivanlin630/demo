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
	# player team → choose_heir forced（凍世界）／絕後 game_over
	if state.player_id != -1 and team.team_id == state.get_player_team_id():
		# 冪等：安全網每 tick 對 leaderless 重呼，已 pending choose_heir 不重設
		if state.player_forced_event is Dictionary \
				and state.player_forced_event.get("action", "") == "choose_heir" \
				and int(state.player_forced_event.get("team_id", -1)) == team.team_id:
			return true
		return handle_player_succession(state, team)
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
		state.remove_member(team, best_successor.id, false)   # 晉升 leader：出 named 仍屬本隊
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

# player leader 死亡繼承（公開單一入口）。external caller 已知是 player team 時直呼此函數，
# 繞過 on_leader_death 的自動偵測（player person 可能已 erase 致 get_player_team_id 查不到）。
# 冪等性由 on_leader_death 的偵測分支負責（安全網每 tick 重呼）。
func handle_player_succession(state: WorldState, team: TeamData) -> bool:
	team.leader_id = -1
	if team.named_members.is_empty():
		state.game_over = true
		state.game_over_reason = "玩家絕後（Team%d 無繼承人）" % team.team_id
		print("[GameOver] %s" % state.game_over_reason)
		return false
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": team.team_id,
		"candidates": team.named_members.duplicate(),
	}
	state.player_forced_event_id = "heir_%d" % state.world.current_tick
	print("[Heir] 玩家 leader 死亡，等待選繼承人 (Team%d, %d 候選)" % [
		team.team_id, team.named_members.size()])
	return true
