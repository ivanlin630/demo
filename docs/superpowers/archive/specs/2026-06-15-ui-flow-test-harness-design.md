# UI-flow 測試 harness — Design

> 日期：2026-06-15
> 議題：每個 GUI 修都要用戶手動開遊戲、點擊、回報（U10/U11/U12/U19/U21 都這樣抓）。headless 既有測試只測純函數 / DTO，**測不到輸入流 / 選單 / label 渲染** → 用戶成驗證瓶頸（「我自己測好麻煩」）。
>
> 建 headless UI-flow 整合測試：實例化 `TextUI.tscn` → 注入情境 → 驅動鍵盤 handler → 斷言 label/state。**自動抓我們一直在踩的「輸入流 / 選單 / 顯示內容」class bug**，用戶只剩真·視覺（旗色/佈局/U16 投影）偶爾瞄。

## 可行性（已驗證 2026-06-15 smoke）

headless 可 `load("res://scenes/TextUI.tscn").instantiate()` + `get_root().add_child()` → `_ready` 跑（建 `_state_label`、`_bridge` 含 default.json 12 teams）→ `_handle_interact_mode(keycode)` 可呼叫 → `node._bridge.get_state()` 可注入情境 → `node._state_label.text` 可讀。

## 設計核心

- **harness = `scripts/debug/ui_flow_test.gd`**（extends SceneTree）：實例化 TextUI.tscn、注入 state、驅動 key、斷言 label/state 的 helper 群。
- **注入情境**：取 `node._bridge.get_state()`（WorldState）→ 直接設 teams / player_forced_event / tile / pending → `node._refresh()` 重算 `_cached_snapshot` → handler 看得到。
- **驅動輸入**：直呼 `node._handle_interact_mode(KEY_X)` / `node._handle_pre_encounter_mode(...)` / `node._process(0)`（autoadvance/forced 偵測）。
- **斷言**：讀 `node._state_label.text` / `node._event_label.text` / `node._interact_mode` / `node._interact_target` / `node._interact_page` 等。
- **覆蓋輸入流 + 選單 + 顯示內容**；**不測**真·視覺（顏色/座標/佈局）— 那些仍人工。

## 不變量

- harness 只**讀寫測試自建的 node + 其 bridge state**，不污染其他測試 / 不改 sim 規則。
- 經 node 的公開/半公開介面（_handle_*/_refresh/_cached_snapshot/labels）驅動 + 斷言，**不複製 UI 邏輯**（測真碼，非鏡像）。
- 每測試獨立實例化 + free（避免 node 狀態殘留）。

## 涵蓋案例（首批）

| 案例 | 注入 | 斷言 |
|---|---|---|
| U19 forced 自動進選單 | state.player_forced_event 非空 | `_process` 後 `_interact_mode==true` |
| U21 互動選單分頁 | 12 同格 discovered teams | 翻頁 + KEY_1 選到第 10 項（_interact_target 對） |
| U10 戰後提示 | encounter 結束態 | encounter_view `_lbl_actions` 含「離開」（或既有 static helper 已覆蓋） |
| U12 交易顯示 | 玩家+鄰隊有貨 | trade str 含實際資源（非「無資源」） |
| hunt 動作可選 | 腳下 wild_game>0 | available_actions / 互動清單含 hunt |

（後續 UI 修都加對應 flow 測試 → 自動回歸。）

## 風險

- **timing**：`_ready`/`_process` 需 `await process_frame`（smoke 已驗 2 frame 足）。harness helper 封裝 await。
- **default.json 基礎 state**：實例化帶 12 teams 預設；測試須**清乾淨或覆蓋**相關欄位（如清 pending、設特定 forced_event）避免預設干擾。helper 提供 reset。
- **node free**：每測試 `node.queue_free()` + await，免殘留。
- **非全自動**：真·視覺（旗色/佈局/U16 fog）測不到，仍需人工偶爾驗 — 但流程/選單/內容 class（90% 我們踩的）自動化。
- **scope**：本 harness 針對 text_ui（TextUI.tscn）；圖形 Main.tscn 另論（U9 邊界債）。encounter_view 部分流程可經 text_ui 的 `_encounter_view` 觸及。

## 測試（自我驗證）

- harness 自身：實例化 + reset + 注入 + 驅動 + free 不崩、不洩漏。
- 首批 5 案例：注入已知 bug 修前態應 FAIL、修後 PASS（對已修的 U19/U21 → 應 PASS，證 harness 有效）。
