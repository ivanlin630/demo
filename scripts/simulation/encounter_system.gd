# scripts/simulation/encounter_system.gd
class_name EncounterSystem

const ANON_UNIT_CAP: int          = 30   # TEST VALUE — 每隊匿名 unit 最多 30 個
const SPAWN_RADIUS: int           = 8    # Units spawn here; MAP_RADIUS-4 buffer to map edge
const ESCORT_DETECT_RANGE: int    = 3    # TEST VALUE — 護送感知範圍
const ESCORT_MAX_NEARBY_ENEMIES: int = 1 # TEST VALUE
const PRISONER_CHECK_INTERVAL: int = 5   # TEST VALUE — 待校正
const MESSENGER_RANGE: int        = 5    # TEST VALUE

const BASE_ACTION_TICKS: int  = 10
const BLOCK_WINDOW: int       = 8
const BLOCK_PENALTY: int      = 5
const STAMINA_REGEN_PER_TICK: float = 0.003  # TEST VALUE — 體力每 tick 恢復量

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

# Body part base HP
const BP_HP_HEAD:  float = 20.0
const BP_HP_TORSO: float = 50.0
const BP_HP_ARM:   float = 25.0
const BP_HP_LEG:   float = 30.0

# Retreat / flee thresholds
const RETREAT_TEAM_RATIO:    float = 0.7   # team ≥ this fraction incapable → retreat
const FLEE_SURVIVAL_VALUE:   float = 0.7   # 求生欲 > this → may flee individually
const FLEE_TEAM_RATIO:       float = 0.5   # team incapable ratio for individual flee check
const FLEE_CHANCE:           float = 0.3   # base flee probability

# Attack targeting
const TACTICS_LEG_AIM_MIN:   float = 0.5   # tactics skill threshold for leg targeting
const LEG_AIM_CHANCE:        float = 0.4   # prob of aiming at leg when tactics high

