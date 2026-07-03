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
const WILD_GAME_PLAINS_CHANCE: float = 0.20   # TEST VALUE — 平原帶獵物機率
const WILD_GAME_FOREST_CHANCE: float = 0.30   # TEST VALUE — 森林獵物更多
const WILD_GAME_MIN: int = 2
const WILD_GAME_MAX: int = 6
const PREDATOR_FOREST_CHANCE: float = 0.12   # TEST VALUE — 森林帶猛獸機率
const PREDATOR_MOUNTAIN_CHANCE: float = 0.15 # TEST VALUE — 山地猛獸更多
const PREDATOR_MAX: int = 2

# 產馬帶（strategic 不對稱地基：戰馬集中一「帶」而非均撒 → 中原缺馬 vs 邊地產馬）。
# resource_cap["mounts"] = 良質牧地標記（stable 直接繁育戰馬,見 OutpostSystem.produce_stable_day）。
# 另撒「一般」wild_horses(1-3,無 resource_cap)= 純 AI 建馬廄誘因訊號（faction_ai stable
# 需求偏好讀 `_nearby_resource(wild_horses)>0`）→ 驅 NPC 於帶內建 stable → breed path 有機會醒。
# 訊號量刻意 <4 = 非富點,不入 resource_cap → 不擾「野馬草原 ~3%」稀有度不變量。全 TEST VALUE。
const HORSE_BAND_HALF_WIDTH: int = 2         # 產馬帶半寬（tile_pos.x 欄）
const HORSE_BAND_DENSITY: float = 0.55       # 帶內 plains 成產馬地機率
const HORSE_BAND_CAP_MIN: int = 6            # resource_cap["mounts"] 下限
const HORSE_BAND_CAP_MAX: int = 12           # resource_cap["mounts"] 上限
const HORSE_BAND_SIGNAL_WILD_MIN: int = 1    # 帶內建廄誘因訊號 wild_horses 下限（<4 = 非富點）
const HORSE_BAND_SIGNAL_WILD_MAX: int = 3    # 上限

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
	# S1 礦脈保證：全圖無金礦 tile 時，挑一座山地注入（消小圖 RNG 槓龜，保 mint 魂有燃料）
	_ensure_min_ore(state.world.tiles, rng, "ore_gold", 5, 30, mult)
	# 產馬帶：集中一「帶」撒戰略牧地（在 per-tile rng 流之後 draw → 不擾既有 seeded 期望）
	_apply_horse_band(state.world.tiles, rng, radius, mult)

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
	# 野味（鹿/兔/豬）：平原/森林帶可獵小獵物，計入 resource_cap（月再生上限）
	match tile.terrain:
		"plains":
			if rng.randf() < WILD_GAME_PLAINS_CHANCE:
				tile.resources["wild_game"] = rng.randi_range(WILD_GAME_MIN, WILD_GAME_MAX)
		"forest":
			if rng.randf() < WILD_GAME_FOREST_CHANCE:
				tile.resources["wild_game"] = rng.randi_range(WILD_GAME_MIN, WILD_GAME_MAX)
	if int(tile.resources.get("wild_game", 0)) > 0:
		tile.resource_cap["wild_game"] = int(tile.resources["wild_game"])
	# 猛獸（熊/野豬/狼群）：森林/山地帶 predator_density，計入 resource_cap（月再生上限）
	match tile.terrain:
		"forest":
			if rng.randf() < PREDATOR_FOREST_CHANCE:
				tile.resources["predator_density"] = rng.randi_range(1, PREDATOR_MAX)
		"mountain":
			if rng.randf() < PREDATOR_MOUNTAIN_CHANCE:
				tile.resources["predator_density"] = rng.randi_range(1, PREDATOR_MAX)
	if int(tile.resources.get("predator_density", 0)) > 0:
		tile.resource_cap["predator_density"] = int(tile.resources["predator_density"])

# S1 礦脈保證：全圖無 res tile 時挑一座山地注入（消小圖 RNG 槓龜）# TEST VALUE
func _ensure_min_ore(tiles_ref: Dictionary, rng: RandomNumberGenerator, res: String, lo: int, hi: int, mult: float) -> void:
	var mountains: Array = []
	for tid in tiles_ref:
		var t = tiles_ref[tid]
		if t.terrain == "mountain": mountains.append(t)
		if float(t.resources.get(res, 0)) > 0.0: return   # 已有，不動
	if mountains.is_empty(): return   # 無山地（極端小圖）→ 跳過
	var pick = mountains[rng.randi() % mountains.size()]
	var amt: float = float(rng.randi_range(lo, hi)) * mult
	pick.resources[res] = amt
	pick.resource_cap[res] = amt

# 產馬帶：挑一條 tile_pos.x 帶（seeded），帶內 plains 依密度撒 resource_cap["mounts"] + wild_horses。
# 集中成帶 = 戰略不對稱地基（非均撒）。至少保底一格（極端 RNG 全 miss 時補一格，保 slice 有源）。
func _apply_horse_band(tiles_ref: Dictionary, rng: RandomNumberGenerator, radius: int, mult: float) -> void:
	# tile_pos.x ∈ [0, 2*radius]；帶心避開邊緣（留半寬）
	var span: int = 2 * radius
	var lo: int = mini(HORSE_BAND_HALF_WIDTH, span)
	var hi: int = maxi(span - HORSE_BAND_HALF_WIDTH, lo)
	var center: int = rng.randi_range(lo, hi)
	var seeded: Array = []
	var plains_in_band: Array = []
	for tid in tiles_ref:
		var t = tiles_ref[tid]
		if t.terrain != "plains": continue
		if absi(int(t.tile_pos.x) - center) > HORSE_BAND_HALF_WIDTH: continue
		plains_in_band.append(t)
		if rng.randf() >= HORSE_BAND_DENSITY: continue
		_seed_horse_tile(t, rng, mult)
		seeded.append(t)
	# 保底：帶內有 plains 但 RNG 全 miss → 撒一格（產馬帶必有源）
	if seeded.is_empty() and not plains_in_band.is_empty():
		_seed_horse_tile(plains_in_band[rng.randi() % plains_in_band.size()], rng, mult)

func _seed_horse_tile(t, rng: RandomNumberGenerator, mult: float) -> void:
	t.resource_cap["mounts"] = int(rng.randi_range(HORSE_BAND_CAP_MIN, HORSE_BAND_CAP_MAX) * mult)
	# 建廄誘因訊號：僅在 tile 無既有 wild_horses 時撒「一般」量（保留既有富點,不入 resource_cap）
	if int(t.resources.get("wild_horses", 0)) == 0:
		t.resources["wild_horses"] = rng.randi_range(HORSE_BAND_SIGNAL_WILD_MIN, HORSE_BAND_SIGNAL_WILD_MAX)

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
