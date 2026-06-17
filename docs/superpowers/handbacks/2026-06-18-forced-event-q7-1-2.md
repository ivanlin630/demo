# Hand Back: Forced-Event 單一真值源 + Q7-1/Q7-2（choose_heir softlock + aid_request）

## 實作摘要

- `scripts/simulation/player_command_system.gd`
  - 新增 `const AID_GIVE_DEFAULT: float = 5.0`（TEST VALUE,一餐量;免新增數值輸入 UI）。
  - `get_forced_response_options` 改算**精確動態 id**（單一真值源）：diplomacy 算 `both_independent`（雙方 faction_id==-1 且 proposal∈alliance/surrender）→ `["accept_join","accept_lead","refuse"]`,否則 `["accept","refuse"]`；新增 `aid_request`→`["give","refuse"]`、`choose_heir`→動態 `["heir_<pid>",…]`。消既有 diplomacy superset drift（舊版恆回 accept+accept_join+accept_lead 四項 superset）。
  - `respond_to_forced` 新增 `aid_request` / `choose_heir` 兩派發分支：aid give→`player_state["aid_response"]={give_amount:AID_GIVE_DEFAULT}`、refuse→`{refuse:true}` 後呼既有 `_action_respond_aid_request`；choose_heir 解 `"heir_<pid>"`→設 `player_state["heir_id"]`→呼既有 `_action_choose_heir`。既有 `_action_*` 契約未改。helper 用既有 `_get_player_team`/`_get_player_team_id`（讀檔確認名）。

- `scripts/simulation/player_api_mapper.gd`
  - `map_forced_interaction` 的 `responses` 不再硬編陣列；改**迭代 `PlayerCommandSystem.new().get_forced_response_options(state)`**,每 id 配 `_forced_label(action,rid,state,evt)` + 統一 `command_args`。→ mapper responses id 集合 == options id 集合,物理上不可 drift。
  - `msg`（display 文案）保留 per-action,補 `aid_request` / `choose_heir` 文案。
  - 新增 `static func _forced_label(action,rid,state,evt) -> String`：各 action 的 label（diplomacy/extort/join_request 保留原文字；aid_request give→「施捨 N 糧」;choose_heir heir_<pid>→候選人姓名）。

- `scripts/debug/headless_test.gd`
  - `_test_forced_choose_heir`（Q7-1 端到端：options 列 heir_<pid> → `resolve_forced_response` 選一 → leader 接位 + player_id 換 + forced 清）。
  - `_test_forced_aid_request`（Q7-2 端到端：options give/refuse → give → 守恆轉糧 + forced 清）。
  - `_test_forced_options_label_no_drift`（drift 防護：6 case 逐 action 比對 `get_forced_response_options` id 集合 == `map_forced_interaction.responses` id 集合,且每 label 非空）。三者註冊於 `_initialize`。

- `scripts/debug/ui_flow_test.gd`
  - `_test_forced_choose_heir_ui` / `_test_forced_aid_request_ui`：注入 forced → `_process` U19 自動進互動模式 → 斷言 DTO `responses` 列候選/give（非只拒絕）→ `_handle_interact_mode(KEY_1)` 驅動選擇 → state 變（leader 接位 / 守恆轉糧）+ forced 清。註冊於 `_initialize`。

## 與 spec 的差異

無。完全依 spec/plan：id 單一源（精確動態）+ mapper 導 label + choose_heir(Q7-1)+aid_request(Q7-2)+順修 diplomacy superset drift。`AID_GIVE_DEFAULT=5.0`（plan 範例值）。helper 確認為 `_get_player_team`/`_get_player_team_id`（非 plan 假設的 `_player_team`,已用實名）。

## 驗證

- `headless_test.gd`：`=== DONE ===`,無 SCRIPT ERROR；`Q7-1 OK` / `Q7-2 OK` / `Q7 drift 防護 OK`；既有 diplomacy/extort/join forced 測試全綠。
- `ui_flow_test.gd`：`=== UI Flow Test DONE === errors: 0`；choose_heir/aid_request forced UI 端到端 PASS（DTO 列候選/give、選擇後 leader 接位/守恆轉糧、forced 清）。
- `game_sim_multi.gd`：4 config（game_sim_test/tyrant/merchant/warzone）coin_eq delta≈0、`違反取樣總計=0`、無 SCRIPT ERROR、無崩潰。

## 連動風險

- `respond_to_forced` 末仍清 `player_forced_event`（保留,重複無害）；新 handler 亦自清,順序安全。
- diplomacy options 由 superset 收斂為精確兩種之一。任何依賴「options 恆含 accept+accept_join+accept_lead」的舊呼叫端會看到較少 id——但這正是 drift 修復目的,且 mapper 同源跟動,UI data-driven 自動正確。已驗無回歸。
- `PlayerCommandSystem.new()` 於 mapper 每次 `map_forced_interaction` 實例化（僅 forced 互動時呼叫,頻率低）。輕量,無狀態副作用。

## 待主 session 確認

- Q7-3（take_loot 文字 UI）/Q7-4（anon→named）/Q7-5（子隊 task）/Q7-6（faction gate）依 spec 為後續獨立 plan,本 branch 未含。
- `AID_GIVE_DEFAULT=5.0` 為 TEST VALUE,正式平衡時與其他時間/資源常數一併調整（見 feedback_tick_balance）。
