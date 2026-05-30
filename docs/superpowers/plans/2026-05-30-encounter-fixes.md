# 遭遇戰修正 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修正四個遭遇戰核心問題：俘虜欄位分離、spawn 改用武裝比例、sim_runner 切換 action-timer 路徑、advance_round 退役。

**Architecture:** 全後端修正，不動 UI。完成後 headless test 必須通過，且遭遇戰 unit 數量可控（不再出現 1000+ unit）。

**Tech Stack:** Godot 4.2.2, GDScript.

**依賴：** `2026-05-30-encounter-core-systems.md` 已完成（HealthSystem、advance_encounter_tick 已存在）。

---

## File Map

| Action | File |
|---|---|
| Modify | `scripts/data/team_data.gd` |
| Modify | `scripts/simulation/encounter_system.gd` |
| Modify | `scripts/simulation/sim_runner.gd` |
| Modify | `scripts/debug/headless_test.gd` |

---

## Task 1: TeamData — prisoner_population 欄位

**Files:**
- Modify: `scripts/data/team_data.gd`

- [ ] **Step 1: 驗證 baseline**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 2: 加 prisoner_population 欄位**

在 `scripts/data/team_data.gd`，`var minor_population: int = 0` 下方加：

```gdscript
var prisoner_population: int = 0   # 俘虜（上限 = population；不計入戰鬥 spawn）
```

- [ ] **Step 3: 執行 import**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 4: Commit**

```
git add scripts/data/team_data.gd
git commit -m "feat(data): add prisoner_population field to TeamData"
```

---

## Task 2: EncounterSystem — 俘虜存入 prisoner_population

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`

- [ ] **Step 1: 修正 resolve_encounter_end 俘虜邏輯**

找到 `resolve_encounter_end` 內的俘虜結算區塊（約 line 839–844）：

```gdscript
# 舊
for u in state.encounter_units:
    if not u.get("is_prisoner", false): continue
    if u["team_id"] != loser_id: continue
    if winner_team:
        winner_team.population += 1
        print("[Encounter] 俘虜加入 Team%d" % winner_id)
```

改為：

```gdscript
# 新：俘虜存入 prisoner_population，上限 = winner population
for u in state.encounter_units:
    if not u.get("is_prisoner", false): continue
    if u["team_id"] != loser_id: continue
    if winner_team == null: continue
    if winner_team.prisoner_population < winner_team.population:
        winner_team.prisoner_population += 1
        print("[Encounter] 俘虜收押 Team%d（總計 %d）" % [
            winner_id, winner_team.prisoner_population])
    else:
        print("[Encounter] 俘虜超額，釋放")
```

- [ ] **Step 2: 跑 headless test 確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): prisoners go to prisoner_population, not population"
```

---

## Task 3: EncounterSystem — spawn 改用 armed_anon_ratio + cap

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`

spawn 邏輯問題：`for _i in range(team.population)` 1:1 spawn，population 幾百時 → 幾百 unit → O(n²) 卡死。

修正：只 spawn **武裝**匿名人口，加硬上限。

- [ ] **Step 1: 加常數**

在 `encounter_system.gd` 頂部常數區加：

```gdscript
const ANON_UNIT_CAP: int = 30   # TEST VALUE — 每隊匿名 unit 最多 30 個
```

- [ ] **Step 2: 修改 `_spawn_team_units`**

找到（約 line 777）：

```gdscript
func _spawn_team_units(state: WorldState, team: TeamData,
        positions: Array) -> void:
    var pos_idx: int = 0
    var named_ids: Array = ([team.leader_id] as Array) + team.named_members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var pos: Vector2i = positions[pos_idx % positions.size()]
        pos_idx += 1
        var unit: Dictionary = _create_named_unit(pid, team.team_id, pos, state)
        _init_named_unit(unit, p, team, state)
        state.encounter_units.append(unit)
    for _i in range(team.population):
        var pos: Vector2i = positions[pos_idx % positions.size()]
        pos_idx += 1
        var unit: Dictionary = _create_anon_unit(team, pos)
        _init_anon_unit(unit, team, state)
        state.encounter_units.append(unit)
```

改為：

```gdscript
func _spawn_team_units(state: WorldState, team: TeamData,
        positions: Array) -> void:
    var pos_idx: int = 0
    # 具名成員（全部 spawn）
    var named_ids: Array = ([team.leader_id] as Array) + team.named_members
    for pid in named_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var pos: Vector2i = positions[pos_idx % positions.size()]
        pos_idx += 1
        var unit: Dictionary = _create_named_unit(pid, team.team_id, pos, state)
        _init_named_unit(unit, p, team, state)
        state.encounter_units.append(unit)
    # 匿名人口：只 spawn 武裝部分，加硬上限
    # 未成年、俘虜不計入 spawn
    var armed_count: int = int(float(team.population) * team.armed_anon_ratio)
    var spawn_count: int = mini(armed_count, ANON_UNIT_CAP)
    for _i in range(spawn_count):
        var pos: Vector2i = positions[pos_idx % positions.size()]
        pos_idx += 1
        var unit: Dictionary = _create_anon_unit(team, pos)
        _init_anon_unit(unit, team, state)
        state.encounter_units.append(unit)
    print("[Encounter] Team%d spawn: %d具名 + %d匿名（武裝率%.0f%%，人口%d）" % [
        team.team_id, named_ids.size(), spawn_count,
        team.armed_anon_ratio * 100, team.population])
