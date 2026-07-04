# Hand Back: E-3 玩家遭遇戰離場

branch: `feat/e3-player-exit`（已 push origin，未 merge）

## 實作摘要
- `scripts/simulation/encounter_system.gd`：`_decide_action` 玩家 `move` 分支偵測 off-map target（`not _is_in_map(mv)`）→ 回 `{type:"retreat"}`，沿用既有 retreat apply（:870-877，`hex_dist>MAP_RADIUS` 設 `has_exited=true`）。in-map move 維持原 `{type:"move"}` 路徑（行為不變）。
- `scripts/ui/encounter_view.gd`：idle HEX_DIRS handler 目標 off-map → `_do_exit`（pending move 帶場外座標 → encounter_system 轉 retreat）；新增 `_do_exit`（與 `_do_move` 並列）；idle 操作提示兩處（:81 init、:156 refresh）加「移動(邊界→離場)」。
- `scripts/debug/headless_test.gd`：加 `_test_e3_player_edge_exit`（玩家 unit 置邊界、pending move 往場外 → `advance_encounter_tick` → assert `has_exited`），註冊於 `_initialize`。
- `docs/known_issues.md`：E-3 條標 ✅ 已修 + 範圍註記。

與 spec 差異：無。完全照 plan（最小邊界離場、復用 has_exited/retreat apply）。

## 回歸閘
- `--headless --import` parse 乾淨（0 SCRIPT ERROR）。
- `--headless --script headless_test.gd`：`=== DONE ===` ×1、0 SCRIPT ERROR、0 Assertion failed、`E-3 player edge exit OK`、InvariantAudit population/faction/subteam 全 OK、coin_eq 守恆測通過。

## 連動風險
- `encounter_system._decide_action`：只新增 player `move` 分支內 off-map 判斷，NPC/野獸路徑與 in-map player move 完全不動 → 無連動。
- `retreat` apply 共用點（:870）：messenger_exit 也走此分支，但本改動只讓 player 多走 retreat 入口，apply 邏輯未改 → 無連動。
- `encounter_view`：UI 層改動（idle handler + hint），不碰 sim/DTO 契約。

## 待主 session 確認
- **UI run-verify（必要）**：encounter_view 鍵入 headless 不可測。需真人玩測「遭遇戰中玩家在邊界按往場外方向鍵 → 玩家角色離場、encounter 結算/返世界正常」。sim 端機制已由 `_test_e3_player_edge_exit` 證實。
- **範圍裁定（已遵守，無需動作）**：只做最小玩家角色 unit 離場。「退場有代價」（追擊落跑傷兵/慢兵）、全隊撤退 = 藍圖裁定的衝突統一傘，本 branch 未做。
- **finishing**：branch keep as-is，等主 session merge。
