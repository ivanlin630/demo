class_name StrategicAiSystem

const STRATEGIC_INTERVAL: int    = 10   # TEST VALUE
const ALLIANCE_CHECK_INTERVAL: int = 30  # TEST VALUE

func tick(state: WorldState, faction: FactionData) -> void:
    if state.world.current_tick % STRATEGIC_INTERVAL != 0: return
    _update_faction_goals(state, faction)
    if faction.strategic_goals.size() > 0:
        var top: Dictionary = faction.strategic_goals[0]
        match top["type"]:
            "expand":
                _assign_encirclement(state, faction, top["target_id"])
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: _assign_breakout(state, t)
    if state.world.current_tick % ALLIANCE_CHECK_INTERVAL == 0:
        _evaluate_alliance_need(state, faction)

func _update_faction_goals(state: WorldState, faction: FactionData) -> void:
    faction.strategic_goals.clear()
    var leader_team: TeamData = state.teams.get(faction.leader_team_id)
    if leader_team == null: return
    var faction_leader: PersonData = state.persons.get(leader_team.leader_id)
    if faction_leader == null: return
    var v := faction_leader.values

    var expand_score: float = v.get("野心", 0.5) * 0.5 + v.get("好戰", 0.5) * 0.5
    if expand_score > 0.4:
        var tgt_id: int = _nearest_independent(state, leader_team)
        if tgt_id != -1:
            faction.strategic_goals.append({ "type": "expand", "target_id": tgt_id,
                "priority": expand_score })

    if faction.member_team_ids.size() > 1:
        var weakest_id: int = _find_weakest_member(state, faction)
        if weakest_id != -1 and weakest_id != faction.leader_team_id:
            faction.strategic_goals.append({ "type": "defend", "target_id": weakest_id,
                "priority": 0.7 })

    var trade_score: float = v.get("貪婪", 0.5) * 0.4 + (1.0 - v.get("好戰", 0.5)) * 0.3
    if trade_score > 0.35:
        faction.strategic_goals.append({ "type": "trade_net", "target_id": -1,
            "priority": trade_score })

    faction.strategic_goals.sort_custom(func(a, b): return a["priority"] > b["priority"])
    if faction.strategic_goals.size() > 0:
        print("[StrategicAI] Faction%d 首要目標: %s target=%d" % [
            faction.faction_id, faction.strategic_goals[0]["type"], faction.strategic_goals[0]["target_id"]])
    # 若無 expand goal，清除所有包圍指派（目標可能已消滅）
    var has_expand: bool = false
    for g in faction.strategic_goals:
        if g["type"] == "expand":
            has_expand = true
            break
    if not has_expand:
        for tid in faction.member_team_ids:
            var t: TeamData = state.teams.get(tid)
            if t:
                for key in t.strategic_assignments.keys():
                    if key != -1:
                        t.strategic_assignments.erase(key)

func _nearest_independent(state: WorldState, from_team: TeamData) -> int:
    var best_id: int = -1; var best_d: int = 999
    for tid in state.team_discovered.get(from_team.team_id, []):
        if not state.teams.has(tid): continue
        var t: TeamData = state.teams[tid]
        if t.faction_id != -1 or t.team_id == from_team.team_id: continue
        var d: int = _hex_dist(from_team.tile_pos, t.tile_pos)
        if d < best_d: best_d = d; best_id = tid
    return best_id

func _find_weakest_member(state: WorldState, faction: FactionData) -> int:
    var weakest_id: int = -1; var weakest_pop: int = 9999
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t and t.population < weakest_pop:
            weakest_pop = t.population; weakest_id = tid
    return weakest_id

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx := b.x - a.x; var dy := b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _assign_encirclement(state: WorldState, faction: FactionData,
        target_id: int) -> void:
    var target: TeamData = state.teams.get(target_id)
    if target == null: return
    var member_teams: Array = []
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: member_teams.append(t)
    # clear stale encirclement assignments before re-assigning
    for t in member_teams:
        t.strategic_assignments.clear()
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
        Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
    ]
    for i in range(member_teams.size()):
        var t: TeamData = member_teams[i]
        var dir: Vector2i = dirs[i % dirs.size()]
        t.strategic_assignments[target_id] = target.tile_pos + dir * 2

func _assign_breakout(state: WorldState, self_team: TeamData) -> void:
    var enemy_teams: Array = []
    for tid in state.team_discovered.get(self_team.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id == -1 or t.faction_id == self_team.faction_id:
            continue
        enemy_teams.append(t)
    if enemy_teams.size() < 2:
        self_team.strategic_assignments.erase(-1)
        return
    var best_dir: Vector2i = _find_escape_dir(self_team.tile_pos, enemy_teams)
    self_team.strategic_assignments[-1] = self_team.tile_pos + best_dir * 5

func _find_escape_dir(origin: Vector2i, enemies: Array) -> Vector2i:
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
        Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
    ]
    var best_dir: Vector2i = dirs[0]; var best_score: float = -99.0
    for d in dirs:
        var score: float = 0.0
        for e in enemies:
            var ev: Vector2i = e.tile_pos - origin
            score -= float(d.x * ev.x + d.y * ev.y)
        if score > best_score: best_score = score; best_dir = d
    return best_dir

func _evaluate_alliance_need(state: WorldState, faction: FactionData) -> void:
    var self_pop: int = _faction_total_pop(state, faction)
    var threat_map: Dictionary = {}
    # 只計算 faction 成員已偵測到的敵方（非全知）
    var seen: Dictionary = {}
    for mid in faction.member_team_ids:
        for tid in state.team_discovered.get(mid, []):
            seen[tid] = true
    for tid in seen:
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id == faction.faction_id or t.faction_id == -1: continue
        threat_map[t.faction_id] = threat_map.get(t.faction_id, 0) + t.population
    for fid in threat_map:
        if threat_map[fid] > self_pop * 1.5:
            print("[StrategicAI] Faction%d 受威脅，尋求結盟" % faction.faction_id)
            break

func _faction_total_pop(state: WorldState, faction: FactionData) -> int:
    var total: int = 0
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: total += t.population
    return total
