# Hand Back: Tick Normalization

## 實作摘要
- `world_state.gd`：TICKS_PER_DAY 24→240，ticks_per_day 改為 getter property alias（`get: return TICKS_PER_DAY`）
- `encounter_system.gd`：MAP_RADIUS 10→12，MAP_DIAMETER 自動→24
- `day_night_system.gd`：state.ticks_per_day → WorldState.TICKS_PER_DAY
- `sim_runner.gd`：state.ticks_per_day → WorldState.TICKS_PER_DAY；近區包進 TICKS_PER_HOUR 批次；FAR_ZONE_INTERVAL 正規化為 `10 * TICKS_PER_HOUR`；turn 計數 % 6 → % (TICKS_PER_DAY/4)；harvest 移出近區批次，獨立 TICKS_PER_DAY/4 條件
- `strategic_ai_system.gd`：STRATEGIC_INTERVAL、ALLIANCE_CHECK_INTERVAL 改用 TICKS_PER_HOUR 倍數
- `diplomatic_ai_system.gd`：BETRAY_CHECK_INTERVAL 改用 TICKS_PER_HOUR 倍數
- `reaction_system.gd`：GOAL_CHECK_INTERVAL 改用 TICKS_PER_HOUR 倍數
- `faction_ai_system.gd`：COLLECT_INTERVAL 改用 TICKS_PER_HOUR 倍數；新增 FACTION_UPDATE_INTERVAL 常數取代 hardcoded % 20
- `message_system.gd`：TIME_DECAY 改為 per-hour 推算（TIME_DECAY_PER_HOUR=0.005，TIME_DECAY_PER_TICK 自動=0.0005）
- `headless_test.gd`：ticks_per_day 斷言值 24→240；day/night 期間測試用 tick 值更新（3→25, 22→220）

與 spec 的差異：無實質差異。

## 連動風險
- headless_test 跑 1000 ticks = 4.2 天（原 41.7 天），月薪/季節事件不在 1000 tick 內觸發，需增加 tick 數才能完整測試長期行為
- 遭遇戰地圖 tile 數：331→469（+42%），如有 tile 遍歷效能問題請查 encounter_system
- BASE_MOVE_TICKS 現為 240（= 1 天/格，由 EncounterSystem.BASE_ACTION_TICKS × MAP_DIAMETER 自動計算），移動相關 UI 顯示（如 ETA）若有假設舊值需確認
- 近區系統現在每 10 ticks 才執行一次（而非每 tick），如有依賴每 tick 執行的近區邏輯需檢查

## 待主 session 確認
- headless_test tick 數是否要增加到 7200（1 個月）以覆蓋薪資測試？
