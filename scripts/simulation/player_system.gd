# scripts/simulation/player_system.gd
class_name PlayerSystem

const ITEM_WEIGHT: Dictionary = {
    "weapon_melee_low":   3.0, "weapon_melee_high":  4.0,
    "weapon_ranged_low":  2.5, "weapon_ranged_high": 3.0,
    "armor_low":          5.0, "armor_high":         8.0,
    "food":               0.5, "medicine":           0.3,
    "tools":              2.0,
}
const PLAYER_MAX_WEIGHT: float = 30.0   # TEST VALUE

func init_player(state: WorldState, person_id: int, team_id: int) -> void:
    state.player_id = person_id
    state.player_state = {
        "inventory": [],
        "coin": 50.0,
    }
    var p: PersonData = state.persons.get(person_id)
    if p:
        p.role = "leader"
        p.team_id = team_id

func calc_inventory_weight(state: WorldState) -> float:
    var total: float = 0.0
    for item in state.player_state.get("inventory", []):
        total += ITEM_WEIGHT.get(item.get("grade", ""), 1.0) * item.get("qty", 1)
    return total

func add_to_inventory(state: WorldState, grade: String, qty: int = 1) -> void:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("type", "pool") == "pool":
            item["qty"] += qty
            return
    inv.append({ "grade": grade, "type": "pool", "qty": qty })

func take_from_team(state: WorldState, grade: String, qty: int) -> bool:
    var team: TeamData = _get_player_team(state)
    if team == null: return false
    var cur: int = int(team.resources.get(grade, 0))
    if cur < qty: return false
    team.resources[grade] = cur - qty
    for i in range(qty):
        add_to_inventory(state, grade, 1)
    return true

func deposit_to_team(state: WorldState, grade: String, qty: int) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("qty", 0) >= qty:
            item["qty"] -= qty
            if item["qty"] <= 0: inv.erase(item)
            var team: TeamData = _get_player_team(state)
            if team:
                team.resources[grade] = int(team.resources.get(grade, 0)) + qty
            return true
    return false

func _get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func get_visible_teams(state: WorldState) -> Array:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return []
    return state.team_discovered.get(p.team_id, [])
