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
    add_to_inventory(state, grade, qty)
    return true

func deposit_to_team(state: WorldState, grade: String, qty: int) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for i in range(inv.size()):
        if inv[i]["grade"] == grade and inv[i].get("qty", 0) >= qty:
            inv[i]["qty"] -= qty
            if inv[i]["qty"] <= 0: inv.remove_at(i)
            var team: TeamData = _get_player_team(state)
            if team:
                team.resources[grade] = int(team.resources.get(grade, 0)) + qty
            return true
    return false

func equip_item(state: WorldState, slot: String, grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    var player: PersonData = state.persons.get(state.player_id)
    if player == null: return false
    for i in range(inv.size()):
        if inv[i]["grade"] == grade and inv[i].get("type", "pool") == "pool":
            # 卸下舊裝備
            var old: Dictionary = player.equipment.get(slot, {})
            if old.get("type", "none") != "none":
                add_to_inventory(state, old["grade"])
            # 轉換 grade 到 EquipmentSystem/SkillSystem 預期的短格式 type
            var wtype: String = grade.replace("weapon_", "")
            player.equipment[slot] = { "type": wtype, "grade": grade }
            inv[i]["qty"] -= 1
            if inv[i]["qty"] <= 0: inv.remove_at(i)
            return true
    return false

func unequip_item(state: WorldState, slot: String) -> bool:
    var player: PersonData = state.persons.get(state.player_id)
    if player == null: return false
    var cur: Dictionary = player.equipment.get(slot, {})
    if cur.get("type", "none") == "none": return false
    add_to_inventory(state, cur["grade"])
    player.equipment[slot] = { "type": "none", "grade": "" }
    return true

func _get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func get_visible_teams(state: WorldState) -> Array:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return []
    return state.team_discovered.get(p.team_id, []).duplicate()
