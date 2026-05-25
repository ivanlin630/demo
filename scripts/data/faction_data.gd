class_name FactionData

var faction_id: int = 0
var faction_name: String = ""
var is_established: bool = false
var leader_team_id: int = -1
var member_team_ids: Array = []
var tribute_rate: float = 0.10

# 策略層（faction_ai_system 讀寫）
var goals: Array = []        # ["徵收", "立國", "擴張", "防禦"]
var strategy: String = "idle"

# 跨勢力關係（立國號才有意義；未立國號留空）
# "neutral" / "ally" / "enemy"
var relations: Dictionary = {}  # faction_id → String

var known_member_states: Dictionary = {}
# { team_id: int → {
#   "food":         float,    # resources["food"]
#   "weapons":      int,      # sum(melee_low+melee_high+ranged_low+ranged_high)
#   "goods":        float,    # resources["goods"]
#   "population":   int,
#   "tile_pos":     Vector2i,
#   "current_task": String,
#   "last_tick":    int,
# }}
