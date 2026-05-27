# 日夜循環 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實裝日夜循環：時間段計算、各系統修正（速度/疲勞/視野）、守夜機制、夜間突襲判定。

**Architecture:** 新建 `DayNightSystem` 提供所有衍生值；SimRunner 每 tick 呼叫取得乘數，傳給 MovementSystem、VisionSystem、FatigueSystem。

**Tech Stack:** Godot 4.2.2 GDScript

**依賴：** `2026-05-27-data-structure-update.md`（ticks_per_day、guard_ratio）；`2026-05-27-team-ai-redesign.md`（疲勞系統基礎）。

---

## File Structure

| 動作 | 檔案 |
|---|---|
| Create | `scripts/simulation/day_night_system.gd` |
| Modify | `scripts/simulation/sim_runner.gd` |
| Modify | `scripts/simulation/movement_system.gd` |
| Modify | `scripts/simulation/vision_system.gd` |
| Modify | `scripts/simulation/interaction_system.gd` |
| Modify | `scripts/debug/headless_test.gd` |

---

### Task 1: DayNightSystem — 時間計算與乘數

**Files:**
- Create: `scripts/simulation/day_night_system.gd`

- [ ] **Step 1: 建立 day_night_system.gd**

```gdscript
# scripts/simulation/day_night_system.gd
class_name DayNightSystem

func get_time_of_day(state: WorldState) -> float:
    return float(state.world.current_tick % state.ticks_per_day) / \
        float(state.ticks_per_day)

func get_time_period(state: WorldState) -> String:
    var t: float = get_time_of_day(state)
    if t < 0.1:  return "dawn"
    if t < 0.75: return "day"
    if t < 0.9:  return "dusk"
    return "night"

func get_speed_mult(state: WorldState) -> float:
    match get_time_period(state):
        "day":   return 1.0
        "dawn":  return 0.8
        "dusk":  return 0.8
        "night": return 0.5
    return 1.0

func get_fatigue_mult(state: WorldState) -> float:
    match get_time_period(state):
        "day":   return 1.0
        "dawn":  return 1.2
        "dusk":  return 1.2
        "night": return 1.5
    return 1.0

func get_vision_mult(state: WorldState) -> float:
    match get_time_period(state):
        "day":   return 1.0
        "dawn":  return 0.75
        "dusk":  return 0.75
        "night": return 0.5
    return 1.0
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
var _dns := DayNightSystem.new()
# tick=0, ticks_per_day=24 → time_of_day=0.0 → "dawn"
assert(_dns.get_time_period(state) == "dawn", "tick 0 應為 dawn")
# 驗證 tick 3 → day（3/24=0.125 > 0.1）
var _saved_tick: int = state.world.current_tick
state.world.current_tick = 3
assert(_dns.get_time_period(state) == "day", "tick 3 應為 day")
assert(_dns.get_fatigue_mult(state) == 1.0, "白天疲勞乘數應為 1.0")
state.world.current_tick = 22   # 22/24=0.917 → "night"
assert(_dns.get_time_period(state) == "night", "tick 22 應為 night")
assert(_dns.get_speed_mult(state) == 0.5, "夜間速度乘數應為 0.5")
state.world.current_tick = _saved_tick
print("[DayNight] 時間計算驗證通過")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DayNight|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/day_night_system.gd scripts/debug/headless_test.gd
git commit -m "feat(day-night): add DayNightSystem with time period and multipliers"
```

---

### Task 2: SimRunner — 整合日夜乘數

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1: sim_runner.gd 加 DayNightSystem**

```gdscript
var _day_night_system: DayNightSystem

# 在 _init() 加
_day_night_system = DayNightSystem.new()
```

- [ ] **Step 2: 更新 _get_time_fatigue_mult（已在 team-ai plan 加的 stub）**

找到 sim_runner.gd 的 `_get_time_fatigue_mult` 函數：

```gdscript
# 原 stub 改為
func _get_time_fatigue_mult(state: WorldState) -> float:
    return _day_night_system.get_fatigue_mult(state)
```

- [ ] **Step 3: advance_tick 加時間乘數傳遞**

在 `advance_tick` 頂部加：
```gdscript
var time_speed_mult: float = _day_night_system.get_speed_mult(state)
var time_vision_mult: float = _day_night_system.get_vision_mult(state)
```

將 `time_speed_mult` 傳給 `_step2_move_teams`；將 `time_vision_mult` 傳給 `_step1b_update_vision`。

修改函數簽名：
```gdscript
func _step2_move_teams(state: WorldState, team_ids: Array,
        time_speed_mult: float = 1.0) -> Array:
    # 傳入 movement_system.advance_teams(state, team_ids, time_speed_mult)

func _step1b_update_vision(state: WorldState, team_ids: Array,
        time_vision_mult: float = 1.0) -> void:
    _vision_system.tick_discovery(state, team_ids, time_vision_mult)
```

