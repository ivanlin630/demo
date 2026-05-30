# Hand Back: UI & Balance Fixes

## 實作摘要

- `scripts/simulation/salary_system.gd` — SALARY_INTERVAL 30→720
- `scripts/simulation/harvest_system.gd` — SEASON_LENGTH 30→720
- `scripts/debug/ui_logic_test.gd` — 新建：Task1/2/3 驗證測試，errors: 0
- `scripts/ui/main.gd` — food 300→5000, coin 20→200, material 20→100；persons 加統領/生產/戰鬥 skills；_on_set_move_target 加 tiles 邊界驗證；_on_tick_advanced 加玩家死亡保護
- `scripts/simulation/vision_system.gd` — _can_detect 閾值 0.5→0.3
- `scripts/ui/world_map_view.gd` — setup() 加 _center_on_player()（新增函數）；_process() 加 H 鍵重置；_draw() team 區塊改為視野外用灰色 stale markers
- `scripts/ui/bottom_bar.gd` — show_tile_info 完整替換：視野內顯示地形/速度/農業效率/資源/據點；視野外顯示情報過時/未知
- `scripts/ui/right_sidebar.gd` — refresh_player 完整替換：加 HP/body_parts/skills/完整資源/疲勞/位置

### 與 spec 的差異

- **Task 4（Camera）**：spec 說「移除 refresh() 的 _center_on_player()」，但原始 refresh() 本來就沒有這個呼叫。改為在 setup() 新增 _center_on_player() 函數（spec 只給了呼叫，未給實作，自行實作：用 get_viewport_rect().size 計算）。
- **ui_logic_test.gd Task3**：加了強制 (0,0)/(1,0)/(2,0) 為 plains 的程式，因 seed=42 生成地圖在這些位置為 forest，exposure 不足通過視野偵測。

## 連動風險

- `salary_system.gd`：SALARY_INTERVAL 720 → 每 30 遊戲天付薪一次。若有依賴薪水週期的 stress/loyalty 積累速度的邏輯，節奏會大幅改變（但這是預期行為）。
- `harvest_system.gd`：SEASON_LENGTH 720 → 季節切換變慢。HarvestSystem 以外若有用 `current_tick / SEASON_LENGTH` 計算季節的地方需確認（搜尋結果只有 harvest_system 本身）。
- `vision_system.gd`：閾值降低 → NPC 之間互相發現機率上升，可能使 diplomatic/faction AI 觸發更早。
- `world_map_view.gd`：_center_on_player() 呼叫 `get_viewport_rect().size`，headless 模式下回傳 Vector2.ZERO，不影響功能（只是不對齊，headless 不用地圖）。

## 待主 session 確認

- **_center_on_player() 實作方式**：用 `get_viewport_rect().size * 0.5 - wc * _zoom`。是否符合預期的對齊行為？
- **test setup skills 範圍**：目前只給 leader (p==0) 加 skills（因為 for p in range(3) 迴圈內沒有 if 判斷，全部 3 個 person 都加了），這樣 NPC teams 也會有相同 skills，可能影響 pop_cap 計算。
- **ui_logic_test.gd 視野測試**：強制 plains 是測試用的繞過，如果未來 vision 邏輯要考慮 terrain，test 的設定需調整。
