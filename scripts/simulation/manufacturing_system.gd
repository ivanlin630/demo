class_name ManufacturingSystem

# TEST VALUES — 平衡期需調整
const GOODS_RATE:       float = 0.10
const CRAFT_RATE:       float = 0.20
const TOOLS_RATE:       float = 0.10
const ARROWS_RATE:      float = 0.10
const SMELT_RATE:       float = 0.50
const MELEE_LOW_RATE:   float = 0.05
const RANGED_LOW_RATE:  float = 0.04
const MELEE_HIGH_RATE:  float = 0.03
const RANGED_HIGH_RATE: float = 0.025
const ARMOR_LOW_RATE:   float = 0.05
const ARMOR_HIGH_RATE:  float = 0.03
const WAGON_RATE:       float = 0.05
const MEDICINE_RATE:    float = 0.10
const SKILL_GROWTH: float = 0.003

const RATES: Dictionary = {
	"GOODS_RATE": GOODS_RATE, "CRAFT_RATE": CRAFT_RATE,
	"TOOLS_RATE": TOOLS_RATE, "ARROWS_RATE": ARROWS_RATE,
	"SMELT_RATE": SMELT_RATE,
	"MELEE_LOW_RATE": MELEE_LOW_RATE, "RANGED_LOW_RATE": RANGED_LOW_RATE,
	"MELEE_HIGH_RATE": MELEE_HIGH_RATE, "RANGED_HIGH_RATE": RANGED_HIGH_RATE,
	"ARMOR_LOW_RATE": ARMOR_LOW_RATE, "ARMOR_HIGH_RATE": ARMOR_HIGH_RATE,
	"WAGON_RATE": WAGON_RATE, "MEDICINE_RATE": MEDICINE_RATE,
}

# 缺口排序用 target（stock / (target × pop) 最低者先做）；缺項 fallback 1.0
const TARGET_PER_POP: Dictionary = {
	"goods": 3.0, "tools": 0.5, "arrows": 2.0,
	"ore_steel": 1.5,
	"weapon_melee_low": 1.0, "weapon_ranged_low": 0.8,
	"weapon_melee_high": 0.5, "weapon_ranged_high": 0.4,
	"armor_low": 0.3, "armor_high": 0.15,
	"wagons": 0.2, "medicine": 1.0, "horses": 0.5,
}

# 4 配方組：各設施只跑自己組；組內依缺口排序，原料不足跳下一個。
# in = 每單位成品原料（per-unit）；實際扣帳 = in × 本 tick 產量 q。
# tools/arrows 純可再生原料（建造鏈守恆）。
const RECIPE_GROUPS: Dictionary = {
	"manufacturing_level": [   # 工坊
		{ "out": "goods",  "rate_const": "GOODS_RATE",  "in": { "material": 3.0 } },
		{ "out": "tools",  "rate_const": "TOOLS_RATE",  "in": { "material": 4.0 } },
		{ "out": "arrows", "rate_const": "ARROWS_RATE", "in": { "material": 0.8 } },
		{ "out": "goods",  "rate_const": "CRAFT_RATE",  "in": { "gem": 0.25, "material": 1.0 } },  # 工藝品 = gem 觸媒高效路線
		# 馬車：horses 來源 = 居民團自有（採集/交易）；公庫 horses 供軍用訓練
		{ "out": "wagons", "rate_const": "WAGON_RATE", "in": { "horses": 1.0, "material": 6.0, "tools": 1.0 } },
	],
	"apothecary_level": [   # 藥坊
		{ "out": "medicine", "rate_const": "MEDICINE_RATE", "in": { "herb": 2.0 } },
	],
	"smelter_level": [
		{ "out": "ore_steel", "rate_const": "SMELT_RATE", "in": { "ore_iron": 2.0, "material": 1.0 } },
	],
	"weaponsmith_level": [
		{ "out": "weapon_melee_low",   "rate_const": "MELEE_LOW_RATE",   "in": { "ore_iron": 2.0, "material": 3.0 } },
		{ "out": "weapon_ranged_low",  "rate_const": "RANGED_LOW_RATE",  "in": { "ore_iron": 2.0, "material": 4.0 } },
		{ "out": "weapon_melee_high",  "rate_const": "MELEE_HIGH_RATE",  "in": { "ore_steel": 2.0, "material": 3.0 } },
		{ "out": "weapon_ranged_high", "rate_const": "RANGED_HIGH_RATE", "in": { "ore_steel": 2.0, "material": 4.0 } },
	],
	"armorsmith_level": [
		{ "out": "armor_low",  "rate_const": "ARMOR_LOW_RATE",  "in": { "ore_iron": 2.0, "material": 2.0 } },
		{ "out": "armor_high", "rate_const": "ARMOR_HIGH_RATE", "in": { "ore_steel": 2.0, "material": 3.0 } },
	],
}