- [ ] **Step 4: 每天轉換 print**

在 advance_tick 加：
```gdscript
if state.world.current_tick % state.ticks_per_day == 0:
    print("[DayNight] Day %d 開始" % (state.world.current_tick / state.ticks_per_day))
```

- [ ] **Step 5: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DayNight|SCRIPT ERROR|DONE"
```

預期：`[DayNight] Day 1 開始` 等 print 出現

- [ ] **Step 6: Commit**

```powershell
git add scripts/simulation/sim_runner.gd
git commit -m "feat(day-night): integrate day/night multipliers into SimRunner"
```

---

### Task 3: MovementSystem — 時間速度修正

**Files:**
- Modify: `scripts/simulation/movement_system.gd`

- [ ] **Step 1: movement_system.gd — advance_teams 加 time_mult 參數**

找到 movement_system.gd 的主推進函數，加 `time_mult: float = 1.0` 參數，並在速度計算中乘入：

```gdscript
func advance_teams(state: WorldState, team_ids: Array,
        time_mult: float = 1.0) -> Array:
    var arrived: Array = []
    for tid in team_ids:
        var team: TeamData = state.teams.get(tid)
        if team == null: continue
        var speed: float = _calc_team_speed(state, team) * time_mult
        # ... 原有移動邏輯 ...
    return arrived
```

- [ ] **Step 2: 執行測試確認無崩潰**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/movement_system.gd
git commit -m "feat(day-night): pass time_mult to MovementSystem"
```

---

### Task 4: VisionSystem — 時間視野修正

**Files:**
- Modify: `scripts/simulation/vision_system.gd`

- [ ] **Step 1: vision_system.gd — tick_discovery 加 time_vision_mult 參數**

```gdscript
func tick_discovery(state: WorldState, team_ids: Array,
        time_vision_mult: float = 1.0) -> void:
    for tid in team_ids:
        # ...
        var vrange: int = roundi((VISION_RADIUS + scout * SCOUT_BONUS) * vmult * time_vision_mult)
        # ...
```

- [ ] **Step 2: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/vision_system.gd
git commit -m "feat(day-night): pass time_vision_mult to VisionSystem"
```

---

### Task 5: 守夜機制 — camp_vision_range 與夜間突襲

**Files:**
- Modify: `scripts/simulation/day_night_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`

- [ ] **Step 1: day_night_system.gd — 加守夜函數**

```gdscript
func get_guards(state: WorldState, team: TeamData) -> Array:
    var guard_count: int = ceili(team.population * team.guard_ratio)
    var scored: Array = []
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        scored.append({ "id": pid, "scout": float(p.skills.get("偵查", 0.0)) })
    scored.sort_custom(func(a, b): return a["scout"] > b["scout"])
    var guards: Array = []
    for i in range(mini(guard_count, scored.size())):
        guards.append(scored[i]["id"])
    return guards

func get_camp_vision_range(state: WorldState, team: TeamData) -> int:
    var guards: Array = get_guards(state, team)
    if guards.size() == 0: return 0
    var total_scout: float = 0.0
    for pid in guards:
        var p: PersonData = state.persons.get(pid)
        if p: total_scout += float(p.skills.get("偵查", 0.0))
    var avg_scout: float = total_scout / guards.size()
    var base: int = 3   # VisionSystem.VISION_RADIUS (避免跨系統依賴)
    return roundi((base + avg_scout * 2.0) * get_vision_mult(state))
```

- [ ] **Step 2: interaction_system.gd — 夜間突襲觸發**

在 `_try_interact` 或遭遇觸發檢查開頭加：

```gdscript
func _check_night_raid(state: WorldState, attacker: TeamData,
        defender: TeamData) -> bool:
    var dns := DayNightSystem.new()
    if defender.current_task != "rest": return false
    if dns.get_camp_vision_range(state, defender) > 0: return false
    return true
# 若 _check_night_raid 返回 true，觸發追擊戰模式（combat_type = "pursuit"）
```

- [ ] **Step 3: headless_test.gd 加驗證**

```gdscript
var _dns2 := DayNightSystem.new()
var _rest_team: TeamData = state.teams.get(2)
_rest_team.current_task = "rest"
_rest_team.guard_ratio = 0.0
var _cvr: int = _dns2.get_camp_vision_range(state, _rest_team)
assert(_cvr == 0, "無守夜 → camp_vision_range 應為 0")
_rest_team.guard_ratio = 0.5
_cvr = _dns2.get_camp_vision_range(state, _rest_team)
print("[DayNight] guard_ratio=0.5 camp_vision_range=%d" % _cvr)
```

- [ ] **Step 4: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DayNight|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/day_night_system.gd scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(day-night): add guard system, camp_vision_range, night raid trigger"
```
