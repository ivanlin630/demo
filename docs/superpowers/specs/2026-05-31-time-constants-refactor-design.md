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

## 設計目標

- 一個地方改 `TICKS_PER_DAY`，全部常數等比縮放
- 巨觀參數（薪水、季節、食物消耗）用「天」定義
- 微觀參數（移動、疲勞）用「小時」定義
- 測試/正式 兩組預設值可快速切換

---

## 核心常數（放 world_state.gd）

```gdscript
# ── 時間尺度 ──────────────────────────────────────────────
const TICKS_PER_DAY:  int   = 24          # TEST VALUE（正式: 8640 = 10秒/tick）
const TICKS_PER_HOUR: int   = TICKS_PER_DAY / 24
const SECONDS_PER_TICK: float = 86400.0 / float(TICKS_PER_DAY)
```

**兩種模式：**

| 模式 | TICKS_PER_DAY | 1 tick 代表 | 1天ticks |
|---|---|---|---|
| 測試 | 24 | 1小時 | 24 |
| 正式 | 8640 | 10秒 | 8640 |

---

## 各系統常數重寫規則

### 巨觀（天尺度）

| 檔案 | 舊常數 | 新定義 | 語意 |
|---|---|---|---|
| `salary_system.gd` | `SALARY_INTERVAL = 30` | `30 * WorldState.TICKS_PER_DAY` | 30天/月 |
| `harvest_system.gd` | `SEASON_LENGTH = 30` | `30 * WorldState.TICKS_PER_DAY` | 30天/季 |
| `population_system.gd` | `OVERFLOW_CHECK_INTERVAL = 10` | `1 * WorldState.TICKS_PER_DAY` | 每天檢查 |

### 速率（每天消耗 → 換算每tick）

| 檔案 | 舊常數 | 新定義 | 語意 |
|---|---|---|---|
| `resource_system.gd` | `FOOD_PER_PERSON_PER_TICK = 0.1` | `FOOD_PER_PERSON_PER_DAY / TICKS_PER_DAY`，其中 `FOOD_PER_PERSON_PER_DAY = 2.4` | 2.4食物/人/天（TEST VALUE） |
| `sim_runner.gd` | `FATIGUE_PER_TICK = 0.002` | `FATIGUE_PER_DAY / TICKS_PER_DAY`，其中 `FATIGUE_PER_DAY = 0.05` | 20天滿疲勞（TEST VALUE） |
| `sim_runner.gd` | `FATIGUE_RECOVERY = 0.01` | `FATIGUE_RECOVERY_PER_DAY / TICKS_PER_DAY`，其中 `FATIGUE_RECOVERY_PER_DAY = 0.24` | 約4天回滿（TEST VALUE） |

### 微觀（小時尺度）

| 檔案 | 舊常數 | 新定義 | 語意 |
|---|---|---|---|
| `movement_system.gd` | `BASE_MOVE_TICKS = 10` | `4 * WorldState.TICKS_PER_HOUR` | 平原 4小時/hex（TEST VALUE） |
| `movement_system.gd` | `MIN_MOVE_TICKS = 3` | `1 * WorldState.TICKS_PER_HOUR` | 最快 1小時/hex |
| `movement_system.gd` | `MAX_MOVE_TICKS = 30` | `12 * WorldState.TICKS_PER_HOUR` | 最慢 12小時/hex |

### 不需改動

| 常數 | 原因 |
|---|---|
| `FAR_ZONE_INTERVAL = 10` | LOD 邏輯用途，不是遊戲時間尺度 |
| `FATIGUE_LOYALTY_PENALTY` | 比例係數，不含時間單位 |
| `SALARY_PER_SKILL_POINT`, `OVERPAY_BONUS`, `SALARY_LOYALTY_PENALTY` | 比例係數 |
| Vision / Skill growth 常數 | 已用 0.001 等微小值，語意是「每次觸發成長」非「每tick」 |

---

## 實作方式

`WorldState.TICKS_PER_DAY` 是 `const`，GDScript 允許其他檔案的 `const` 用它計算：

```gdscript
# salary_system.gd
const SALARY_INTERVAL: int = 30 * WorldState.TICKS_PER_DAY
```

GDScript const expression 限制：只支援純量常數運算（int/float），`WorldState.TICKS_PER_DAY` 為 `const int`，可以直接用。

---

## 不在此次範圍

- `TICKS_PER_DAY` 的值本身平衡（這是後期設計決策）
- sim_runner 的 LOD 邏輯（FAR_ZONE_INTERVAL 不改）
- encounter/combat 系統的時間設計（另立 spec）
- UI 顯示「現實時間」換算（超出 demo 範圍）

---

## 驗證標準

- 測試模式（TICKS_PER_DAY=24）：headless 1000 ticks 無崩潰，行為與現在一致
- 常數換算正確：`SALARY_INTERVAL / TICKS_PER_DAY == 30`（天）
- 正式模式（TICKS_PER_DAY=8640）：headless 1000 ticks 無崩潰，薪水不在第 2 天觸發

---

## 待確認

- `FOOD_PER_PERSON_PER_DAY = 2.4` 是否合理？（現在 0.1/tick × 24 = 2.4/天，保持一致）
- 移動速度 plains 4小時/hex 是否合理（地圖 radius=4 → 穿越地圖 ≈ 32小時）
