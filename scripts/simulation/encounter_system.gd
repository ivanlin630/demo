# scripts/simulation/encounter_system.gd
class_name EncounterSystem

const ANON_UNIT_CAP: int          = 30   # TEST VALUE — 每隊匿名 unit 最多 30 個
const ESCORT_DETECT_RANGE: int    = 3    # TEST VALUE — 護送感知範圍
const ESCORT_MAX_NEARBY_ENEMIES: int = 1 # TEST VALUE
const PRISONER_CHECK_INTERVAL: int = 5   # TEST VALUE — 待校正
const MESSENGER_RANGE: int        = 5    # TEST VALUE

const BASE_ACTION_TICKS: int  = 10
const BLOCK_WINDOW: int       = 8
const BLOCK_PENALTY: int      = 5

const STANCE_SPEED_MULT: Dictionary = {
	"walk":   1.0,
	"sprint": 1.5,
	"crouch": 0.5,
	"prone":  0.1,
}
const STANCE_MOVE_STAMINA: Dictionary = {
	"walk":   0.02,
	"sprint": 0.05,
	"crouch": 0.005,
	"prone":  0.0,
}
const STANCE_RANGED_DMG_MULT: Dictionary = {
	"walk":   1.0,
	"sprint": 1.0,
	"crouch": 0.7,
	"prone":  0.4,
}
const STAMINA_EXHAUSTED_ATK_MULT: float = 0.5

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

func _is_in_map(pos: Vector2i) -> bool:
	return hex_dist(Vector2i.ZERO, pos) <= MAP_RADIUS

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
		"head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"torso":     { "hp": 50.0, "max_hp": 50.0, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"right_arm": { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"left_arm":  { "hp": 25.0, "max_hp": 25.0, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"right_leg": { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"left_leg":  { "hp": 30.0, "max_hp": 30.0, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
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
		"action_timer":         BASE_ACTION_TICKS,
		"stance":               "walk",
		"pending_dodge":        false,
		"current_order":        { "type": "none", "target": -1 },
		"messenger_target_idx": -1,
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
		"equipment": {
			"hand_1": {}, "hand_2": {}, "head": {}, "torso": {},
			"right_arm": {}, "left_arm": {}, "right_leg": {}, "left_leg": {},
		},
		"inventory": [],
		"action_timer":         BASE_ACTION_TICKS,
		"stance":               "walk",
		"pending_dodge":        false,
		"current_order":        { "type": "none", "target": -1 },
		"messenger_target_idx": -1,
	}

const MAP_RADIUS: int = 10   # TEST VALUE
const MAP_DIAMETER: int = MAP_RADIUS * 2   # 內切圓直徑 = 1 world-hex 的尺度

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
		0:  # top: y=-R, x from 0 to R
			for x in range(0, MAP_RADIUS + 1):
				result.append(Vector2i(x, -MAP_RADIUS))
		1:  # upper-right: x=R, y from -R to 0
			for y in range(-MAP_RADIUS, 1):
				result.append(Vector2i(MAP_RADIUS, y))
		2:  # lower-right: x+y=R, x from 0 to R
			for x in range(0, MAP_RADIUS + 1):
				result.append(Vector2i(x, MAP_RADIUS - x))
		3:  # bottom: y=R, x from -R to 0
			for x in range(-MAP_RADIUS, 1):
				result.append(Vector2i(x, MAP_RADIUS))
		4:  # lower-left: x=-R, y from 0 to R
			for y in range(0, MAP_RADIUS + 1):
				result.append(Vector2i(-MAP_RADIUS, y))
		5:  # upper-left: x+y=-R, x from -R to 0
			for x in range(-MAP_RADIUS, 1):
				result.append(Vector2i(x, -MAP_RADIUS - x))
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
		var atk_anon: int = mini(int(float(atk.population) * atk.armed_anon_ratio), ANON_UNIT_CAP)
		var def_anon: int = mini(int(float(def.population) * def.armed_anon_ratio), ANON_UNIT_CAP)
		var atk_pos := _get_edge_entry_positions(0, atk.named_members.size() + 1 + atk_anon)
		var def_pos := _get_edge_entry_positions(3, def.named_members.size() + 1 + def_anon)
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
	is_archer = archer_skill > 0.1 and _has_arrows(unit)

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
		part: String, final_dmg: float) -> void:
	HealthSystem.receive_damage(unit, state, part, final_dmg)

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

