# Hand Back: Cadence-Aware 累積公式重構

## 實作摘要

- `sim_runner.gd`：加 `NEAR_CADENCE = TICKS_PER_HOUR` 常數；line 80 cadence 改 NEAR_CADENCE
- `resource_system.gd`：`resolve_consumption` 簽名加 `cadence_ticks`，公式改為 `pop × FOOD_PER_PERSON_PER_DAY × day_fraction`
- `sim_runner._step6d_fatigue`：簽名加 `cadence_ticks`，公式改為 `FATIGUE_PER_DAY × day_fraction × ...`
- `salary_system.gd`：`SALARY_INTERVAL` 由 TICKS_PER_MONTH 改 TICKS_PER_DAY × 7（1 週）
- `headless_test.gd`：加 5 個 Cadence Task 測試（食物消耗、疲勞累積、疲勞回復、薪水週期、interval 整除性）
- `docs/tick_parameters.md`：修「12.5 天」說明，更新 SALARY_INTERVAL 表格，加已修 bug 記錄
- `docs/known_issues.md`：加 S8 `p.salary` 平衡技術債

## 行為變化

- 食物消耗：0.24/人/天 → **2.4/人/天**（10 倍）
- 疲勞累積：0.0048/天 → **0.048/天**（20.8 天滿）
- 疲勞回復：0.024/天 → **0.24/天**（4.2 天回滿）
- 薪水：每月 1 次 → **每週 1 次**（月支出 4 倍，需平衡 p.salary）

## 連動風險

- main.gd test setup 食物 300 → 12.5 天斷糧（從 125 天）。已存在 known_issues S5
- demo 場景 `p.salary` 預設值需手動降 25%（S8）
- 任何依賴「每月發薪一次」的事件 / NPC 反應需檢查

## 待主 session 確認

- main.gd test setup 是否需要加初始 food（連動 S5）
- p.salary 全域降 25% 是否要包在這個 sprint 還是另開
