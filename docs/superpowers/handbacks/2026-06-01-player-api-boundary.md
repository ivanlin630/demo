# Hand Back: Player API Boundary

## 實作摘要

### 新增檔案
- `scripts/simulation/player_api_mapper.gd` — 純靜態 DTO 映射；所有 `map_*` 函數；無遊戲邏輯
- `scripts/simulation/player_query_api.gd` — snapshot 查詢組合；`get_player_snapshot` 返回帶 envelope 的完整 snapshot
- `scripts/simulation/player_command_api.gd` — 指令驗證+分派；`dispatch(state, name, args)` 入口

### 修改檔案
- `scripts/data/world_state.gd` — 加 `player_forced_event_id: String = ""`
- `scripts/simulation/interaction_system.gd` — 外交/勒索兩路徑各加 `player_forced_event_id = str(randi())`
- `scripts/simulation/player_command_system.gd` — `respond_to_forced` 加清除；新增 `resolve_forced_response`（帶 ID 驗證）
- `scripts/ui/sim_bridge.gd` — 加 `query_player(request = {})` / `command_player(name, args)` 及 4 個輔助查詢方法
- `scripts/ui/popup_layer.gd` — 4 個 `PlayerSystem.new().*` 呼叫換成 `_bridge.command_player(...)`
- `scripts/ui/main.gd` — `_on_set_move_target` 改用 `_bridge.command_player("move_to", ...)`
- `scripts/ui/text_ui_main.gd` — 加 `_cached_snapshot`；`_refresh()` 加 `_refresh_snapshot()`；所有 `_state.player_*` 欄位直讀改成 snapshot；所有 `_player_cmd.*` 指令呼叫改成 bridge
- `scripts/debug/headless_test.gd` — PlayerApiMapper / PlayerQueryApi / PlayerCommandApi / SimBridge 四段測試

### 與 spec 的差異
- `query_player(request: Dictionary)` 改為 `= {}` 預設（原 spec 未標示）
- `_refresh_snapshot()` 從 envelope 解包：`.get("data", {}).get("snapshot", {})`（原 spec 未說明解包邏輯）
- `_handle_interact_mode` 中 respond 使用 snapshot 的 `responses[i].command_args` 直接傳 bridge，不再呼叫 `_player_cmd.get_forced_response_options`

## 連動風險

- `interaction_system.gd`：`player_forced_event_id = str(randi())` 有極低碰撞風險；可考慮改用雙 randi 或 UUID
- `text_ui_main.gd`：`_player_cmd.get_available_actions` 仍在使用（查詢型，非指令），尚未替換為 bridge
- `sim_bridge.gd`：每次 `_refresh()` 執行完整 snapshot 組合，高頻 tick 可能有輕微效能影響

## 待主 session 確認

1. **`_player_cmd.get_available_actions` 是否保留** — text_ui_main.gd 仍在互動模式中呼叫。若要完全隔離可改成 `_bridge.query_player_actions(...)` 並解析 actions 陣列。

2. **`player_forced_event_id` 碰撞風險** — 目前 `str(randi())`，建議評估是否強化。

3. **建議後續 task**：
   - 完全移除 text_ui_main.gd 中的 `_player_cmd`（替換 `get_available_actions`）
   - `_cached_snapshot` refresh guard（避免每幀重建 snapshot）
   - 遭遇戰 UI（EncounterSystem 已有邏輯層）
