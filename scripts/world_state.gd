class_name WorldState
extends RefCounted
## Central data container for the whole simulation.
## All inner classes are plain data objects with no logic.

# ── Inner data classes ────────────────────────────────────────────────────────

class CellData:
	var terrain:   int   = 0    # GameConfig.Terrain value
	var food_res:  float = 0.0
	var wood_res:  float = 0.0
	var ore_res:   float = 0.0
	var faction_id: int  = -1   # -1 = unclaimed

class FactionData:
	var id:          int     = 0
	var name:        String  = ""
	var color:       Color   = Color.WHITE
	var population:  float   = 100.0
	var food:        float   = 200.0
	var wood:        float   = 50.0
	var ore:         float   = 20.0
	var military:    float   = 20.0
	var outpost_pos: Vector2i = Vector2i.ZERO
	var territory:       Array = []   # Array[Vector2i] of owned cell positions
	var known_messages:  Array = []   # Array[MessageSystem.MessageData]

	func _init() -> void:
		territory      = []
		known_messages = []

class OutpostData:
	var pos:             Vector2i = Vector2i.ZERO
	var faction_id:      int      = -1
	var known_messages:  Array    = []   # Array[MessageSystem.MessageData]

	func _init() -> void:
		known_messages = []

# ── World fields ──────────────────────────────────────────────────────────────

## Flat grid: index = y * map_width + x
var cells:           Array = []
var factions:        Array = []   # Array[FactionData]
var outposts:        Array = []   # Array[OutpostData]
var global_messages: Array = []   # every message ever emitted
var current_turn:    int   = 0
var map_width:       int   = 128
var map_height:      int   = 128
var seed_value:      int   = 0

func _init(w: int, h: int, s: int) -> void:
	map_width  = w
	map_height = h
	seed_value = s
	cells.resize(w * h)

# ── Accessors ─────────────────────────────────────────────────────────────────

func get_cell(x: int, y: int) -> CellData:
	if x < 0 or x >= map_width or y < 0 or y >= map_height:
		return null
	return cells[y * map_width + x]

func set_cell(x: int, y: int, cell: CellData) -> void:
	if x < 0 or x >= map_width or y < 0 or y >= map_height:
		return
	cells[y * map_width + x] = cell

func is_valid_pos(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < map_width and pos.y >= 0 and pos.y < map_height

func get_faction(id: int) -> FactionData:
	for f in factions:
		if (f as FactionData).id == id:
			return f as FactionData
	return null

func get_outpost_at(pos: Vector2i) -> OutpostData:
	for o in outposts:
		if (o as OutpostData).pos == pos:
			return o as OutpostData
	return null
