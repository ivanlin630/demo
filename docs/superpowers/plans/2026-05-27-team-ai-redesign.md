# Team AI 重構 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實裝薪水系統、loyalty transfer 規則、依技能選子隊 leader、更新 split 機制、加入疲勞系統與負重系統。

**Architecture:** 新增 `SalarySystem` 獨立檔案；修改 `event_unrest_split.gd`、`subteam_system.gd`、`sim_runner.gd`；疲勞在 SimRunner 每 tick 累積，由 MovementSystem 讀取速度懲罰。

**Tech Stack:** Godot 4.2.2 GDScript

**依賴：** 本 plan 依賴 `2026-05-27-data-structure-update.md` 完成（named_members、salary、fatigue、guard_ratio 欄位已存在）。

---

## File Structure

| 動作 | 檔案 |
|---|---|
| Create | `scripts/simulation/salary_system.gd` |
| Modify | `scripts/simulation/subteam_system.gd` |
| Modify | `scripts/simulation/events/event_unrest_split.gd` |
| Modify | `scripts/simulation/sim_runner.gd` |
| Modify | `scripts/simulation/movement_system.gd` |
| Modify | `scripts/debug/headless_test.gd` |

---

### Task 1: SubteamSystem — 依任務技能選子隊 leader

**Files:**
- Modify: `scripts/simulation/subteam_system.gd`
- Modify: `scripts/simulation/faction_ai_system.gd`

目前 `faction_ai_system.gd` 取 `leader_team.named_members[0]` 作為子隊 leader（遷移後）。改為依任務類型選最高對應技能者。

- [ ] **Step 1: subteam_system.gd 加入 _pick_subteam_leader 函數**

在 `subteam_system.gd` 末尾加入：

```gdscript
func _pick_subteam_leader(state: WorldState, team: TeamData, task: String) -> int:
    var skill_map: Dictionary = {
        "攻擊": "統領", "掠奪": "統領", "貿易": "商業",
        "外交": "交涉", "生產": "生產", "製造": "製造", "偵查": "偵查"
    }
    var skill: String = skill_map.get(task, "統領")
    var best_id: int = -1
    var best_val: float = -1.0
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var v: float = float(p.skills.get(skill, 0.0))
        if v > best_val:
            best_val = v; best_id = pid
    return best_id
```

- [ ] **Step 2: faction_ai_system.gd — 更新 dispatch 呼叫**

找到 `faction_ai_system.gd` 中呼叫 dispatch 並取 `named_members[0]` 的位置（原 `advisors[0]`，Task 9 已遷移），改為：

```gdscript
var sub_sys := SubteamSystem.new()
var task_for_dispatch: String = "偵查"   # 或依 FactionAI 決策的任務
var sub_leader_id: int = sub_sys._pick_subteam_leader(state, leader_team, task_for_dispatch)
if sub_leader_id == -1: continue   # 無合適人選
var _sid := sub_sys.dispatch(state, f.leader_team_id, sub_leader_id, ...)
```

- [ ] **Step 3: headless_test.gd 加驗證**

```gdscript
var _sub_sys2 := SubteamSystem.new()
var _best := _sub_sys2._pick_subteam_leader(state, state.teams[0], "偵查")
print("[TeamAI] _pick_subteam_leader(偵查) = P%d" % _best)
assert(_best != -1, "應能找到偵查子隊 leader")
# Person1 有偵查 0.4，應選 Person1（id=1）
assert(_best == 1, "最高偵查技能應為 Person1")
```

- [ ] **Step 4: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "TeamAI|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/subteam_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(team-ai): pick subteam leader by task skill"
```

---

### Task 2: SalarySystem — 建立薪水系統

**Files:**
- Create: `scripts/simulation/salary_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加驗證（先行）**

在驗證段加：
```gdscript
print("[Salary] 結算前 Team0 coin=%s" % str(state.teams[0].resources.get("coin", 0)))
```
（完整驗證在 Step 5 補充）

- [ ] **Step 2: 建立 salary_system.gd**

