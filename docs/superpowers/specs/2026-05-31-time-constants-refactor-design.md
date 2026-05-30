# Time Constants Refactor Design Spec

**Date:** 2026-05-31
**Status:** Approved → Awaiting Plan

---

## 問題

所有時間相關常數都是硬編碼的小數字（SALARY_INTERVAL=30, SEASON_LENGTH=30, BASE_MOVE_TICKS=10 等），為了測試方便，但：
1. 改一個值要找遍多個檔案
2. 不同尺度（天/小時/秒）混在一起，語意不清
3. 正式平衡時無法統一縮放

---

## 時間單位體系

```
1 天  = 24 小時
1 月  = 30 天
1 季  = 3 月  = 90 天
1 年  = 12 月 = 4 季 = 360 天
```

---

## 設計目標

- 一個地方改 `TICKS_PER_DAY`，全部常數等比縮放
- 所有時間常數用具名單位（天/月/季/小時）定義，不用裸數字
- 測試/正式 兩組預設值可快速切換

---

## 核心常數（放 world_state.gd）

```gdscript
# ── 時間基底 ──────────────────────────────────────────────
const TICKS_PER_DAY:    int   = 24           # TEST VALUE（正式: 8640 = 10秒/tick）
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24
const TICKS_PER_MONTH:  int   = TICKS_PER_DAY * 30
const TICKS_PER_SEASON: int   = TICKS_PER_DAY * 90    # 3月
const TICKS_PER_YEAR:   int   = TICKS_PER_DAY * 360   # 12月 / 4季
const SECONDS_PER_TICK: float = 86400.0 / float(TICKS_PER_DAY)
```

**兩種模式：**

| 模式 | TICKS_PER_DAY | 1 tick | 1天 | 1月 | 1年 |
|---|---|---|---|---|---|
| 測試 | 24 | 1小時 | 24 ticks | 720 ticks | 8640 ticks |
| 正式 | 8640 | 10秒 | 8640 ticks | 259200 ticks | 3110400 ticks |

---

## 各系統常數重寫規則

### 巨觀（月/季/天尺度）

| 檔案 | 舊常數 | 新定義 | 語意 |
|---|---|---|---|
| `salary_system.gd` | `SALARY_INTERVAL = 30` | `WorldState.TICKS_PER_MONTH` | 1月/次 |
| `harvest_system.gd` | `SEASON_LENGTH = 30` | `WorldState.TICKS_PER_SEASON` | 1季 = 90天 |
| `population_system.gd` | `OVERFLOW_CHECK_INTERVAL = 10` | `WorldState.TICKS_PER_DAY` | 每天檢查 |

> `SEASON_LENGTH` 原本 30 ticks（= 1.25天）→ 改為 90天/季（4季=360天/年）

### 速率（per-day 定義 → 每 tick 換算）

```gdscript
# 各系統內部計算用
# const X_PER_DAY = ...（語意清晰的定義）
# 實際每 tick 使用: X_PER_DAY / WorldState.TICKS_PER_DAY
```

| 檔案 | 舊常數 | 新增 per-day 常數 | 語意 |
|---|---|---|---|
| `resource_system.gd` | `FOOD_PER_PERSON_PER_TICK = 0.1` | `FOOD_PER_PERSON_PER_DAY = 2.4` | 2.4食物/人/天（TEST VALUE） |
| `sim_runner.gd` | `FATIGUE_PER_TICK = 0.002` | `FATIGUE_PER_DAY = 0.05` | 20天滿疲勞（TEST VALUE） |
| `sim_runner.gd` | `FATIGUE_RECOVERY = 0.01` | `FATIGUE_RECOVERY_PER_DAY = 0.24` | 約4天回滿（TEST VALUE） |

### 微觀（遭遇戰尺度換算）

世界地圖 1 hex = 遭遇戰地圖內切圓直徑（`MAP_DIAMETER = MAP_RADIUS × 2`）。
標準 NPC 移動 1 world-hex 的成本 = 移動 MAP_DIAMETER 個 encounter-hex 的成本。

