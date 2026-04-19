extends Node
# Autoloaded as the "GameConfig" singleton.
# Edit these values directly here, or change them at runtime before world generation.

# ── World generation ──────────────────────────────────────────────────────────
var seed_value:    int = 12345
var map_width:     int = 128
var map_height:    int = 128
var faction_count: int = 4

# ── Terrain enum ──────────────────────────────────────────────────────────────
enum Terrain { WATER = 0, GRASSLAND = 1, FOREST = 2, MOUNTAIN = 3 }

# ── Terrain display colours ───────────────────────────────────────────────────
const TERRAIN_COLORS: Dictionary = {
	0: Color(0.18, 0.38, 0.78),  # WATER      – blue
	1: Color(0.45, 0.78, 0.28),  # GRASSLAND  – light green
	2: Color(0.10, 0.45, 0.15),  # FOREST     – dark green
	3: Color(0.58, 0.58, 0.58),  # MOUNTAIN   – grey
}

# ── Resource yields per owned cell per turn ───────────────────────────────────
const TERRAIN_FOOD_YIELD: Dictionary = {0: 0.0, 1: 2.0, 2: 0.5, 3: 0.0}
const TERRAIN_WOOD_YIELD: Dictionary = {0: 0.0, 1: 0.5, 2: 3.0, 3: 0.2}
const TERRAIN_ORE_YIELD:  Dictionary = {0: 0.0, 1: 0.0, 2: 0.2, 3: 3.0}

# ── Faction initial-stat ranges ───────────────────────────────────────────────
const INIT_POP_MIN:  int = 50
const INIT_POP_MAX:  int = 150
const INIT_FOOD_MIN: int = 100
const INIT_FOOD_MAX: int = 300
const INIT_MIL_MIN:  int = 10
const INIT_MIL_MAX:  int = 50

# ── Simulation parameters ─────────────────────────────────────────────────────
const FOOD_PER_PERSON:    float = 0.5
const GROWTH_RATE:        float = 0.03
const STARVATION_RATE:    float = 0.08
const EXPAND_MIL_COST:    float = 2.0
const CONFLICT_CHANCE:    float = 0.25
const CONFLICT_MIL_RATIO: float = 0.4
const CONFLICT_MIN_MIL:   float = 5.0

# ── Message propagation ───────────────────────────────────────────────────────
const MSG_DECAY_PER_TURN: float = 0.12
const MSG_DECAY_PER_CELL: float = 0.06
const MSG_MIN_STRENGTH:   float = 0.10
const MSG_SPREAD_RADIUS:  int   = 12
