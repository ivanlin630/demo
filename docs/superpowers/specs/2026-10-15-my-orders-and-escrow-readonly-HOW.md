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
- 資料：`PlayerQueryApi.query_memory_panel` 擴一欄 `my_orders`（不另開查詢）。只讀附身隊自己的帳：
  - **掛單**：每張 `active_orders` 一列。
    - 「賣 糧食 ×12｜押在 (14,2)｜還有 3 天 4 小時到期」。
    - 有押貨（escrowed）⇒「押在 (q,r)」＝`escrow_tile` 的座標。
    - 沒押、但登上自家板 ⇒「掛在 (q,r) 自家市集」＝`OrderSystem._market_pos`，改公開為 `market_pos`。
    - 都沒有 ⇒「沒上板（只靠碰面傳出去）」。
  - **待領**：掃 `pending_claims` 中 `owner_team == 附身隊` 的條目，每筆一列。
    - 「待領 糧食 ×12｜在 (14,2)｜第 3 天 08:00 起」。
    - 款項印「待領 錢 ×N」。
- ★感知：這兩份是附身隊**自己的帳**（自己掛的單、自己的貨落在哪裡是規則決定的）。自知合法，不是 god-view。
- ★成本：掃待領要走全圖 tile。
  - 只在情報頁 render 時算（不是每 tick）。
  - 實作端量一次全圖掃描時間並列在交件信。
  - 超過 1ms ⇒ 改成由寫入點（`add_pending_claim`／`_claim_pending_here`）維護一份 `team_id → [tile_id]` 索引。索引是派生，不進 fp。
- 資源名讀 `TextBank.res_name`（顧問票 names.tsv）。顧問票若晚於本票，就用 `ObserverEventText.RES_NAMES`，交件信寫明。

## 二、事件：撤單、退貨落格、到場領回各一則
- 新 kind `goods_returned`，在 `release_order_escrow` 真的落了一筆待領時發。
  - info={res, qty, pos, why}，why ∈ {expire, cancel, possession}。
  - 句：「你的 {res} ×{qty} 退回 ({q},{r}) 待領（{原因}）」。
  - 原因字：到期／你撤了單／附身時撤下 AI 的單。
- 新 kind `goods_claimed`，在 `_claim_pending_here` 真的交還東西時發：「在 ({q},{r}) 領回 糧食 ×12、錢 ×3」。
- ★只對附身隊發：發之前判 `state.teams[owner].possessed`。
  - 理由：emit 會寫 `pending_rethink` ⇒ 對 NPC 發會改世界。
  - 這是「把匯流排告知限在玩家」，不是給玩家特別規則。#12 精神：不替玩家決定，只告知。
- 來源欄：親見（自己的隊）。若結構輪③（「怎麼知道的」必填）先落地，照它的欄位填；沒落地就照現行 emit。
- 不進 ADVANCE_STOP_KINDS（不是威脅；附身那刻可能一次發好幾則，進停點會連停）。
- `release_order_escrow` 要知道 why：加參數 `why: String = "expire"`。三個呼叫點各傳自己的（:234 possession、:251 cancel、:276 expire）。預設值只為了不漏改；床斷言三處都明傳。

## 驗收（床 `my_orders_panel_bed.gd`；修前跑：P1／E1／E2 修前紅）
- P1 附身撤單：佈置 NPC 隊在別人市集寄賣糧 12（真押貨），附身 ⇒
  - 情報頁「我的掛單與待領」有一列「待領 糧食 ×12｜在 (q,r)」，座標＝押貨那格。
  - 事件流一則 goods_returned（why=possession）。
- P2 掛單列：API 掛一張寄賣單 ⇒ 一列「押在 (q,r)｜還有 N 天…到期」，N＝(expire−now) 換算；撥鐘一天 ⇒ N 少一天。
- P3 三種位置字：押貨、自家板、沒上板，各一列字樣正確。
- E1 到期：撥到 expire ⇒ goods_returned(why=expire)，待領列出現、掛單列消失。
- E2 撤單：API 撤 ⇒ goods_returned(why=cancel)。
- E3 領回：走到那格 ⇒ goods_claimed 一則，待領列消失，存量＋12。
- E4 NPC 不發：同佈置但不附身、讓單到期 ⇒ 匯流排零則 goods_returned。
- CAP：8 筆 ⇒ 5 列＋「另有 3 筆」。
- W：無玩家世界 world-fp 不變。

### 負對照
| 對照 | 該紅 |
|---|---|
| n1 拿掉 possessed 判斷 | E4（以及電池 world-fp） |
| n2 release_order_escrow 不發事件 | P1 事件格、E1、E2 |
| n3 待領列改讀全部 owner | P1 的只列自己的格（佈置一筆別隊的待領在同格） |

## 範圍外
- 終端加掛單／撤單的鍵：本票只讀（藍圖裁）。要加鍵另開票。
- 買單押錢（order_system 註解「後補」）：不在本票。
