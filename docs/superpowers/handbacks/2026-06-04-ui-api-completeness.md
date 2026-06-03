# Hand Back: UI API Completeness

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/player_command_api.gd` | `execute_action` success path 改建 payload dict + merge inner payload，確保 `inquiry_options` 等傳回 UI |
| `scripts/ui/sim_bridge.gd` | 加 `set_player_input(key, value)`、`query_faction_panel()`、`query_outpost_panel()`、`query_subteam_panel()` 四個 wrapper |
| `scripts/simulation/player_api_mapper.gd` | 加 `map_faction_panel`、`map_outpost_panel`、`map_subteam_panel` 三個 static func |
| `scripts/simulation/player_query_api.gd` | 加 `query_faction_panel`、`query_outpost_panel`、`query_subteam_panel`；`_build_available_actions` Layer 5 加 3 個全域 action；`_action_label` 加 20 個標籤 |
| `scripts/debug/headless_test.gd` | 加 3 個 `[Test]` 驗證 print（faction / outpost / subteam panel） |

### 與 spec 的差異

| Spec 寫法 | 實際用法 | 原因 |
|---|---|---|
| `mt.player_commanded_task` | `mt.order_task` | TeamData 無此欄位 |
| `f.player_goal_override` | `""` (stub) | FactionData 無此欄位，Plan 3 補 |
| `OutpostSystem.new()._has_control(...)` | `tile.outpost_owner == -1 or == pt.team_id` | OutpostSystem 無 `_has_control` |
| `state.get("player_pending_orders", {})` | `{}` + 註解 | `Object.get()` 只接受 1 個參數；欄位 Plan 3 才加 |
| `state.last_encounter_result` | `state.get("last_encounter_result")` null guard | WorldState 無此欄位，現為 safe stub |

## 連動風險

- `FactionData`：`player_goal_override` 欄位尚未存在。Plan 3 Task 1 加上後，`map_faction_panel` 第 470 行須從 `""` 改為 `f.player_goal_override`。
- `WorldState`：`player_pending_orders` 欄位尚未存在。Plan 3 Task 1 加上後，`map_faction_panel` 的 `pending_orders` 須從 `{}` 改為 `state.player_pending_orders`（已留 TODO 註解）。
- `WorldState`：`last_encounter_result` 欄位尚未存在。加上後，`_build_available_actions` 的 `subjugate_enemy` 區塊會自動生效（guard 已寫好）。
- `PlayerQueryApi._build_available_actions`：Layer 5 (`offer_surrender`) 依賴 `state.encounter_active`，已有欄位，無風險。

## 待主 session 確認

1. **`player_goal_override` stub**：`map_faction_panel` 回傳 `""` 而非從 FactionData 讀。若 Plan 3 設計有變，此處需同步更新。
2. **`map_faction_panel` `faction_goal`**：回傳 `f.strategic_goals[0]`，型別為 `Dictionary`（含 type/target_id/priority），非 String。UI 端需確認是否能接受 Dict 或需轉字串。
3. **`state.last_encounter_result` guard**：`subjugate_enemy` 目前永遠不出現（field 不存在）。需在 WorldState 加欄位後才會生效。
