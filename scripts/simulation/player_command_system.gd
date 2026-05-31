class_name PlayerCommandSystem

# ── 查詢 API ─────────────────────────

func inspect_team(state: WorldState, team_id: int) -> Dictionary:
	var t: TeamData = state.teams.get(team_id)
	if t == null: return {}
	var leader: PersonData = state.persons.get(t.leader_id)
	var members: Array = []
	for pid in t.named_members:
		var p: PersonData = state.persons.get(pid)
		if p:
			members.append({
				"id": p.id, "name": p.person_name, "role": p.role,
				"loyalty": p.loyalty, "fatigue": p.stress
			})
	var leader_info: Dictionary = {}
	if leader:
		leader_info = { "id": leader.id, "name": leader.person_name }
	return {
		"team_id": t.team_id, "tile_pos": t.tile_pos, "population": t.population,
		"fatigue": t.fatigue, "current_task": t.current_task,
		"faction_id": t.faction_id, "tags": t.tags,
		"leader": leader_info, "named_members": members,
		"resources": t.resources
	}

func inspect_member(state: WorldState, person_id: int) -> Dictionary:
	var p: PersonData = state.persons.get(person_id)
	if p == null: return {}
	return {
		"id": p.id, "name": p.person_name, "role": p.role,
		"team_id": p.team_id, "age": p.age,
		"loyalty": p.loyalty, "stress": p.stress, "fear": p.fear,
		"values": p.values, "attributes": p.attributes, "skills": p.skills,
		"equipment": p.equipment
	}

func move_to(state: WorldState, target_pos: Vector2i) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	var key: int = target_pos.x * 1000 + target_pos.y
	if not state.world.tiles.has(key):
		return { "ok": false, "msg": "目標格不在地圖內" }
	if pt.tile_pos == target_pos:
		return { "ok": true, "msg": "已在目標格" }
	pt.move_target = target_pos
	return { "ok": true, "msg": "設定目標 (%d,%d)" % [target_pos.x, target_pos.y] }

func cancel_move(state: WorldState) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	pt.move_target = Vector2i(-1, -1)
	return { "ok": true, "msg": "取消移動" }

func get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return null
	return state.teams.get(p.team_id)

func get_player_person(state: WorldState) -> PersonData:
	return state.persons.get(state.player_id)
