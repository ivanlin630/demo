# 戰略 AI Design

## 依賴

本 spec 依賴：
- `2026-05-27-data-structure-update-design.md`（strategic_assignments、known_reputations）
- `2026-05-27-diplomatic-ai-design.md`（結盟、背叛邏輯）

---

## Goal

強化 FactionAI 的戰略層：加入包圍/突圍指派（strategic_assignments）、多勢力聯盟計算、目標優先級動態調整。維持現有 bias-modification 架構，不覆蓋 NPC 自主決策。

---

## 1. 架構原則

- 戰略 AI **修改 task bias**，不強制覆蓋 NPC 決策
- `strategic_assignments[team_id] = Vector2i` 指派目標座標，MovementSystem 讀取作為目標位點
- 每 STRATEGIC_INTERVAL tick 重新評估（TEST VALUE: 10）

---

## 2. 勢力目標（FactionGoals）

FactionData 維護目標清單，每次 tick 依條件更新優先目標：

```gdscript
# FactionData（現有結構）補充
var goals: Array = []   # Array[Dictionary]
# goal 格式：{ "type": String, "target_id": int, "priority": float }

# goal types
# "expand"    → 攻擊獨立 team 或弱小勢力
# "defend"    → 守護己方最弱 team
# "trade_net" → 拓展貿易網路
# "tribute"   → 向目標勒索
# "alliance"  → 尋求結盟
```

### 目標選擇邏輯

```gdscript
func _update_faction_goals(state: WorldState, faction: FactionData) -> void:
    faction.goals.clear()
    var leader_team: TeamData = state.teams.get(faction.leader_team_id)
    if leader_team == null: return
    var faction_leader: PersonData = state.persons.get(leader_team.leader_id)
    if faction_leader == null: return

    var v := faction_leader.values

    # 擴張衝動
    var expand_score: float = v.get("野心", 0.5) * 0.5 + v.get("好戰", 0.5) * 0.5
    if expand_score > 0.4 and _has_independent(state, faction.leader_team_id):
        var tgt_id: int = _nearest_independent(state, leader_team)
        if tgt_id != -1:
            faction.goals.append({ "type": "expand", "target_id": tgt_id,
                "priority": expand_score })

    # 防禦需求（最弱 team 受威脅）
    var weakest_id: int = _find_weakest_member(state, faction)
    if weakest_id != -1:
        faction.goals.append({ "type": "defend", "target_id": weakest_id,
            "priority": 0.7 })

    # 貿易意願
    var trade_score: float = v.get("貪婪", 0.5) * 0.4 + (1.0 - v.get("好戰", 0.5)) * 0.3
    if trade_score > 0.35:
        faction.goals.append({ "type": "trade_net", "target_id": -1,
            "priority": trade_score })

    # 依優先級排序
    faction.goals.sort_custom(func(a, b): return a["priority"] > b["priority"])
```

---

## 3. 包圍指派（Encirclement）

當勢力目標為 `"expand"` 且有多個 team 時，協調多 team 從不同方向逼近目標：

```gdscript
func _assign_encirclement(state: WorldState, faction: FactionData,
        target_id: int) -> void:
    var target: TeamData = state.teams.get(target_id)
    if target == null: return
    var member_teams: Array = []
    for tid in faction.member_team_ids:
        if state.teams.has(tid):
            member_teams.append(state.teams[tid])
    if member_teams.size() < 2:
        # 只有一個 team：直接指向目標
        if member_teams.size() == 1:
            faction.leader_team_id   # 直接移動
            state.teams[faction.member_team_ids[0]].strategic_assignments[\
                target_id] = target.tile_pos
        return

    # 多 team：分配不同接近方向
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0),
        Vector2i(0, 1), Vector2i(0, -1),
        Vector2i(1, -1), Vector2i(-1, 1),
    ]
    for i in range(member_teams.size()):
        var t: TeamData = member_teams[i]
        var dir: Vector2i = dirs[i % dirs.size()]
        var approach_pos: Vector2i = target.tile_pos + dir * 2   # TEST VALUE
        t.strategic_assignments[target_id] = approach_pos
```

---

## 4. 突圍指派（Breakout）

