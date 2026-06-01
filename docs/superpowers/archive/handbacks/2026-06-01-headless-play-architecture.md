# Hand Back: Headless Play Architecture (Phase 1)

## 實作摘要

- `scripts/simulation/person_generator.gd` 改寫：新增 static `generate(state, seed_offset, role)` API（24 漢字姓名、seeded RNG）；保留 `generate_from_team()` compat shim 供舊呼叫方使用
- `scripts/simulation/event_system.gd` 小改：呼叫方改用 `generate_from_team()`（因新 static API 簽名不相容）
- `scripts/simulation/population_system.gd` 小改：同上
- `scripts/simulation/world_generator.gd` 擴充：`generate()` 讀 `resource_multiplier`，`_apply_resources()` 接受 `mult: float = 1.0`
- `config/default.json` 新建：seed=42, radius=8, 10 outposts, 3 factions, join_mode=independent
- `scripts/simulation/player_command_system.gd` 新建：`get_player_team`, `get_player_person`, `move_to`, `cancel_move`, `inspect_team`, `inspect_member`
- `scripts/simulation/game_setup.gd` 新建：從 config 統一建世界（地圖 + 據點 + 勢力 + teams + 玩家）
- `scripts/debug/playtest_minimal.gd` 新建：session 驗證腳本
- `scripts/ui/sim_bridge.gd` 擴充：`request_advance`, `tick_step`, `cancel_advance`, `is_advancing`（cherry-pick 自 local main）
- `scripts/ui/text_map_renderer.gd` 改寫：one-line-per-Y, odd-Y indent（cherry-pick 自 local main）
- `scripts/ui/text_ui_main.gd` 重構：`_ready` 改用 GameSetup；`KEY_M` 改呼叫 `move_to`；刪除 `_do_move_auto`；`_process` 加移動完成偵測

## 與 spec 差異

- **PersonGenerator 保留 compat shim**：spec 只要求新 static API，但舊 `event_system.gd` / `population_system.gd` 呼叫 `gen.generate(team, state)` 會 crash。加入 `generate_from_team()` instance method 保持現有系統運作；兩個呼叫方也同步更新。
- **Cherry-pick 3 commits from local main**：worktree 從 origin/main (deed992) 建立，缺少 SimBridge scheduling 和 text_ui refactor 前置 commits（756c76a, 780d535, 3ea604d）。cherry-pick 時 TextMapRenderer 有衝突，取 incoming 版本（即 one-line-per-Y，符合 spec 要求）。

## 連動風險

- `event_system.gd`：呼叫方改用 `generate_from_team()` compat shim，shim 使用全局 `randi_range`/`randf_range`（非 seeded），晉升 leader 名字格式為 `NPC_X`（非中文）。若主 session 希望晉升 leader 也有中文名，需改用新 static API 並提供適當 seed_offset。
- `population_system.gd`：同上。
- `text_ui_main.gd` 大幅重構（494 行變動）：其他 UI 系統（`_handle_interact_mode`、encounter 流程、inventory 模式）未改動，但 `_player_tid` 現在從 `GameSetup` 派生，不再固定為 0。若有其他 UI 程式碼假設 player team_id=0，需檢查。

## 待主 session 確認

- **compat shim 長期方案**：`generate_from_team()` 使用全局 RNG（非 seeded），晉升 leader 無中文名。建議主 session 決定是否在下一個 task 將 event_system / population_system 改用新 static API。
- **playtest_minimal move_to 測試**：`bridge.advance_ticks` 遇 player-relevant event 即提前停止，3 天後 move_target 仍為 (5,11) 未到達（因 SimBridge.advance_ticks 不連續推進到目標）。move_to 功能本身正確，移動完成需透過 TextUI 的 `_process` 非同步偵測；playtest_minimal 腳本無法驗證到達事件（僅能驗證設定成功）。
- **TextUI.tscn 手動驗證**：本 session 無法啟動 GUI，Task 7 Step 5 的人工驗收（NPC 顯示、M 鍵移動、T 鍵互動）需主 session 手動執行。
