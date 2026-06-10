class_name StrategicAiSystem

const STRATEGIC_INTERVAL:      int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
const ALLIANCE_CHECK_INTERVAL: int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
const BREAKOUT_DIST: int = 2     # 原 5，縮為 2（radius 小地圖友善）
const ENCIRCLE_DIST: int = 1     # 原 2，縮為 1
const BREAKOUT_NEAREST_THRESHOLD: int = 3   # 鄰敵 > 此距不觸發 breakout

static func _is_valid_tile(state: WorldState, pos: Vector2i) -> bool:
    return state.world.tiles.has(pos.x * 1000 + pos.y)

static func _nearest_valid_tile(state: WorldState, target: Vector2i, fallback: Vector2i) -> Vector2i:
    if _is_valid_tile(state, target): return target
    # 從 target 往 fallback 方向找最近 in-map tile
    var dir: Vector2i = fallback - target
    var step: Vector2i = Vector2i(sign(dir.x), sign(dir.y))
    if step == Vector2i.ZERO: return fallback
    var cur: Vector2i = target
    for _i in range(20):
        cur = cur + step
        if _is_valid_tile(state, cur): return cur
    return fallback

func tick(state: WorldState, faction: FactionData) -> void:
    if state.world.current_tick % STRATEGIC_INTERVAL != 0: return
    _update_faction_goals(state, faction)
    if faction.strategic_goals.size() > 0:
        var top: Dictionary = faction.strategic_goals[0]
        match top["type"]:
            "expand":
                _assign_encirclement(state, faction, top["target_id"])
            "trade_net":
                _dispatch_trade_net(state, faction)
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

func _get_pop_est(state: WorldState, obs_id: int, tgt_id: int, fallback: int) -> int:
    return state.team_intel.get(obs_id, {}).get(tgt_id, {}).get("population_est", fallback)

func _find_weakest_member(state: WorldState, faction: FactionData) -> int:
    var weakest_id: int = -1; var weakest_pop: int = 9999
    for tid in faction.member_team_ids:
        # T-02：從 faction_snapshot 讀人口；無快照 = 9999（視為強健，不優先支援）
        var pop: int = faction.known_member_states.get(tid, {}).get("population", 9999)
        if pop < weakest_pop:
            weakest_pop = pop; weakest_id = tid
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
    # T-02：用 leader 的 team_intel 取目標最後已知位置
    var leader_id: int = faction.leader_team_id
    var target_pos: Vector2i = state.team_intel.get(leader_id, {}).get(
        target_id, {}).get("tile_pos", target.tile_pos)
    for i in range(member_teams.size()):
        var t: TeamData = member_teams[i]
        if t.current_task in FactionAISystem.SURVIVAL_TASKS:
            continue
        var dir: Vector2i = dirs[i % dirs.size()]
        var sa_pos: Vector2i = target_pos + dir * ENCIRCLE_DIST
        sa_pos = _nearest_valid_tile(state, sa_pos, target_pos)
        t.strategic_assignments[target_id] = sa_pos

func _assign_breakout(state: WorldState, self_team: TeamData) -> void:
    if self_team.current_task in FactionAISystem.SURVIVAL_TASKS:
        self_team.strategic_assignments.erase(-1)
        return
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
    # 鄰敵 > BREAKOUT_NEAREST_THRESHOLD hex 不觸發 breakout（看遠敵不必恐慌）
    var nearest_dist: int = 9999
    for e in enemy_teams:
        var d: int = _hex_dist(self_team.tile_pos, e.tile_pos)
        if d < nearest_dist: nearest_dist = d
    if nearest_dist > BREAKOUT_NEAREST_THRESHOLD:
        self_team.strategic_assignments.erase(-1)
        return
    var best_dir: Vector2i = _find_escape_dir(self_team.tile_pos, enemy_teams)
    var sa_pos: Vector2i = self_team.tile_pos + best_dir * BREAKOUT_DIST
    sa_pos = _nearest_valid_tile(state, sa_pos, self_team.tile_pos)
    self_team.strategic_assignments[-1] = sa_pos

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
    var seen: Dictionary = {}  # tid → obs_id（記錄是哪個 member 看到的）
    for mid in faction.member_team_ids:
        for tid in state.team_discovered.get(mid, []):
            seen[tid] = mid
    for tid in seen:
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id == faction.faction_id or t.faction_id == -1: continue
        # T-02：讀目擊者 member 的 team_intel 估算值
        var obs_id: int = seen[tid]
        var pop_est: int = _get_pop_est(state, obs_id, tid, t.population)
        threat_map[t.faction_id] = threat_map.get(t.faction_id, 0) + pop_est
    for fid in threat_map:
        if threat_map[fid] > self_pop * 1.5:
            print("[StrategicAI] Faction%d 受威脅，尋求結盟" % faction.faction_id)
            break

func _faction_total_pop(state: WorldState, faction: FactionData) -> int:
    var total: int = 0
    for tid in faction.member_team_ids:
        # T-02：從快照讀人口；無快照 fallback = 直讀（自己的隊伍應有快照）
        var t: TeamData = state.teams.get(tid)
        var snap_pop: int = faction.known_member_states.get(tid, {}).get("population", -1)
        if snap_pop >= 0:
            total += snap_pop
        elif t:
            total += t.population
    return total

# trade_net goal：派 idle 商隊去鄰近有貨/有錢的對象交易（移動到對方格，由 interaction 同格成交）
func _dispatch_trade_net(state: WorldState, faction: FactionData) -> void:
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if not ("商隊" in t.tags): continue
        if t.current_task != TeamData.TASK_IDLE: continue
        var partner_id: int = _find_trade_partner(state, t)
        if partner_id == -1: continue
        var p: TeamData = state.teams[partner_id]
        t.current_task = TeamData.TASK_TRADE
        t.move_target = p.tile_pos
        print("[StrategicAI] Faction%d 商隊 Team%d → trade Team%d" % [
            faction.faction_id, t.team_id, partner_id])

func _find_trade_partner(state: WorldState, trader: TeamData) -> int:
    for tid in state.team_discovered.get(trader.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
        # 對方有 goods 或一定 coin 即視為可交易對象
        if float(t.resources.get("goods", 0)) > 0 or float(t.resources.get("coin", 0)) > 50:
            return tid
    return -1
