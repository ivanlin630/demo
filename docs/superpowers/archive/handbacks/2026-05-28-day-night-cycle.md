# Hand Back: 日夜循環 (Day-Night Cycle)

## 實作摘要

- `scripts/simulation/day_night_system.gd`（新建）：`DayNightSystem` class，提供 `get_time_of_day`、`get_time_period`（dawn/day/dusk/night）、`get_speed_mult`、`get_fatigue_mult`、`get_vision_mult`、`get_guards`、`get_camp_vision_range`。
- `scripts/simulation/sim_runner.gd`（修改）：加入 `_day_night_system` 欄位與 `_get_time_fatigue_mult()`；`advance_tick` 每天開始 print `[DayNight] Day N 開始`；`_step2_move_teams`、`_step1b_update_vision` 加 time mult 參數並傳入。
- `scripts/simulation/movement_system.gd`（修改）：`process()` 與 `_move_cost()` 加 `time_mult: float = 1.0` 參數，speed 計算乘入 time_mult。
- `scripts/simulation/vision_system.gd`（修改）：`tick_discovery()` 加 `time_vision_mult: float = 1.0`，vrange 計算乘入 time_vision_mult。
- `scripts/simulation/interaction_system.gd`（修改）：加 `_check_night_raid()` 函數（守夜邏輯基礎，尚未接入主流程）。
- `scripts/debug/headless_test.gd`（修改）：加 DayNightSystem 時間計算驗證、guard_ratio 守夜驗證。

### 與 spec 的差異

- `_get_time_fatigue_mult` stub 不存在（team-ai-redesign 未 merge），由本次 **新建**，而非修改 stub。
- MovementSystem 主函數為 `process()` 非 `advance_teams()`（spec 用名），直接在原函數加 `time_mult` 參數，未重命名。
- headless_test 中 tick 0 驗證需先將 `state.world.current_tick = 0`（模擬跑 200 ticks 後），spec 未標注，由實作補上。

## 連動風險

- `sim_runner.gd`：`_get_time_fatigue_mult` 已建立但尚未被任何疲勞計算呼叫——若 team-ai-redesign 也建了同名函數，merge 時需合併。
- `interaction_system.gd`：`_check_night_raid` 尚未接入 `process_on_arrival` 流程，夜間突襲判定不會自動觸發。需另開 task 決定在哪個 interaction 判斷點呼叫。
- `movement_system.gd`：time_mult 在 terrain mult 前乘入（speed × time_mult × terrain），乘法順序對 clamp 後結果有影響，測試值尚未驗證夜間山地移動的平衡性。

## 待主 session 確認

- **`_check_night_raid` 觸發點**：spec 說「在 `_try_interact` 或遭遇觸發檢查開頭」，但 interaction_system 實際觸發函數為 `process_on_arrival`，需主 session 決定接入位置與 combat_type 處理方式。
- **`_get_time_fatigue_mult` 使用方**：函數已建立，但疲勞系統（team-ai-redesign 的 stress 計算）尚未 merge，需主 session 確認接入時機。
- **時間常數**：dawn/day/dusk/night 邊界值（0.1/0.75/0.9）與乘數（speed 0.5/0.8、fatigue 1.5/1.2、vision 0.5/0.75）均為測試值，正式模擬需調整。
