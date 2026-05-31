# Tick Normalization Design Spec

**Date:** 2026-05-31
**Status:** Awaiting Review

---

## 目標

將所有非遭遇戰的固定 tick 常數，改用 `WorldState.TICKS_PER_HOUR` 或 `WorldState.TICKS_PER_DAY` 表達，使未來調整 `TICKS_PER_DAY` 時各系統自動縮放。

**不在範圍：**
- 遭遇戰相關（`BASE_ACTION_TICKS`、`MAP_RADIUS`、`HP_REGEN_PER_TICK`、`BLOOD_REGEN_PER_TICK`、`PRISONER_CHECK_INTERVAL`）
- `BASE_MOVE_TICKS`：保留 `BASE_ACTION_TICKS × MAP_DIAMETER` 的耦合（遭遇戰與大地圖同步縮放）

---

## 現有常數與現值

| 檔案 | 常數/用法 | 現值 | 語意（TICKS_PER_DAY=24時）|
|---|---|---|---|
| `world_state.gd` | `ticks_per_day`（instance var）| 24 | 與 const 重複 |
| `day_night_system.gd` | `state.ticks_per_day` | 讀 instance var | 應改讀 const |
| `sim_runner.gd` | `FAR_ZONE_INTERVAL = 10` | 10 ticks | 每 10 小時 |
| `sim_runner.gd` | `% 6`（turn 計數，line 126）| 6 ticks | 每 6 小時（= 1天/4） |
| `sim_runner.gd` | `% 6`（harvest，line 146）| 6 ticks | 每 6 小時 |
| `sim_runner.gd` | `state.ticks_per_day`（line 65）| 讀 instance var | 應改讀 const |
| `strategic_ai_system.gd` | `STRATEGIC_INTERVAL = 10` | 10 ticks | 每 10 小時 |
| `strategic_ai_system.gd` | `ALLIANCE_CHECK_INTERVAL = 30` | 30 ticks | 每 30 小時 |
| `diplomatic_ai_system.gd` | `BETRAY_CHECK_INTERVAL = 50` | 50 ticks | 每 50 小時 |
| `reaction_system.gd` | `GOAL_CHECK_INTERVAL = 10` | 10 ticks | 每 10 小時 |
| `faction_ai_system.gd` | `COLLECT_INTERVAL = 30` | 30 ticks | 每 30 小時 |
| `faction_ai_system.gd` | hardcoded `% 20`（line 39）| 20 ticks | 每 20 小時 |
| `message_system.gd` | `TIME_DECAY_PER_TICK = 0.005` | per tick | 每天衰減 0.12 |

---

## 修改方式

### 原則

- 「幾小時一次」→ `X * WorldState.TICKS_PER_HOUR`
- 「幾天一次」→ `X * WorldState.TICKS_PER_DAY`（已有 SALARY_INTERVAL 等先例）
- per-tick 速率 → 改為 per-day，除以 `TICKS_PER_DAY`（已有 `FOOD_PER_PERSON_PER_DAY` 先例）
- instance var `ticks_per_day` → 全部換成 const `WorldState.TICKS_PER_DAY`

### 各檔案變更

#### `scripts/data/world_state.gd`
```gdscript
# 移除（或保留但不使用）
# var ticks_per_day: int = 24
# TICKS_PER_HOUR 已存在 = TICKS_PER_DAY / 24，確認有此行即可
```

#### `scripts/simulation/day_night_system.gd`
```gdscript
# 舊
float(state.world.current_tick % state.ticks_per_day) / float(state.ticks_per_day)

# 新
float(state.world.current_tick % WorldState.TICKS_PER_DAY) / float(WorldState.TICKS_PER_DAY)
```

#### `scripts/simulation/sim_runner.gd`
```gdscript
# 舊
const FAR_ZONE_INTERVAL: int = 10
...
if state.world.current_tick % state.ticks_per_day == 0:
...
if state.world.current_tick % 6 == 0:  # turn 計數（兩處）

# 新
const FAR_ZONE_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
...
if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
...
if state.world.current_tick % (WorldState.TICKS_PER_DAY / 4) == 0:  # 每 6 小時（兩處）
```

#### `scripts/simulation/strategic_ai_system.gd`
```gdscript
# 舊
const STRATEGIC_INTERVAL: int    = 10
const ALLIANCE_CHECK_INTERVAL: int = 30

# 新
const STRATEGIC_INTERVAL: int      = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
const ALLIANCE_CHECK_INTERVAL: int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
```

#### `scripts/simulation/diplomatic_ai_system.gd`
```gdscript
# 舊
const BETRAY_CHECK_INTERVAL: int = 50

# 新
const BETRAY_CHECK_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時
```

#### `scripts/simulation/reaction_system.gd`
```gdscript
# 舊
const GOAL_CHECK_INTERVAL: int = 10

# 新
const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
```

#### `scripts/simulation/faction_ai_system.gd`
```gdscript
# 舊
const COLLECT_INTERVAL: int = 30
...
if state.world.current_tick % 20 == 0:

# 新
const COLLECT_INTERVAL: int = 30 * WorldState.TICKS_PER_HOUR  # 每 30 小時
const FACTION_UPDATE_INTERVAL: int = 20 * WorldState.TICKS_PER_HOUR  # 新常數，每 20 小時
...
if state.world.current_tick % FACTION_UPDATE_INTERVAL == 0:
```

#### `scripts/simulation/message_system.gd`
```gdscript
# 舊
const TIME_DECAY_PER_TICK: float = 0.005

# 新
const TIME_DECAY_PER_DAY: float  = 0.12   # 原 0.005 × 24（行為不變）
const TIME_DECAY_PER_TICK: float = TIME_DECAY_PER_DAY / float(WorldState.TICKS_PER_DAY)
```

**注意：** `TIME_DECAY_PER_TICK` 這個名稱保留，用法不變（其他地方直接用它），只是改成從 per-day 推算。

---

## 行為驗證

此次修改為**純重構**，`TICKS_PER_DAY = 24` 不變，所有常數數值與目前完全相同：

| 常數 | 舊值（ticks）| 新計算 | 結果 |
|---|---|---|---|
| `FAR_ZONE_INTERVAL` | 10 | `10 × 1` | **10** |
| `% 6` | 6 | `24 / 4` | **6** |
| `STRATEGIC_INTERVAL` | 10 | `10 × 1` | **10** |
| `ALLIANCE_CHECK_INTERVAL` | 30 | `30 × 1` | **30** |
| `BETRAY_CHECK_INTERVAL` | 50 | `50 × 1` | **50** |
| `GOAL_CHECK_INTERVAL` | 10 | `10 × 1` | **10** |
| `COLLECT_INTERVAL` | 30 | `30 × 1` | **30** |
| `FACTION_UPDATE_INTERVAL` | 20 | `20 × 1` | **20** |
| `TIME_DECAY_PER_TICK` | 0.005 | `0.12 / 24` | **0.005** |

`TICKS_PER_HOUR = 1`（當 `TICKS_PER_DAY = 24`），故所有結果不變。

**驗證指令：**
```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`，輸出與重構前相同。

---

## 注意事項

- `WorldState.TICKS_PER_HOUR` 若不存在需補加（確認 world_state.gd 有 `const TICKS_PER_HOUR: int = TICKS_PER_DAY / 24`）
- `TICKS_PER_DAY / 4 = 6`（整數除法，GDScript 無問題）
- 完成後 `state.ticks_per_day` instance var 可標記為 deprecated 或移除，視相容性決定
