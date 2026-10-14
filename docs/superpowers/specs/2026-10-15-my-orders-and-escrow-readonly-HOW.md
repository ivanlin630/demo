# 我的掛單與押貨（只讀）— HOW

> systems 2026-10-15。
> WHAT：藍圖裁定信 2026-10-15-blueprint-to-systems-RULING-my-orders-and-escrow-readonly-tail-ticket-and-advisor-pilot-status §一。
> - 只讀小票，不改商業規則。
> - 兩個邊界：①每筆有「在哪」與「何時到期／退回」；②撤單、退貨落格各走玩家事件一則（來源＝親見）。
>
> 位置：玩家可見批尾，真玩小修之後（板第 8 行）。
> 關 known_issues「掛單與押貨（escrow）對玩家不可見」。

## 現況（file:line，本輪已讀）
- 終端畫面**沒有任何掛單／撤單的鍵**：
  - `scripts/ui` 對 `post_*_order`／`cancel_order` 零命中。
  - 只有 `player_command_api.gd:153-180` 的 API。
  ⇒ 今天玩家真會遇到的不是「自己掛的單看不到」，而是下面這件。
- **附身那一刻**，`world_state.gd:1119 → OrderSystem.withdraw_on_possession`（order_system.gd:225-237）撤掉 AI 殘單：
  - 押貨經 `release_order_escrow`（:205-222）落到押貨那格的 `pending_claims`，屬主＝這隊。
  - 只印 `print`，玩家什麼都不知道。
  - 貨要**到場才領得到**（`InteractionSystem.claim_on_arrival` interaction_system.gd:1128）。
  ⇒ 玩家的貨躺在某一格，他不知道在哪、甚至不知道有。
- 其餘會產生待領的路：玩家單到期（`tick_team_orders` :262-290）、玩家撤單（:242-256）、賣單成交的貨款（待領款，`kind:"coin"`）。三條都經 `release_order_escrow` 或 `add_pending_claim`（:1098）。
- 帳的結構：
  - `team.active_orders[]`：{order_id, kind, res, qty_remaining, expire_tick, escrowed, escrow_tile}。
  - `tile.market_escrow{oid: {res, qty, owner_team, since_tick}}`。
  - `tile.pending_claims[]`：{kind, res, amt, owner_team, since_tick}。

## 一、面板：情報頁加一類「我的掛單與待領」
- 位置：情報頁（7eeb5cb5c）第五類，標題「我的掛單與待領」。
  - 理由：同一頁已是「你知道的東西在哪」。團頁是人與物資，放這裡會把「在別格的東西」跟「身上的東西」混在一起。
  - 每類列數沿用 `UiPages.INTEL_ROWS_PER_KIND`，超出印「另有 M 筆」（同常數、同字）。
- 資料：`PlayerQueryApi.query_memory_panel` 擴一欄 `my_orders`（不另開查詢）。只讀附身隊自己的帳。
  - ★payload **只放絕對 tick**（expire_tick、since_tick）；「還有 3 天 4 小時」由 UI 用 now 組句（R²：player_query_api.gd:53 的 I8 要求 payload 是帳的純函數，intel_panel_bed:274-277 與 terminal_e2e_bed:462 比兩次相等）。
  - 檔頭 :55「零真值：每一欄都來自 belief／附身隊自己的帳」同步改：註明這一欄是自知帳、讀法是全圖掃描，標 gate-ok。
  - **掛單**：每張 `active_orders` 一列。
    - 「賣 糧食 ×12｜押在 (14,2)｜還有 3 天 4 小時到期」。
    - 有押貨（escrowed）⇒「押在 (q,r)」＝`escrow_tile` 的座標。
    - 沒押、但登上自家板 ⇒「掛在 (q,r) 自家市集」＝`OrderSystem._market_pos`，改公開為 `market_pos`。
    - 都沒有 ⇒「沒上板（只靠碰面傳出去）」。
  - **待領**：掃 `pending_claims` 中 `owner_team == 附身隊` 的條目，每筆一列。
    - 「待領 糧食 ×12｜在 (14,2)｜第 3 天 08:00 起」。「起」＝該列最早一筆的時間（`add_pending_claim` 同 owner＋kind＋res 會合併、保留最早 since_tick，interaction_system.gd:1102-1104），不是最近一次退貨。
    - 款項印「待領 錢 ×N」。
- ★感知：這兩份是附身隊**自己的帳**（自己掛的單、自己的貨落在哪裡是規則決定的）。自知合法，不是 god-view。
- ★成本：掃待領要走全圖 tile，只在情報頁 render 時算（不是每 tick）。實作端量一次時間列在交件信，只記錄。
  - **不建索引**（R²：`add_pending_claim` 是 static、拿不到 state；床直接 append 會繞過索引；NPC 每次 gather 本來就在掃）。
- 資源名讀 `TextBank.res_name`（顧問票 names.tsv；顧問票排在本票之前，合併序保證它已在）。

## 二、事件：撤單、退貨落格、到場領回各一則
- 新 kind `goods_returned`，在 `release_order_escrow` 真的落了一筆待領時發。
  - info={res, qty, pos, why}，why ∈ {expire, cancel, possession}。
  - 句：「你的 {res} ×{qty} 退回 ({q},{r}) 待領（{原因}）」。
  - 原因字：到期／你撤了單／附身時撤下隊上的單（R²：解除附身再附身同一隊時，撤的可能包括玩家先前自己掛的單 ⇒ 原因字用中性，不說「AI 的」）。