func _base_speed(unit: Dictionary, state: WorldState) -> float:
	var p: PersonData = state.persons.get(unit.get("person_id", -1))
	var body: float = float(p.attributes.get("體力", 0.5)) if p else 0.5
	return 1.0 + body * 0.2

func _effective_speed(unit: Dictionary, state: WorldState) -> float:
	var base: float   = _base_speed(unit, state)
	var stance: float = STANCE_SPEED_MULT.get(unit.get("stance", "walk"), 1.0)
	var health: float = HealthSystem.get_speed_mult(unit, state)
	return base * stance * health

func _max_timer(unit: Dictionary, state: WorldState) -> int:
	return maxi(roundi(float(BASE_ACTION_TICKS) / _effective_speed(unit, state)), 1)

func _get_weapon_grade(unit: Dictionary, _state: WorldState) -> String:
	var equip: Dictionary = unit.get("equipment", {})
	var h1: Dictionary    = equip.get("hand_1", {})
	if h1.get("type", "none") not in ["none", "2h_ref", ""]:
		return h1.get("grade", "unarmed")
	return "unarmed"

func _get_armor_grade_at(unit: Dictionary, _state: WorldState,
		part: String) -> String:
	var equip: Dictionary = unit.get("equipment", {})
	var slot: Dictionary  = equip.get(part, {})
	if slot.get("type", "none") in ["none", ""]: return "none"
	return slot.get("grade", "none")

func _get_shield_grade(unit: Dictionary, _state: WorldState) -> String:
	var equip: Dictionary = unit.get("equipment", {})
	for hand in ["hand_1", "hand_2"]:
		var s: Dictionary = equip.get(hand, {})
		if s.get("grade", "").begins_with("armor_"): return s.get("grade", "")
	return ""

func _has_shield(unit: Dictionary, state: WorldState) -> bool:
	return _get_shield_grade(unit, state) != ""

func _has_melee_weapon(unit: Dictionary, state: WorldState) -> bool:
	var grade: String = _get_weapon_grade(unit, state)
	return grade.contains("melee") or grade == "unarmed"

func _get_skill(unit: Dictionary, state: WorldState, skill: String) -> float:
	var p: PersonData = state.persons.get(unit.get("person_id", -1))
	if p: return float(p.skills.get(skill, 0.0))
	return float(unit.get("skills", {}).get(skill, 0.0))

func _can_block(unit: Dictionary) -> bool:
	return int(unit.get("action_timer", 999)) <= BLOCK_WINDOW

func _shield_block_chance(unit: Dictionary, state: WorldState) -> float:
	var grade: String  = _get_shield_grade(unit, state)
	var base: float    = ItemAttributes.get_block_chance(grade)
	var combat: float  = _get_skill(unit, state, "戰鬥")
	return clampf(base + combat * 0.3, 0.0, 0.90)

func _parry_chance(unit: Dictionary, state: WorldState) -> float:
	var weapon: String = _get_weapon_grade(unit, state)
	var base: float    = ItemAttributes.get_parry_chance(weapon)
	var combat: float  = _get_skill(unit, state, "戰鬥")
	return clampf(base + combat * 0.4, 0.0, 0.85)

func _dodge_chance(unit: Dictionary, state: WorldState) -> float:
	var p: PersonData   = state.persons.get(unit.get("person_id", -1))
	var survival: float = _get_skill(unit, state, "求生")
	var body: float     = float(p.attributes.get("體力", 0.5)) if p else 0.5
	return clampf(0.2 + survival * 0.4 * (0.5 + body * 0.5), 0.0, 0.80)

func _resolve_block(unit: Dictionary, state: WorldState,
		choice: String) -> bool:
	match choice:
		"shield": return randf() < _shield_block_chance(unit, state)
		"parry":  return randf() < _parry_chance(unit, state)
		"dodge":
			unit["stamina"] = maxf(float(unit.get("stamina", 0.0)) - 0.1, 0.0)
			return randf() < _dodge_chance(unit, state)
	return false

