# Hand Back: UI-flow 測試 harness

## 實作摘要

- `scripts/debug/ui_flow_test.gd`（新建）：headless UI-flow 整合測試 harness（extends SceneTree）。helper `_make_ui`（實例化 TextUI.tscn + 2× await frame）/`_free_ui`/`_check`。首批 4 案。
- `docs/progress.md`：測試表新增 ui_flow_test 一列。

### 各案 PASS/FAIL（最終全跑 errors: 0，無 SCRIPT ERROR）

| 案 | 結果 | 驗的事 |
|---|---|---|
| harness smoke | PASS | 場景實例化、_state_label/_bridge 存在、_handle_interact_mode 可呼叫 |
| U19 forced 自動進互動 | PASS | 注入 player_forced_event → _process 自動進 _interact_mode |
| U21 互動選單分頁 | PASS | 同格 12 隊 → [.] 翻頁 + KEY_1 選到全域第 10 項 |
| U12 交易顯示 | PASS | _build_trade_str 顯真資源（非「無可交換」）|
| hunt 動作可選 | PASS | 腳下 wild_game → available_actions 含 hunt |

### 與 plan 的差異（對齊現行碼，非臆造）

- **U19**：plan 只 `_process(0.0)`，但現行 `_process` 早段 `if not is_advancing(): return`。補 `request_advance(1)` 才跑到 forced 偵測分支。
- **U21**：plan 用 `team_discovered` 造 pending，但現行 `refresh_colocation_targets` 只看「同格 tile_pos + combat_target==-1」與 discovered 無關。改為純造同格隊。加 `pending_targets >9` 前置斷言。
- **U12**：plan 未把 6001 加入 `team_discovered`，但 `query_trade_direct_preview` 對未發現 target 回 not_visible（無 preview）→ 會 FAIL。補 discovered + other.food=0（使 preview_trade feasible：玩家 food>10 且對方更少 → 付出食物）。
- **hunt**：確認 hunt 出自 `_build_available_actions` Layer 6（依 `pt_tile_self` 腳下 tile wild_game），非 plan 註的泛 Layer。snapshot 路徑成立。

## 連動風險

- **無已知連動風險**：純測試新增，未動 sim/UI 產品碼。
- harness 依賴現行 text_ui_main 私有欄位/方法名（`_bridge`/`_cached_snapshot`/`_interact_mode`/`_interact_target`/`_interact_page`/`_trade_mode`/`_trade_target_id`/`_build_trade_str`/`_handle_interact_mode`/`_refresh`/`_process`）。**未來 UI 重構若改名，harness 需同步**（FAIL 會立即揭示）。

## 待主 session 確認

- 新 worktree 首跑須先 `.\tools\godot.ps1 --headless --import` 重建 class 快取，否則 text_ui_main 解析失敗（已處理）。
- 建議後續：U16 fog / 旗色 / 佈局等「真視覺」不在本 harness 範圍（plan 已聲明）；若要覆蓋需另開 render 比對手法。
- 建議將 ui_flow_test 納入常規測試清單（與 headless_test / team_ui_test 並列跑）。
