# Tick Normalization Design Spec

**Date:** 2026-05-31
**Status:** Awaiting Review

---

## 目標

1. **時間系統校準**：將 `TICKS_PER_DAY` 從 24 改為 240，`MAP_RADIUS` 從 10 改為 12，使時間粒度更細、世界移動速度合理
2. **常數正規化**：所有 `*_INTERVAL` 改用 `TICKS_PER_HOUR` / `TICKS_PER_DAY` 表達，未來調整時自動縮放
3. **近區批次化**：大地圖近區系統改為每小時（`% TICKS_PER_HOUR`）執行，頻率與粒度解耦

遭遇戰系統走獨立路徑（`encounter_active` early return），效能完全不受影響。

---

## 設計決策：新時間比例

| 常數 | 舊值 | 新值 |
|---|---|---|
| `TICKS_PER_DAY` | 24 | **240** |
| `TICKS_PER_HOUR` | 1 | **10** |
| `MAP_RADIUS`（遭遇戰）| 10 | **12** |
| `MAP_DIAMETER`（遭遇戰）| 20 | **24** |
| `BASE_ACTION_TICKS`（遭遇戰）| 10 | 不變 |
| `BASE_MOVE_TICKS`（由耦合自動）| 200 | **240**（= 10×24）|

**結果：**
```
1 tick        = 6 分鐘（game time）
1 小時        = TICKS_PER_HOUR = 10 ticks
1 天          = TICKS_PER_DAY = 240 ticks
遭遇戰 1 action（普通）= 10 ticks = 1 小時
遭遇戰 1 action（最快）= 6 ticks  = 36 分鐘
走 1 世界格   = BASE_MOVE_TICKS = 240 ticks = 1 天 ✓
```

**效能：** 近區每 `TICKS_PER_HOUR=10` ticks 執行一次 → 每天 240/10 = 24 次系統運算（與現在相同）

---

## 常數變更對照表

| 常數 | 舊值（ticks）| 新值（ticks）| 語意 |
|---|---|---|---|
| `TICKS_PER_DAY` | 24 | **240** | — |
| `TICKS_PER_HOUR` | 1 | **10** | — |
| `FAR_ZONE_INTERVAL` | 10 | **100** | 每 10 小時 |
| `% 6`（turn 計數）| 6 | **60** | 每 6 小時（TICKS_PER_DAY/4）|
| `% 6`（harvest）| 6 | **60** | 每 6 小時 |
| `STRATEGIC_INTERVAL` | 10 | **100** | 每 10 小時 |
| `ALLIANCE_CHECK_INTERVAL` | 30 | **300** | 每 30 小時 |
| `BETRAY_CHECK_INTERVAL` | 50 | **500** | 每 50 小時 |
| `GOAL_CHECK_INTERVAL` | 10 | **100** | 每 10 小時 |
| `COLLECT_INTERVAL` | 30 | **300** | 每 30 小時 |
| `FACTION_UPDATE_INTERVAL`（新）| 20 | **200** | 每 20 小時 |
| `TIME_DECAY_PER_TICK` | 0.005 | **0.0005** | 每小時 0.005（不變）|
| `BASE_MOVE_TICKS` | 200 | **240** | 1 天/格（由耦合自動）|
| `OVERFLOW_CHECK_INTERVAL` | 24 | **240** | 每天（自動縮放）|
| `SALARY_INTERVAL` | 720 | **7200** | 每月（自動縮放）|
| `SEASON_LENGTH` | 2160 | **21600** | 每季（自動縮放）|

---

## 修改檔案

### `scripts/data/world_state.gd`
```gdscript
# 舊
const TICKS_PER_DAY:    int   = 24
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24   # = 1
var ticks_per_day: int = 24   # instance var（廢棄）

# 新
const TICKS_PER_DAY:    int   = 240
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24   # = 10
# ticks_per_day instance var 移除
```

