class_name VisionSystem

const VISION_RADIUS: int  = 3    # TEST VALUE
const SCOUT_BONUS: float  = 2.0  # TEST VALUE — 偵查=1.0 最多 +2 hex

const TERRAIN_VISION_MULT: Dictionary   = { "plains": 1.0, "forest": 0.6, "mountain": 0.8 }
const TERRAIN_EXPOSURE_MULT: Dictionary = { "plains": 1.0, "forest": 0.5, "mountain": 0.7 }

func tick_discovery(state: WorldState, team_ids: Array,
		time_vision_mult: float = 1.0) -> void:
	for tid in team_ids:
		if not state.team_discovered.has(tid):
			state.team_discovered[tid] = []
		var obs: TeamData = state.teams[tid]
		var scout: float  = _avg_skill(state, obs, "偵查")
		var obs_tile      = _get_tile(state, obs.tile_pos)
		var obs_terrain   = obs_tile.terrain if obs_tile else "plains"
		var vmult: float  = float(TERRAIN_VISION_MULT.get(obs_terrain, 1.0))
		var vrange: int   = roundi((VISION_RADIUS + scout * SCOUT_BONUS) * vmult * time_vision_mult)
		for other_id in state.teams:
			if other_id == tid: continue
			var other: TeamData = state.teams[other_id]
			var dist: int = _hex_dist(obs.tile_pos, other.tile_pos)
			if dist > vrange: continue
			var exposure: float = _get_exposure(state, other)
			var dist_f: float   = 1.0 - (float(dist) / float(vrange + 1)) * 0.5  # TEST VALUE
			var eff_exp: float  = exposure * dist_f
			if _can_detect(scout, eff_exp):
				var is_new: bool = not state.team_discovered[tid].has(other_id)
				_mark(state, tid, other_id)
				_write_tier01(state, tid, other_id, other, dist, dist_f)
				if is_new:
					_grow_skill(state, obs, "偵查", "智力", "體力")
			else:
				_grow_skill(state, other, "潛行", "體力", "毅力")

func reveal_encounter(state: WorldState, id_a: int, id_b: int) -> void:
	_mark(state, id_a, id_b)
	_mark(state, id_b, id_a)

func _can_detect(scout: float, eff_exposure: float) -> bool:
	return eff_exposure + scout * 0.3 > 0.3

func _get_exposure(state: WorldState, team: TeamData) -> float:
	var base: float    = clampf(0.2 + team.population * 0.04, 0.2, 0.9)  # TEST VALUE
	var stealth: float = _avg_skill(state, team, "潛行")
	var tgt_tile       = _get_tile(state, team.tile_pos)
	var terrain: String = tgt_tile.terrain if tgt_tile else "plains"
	var emult: float   = float(TERRAIN_EXPOSURE_MULT.get(terrain, 1.0))
	return base * (1.0 - stealth * 0.6) * emult

func _get_tile(state: WorldState, pos: Vector2i):
	return state.world.tiles.get(pos.x * 1000 + pos.y)

func _avg_skill(state: WorldState, team: TeamData, skill: String) -> float:
	var total: float = 0.0; var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: total += float(p.skills.get(skill, 0.0)); count += 1
	return total / maxf(float(count), 1.0)

func _grow_skill(state: WorldState, team: TeamData,
		skill: String, attr1: String, attr2: String) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var a1: float = float(p.attributes.get(attr1, 0.5)) * p.get_attribute_mult(attr1)
		var a2: float = float(p.attributes.get(attr2, 0.5)) * p.get_attribute_mult(attr2)
		var growth: float = 0.001 * a1 * (0.5 + a2 * 0.5) * p.get_skill_mult(skill)  # TEST VALUE
		SkillSystem.cap_add(p, skill, growth)

func _mark(state: WorldState, obs_id: int, tgt_id: int) -> void:
	if not state.team_discovered.has(obs_id):
		state.team_discovered[obs_id] = []
	if not state.team_discovered[obs_id].has(tgt_id):
		state.team_discovered[obs_id].append(tgt_id)

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _write_tier01(state: WorldState, obs_id: int, tgt_id: int,
		tgt: TeamData, dist: int, dist_f: float) -> void:
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var noise: float = 1.0 - dist_f  # TEST VALUE
	var pop_est: int = maxi(1, roundi(
		tgt.population * randf_range(1.0 - noise, 1.0 + noise)))
	var snap: Dictionary = state.team_intel[obs_id].get(tgt_id, {}).duplicate()
	snap["population_est"] = pop_est
	snap["tile_pos"]       = tgt.tile_pos
	snap["last_tick"]      = state.world.current_tick
	if not snap.has("tier"):
		snap["tier"] = 0
	if dist <= 1:
		if int(snap["tier"]) < 1:
			snap["tier"] = 1
		var total_res: float = 0.0
		for rk in tgt.resources:
			total_res += float(tgt.resources[rk])
		var scale: int = 0
		if   total_res >= 600.0: scale = 3
		elif total_res >= 200.0: scale = 2
		elif total_res >= 50.0:  scale = 1
		scale = clampi(scale + randi_range(-1, 1), 0, 3)
		snap["resource_scale"] = scale
	state.team_intel[obs_id][tgt_id] = snap