當己方 team 被包圍（多方向有敵對 team）時，指派突圍方向：

```gdscript
func _assign_breakout(state: WorldState, self_team: TeamData) -> void:
    # 找最少敵人方向
    var enemy_teams: Array = []
    for tid in state.team_discovered.get(self_team.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id != self_team.faction_id and t.faction_id != -1:
            enemy_teams.append(t)
        elif t.faction_id == -1:
            enemy_teams.append(t)

    if enemy_teams.size() < 2: return   # 未真正被包圍

    # 計算各方向敵人密度，選最稀疏方向
    var best_dir: Vector2i = _find_escape_dir(self_team.tile_pos, enemy_teams)
    var escape_pos: Vector2i = self_team.tile_pos + best_dir * 5   # TEST VALUE
    self_team.strategic_assignments[-1] = escape_pos   # -1 = 突圍目標

func _find_escape_dir(origin: Vector2i, enemies: Array) -> Vector2i:
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0),
        Vector2i(0, 1), Vector2i(0, -1),
        Vector2i(1, -1), Vector2i(-1, 1),
    ]
    var best_dir: Vector2i = dirs[0]
    var best_score: float = -99.0
    for d in dirs:
        var score: float = 0.0
        for e in enemies:
            var ev: Vector2i = e.tile_pos - origin
            # 與方向反向的敵人得分高（逃離方向）
            var dot: float = float(d.x * ev.x + d.y * ev.y)
            score -= dot   # 越遠離敵人越好
        if score > best_score:
            best_score = score
            best_dir = d
    return best_dir
```

---

## 5. 多勢力聯盟計算

每 ALLIANCE_CHECK_INTERVAL tick（TEST VALUE: 30）評估外部威脅，觸發聯盟外交：

```gdscript
func _evaluate_alliance_need(state: WorldState, faction: FactionData) -> void:
    var self_pop: int = _faction_total_pop(state, faction)
    # 找最大威脅勢力
    var threat_map: Dictionary = {}   # {faction_id: int pop}
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        if t.faction_id == faction.faction_id: continue
        if t.faction_id == -1: continue
        var v: int = threat_map.get(t.faction_id, 0)
        threat_map[t.faction_id] = v + t.population

    for fid in threat_map:
        var threat_pop: int = threat_map[fid]
        if threat_pop > self_pop * 1.5:   # TEST VALUE
            # 找第三方勢力外交
            for other_fid in state.factions:
                if other_fid == faction.faction_id: continue
                if other_fid == fid: continue
                var other_f: FactionData = state.factions[other_fid]
                var other_leader_team: TeamData = state.teams.get(
                    other_f.leader_team_id)
                var self_leader_team: TeamData = state.teams.get(
                    faction.leader_team_id)
                if other_leader_team == null or self_leader_team == null: continue
                # 透過外交 AI 提出結盟
                # （外交AI將生成 propose_alliance 訊息）
                break

func _faction_total_pop(state: WorldState, faction: FactionData) -> int:
    var total: int = 0
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: total += t.population
    return total
```

---

## 6. 與 FactionAISystem 整合

在 `FactionAISystem._update_faction(state, faction)` 末端呼叫：

```gdscript
# 每 STRATEGIC_INTERVAL tick
if state.current_tick % STRATEGIC_INTERVAL == 0:
    _update_faction_goals(state, faction)
    # 依首要目標觸發對應指派
    if faction.goals.size() > 0:
        var top_goal: Dictionary = faction.goals[0]
        match top_goal["type"]:
            "expand":
                _assign_encirclement(state, faction, top_goal["target_id"])
            "defend":
                pass   # MovementSystem 直接讀取 weakest team 位置
    _evaluate_alliance_need(state, faction)

# 突圍：每 team 獨立判斷（不需 STRATEGIC_INTERVAL）
for tid in faction.member_team_ids:
    var t: TeamData = state.teams.get(tid)
    if t == null: continue
    _assign_breakout(state, t)
```

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `[StrategicAI]` print 出現
- `faction.goals` 在 tick 後非空
- `strategic_assignments` 在包圍模式下各 team 指向不同接近點
- 多勢力模擬中出現聯盟談判 print
