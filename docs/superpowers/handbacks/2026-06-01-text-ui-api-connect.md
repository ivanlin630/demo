# Hand Back: Text UI → Player API 接口補全

## 實作摘要

- `scripts/simulation/player_api_mapper.gd`：
  - 新增 `_hp_status(p: PersonData) -> String` static private helper（body_parts 掃描）
  - `map_player_summary`：加入 `hp_status`、`skills`（過濾 >0.01）
  - `map_controlled_team`：resources 擴充至全 11 欄位；members 每項加 `hp_status` + `equipment.hand_1/torso`；return dict 加 `faction_display`、`fatigue_pct`、`population`、`minor_population`、`faction_id`
  - `map_visible_teams`：每項加 `faction_display`、`population`

- `scripts/ui/text_ui_main.gd`：
  - `_refresh_snapshot`：`_selected != (-1,-1)` 時補傳 `cursor_tile_q`/`cursor_tile_r`
  - `_visible_team_at`：改從 `_cached_snapshot.visible_teams` 查找，不再直讀 `_state.team_discovered`/`_state.teams`
  - `_build_state_str`：完整改用 `controlled_team`、`player_summary`、`location_context` snapshot；selected tile 仍直讀 `_state.world.tiles`（允許）
  - `_build_member_str`：完整改用 `controlled_team` snapshot
  - `_build_inv_str`：手部裝備改從 `inventory_state.equipped_items` 讀；team 資源改從 `controlled_team.resources` 讀；body_slots 仍直讀 `_state.persons`（mapper 未 expose）

## 連動風險

- `_handle_inv_mode`：仍直讀 `_state.teams.get(_player_tid)` 以傳給 `_get_team_takeable_items`；但 `_get_team_takeable_items` 忽略參數（返回靜態 list），實際無功能影響。若未來 `_get_team_takeable_items` 需要動態化，可一併遷移。
- `_build_interact_str` / `_handle_interact_mode`：仍直讀 `_state.teams` 取 faction/position 顯示，未納入本次 scope。若 spec 要求這些也走 snapshot，需後續 task。
- `map_controlled_team` 新欄位目前未加入 headless_test 斷言，只驗證不崩潰。

## 待主 session 確認

- `_build_inv_str` body_slots（head/torso/right_arm 等）仍直讀 `_state.persons`；若要完整隔離，需 mapper 擴充 `equipped_items` 至全 slot。建議後續 task 評估是否需要。
- `_build_interact_str` 中 pending targets 顯示仍直讀 `_state.teams`；可考慮改用 `visible_teams` snapshot 統一，但需確認 pending targets 必定在 visible_teams 內。
