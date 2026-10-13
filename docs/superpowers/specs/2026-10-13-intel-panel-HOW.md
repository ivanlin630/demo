# 情報面板：玩家查得到「我知道什麼」——HOW

狀態：收 R²（…-R2-intel-panel-ISSUES，同版不需再審）
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-intel-panel-and-intel-event-folding ③（第五輪用戶回饋 #6：「也沒記憶與情報欄位可以查看？」）
順位：本批（Q 鍵／子隊輸入／地圖整寬／勒索 0／附身隊三件）之後、游標即選中之前。

## 事實（main 3802f3db6）
- **已有一頁「記憶」**：分頁第 5 頁（`ui_pages.gd:14` PAGE_ORDER），`text_ui_main.gd:1794-1808 _build_memory_lines` 讀 `PlayerQueryApi.query_memory_panel`（player_query_api.gd:53-87）。它只列「Team N：幾筆｜最新 T｜傳聞來源｜有疑點」——**沒有位置、親見／聽說、關係、實力**，也沒有據點／市集／勢力。用戶沒找到它（分頁要用 , . 切到第 5 頁，鍵列沒有直達鍵）。
- 資料來源都已存在：`BeliefSystem.known_targets`／`claims`／`best_estimate`（位置、last_tick、source）；`PlayerQueryApi.tile_knowledge`（:412，游標處同一份）；已知據點關係 `FactionAISystem._known_outpost_relations`（faction_ai_system.gd:6069，F9′）。
- 糧源情報：belief 沒有這一種（深層批「糧源情報 kind」）。

## 決定
**不另開第二個面板，把既有「記憶」頁擴成情報頁，並給它直達鍵**（藍圖要的「新鍵、鍵列全列」由直達鍵滿足；同一份資料不開第二個出口）。
- 頁名「記憶」改「情報」（PAGE_ORDER 第 5 項）；鍵列加直達鍵（實作端挑一個主畫面未綁的鍵，登進 MODE_KEYMAP 與 unbound_key_bed）。
- 查詢面 `query_memory_panel` **不改名**（R²：3 支床 4 個呼叫點，價值低），函式註解寫「頁名＝情報」。擴欄如下。
- **payload 是 belief 的純函數**：不得含「N 分鐘前」「距今」等相對現在的欄（`inquiry_writes_bed` 以 JSON 前後比對、`terminal_e2e_bed` 存整個快照，相對欄會讓它們隔 tick 誤紅）。查詢回**絕對 tick**；「N 分鐘前」在 UI 組句時算，在 UI 層驗。
  - **隊伍**：對象、最後所知位置、位置的 tick（**`value.last_tick`**＝位置年齡，轉述時繼承 giver 的；不是收到 claim 的 tick；UI 欄標「位置是 N 分鐘前的」）、親見／聽說（**重用 `_remembered_teams_at` 的謂詞**：source_type=="親見" 且 source_id==ptid，不自寫）、來源、有疑點、關係（**`TeamData.known_reputations`**，隊層 belief；未知印「不明」，不用預設 0.5；不讀 leader.relations／relation_edges）、實力估（若有）。
    - **staleness**：位置與游標處 `_remembered_teams_at` 過同一道閘（belief_pos 的過期線）。過期的 ⇒ 面板仍列該隊，但位置欄印「（太久，視同不知）」，並從 I7 母體排除。
    - 有 claim 沒位置（best_estimate 為 {} 或無 tile_pos）⇒「位置不明」。
  - **據點與市集**：讀 `_known_outpost_relations` 同一支，以附身隊 pt 呼叫（游標處 F7 已這樣，player_query_api.gd:432；它讀的是該隊自己的 known_outposts 與自家勢力名冊）。關係值 g 唯一人層讀取是該隊領袖的 relation_edges ⇒ **採 (a)：g＝隊的立場（取自領袖）**，類別標頭一句「關係＝你隊伍領袖的看法」。與游標處一致。
  - **勢力關係**：只列附身隊 belief 裡有的；沒有 ⇒「尚無」。
  - **糧源**：印「尚無（還沒有這種情報）」，不偽造。
- 每類 0 筆也印一行「尚無」（沿用現行「0 筆也印」的原則）。
- 長清單：每類最多 N 列＋「另有 M 筆」；N 讀分頁框**實際可用列數**（地圖整寬票之後版面才定，不寫死）；排序：位置 tick 新的在前。
- **零真值**：面板任何欄都不得讀 `state.teams[x].tile_pos` 等真值；親見的位置也是 belief 裡那一筆。

## 驗收
- I1（修前紅）：直達鍵一按 ⇒ 畫面在情報頁；鍵列上有它。
- I2（修前紅）：打聽得知 Team6 在 (4,7) ⇒ 情報頁隊伍類有「Team6 (4,7)，聽說，來自 TeamN，位置是 N 分鐘前的」（N 在 UI 層驗；查詢 payload 只有絕對 tick）。
- I2b：只有實力估、沒有位置的對象 ⇒「位置不明」。
- I2c：關係未知 ⇒「不明」（不是中立）。
- I3：親見的隊 ⇒ 標「親見」。
- I4：真值移動後（目標隊走了、附身隊沒看到）⇒ 情報頁仍印舊位置（證零真值）；負對照：改讀真值 ⇒ I4 紅。
- I5：據點類有已知據點；沒有時「尚無」。
- I6：糧源「尚無（還沒有這種情報）」。
- I7：與游標處明細一致——游標移到情報頁列出的某隊（未過期）位置，游標處明細列出同一隊；過期的不在母體內，面板標「（太久，視同不知）」。
- I8：同一 tick 兩次呼叫 `query_memory_panel` ⇒ JSON 相同；隔 tick 且 belief 不變 ⇒ JSON 仍相同（純函數）。
- 既有讀 `query_memory_panel` 的 4 支床照綠（改名的話同步）；terminal E2E 照綠。world-fp 不變。

## 範圍外
- 糧源情報這種 belief（深層批）。
- 游標即選中（回饋 #4，下一張）。
