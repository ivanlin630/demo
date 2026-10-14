# 游標停在哪格，側欄就顯示那格你知道的——HOW

狀態：R² ISSUES（2026-10-14-reviewer-to-systems-R2-cursor-hover-ISSUES）已補——一擋（來源洩漏）照建議改在來源；補完不需再審，交件信貼 map_location_context 改法與 C5 佈置給審查核
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
- ★**來源洩漏（R² 擋）**：快照的格脈絡 `PlayerApiMapper.map_location_context`（player_api_mapper.gd:622-670）對任何在圖格回**真值**——occupants 逐隊比真實 `tile_pos`、`visibility_state` 寫死 "visible"、food／wild_game／predator／settlement 全真值；只有不在圖才回 hidden 殼。側欄今天只在 UI 層擋「沒去過」；**記得但不在視野**的格照印 `lc.occupants`＝此刻真正站在那裡的隊。今天要按 Enter 才開；本票若只改成跟游標走＝WASD 掃過就看到每個去過的格上現在有誰。且洩在 payload 層（任何送 cursor 的消費者都拿得到）。

## 改法
1. **側欄明細讀游標**：`:1860` 區塊改讀 `_cursor`，永遠顯示（不再有「未選」狀態）；標頭「選中:」改「游標處明細:」（與頂部一行「游標處」同源同資料，頂部那行是一行摘要、側欄是全文——不新增第二支查詢）。
2. **快照請求讀游標**：`_refresh_snapshot` 一律送 `cursor_tile_q/r = _cursor`。
2b. **★先在來源補知識閘（R² 擋，必須在 2 之前或同 commit）**：`map_location_context` 改成以 `PlayerQueryApi.tile_knowledge`（同一支，不另寫）的結果組 payload：
   - `off_map`／`no_team` ⇒ 既有 not_visible 殼。
   - `unvisited` ⇒ `visibility_state:"hidden"`、terrain／settlement／food／wild_game／predator 皆無；`occupants` ＝ tile_knowledge 的 `teams`（belief 記得在那格的隊——地圖畫 a? 的同一份；沒有就空）。
   - `remembered` ⇒ `visibility_state:"remembered"`、terrain、settlement 只取 tile_knowledge 的 `outpost`（已知據點）、`occupants` ＝ tile_knowledge 的 `teams`（belief）；**不給** food／wild_game／predator。
   - `visible` ⇒ 今天的真值（tile_knowledge visible 分支本來就含視野內真隊）。
   - occupants 一律由 tile_knowledge 的 `teams` 映射（id、名、tick、heard），**不再逐隊比真實 tile_pos**。
   - 消費者普查：實作端列出所有讀 `location_context` 欄位的地方（`text_ui_main` 側欄、PlayerRepl、床），讀 `visibility_state=="visible"` 或讀 food 的要對 remembered 新值不壞。
2c. **側欄與頂部「游標處」同一份**：兩處都讀同一次 `tile_knowledge` 結果（每幀算一次，三處共用；不各掃一圈全隊）。側欄「人口」照舊只從 `visible_teams` 取、不在視野印「?」（R² ③，不得為補欄位讀真值）。
3. **`_selected` 刪除——只限 `text_ui_main.gd`**（變數、寫入點、讀者一起）。`world_map_view.gd:20`（GUI 滑鼠選格）與 `observer_inspect_panel.gd:14`（觀察者選隊）是各自獨立的同名變數，不動。理由：它唯一的效果就是本票要拿掉的門檻；留一個沒有消費者的「鎖定」狀態＝死狀態，下一個人會以為它有用途。
4. **主畫面 Enter 不再綁**：`KEY_ENTER` 分支與鍵列 `:1185`「[Enter]選格」**同一 commit 一起刪**（unbound_key_bed P2 機械抽 KEY_ 分支比對鍵表，只刪一邊會紅）；`text_ui_layout_bed.gd` 約 :213 的 keymap 夾具「Enter 選中」同步改。★主畫面 match 沒有 default 分支、沒有主畫面未綁回句（R²；同按 Q 那張的前提錯）⇒ 按 Enter 的結果＝什麼都不發生；要一句話是另一張票（動 unbound_key_bed／不變量 #10），本票不做。藍圖說「Enter 保留給鎖定目標（之後 M／互動用）」——那張票出現時連同它的消費者一起加回，不預留空狀態。其他模式的 Enter（輸入確定、交易送出、選單）不動。
5. **明細內容不擴**：本票只換「看哪一格」，不改明細欄位；欄位與情報面板 I7「同一隊同一過期閘」的一致性由情報面板票負責（兩票共用 `tile_knowledge`／`_remembered_teams_at`，不各寫一份）。

## 會動的床（實作端照實列在交件信）
- `terminal_e2e_bed.gd:1723`（`node._selected = far`）、`:1818`（找「選中: 」）；`ui_flow_test.gd:1109`、`:1921-1947`（以 `_selected` 未選當母體地板）；`ui_state_str_capture.gd:162-203`（逼出選中區塊）；`MIXED_PAGE_LINES`（`:1647` 含 "選中: "）；`multi_hop_move_bed.gd:20` REPRO_KEYS 含 "enter"（那顆鍵原本只承擔「選格」，沒有語意 ⇒ 拿掉）。
- 改的是錨字與佈置方式，判準不動；`_selected` 相關的母體地板改成「游標真的動了」。

## 驗收（各格「由什麼判」＝新床 `cursor_hover_bed.gd`，acceptance，註冊表登一列）
- C1（修前紅）：管道送 `w`（不送 enter）⇒ 側欄「游標處明細: (q,r)」座標＝`_cursor`。
- C2：游標移到沒去過的格 ⇒「沒去過」；移到記得的格 ⇒ 地形＋「糧量：未記錄」；移到視野內 ⇒ 糧量數字（三態都從游標移動得到，不按 Enter）。
- C3：游標移到一格有已知隊伍 ⇒ 明細列出該隊；同一格頂部「游標處」一行與側欄明細的隊伍集合相同（同源）。
- C4：主畫面按 Enter ⇒ 程式仍在、畫面不變（結果行亦不變）；鍵列無「Enter」。
- C5（修前紅）零真值——**remembered 格**：附身隊走過格 X 後離開（X 不在視野）、之後一支附身隊沒見過的 NPC 隊被放上 X ⇒ 側欄不列它，且 **payload 層** `snapshot.location_context.occupants` 不含它、`visibility_state=="remembered"`、無 food 欄。
- C5b 陰性對照——unvisited 格且 belief 在那格沒有隊、真值放一支隊 ⇒ `occupants` 為空、`visibility_state=="hidden"`（今天 UI 也擋，但斷言放在 payload 層）。
- C5c——visible 格 ⇒ 真值隊列出、food 有值（閘沒有把看得見的也擋掉）。
- 負對照：明細改回讀一個只在 Enter 時更新的變數 ⇒ C1 紅；快照請求不送游標 ⇒ C3 紅；`map_location_context` 拿掉知識閘（改回逐隊比真實 tile_pos）⇒ C5 紅。
- 效能（R² ④）：在隊數最大的世界量一次游標移動的單幀成本，寫進交件信（可慢不可卡）。
- terminal E2E 照綠；world-fp 不變（只動 UI）。

## 範圍外
- 「鎖定目標」（Enter 的未來用途）：連消費者一起另開。
- 明細欄位擴充（關係、實力估、位置年齡）：情報面板票。
