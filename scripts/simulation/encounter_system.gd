# scripts/simulation/encounter_system.gd
class_name EncounterSystem

const ESCORT_DETECT_RANGE: int    = 3    # TEST VALUE — 護送感知範圍
const ESCORT_MAX_NEARBY_ENEMIES: int = 1 # TEST VALUE
const PRISONER_CHECK_INTERVAL: int = 5   # TEST VALUE — 待校正
const MESSENGER_RANGE: int        = 5    # TEST VALUE

const WORLD_DIR_TO_EDGE: Dictionary = {
	Vector2i( 0, -1): 0,
	Vector2i( 1, -1): 1,
	Vector2i( 1,  0): 2,
	Vector2i( 0,  1): 3,
	Vector2i(-1,  1): 4,
	Vector2i(-1,  0): 5,
}

func hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _get_body_parts(unit: Dictionary, state: WorldState) -> Dictionary:
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		return p.body_parts if p else {}
	return unit.get("body_parts", {})

func is_dead(unit: Dictionary, state: WorldState) -> bool:
	var bp := _get_body_parts(unit, state)
	return bp.get("torso", {}).get("status", "healthy") == "severed"

func is_combat_capable(unit: Dictionary, state: WorldState) -> bool:
	if is_dead(unit, state): return false
	if unit.get("has_exited", false): return false
	var bp := _get_body_parts(unit, state)
	if bp.get("torso", {}).get("status", "healthy") == "critical": return false
	var legs_critical: int = 0
	if bp.get("right_leg", {}).get("status") == "critical": legs_critical += 1
	if bp.get("left_leg",  {}).get("status") == "critical": legs_critical += 1
	if legs_critical >= 2: return false
	return true

func _default_body_parts() -> Dictionary:
	return {
		"head":      {"status": "healthy"},
		"torso":     {"status": "healthy"},
		"right_arm": {"status": "healthy"},
		"left_arm":  {"status": "healthy"},
		"right_leg": {"status": "healthy"},
		"left_leg":  {"status": "healthy"},
	}

func _create_named_unit(pid: int, team_id: int, pos: Vector2i,
		state: WorldState) -> Dictionary:
	var fatigue: float = 0.0
	var t: TeamData = state.teams.get(team_id)
	if t: fatigue = t.fatigue
	return {
		"person_id":    pid,
		"team_id":      team_id,
		"pos":          pos,
		"stamina":      clampf(1.0 - fatigue, 0.1, 1.0),
		"is_messenger": false,
		"has_exited":   false,
		"escort_target": -1,
		"current_order":        { "type": "none", "target": -1 },
		"messenger_target_idx": -1,
		"action_timer":         0,
		"_max_timer":           10,
	}

func _create_anon_unit(team: TeamData, pos: Vector2i) -> Dictionary:
	return {
		"person_id":    -1,
		"team_id":      team.team_id,
		"pos":          pos,
		"stamina":      clampf(1.0 - team.fatigue, 0.1, 1.0),
		"is_messenger": false,
		"has_exited":   false,
		"escort_target": -1,
		"body_parts":   _default_body_parts(),
		"skills": { "戰鬥": float(team.resources.get("anon_combat_skill", 0.2)) },
		"current_order":        { "type": "none", "target": -1 },
		"messenger_target_idx": -1,
		"action_timer":         0,
		"_max_timer":           10,
	}

const MAP_RADIUS: int = 10   # TEST VALUE

func _get_edge_entry_positions(edge: int, count: int) -> Array:
	var positions: Array = []
	var edge_hexes: Array = _get_edge_hexes(edge)
	edge_hexes.shuffle()
	for i in range(mini(count, edge_hexes.size())):
		positions.append(edge_hexes[i])
	return positions

func _get_edge_hexes(edge: int) -> Array:
	var result: Array = []
	match edge:
		0: for x in range(-MAP_RADIUS, MAP_RADIUS + 1): result.append(Vector2i(x, -MAP_RADIUS))
		1: for y in range(-MAP_RADIUS, 0): result.append(Vector2i(MAP_RADIUS, y))
		2: for y in range(0, MAP_RADIUS + 1): result.append(Vector2i(MAP_RADIUS, y))
		3: for x in range(-MAP_RADIUS, MAP_RADIUS + 1): result.append(Vector2i(x, MAP_RADIUS))
		4: for y in range(0, MAP_RADIUS + 1): result.append(Vector2i(-MAP_RADIUS, y))
		5: for y in range(-MAP_RADIUS, 0): result.append(Vector2i(-MAP_RADIUS, y))
	return result