func tick_all(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.current_task != TeamData.TASK_MANUFACTURE:
			continue
		var tile_id: int      = team.tile_pos.x * 1000 + team.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile == null or tile.outpost_level == 0:
			continue
		if not _team_works_tile(state, team, tile):
			continue
		# 生產人力 gate：tile 上有居民團（PRODUCE tag）才生產
		if not OutpostSystem.new()._has_resident_on_tile(state, tile):
			continue

		var pop_mult: float   = clampf(sqrt(float(team.population) / 5.0), 0.5, 2.0)
		var avg_skill: float  = _avg_skill(state, team, "製造")

		var ran_any: bool = false
		for level_key in RECIPE_GROUPS:
			var level: int = int(tile.get(level_key))
			if level <= 0:
				continue
			var worker_rate: float = float(level) * pop_mult * (0.5 + avg_skill * 0.5)
			var ran_recipe: String = _run_recipe_group(state, team, tile, level_key, worker_rate)
			if ran_recipe != "":
				ran_any = true
				print("[Manufacture] Team%d %s worker_rate=%.2f" % [tid, ran_recipe, worker_rate])
		if ran_any:
			_grow_skills(state, team)

# 生產權：owner 本人或同 faction（軍屯/派駐居民團代工）
func _team_works_tile(state: WorldState, team: TeamData, tile: HexTileData) -> bool:
	if tile.outpost_owner == team.team_id:
		return true
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null:
		return false
	var allowed: bool = owner.faction_id == team.faction_id and team.faction_id != -1
	# Task1 A 探針：同 faction 代工放行（治權隨旗後村民代 owner 生產＝收益鏈點火）
	if allowed and Probe.enabled:
		Probe.bump("yield.works_tile_pass")
	return allowed

# 成品流向公庫（tile 為自家 outpost）；無 outpost fallback 進 team
func _add_output(team: TeamData, tile: HexTileData, res: String, amt: float) -> void:
	if tile != null and tile.outpost_level > 0:
		TileBank.deposit(tile, res, amt, "manufacture_output")   # capped add，溢出 drop = sink
	else:
		ResourceBank.add(team, res, amt, "manufacture_output")

# 組內排序：①命中自隊收到買單(需求驅動)優先 ②其次缺口 stock/(TARGET×pop) 最低者；
# 原料不足跳下一個；每設施每 tick 跑一條配方。回傳配方名（"" = 無可跑）。
func _run_recipe_group(state: WorldState, team: TeamData, tile: HexTileData, level_key: String,
		worker_rate: float) -> String:
	var recipes: Array = RECIPE_GROUPS[level_key]
	# 自隊收到的買單需求集（訂單真 reader → 非 dormant；殘缺/失真副本）
	var demand: Dictionary = {}
	for bo in OrderSystem.new().received_buy_orders(state, team):
		demand[bo["res"]] = true
	var order: Array = []
	for i in range(recipes.size()):
		var out: String = recipes[i]["out"]
		var stock: float = float(team.resources.get(out, 0)) \
			+ float(tile.public_storage.get(out, 0))
		var target: float = float(TARGET_PER_POP.get(out, 1.0)) * float(maxi(team.population, 1))
		order.append({ "idx": i, "ratio": stock / maxf(target, 0.001), "demand": demand.has(out) })
	# 需求命中優先（demand=true 排前），其次缺口比最低先
	order.sort_custom(func(a, b):
		if a.demand != b.demand:
			return a.demand
		return a.ratio < b.ratio)
	for entry in order:
		var recipe: Dictionary = recipes[entry.idx]
		var rate: float = float(RATES[recipe["rate_const"]])
		var q: float = worker_rate * rate          # 本 tick 產量
		if q <= 0.0:
			continue
		if not _can_consume_scaled(team, recipe["in"], q):
			continue
		for res in recipe["in"]:
			ResourceBank.add(team, res, -(float(recipe["in"][res]) * q), "manufacture_input")     # 投入隨產量縮放（in = 每單位成品原料）；原無 clamp 保可負
		_add_output(team, tile, recipe["out"], q)
		return recipe["out"]
	return ""

func _can_consume_scaled(team: TeamData, inputs: Dictionary, q: float) -> bool:
	for res in inputs:
		if float(team.resources.get(res, 0)) < float(inputs[res]) * q:
			return false
	return true

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
		SkillSystem.cap_add(p, "製造", growth)
