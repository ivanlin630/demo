# 情報面板：玩家查得到「我知道什麼」——HOW

狀態：草稿，待 R²
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-intel-panel-and-intel-event-folding ③（第五輪用戶回饋 #6：「也沒記憶與情報欄位可以查看？」）
順位：本批（Q 鍵／子隊輸入／地圖整寬／勒索 0／附身隊三件）之後、游標即選中之前。

## 事實（main 3802f3db6）
- **已有一頁「記憶」**：分頁第 5 頁（`ui_pages.gd:14` PAGE_ORDER），`text_ui_main.gd:1794-1808 _build_memory_lines` 讀 `PlayerQueryApi.query_memory_panel`（player_query_api.gd:53-87）。它只列「Team N：幾筆｜最新 T｜傳聞來源｜有疑點」——**沒有位置、親見／聽說、關係、實力**，也沒有據點／市集／勢力。用戶沒找到它（分頁要用 , . 切到第 5 頁，鍵列沒有直達鍵）。
- 資料來源都已存在：`BeliefSystem.known_targets`／`claims`／`best_estimate`（位置、last_tick、source）；`PlayerQueryApi.tile_knowledge`（:412，游標處同一份）；已知據點關係 `FactionAISystem._known_outpost_relations`（faction_ai_system.gd:6069，F9′）。
- 糧源情報：belief 沒有這一種（深層批「糧源情報 kind」）。

## 決定
**不另開第二個面板，把既有「記憶」頁擴成情報頁，並給它直達鍵**（藍圖要的「新鍵、鍵列全列」由直達鍵滿足；同一份資料不開第二個出口）。
- 頁名「記憶」改「情報」（PAGE_ORDER 第 5 項）；鍵列加直達鍵（實作端挑一個主畫面未綁的鍵，登進 MODE_KEYMAP 與 unbound_key_bed）。
- 查詢面 `query_memory_panel` 擴欄（改名 `query_intel_panel`，舊名留轉呼叫一版或一次改完所有呼叫端——床有 4 處讀它）：
  - **隊伍**：對象、最後所知位置（best_estimate 的 tile_pos）、距今多久、親見／聽說（source 是自己＝親見）、來源、有疑點、關係（附身隊 belief 的 `known_reputations` 或既有關係帳，**只讀附身隊自己的**）、實力估（best_estimate 若有）。
  - **據點與市集**：讀 `_known_outpost_relations` 同一支（位置、主人、關係值）；市集＝其中有市集的。若那支函式的輸入是領袖隊、而附身隊不是領袖 ⇒ 交件信說明怎麼取附身隊自己的那份，不讀勢力的。
  - **勢力關係**：只列附身隊 belief 裡有的；沒有 ⇒「尚無」。
  - **糧源**：印「尚無（還沒有這種情報）」，不偽造。
- 每類 0 筆也印一行「尚無」（沿用現行「0 筆也印」的原則）。
- 長清單：每類最多 N 列＋「另有 M 筆」（N 由分頁可用列數推，不新增絕對常數）；排序：最近更新在前。
- **零真值**：面板任何欄都不得讀 `state.teams[x].tile_pos` 等真值；親見的位置也是 belief 裡那一筆。

## 驗收
- I1（修前紅）：直達鍵一按 ⇒ 畫面在情報頁；鍵列上有它。
- I2（修前紅）：打聽得知 Team6 在 (4,7) ⇒ 情報頁隊伍類有「Team6 (4,7)，聽說，來自 TeamN，N 分鐘前」。
- I3：親見的隊 ⇒ 標「親見」。
- I4：真值移動後（目標隊走了、附身隊沒看到）⇒ 情報頁仍印舊位置（證零真值）；負對照：改讀真值 ⇒ I4 紅。
- I5：據點類有已知據點；沒有時「尚無」。
- I6：糧源「尚無（還沒有這種情報）」。
- I7：與游標處明細一致——游標移到情報頁列出的某隊位置，游標處明細列出同一隊（同一份 belief）。
- 既有讀 `query_memory_panel` 的 4 支床照綠（改名的話同步）；terminal E2E 照綠。world-fp 不變。

## 範圍外
- 糧源情報這種 belief（深層批）。
- 游標即選中（回饋 #4，下一張）。
