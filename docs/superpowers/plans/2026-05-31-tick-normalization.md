# Tick Normalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將 TICKS_PER_DAY 從 24 改為 240、MAP_RADIUS 從 10 改為 12，並將所有 tick 常數改用 TICKS_PER_HOUR/DAY 表達，使時間系統自動縮放。

**Architecture:** 分層修改：先改 WorldState const（其他系統依賴它），再改遭遇戰地圖大小，再修正 instance var 殘留，最後批次正規化各系統的 interval 常數。每個 task 後跑 headless_test 驗證。

**Tech Stack:** Godot 4.2.2 GDScript，headless 測試指令見各 task。

---

## 檔案清單

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | TICKS_PER_DAY 24→240，ticks_per_day 改為 alias |
| `scripts/simulation/encounter_system.gd` | MAP_RADIUS 10→12 |
| `scripts/simulation/day_night_system.gd` | state.ticks_per_day → WorldState.TICKS_PER_DAY |
| `scripts/simulation/sim_runner.gd` | FAR_ZONE_INTERVAL、% 6、近區批次、state.ticks_per_day |
| `scripts/simulation/strategic_ai_system.gd` | STRATEGIC_INTERVAL、ALLIANCE_CHECK_INTERVAL |
| `scripts/simulation/diplomatic_ai_system.gd` | BETRAY_CHECK_INTERVAL |
| `scripts/simulation/reaction_system.gd` | GOAL_CHECK_INTERVAL |
| `scripts/simulation/faction_ai_system.gd` | COLLECT_INTERVAL、hardcoded % 20 |
| `scripts/simulation/message_system.gd` | TIME_DECAY_PER_HOUR + TIME_DECAY_PER_TICK |
| `scripts/debug/headless_test.gd` | 更新 ticks_per_day 斷言值 |

---

## Task 1：WorldState — TICKS_PER_DAY 24 → 240

**Files:**
- Modify: `scripts/data/world_state.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1：修改 world_state.gd**

```gdscript
# scripts/data/world_state.gd — 找到這幾行並修改
const TICKS_PER_DAY:    int   = 240          # 舊: 24
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24   # 自動 = 10
const TICKS_PER_MONTH:  int   = TICKS_PER_DAY * 30   # 自動 = 7200
const TICKS_PER_SEASON: int   = TICKS_PER_DAY * 90   # 自動 = 21600
const TICKS_PER_YEAR:   int   = TICKS_PER_DAY * 360  # 自動 = 86400

# instance var 改為讀 const（保持相容性）
var ticks_per_day: int:
    get: return TICKS_PER_DAY
```

- [ ] **Step 2：更新 headless_test.gd 斷言**

找到並修改：
```gdscript
# scripts/debug/headless_test.gd line ~918
assert(state.ticks_per_day == 240, "ticks_per_day 應為 240")   # 舊: == 24
```

- [ ] **Step 3：跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-Object -Last 20
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4：Commit**

```
git add scripts/data/world_state.gd scripts/debug/headless_test.gd
git commit -m "feat(time): TICKS_PER_DAY 24→240, ticks_per_day alias"
```

---

## Task 2：EncounterSystem — MAP_RADIUS 10 → 12

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`

- [ ] **Step 1：修改常數**

```gdscript
# scripts/simulation/encounter_system.gd — 找到並修改
const MAP_RADIUS:   int = 12     # 舊: 10
const MAP_DIAMETER: int = MAP_RADIUS * 2   # 自動 = 24
```

`BASE_ACTION_TICKS` 不動（= 10）。`BASE_MOVE_TICKS` 在 movement_system 由 `BASE_ACTION_TICKS * MAP_DIAMETER` 自動計算，不需手動改（新值自動 = 10×24 = 240）。

- [ ] **Step 2：跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-Object -Last 20
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3：Commit**

```
git add scripts/simulation/encounter_system.gd
git commit -m "feat(encounter): MAP_RADIUS 10→12"
```

---

## Task 3：修正 state.ticks_per_day 殘留引用

**Files:**
- Modify: `scripts/simulation/day_night_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1：修改 day_night_system.gd**

```gdscript
# scripts/simulation/day_night_system.gd
# 舊（兩行）：
#   return float(state.world.current_tick % state.ticks_per_day) / \
#       float(state.ticks_per_day)
# 新：
    return float(state.world.current_tick % WorldState.TICKS_PER_DAY) / \
        float(WorldState.TICKS_PER_DAY)
```

- [ ] **Step 2：修改 sim_runner.gd（state.ticks_per_day 兩處）**

```gdscript
# scripts/simulation/sim_runner.gd line ~65
# 舊：
#   if state.world.current_tick % state.ticks_per_day == 0:
#       print("[DayNight] Day %d 開始" % (state.world.current_tick / state.ticks_per_day))
# 新：
    if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
        print("[DayNight] Day %d 開始" % (state.world.current_tick / WorldState.TICKS_PER_DAY))