```gdscript
# scripts/simulation/salary_system.gd
class_name SalarySystem

const SALARY_INTERVAL: int     = 30    # TEST VALUE
const SALARY_PER_SKILL_POINT: float = 2.0   # TEST VALUE
const OVERPAY_BONUS: float     = 0.02  # TEST VALUE
const SALARY_LOYALTY_PENALTY: float = 0.03  # TEST VALUE
const MAX_LOYALTY: float       = 0.95

func tick(state: WorldState, team_ids: Array) -> void:
    if state.world.current_tick % SALARY_INTERVAL != 0:
        return
    for tid in team_ids:
        var team: TeamData = state.teams.get(tid)
        if team == null: continue
        _pay_salary(state, team)

func _calc_fair_salary(p: PersonData) -> float:
    var total: float = 0.0
    for v in p.skills.values():
        total += float(v)
    return total * SALARY_PER_SKILL_POINT

func _pay_salary(state: WorldState, team: TeamData) -> void:
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        if _has_master_memory(p, team.leader_id): continue
        var fair: float = _calc_fair_salary(p)
        var ratio: float = p.salary / maxf(fair, 0.01)
        team.resources["coin"] = float(team.resources.get("coin", 0)) - p.salary
        p.coin += p.salary
        if ratio >= 1.0:
            p.loyalty = minf(p.loyalty + (ratio - 1.0) * OVERPAY_BONUS, MAX_LOYALTY)
        else:
            p.loyalty -= (1.0 - ratio) * SALARY_LOYALTY_PENALTY
    var anon_count: int = team.population - team.named_members.size() - 1
    var anon_total: float = team.anon_wage * maxf(anon_count, 0)
    team.resources["coin"] = float(team.resources.get("coin", 0)) - anon_total
    if float(team.resources.get("coin", 0)) < 0:
        team.unrest_turns += 1
    print("[Salary] Team%d 薪水結算 coin=%.1f" % [team.team_id, float(team.resources.get("coin", 0))])

func _has_master_memory(p: PersonData, leader_id: int) -> bool:
    for m in p.memory:
        if m.get("type") == "master" and m.get("subject_id") == leader_id:
            return true
    return false
```

- [ ] **Step 3: sim_runner.gd 整合 SalarySystem**

在 `_init()` 加：
```gdscript
var _salary_system: SalarySystem

# 在 _init() 最後
_salary_system = SalarySystem.new()
```

在 `advance_tick` 的 `_step6_resolve_consumption` 之後加：
```gdscript
_step6c_salary(state, near_teams)
```

加函數：
```gdscript
func _step6c_salary(state: WorldState, team_ids: Array) -> void:
    _salary_system.tick(state, team_ids)
```

- [ ] **Step 4: headless_test.gd 設定薪水初始值**

在 Person0-2 初始化後加（Team0 成員有薪水設定）：
```gdscript
# Person1 期望薪水（非死士，需結算）
state.persons[1].salary = 5.0
state.persons[2].salary = 3.0
```

- [ ] **Step 5: headless_test.gd 加驗證**

```gdscript
print("[Salary] 驗證：30 tick 後應有薪水結算 print")
# [Salary] 結算 print 在模擬過程中自動出現（tick 30）
```

- [ ] **Step 6: 執行 100 tick 測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Salary|SCRIPT ERROR|DONE"
```

預期：`[Salary] Team0 薪水結算 coin=...` 在 tick 30 附近出現

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/salary_system.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(team-ai): add SalarySystem with fair_salary and loyalty effects"
```

---

### Task 3: reset_loyalty_on_transfer 函數

**Files:**
- Modify: `scripts/simulation/events/event_unrest_split.gd`

- [ ] **Step 1: event_unrest_split.gd 加入函數**

在 `_next_team_id` 前加入：

