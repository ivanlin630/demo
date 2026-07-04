# Hand Back: B4 成員管理（調薪 / 武裝anon / 成員裝備）

branch: `feat/b4-member-management`

## 實作摘要

- `scripts/simulation/player_command_system.gd`：
  - `set_armed_anon_ratio` 加入 registry（none-target，比照 `set_tribute_rate`），handler `_action_set_armed_ratio` 讀 `player_state["armed_ratio_input"]`，clamp 0~1 寫 `team.armed_anon_ratio`。
  - `execute_action_with_target` match 增 `set_member_salary` / `equip_member` / `unequip_member` 三 case + 私有 handler。**member-target 動作走 match 而非 registry**（與 plan 文字不同；plan 原寫「加 registry」，實際 member 動作經 `execute_action_with_target`，已照現行碼對齊）。
  - 裝備守恆：equip 從 `team.resources` 扣 1、原槽 pool 裝備還回；unequip 還回池。2h 武器同步 set/clear `hand_2` 2h_ref（比照 `player_system.equip_item`）。
- `scripts/simulation/player_api_mapper.gd`：`map_controlled_team` 補 `armed_ratio` 欄位（= `t.armed_anon_ratio`）。
- `scripts/ui/text_ui_main.gd`：
  - 主模式 `[R]` → numeric input → `armed_ratio_input`（輸入 0~100 %）→ `set_armed_anon_ratio`。
  - member 模式 equipment submode `[E]` 裝 team 池第一個可用武器到 hand_1、`[U]` 卸下；任一 submode `[Y]` 數字輸入調薪 → `set_member_salary`。
  - status 行顯示武裝比例 `(比例N%)`；member 視圖底部加鍵位提示。
- `scripts/debug/headless_test.gd`：+3 測（`_test_set_member_salary` / `_test_set_armed_ratio` / `_test_equip_member`）。
- `scripts/debug/ui_flow_test.gd`：+2 測（`_test_member_equip_flow` / `_test_armed_ratio_cmd`）。

## 與 spec 的差異

- member-target 指令實作於 `execute_action_with_target` match block，非 registry（plan step 3 文字誤導，已按「讀現行對齊，勿臆造」原則修正）。
- UI `[E]` 採「裝 team 池第一個可用武器」最小流程（plan 容許「裝第一個可用」）；未做選武器子流程。
- 調薪鍵用 `[Y]`（plan 提 `[$]`/`[Y]`，`$` 無單一 keycode）。

## 驗證

- headless：`=== DONE ===`，3 新測綠（`set_member_salary OK` / `set_armed_ratio OK` / `equip_member OK`）。
- ui_flow：`errors: 0`，含 equip/ratio/status 比例斷言。
- ui_logic：`errors: 0`。
- 既存 baseline 仍有 1 個與本批無關的 assertion `_test_on_team_extinct_to_storage`「food 應進公庫」（baseline Bug8，未動）。

## 連動風險

- `player_api_mapper`：`controlled_team` 新增欄位 `armed_ratio`，純加欄不破壞既有讀取；右側欄/其他 UI 不受影響。
- `armed_anon_ratio`：本批僅提供玩家寫入入口，未檢查是否有 tick 系統實際依該比例武裝 anon。**待主 session 確認**該欄位下游消費端（武裝結算）是否如預期讀取，否則玩家設了無效果。
- equip_member 直寫 `m.equipment`，未走 `player_system`；NPC 成員裝備若另有結算路徑（戰力計算讀 equipment）應自然生效，但未端到端驗。

## 待主 session 確認

- `armed_anon_ratio` 下游：確認模擬端有依此比例武裝 anon（否則 U18 入口僅為設值）。
- member 裝備真視覺（鍵位/三欄版面）尚待人工 run-verify；指令與 flow 已自動測。
- 後續可加：member 裝備選 slot / 選武器子流程（目前固定 hand_1 + 第一個可用）。