| 檔案 | 舊常數 | 新定義 | 語意 |
|---|---|---|---|
| `encounter_system.gd` | （新增）| `MAP_DIAMETER: int = MAP_RADIUS * 2` | 內切圓直徑，定義 world-hex 尺度 |
| `movement_system.gd` | `BASE_MOVE_TICKS = 10` | `EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER` | 與遭遇戰速度掛鉤；MAP_RADIUS 改大自動縮放 |
| `movement_system.gd` | `MIN_MOVE_TICKS = 3` | `EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER / 3` | 最快（速度×3） |
| `movement_system.gd` | `MAX_MOVE_TICKS = 30` | `EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER * 3` | 最慢（速度÷3） |

> 例：MAP_RADIUS=10 → MAP_DIAMETER=20 → BASE_MOVE_TICKS=200 ticks（速度=1.0，plains）
> = 2000秒 = 33分鐘/world-hex（TICKS_PER_DAY=8640）

### 不需改動

| 常數 | 原因 |
|---|---|
| `FAR_ZONE_INTERVAL = 10` | LOD 邏輯用途，不是遊戲時間尺度 |
| `FATIGUE_LOYALTY_PENALTY` | 比例係數，無時間單位 |
| `SALARY_PER_SKILL_POINT`, `OVERPAY_BONUS`, `SALARY_LOYALTY_PENALTY` | 比例係數 |
| Vision / Skill growth 常數 | 語意是「每次事件觸發成長」非「每 tick」 |

---

## UI 顯示換算（text UI 用）

```gdscript
# world_state 輔助函數（顯示用）
func tick_to_date(tick: int) -> String:
    var day:    int = tick / TICKS_PER_DAY
    var month:  int = day / 30
    var season: int = month / 3
    var year:   int = month / 12
    var season_names := ["春", "夏", "秋", "冬"]
    return "第%d年 %s 第%d月 第%d天" % [
        year + 1,
        season_names[season % 4],
        month % 12 + 1,
        day % 30 + 1
    ]
```

---

## 實作方式

`WorldState` 的 `const` 可在其他檔案的 `const` expression 中直接使用：

```gdscript
# salary_system.gd
const SALARY_INTERVAL: int = WorldState.TICKS_PER_MONTH   # = TICKS_PER_DAY * 30

# harvest_system.gd
const SEASON_LENGTH: int = WorldState.TICKS_PER_SEASON     # = TICKS_PER_DAY * 90
```

GDScript const expression 限制：只支援純量常數運算，`WorldState.TICKS_PER_DAY` 為 `const int`，可用。

---

## 不在此次範圍

- `TICKS_PER_DAY` 的值本身平衡（後期設計決策）
- sim_runner 的 LOD 邏輯（FAR_ZONE_INTERVAL 不改）
- encounter/combat 系統的時間設計（另立 spec）

---

## 驗證標準

```gdscript
# headless_test 加入：
assert(WorldState.TICKS_PER_MONTH  == WorldState.TICKS_PER_DAY * 30)
assert(WorldState.TICKS_PER_SEASON == WorldState.TICKS_PER_DAY * 90)
assert(WorldState.TICKS_PER_YEAR   == WorldState.TICKS_PER_DAY * 360)
# 薪水：30天/月
assert(SalarySystem.new().get("SALARY_INTERVAL") == WorldState.TICKS_PER_MONTH)
# 季節：90天/季
assert(HarvestSystem.new().get("SEASON_LENGTH") == WorldState.TICKS_PER_SEASON)
```

- 測試模式（TICKS_PER_DAY=24）：headless 1000 ticks 無崩潰，行為與現在一致
- 正式模式（TICKS_PER_DAY=8640）：headless 1000 ticks 無崩潰，薪水不在第 2 天觸發

---

## 待確認

- `FOOD_PER_PERSON_PER_DAY = 2.4` 合理？（現 0.1×24=2.4，保持不變）
- MIN/MAX_MOVE_TICKS 的倍數（÷3 / ×3）是否合理？
