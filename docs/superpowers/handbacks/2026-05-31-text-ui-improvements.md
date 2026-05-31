# Hand Back: Text UI Improvements

## 實作摘要
- `scripts/ui/text_map_renderer.gd`：修正 render() — 從 axial X 分行改為 display_col 計算，地圖正確顯示為菱形
- `scripts/debug/map_render_test.gd`（新建）：地圖渲染獨立測試，含 18 行 + @ 中間行斷言
- `scenes/TextUI.tscn`：加 DebugBar（tick/時間/teams）和 InputBar（G key 輸入提示）節點
- `scripts/ui/text_ui_main.gd`：
  - 加 `@onready` refs for DebugBar/InputBar
  - _move_cursor() 加邊界檢查，WASD 不再離開地圖
  - G 鍵：數字輸入模式跳過 N ticks
  - M 鍵：自動推進至目標（最多 1000 ticks，每天刷新）
  - _build_state_str() 增強：玩家 HP/技能、完整資源欄、選中格 team 資訊
  - _build_debug_str()：tick/時/日/月/季、所有 teams 位置、最近 10 事件和訊息
  - P 鍵：成員面板（隊長 + named_members 裝備/HP、匿名人口、武裝率）
  - I 鍵：背包面板（裝備槽、背包列表、從 Team 取出），E/S/G 鍵操作
  - _ready() 加 player_state 初始化

## 連動風險
- `text_ui_main.gd` 的 `_ready()` 只初始化單一玩家 team；正式遊戲需更完整的世界初始化（多 NPC teams）
- `_build_debug_str()` 會列出所有 teams — world 規模大時 debug bar 文字很長，可能需要後續截斷
- `_handle_inv_mode()` 的 KEY_S 呼叫 `player_sys.deposit_to_team()` — 若 PlayerSystem 未來修改簽名需同步更新

## 待主 session 確認
- 目測確認（需開 Godot 啟動 TextUI）地圖菱形顯示是否正確？
- 初始 team 設定是否需改成載入完整多 team 世界以便測試 debug bar？
- G 鍵上限 99999 ticks 是否合理（240 ticks/day → 約 416 天）？
