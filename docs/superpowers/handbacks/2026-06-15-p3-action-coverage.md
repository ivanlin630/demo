# Hand Back: P3 全動作覆蓋

對應 spec `docs/superpowers/specs/2026-06-15-p3-action-coverage-design.md` /
plan `docs/superpowers/plans/2026-06-15-p3-action-coverage.md`。
分支 `feat/p3-action-coverage`。後端 6 個 `_action_*` 既有，本次只暴露 DTO/面板列/emit + UI，零後端行為改動。

## 實作摘要
- `scripts/simulation/outpost_system.gd`：加公開 `storage_cap(tile,res)` wrapper（包私有 `_get_storage_cap`）。
- `scripts/simulation/player_api_mapper.gd`：
  - 新 `map_storage_panel`（feasible/stored/team_res）。
  - `map_outpost_panel` 在 has_ctrl 分支加 `abandon_outpost`、`build_facility`（空 slot 時）。
  - `map_faction_panel` leader 分支加 `extract_treasury`。
- `scripts/simulation/player_query_api.gd`：新 `get_storage_panel`；`_action_label` 加 `invite_settle`→「邀請定居」。
- `scripts/simulation/player_command_system.gd`：`get_available_actions` emit `recruit_anon`/`invite_settle`；加 `_target_has_anon`/`_can_invite_settle` helper。
- `scripts/ui/sim_bridge.gd`：`query_storage_panel` facade。
- `scripts/ui/text_ui_main.gd`：
  - 公庫 mode（`_storage_mode`/`_storage_page`/`_build_storage_str`/`_storage_rows`/`_handle_storage_mode`），入口鍵 **`[K]`**（非 plan 的 `[G]`，見下）。
  - outpost：`_handle_outpost_mode` 加 `build_facility`（`_prompt_build_facility` 設施選單）+ `abandon_outpost`（二次確認，`_outpost_pending_abandon`）；`_build_outpost_str` ACTION_LABELS 加「蓋設施」「棄置據點」。
  - faction：`_handle_faction_mode` 加 `[G]` extract_treasury（比例輸入，>0.5 高比例需再按 `[G]` 確認，`_faction_extract_pending`）；`_build_faction_str` leader 加「[G]徵用國庫」。
  - MODE_KEYMAP/`_close_all_modes`/`_current_mode_name`/`_refresh` dispatch 全接 storage mode。
- `scripts/debug/headless_test.gd`：+`_test_storage_panel_dto`、`_test_get_actions_recruit_anon_invite`、`_test_storage_conservation`、`_test_extract_treasury_conservation`。
- `scripts/debug/ui_flow_test.gd`：+`_test_storage_panel_ui`、`_test_outpost_build_abandon`、`_test_faction_extract_treasury`。

## 與 spec/plan 的差異
1. **公庫入口鍵 `[G]`→`[K]`**：plan 指定 `[G]`，但 text_ui_main 主模式 `[G]` 已綁「跳過 Tick 數」。改用 `[K]`（公庫），已同步 MODE_KEYMAP。
2. **`invite_settle` emit 前提**：plan 留白。實作前提＝玩家站在「自家 outpost」（`tile.outpost_owner==pt_id and outpost_level>0`），對齊後端 `_action_invite_settle` 需 `settle_pos` 指向自家 outpost。

## 連動風險
- **`invite_settle` 經互動選單執行會失敗**：emit 後該動作進互動選單（team-target，`_build_available_actions` 自動渲染），但 `_action_invite_settle` 讀 `state.player_state["settle_pos"]`，互動選單路徑未設 → 必回「未指定 outpost 位置」。本 plan 範圍僅「emit/暴露對稱性」，**settle_pos 的 UI 收集尚未接**。建議後續 task：互動選單選 `invite_settle` 時，以玩家腳下 outpost pos 自動填 `settle_pos`（或加位置輸入）。recruit_anon 無此問題（只讀 target_id）。
- **`recruit` 與 `recruit_anon` 並列**：互動選單同時出現「招募」（開選單）與「招募匿名」（直接執行），label 已區分；玩家體感差異待人工確認。
- 其餘為純讀 DTO / 既有 command，無世界模型改動。

## 待主 session 確認 / 人工 run-verify
- **真視覺面板版面**：公庫存取分頁、outpost 設施選單、abandon/extract 二次確認的實際畫面與按鍵流，headless 僅驗字串/DTO，建議手動跑 TextUI 確認版面與二次確認手感。
- **既有失敗（非本次造成）**：`headless_test._test_on_team_extinct_to_storage`（line ~5182）斷言失敗。根因：`faction_ai_system._on_team_extinct` 已重構為「標記 pending → `cleanup_extinct_teams` 中 `_route_extinct_assets`」延遲路由，但該測試仍斷言 `_on_team_extinct` 後公庫立即有值。faction_ai 與該測試本次均未改動 → baseline 既存。建議：修測試改呼 `cleanup_extinct_teams` 或斷言 pending。
  - 驗證結果：headless 全跑僅此 1 個 assertion、0 Parse Error；ui_flow 0 errors；ui_logic 0 errors。本次新增 7 測全綠。