```gdscript
func reset_loyalty_on_transfer(p: PersonData, transfer_type: String) -> void:
    match transfer_type:
        "split_hard":   p.loyalty = 0.5
        "split_soft":   p.loyalty = 0.65
        "split_leader": p.loyalty = 1.0
        "conquered":    p.loyalty = 0.25
        "voluntary":    p.loyalty = 0.5
        "master":       p.loyalty = 0.9
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
var _evt_split := load("res://scripts/simulation/events/event_unrest_split.gd").new()
var _tp := PersonData.new()
_tp.loyalty = 0.8
_evt_split.reset_loyalty_on_transfer(_tp, "split_hard")
assert(_tp.loyalty == 0.5, "split_hard loyalty 應為 0.5")
_evt_split.reset_loyalty_on_transfer(_tp, "split_leader")
assert(_tp.loyalty == 1.0, "split_leader loyalty 應為 1.0")
print("[TeamAI] reset_loyalty_on_transfer 驗證通過")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "TeamAI|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/events/event_unrest_split.gd scripts/debug/headless_test.gd
git commit -m "feat(team-ai): add reset_loyalty_on_transfer"
```

---

### Task 4: _split_team 重構

**Files:**
- Modify: `scripts/simulation/events/event_unrest_split.gd`

- [ ] **Step 1: 更新 _has_goal_conflict（goals 格式已改為 dict）**

目前：
```gdscript
for goal in p.goals:
    if not leader.goals.has(goal):
        return true
```
改為：
```gdscript
for g in p.goals:
    if not g.get("active", false): continue
    for lg in leader.goals:
        if lg.get("type") == g.get("type"): continue
    return true
```

- [ ] **Step 2: 重寫 _split_team 函數**

將現有 `_split_team` 完全替換為：

```gdscript
func _split_team(state: WorldState, parent: TeamData, dissenters: Array) -> TeamData:
    if dissenters.is_empty():
        return null
    var new_team := TeamData.new()
    new_team.team_id   = _next_team_id(state)
    new_team.tile_pos  = parent.tile_pos
    new_team.faction_id = -1
    new_team.resources = {
        "food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
        "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
        "weapon_melee_low": 0, "weapon_melee_high": 0,
        "weapon_ranged_low": 0, "weapon_ranged_high": 0,
        "mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
        "armor_low": 0, "armor_high": 0,
    }
    new_team.tags = []

    # 選 new leader
    var new_leader: PersonData = dissenters[0]
    new_leader.team_id = new_team.team_id
    new_leader.role    = "leader"
    new_team.leader_id = new_leader.id
    reset_loyalty_on_transfer(new_leader, "split_leader")
    parent.named_members.erase(new_leader.id)
    parent.population -= 1
    new_team.population += 1

    # Hard dissenters（loyalty < 0.35）
    for i in range(1, dissenters.size()):
        var p: PersonData = dissenters[i]
        p.team_id = new_team.team_id
        new_team.named_members.append(p.id)
        reset_loyalty_on_transfer(p, "split_hard")
        parent.named_members.erase(p.id)
        parent.population -= 1
        new_team.population += 1

    # Soft followers（loyalty 0.35–0.55，依魅力）
    var charisma: float = float(new_leader.attributes.get("魅力", 0.5))
    for pid in parent.named_members.duplicate():
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        if p.loyalty >= 0.35 and p.loyalty <= 0.55:
            if randf() < charisma * 0.6:
                p.team_id = new_team.team_id
                new_team.named_members.append(p.id)
                reset_loyalty_on_transfer(p, "split_soft")
                parent.named_members.erase(p.id)
                parent.population -= 1
                new_team.population += 1

    # 匿名跟隨者（依統領×魅力）
    var leadership: float = float(new_leader.skills.get("統領", 0.0))
    var anon_in_parent: int = parent.population - parent.named_members.size() - 1
    var anon_split: int = roundi(leadership * charisma * anon_in_parent * 0.3)
    anon_split = mini(anon_split, parent.population / 3)
    new_team.population += anon_split
    parent.population   -= anon_split

    state.teams[new_team.team_id]           = new_team
    state.team_known[new_team.team_id]      = []
    state.team_discovered[new_team.team_id] = []
    parent.unrest_turns = 0
    return new_team
```

- [ ] **Step 3: headless_test.gd — 加 split 後 loyalty 驗證**

在 1000 tick 模擬後（已有分裂場景）加：
```gdscript
# 找第一個 loyalty = 1.0 的非 Team0/3 leader
for tid in state.teams:
    var t: TeamData = state.teams[tid]
    if tid in [0, 1, 2, 3, 5, 6, 7, 8]: continue
    var ldr: PersonData = state.persons.get(t.leader_id)
    if ldr and absf(ldr.loyalty - 1.0) < 0.01:
        print("[TeamAI] split_leader loyalty=1.0 驗證通過 (Team%d)" % tid)
        break
```

