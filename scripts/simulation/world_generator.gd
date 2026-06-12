const TERRAIN_WEIGHTS: Dictionary = { "plains": 50, "forest": 30, "mountain": 20 }

const RESOURCE_PROFILE: Dictionary = {
	"plains":   { "food": [100, 300], "material": [5,  20]  },   # 農業為主
	"forest":   { "food": [20,   80], "material": [80, 220] },   # 木材為主
	"mountain": { "food": [5,    20], "material": [30, 100] },   # 礦產為主
}

const PRODUCTIVITY_RANGE: Dictionary = {
	"plains":   [0.9, 1.3],
	"forest":   [0.7, 1.1],
	"mountain": [0.5, 0.9],
}

const ORE_GOLD_CHANCE:   float = 0.12
const ORE_SILVER_CHANCE: float = 0.25
const GEM_CHANCE:        float = 0.05
const ORE_IRON_MOUNTAIN_CHANCE: float = 0.30
const ORE_IRON_PLAINS_CHANCE:   float = 0.05
const WILD_HORSE_PLAINS_CHANCE: float = 0.01
const WILD_HORSE_FOREST_CHANCE: float = 0.005
const HERB_FOREST_CHANCE: float = 0.30      # TEST VALUE
const HERB_RICH_CHANCE: float = 0.05        # 藥草林（先 roll rich 再 roll 一般）TEST VALUE
const WILD_HORSE_RICH_CHANCE: float = 0.03  # 野馬草原 TEST VALUE

func generate(state: WorldState, config: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	if config.get("seed", -1) == -1:
		rng.randomize()
	else:
		rng.seed = int(config.get("seed", 0))
	var radius: int = config.get("radius", 4)
	var mult: float = float(config.get("resource_multiplier", 1.0))
	for qx in range(-radius, radius + 1):
		for ry in range(-radius, radius + 1):
			if _hex_dist(Vector2i(qx, ry), Vector2i.ZERO) > radius:
				continue
			var ox: int = qx + radius
			var oy: int = ry + radius
			var tile = load("res://scripts/data/tile_data.gd").new()
			tile.tile_id  = ox * 1000 + oy
			tile.tile_pos = Vector2i(ox, oy)
			tile.terrain  = _random_terrain(rng)
			_apply_resources(tile, rng, mult)
			state.world.tiles[tile.tile_id] = tile

func _apply_resources(tile, rng: RandomNumberGenerator, mult: float = 1.0) -> void:
	tile.resources = {}
	var profile: Dictionary = RESOURCE_PROFILE[tile.terrain]
	for res in profile:
		var r: Array = profile[res]
		tile.resources[res] = int(rng.randi_range(r[0], r[1]) * mult)
	var prod_r: Array = PRODUCTIVITY_RANGE[tile.terrain]
	tile.productivity = rng.randf_range(prod_r[0], prod_r[1])
	if tile.terrain == "mountain":
		if rng.randf() < ORE_GOLD_CHANCE:
			tile.resources["ore_gold"] = int(rng.randi_range(5, 30) * mult)
		elif rng.randf() < ORE_SILVER_CHANCE:
			tile.resources["ore_silver"] = int(rng.randi_range(10, 60) * mult)
		if rng.randf() < GEM_CHANCE:
			tile.resources["gem"] = int(rng.randi_range(1, 8) * mult)
		if rng.randf() < ORE_IRON_MOUNTAIN_CHANCE:
			tile.resources["ore_iron"] = int(rng.randi_range(50, 150) * mult)
	elif tile.terrain == "plains":
		if rng.randf() < ORE_IRON_PLAINS_CHANCE:
			tile.resources["ore_iron"] = int(rng.randi_range(20, 60) * mult)
	# herb：森林 30% 帶 2-6；藥草林（高產點）5% 帶 10-20。計入 resource_cap（月再生上限 = 初始值）
	if tile.terrain == "forest":
		if rng.randf() < HERB_RICH_CHANCE:
			tile.resources["herb"] = rng.randi_range(10, 20)
		elif rng.randf() < HERB_FOREST_CHANCE:
			tile.resources["herb"] = rng.randi_range(2, 6)
	tile.resource_cap = tile.resources.duplicate()
	# 野馬：平原 1% 1-2 隻 / 森林 0.5% 1 隻（活物不被 generic collect 採集，再生由 HarvestSystem 處理）
	# 野馬草原（高產點）：平原 3% 帶 4-8，resource_cap["wild_horses"]=8 標記富點（僅供再生 cap 判定）
	match tile.terrain:
		"plains":
			if rng.randf() < WILD_HORSE_RICH_CHANCE:
				tile.resources["wild_horses"] = rng.randi_range(4, 8)
				tile.resource_cap["wild_horses"] = 8
			elif rng.randf() < WILD_HORSE_PLAINS_CHANCE:
				tile.resources["wild_horses"] = rng.randi_range(1, 2)
		"forest":
			if rng.randf() < WILD_HORSE_FOREST_CHANCE:
				tile.resources["wild_horses"] = 1

func _random_terrain(rng: RandomNumberGenerator) -> String:
	var roll: int = rng.randi_range(0, 99)
	var acc: int = 0
	for t in TERRAIN_WEIGHTS:
		acc += TERRAIN_WEIGHTS[t]
		if roll < acc:
			return t
	return "plains"

func pick_start_positions(state: WorldState, n: int, min_sep: int) -> Array:
	var chosen: Array = []
	for tid in state.world.tiles:
		var tile = state.world.tiles[tid]
		var pos := Vector2i(tid / 1000, tid % 1000)
		var ok := true
		for c in chosen:
			if _hex_dist(pos, c) < min_sep:
				ok = false
				break
		if ok:
			chosen.append(pos)
		if chosen.size() >= n:
			break
	return chosen

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
