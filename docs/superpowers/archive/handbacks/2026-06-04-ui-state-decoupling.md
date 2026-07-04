# Hand Back: UI State Decoupling

## 實作摘要

- `scripts/simulation/player_api_mapper.gd`：加 `wounded` 欄位至 `map_controlled_team`；加 `loyalty`/`stress` 至 `map_player_summary`；新增 `map_body_slots`、`map_global_messages`、`map_visible_teams_render` 三個 static 函式
- `scripts/ui/sim_bridge.gd`：新增 15 個 helper 方法（`get_current_tick`、`get_player_tile_pos`、`get_player_move_target`、`is_valid_tile`、`query_tile`、`render_text_map`、`query_body_slots`、`query_global_messages`、`query_visible_teams_render`、`query_world_tiles`、`is_tile_in_vision`、`has_tile_intel`、`get_teams_at_tile`、`get_all_teams_debug`、`query_render_context`）
- `scripts/ui/text_ui_main.gd`：移除 `var _state: WorldState`；`_ready()`、`_process()`、`_move_cursor()`、`KEY_H handler`、`_refresh()`、`_build_state_str()`、`_build_debug_str()`、`_build_member_str()`、`_build_inv_str()`、`_build_interact_str()` 全改用 bridge 呼叫
- `scripts/ui/right_sidebar.gd`：`refresh_player()` 改用 `_bridge.query_player({})` snapshot；刪除 `_find_team_at` dead code
- `scripts/ui/bottom_bar.gd`：`show_tile_info()` 改用 `is_tile_in_vision`、`query_tile`、`get_teams_at_tile`、`get_player_tile_pos`、`has_tile_intel`；修正 faction_id 改用 safe `.get()` 存取
- `scripts/ui/world_map_view.gd`：加 `_cached_tiles`/`_cached_teams`/`_render_ctx` 快取欄位；`setup()`/`refresh()`/`_center_on_player()`/`_draw()` 全改用快取；刪除 `_is_tile_discovered`、`_is_team_visible`、`_draw_team_marker`；新增 `_is_tile_visible()` helper（含 no-player guard）

與 spec 的差異：`sim_bridge.gd` 新增方法數為 15（spec 標題寫 12，但 spec 內容列出 15 個）。

## 連動風險

- `scripts/ui/sim_bridge.gd`：新增 15 個 public 方法，若其他 UI 檔（如 `main.gd`、`popup_layer.gd`）有類似直讀 `_state` 的情況，可比照本次模式補修
- `scripts/simulation/player_api_mapper.gd`：`map_controlled_team` 新增 `wounded` 欄位、`map_player_summary` 新增 `loyalty`/`stress` 欄位，消費這些 API 的其他地方（`PlayerQueryApi`、`player_command_api`）不受影響，但 snapshot 欄位有變化，若主 session 有文件記錄 snapshot schema 需同步更新

## 待主 session 確認

- `query_tile()` 同時回傳 `"productivity"` 與 `"harvest_factor"` 兩個欄位（值相同）：`text_ui_main` 用 `productivity`、`bottom_bar` 用 `harvest_factor`，目前保留兩者作為別名，主 session 可決定是否統一
- `map_visible_teams_render` 回傳 `tile_pos: Vector2i`（GDScript 原生型別），與 `map_visible_teams` 回傳 `"position": {"q":x,"r":y}` 格式不同；目前下游 `world_map_view` 直接以 Vector2i 使用，無問題，主 session 可決定是否統一格式
