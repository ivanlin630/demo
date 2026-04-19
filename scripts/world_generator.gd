class_name WorldGenerator
extends RefCounted
## Generates the initial WorldState from GameConfig settings.

const _FACTION_NAMES:  Array = ["鐵狼族", "金獅族", "銀鷹族", "石熊族", "赤狐族"]
const _FACTION_COLORS: Array = [
	Color(0.90, 0.20, 0.20),   # red
	Color(0.95, 0.80, 0.10),   # gold
	Color(0.25, 0.75, 1.00),   # sky-blue
	Color(0.95, 0.55, 0.10),   # orange
	Color(0.80, 0.20, 0.80),   # magenta
]

var _noise: FastNoiseLite

func _init() -> void:
	_noise              = FastNoiseLite.new()
	_noise.noise_type   = FastNoiseLite.TYPE_PERLIN
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM

## Generate and return a fully initialised WorldState.
func generate() -> WorldState:
	var state := WorldState.new(
		GameConfig.map_width, GameConfig.map_height, GameConfig.seed_value
	)
	_noise.seed      = GameConfig.seed_value
	_noise.frequency = 0.03
	_generate_terrain(state)
	_place_factions(state)
	return state

# ── Terrain generation ────────────────────────────────────────────────────────

func _generate_terrain(state: WorldState) -> void:
	for y in range(state.map_height):
		for x in range(state.map_width):
			var cell     := WorldState.CellData.new()
			var h: float  = _noise.get_noise_2d(float(x), float(y))

			if   h < -0.20: cell.terrain = GameConfig.Terrain.WATER
			elif h <  0.10: cell.terrain = GameConfig.Terrain.GRASSLAND
			elif h <  0.35: cell.terrain = GameConfig.Terrain.FOREST
			else:           cell.terrain = GameConfig.Terrain.MOUNTAIN

			cell.food_res = GameConfig.TERRAIN_FOOD_YIELD[cell.terrain]
			cell.wood_res = GameConfig.TERRAIN_WOOD_YIELD[cell.terrain]
			cell.ore_res  = GameConfig.TERRAIN_ORE_YIELD [cell.terrain]
			state.set_cell(x, y, cell)

# ── Faction placement ─────────────────────────────────────────────────────────

func _place_factions(state: WorldState) -> void:
	var rng        := RandomNumberGenerator.new()
	rng.seed        = state.seed_value + 9999
	var placed     := 0
	var attempts   := 0
	const MAX_ATT  := 2000
	const MIN_DIST := 25.0

	while placed < GameConfig.faction_count and attempts < MAX_ATT:
		attempts += 1
		var rx: int = rng.randi_range(8, state.map_width  - 8)
		var ry: int = rng.randi_range(8, state.map_height - 8)

		var cell := state.get_cell(rx, ry)
		if cell == null:
			continue
		if cell.terrain == GameConfig.Terrain.WATER \
				or cell.terrain == GameConfig.Terrain.MOUNTAIN:
			continue

		# Enforce minimum spacing between faction outposts
		var too_close := false
		for existing in state.factions:
			var f := existing as WorldState.FactionData
			if Vector2(rx, ry).distance_to(Vector2(f.outpost_pos)) < MIN_DIST:
				too_close = true
				break
		if too_close:
			continue

		# Build FactionData
		var f             := WorldState.FactionData.new()
		f.id               = placed
		f.name             = _FACTION_NAMES [placed]
		f.color            = _FACTION_COLORS[placed]
		f.population       = rng.randi_range(GameConfig.INIT_POP_MIN,  GameConfig.INIT_POP_MAX)
		f.food             = rng.randi_range(GameConfig.INIT_FOOD_MIN, GameConfig.INIT_FOOD_MAX)
		f.wood             = 50.0
		f.ore              = 20.0
		f.military         = rng.randi_range(GameConfig.INIT_MIL_MIN,  GameConfig.INIT_MIL_MAX)
		f.outpost_pos      = Vector2i(rx, ry)

		# Claim a 3×3 initial territory
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var cx: int = rx + dx
				var cy: int = ry + dy
				if not state.is_valid_pos(Vector2i(cx, cy)):
					continue
				var tc := state.get_cell(cx, cy)
				if tc == null:
					continue
				tc.faction_id = f.id
				f.territory.append(Vector2i(cx, cy))

		state.factions.append(f)

		# Build OutpostData
		var o    := WorldState.OutpostData.new()
		o.pos     = Vector2i(rx, ry)
		o.faction_id = f.id
		state.outposts.append(o)

		placed += 1