```

- [ ] **Step 3: 修正 init_encounter position 計算**

找到 init_encounter 內（約 line 179–183）：

```gdscript
var atk_pos := _get_edge_entry_positions(0, atk.population + atk.named_members.size())
var def_pos := _get_edge_entry_positions(3, def.population + def.named_members.size())
```

改為（位置數量跟 spawn 數量一致）：

```gdscript
var atk_anon: int = mini(int(float(atk.population) * atk.armed_anon_ratio), ANON_UNIT_CAP)
var def_anon: int = mini(int(float(def.population) * def.armed_anon_ratio), ANON_UNIT_CAP)
var atk_pos := _get_edge_entry_positions(0, atk.named_members.size() + 1 + atk_anon)
var def_pos := _get_edge_entry_positions(3, def.named_members.size() + 1 + def_anon)
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`，無 `SCRIPT ERROR`，1000 tick 應在 30 秒內完成（不再卡死）。
Print 輸出中每隊 unit 數量應 ≤ named_count + 30。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/encounter_system.gd
git commit -m "fix(encounter): spawn only armed anon units with ANON_UNIT_CAP=30"
```

---

## Task 4: SimRunner — 切換到 advance_encounter_tick，退役 advance_round

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`
- Modify: `scripts/simulation/encounter_system.gd`

- [ ] **Step 1: 更新 sim_runner.gd encounter 分支**

找到（約 line 57–64）：

```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> void:
    if state.encounter_active:
        var round_num: int = state.world.current_tick
        var result: String = _encounter_system.advance_round(state, round_num)
        if result != "ongoing":
            _encounter_system.resolve_encounter_end(state, result)
        _step1_advance_time(state)
        return
```

改為：

```gdscript
func advance_tick(state: WorldState, player_pos: Vector2i) -> void:
    if state.encounter_active:
        var result: String = _encounter_system.advance_encounter_tick(state)
        if result != "ongoing":
            _encounter_system.resolve_encounter_end(state, result)
        _step1_advance_time(state)
        return
```

- [ ] **Step 2: 退役 advance_round**

在 `encounter_system.gd` 找到 `advance_round` 函式，在函式第一行加警告後保留（不刪除，避免外部還有遺留呼叫）：

```gdscript
func advance_round(state: WorldState, _round_num: int) -> String:
    push_warning("advance_round is deprecated — use advance_encounter_tick")
    return advance_encounter_tick(state)
```

- [ ] **Step 3: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。若有 `advance_round is deprecated` 警告，代表還有遺留呼叫點，逐一找出並改掉。

- [ ] **Step 4: Commit**

```
git add scripts/simulation/sim_runner.gd scripts/simulation/encounter_system.gd
git commit -m "fix(sim): switch SimRunner to advance_encounter_tick; deprecate advance_round"
```

---

## Task 5: headless_test 驗證新行為

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 prisoner_population 驗證**

在 headless_test.gd `=== DONE ===` 前加：

```gdscript
    # prisoner_population 驗證
    print("--- prisoner_population ---")
    var _total_prisoners: int = 0
    for _tid in state.teams:
        var _t: TeamData = state.teams[_tid]
        _total_prisoners += _t.prisoner_population
        assert(_t.prisoner_population <= _t.population,
            "prisoner_population 不可超過 population（Team%d）" % _tid)
    print("全域俘虜總數: %d" % _total_prisoners)
    print("prisoner_population OK")
```

- [ ] **Step 2: 加 spawn 數量驗證**

在遭遇戰相關輸出後加確認（不需改動既有斷言，只加 print 觀察）：

```gdscript
    # spawn cap 驗證（觀察用）
    print("--- encounter unit count ---")
    print("遭遇戰 unit 上限確認：每隊 named + max %d anon" % EncounterSystem.ANON_UNIT_CAP)
```

- [ ] **Step 3: 完整跑一次**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
Expected:
- `prisoner_population OK`
- `=== DONE ===`
- 無 `SCRIPT ERROR`
- 1000 tick 在合理時間內完成（< 60 秒）

- [ ] **Step 4: Commit**

```
git add scripts/debug/headless_test.gd
git commit -m "test: add prisoner_population and spawn cap assertions"
```

---

## 完成後 hand-back

寫 `docs/superpowers/handbacks/2026-05-30-encounter-fixes.md`，push branch，finishing Option 3。

---

## ⚠️ 測試值

| 常數 | 值 | 位置 |
|---|---|---|
| `ANON_UNIT_CAP` | 30 | encounter_system.gd |
