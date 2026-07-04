# Hand Back: 文字 UI 翻新 Phase 1 — API 暴露 + 邊界清理

branch: `feat/textui-api-exposure`
plan: `docs/superpowers/plans/2026-06-14-textui-p1-api-exposure.md`

## 實作摘要

- `scripts/simulation/player_api_mapper.gd`
  - `map_location_context` 回傳加 `food` / `wild_game` / `predator`。
  - 新 helper `_predator_intel(state, tile)`：掠食者認知分級 `none/detected/lurking`，腳下格復用 `AmbushSystem.new().detect`，非腳下格預設 `lurking`（認知不透明）。
  - `map_controlled_team` 加 `food_days` / `starving`（< 3 天）。
  - `map_player_summary` 比照加 `food_days` / `starving`（t==null 時回 0.0/false）。
  - 新 const `FOOD_PER_PERSON_PER_DAY = 2.4` + helper `_food_days(t)`。
- `scripts/simulation/player_query_api.gd`
  - `_build_available_actions` 加 Layer 6：玩家隊 self/tile 動作。腳下 tile 有 `wild_game>0` → 列 `hunt`；`predator_density>0` → 列 `hunt_beast`（皆 `kind:"none"`）。
  - 新 helper `pt_tile_self(state, ptid)`。
  - `_action_label` 補 `hunt`→「狩獵」、`hunt_beast`→「獵猛獸」。
- `scripts/ui/sim_bridge.gd`：加 facade `is_encounter_active()`。
- `scripts/ui/text_ui_main.gd`：`KEY_Q` 分支改 `_bridge.is_encounter_active()`，不再 `_bridge.get_state().encounter_active`。
- `scripts/debug/headless_test.gd`：加並註冊 `_test_location_game_predator` / `_test_precarity_dto` / `_test_self_actions`。

### DTO 新欄位清單

| DTO | 新欄位 |
|---|---|
| `location_context` | `food` (int), `wild_game` (int), `predator` (String: none/detected/lurking) |
| `controlled_team` | `food_days` (float), `starving` (bool) |
| `player_summary` | `food_days` (float), `starving` (bool) |
| `available_actions` | `hunt` / `hunt_beast`（腳下 tile 條件式，kind=none）|

## 與 spec 的差異

- Task 4 邊界清理的 plan 重點假設「`text_ui_main` 互動模式直呼 `_player_cmd.get_available_actions`」**已不存在**於現行碼 — text_ui_main 早已走 `_bridge`。實際殘留的 text-UI 層直存只有一處：`text_ui_main:270` 讀 `_bridge.get_state().encounter_active`，已改 facade。
- text_ui_main 構造 root（`WorldState.new()` / `SimRunner.new()` 餵 `SimBridge`）保留 — 屬 wiring，非查詢/指令繞道。
- 改後 grep `scripts/ui/text_ui_main.gd` 無任何 `get_state()/.persons/.teams/.world/_runner./_player_cmd`。

## 連動風險

- **圖形 Main.tscn 系列**（`main.gd` / `encounter_view.gd` / `popup_layer.gd` / `debug_bar.gd`）仍大量 `_bridge.get_state()` reach-through 直讀 raw `WorldState`（body_parts、units、world.current_tick 等）。plan 明示「不碰圖形 Main.tscn」「chrome/互動屬 Phase 2/3」，故本 task 不動。若主 session 要把「UI 邊界 invariant」推到圖形 UI，需另開 task（範圍大，涉及 encounter tactical view 解耦）。
- `text_map_renderer.gd` 為 static 純函數，透過 `SimBridge.render_text_map()` 由 bridge 餵 `_state` — 屬 bridge-internal delegation，未列為洩漏。
- `predator` 欄位語意為「玩家認知」非真實 — UI 渲染勿當成 ground truth（lurking = 有但未察覺）。

## 測試結果

- `headless_test.gd`：`=== DONE ===`，3 個新測試全綠（`location game/predator OK` / `precarity DTO OK` / `self actions OK`）。
- `team_ui_test.gd`：全 `[OK]`，無 SCRIPT ERROR。
- `ui_logic_test.gd`：`=== UI Logic Test DONE === errors: 0`。

## 待主 session 確認

- **既有 baseline 失敗**：`_test_on_team_extinct_to_storage`（headless_test.gd:5080）`Assertion failed: food 應進公庫`。此 worktree 自 `bf7114f`（main HEAD）建立、tree 乾淨時即失敗，**非本 task 引入**。建議獨立追查（與本翻新無關）。
- Phase 2/3：圖形 UI 邊界解耦、chrome、stage-1 互動渲染。
