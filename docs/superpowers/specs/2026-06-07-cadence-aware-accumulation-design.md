# Cadence-Aware 累積公式重構 — Design

> 日期：2026-06-07
> 議題：食物 / 疲勞 / 訊息衰減等「累積式」公式假設每 tick 跑，但實際在 hour-block 跑 → 累積值只達設計值 1/10

## 背景

`sim_runner` 將大部分系統包在 `% TICKS_PER_HOUR == 0` 區塊（line 80）內，每小時跑一次。但 `resource_system.resolve_consumption`、`sim_runner._step6d_fatigue` 等累積式公式用 `/ TICKS_PER_DAY` 作分母，**隱含「每 tick 跑」的假設**。結果：

| 系統 | 設計值 | 實際效果 |
|---|---|---|
| 食物消耗 | 2.4 / 人 / 天 | **0.24 / 人 / 天**（1/10）|
| 疲勞累積 | 1.0 滿 / 20.8 天 | **1.0 滿 / 208 天** |
| 疲勞回復 | 1.0 / 4.2 天 | **1.0 / 42 天** |

> `tick_parameters.md` 紀錄的「food=300 → 12.5 天斷糧」是文件誤導，實際是 125 天。

## 目標

1. 把 cadence（更新頻率）抽成具名常數 `NEAR_CADENCE`，未來可調（例如 1h → 6h）
2. 累積公式改為 **cadence-aware**：每 call 算 `cadence_ticks / TICKS_PER_DAY` 天的量，總和正確
3. 修正常數命名語意對齊實際效果（per-day 名稱 → 真正 per-day 效果）
4. 統一驗證：所有 interval 常數都是 `NEAR_CADENCE` 倍數，否則永遠不觸發
5. 薪水頻率從 1 月縮短到 1 週（玩家感受更頻繁，忠誠系統有反應空間）

## 不在範圍

- **Cadence 值改 1h → 6h**：留待後續討論
- **`p.salary` 預設值平衡**（從月薪語意改週薪）：標註技術債，後續處理
- **forced_event 超時邏輯**重新設計：獨立議題
- **遠區公式**（`far_teams` cadence 不同）：以同樣 cadence-aware 模式處理，但 cadence 值不同（`FAR_ZONE_INTERVAL`）

## 架構

### 1. 新增 `NEAR_CADENCE` 常數

`scripts/simulation/sim_runner.gd`：

```gdscript
const NEAR_CADENCE: int = WorldState.TICKS_PER_HOUR   # TEST VALUE — 近區更新頻率（1h）
```

把 line 80 的 `% WorldState.TICKS_PER_HOUR == 0` 改為 `% NEAR_CADENCE == 0`。語意相同，但日後改 NEAR_CADENCE 即一行調整。

### 2. 累積公式 cadence-aware 化

**Pattern：** 在 call 端傳入「本 call 經過的 tick 數」當作 cadence 參數。

#### A. `resource_system.resolve_consumption`

簽名改：

```gdscript
func resolve_consumption(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
```

公式改（line 66）：

```gdscript
var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY * day_fraction
```

`sim_runner.gd` 呼叫端：

```gdscript
# Near block (sim_runner.gd:100)
_step6_resolve_consumption(state, near_teams, NEAR_CADENCE)
# Far block (sim_runner.gd:126)
_step6_resolve_consumption(state, far_teams, FAR_ZONE_INTERVAL)
```

`_step6_resolve_consumption` wrapper 加 cadence 參數轉發。

#### B. `sim_runner._step6d_fatigue`

公式改：

```gdscript
# line 216 紮營回復
team.fatigue -= FATIGUE_RECOVERY_PER_DAY * day_fraction * rest_mult
# line 223 行軍累積
team.fatigue += FATIGUE_PER_DAY * day_fraction * terrain_mult * time_mult
```

其中 `day_fraction = cadence_ticks / TICKS_PER_DAY`。函數簽名加 `cadence_ticks: int` 參數。

#### C. `message_system.TIME_DECAY_PER_TICK`

**現況：** `TIME_DECAY_PER_HOUR = 0.005`，`TIME_DECAY_PER_TICK = 0.005 / 10 = 0.0005 per tick`。

`age` 計算用 tick 數，formula `1.0 - age × 0.0005`。**這個公式不受 cadence 影響**（直接乘 age tick 數），所以**不用改**。但常數命名建議改為 `TIME_DECAY_PER_TICK` 改為由 `PER_HOUR` 計算的衍生常數即可（現況已是衍生）。**保留現狀**。

