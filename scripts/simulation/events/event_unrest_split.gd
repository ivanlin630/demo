extends "res://scripts/simulation/events/base_event.gd"

const UNREST_SPLIT_THRESHOLD: int = 30
const LOYALTY_LEAVE_THRESHOLD: float = 0.35

func check(state: WorldState, team: TeamData) -> bool:
	if team.unrest_turns < UNREST_SPLIT_THRESHOLD:
		return false
	var dissenters := _get_dissenters(state, team)
	if dissenters.is_empty():
		return false
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null:
		return false
	return _has_goal_conflict(dissenters, leader)

func execute(state: WorldState, team: TeamData) -> Array:
	var dissenters := _get_dissenters(state, team)
	var new_team := _split_team(state, team, dissenters)
	if new_team == null:
		return []
	UnrestBank.reset(team, "split")
	print("[Event] Team %d 分裂 → 新 Team %d（%d人）" % [
		team.team_id, new_team.team_id, new_team.population
	])
	SimMessageSystem.new().emit_message(state, "split",
		"Team %d 發生分裂，新 Team %d 在 (%d,%d) 成立" % [
			team.team_id, new_team.team_id, team.tile_pos.x, team.tile_pos.y
		], team,
		{ "origin": str(team.team_id), "x": str(team.tile_pos.x), "y": str(team.tile_pos.y) })
	return [new_team]

func _get_dissenters(state: WorldState, team: TeamData) -> Array:
	var result: Array = []
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == team.team_id and p.id != team.leader_id:
			if p.loyalty < LOYALTY_LEAVE_THRESHOLD:
				result.append(p)
	return result

# 義氣 < 0.4 的異見者才觸發分裂；義氣 >= 0.4 視為不足以割席
func _has_goal_conflict(dissenters: Array, leader: PersonData) -> bool:
	for p in dissenters:
		var loyalty_val: float = float(p.values.get("義氣", 0.5))
		if loyalty_val >= 0.4:
			continue
		for goal in p.goals:
			if not (goal is Dictionary): continue
			if not goal.get("active", false): continue
			var gtype: String = goal.get("type", "")
			var leader_has: bool = false
			for lg in leader.goals:
				if lg is Dictionary and lg.get("type", "") == gtype:
					leader_has = true
					break
			if not leader_has:
				return true
	return false

func _split_team(state: WorldState, parent: TeamData, dissenters: Array) -> TeamData:
	if dissenters.is_empty():
		return null
	var new_team := TeamData.new()
	new_team.team_id   = _next_team_id(state)
	new_team.tile_pos  = parent.tile_pos
	state.set_team_faction(new_team, -1)   # S11 chokepoint（fresh team，no-op；單寫者一致）
	# 新團 resources 全 0 = 空池（downstream 一律 .get(k,0)）→ clear_all 等價且不憑空生
	ResourceBank.clear_all(new_team, "split_init")
	state.set_team_tags(new_team, [], "split_init")

	# 選 new leader
	var new_leader: PersonData = dissenters[0]
	state.set_leader(new_team, new_leader.id)   # chokepoint：leader_id+team_id(=new_team)+role
	reset_loyalty_on_transfer(new_leader, "split_leader")
	state.remove_member(parent, new_leader.id, false)   # 出母 roster（team_id 已=new_team）
	# population 為 getter：leader_id 設定 + named.erase 即反映，無須手動加減

	# Hard dissenters（loyalty < 0.35）
	for i in range(1, dissenters.size()):
		var p: PersonData = dissenters[i]
		state.add_member(new_team, p.id)               # 入新隊 + team_id
		reset_loyalty_on_transfer(p, "split_hard")
		state.remove_member(parent, p.id, false)       # 出母 roster（team_id 已=new_team）

	# Soft followers（loyalty 0.35–0.55，依魅力）
	var charisma: float = float(new_leader.attributes.get("魅力", 0.5))
	for pid in parent.named_members.duplicate():
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		if p.loyalty >= 0.35 and p.loyalty <= 0.55:
			if randf() < charisma * 0.6:
				state.add_member(new_team, p.id)               # 入新隊 + team_id
				reset_loyalty_on_transfer(p, "split_soft")
				state.remove_member(parent, p.id, false)       # 出母 roster（team_id 已=new_team）

	# 匿名跟隨者（依統領×魅力）
	var leadership: float = float(new_leader.skills.get("統領", 0.0))
	var anon_in_parent: int = parent.population - parent.named_members.size() - 1
	var anon_split: int = roundi(leadership * charisma * anon_in_parent * 0.3)
	anon_split = mini(anon_split, parent.population / 3)
	AnonTierSystem.transfer_proportional(parent, new_team, anon_split)

	state.create_team(new_team)   # S9 chokepoint：註冊 + known/discovered init
	if Probe.enabled: Probe.bump("spawn.unrest_split")   # ★tap-gap 補：高 unrest 分裂生新隊（碎裂源可測、全量暫態可觀測）
	UnrestBank.reset(parent, "split")
	return new_team

func reset_loyalty_on_transfer(p: PersonData, transfer_type: String) -> void:
	match transfer_type:
		"split_hard":   LoyaltyBank.set_baseline(p, 0.5, "split_hard")
		"split_soft":   LoyaltyBank.set_baseline(p, 0.65, "split_soft")
		"split_leader": LoyaltyBank.set_baseline(p, 1.0, "split_leader")
		"conquered":    LoyaltyBank.set_baseline(p, 0.25, "conquered")
		"voluntary":    LoyaltyBank.set_baseline(p, 0.5, "voluntary")
		"master":       LoyaltyBank.set_baseline(p, 0.9, "master")

func _next_team_id(state: WorldState) -> int:
	var max_id: int = 0
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1
