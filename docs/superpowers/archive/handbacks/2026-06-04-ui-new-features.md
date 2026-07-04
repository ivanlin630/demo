# Hand Back: UI New Features (Plan 3)

## 實作摘要

### Task 1–2: 資料層 + Herald 機制
- `scripts/data/world_state.gd`：加 `player_pending_orders: Dictionary = {}` 和 `player_alerts: Array = []` 和 `last_encounter_result: Dictionary = {}`
- `scripts/data/team_data.gd`：加 `player_commanded_task: String = ""`
- `scripts/simulation/interaction_system.gd`：`_deliver_order` 加 player herald 偵測，抵達時設 `player_commanded_task`、清 `player_pending_orders`
- `scripts/simulation/player_command_system.gd`：`_action_order_faction_member` 改用 `SubteamSystem.dispatch` 派信使；成功後寫 `player_pending_orders`；新增 class-level `_subteam: SubteamSystem`

### Task 3: text_ui_main 基礎
- 新 mode 變數：`_faction_mode`, `_outpost_mode`, `_subteam_mode`, `_advisor_mode`, `_subteam_selection`, `_advisor_selection`
- gather_intel submode 變數：`_intel_mode`, `_intel_target_id`, `_intel_options`
- 彈性 input mode：`_input_mode_type ("numeric"|"string")`, `_input_mode_callback: Callable`, `_input_mode_prompt`
- `_ready()` 動態建立 `_alert_bar: Label`（黃色，置於 InputBar 上方）
- `_handle_input_mode()` 改支援 string 模式（A-Z + backspace + enter/callback + escape）
- `_close_all_modes(keep)` + `_check_alerts()` 輔助函式
- `[Z]` dismiss alert
- `scripts/ui/sim_bridge.gd`：加 `get_and_clear_alerts()`

### Task 4–5: 新 Panel
- `[F]` 勢力面板：`_handle_faction_mode` + `_build_faction_str`；[A]設目標 [B]徵收率 [C]離開 [D]背叛 [E]解散 [1-9]下令成員
- `[O]` 前哨站面板：`_handle_outpost_mode` + `_build_outpost_str`；[1-9]執行 action
- `[U]` 子隊面板：`_handle_subteam_mode` + `_build_subteam_str`；兩步選子隊→[A]移動（嵌套 q/r 輸入）[B]召回

### Task 6: 顧問 + gather_intel
- `scripts/simulation/advisor_system.gd`：`AdvisorSystem` 新建（get_advice, skill mapping, tone detection）
- `scripts/ui/sim_bridge.gd`：加 `query_advisor_advice(pid, situation) -> String`
- `[V]` 顧問模式：從 `_cached_snapshot.members_detail` 選顧問，輸入情境關鍵字，呼叫 bridge
- `gather_intel` submode：`_handle_interact_mode` 偵測 `action_id == "gather_intel"`，進 `_intel_mode` 顯示問題選單，選後 `confirm_gather_intel`
- `scripts/simulation/player_api_mapper.gd`：加 `map_members_detail`, `map_faction_panel`, `map_outpost_panel`, `map_subteam_panel`
- `scripts/simulation/player_query_api.gd`：加 `query_faction_panel`, `query_outpost_panel`, `query_subteam_panel`
- `scripts/data/faction_data.gd`：加 `player_goal_override: String = ""`
- `scripts/debug/headless_test.gd`：加 AdvisorSystem smoke test

### Task 7: encounter_view
- `[S]` 投降：`encounter_active == true` 時 surrender；否則 fall-through 至南向移動（KEY_S 保留在 HEX_DIRS）
- `[J]` 收編：`not encounter_active and last_encounter_result.get("can_subjugate")` 時 subjugate_enemy
- `_refresh_ui()` 更新 action hints 顯示 S/J

## 連動風險

- `gather_intel` / `confirm_gather_intel` actions：UI 端已實裝，但 `player_command_system` 無對應 case；目前安全降級（無問題選項、顯示「無可用問題」）。需後續補 backend。
- `AdvisorSystem` stub：SITUATION_SKILL_MAP 鍵名（assess_enemy/diplomatic/resources）與 UI prompt（attack/diplomacy/resource）不一致，`_advisor_tone()` 誤讀 skills 為 values；功能可用但 accuracy 恆用預設值。若要真正依 skill 給建議需修正。
- `last_encounter_result.can_subjugate`：目前 encounter_system 未寫入此欄位，`[J]` 永遠不觸發。需 encounter_system 在戰鬥結束時寫入。
- `player_commanded_task` 無清除路徑：成員換任務後舊值殘留。低優先，UI 仍顯示最後指令。

## 待主 session 確認

- `gather_intel` backend 是否列入下一批次
- `AdvisorSystem` skill mapping 修正優先級
- `encounter_system` 寫入 `can_subjugate` 時機設計