### 3. `SALARY_INTERVAL` 改週

```gdscript
# salary_system.gd:3
const SALARY_INTERVAL: int = WorldState.TICKS_PER_DAY * 7   # 1 週/次
```

`WorldState.TICKS_PER_MONTH` 既有衍生常數保留不動。

**Side effect：** 月發薪變週發薪 → 月總支出 4 倍。`p.salary` 預設值若原本是月薪意圖，需另外調降 25%（標為 known_issues 技術債，本 spec 不修）。

**忠誠變化：** 欠薪 -0.03/週、過薪 +0.02/週 → 月為 -0.12 / +0.08。比舊月發薪 4 倍快，符合玩家反應空間需求。

### 4. Interval 整除性驗證

所有 `% N == 0` 判斷的 N 都必須是 `NEAR_CADENCE = 10` 倍數，否則跳過 cadence tick 永不觸發。

現況檢查：

| 常數 | 值 | NEAR_CADENCE=10 整除？|
|---|---|---|
| `STRATEGIC_INTERVAL` | 100 | ✓ |
| `ALLIANCE_CHECK_INTERVAL` | 300 | ✓ |
| `BETRAY_CHECK_INTERVAL` | 500 | ✓ |
| `FACTION_UPDATE_INTERVAL` | 200 | ✓ |
| `COLLECT_INTERVAL` | 300 | ✓ |
| `GOAL_CHECK_INTERVAL` | 100 | ✓ |
| `FAR_ZONE_INTERVAL` | 100 | ✓ |
| `Harvest` (TICKS_PER_DAY/4) | 60 | ✓ |
| `SALARY_INTERVAL` 改後 | 1680 (7 × 240) | ✓ |
| `OVERFLOW_CHECK_INTERVAL` | 240 | ✓ |

全 OK。**未來若改 NEAR_CADENCE 為 60（6h），上述 100/200/300/500 都不是 60 倍數 → 全部要重評。** 標為後續 cadence 改動連動 issue。

### 5. 文件修正

`docs/tick_parameters.md`：

- 修「food=300 → 12.5 天」誤敘為「food=300 → 125 天（cadence 為 1h、公式 cadence-aware 後）」
- 更新疲勞累積時間（20.8 天、4.2 天）為「修完後實際達標」

## 不變量

- 公式總量正確：`per_call × calls_per_day = per_day`
- `cadence_ticks` 為正整數
- `NEAR_CADENCE > 0` 且 `TICKS_PER_DAY % NEAR_CADENCE == 0`（保證每天整除次數）

## 測試（`headless_test.gd` 加 case）

1. **食物消耗總量**：建 10 人 team，food=2400，跑 240 tick（1 天）→ 預期剩 `2400 - 24 = 2376`（10 × 2.4 = 24/天）
2. **疲勞累積總量**：行軍 1 天（240 tick）→ `fatigue ≈ 0.048`
3. **疲勞回復總量**：紮營 1 天 → `fatigue ≈ -0.24`
4. **薪水週期**：跑 1680 tick → 觸發 1 次薪水；3360 tick → 觸發 2 次
5. **不變量檢驗 NEAR_CADENCE 整除**：assert `TICKS_PER_DAY % NEAR_CADENCE == 0`

## 風險

- **食物消耗 10 倍變化**：所有現有 setup 的 food 庫存對遊戲時間都失效
  - 緩解：`main.gd` test setup、`headless_test.gd` 初始 food、所有 demo 場景都要重新平衡
  - 包在這個 plan 內處理（巡掃 `food=` 字串）
- **疲勞 10 倍快**：行軍 21 天就滿，影響 `fatigue_loyalty_penalty` 觸發頻率（從幾年變幾月）→ 屬於設計意圖（修 bug 暴露真實設計），不額外緩解
- **薪水變週**：`p.salary` 預設值未連動，玩家有 4 倍月支出（直到後續平衡）→ 標 known_issues

## 解決的 known issues

- 累積公式假設每 tick 但實際每 hour 的 bug（系統性 1/10 偏差）
- 文件「12.5 天斷糧」記載錯誤
- 月發薪太慢，忠誠系統反應遲鈍

## 後續延伸（不在本 spec）

- Cadence 1h → 6h 改動 + 連動 interval 重評
- `p.salary` 預設值從月語意改週語意
- forced_event 超時邏輯重新設計