- [ ] **Step 4: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "TeamAI|Event.*分裂|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/events/event_unrest_split.gd scripts/debug/headless_test.gd
git commit -m "feat(team-ai): rewrite _split_team with leadership/charisma follower calc"
```

---

### Task 5: 疲勞系統

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: sim_runner.gd — 加疲勞常數與累積**

在 SimRunner class 頂部加：
```gdscript
const FATIGUE_PER_TICK: float    = 0.002   # TEST VALUE
const FATIGUE_RECOVERY: float    = 0.01    # TEST VALUE
const FATIGUE_LOYALTY_PENALTY: float = 0.005  # TEST VALUE

const TERRAIN_FATIGUE_MULT: Dictionary = {
    "plains": 1.0, "forest": 1.2, "mountain": 1.4
}
```

在 `advance_tick` 的 `_step6_resolve_consumption` 後加：
```gdscript
_step6d_fatigue(state, near_teams)
```

加函數：
```gdscript
func _step6d_fatigue(state: WorldState, team_ids: Array) -> void:
    var time_mult: float = _get_time_fatigue_mult(state)
    for tid in team_ids:
        var team: TeamData = state.teams.get(tid)
        if team == null: continue
        if team.current_task == "rest":
            # 紮營休息
            var rest_mult: float = 1.0 - team.guard_ratio * 0.5
            team.fatigue -= FATIGUE_RECOVERY * rest_mult
            team.fatigue = maxf(team.fatigue, 0.0)
        else:
            var tile = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
            var terrain: String = tile.terrain if tile else "plains"
            var terrain_mult: float = TERRAIN_FATIGUE_MULT.get(terrain, 1.0)
            team.fatigue += FATIGUE_PER_TICK * terrain_mult * time_mult
            team.fatigue = minf(team.fatigue, 1.0)
        if team.fatigue >= 1.0:
            for pid in team.named_members:
                var p: PersonData = state.persons.get(pid)
                if p: p.loyalty -= FATIGUE_LOYALTY_PENALTY

func _get_time_fatigue_mult(state: WorldState) -> float:
    # 簡化版（完整版在 day-night-cycle plan 實裝）
    return 1.0
```

- [ ] **Step 2: movement_system.gd — 讀取疲勞速度懲罰**

找到 movement_system.gd 計算 team 移動速度的地方，在速度計算後加：
```gdscript
# 疲勞懲罰
if team.fatigue >= 1.0:
    speed *= 0.3
elif team.fatigue > 0.5:
    speed *= (1.0 - team.fatigue * 0.4)
```

- [ ] **Step 3: headless_test.gd 加疲勞驗證**

```gdscript
# 200 tick 後，移動中的 team 應有疲勞累積
var _ft: TeamData = state.teams.get(0)
if _ft:
    print("[TeamAI] Team0 fatigue=%.4f（預期 > 0）" % _ft.fatigue)
    assert(_ft.fatigue > 0.0, "移動 team 應有疲勞累積")
```

- [ ] **Step 4: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "TeamAI.*fatigue|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/sim_runner.gd scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(team-ai): add fatigue accumulation and movement penalty"
```

---

### Task 6: 負重系統

**Files:**
- Modify: `scripts/simulation/movement_system.gd`

- [ ] **Step 1: movement_system.gd — 加負重常數**

```gdscript
const BASE_CARRY: float   = 10.0   # TEST VALUE
const MOUNT_BONUS: float  = 15.0   # TEST VALUE
const WAGON_BONUS: float  = 40.0   # TEST VALUE
const STRAY_RATE: float   = 0.1    # TEST VALUE 超額馱獸流失率

const WAGON_TERRAIN_MULT: Dictionary = {
    "plains": 0.9, "forest": 0.4, "mountain": 0.2
}
```

- [ ] **Step 2: movement_system.gd — 加負重計算函數**