func _npc_auto_block(unit: Dictionary, state: WorldState) -> String:
	var options: Dictionary = {}
	if _has_shield(unit, state):
		options["shield"] = _shield_block_chance(unit, state)
	if _has_melee_weapon(unit, state):
		options["parry"] = _parry_chance(unit, state)
	if float(unit.get("stamina", 0.0)) > 0.1:
		options["dodge"] = _dodge_chance(unit, state)
	var best: String = "none"; var best_val: float = 0.3
	for opt in options:
		if options[opt] > best_val: best_val = options[opt]; best = opt
	return best

func _check_range(attacker: Dictionary, target: Dictionary,
		state: WorldState) -> bool:
	var weapon: String = _get_weapon_grade(attacker, state)
	return hex_dist(attacker["pos"], target["pos"]) \
		   <= ItemAttributes.get_range(weapon)

func _hit_chance(attacker: Dictionary, state: WorldState) -> float:
	var weapon: String = _get_weapon_grade(attacker, state)
	var base: float    = 0.6
	var skill: float   = 0.0
	if weapon.contains("ranged"):
		skill = _get_skill(attacker, state, "弓箭") * 0.4
	else:
		skill = _get_skill(attacker, state, "戰鬥") * 0.4
	return clampf(base + skill, 0.05, 0.95)

func resolve_attack(attacker: Dictionary, target: Dictionary,
		state: WorldState, target_part: String) -> void:
	var weapon: String  = _get_weapon_grade(attacker, state)
	var is_ranged: bool = weapon.contains("ranged")
	if is_ranged and not _check_range(attacker, target, state): return
	if target.get("pending_dodge", false):
		target["pending_dodge"] = false
		if _resolve_block(target, state, "dodge"):
			print("[Dodge] unit team=%d 閃避成功" % target["team_id"])
			target["action_timer"] = mini(target["action_timer"] + BLOCK_PENALTY,
				_max_timer(target, state))
			return
	if _can_block(target):
		var choice: String = "none"
		if target.get("person_id", -1) != state.player_id:
			choice = _npc_auto_block(target, state)
		if choice != "none":
			var blocked: bool = _resolve_block(target, state, choice)
			target["action_timer"] = mini(target["action_timer"] + BLOCK_PENALTY,
				_max_timer(target, state))
			if blocked:
				print("[Block] team=%d blocked with %s" % [target["team_id"], choice])
				return
	if randf() > _hit_chance(attacker, state):
		print("[Miss]")
		return
	var raw_dmg: float = ItemAttributes.get_damage(weapon)
	var drain_mult: float = HealthSystem.get_weight_stamina_drain_mult(attacker, state)
	attacker["stamina"] = maxf(float(attacker.get("stamina", 1.0)) - 0.05 * drain_mult, 0.0)
	if float(attacker.get("stamina", 1.0)) <= 0.0:
		raw_dmg *= STAMINA_EXHAUSTED_ATK_MULT
	if is_ranged:
		raw_dmg *= STANCE_RANGED_DMG_MULT.get(target.get("stance", "walk"), 1.0)
	var armor: String    = _get_armor_grade_at(target, state, target_part)
	var reduction: float = ItemAttributes.get_damage_reduction(armor)
	var final_dmg: float = raw_dmg * (1.0 - reduction)
	HealthSystem.receive_damage(target, state, target_part, final_dmg)
	print("[Hit] part=%s dmg=%.1f" % [target_part, final_dmg])

