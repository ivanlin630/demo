# 戰略 AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實裝勢力目標更新、包圍/突圍 strategic_assignments 指派、多勢力聯盟威脅評估。

**Architecture:** 新建 `StrategicAiSystem`；`FactionAiSystem._update_faction` 每 STRATEGIC_INTERVAL tick 呼叫；MovementSystem 讀取 `strategic_assignments` 作為移動目標優先級。

**Tech Stack:** Godot 4.2.2 GDScript

**依賴：** `2026-05-27-data-structure-update.md`（strategic_assignments、known_reputations）；`2026-05-27-diplomatic-ai.md`（_form_alliance）。

---

## File Structure

| 動作 | 檔案 |
|---|---|
| Create | `scripts/simulation/strategic_ai_system.gd` |
| Modify | `scripts/simulation/faction_ai_system.gd` |
| Modify | `scripts/simulation/movement_system.gd` |
| Modify | `scripts/simulation/data/faction_data.gd` |
| Modify | `scripts/debug/headless_test.gd` |

---

### Task 1: FactionData — 加入 goals 欄位

**Files:**
- Modify: `scripts/data/faction_data.gd`

- [ ] **Step 1: 讀取 faction_data.gd 現有結構**

```powershell
Get-Content scripts/data/faction_data.gd
```

- [ ] **Step 2: 加入 goals 欄位**

在 `faction_data.gd` 末尾加：
```gdscript
var goals: Array = []
# goal 格式: { "type": String, "target_id": int, "priority": float }
# type: "expand" / "defend" / "trade_net" / "tribute" / "alliance"
```

- [ ] **Step 3: 執行測試確認無崩潰**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/data/faction_data.gd
git commit -m "feat(strategic-ai): add goals field to FactionData"
```

---

### Task 2: StrategicAiSystem — 勢力目標更新

**Files:**
- Create: `scripts/simulation/strategic_ai_system.gd`

- [ ] **Step 1: 建立 strategic_ai_system.gd**

```gdscript
# scripts/simulation/strategic_ai_system.gd
class_name StrategicAiSystem

const STRATEGIC_INTERVAL: int    = 10   # TEST VALUE
const ALLIANCE_CHECK_INTERVAL: int = 30  # TEST VALUE

func tick(state: WorldState, faction: FactionData) -> void:
    if state.world.current_tick % STRATEGIC_INTERVAL != 0: return
    _update_faction_goals(state, faction)
    if faction.goals.size() > 0:
        var top: Dictionary = faction.goals[0]
        match top["type"]:
            "expand":
                _assign_encirclement(state, faction, top["target_id"])
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: _assign_breakout(state, t)
    if state.world.current_tick % ALLIANCE_CHECK_INTERVAL == 0:
        _evaluate_alliance_need(state, faction)

func _update_faction_goals(state: WorldState, faction: FactionData) -> void:
    faction.goals.clear()
    var leader_team: TeamData = state.teams.get(faction.leader_team_id)
    if leader_team == null: return
    var faction_leader: PersonData = state.persons.get(leader_team.leader_id)
    if faction_leader == null: return
    var v := faction_leader.values

    var expand_score: float = v.get("野心", 0.5) * 0.5 + v.get("好戰", 0.5) * 0.5
    if expand_score > 0.4:
        var tgt_id: int = _nearest_independent(state, leader_team)
        if tgt_id != -1:
            faction.goals.append({ "type": "expand", "target_id": tgt_id,
                "priority": expand_score })

    var weakest_id: int = _find_weakest_member(state, faction)
    if weakest_id != -1:
        faction.goals.append({ "type": "defend", "target_id": weakest_id,
            "priority": 0.7 })

    var trade_score: float = v.get("貪婪", 0.5) * 0.4 + (1.0 - v.get("好戰", 0.5)) * 0.3
    if trade_score > 0.35:
        faction.goals.append({ "type": "trade_net", "target_id": -1,
            "priority": trade_score })

    faction.goals.sort_custom(func(a, b): return a["priority"] > b["priority"])
    if faction.goals.size() > 0:
        print("[StrategicAI] Faction%d 首要目標: %s target=%d" % [
            faction.faction_id, faction.goals[0]["type"], faction.goals[0]["target_id"]])