```

- [ ] **Step 3：Grep 確認無殘留**

```powershell
grep -rn "state\.ticks_per_day" scripts/ --include="*.gd"
```

預期：只剩 headless_test.gd 的 print 行（`state.ticks_per_day=%d`），其餘全部清除。

- [ ] **Step 4：跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-Object -Last 20
```

預期：`=== DONE ===`。

- [ ] **Step 5：Commit**

```
git add scripts/simulation/day_night_system.gd scripts/simulation/sim_runner.gd
git commit -m "fix(time): replace state.ticks_per_day with WorldState.TICKS_PER_DAY const"
```

---

## Task 4：sim_runner — FAR_ZONE_INTERVAL、% 6、近區批次化

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1：更新 FAR_ZONE_INTERVAL 常數**

```gdscript
# scripts/simulation/sim_runner.gd 頂部
const FAR_ZONE_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時 = 100 ticks
```

- [ ] **Step 2：將近區系統包進 TICKS_PER_HOUR 條件，並移出 % 6**

`advance_tick` 函數中，現有結構：
```gdscript
# 目前（near 區直接跑，harvest 在內部 % 6）：
var near_teams := _get_near_teams(...)
var far_teams  := _get_far_teams(...)
_step1b_update_vision(state, near_teams, time_vision_mult)
_step1c_update_equipment(state, near_teams)
var arrived_near := _step2_move_teams(state, near_teams, time_speed_mult)
_step3_propagate_messages(state, arrived_near, near_teams)
_step4_resolve_interactions(state, arrived_near, near_teams)
_step4b_outpost_tick(state)
_step4c_harvest_tick(state)     # 內部有 % 6
_step5_collect_resources(state, near_teams)
_step5a_regenerate_tiles(state)
_step5b_manufacture(state, near_teams)
_step6_resolve_consumption(state, near_teams)
_step6c_salary(state, near_teams)
_step6d_fatigue(state, near_teams)
_step6b_faction_ai(state, near_teams)
_step6e_strategic_ai(state)
_step7_person_reactions(state, near_teams)
_step7b_npc_goal_cleanup(state, near_teams)
_step8_generate_events(state, near_teams)
_step9_emit_messages(state)

if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
    ...
```

改成：
```gdscript
var near_teams := _get_near_teams(state, player_pos)
var far_teams  := _get_far_teams(state, player_pos)

# 近區：每小時執行
if state.world.current_tick % WorldState.TICKS_PER_HOUR == 0:
    _step1b_update_vision(state, near_teams, time_vision_mult)
    _step1c_update_equipment(state, near_teams)
    var arrived_near := _step2_move_teams(state, near_teams, time_speed_mult)
    _step3_propagate_messages(state, arrived_near, near_teams)
    _step4_resolve_interactions(state, arrived_near, near_teams)
    _step4b_outpost_tick(state)
    _step5_collect_resources(state, near_teams)
    _step5a_regenerate_tiles(state)
    _step5b_manufacture(state, near_teams)
    _step6_resolve_consumption(state, near_teams)
    _step6c_salary(state, near_teams)
    _step6d_fatigue(state, near_teams)
    _step6b_faction_ai(state, near_teams)
    _step6e_strategic_ai(state)
    _step7_person_reactions(state, near_teams)
    _step7b_npc_goal_cleanup(state, near_teams)
    _step8_generate_events(state, near_teams)
    _step9_emit_messages(state)

# Harvest：每 6 小時（移出近區批次，獨立判斷）
if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:
    _step4c_harvest_tick(state)

if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
    ...（遠區不變）
```

同時修改 `_step1_advance_time` 函數（turn 計數在此，每 tick 都跑含遭遇戰）：
```gdscript
func _step1_advance_time(state: WorldState) -> void:
    state.world.current_tick += 1
    if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:  # 每 6 小時
        state.world.current_turn += 1
```

同時修改 `_step4c_harvest_tick` 函數，移除內部 `% 6` 條件（外層已做判斷）：
```gdscript
func _step4c_harvest_tick(state: WorldState) -> void:
    _harvest_system.tick_all(state)   # 移除內部 % 6 判斷
```

- [ ] **Step 3：跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-Object -Last 20
```

預期：`=== DONE ===`。

- [ ] **Step 4：Commit**

```
git add scripts/simulation/sim_runner.gd
git commit -m "feat(sim): near-zone hourly batching, normalize FAR_ZONE_INTERVAL"
```

---

## Task 5：正規化各系統 *_INTERVAL 常數

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/simulation/diplomatic_ai_system.gd`
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/simulation/faction_ai_system.gd`

- [ ] **Step 1：strategic_ai_system.gd**

```gdscript
const STRATEGIC_INTERVAL:      int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
const ALLIANCE_CHECK_INTERVAL: int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
```

- [ ] **Step 2：diplomatic_ai_system.gd**

```gdscript
const BETRAY_CHECK_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時
```

- [ ] **Step 3：reaction_system.gd**

```gdscript
const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
```

- [ ] **Step 4：faction_ai_system.gd**

```gdscript
const COLLECT_INTERVAL:        int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
const FACTION_UPDATE_INTERVAL: int = 20 * WorldState.TICKS_PER_HOUR  # 每 20 小時（新常數）
```

找到 hardcoded `% 20` 行（line ~39），改為：
```gdscript
if state.world.current_tick % FACTION_UPDATE_INTERVAL == 0:
```

- [ ] **Step 5：跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-Object -Last 20
```

