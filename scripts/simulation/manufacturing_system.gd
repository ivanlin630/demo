class_name ManufacturingSystem

# TEST VALUES — 平衡期需調整
const GOODS_RATE:       float = 0.10
const CRAFT_RATE:       float = 0.20
const SMELT_RATE:       float = 0.50
const MELEE_LOW_RATE:   float = 0.05
const RANGED_LOW_RATE:  float = 0.04
const MELEE_HIGH_RATE:  float = 0.03
const RANGED_HIGH_RATE: float = 0.025
const SKILL_GROWTH: float = 0.003

func tick_all(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.current_task != TeamData.TASK_MANUFACTURE:
			continue
		var tile_id: int      = team.tile_pos.x * 1000 + team.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile == null or tile.outpost_type != "civilian" \
				or tile.manufacturing_level == 0 \
				or tile.outpost_owner != team.team_id:
			continue

		var pop_mult: float   = clampf(sqrt(float(team.population) / 5.0), 0.5, 2.0)
		var avg_skill: float  = _avg_skill(state, team, "製造")
		var worker_rate: float = float(tile.manufacturing_level) * pop_mult \
			* (0.5 + avg_skill * 0.5)

		var ran_recipe: String = _run_recipes(team, worker_rate)
		if ran_recipe != "":
			print("[Manufacture] Team%d %s worker_rate=%.2f" % [tid, ran_recipe, worker_rate])
			_grow_skills(state, team)

func _run_recipes(team: TeamData, worker_rate: float) -> String:
	var mat: float   = float(team.resources.get("material", 0))
	var gem: float   = float(team.resources.get("gem", 0))
	var iron: float  = float(team.resources.get("ore_iron", 0))
	var steel: float = float(team.resources.get("ore_steel", 0))

	# 工藝品優先（有 gem）
	if gem >= 1.0 and mat >= 4.0:
		team.resources["gem"]      = gem - 1.0
		team.resources["material"] = mat - 4.0
		team.resources["goods"]    = float(team.resources.get("goods", 0)) + worker_rate * CRAFT_RATE
		return "工藝品"

	# 高階近戰武器（steel）
	if steel >= 2.0 and mat >= 3.0:
		team.resources["ore_steel"] = steel - 2.0
		team.resources["material"]  = mat - 3.0
		team.resources["weapon_melee_high"] = float(team.resources.get("weapon_melee_high", 0)) \
			+ worker_rate * MELEE_HIGH_RATE
		return "高階近戰武器"

	# 高階遠程武器（steel）
	if steel >= 2.0 and mat >= 4.0:
		team.resources["ore_steel"] = steel - 2.0
		team.resources["material"]  = mat - 4.0
		team.resources["weapon_ranged_high"] = float(team.resources.get("weapon_ranged_high", 0)) \
			+ worker_rate * RANGED_HIGH_RATE
		return "高階遠程武器"

	# 冶煉（iron → steel）
	if iron >= 2.0 and mat >= 1.0:
		team.resources["ore_iron"]  = iron - 2.0
		team.resources["material"]  = mat - 1.0
		team.resources["ore_steel"] = float(team.resources.get("ore_steel", 0)) \
			+ worker_rate * SMELT_RATE
		return "冶煉"

	# 低階近戰武器（iron）
	if iron >= 2.0 and mat >= 3.0:
		team.resources["ore_iron"]  = iron - 2.0
		team.resources["material"]  = mat - 3.0
		team.resources["weapon_melee_low"] = float(team.resources.get("weapon_melee_low", 0)) \
			+ worker_rate * MELEE_LOW_RATE
		return "低階近戰武器"

	# 低階遠程武器（iron）
	if iron >= 2.0 and mat >= 4.0:
		team.resources["ore_iron"]  = iron - 2.0
		team.resources["material"]  = mat - 4.0
		team.resources["weapon_ranged_low"] = float(team.resources.get("weapon_ranged_low", 0)) \
			+ worker_rate * RANGED_LOW_RATE
		return "低階遠程武器"

	# 一般製造（無礦時 fallback）
	if mat >= 3.0:
		team.resources["material"] = mat - 3.0
		team.resources["goods"]    = float(team.resources.get("goods", 0)) + worker_rate * GOODS_RATE
		return "一般製造"

	return ""

func _avg_skill(state: WorldState, team: TeamData, skill: String) -> float:
	var total: float = 0.0
	var count: int   = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p = state.persons.get(pid)
		if p != null:
			total += float(p.skills.get(skill, 0.0))
			count += 1
	return total / maxf(count, 1)

func _grow_skills(state: WorldState, team: TeamData) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var intel: float = float(p.attributes.get("智力", 0.5)) * p.get_attribute_mult("智力")
		var will: float  = float(p.attributes.get("毅力", 0.5)) * p.get_attribute_mult("毅力")
		var growth: float = SKILL_GROWTH * intel * (0.5 + will * 0.5) * p.get_skill_mult("製造")
		p.skills["製造"] = minf(float(p.skills.get("製造", 0.0)) + growth, 1.0)