func advance_encounter_tick(state: WorldState) -> String:
	var atk_id: int = state.encounter_attacker_id
	var def_id: int = state.encounter_defender_id
	var round_num: int = state.encounter_tick
	state.encounter_tick = round_num + 1

	for i in range(state.encounter_units.size()):
		var unit: Dictionary = state.encounter_units[i]
		if is_dead(unit, state): continue
		if unit.get("has_exited", false): continue
		if unit.get("is_prisoner", false): continue

		HealthSystem.tick_status_effects(unit, state)
		unit["action_timer"] -= 1
		if unit["action_timer"] > 0: continue

		var action: Dictionary = _decide_action(i, state, -1)
		match action["type"]:
			"attack", "shoot":
				if action["target_idx"] != -1:
					var target: Dictionary = state.encounter_units[action["target_idx"]]
					if not is_dead(target, state) and not target.get("has_exited", false):
						if action["type"] == "shoot" and not _has_arrows(unit): pass
						else:
							if action["type"] == "shoot": _consume_arrow(unit)
							resolve_attack(unit, target, state, action["attack_part"])
			"move", "move_back", "escort_move", "start_escort":
				var drain_mult: float = HealthSystem.get_weight_stamina_drain_mult(unit, state)
				var stamina_cost: float = STANCE_MOVE_STAMINA.get(unit.get("stance", "walk"), 0.02)
				unit["pos"]     = action["move_to"]
				unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - stamina_cost * drain_mult, 0.0)
				if action["type"] == "start_escort":
					unit["escort_target"] = action["target_idx"]
			"retreat", "messenger_exit":
				unit["pos"]     = action["move_to"]
				unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - 0.03, 0.0)
				if hex_dist(Vector2i.ZERO, unit["pos"]) >= MAP_RADIUS:
					unit["has_exited"] = true
					if action["type"] == "messenger_exit":
						var parent: TeamData = state.teams.get(unit["team_id"])
						if parent: _messenger_exit(state, unit, parent)

		unit["action_timer"] = _max_timer(unit, state)

	_check_prisoners(state, round_num)

	var atk_alive: bool  = _has_active_units(atk_id, state)
	var def_alive: bool  = _has_active_units(def_id, state)
	var atk_exited: bool = _all_exited(atk_id, state)
	var def_exited: bool = _all_exited(def_id, state)

	if def_exited or (not def_alive and def_id != -1): return "attacker_win"
	if atk_exited or (not atk_alive and atk_id != -1): return "defender_win"
	if not atk_alive and not def_alive: return "draw"
	return "ongoing"

func advance_round(state: WorldState, _round_num: int) -> String:
	push_warning("advance_round is deprecated — use advance_encounter_tick")
	return advance_encounter_tick(state)

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

func _init_named_unit(unit: Dictionary, p: PersonData,
		team: TeamData, state: WorldState) -> void:
	unit["equipment"] = p.equipment.duplicate(true)
	if unit["equipment"]["hand_1"].get("type", "none") in ["none", ""]:
		for grade in ["weapon_melee_low", "weapon_melee_high",
				"weapon_ranged_low", "weapon_ranged_high"]:
			if int(team.resources.get(grade, 0)) > 0:
				unit["equipment"]["hand_1"] = { "type": "pool", "grade": grade }
				team.resources[grade] = int(team.resources[grade]) - 1
				break
	if unit["equipment"]["torso"].get("type", "none") in ["none", ""]:
		var cfg: String = team.armor_config.get("torso", "none")
		if cfg == "low" and int(team.resources.get("armor_low", 0)) > 0:
			unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_low" }
			team.resources["armor_low"] -= 1
		elif cfg == "high" and int(team.resources.get("armor_high", 0)) > 0:
			unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_high" }
			team.resources["armor_high"] -= 1
	for slot in ["head", "right_arm", "left_arm", "right_leg", "left_leg"]:
		if unit["equipment"][slot].get("type", "none") in ["none", ""]:
			var cfg2: String = team.armor_config.get(slot, "none")
			if cfg2 == "low" and int(team.resources.get("armor_low", 0)) > 0:
				unit["equipment"][slot] = { "type": "pool", "grade": "armor_low" }
				team.resources["armor_low"] -= 1
			elif cfg2 == "high" and int(team.resources.get("armor_high", 0)) > 0:
				unit["equipment"][slot] = { "type": "pool", "grade": "armor_high" }
				team.resources["armor_high"] -= 1
	unit["inventory"] = []
	EncounterTemplates.fill_inventory(unit, team, state)

func _init_anon_unit(unit: Dictionary, team: TeamData,
		state: WorldState) -> void:
	for grade in ["weapon_melee_low", "weapon_melee_high",
			"weapon_ranged_low", "weapon_ranged_high"]:
		if int(team.resources.get(grade, 0)) > 0:
			unit["equipment"]["hand_1"] = { "type": "pool", "grade": grade }
			team.resources[grade] = int(team.resources[grade]) - 1
			break
	var cfg: String = team.armor_config.get("torso", "none")
	if cfg == "low" and int(team.resources.get("armor_low", 0)) > 0:
		unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_low" }
		team.resources["armor_low"] -= 1
	elif cfg == "high" and int(team.resources.get("armor_high", 0)) > 0:
		unit["equipment"]["torso"] = { "type": "pool", "grade": "armor_high" }
		team.resources["armor_high"] -= 1
	EncounterTemplates.fill_inventory(unit, team, state)