func _get_pursuit_entry_edges(offset: int) -> Array:
	return [(offset) % 6, (offset + 1) % 6, (offset + 2) % 6]

func get_reinforcement_entry_edge(
		encounter_tile: Vector2i, reinforcement_tile: Vector2i) -> int:
	var delta: Vector2i = encounter_tile - reinforcement_tile
	var best_edge: int = 0
	var best_dot: float = -99.0
	for dir in WORLD_DIR_TO_EDGE:
		var dot: float = float(delta.x * dir.x + delta.y * dir.y)
		if dot > best_dot:
			best_dot = dot
			best_edge = WORLD_DIR_TO_EDGE[dir]
	return best_edge

func init_encounter(state: WorldState, attacker_id: int, defender_id: int,
		combat_type: String) -> void:
	state.encounter_active      = true
	state.encounter_attacker_id = attacker_id
	state.encounter_defender_id = defender_id
	state.encounter_units.clear()

	var atk: TeamData = state.teams.get(attacker_id)
	var def: TeamData = state.teams.get(defender_id)
	if atk == null or def == null: return

	if combat_type == "pursuit":
		var center_positions: Array = [Vector2i(0,0), Vector2i(1,0),
			Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		_spawn_team_units(state, def, center_positions)
		var edges := _get_pursuit_entry_edges(state.pursuit_edge_offset)
		state.pursuit_edge_offset = (state.pursuit_edge_offset + 2) % 6
		var atk_positions: Array = []
		for e in edges:
			atk_positions += _get_edge_entry_positions(e, 5)
		_spawn_team_units(state, atk, atk_positions)
	else:
		var atk_pos := _get_edge_entry_positions(0, atk.population + atk.named_members.size())
		var def_pos := _get_edge_entry_positions(3, def.population + def.named_members.size())
		_spawn_team_units(state, atk, atk_pos)
		_spawn_team_units(state, def, def_pos)

	print("[Encounter] 遭遇戰開始 Team%d vs Team%d (type=%s) units=%d" % [
		attacker_id, defender_id, combat_type, state.encounter_units.size()])

func _calc_vision_range(unit: Dictionary, state: WorldState,
		time_vision_mult: float) -> int:
	var scout: float = 0.0
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p: scout = float(p.skills.get("偵查", 0.0))
	return roundi((2.0 + scout * 2.0) * time_vision_mult)   # TEST VALUE

func _count_nearby_enemies(unit: Dictionary, state: WorldState,
		range_hex: int) -> int:
	var count: int = 0
	for other in state.encounter_units:
		if other["team_id"] == unit["team_id"]: continue
		if is_dead(other, state) or other.get("has_exited", false): continue
		if hex_dist(unit["pos"], other["pos"]) <= range_hex:
			count += 1
	return count

func _get_nearest_enemy_index(unit: Dictionary, state: WorldState) -> int:
	var best_idx: int = -1; var best_d: int = 9999
	for i in range(state.encounter_units.size()):
		var other: Dictionary = state.encounter_units[i]
		if other["team_id"] == unit["team_id"]: continue
		if is_dead(other, state) or other.get("has_exited", false): continue
		var d: int = hex_dist(unit["pos"], other["pos"])
		if d < best_d: best_d = d; best_idx = i
	return best_idx

func _should_retreat(unit: Dictionary, state: WorldState,
		team_incapable_ratio: float) -> bool:
	if team_incapable_ratio > 0.7: return true
	var bp := _get_body_parts(unit, state)
	if bp.get("torso", {}).get("status") == "critical": return true
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p and p.values.get("求生欲", 0.5) > 0.7 and team_incapable_ratio > 0.5:
			return randf() < 0.3
	return false

func _should_escort(unit_idx: int, state: WorldState) -> int:
	var unit: Dictionary = state.encounter_units[unit_idx]
	if not is_combat_capable(unit, state): return -1
	if _count_nearby_enemies(unit, state, 2) > ESCORT_MAX_NEARBY_ENEMIES: return -1
	var p: PersonData = null
	if unit["person_id"] != -1:
		p = state.persons.get(unit["person_id"])
	if p != null and p.values.get("義氣", 0.5) < 0.4: return -1
	for i in range(state.encounter_units.size()):
		if i == unit_idx: continue
		var target: Dictionary = state.encounter_units[i]
		if target["team_id"] != unit["team_id"]: continue
		if is_dead(target, state): continue
		if is_combat_capable(target, state): continue
		if hex_dist(unit["pos"], target["pos"]) <= ESCORT_DETECT_RANGE:
			return i
	return -1

func _calc_team_incapable_ratio(team_id: int, state: WorldState) -> float:
	var total: int = 0; var incapable: int = 0
	for u in state.encounter_units:
		if u["team_id"] != team_id: continue
		if u.get("has_exited", false): continue
		total += 1
		if not is_combat_capable(u, state): incapable += 1
	if total == 0: return 0.0
	return float(incapable) / float(total)

# action 格式: { "type": String, "target_idx": int, "move_to": Vector2i, "attack_part": String }
func _decide_action(unit_idx: int, state: WorldState,
		focus_target: int) -> Dictionary:
	var unit: Dictionary = state.encounter_units[unit_idx]
	if not is_combat_capable(unit, state):
		return { "type": "incapable", "target_idx": -1,
			"move_to": unit["pos"], "attack_part": "" }

	var team_ratio: float = _calc_team_incapable_ratio(unit["team_id"], state)

	# 1. 撤退
	if _should_retreat(unit, state, team_ratio):
		return { "type": "retreat", "target_idx": -1,
			"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }

	# 2. 傳令
	if unit.get("is_messenger", false):
		return { "type": "messenger_exit", "target_idx": -1,
			"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }

	# 3. 護送
	var escort_idx: int = _should_escort(unit_idx, state)
	if escort_idx != -1 and unit.get("escort_target", -1) == -1:
		return { "type": "start_escort", "target_idx": escort_idx,
			"move_to": state.encounter_units[escort_idx]["pos"], "attack_part": "" }
	if unit.get("escort_target", -1) != -1:
		var etgt: Dictionary = state.encounter_units[unit["escort_target"]]
		if _count_nearby_enemies(unit, state, 2) >= 2:
			unit["escort_target"] = -1
			if _should_retreat(unit, state, team_ratio):
				return { "type": "retreat", "target_idx": -1,
					"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }
			var enemy_idx: int = _get_nearest_enemy_index(unit, state)
			return { "type": "attack", "target_idx": enemy_idx,
				"move_to": state.encounter_units[enemy_idx]["pos"] if enemy_idx != -1 else unit["pos"],
				"attack_part": "torso" }
		if unit["stamina"] <= 0.05:
			unit["escort_target"] = -1
			return { "type": "retreat", "target_idx": -1,
				"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }
		var _etgt_ref: Dictionary = etgt  # suppress unused warning
		return { "type": "escort_move", "target_idx": unit["escort_target"],
			"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }

	# 4. 集火目標
	if focus_target != -1 and focus_target < state.encounter_units.size():
		var ft: Dictionary = state.encounter_units[focus_target]
		if is_combat_capable(ft, state):
			return { "type": "attack", "target_idx": focus_target,
				"move_to": ft["pos"],
				"attack_part": _choose_attack_part(unit, state) }

	# 5. 接近最近敵人
	var nearest: int = _get_nearest_enemy_index(unit, state)
	if nearest == -1:
		return { "type": "idle", "target_idx": -1,
			"move_to": unit["pos"], "attack_part": "" }

	var target: Dictionary = state.encounter_units[nearest]
	var dist: int = hex_dist(unit["pos"], target["pos"])

	# 6. 技能行動
	var is_archer: bool = false
	var archer_skill: float = 0.0
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p: archer_skill = float(p.skills.get("弓箭", 0.0))
	is_archer = archer_skill > 0.1 and unit.get("arrows", 0) > 0

	if is_archer:
		if dist >= 3 and dist <= 5:
			return { "type": "shoot", "target_idx": nearest,
				"move_to": unit["pos"], "attack_part": _choose_attack_part(unit, state) }
		elif dist < 3:
			return { "type": "move_back", "target_idx": nearest,
				"move_to": _calc_retreat_dir(unit, state, nearest),
				"attack_part": "" }

	if dist <= 1:
		return { "type": "attack", "target_idx": nearest,
			"move_to": unit["pos"], "attack_part": _choose_attack_part(unit, state) }
	return { "type": "move", "target_idx": nearest,
		"move_to": target["pos"], "attack_part": "" }

func _choose_attack_part(unit: Dictionary, state: WorldState) -> String:
	if unit["person_id"] == -1: return "torso"
	var p: PersonData = state.persons.get(unit["person_id"])
	if p == null: return "torso"
	var tactics: float = float(p.skills.get("戰術", 0.0))
	if tactics > 0.5 and randf() < 0.4: return "right_leg"
	return "torso"

func _nearest_edge_pos(pos: Vector2i) -> Vector2i:
	var dirs: Array = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
		Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	var best_dir: Vector2i = dirs[0]; var best_score: int = -999
	for d in dirs:
		var npos: Vector2i = pos + d
		var score: int = abs(npos.x) + abs(npos.y)
		if score > best_score: best_score = score; best_dir = d
	return pos + best_dir

func _calc_retreat_dir(unit: Dictionary, state: WorldState,
		threat_idx: int) -> Vector2i:
	var threat: Dictionary = state.encounter_units[threat_idx]
	var away: Vector2i = unit["pos"] - threat["pos"]
	return unit["pos"] + away.sign()

const STATUS_ORDER: Array = ["healthy", "wounded", "critical", "severed"]

func _apply_body_part_damage(unit: Dictionary, state: WorldState,
		part: String, attacker_skill: float) -> void:
	var bp: Dictionary = _get_body_parts(unit, state)
	if not bp.has(part): part = "torso"
	var cur_status: String = bp[part].get("status", "healthy")
	var cur_idx: int = STATUS_ORDER.find(cur_status)
	if cur_idx < 0: cur_idx = 0
	var hit_chance: float = 0.5 + attacker_skill * 0.3
	if randf() > hit_chance: return
	var new_idx: int = mini(cur_idx + 1, STATUS_ORDER.size() - 1)
	bp[part]["status"] = STATUS_ORDER[new_idx]
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p: p.body_parts[part]["status"] = STATUS_ORDER[new_idx]

func _get_attacker_skill(unit: Dictionary, state: WorldState) -> float:
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p: return float(p.skills.get("戰鬥", 0.0))
	return float(unit.get("skills", {}).get("戰鬥", 0.2))

func _check_prisoners(state: WorldState, round_num: int) -> void:
	if round_num % PRISONER_CHECK_INTERVAL != 0: return
	for i in range(state.encounter_units.size()):
		var unit: Dictionary = state.encounter_units[i]
		if is_dead(unit, state): continue
		if is_combat_capable(unit, state): continue
		if unit.get("has_exited", false): continue
		if unit.get("is_prisoner", false): continue
		var nearby_enemies: int = _count_nearby_enemies(unit, state, 1)
		if nearby_enemies >= 2:
			unit["is_prisoner"] = true
			var winner_team_id: int = _get_enemy_team_id(unit["team_id"], state)
			print("[Encounter] Unit(team=%d) 被俘虜，歸入 Team%d" % [
				unit["team_id"], winner_team_id])

func _get_enemy_team_id(own_team_id: int, state: WorldState) -> int:
	for u in state.encounter_units:
		if u["team_id"] != own_team_id and not is_dead(u, state):
			return u["team_id"]
	return -1

func _messenger_exit(state: WorldState, unit: Dictionary,
		parent_team: TeamData) -> void:
	unit["has_exited"] = true
	if unit["person_id"] == -1: return
	var sub_sys := SubteamSystem.new()
	var sub_data: Dictionary = {
		"leader_id":      unit["person_id"],
		"parent_team_id": parent_team.team_id,
		"tile_pos":       parent_team.tile_pos,
		"task":           "傳令",
	}
	print("[Encounter] Person%d 傳令兵退出，建立子隊" % unit["person_id"])
	if sub_sys.has_method("create_subteam"):
		sub_sys.create_subteam(state, sub_data)

func advance_round(state: WorldState, round_num: int) -> String:
	var atk_id: int = state.encounter_attacker_id
	var def_id: int = state.encounter_defender_id

	for i in range(state.encounter_units.size()):
		var unit: Dictionary = state.encounter_units[i]
		if is_dead(unit, state): continue
		if unit.get("has_exited", false): continue
		if unit.get("is_prisoner", false): continue

		var action: Dictionary = _decide_action(i, state, -1)

		match action["type"]:
			"attack", "shoot":
				if action["target_idx"] != -1:
					var target: Dictionary = state.encounter_units[action["target_idx"]]
					if not is_dead(target, state) and not target.get("has_exited", false):
						var skill: float = _get_attacker_skill(unit, state)
						_apply_body_part_damage(target, state,
							action["attack_part"], skill)
						if action["type"] == "shoot":
							unit["arrows"] = max(unit.get("arrows", 0) - 1, 0)
						unit["stamina"] = maxf(unit.get("stamina", 1.0) - 0.05, 0.0)
			"move", "move_back", "escort_move", "start_escort":
				unit["pos"] = action["move_to"]
				unit["stamina"] = maxf(unit.get("stamina", 1.0) - 0.02, 0.0)
				if action["type"] == "start_escort":
					unit["escort_target"] = action["target_idx"]
			"retreat", "messenger_exit":
				unit["pos"] = action["move_to"]
				unit["stamina"] = maxf(unit.get("stamina", 1.0) - 0.03, 0.0)
				var dist_to_edge: int = MAP_RADIUS - maxi(abs(unit["pos"].x), abs(unit["pos"].y))
				if dist_to_edge <= 0:
					unit["has_exited"] = true
					if action["type"] == "messenger_exit":
						var parent: TeamData = state.teams.get(unit["team_id"])
						if parent: _messenger_exit(state, unit, parent)

	_check_prisoners(state, round_num)

	var atk_alive: bool = _has_active_units(atk_id, state)
	var def_alive: bool = _has_active_units(def_id, state)
	var atk_exited: bool = _all_exited(atk_id, state)
	var def_exited: bool = _all_exited(def_id, state)

	if def_exited or (not def_alive and def_id != -1):
		return "attacker_win"
	if atk_exited or (not atk_alive and atk_id != -1):
		return "defender_win"
	if not atk_alive and not def_alive:
		return "draw"
	return "ongoing"

func _has_active_units(team_id: int, state: WorldState) -> bool:
	for u in state.encounter_units:
		if u["team_id"] == team_id:
			if not is_dead(u, state) and not u.get("has_exited", false) \
					and not u.get("is_prisoner", false):
				return true
	return false

func _all_exited(team_id: int, state: WorldState) -> bool:
	var had_units: bool = false
	for u in state.encounter_units:
		if u["team_id"] != team_id: continue
		had_units = true
		if not is_dead(u, state) and not u.get("has_exited", false): return false
	return had_units

func _equip_named_npc(p: PersonData, team: TeamData) -> void:
	if p.equipment["right_hand"]["type"] == "none":
		for grade in ["weapon_melee_low", "weapon_melee_high",
				"weapon_ranged_low", "weapon_ranged_high"]:
			if int(team.resources.get(grade, 0)) > 0:
				p.equipment["right_hand"] = { "type": "pool", "grade": grade }
				team.resources[grade] = int(team.resources[grade]) - 1
				break
	for slot in ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]:
		if p.equipment.get(slot, {"type":"none"})["type"] != "none": continue
		var cfg: String = team.armor_config.get(slot, "none")
		if cfg == "none": continue
		var grade_key: String = "armor_" + cfg
		if int(team.resources.get(grade_key, 0)) > 0:
			p.equipment[slot] = { "type": "pool", "grade": grade_key }
			team.resources[grade_key] = int(team.resources[grade_key]) - 1

func _distribute_anon_equipment(state: WorldState, team: TeamData) -> void:
	var anon_units: Array = []
	for u in state.encounter_units:
		if u["team_id"] == team.team_id and u["person_id"] == -1:
			anon_units.append(u)
	var weapon_pool: int = 0
	for grade in ["weapon_melee_low", "weapon_melee_high",
			"weapon_ranged_low", "weapon_ranged_high"]:
		weapon_pool += int(team.resources.get(grade, 0))
	var i: int = 0
	for u in anon_units:
		u["has_weapon"] = (i < weapon_pool)
		i += 1

func setup_arrows(state: WorldState, team: TeamData) -> void:
	var archers: int = 0
	for u in state.encounter_units:
		if u["team_id"] != team.team_id: continue
		if u["person_id"] != -1:
			var p: PersonData = state.persons.get(u["person_id"])
			if p and float(p.skills.get("弓箭", 0.0)) > 0.1: archers += 1
		else:
			if float(u.get("skills", {}).get("弓箭", 0.0)) > 0.0: archers += 1
	var total_arrows: int = int(team.resources.get("arrows", 0))
	var per_archer: int = total_arrows / maxi(archers, 1)
	for u in state.encounter_units:
		if u["team_id"] != team.team_id: continue
		var is_archer: bool = false
		if u["person_id"] != -1:
			var p: PersonData = state.persons.get(u["person_id"])
			is_archer = p != null and float(p.skills.get("弓箭", 0.0)) > 0.1
		else:
			is_archer = float(u.get("skills", {}).get("弓箭", 0.0)) > 0.0
		u["arrows"] = per_archer if is_archer else 0

func _return_pool_equipment(state: WorldState) -> void:
	for u in state.encounter_units:
		if not is_dead(u, state): continue
		var team: TeamData = state.teams.get(u["team_id"])
		if team == null: continue
		if u["person_id"] != -1:
			var p: PersonData = state.persons.get(u["person_id"])
			if p == null: continue
			for slot in p.equipment:
				var item: Dictionary = p.equipment[slot]
				if item.get("type", "none") == "pool":
					team.resources[item["grade"]] = int(team.resources.get(item["grade"], 0)) + 1
					p.equipment[slot] = { "type": "none", "grade": "" }

func _spawn_team_units(state: WorldState, team: TeamData,
		positions: Array) -> void:
	var pos_idx: int = 0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var pos: Vector2i = positions[pos_idx % positions.size()]
		pos_idx += 1
		state.encounter_units.append(_create_named_unit(pid, team.team_id, pos, state))
	for _i in range(team.population):
		var pos: Vector2i = positions[pos_idx % positions.size()]
		pos_idx += 1
		state.encounter_units.append(_create_anon_unit(team, pos))

func resolve_encounter_end(state: WorldState, result: String) -> void:
	var atk_id: int = state.encounter_attacker_id
	var def_id: int = state.encounter_defender_id

	_return_pool_equipment(state)

	var arrows_used: Dictionary = {}
	for u in state.encounter_units:
		var used: int = u.get("archer_arrows_init", 0) - u.get("arrows", 0)
		if used > 0:
			arrows_used[u["team_id"]] = arrows_used.get(u["team_id"], 0) + used
	for tid in arrows_used:
		var t: TeamData = state.teams.get(tid)
		if t:
			t.resources["arrows"] = maxi(int(t.resources.get("arrows", 0)) - arrows_used[tid], 0)

	for u in state.encounter_units:
		if u["person_id"] == -1: continue
		if not is_dead(u, state): continue
		var t: TeamData = state.teams.get(u["team_id"])
		if t:
			t.named_members.erase(u["person_id"])
			if t.leader_id == u["person_id"]: t.leader_id = -1

	for team_id in [atk_id, def_id]:
		var dead_anon: int = 0
		for u in state.encounter_units:
			if u["team_id"] != team_id: continue
			if u["person_id"] != -1: continue
			if is_dead(u, state): dead_anon += 1
		var t: TeamData = state.teams.get(team_id)
		if t: t.population = maxi(t.population - dead_anon, 0)

	var winner_id: int = atk_id if result == "attacker_win" else def_id
	var loser_id: int  = def_id if result == "attacker_win" else atk_id
	var winner_team: TeamData = state.teams.get(winner_id)
	for u in state.encounter_units:
		if not u.get("is_prisoner", false): continue
		if u["team_id"] != loser_id: continue
		if winner_team:
			winner_team.population += 1
			print("[Encounter] 俘虜加入 Team%d" % winner_id)

	for team_id in [atk_id, def_id]:
		var t: TeamData = state.teams.get(team_id)
		if t: t.combat_target = -1

	print("[Encounter] 遭遇戰結算完成 result=%s" % result)

	state.encounter_units.clear()
	state.encounter_active = false
	state.encounter_attacker_id = -1
	state.encounter_defender_id = -1