### `scripts/simulation/encounter_system.gd`
```gdscript
# 舊
const MAP_RADIUS:    int = 10
const MAP_DIAMETER:  int = MAP_RADIUS * 2   # = 20

# 新
const MAP_RADIUS:    int = 12
const MAP_DIAMETER:  int = MAP_RADIUS * 2   # = 24
# BASE_ACTION_TICKS 不變（= 10）
# BASE_MOVE_TICKS 在 movement_system 自動更新
```

### `scripts/simulation/movement_system.gd`
```gdscript
# BASE_MOVE_TICKS 由耦合自動計算，不需手動改
# 確認公式仍為：
const BASE_MOVE_TICKS: int = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER
# 新值 = 10 × 24 = 240 ✓
```

### `scripts/simulation/day_night_system.gd`
```gdscript
# 舊
float(state.world.current_tick % state.ticks_per_day) / float(state.ticks_per_day)

# 新
float(state.world.current_tick % WorldState.TICKS_PER_DAY) / float(WorldState.TICKS_PER_DAY)
```

### `scripts/simulation/sim_runner.gd`
```gdscript
# 舊
const FAR_ZONE_INTERVAL: int = 10
if state.world.current_tick % state.ticks_per_day == 0: ...
if state.world.current_tick % 6 == 0: state.world.current_turn += 1
if state.world.current_tick % 6 == 0: _harvest_system.tick_all(state)
# 近區：直接跑（每 tick）
_step1b_update_vision(...)
...所有近區步驟（無條件）

# 新
const FAR_ZONE_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # = 100

if state.world.current_tick % WorldState.TICKS_PER_DAY == 0: ...
if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:
    state.world.current_turn += 1
if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:
    _harvest_system.tick_all(state)

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

# 遠區：每 FAR_ZONE_INTERVAL（100 ticks = 10 小時）
if state.world.current_tick % FAR_ZONE_INTERVAL == 0:
    ...（同現有遠區邏輯，不變）
```

### `scripts/simulation/strategic_ai_system.gd`
```gdscript
const STRATEGIC_INTERVAL:      int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時 = 100 ticks
const ALLIANCE_CHECK_INTERVAL: int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時 = 300 ticks
```

### `scripts/simulation/diplomatic_ai_system.gd`
```gdscript
const BETRAY_CHECK_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時 = 500 ticks
```

### `scripts/simulation/reaction_system.gd`
```gdscript
const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時 = 100 ticks
```

### `scripts/simulation/faction_ai_system.gd`
```gdscript
const COLLECT_INTERVAL:        int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時 = 300 ticks
const FACTION_UPDATE_INTERVAL: int = 20 * WorldState.TICKS_PER_HOUR  # 每 20 小時 = 200 ticks（新常數）
# 舊 hardcoded % 20 → 改為 % FACTION_UPDATE_INTERVAL
```

### `scripts/simulation/message_system.gd`
```gdscript
const TIME_DECAY_PER_HOUR: float = 0.005   # 每小時衰減 0.005
const TIME_DECAY_PER_TICK: float = TIME_DECAY_PER_HOUR / float(WorldState.TICKS_PER_HOUR)
# 新值 = 0.005 / 10 = 0.0005（每 tick）
```

---

## headless_test.gd 影響

測試中硬編碼的 tick 數（如 `1000 ticks`）語意從「41.7天」變為「4.17天」。測試邏輯不變，但數值解讀不同。無需修改。

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `=== DONE ===`，無 `SCRIPT ERROR`
- 1000 ticks ≈ 4.2 天（原來 41.7 天），事件/交互仍發生（比例縮短但仍出現）
- `[Trade]`、`[Combat]`、`[FactionAI]` 等 print 仍出現
- 無因 `% 0` 或 division by zero 導致的崩潰

---

## 注意事項

- `WorldState.TICKS_PER_HOUR` 確認已存在（= `TICKS_PER_DAY / 24`）
- `TICKS_PER_DAY / 4 = 60`（整數，無問題）
- `state.ticks_per_day` instance var 全部移除（grep 確認無殘留）
- 遭遇戰地圖 tile 數：R=10→331，R=12→469（+42%），效能可接受
- `BASE_MOVE_TICKS` 由 `encounter_system` 常數自動推算，不需手動設
