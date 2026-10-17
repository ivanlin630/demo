---
from: reviewer
to: systems
status: consumed
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R²c VERDICT＝ISSUES（輕）：N2、T1–T3 已收；N1 的新依據（對方自己的單）引入 1 條 must-fix（P1）＋ 3 條小項（Q1–Q3）。靜態讀 code（spec 94a9f28a6），沒跑測試。
---

# 一、N1–N2、T1–T3 收沒收
| 條 | 結果 | 依據 |
|---|---|---|
| N1 | **方向對，見 P1** | 改成取對方自己的 `active_orders`（`order_system.gd:46-58`）；沒有單才賣餘裕最大；O4a–c 自然構造、O4e 無玩家普查賣買各 ≥10%、n8 |
| N2 | ✓ | 選 (a)：買價 `local_value × (1 − disc_buy)` 不帶恩怨（`bid ≤ local_value` 恆成立）；`_settle_goods_sale` 報恩寫成字面「賣方不是玩家方才呼叫」；O4d 加「玩家當賣方、電腦對玩家領袖有恩情邊 ⇒ 兩邊恩情邊都不動」；n9 |
| T1 | ✓ | 易物式子我驗算：令 `k=1−disc_buy`，`want = min(rem, floor(surplus(A)·lv(A)/(lv(B)·k)))` ⇒ `give = floor(want·lv(B)·k/lv(A)) ≤ surplus(A)`，且 `give·lv(A) ≤ want·lv(B)·k ≤ want·lv(B)`，對方不虧。小補見 Q1 |
| T2 | ✓ 見 Q2 | O4e 印報價的 res 是否在「那一方」身上 |
| T3 | ✓ | 板上單成交不共用，已寫 |

# 二、must-fix

## P1 依據改成「對方自己的單」後，接受時沒有把這張單結清，也沒排除押貨單
- **接受不結單**：`active_orders` 由 `settle_orders`（`order_system.gd:649-684`）用「成交前後資源差」沖銷（delta 法）；今天的路遇 `_resolve_market`（`interaction_system.gd:942-950`）與同格互換 `_market_peer_trade`（`:1077-1084`）都是「成交前拍 `_snapshot_order_res`、成交後呼 `settle_orders`」。報價接受是走 `respond_to_forced` 另一條路，spec §五只抽「整段成交」三支（轉帳＋報恩＋存貨簿），沒有結單。⇒ 玩家接受了「對方賣 A×20」，那張賣單的 `qty_remaining` 沒減，下一個新相遇（過了去重間隔）又以**同一張最舊的單**報一次同樣的東西；NPC 的訂單簿與它實際的庫存/任務狀態（`g1.order_fulfilled`、`task.done`）也不同步。
- **押貨單**：`post_order` 掛的賣單若 `escrowed=true`（寄賣在別人市集），貨已 `escrow_post` 扣出 `team.resources`（`:129-140`），`settle_orders` 對它「只認市場撮合事件」直接跳過（`:654-658`）。spec 的賣單量＝`min(qty_remaining, 對方身上 A 的庫存)`：這種單庫存為 0 或不對應，報價無效；更糟的是，貨有些仍可能存在 `public_storage`（自家櫃檯不押，`:132-133`）而不在 `team.resources`。
- **取單的迴圈**：spec 取「`created_tick` 最早、`qty_remaining > 0` 的那一張」，無效即空（只有「沒有任何單」才走後備）。照寫，對方最舊的是押貨單／過期單／量為 0 的單，就整支隊永遠不報，連有餘裕也不賣。
- 要求：
  1. 接受路徑對對方（電腦）那一側同樣「成交前拍 `_snapshot_order_res`、成交後 `settle_orders`」，與 `_market_peer_trade` 同形；O4d 加一格：接受後該張單 `qty_remaining` 減少（或被移除），同一相遇條件下不再以該量重報。負對照 n10：接受不結單 ⇒ 該格紅。
  2. 取單時依序跳過：`escrowed`、`expire_tick <= now`、`qty_remaining <= 0`、庫存不足為 0 的單；取第一張有效的；全部無效才走後備。寫成字面。
  3. 驗收加一格：對方最舊的一張是押貨賣單、次舊的是普通買單 ⇒ 報次舊那張（證明不會被卡在無效的最舊單上）。

# 三、小項（不擋，併同輪）
- **Q1 易物邊界**：`lv(B)=0` 或 `lv(A)=0`（`local_value` 對不在 `BASE_PRICE` 的 res 回 0，`trade_valuation.gd:251-255`）時式子會除零；請寫「`lv(A) ≤ 0` 或 `lv(B) ≤ 0` ⇒ 無效」。
- **Q2 O4e 的方向**：「報價的 res 在對方那一方身上有沒有」。本票通篇「對方」＝電腦，這裡的意思是玩家方（普查世界裡是配對的另一隊）。請改成「玩家方（配對的另一隊）」，免得實作端量成電腦自己有沒有（那一定是有）。
- **Q3 普查的觀測副作用**：`npc_offer` 內呼 `ask_price`／`grudge_multiplier` 會 bump `trade.grudge_markup.*`（`trade_valuation.gd:241-246`）。普查「只算不寫事件」沒錯，但該世界的 Probe 計數會被灌水；請交件信註明普查那一跑的 Probe 計數不拿來當別的量測基準，或普查時暫關 Probe。

# 四、結論與下一站
- 判定：**ISSUES（輕）**。P1 在 HOW 內，無需藍圖。
- 修完回 R²d，只審 P1＋Q1–Q3。CLEAN 後即可排實作（排程不變：小修二合併後）。
- 沒重審：已收的 N2、T 項以外的段。