func _has_arrows(unit: Dictionary) -> bool:
	for item in unit.get("inventory", []):
		if item.get("grade") == "arrows" \
				and item.get("qty", 0) >= ItemAttributes.ARROW_COST_PER_SHOT:
			return true
	return false

func _consume_arrow(unit: Dictionary) -> void:
	for item in unit.get("inventory", []):
		if item.get("grade") == "arrows":
			item["qty"] = maxi(item["qty"] - ItemAttributes.ARROW_COST_PER_SHOT, 0)
			return

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

func _sync_back_units(state: WorldState, team_id: int) -> void:
	var team: TeamData = state.teams.get(team_id)
	if team == null: return
	for unit in state.encounter_units:
		if unit["team_id"] != team_id: continue
		if unit.get("person_id", -1) != -1:
			var p: PersonData = state.persons.get(unit["person_id"])
			if p: p.equipment = unit["equipment"].duplicate(true)
		else:
			for slot in unit.get("equipment", {}):
				var s: Dictionary = unit["equipment"][slot]
				if s.get("type") == "pool" and s.get("grade", "") != "":
					team.resources[s["grade"]] = \
						int(team.resources.get(s["grade"], 0)) + 1
		for item in unit.get("inventory", []):
			if item.get("type") == "pool":
				var g: String = item.get("grade", "")
				if g != "":
					team.resources[g] = int(team.resources.get(g, 0)) + item.get("qty", 0)

func _spawn_team_units(state: WorldState, team: TeamData,
		positions: Array) -> void:
	var pos_idx: int = 0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var pos: Vector2i = positions[pos_idx % positions.size()]
		pos_idx += 1
		var unit: Dictionary = _create_named_unit(pid, team.team_id, pos, state)
		_init_named_unit(unit, p, team, state)
		state.encounter_units.append(unit)
	# 匿名人口：只 spawn 武裝部分，加硬上限
	# 未成年、俘虜不計入 spawn
	var armed_count: int = int(float(team.population) * team.armed_anon_ratio)
	var spawn_count: int = mini(armed_count, ANON_UNIT_CAP)
	for _i in range(spawn_count):
		var pos: Vector2i = positions[pos_idx % positions.size()]
		pos_idx += 1
		var unit: Dictionary = _create_anon_unit(team, pos)
		_init_anon_unit(unit, team, state)
		state.encounter_units.append(unit)
	print("[Encounter] Team%d spawn: %d具名 + %d匿名（武裝率%.0f%%，人口%d）" % [
		team.team_id, named_ids.size(), spawn_count,
		team.armed_anon_ratio * 100, team.population])

func resolve_encounter_end(state: WorldState, result: String) -> void:
	var atk_id: int = state.encounter_attacker_id
	var def_id: int = state.encounter_defender_id

	_return_pool_equipment(state)

	for team_id in [atk_id, def_id]:
		if team_id == -1: continue
		_sync_back_units(state, team_id)
		var t: TeamData = state.teams.get(team_id)
		if t: HealthSystem.resolve_negative_flags(state, t)
		HealthSystem.resolve_anon_units(state, team_id)

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
	# 新：俘虜存入 prisoner_population，上限 = winner population
	for u in state.encounter_units:
		if not u.get("is_prisoner", false): continue
		if u["team_id"] != loser_id: continue
		if winner_team == null: continue
		if winner_team.prisoner_population < winner_team.population:
			winner_team.prisoner_population += 1
			print("[Encounter] 俘虜收押 Team%d（總計 %d）" % [
				winner_id, winner_team.prisoner_population])
		else:
			print("[Encounter] 俘虜超額，釋放")

	for team_id in [atk_id, def_id]:
		var t: TeamData = state.teams.get(team_id)
		if t: t.combat_target = -1

	print("[Encounter] 遭遇戰結算完成 result=%s" % result)

	state.encounter_units.clear()
	state.encounter_active = false
	state.encounter_attacker_id = -1
	state.encounter_defender_id = -1
