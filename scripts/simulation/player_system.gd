# scripts/simulation/player_system.gd
class_name PlayerSystem

const PLAYER_INVENTORY_MAX_SLOTS: int = 6   # TEST VALUE

func _can_add_item(state: WorldState, grade: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    var already_has: bool = inv.any(func(x): return x.get("grade") == grade)
    if not already_has and inv.size() >= PLAYER_INVENTORY_MAX_SLOTS:
        return false
    return true

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
        total += ItemAttributes.get_weight(item.get("grade", ""), item.get("qty", 1))
    return total

func add_to_inventory(state: WorldState, grade: String, qty: int = 1) -> bool:
    if not _can_add_item(state, grade): return false
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == grade and item.get("type", "pool") == "pool":
            item["qty"] += qty
            return true
    inv.append({ "grade": grade, "type": "pool", "qty": qty })
    return true

func take_from_team(state: WorldState, grade: String, qty: int) -> bool:
    var team: TeamData = _get_player_team(state)
    if team == null: return false
    var cur: int = int(team.resources.get(grade, 0))
    if cur < qty: return false
    if not _can_add_item(state, grade): return false
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
            var old: Dictionary = player.equipment.get(slot, {})
            if old.get("type", "none") != "none":
                add_to_inventory(state, old["grade"])
            player.equipment[slot] = { "type": "pool", "grade": grade }
            if ItemAttributes.is_2h(grade):
                player.equipment["hand_2"] = { "type": "2h_ref" }
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

func use_splint(state: WorldState, pid: int, part: String) -> bool:
    return HealthSystem.use_splint(state, pid, part)

func _get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func get_visible_teams(state: WorldState) -> Array:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return []
    return state.team_discovered.get(p.team_id, []).duplicate()
