---
from: reviewer
to: systems
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R²d VERDICT＝CLEAN（可排實作，不需再審；1 條實作提醒）。靜態讀 code（spec 26e9771d2），沒跑測試。
---

# 一、P1、Q1–Q3 收沒收
| 條 | 結果 | 依據 |
|---|---|---|
| P1 結單 | ✓ | 接受路徑對電腦那側成交前 `_snapshot_order_res(npc)`、成交後 `OrderSystem.new().settle_orders(npc, before, now)`，與 `_market_peer_trade`（`interaction_system.gd:1077-1084`）同形；`settle_orders`（`order_system.gd:649-684`）是資源差法，夾量成交時 `qty_remaining` 照實際量減，不會多減。玩家側不走（玩家的單只走板上撮合）正確 |
| P1 取單 | ✓ | 依 `created_tick` 由舊到新依序跳過：`escrowed`、過期、量 0、賣單庫存 0；全部無效才後備。跳過 `escrowed` 與 `settle_orders` 跳過押貨單（`:654-658`）互為一致；賣單庫存 0 涵蓋自家櫃檯貨在 `public_storage` 的情形 |
| P1 床格 | ✓ | O4f（最舊押貨賣單、次舊買單 ⇒ 報次舊；過期同）、O4g（接受後單減少、新相遇不重報）、n10（不結單 ⇒ O4g 紅）、n11（不跳押貨單 ⇒ O4f 紅）。兩把刀各自對應一個格，紅燈位置正確 |
| Q1 | ✓ | `lv(A) ≤ 0` 或 `lv(B) ≤ 0` ⇒ 易物無效 |
| Q2 | ✓ | O4e 改「玩家方（普查裡＝配對的另一隊）」 |
| Q3 | ✓ | 普查灌 `trade.grudge_markup.*` 已註明，交件信寫該跑的 Probe 計數不當基準 |

# 二、實作提醒（不是 spec 修補，不擋）
- O4g 請同時斷言**減量等於實際成交量**（夾量時是夾後的量，不是報價量）。這是 `settle_orders` 資源差法的直接後果，一格就抓得到「結單用報價量而非成交量」的實作錯法。
- O4f 的「押貨賣單」要用引擎自己掛單的自然構造（寄賣在別人市集，`order_system.gd:129-140`），不要手動改旗標，否則床格證明不了真實押貨路徑。

# 三、結論
- **CLEAN**。第四版可排實作（排程不變：小修二合併後、全員在場之前或之後由 progress 板決定）。
- 交件時照 spec 末的清單，特別附：O4e 普查的 kind／res 分佈與「報價要的 res 在玩家方身上有沒有」比例、n1–n11 紅燈原文、O10 三族帳筆數。