```gdscript
func get_effective_mounts(team: TeamData) -> int:
    return mini(int(team.resources.get("mounts", 0)), team.population)

func get_effective_wagons(team: TeamData) -> int:
    return mini(int(team.resources.get("wagons", 0)), team.population)

func get_carry_capacity(team: TeamData) -> float:
    return team.population * BASE_CARRY \
        + get_effective_mounts(team) * MOUNT_BONUS \
        + get_effective_wagons(team) * WAGON_BONUS

func calc_total_weight(team: TeamData) -> float:
    var total: float = 0.0
    for key in team.resources:
        total += float(team.resources[key]) * _resource_weight(key)
    return total

func _resource_weight(key: String) -> float:
    match key:
        "food":              return 0.1
        "weapon_melee_low":  return 2.0
        "weapon_melee_high": return 3.0
        "armor_low":         return 4.0
        "armor_high":        return 7.0
        "mounts", "wagons":  return 0.0  # 搬運工具本身不計重
        _:                   return 1.0
```

- [ ] **Step 3: movement_system.gd — 超額馱獸流失（每 tick）**

在現有 tick 函數中加：
```gdscript
func _tick_stray_mounts(team: TeamData) -> void:
    var excess: int = int(team.resources.get("mounts", 0)) - team.population
    if excess > 0:
        team.resources["mounts"] = int(team.resources["mounts"]) - ceili(excess * STRAY_RATE)
```

並在 movement_system 的主 tick 呼叫中加此函數。

- [ ] **Step 4: movement_system.gd — 速度懲罰（超載）**

在速度計算後（Task 5 疲勞懲罰之後）加：
```gdscript
var cap: float = get_carry_capacity(team)
var weight: float = calc_total_weight(team)
if weight > cap:
    speed *= (cap / weight)

# 車輛地形懲罰
var wagons: int = get_effective_wagons(team)
if wagons > 0:
    var tile = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
    var terrain: String = tile.terrain if tile else "plains"
    speed *= WAGON_TERRAIN_MULT.get(terrain, 1.0)
```

- [ ] **Step 5: headless_test.gd 加驗證**

```gdscript
var _ms := load("res://scripts/simulation/movement_system.gd").new()
var _wt: TeamData = state.teams.get(0)
var _cap: float = _ms.get_carry_capacity(_wt)
print("[TeamAI] Team0 carry_cap=%.1f weight=%.1f" % [_cap, _ms.calc_total_weight(_wt)])
assert(_cap > 0.0, "carry capacity 應 > 0")
```

- [ ] **Step 6: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "TeamAI|SCRIPT ERROR|DONE"
```

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/movement_system.gd scripts/debug/headless_test.gd
git commit -m "feat(team-ai): add carry capacity, stray mount, wagon terrain penalty"
```

---

### Task 7: 極端事件 loyalty 懲罰（loot / execute_prisoner）

**Files:**
- Modify: `scripts/simulation/events/event_unrest_split.gd`（或新 event 檔）
- Modify: `scripts/simulation/interaction_system.gd`

- [ ] **Step 1: interaction_system.gd — loot 時觸發 loyalty 懲罰**

找到 interaction_system.gd 中處理 loot/掠奪 的地方，加：
```gdscript
# loot 結算後，全 named_members loyalty 懲罰
for pid in team.named_members:
    var p: PersonData = state.persons.get(pid)
    if p == null: continue
    var yi_qi: float = float(p.values.get("義氣", 0.5))
    p.loyalty -= (1.0 - yi_qi) * 0.05
```

- [ ] **Step 2: interaction_system.gd — execute_prisoner 後懲罰**

找到處決俘虜的邏輯（或在 interaction_system 中的殺死俘虜邏輯），加：
```gdscript
# 處決俘虜：全 named_members witnessed_atrocity loyalty 懲罰
for pid in team.named_members:
    var p: PersonData = state.persons.get(pid)
    if p == null: continue
    var yi_qi: float = float(p.values.get("義氣", 0.5))
    p.loyalty -= yi_qi * 0.08
```

- [ ] **Step 3: 執行測試（無新驗證，確認不崩）**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/interaction_system.gd
git commit -m "feat(team-ai): add loyalty penalties for loot and execute_prisoner events"
```
