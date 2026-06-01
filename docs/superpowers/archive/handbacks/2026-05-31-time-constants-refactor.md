# Hand Back: Time Constants Refactor

## 實作摘要
- `world_state.gd`：加 TICKS_PER_DAY/HOUR/MONTH/SEASON/YEAR/SECONDS_PER_TICK 常數
- `salary_system.gd`：SALARY_INTERVAL = WorldState.TICKS_PER_MONTH（數值不變 720）
- `harvest_system.gd`：SEASON_LENGTH = WorldState.TICKS_PER_SEASON（720→2160，行為變更）
- `population_system.gd`：OVERFLOW_CHECK_INTERVAL = WorldState.TICKS_PER_DAY（10→24）
- `sim_runner.gd`：FATIGUE_PER_DAY / FATIGUE_RECOVERY_PER_DAY（數值等比換算，使用處除以 TICKS_PER_DAY）
- `resource_system.gd`：FOOD_PER_PERSON_PER_DAY（數值等比換算，使用處除以 TICKS_PER_DAY）
- `movement_system.gd`：BASE/MIN/MAX_MOVE_TICKS 由 EncounterSystem 常數導出（10→200, 3→66, 30→600）
- `headless_test.gd`：加 TimeConstants assert，驗證 TICKS_PER_DAY=24 MONTH=720 SEASON=2160 YEAR=8640

## 連動風險
- `harvest_system.gd` SEASON_LENGTH 從 720→2160，若其他系統依賴季節切換頻率需確認
- `movement_system.gd` BASE_MOVE_TICKS 從 10→200，團隊移動速度大幅降低，AI 行為（尤其 faction_ai 的目標追蹤）可能需要重新評估
- `population_system.gd` OVERFLOW_CHECK_INTERVAL 10→24，微小效能差異，行為等效

## 待主 session 確認
- SEASON_LENGTH=2160 導致 1000 tick headless 看不到 harvest 季節切換，是否需調整測試 tick 數？
- BASE_MOVE_TICKS=200 是否合理（plains 標準速度 1.0 → 200 ticks/world-hex）？