func _nearest_independent(state: WorldState, from_team: TeamData) -> int:
    var best_id: int = -1; var best_d: int = 999
    for tid in state.team_discovered.get(from_team.team_id, []):
        if not state.teams.has(tid): continue
        var t: TeamData = state.teams[tid]
        if t.faction_id != -1: continue
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
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
var _strat := StrategicAiSystem.new()
var _f0: FactionData = state.factions.get(0)
if _f0:
    _strat._update_faction_goals(state, _f0)
    print("[StrategicAI] Faction0 goals=%d" % _f0.goals.size())
    assert(_f0.goals.size() > 0, "Faction0 應有至少一個戰略目標")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "StrategicAI|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(strategic-ai): add StrategicAiSystem with faction goal update"
```

---

### Task 3: 包圍/突圍 strategic_assignments

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`

- [ ] **Step 1: 加入 _assign_encirclement**

```gdscript
func _assign_encirclement(state: WorldState, faction: FactionData,
        target_id: int) -> void:
    var target: TeamData = state.teams.get(target_id)
    if target == null: return
    var member_teams: Array = []
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: member_teams.append(t)
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
        Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
    ]
    for i in range(member_teams.size()):
        var t: TeamData = member_teams[i]
        var dir: Vector2i = dirs[i % dirs.size()]
        t.strategic_assignments[target_id] = target.tile_pos + dir * 2
```

- [ ] **Step 2: 加入 _assign_breakout 與 _find_escape_dir**

```gdscript
func _assign_breakout(state: WorldState, self_team: TeamData) -> void:
    var enemy_teams: Array = []
    for tid in state.team_discovered.get(self_team.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id != self_team.faction_id:
            enemy_teams.append(t)
    if enemy_teams.size() < 2: return
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
```

- [ ] **Step 3: headless_test.gd 加 strategic_assignments 驗證**

```gdscript
if _f0 and _f0.goals.size() > 0 and _f0.goals[0]["type"] == "expand":
    _strat._assign_encirclement(state, _f0, _f0.goals[0]["target_id"])
    for tid in _f0.member_team_ids:
        var mt: TeamData = state.teams.get(tid)
        if mt and mt.strategic_assignments.size() > 0:
            print("[StrategicAI] Team%d strategic_assignments=%s" % [
                tid, str(mt.strategic_assignments)])
            break
```

- [ ] **Step 4: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "StrategicAI|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(strategic-ai): add encirclement and breakout assignments"
```

---

### Task 4: 聯盟威脅評估 + MovementSystem 讀取 strategic_assignments + SimRunner 整合

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1: strategic_ai_system.gd — _evaluate_alliance_need**

```gdscript
func _evaluate_alliance_need(state: WorldState, faction: FactionData) -> void:
    var self_pop: int = _faction_total_pop(state, faction)
    var threat_map: Dictionary = {}
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
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
```

- [ ] **Step 2: movement_system.gd — 讀取 strategic_assignments**

在 movement_system 選定 move_target 的邏輯前加：
```gdscript
# strategic_assignments 優先（-1 key = 突圍；正整數 key = 包圍目標）
if team.strategic_assignments.size() > 0:
    var sa_target: Vector2i = team.strategic_assignments.values()[0]
    if team.move_target == Vector2i(-1, -1) or team.move_target == team.tile_pos:
        team.move_target = sa_target
```

- [ ] **Step 3: sim_runner.gd 加 StrategicAiSystem**

```gdscript
var _strategic_ai_system: StrategicAiSystem
# 在 _init() 加
_strategic_ai_system = StrategicAiSystem.new()
```

在 `_step6b_faction_ai` 後加：
```gdscript
_step6e_strategic_ai(state, near_teams)

func _step6e_strategic_ai(state: WorldState, team_ids: Array) -> void:
    for fid in state.factions:
        _strategic_ai_system.tick(state, state.factions[fid])
```

- [ ] **Step 4: 執行 1000 tick 測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "StrategicAI|SCRIPT ERROR|DONE"
```

預期：`[StrategicAI]` print 至少出現一次

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/simulation/movement_system.gd scripts/simulation/faction_ai_system.gd scripts/simulation/sim_runner.gd
git commit -m "feat(strategic-ai): integrate StrategicAiSystem, alliance need, movement priority"
```