預期：`=== DONE ===`。

- [ ] **Step 6：Commit**

```
git add scripts/simulation/strategic_ai_system.gd scripts/simulation/diplomatic_ai_system.gd scripts/simulation/reaction_system.gd scripts/simulation/faction_ai_system.gd
git commit -m "feat(time): normalize *_INTERVAL constants to TICKS_PER_HOUR"
```

---

## Task 6：message_system — TIME_DECAY per-hour 化

**Files:**
- Modify: `scripts/simulation/message_system.gd`

- [ ] **Step 1：修改常數定義**

```gdscript
# scripts/simulation/message_system.gd 頂部
# 舊：
# const TIME_DECAY_PER_TICK: float = 0.005
# 新：
const TIME_DECAY_PER_HOUR: float = 0.005   # 每小時衰減（不變）
const TIME_DECAY_PER_TICK: float = TIME_DECAY_PER_HOUR / float(WorldState.TICKS_PER_HOUR)
# 新值 = 0.005 / 10 = 0.0005
```

`TIME_DECAY_PER_TICK` 名稱和用法保留，其他地方不需改。

- [ ] **Step 2：跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-Object -Last 20
```

預期：`=== DONE ===`。

- [ ] **Step 3：Commit**

```
git add scripts/simulation/message_system.gd
git commit -m "feat(time): TIME_DECAY expressed as per-hour rate"
```

---

## Task 7：最終驗證與清理

- [ ] **Step 1：Grep 殘留硬編碼**

```powershell
# 確認無殘留的舊值
grep -rn "TICKS_PER_DAY\s*=\s*24\b" scripts/ --include="*.gd"
grep -rn "MAP_RADIUS\s*=\s*10\b" scripts/ --include="*.gd"
grep -rn "% 6\b" scripts/simulation/sim_runner.gd
grep -rn "% 20\b" scripts/simulation/faction_ai_system.gd
```

預期：全部無輸出。

- [ ] **Step 2：驗證 movement_system BASE_MOVE_TICKS**

```powershell
grep -n "BASE_MOVE_TICKS\|BASE_ACTION_TICKS\|MAP_DIAMETER" scripts/simulation/movement_system.gd
```

確認 `BASE_MOVE_TICKS = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER`（= 10×24 = 240 = 1 天/格）。

- [ ] **Step 3：完整 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `=== DONE ===`，無 `SCRIPT ERROR`
- `TimeConstants OK — TICKS_PER_DAY=240 MONTH=7200 SEASON=21600 YEAR=86400`
- `[Trade]`、`[FactionAI]` 等 print 出現（1000 ticks ≈ 4.2 天，基本事件仍觸發）

- [ ] **Step 4：寫 hand-back 文件**

建立 `docs/superpowers/handbacks/2026-05-31-tick-normalization.md`：

```markdown
# Hand Back: Tick Normalization

## 實作摘要
- `world_state.gd`：TICKS_PER_DAY 24→240，ticks_per_day 改為 alias property
- `encounter_system.gd`：MAP_RADIUS 10→12，MAP_DIAMETER 自動→24
- `day_night_system.gd`、`sim_runner.gd`：state.ticks_per_day → WorldState.TICKS_PER_DAY
- `sim_runner.gd`：近區包進 TICKS_PER_HOUR 批次，FAR_ZONE_INTERVAL 正規化，% 6 → TICKS_PER_DAY/4
- `strategic_ai_system.gd`、`diplomatic_ai_system.gd`、`reaction_system.gd`、`faction_ai_system.gd`：所有 *_INTERVAL 改用 TICKS_PER_HOUR 倍數
- `message_system.gd`：TIME_DECAY 改為 per-hour 推算

## 連動風險
- headless_test 跑 1000 ticks = 4.2 天（原 41.7 天），月薪/季節事件不在 1000 tick 內觸發，需增加 tick 數才能完整測試長期行為
- 遭遇戰地圖 tile 數：331→469（+42%），如有 tile 遍歷效能問題請查 encounter_system
- BASE_MOVE_TICKS 現為 240（= 1 天/格），移動相關 UI 顯示（如 ETA）若有假設舊值需確認

## 待主 session 確認
- headless_test tick 數是否要增加到 7200（1 個月）以覆蓋薪資測試？
```

- [ ] **Step 5：Commit hand-back**

```
git add docs/superpowers/handbacks/2026-05-31-tick-normalization.md
git commit -m "docs: add tick normalization hand-back"
git push -u origin feat/tick-normalization
```