- 新 kind `goods_claimed`，在 `_claim_pending_here` 真的交還東西時發：「在 ({q},{r}) 領回 糧食 ×12、錢 ×3」。
  - **逐資源**（R² M3）：今天迴圈只累兩個純量 got_goods／got_coin（interaction_system.gd:1139-1155）。改成在同一迴圈內累 `{res: amt}`（款以 `coin` 為鍵），函式尾一則；沒領到不發。
  - 同一 tick 在兩格都領 ⇒ 兩則，不折疊。
- ★只對玩家隊發（R² M1）：判斷式＝**`owner_team == state.get_player_team_id()`**。owner 取 escrow／claim 條目的 owner_team。
  - **不用 `.possessed`**：world_state.gd:1118-1120 先在 :1119 撤單、:1120 才設 possessed ⇒ 附身那一刻判 possessed 必為假，主格 P1 一則都不發。`get_player_team_id()`（:1175-1185）在同一時刻是對的，也是 `_player_perceives` ① 用的判準。
  - 理由：emit 無條件寫 `pending_rethink`（world_events.gd:185）⇒ 對 NPC 發會讓它多想一輪。NPC 的事件本來就被 `_player_perceives` 擋在匯流排外，這個判斷真正擋的是喚醒。
  - 不算給玩家特別規則（R² 判同；先例 outpost_owner_bank、emit_player_subteam）。
  - goods_claimed 同一式，且判斷放在**建 per-res dict 之前**：`_claim_pending_here` 每次 NPC 到場都走，別讓 NPC 白建 dict。
- 兩個新 kind 進 `FUNC_KINDS`（world_events.gd:34-82）＋`KIND_LABEL`（:97-111）＋`describe` 分支；E2E 格 a 會逐一驗每個 kind 有短名。
- 來源欄：親見（自己的隊）。若結構輪③（「怎麼知道的」必填）先落地，照它的欄位填；沒落地就照現行 emit。
- 不進 ADVANCE_STOP_KINDS（不是威脅；附身那刻可能一次發好幾則，進停點會連停）。
- `release_order_escrow` 要知道 why：加**必填**參數 `why: String`，不給預設值（R²：漏改的呼叫點直接 parse 錯，比床斷言可靠）。三個呼叫點各傳自己的（:234 possession、:251 cancel、:276 expire）。

## 驗收（床 `my_orders_panel_bed.gd`；修前跑：P1／E1／E2 修前紅）
- P1 附身撤單：佈置 NPC 隊在別人市集寄賣糧 12（真押貨），**走真實的 `sync_possession` 邊附身**（不是手動先設 possessed 再呼 withdraw；那樣測不到 M1 的時序洞）⇒
  - 情報頁「我的掛單與待領」有一列「待領 糧食 ×12｜在 (q,r)」，座標＝押貨那格。
  - 事件流一則 goods_returned（why=possession）。
- P2 掛單列：API 掛一張寄賣單 ⇒ 一列「押在 (q,r)｜還有 N 天…到期」，N＝(expire−now) 換算；撥鐘一天 ⇒ N 少一天。
- P3 三種位置字：押貨、自家板、沒上板，各一列字樣正確。
- E1 到期：撥到 expire ⇒ goods_returned(why=expire)，待領列出現、掛單列消失。（佈置在沒有同資源待領的格；同格同資源再退貨是原列加量，不是新列。）
- E2 撤單：API 撤 ⇒ goods_returned(why=cancel)。
- E3 領回：單格佈置糧 12＋錢 3，走到那格 ⇒ goods_claimed 恰一則、句子含兩種資源各自的量；待領列消失，存量＋12、錢＋3。
- E4 NPC 不喚醒（R² M2）：同佈置但不附身、讓單到期 ⇒ 同 tick 內 `state.pending_rethink` 不含該 NPC 隊。（只看匯流排是恆綠：`_player_perceives` 本來就擋。）
- E5 同勢力 NPC：NPC 隊與玩家同勢力（`_player_perceives` ② 會放行）、單到期 ⇒ 匯流排仍零則 goods_returned。
- CAP：8 個不同 (格, 種類, 資源) 的待領 ⇒ 5 列＋「另有 3 筆」。
- W：無玩家世界 world-fp 不變。

### 負對照
| 對照 | 該紅 |
|---|---|
| n1 拿掉玩家隊判斷 | E4（pending_rethink 格）＋E5 |
| n4 判斷式改回 `.possessed` | P1 事件格 |
| n2 release_order_escrow 不發事件 | P1 事件格、E1、E2 |
| n3 待領列改讀全部 owner | P1 的只列自己的格（佈置一筆別隊的待領在同格） |

## 範圍外
- 終端加掛單／撤單的鍵：本票只讀（藍圖裁）。要加鍵另開票。
- 買單押錢（order_system 註解「後補」）：不在本票。
- 賣單成交的貨款落格（interaction_system.gd:1241 `add_pending_claim "coin"`）：面板有列、**不發事件**。這跟藍圖的 WHAT（撤單、退貨落格各一則）一致，不是漏掉；要通知「錢躺在市集」另提。
- 附身時連玩家自己先前的單一起撤（withdraw_on_possession 註解 :226 的假設外溢）：不在本票，原因字已改中性。
