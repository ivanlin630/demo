class_name TeamData

var team_id: int = 0
var leader_id: int = -1
var advisors: Array = []
var members: Array = []
var population: int = 1
var minor_population: int = 0
var resources: Dictionary = { "food": 0, "material": 0, "weapon": 0, "money": 0, "goods": 0 }
var move_speed: float = 1.0
var tags: Array = []
var current_task: String = "idle"
var unrest_turns: int = 0
var faction_id: int = -1
var tile_pos: Vector2i = Vector2i.ZERO
var move_target: Vector2i = Vector2i(-1, -1)  # -1,-1 = 無目標，不移動
var move_tick_acc: int = 0
var combat_target: int = -1
var readiness: float   = 1.0
var wounded: int       = 0
