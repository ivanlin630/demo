# 游標停在哪格，側欄就顯示那格你知道的——HOW

狀態：待 R²
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-cursor-hover-shows-full-known-detail-without-enter（第五輪用戶回饋 #4：「游標移到它格或它隊 不會顯示記憶或已知或看到的情況?」「我沒按 Enter 按了就有」）
順位：玩家可見批第 6 張（情報面板之後、第 7 張之前）。

## 事實（main 5f5180734）
- `text_ui_main.gd:27` `_selected`；唯一寫入點 `:474-476`（主畫面 KEY_ENTER ⇒ `_selected = _cursor`）。
- 讀者只有兩處，都是顯示：
  - `:236-238 _refresh_snapshot`：`_selected` 有值才把 `cursor_tile_q/r` 送進 `query_player` ⇒ 快照的格脈絡（occupants 等）只在按過 Enter 後才算。
  - `:1860-1890` 側欄「選中: (q,r)」區塊：讀 `tile_knowledge(_selected)`（belief-gated，F7b）＋快照 occupants。
- `_move_cursor`（:855-859）結尾已呼叫 `_refresh()`，而 `_refresh()` 第一行就 `_refresh_snapshot()` ⇒ **游標每動一格本來就重查快照**；只是查的不是游標那格。
- 沒有任何互動／移動／M 讀 `_selected`（M 讀 `_cursor`；互動讀 `_interact_target`）⇒ **Enter 選格除了改側欄顯示之外沒有任何效果**。
- 鍵列 `:1185` 寫「[Enter]選格」。

## 改法
1. **側欄明細讀游標**：`:1860` 區塊改讀 `_cursor`，永遠顯示（不再有「未選」狀態）；標頭「選中:」改「游標處明細:」（與頂部一行「游標處」同源同資料，頂部那行是一行摘要、側欄是全文——不新增第二支查詢）。
2. **快照請求讀游標**：`_refresh_snapshot` 一律送 `cursor_tile_q/r = _cursor`。資料來源不變（`query_player` 的格脈絡＋`tile_knowledge`，全 belief-gated）；不新增真值讀取。
3. **`_selected` 刪除**（變數、寫入點、讀者一起）。理由：它唯一的效果就是本票要拿掉的門檻；留一個沒有消費者的「鎖定」狀態＝死狀態，下一個人會以為它有用途。
4. **主畫面 Enter 不再綁**：鍵列拿掉「[Enter]選格」；按 Enter 走主畫面未綁鍵的既有回句。藍圖說「Enter 保留給鎖定目標（之後 M／互動用）」——那張票出現時連同它的消費者一起加回，不預留空狀態。其他模式的 Enter（輸入確定、交易送出、選單）不動。
5. **明細內容不擴**：本票只換「看哪一格」，不改明細欄位；欄位與情報面板 I7「同一隊同一過期閘」的一致性由情報面板票負責（兩票共用 `tile_knowledge`／`_remembered_teams_at`，不各寫一份）。

## 會動的床（實作端照實列在交件信）
- `terminal_e2e_bed.gd:1723`（`node._selected = far`）、`:1818`（找「選中: 」）；`ui_flow_test.gd:1109`、`:1921-1947`（以 `_selected` 未選當母體地板）；`ui_state_str_capture.gd:162-203`（逼出選中區塊）；`MIXED_PAGE_LINES`（`:1647` 含 "選中: "）；`multi_hop_move_bed.gd:20` REPRO_KEYS 含 "enter"（改後按 Enter 只得未綁回句，重現序列要不要拿掉它由實作端判，判準：那顆鍵原本有沒有承擔語意）。
- 改的是錨字與佈置方式，判準不動；`_selected` 相關的母體地板改成「游標真的動了」。

## 驗收（各格「由什麼判」＝新床 `cursor_hover_bed.gd`，acceptance，註冊表登一列）
- C1（修前紅）：管道送 `w`（不送 enter）⇒ 側欄「游標處明細: (q,r)」座標＝`_cursor`。
- C2：游標移到沒去過的格 ⇒「沒去過」；移到記得的格 ⇒ 地形＋「糧量：未記錄」；移到視野內 ⇒ 糧量數字（三態都從游標移動得到，不按 Enter）。
- C3：游標移到一格有已知隊伍 ⇒ 明細列出該隊；同一格頂部「游標處」一行與側欄明細的隊伍集合相同（同源）。
- C4：主畫面按 Enter ⇒ 未綁回句、畫面除結果行外不變；鍵列無「Enter」。
- C5 零真值：游標移到一格，真值有隊而附身隊不知道 ⇒ 明細不列（佈置：把一支 NPC 隊放到附身隊視野外、從未見過的格）。
- 負對照：明細改回讀一個只在 Enter 時更新的變數 ⇒ C1 紅；快照請求不送游標 ⇒ C3 紅。
- terminal E2E 照綠；world-fp 不變（只動 UI）。

## 範圍外
- 「鎖定目標」（Enter 的未來用途）：連消費者一起另開。
- 明細欄位擴充（關係、實力估、位置年齡）：情報面板票。