# Hit / block / dodge
const BASE_HIT_CHANCE:       float = 0.6
const HIT_SKILL_WEIGHT:      float = 0.4
const MIN_HIT_CHANCE:        float = 0.05
const MAX_HIT_CHANCE:        float = 0.95
const SHIELD_SKILL_BONUS:    float = 0.3
const SHIELD_BLOCK_MAX:      float = 0.90
const PARRY_SKILL_BONUS:     float = 0.4
const PARRY_MAX:             float = 0.85
const BASE_DODGE_CHANCE:     float = 0.2
const DODGE_SURVIVAL_WEIGHT: float = 0.4
const DODGE_BODY_HALF:       float = 0.5   # body weight factor inside dodge formula
const DODGE_MAX:             float = 0.80
const DODGE_STAMINA_COST:    float = 0.1
const MIN_STAMINA_TO_DODGE:  float = 0.1
const AUTO_BLOCK_MIN:        float = 0.3   # minimum threshold for auto-block selection

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
		"head":      { "hp": BP_HP_HEAD,  "max_hp": BP_HP_HEAD,  "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"torso":     { "hp": BP_HP_TORSO, "max_hp": BP_HP_TORSO, "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"right_arm": { "hp": BP_HP_ARM,   "max_hp": BP_HP_ARM,   "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"left_arm":  { "hp": BP_HP_ARM,   "max_hp": BP_HP_ARM,   "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"right_leg": { "hp": BP_HP_LEG,   "max_hp": BP_HP_LEG,   "status": "healthy",
					   "poisoned": false, "bleeding": "none", "fracture": false },
		"left_leg":  { "hp": BP_HP_LEG,   "max_hp": BP_HP_LEG,   "status": "healthy",
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
		"skills": { "戰鬥": AnonTierSystem.avg_combat_skill(team) },
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

const MAP_RADIUS: int = 12
const MAP_DIAMETER: int = MAP_RADIUS * 2   # 內切圓直徑 = 1 world-hex 的尺度

func _get_edge_entry_positions(edge: int, count: int) -> Array:
	var positions: Array = []
	var edge_hexes: Array = _get_edge_hexes(edge)
	edge_hexes.shuffle()
	for i in range(mini(count, edge_hexes.size())):
		positions.append(edge_hexes[i])
	return positions

func _get_edge_hexes(edge: int, radius: int = MAP_RADIUS) -> Array:
	var result: Array = []
	var R: int = radius
	match edge:
		0:  for x in range(0, R + 1):   result.append(Vector2i(x, -R))
		1:  for y in range(-R, 1):       result.append(Vector2i(R, y))
		2:  for x in range(0, R + 1):   result.append(Vector2i(x, R - x))
		3:  for x in range(-R, 1):      result.append(Vector2i(x, R))
		4:  for y in range(0, R + 1):   result.append(Vector2i(-R, y))
		5:  for x in range(-R, 1):      result.append(Vector2i(x, -R - x))
	return result

func _get_spawn_positions(side: int, count: int) -> Array:
	# side=0: edges 5,0,1 (upper); side=1: edges 2,3,4 (lower)
	var edges: Array = [5, 0, 1] if side == 0 else [2, 3, 4]
	var positions: Array = []
	for e in edges:
		positions += _get_edge_hexes(e, SPAWN_RADIUS)
	positions.shuffle()
	return positions.slice(0, mini(count, positions.size()))

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

	# mount loot 用：記錄戰前人口快照
	atk.encounter_initial_pop = atk.population
	def.encounter_initial_pop = def.population

	if combat_type == "pursuit":
		var center_positions: Array = [Vector2i(0,0), Vector2i(1,0),
			Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		_spawn_team_units(state, def, center_positions)
		var edges := _get_pursuit_entry_edges(state.pursuit_edge_offset)
		state.pursuit_edge_offset = (state.pursuit_edge_offset + 2) % 6
		var atk_positions: Array = []
		for e in edges:
			atk_positions += _get_edge_hexes(e, SPAWN_RADIUS)
		atk_positions.shuffle()
		_spawn_team_units(state, atk, atk_positions)
	else:
		var atk_anon: int = mini(int(float(atk.population) * atk.armed_anon_ratio), ANON_UNIT_CAP)
		var def_anon: int = mini(int(float(def.population) * def.armed_anon_ratio), ANON_UNIT_CAP)
		var total_atk: int = atk.named_members.size() + 1 + atk_anon
		var total_def: int = def.named_members.size() + 1 + def_anon
		var atk_pos: Array = _get_spawn_positions(0, total_atk)
		var def_pos: Array = _get_spawn_positions(1, total_def)
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
		if other.get("is_prisoner", false): continue   # BUG-B: prisoners don't guard
		if hex_dist(unit["pos"], other["pos"]) <= range_hex:
			count += 1
	return count

func _find_guard_target(unit: Dictionary, state: WorldState) -> int:
	# Returns index of an incapacitated enemy unit that has < 2 guards; -1 if none
	for i in range(state.encounter_units.size()):
		var candidate: Dictionary = state.encounter_units[i]
		if candidate["team_id"] == unit["team_id"]: continue
		if is_dead(candidate, state) or candidate.get("has_exited", false): continue
		if is_combat_capable(candidate, state): continue   # target must be incapacitated
		if candidate.get("is_prisoner", false): continue   # already guarded
		var guard_count: int = 0
		for other in state.encounter_units:
			if other["team_id"] != unit["team_id"]: continue
			if is_dead(other, state): continue
			if hex_dist(other["pos"], candidate["pos"]) <= 1:
				guard_count += 1
		if guard_count < 2:
			return i
	return -1

func _find_rescue_target(unit: Dictionary, state: WorldState) -> int:
	# Returns index of nearest ally prisoner with no adjacent enemies; -1 if none
	var best_idx: int = -1
	var best_d:   int = 9999
	for i in range(state.encounter_units.size()):
		var candidate: Dictionary = state.encounter_units[i]
		if not candidate.get("is_prisoner", false): continue
		if candidate["team_id"] != unit["team_id"]: continue
		if is_dead(candidate, state): continue
		if _count_nearby_enemies(candidate, state, 1) > 0: continue  # 仍被看守
		var d: int = hex_dist(unit["pos"], candidate["pos"])
		if d < best_d:
			best_d   = d
			best_idx = i
	return best_idx

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
	if team_incapable_ratio > RETREAT_TEAM_RATIO: return true
	var bp := _get_body_parts(unit, state)
	if bp.get("torso", {}).get("status") == "critical": return true
	if unit["person_id"] != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p and p.values.get("求生欲", 0.5) > FLEE_SURVIVAL_VALUE and team_incapable_ratio > FLEE_TEAM_RATIO:
			return randf() < FLEE_CHANCE
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

	# Player control: use pending_action if set, then clear it
	if unit.get("person_id", -1) == state.player_id and unit.has("pending_action"):
		var pa: Dictionary = unit["pending_action"]
		unit.erase("pending_action")
		var pa_type: String = pa.get("type", "wait")
		match pa_type:
			"attack":
				var tidx: int = pa.get("target_idx", -1)
				if tidx >= 0 and tidx < state.encounter_units.size():
					var tgt: Dictionary = state.encounter_units[tidx]
					if not is_dead(tgt, state) and not tgt.get("has_exited", false):
						return { "type": "attack", "target_idx": tidx,
							"move_to": tgt["pos"],
							"attack_part": pa.get("attack_part", _choose_attack_part(unit, state)) }
			"move":
				return { "type": "move", "target_idx": -1,
					"move_to": pa.get("move_to", unit["pos"]), "attack_part": "" }
			_:
				pass  # wait / unknown → idle
		return { "type": "idle", "target_idx": -1, "move_to": unit["pos"], "attack_part": "" }

	# Player unit with no pending_action: wait this tick
	# encounter_view will set pending_action before next advance call
	if unit.get("person_id", -1) == state.player_id:
		return { "type": "idle", "target_idx": -1, "move_to": unit["pos"], "attack_part": "" }

	if not is_combat_capable(unit, state):
		return { "type": "incapable", "target_idx": -1,
			"move_to": unit["pos"], "attack_part": "" }

	var team_ratio: float = _calc_team_incapable_ratio(unit["team_id"], state)

	# 1. 撤退
	if _should_retreat(unit, state, team_ratio):
		return { "type": "retreat", "target_idx": -1,
			"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }

	# 2. 解救俘虜（附近無敵人才優先救）
	if _count_nearby_enemies(unit, state, 2) == 0:
		var rescue_idx: int = _find_rescue_target(unit, state)
		if rescue_idx != -1:
			var rpos: Vector2i = state.encounter_units[rescue_idx]["pos"]
			return { "type": "move", "target_idx": rescue_idx,
				"move_to": _calc_next_step(unit["pos"], rpos), "attack_part": "" }

	# 3. 傳令
	if unit.get("is_messenger", false):
		return { "type": "messenger_exit", "target_idx": -1,
			"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }

	# 4. 護送
	var escort_idx: int = _should_escort(unit_idx, state)
	if escort_idx != -1 and unit.get("escort_target", -1) == -1:
		return { "type": "start_escort", "target_idx": escort_idx,
			"move_to": _calc_next_step(unit["pos"], state.encounter_units[escort_idx]["pos"]),
			"attack_part": "" }
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
		# No combat-capable enemies visible — check if we should guard an incapacitated enemy
		var guard_idx: int = _find_guard_target(unit, state)
		if guard_idx != -1:
			var guard_pos: Vector2i = state.encounter_units[guard_idx]["pos"]
			return { "type": "move", "target_idx": guard_idx,
				"move_to": _calc_next_step(unit["pos"], guard_pos), "attack_part": "" }
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
	else:
		# anon 單位：以持有遠端武器作為弓箭手判斷，技能從 unit["skills"] 讀
		var h1_grade: String = unit.get("equipment", {}).get("hand_1", {}).get("grade", "")
		if h1_grade.contains("ranged"):
			archer_skill = float(unit.get("skills", {}).get("弓箭", 0.3))
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
		"move_to": _calc_next_step(unit["pos"], target["pos"]), "attack_part": "" }

func _choose_attack_part(unit: Dictionary, state: WorldState) -> String:
	if unit["person_id"] == -1: return "torso"
	var p: PersonData = state.persons.get(unit["person_id"])
	if p == null: return "torso"
	var tactics: float = float(p.skills.get("戰術", 0.0))
	if tactics > TACTICS_LEG_AIM_MIN and randf() < LEG_AIM_CHANCE: return "right_leg"
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

func _calc_next_step(from: Vector2i, to: Vector2i) -> Vector2i:
	# Returns one axial step from `from` toward `to`
	const DIRS: Array = [
		Vector2i( 1,  0), Vector2i(-1,  0),
		Vector2i( 0,  1), Vector2i( 0, -1),
		Vector2i( 1, -1), Vector2i(-1,  1),
	]
	var best: Vector2i = from
	var best_dist: int = hex_dist(from, to)
	for d in DIRS:
		var candidate: Vector2i = from + d
		var dist: int = hex_dist(candidate, to)
		if dist < best_dist:
			best_dist = dist
			best = candidate
	return best

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
		if nearby_enemies >= 1:
			unit["is_prisoner"] = true
			var winner_team_id: int = _get_enemy_team_id(unit["team_id"], state)
			var prisoner_name: String
			if unit["person_id"] >= 0:
				var pp: PersonData = state.persons.get(unit["person_id"])
				prisoner_name = pp.person_name if pp != null else ("Person%d" % unit["person_id"])
			else:
				prisoner_name = "匿名兵(Team%d)" % unit["team_id"]
			var captor_team: TeamData = state.teams.get(winner_team_id)
			var captor_name: String
			if captor_team != null and captor_team.leader_id >= 0:
				var cp: PersonData = state.persons.get(captor_team.leader_id)
				captor_name = ("%s隊" % cp.person_name) if cp != null else ("Team%d" % winner_team_id)
			else:
				captor_name = "Team%d" % winner_team_id
			print("[Encounter] %s 被 %s 俘虜" % [prisoner_name, captor_name])

func _check_rescues(state: WorldState) -> void:
	# 隊友緊鄰且無敵人看守 → 解救俘虜
	for unit in state.encounter_units:
		if not unit.get("is_prisoner", false): continue
		if is_dead(unit, state): continue
		if _count_nearby_enemies(unit, state, 1) > 0: continue  # 仍被看守
		for other in state.encounter_units:
			if other == unit: continue
			if other["team_id"] != unit["team_id"]: continue
			if is_dead(other, state) or other.get("has_exited", false): continue
			if other.get("is_prisoner", false): continue
			if hex_dist(other["pos"], unit["pos"]) <= 1:
				unit["is_prisoner"] = false
				var pname: String
				if unit.get("person_id", -1) >= 0:
					var pp: PersonData = state.persons.get(unit["person_id"])
					pname = pp.person_name if pp != null else ("Person%d" % unit["person_id"])
				else:
					pname = "匿名兵(Team%d)" % unit["team_id"]
				print("[Encounter] %s 被隊友解救" % pname)
				break

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
	var spd: float = maxf(_effective_speed(unit, state), 0.0001)
	return clamp(roundi(float(BASE_ACTION_TICKS) / spd), 1, BASE_ACTION_TICKS * 5)

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
	return clampf(base + combat * SHIELD_SKILL_BONUS, 0.0, SHIELD_BLOCK_MAX)

func _parry_chance(unit: Dictionary, state: WorldState) -> float:
	var weapon: String = _get_weapon_grade(unit, state)
	var base: float    = ItemAttributes.get_parry_chance(weapon)
	var combat: float  = _get_skill(unit, state, "戰鬥")
	return clampf(base + combat * PARRY_SKILL_BONUS, 0.0, PARRY_MAX)

func _dodge_chance(unit: Dictionary, state: WorldState) -> float:
	var p: PersonData   = state.persons.get(unit.get("person_id", -1))
	var survival: float = _get_skill(unit, state, "求生")
	var body: float     = float(p.attributes.get("體力", 0.5)) if p else 0.5
	return clampf(BASE_DODGE_CHANCE + survival * DODGE_SURVIVAL_WEIGHT * (DODGE_BODY_HALF + body * DODGE_BODY_HALF), 0.0, DODGE_MAX)

func _resolve_block(unit: Dictionary, state: WorldState,
		choice: String) -> bool:
	match choice:
		"shield": return randf() < _shield_block_chance(unit, state)
		"parry":  return randf() < _parry_chance(unit, state)
		"dodge":
			unit["stamina"] = maxf(float(unit.get("stamina", 0.0)) - DODGE_STAMINA_COST, 0.0)
			return randf() < _dodge_chance(unit, state)
	return false

func _npc_auto_block(unit: Dictionary, state: WorldState) -> String:
	var options: Dictionary = {}
	if _has_shield(unit, state):
		options["shield"] = _shield_block_chance(unit, state)
	if _has_melee_weapon(unit, state):
		options["parry"] = _parry_chance(unit, state)
	if float(unit.get("stamina", 0.0)) > MIN_STAMINA_TO_DODGE:
		options["dodge"] = _dodge_chance(unit, state)
	var best: String = "none"; var best_val: float = AUTO_BLOCK_MIN
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
	var base: float    = BASE_HIT_CHANCE
	var skill: float   = 0.0
	if weapon.contains("ranged"):
		skill = _get_skill(attacker, state, "弓箭") * HIT_SKILL_WEIGHT
	else:
		skill = _get_skill(attacker, state, "戰鬥") * HIT_SKILL_WEIGHT
	return clampf(base + skill, MIN_HIT_CHANCE, MAX_HIT_CHANCE)

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
		unit["stamina"] = minf(float(unit.get("stamina", 1.0)) + STAMINA_REGEN_PER_TICK, 1.0)
		unit["action_timer"] -= 1
		if unit["action_timer"] > 0: continue

		# Player turn: if timer reached 0 and no pending action, stop and wait
		if unit.get("person_id", -1) == state.player_id:
			if unit.get("pending_action", {}).is_empty():
				unit["action_timer"] = 0   # keep at 0; don't go negative
				return "player_turn"
			# Has pending_action — fall through to process it

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
				var move_target: Vector2i = action["move_to"]
				# BUG-5b: boundary check
				if _is_in_map(move_target):
					# BUG-15: occupancy check (skip dead/exited units)
					var occupied: bool = false
					for other in state.encounter_units:
						if other == unit: continue
						if is_dead(other, state) or other.get("has_exited", false): continue
						if other.get("pos") == move_target:
							occupied = true; break
					if not occupied:
						unit["pos"] = move_target
				unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - stamina_cost * drain_mult, 0.0)
				if action["type"] == "start_escort":
					unit["escort_target"] = action["target_idx"]
			"retreat", "messenger_exit":
				unit["pos"]     = action["move_to"]
				unit["stamina"] = maxf(float(unit.get("stamina", 1.0)) - 0.03, 0.0)
				if hex_dist(Vector2i.ZERO, unit["pos"]) > MAP_RADIUS:
					unit["has_exited"] = true
					if action["type"] == "messenger_exit":
						var parent: TeamData = state.teams.get(unit["team_id"])
						if parent: _messenger_exit(state, unit, parent)

		# After processing player action, clear pending_action
		if unit.get("person_id", -1) == state.player_id:
			unit.erase("pending_action")
		unit["action_timer"] = _max_timer(unit, state)

	_check_prisoners(state, round_num)
	_check_rescues(state)

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
					and not u.get("is_prisoner", false) \
					and is_combat_capable(u, state):
				return true
	return false

func _all_exited(team_id: int, state: WorldState) -> bool:
	var had_units: bool = false
	for u in state.encounter_units:
		if u["team_id"] != team_id: continue
		had_units = true
		if u.get("is_prisoner", false): continue   # BUG-8: prisoners don't block all_exited
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

func _assign_anon_weapons(team: TeamData, count: int) -> Array:
	# Returns a list of weapon grade strings (or "" = unarmed) for `count` anon units.
	# Uses equip_order to determine melee/ranged split; falls back to priority order if unset.
	var queue: Array = []
	var order: Dictionary = team.equip_order
	var total_ordered: int = 0
	for v in order.values(): total_ordered += v

	if total_ordered == 0:
		# No equip_order guidance — old priority fallback (melee first)
		for _i in range(count):
			var assigned: String = ""
			for grade in ["weapon_melee_low", "weapon_melee_high",
					"weapon_ranged_low", "weapon_ranged_high"]:
				if int(team.resources.get(grade, 0)) > 0:
					assigned = grade
					team.resources[grade] = int(team.resources[grade]) - 1
					break
			queue.append(assigned)
		return queue

	# Distribute proportionally: high-grade first within each split
	for wtype in ["melee_high", "ranged_high", "melee_low", "ranged_low"]:
		var key: String = "weapon_" + wtype
		var want: int   = order.get(wtype, 0)
		var avail: int  = int(team.resources.get(key, 0))
		var give: int   = mini(mini(want, avail), count - queue.size())
		for _j in range(give):
			queue.append(key)
		team.resources[key] = int(team.resources.get(key, 0)) - give
		if queue.size() >= count: break

	# Pad with unarmed if equip_order exhausted before all slots filled
	while queue.size() < count:
		queue.append("")
	return queue

func _init_anon_unit(unit: Dictionary, team: TeamData,
		state: WorldState, assigned_weapon: String = "") -> void:
	# Weapon: use pre-assigned grade (from _assign_anon_weapons) if provided
	if assigned_weapon != "":
		unit["equipment"]["hand_1"] = { "type": "pool", "grade": assigned_weapon }
	# (If "" or not provided, unit fights unarmed — weapon was already deducted by caller)
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

func cleanup_encounter(state: WorldState) -> void:
	_return_pool_equipment(state)
	# 守恆：中止路徑（投降等）存活單位的 pool 裝備也歸還，不蒸發
	for team_id in [state.encounter_attacker_id, state.encounter_defender_id]:
		if team_id != -1:
			_sync_back_units(state, team_id)
	state.encounter_units.clear()
	state.encounter_active      = false
	state.encounter_attacker_id = -1
	state.encounter_defender_id = -1

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
		if pos_idx >= positions.size(): break   # no more spawn slots
		var pos: Vector2i = positions[pos_idx]
		pos_idx += 1
		var unit: Dictionary = _create_named_unit(pid, team.team_id, pos, state)
		_init_named_unit(unit, p, team, state)
		state.encounter_units.append(unit)
	var armed_count: int = int(float(team.population) * team.armed_anon_ratio)
	var spawn_count: int = mini(armed_count, ANON_UNIT_CAP)
	var weapon_queue: Array = _assign_anon_weapons(team, spawn_count)
	var spawned_anon: int = 0
	for _i in range(spawn_count):
		if pos_idx >= positions.size(): break   # no more spawn slots
		var pos: Vector2i = positions[pos_idx]
		pos_idx += 1
		var unit: Dictionary = _create_anon_unit(team, pos)
		_init_anon_unit(unit, team, state, weapon_queue[_i] if _i < weapon_queue.size() else "")
		state.encounter_units.append(unit)
		spawned_anon += 1
	# 守恆：spawn 位不足未上場者，已預扣武器歸還
	for j in range(spawned_anon, weapon_queue.size()):
		var grade: String = weapon_queue[j]
		if grade != "":
			team.resources[grade] = int(team.resources.get(grade, 0)) + 1
	print("[Encounter] Team%d spawn: %d具名 + %d匿名（武裝率%.0f%%，人口%d）" % [
		team.team_id, named_ids.size(), spawn_count,
		team.armed_anon_ratio * 100, team.population])

func _loot_treasury_share(_state: WorldState, loser: TeamData, winner: TeamData,
		anon_lost: int, original_anon: int) -> void:
	if loser.anon_treasury <= 0: return
	if original_anon <= 0:
		# 全給 winner
		winner.anon_treasury += loser.anon_treasury
		loser.anon_treasury = 0.0
		return
	var ratio: float = clampf(float(anon_lost) / float(original_anon), 0.0, 1.0)
	var amt: float = loser.anon_treasury * ratio
	loser.anon_treasury -= amt
	winner.anon_treasury += amt
	# 全滅補拿剩餘
	if loser.population == 0:
		winner.anon_treasury += loser.anon_treasury
		loser.anon_treasury = 0.0

# mount loot：勝方擄獲 loser_mounts × kill_ratio（kill_ratio = 陣亡/初始人口）
func apply_mount_loot(state: WorldState, winner_id: int, loser_id: int) -> void:
	if winner_id == -1 or loser_id == -1: return
	var winner: TeamData = state.teams.get(winner_id)
	var loser: TeamData = state.teams.get(loser_id)
	if winner == null or loser == null: return
	var initial: int = loser.encounter_initial_pop
	if initial <= 0: return
	var dead: int = maxi(initial - loser.population, 0)
	var kill_ratio: float = clampf(float(dead) / float(initial), 0.0, 1.0)
	var loser_mounts: int = int(loser.resources.get("mounts", 0))
	var loot: int = roundi(float(loser_mounts) * kill_ratio)
	if loot > 0:
		loser.resources["mounts"] = loser_mounts - loot
		winner.resources["mounts"] = int(winner.resources.get("mounts", 0)) + loot
		print("[Loot] Team%d → Team%d mounts +%d (kill_ratio=%.2f)" % [
			loser_id, winner_id, loot, kill_ratio])
	# horses（馴馬）同公式
	var loser_horses: int = int(loser.resources.get("horses", 0))
	var hloot: int = roundi(float(loser_horses) * kill_ratio)
	if hloot > 0:
		loser.resources["horses"] = loser_horses - hloot
		winner.resources["horses"] = int(winner.resources.get("horses", 0)) + hloot
		print("[Loot] Team%d → Team%d horses +%d (kill_ratio=%.2f)" % [
			loser_id, winner_id, hloot, kill_ratio])

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
		if t:
			AnonTierSystem.kill_random(t, dead_anon, "combat")
			t.population = maxi(t.population - dead_anon, 0)

	# BUG-10: "draw" has no winner; skip prisoner/loot logic
	if result == "draw":
		for team_id in [atk_id, def_id]:
			var t: TeamData = state.teams.get(team_id)
			if t: t.combat_target = -1
		print("[Encounter] 遭遇戰結算完成 result=%s" % result)
		# 清理 encounter state（draw 也要清，否則 encounter_active 永遠 true）
		state.encounter_units.clear()
		state.encounter_active = false
		state.encounter_attacker_id = -1
		state.encounter_defender_id = -1
		return

	var winner_id: int = atk_id if result == "attacker_win" else def_id
	var loser_id: int  = def_id if result == "attacker_win" else atk_id
	var winner_team: TeamData = state.teams.get(winner_id)
	# 戰鬥存活 exp：倖存各 tier +5，勝方額外 +5
	var loser_team_exp: TeamData = state.teams.get(loser_id)
	const EXP_SURVIVOR: float = 5.0
	const EXP_VICTORY_BONUS: float = 5.0
	for exp_tier in AnonTierSystem.TIER_ORDER:
		if exp_tier == "菁英": continue
		if winner_team != null and AnonTierSystem.tier_count(winner_team, exp_tier) > 0:
			AnonTierSystem.add_exp(winner_team, exp_tier, EXP_SURVIVOR + EXP_VICTORY_BONUS)
		if loser_team_exp != null and AnonTierSystem.tier_count(loser_team_exp, exp_tier) > 0:
			AnonTierSystem.add_exp(loser_team_exp, exp_tier, EXP_SURVIVOR)
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

	# 公庫 treasury 按 anon 損失比例 loot
	var loser_team_treasury: TeamData = state.teams.get(loser_id)
	if loser_team_treasury != null and winner_team != null:
		var original_anon: int = 0
		var anon_lost: int = 0
		for u in state.encounter_units:
			if u["team_id"] != loser_id: continue
			if u["person_id"] != -1: continue
			original_anon += 1
			if is_dead(u, state) or u.get("is_prisoner", false):
				anon_lost += 1
		_loot_treasury_share(state, loser_team_treasury, winner_team, anon_lost, original_anon)

	# mount loot：勝方依 prey 人口陣亡比例擄獲 mounts（wagons 走既有物資 loot）
	apply_mount_loot(state, winner_id, loser_id)

	print("[Encounter] 遭遇戰結算完成 result=%s" % result)

	# Build loot_pool: 30% of each resource from loser team
	var loser_team_loot: TeamData = state.teams.get(loser_id)
	var loot: Dictionary = {}
	if loser_team_loot != null:
		for rk in loser_team_loot.resources:
			var v: float = float(loser_team_loot.resources.get(rk, 0))
			if v > 0:
				loot[rk] = v * 0.3   # TEST VALUE — 30%
	# G-02：玩家勝利 → 標記 can_subjugate，讓玩家自選；NPC 勝利維持自動
	var _player_p2: PersonData = state.persons.get(state.player_id)
	var _player_tid2: int = _player_p2.team_id if _player_p2 else -1
	var is_player_winner: bool = (_player_tid2 != -1 and winner_id == _player_tid2)
	state.last_encounter_result = {
		"winner_id": winner_id,
		"loser_id":  loser_id,
		"loot_pool": loot,
		"can_subjugate": is_player_winner
	}
	print("[Encounter] 戰鬥結束 winner=Team%d loser=Team%d loot=%s" % [winner_id, loser_id, str(loot)])

	# D B1: 戰勝接管 outpost（敗方所在格據點易主）
	var loser_team_cap: TeamData = state.teams.get(loser_id)
	if loser_team_cap != null:
		var cap_tid: int = loser_team_cap.tile_pos.x * 1000 + loser_team_cap.tile_pos.y
		var cap_tile: HexTileData = state.world.tiles.get(cap_tid)
		if cap_tile != null and cap_tile.outpost_level > 0 and cap_tile.outpost_owner != winner_id:
			var old_cap_owner: int = cap_tile.outpost_owner
			cap_tile.outpost_owner = winner_id
			print("[Capture] Outpost (%d,%d) %d→%d" % [
				loser_team_cap.tile_pos.x, loser_team_cap.tile_pos.y, old_cap_owner, winner_id])

	# Prosperity: 攻方勝 → 處理被佔 outpost 上的居民團（屠/放棄/強佔）
	if result == "attacker_win":
		_process_occupied_residents(state, winner_id, loser_id)
	# Prosperity: 攻方戰敗 → reaction（loyalty 降 / leader stress 升）
	elif result == "defender_win" and atk_id != -1:
		var atk_total: int = 0
		var atk_dead: int = 0
		for u in state.encounter_units:
			if u["team_id"] != atk_id: continue
			atk_total += 1
			if is_dead(u, state) or u.get("is_prisoner", false): atk_dead += 1
		var ratio: float = float(atk_dead) / maxf(float(atk_total), 1.0)
		ReactionSystem.new().on_attack_defeat(state, atk_id, ratio)

	state.encounter_units.clear()
	state.encounter_active = false
	state.encounter_attacker_id = -1
	state.encounter_defender_id = -1

# ──────── Prosperity: 攻佔 outpost 居民處置 ────────

func _find_prey_outpost(state: WorldState, prey: TeamData) -> HexTileData:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level > 0 and tile.outpost_owner == prey.team_id:
			return tile
	return null

func _find_resident_team_on_tile(state: WorldState, tile: HexTileData,
		exclude_a: int, exclude_b: int) -> TeamData:
	for tid in state.teams:
		if tid == exclude_a or tid == exclude_b: continue
		var t: TeamData = state.teams[tid]
		if t.population <= 0: continue
		if t.tile_pos == tile.tile_pos:
			return t
	return null

func _process_occupied_residents(state: WorldState, attacker_id: int, prey_id: int) -> void:
	var attacker: TeamData = state.teams.get(attacker_id)
	var prey: TeamData = state.teams.get(prey_id)
	if attacker == null or prey == null: return
	var occupied_tile: HexTileData = _find_prey_outpost(state, prey)
	if occupied_tile == null: return
	var resident: TeamData = _find_resident_team_on_tile(state, occupied_tile, attacker_id, prey_id)
	if resident == null: return
	# 居民拒投靠判定
	var rep: float = float(resident.known_reputations.get(attacker_id, 0.5))
	var resident_leader: PersonData = state.persons.get(resident.leader_id)
	var fear: float = clampf(1.0 - rep, 0.0, 1.0)
	var caution: float = float(resident_leader.values.get("慎重", 0.5)) if resident_leader else 0.5
	var accept: bool = (fear > caution + 0.2) and rep > 0.3
	if accept:
		occupied_tile.outpost_owner = attacker_id
		print("[ResidentAccept] attacker=Team%d resident=Team%d outpost易主" % [attacker_id, resident.team_id])
		return
	# 攻城方 leader 個性決定
	var atk_leader: PersonData = state.persons.get(attacker.leader_id)
	if atk_leader == null:
		_abandon_occupation(state, occupied_tile)
		return
	var cruelty: float = float(atk_leader.values.get("殘忍", 0.5))
	var martial: float = float(atk_leader.values.get("好戰", 0.5))
	var honor: float = float(atk_leader.values.get("義氣", 0.5))
	var faith: float = float(atk_leader.values.get("信義", 0.5))
	var ambition: float = float(atk_leader.values.get("野心", 0.5))
	var caution2: float = float(atk_leader.values.get("慎重", 0.5))
	if cruelty > 0.7 or martial > 0.7:
		_massacre_residents(state, attacker, resident, occupied_tile)
	elif honor > 0.6 or faith > 0.6:
		_abandon_occupation(state, occupied_tile)
	elif ambition > 0.7 and caution2 > 0.5:
		_force_occupy(state, attacker, resident, occupied_tile)
	else:
		_abandon_occupation(state, occupied_tile)

func _massacre_residents(state: WorldState, attacker: TeamData, resident: TeamData,
		tile: HexTileData) -> void:
	tile.outpost_owner = attacker.team_id
	for k in resident.resources:
		attacker.resources[k] = attacker.resources.get(k, 0) + resident.resources[k]
	attacker.anon_treasury += resident.population * 5.0
	var rid: int = resident.team_id
	state.teams.erase(rid)
	print("[Massacre] attacker=Team%d resident=Team%d 屠村，outpost空殼易主" % [attacker.team_id, rid])

func _abandon_occupation(state: WorldState, tile: HexTileData) -> void:
	print("[AbandonOccupation] outpost (%d,%d) 放棄佔領" % [tile.tile_pos.x, tile.tile_pos.y])

func _force_occupy(state: WorldState, attacker: TeamData, resident: TeamData,
		tile: HexTileData) -> void:
	tile.outpost_owner = attacker.team_id
	resident.population = int(float(resident.population) * 0.8)
	print("[ForceOccupy] attacker=Team%d resident=Team%d 強佔 pop-20%%" % [attacker.team_id, resident.team_id])
