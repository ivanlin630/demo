# Hand Back: Pathfinding + ETA + Catch-up

> branch: `feat/pathfinding-and-eta`
> 日期：2026-06-09

## 實作摘要

- `scripts/data/team_data.gd`：加 `last_tile_pos: Vector2i = Vector2i(-999, -999)`（observe_velocity 用，預設表「無移動 history」）
- `scripts/simulation/path_system.gd`（**新檔**）：
  - `find_path(state, from, to)`：A* + 同-tick cache（key = from/to/tick）
  - `eta_ticks(team, path_cost)` + `_team_speed_mult(team)`（fatigue 影響，speed_class hook 預留）
  - `observe_velocity(state, observer, target)`：限視野，含距離雜訊（`dist / VISION_RADIUS`）
  - `estimate_catch_up(state, self_team, target_id)`：限視野 + 觀察速度 + path cost → reachable / eta / reason
- `scripts/simulation/movement_system.gd`：
  - 新增 `_calc_next_step(state, from, to)`（A*，回 path[1]）
  - 改寫 `_step_team` 用 `_calc_next_step`（原為 greedy 鄰格），保留 stuck 偵測 + `_on_arrival` 介面
  - 實際移動時記 `team.last_tile_pos = old_pos`
- `scripts/simulation/faction_ai_system.gd`：`_find_trade_target` / `_find_weakest_prey` / `_find_strong_neighbor` / `_find_aid_target` 改用 `estimate_catch_up`（reachable 過濾 + score 用 eta 取代 hex_dist）
- `scripts/debug/headless_test.gd`：15 個 Path 測試（Task1–Task7）；3 個既有測試補 plains grid（見下）

## 與 spec 的差異

- **`_calc_next_step` 原不存在**：spec/plan 假設 movement 已有此函數。實際是 greedy inline 於 `_step_team`。已新增 `_calc_next_step` 並改寫 `_step_team` 呼叫它，介面（`_on_arrival`、回傳 bool）不變。唯一呼叫端就是 `_step_team`，無其他端需更新。
- **`last_tile_pos` 更新時機**：spec 寫「process 移動前每 tick 記」。改為在 `_step_team` 實際換格時記 `old_pos` → velocity = 真實上一步向量（每 tick 無條件記會讓移動 tick 的 velocity 變 0，錯誤）。
- **既有測試補地圖**：新 AI reachability 需 A* 有路可走，但下列既有單元測試原本無 tiles（靠 hex_dist 不需地圖）。已補 plains grid + 唯一 `current_tick`（避免 static path cache 跨測試污染）：
  - `_test_find_trade_target_max_gap`（target==2 排序不變，已驗證）
  - `_test_survival_helpers`
  - `_test_survival_decision_tree`（s2/s3/s4）
  - 新增 helper `_fill_plains(state, x0, x1, y0, y1)`
- **`MERCHANT_MAX_RANGE` const 變未使用**（被 `AI_ETA_LIMIT` 取代），保留未刪。

## 驗證

- `headless_test`：0 SCRIPT ERROR、0 Assertion failed，全 Path Task1–7 OK，既有測試全綠
- `game_sim_test`：7200 tick 無崩潰，`ALL INVARIANTS PASSED (violations=0)`，DONE
- baseline `[Move] stuck` 訊息為**既有行為**（baseline 18 次），非本次回歸

## 連動風險

- **AI 有效範圍縮小**：原 `MERCHANT_MAX_RANGE` 20 hex → 現 `AI_ETA_LIMIT` 1200 tick ≈ 10 plains hex（地形越難越短）。商隊/掠奪/求援目標考量範圍變小，可能改變 AI 行為密度。
- **A* 性能**：`estimate_catch_up` 對每個 discovered team 各跑一次 A*（同 tick cache 緩解）。多 team × 多 discovered 累積成本需觀察 7200-tick 以上規模。
- **觀察速度雜訊隨機**：`observe_velocity` 用 `randf()`，同一 target 評估結果 tick 間可能波動 → AI 目標選擇可能抖動。
- **需完整路徑才移動**：team 現需 A* 到「目標確切 tile」才走；若目標 tile 在地圖外/被隔絕，team 直接放棄（stuck 清 move_target），不像舊 greedy 做部分逼近。靠近地圖邊緣的追擊行為可能改變。
- **`last_tile_pos` 僅在實際換格時更新**：靜止 team 的 `last_tile_pos` 維持上一次移動的舊值；observe 對「剛停下」的 target 仍算出非 0 速度直到下個 cache miss。影響輕微但存在。

## 待主 session 確認

- 騎兵 / wagon `speed_class` 後續實作（`_team_speed_mult` 已留 hook）
- 動態避障（避 enemy outpost）後續 spec
- 是否加更多 AI 整合點（`strategic_ai_system._find_strong_neighbor`@1361、`npc_combat_system` 等）？本次只改 `faction_ai_system` 4 個函數
- `AI_ETA_LIMIT = 1200` 為測試值，正式平衡需調整（屬時間常數待辦）
