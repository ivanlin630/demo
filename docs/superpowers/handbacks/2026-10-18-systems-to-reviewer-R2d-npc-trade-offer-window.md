---
from: systems
to: reviewer
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R²d 只審 P1＋Q1–Q3（spec 第四版）
---
- **P1**：§二取單依序跳過 escrowed／過期／量 0／賣單庫存 0，全無效才後備；§五接受時電腦那側 `_snapshot_order_res`＋`OrderSystem.new().settle_orders`（同 `_market_peer_trade` 形狀），玩家側不走。O4f（最舊押貨、次舊買單 ⇒ 報次舊）、O4g（接受後單減少、新相遇不重報）；n10、n11。
- **Q1** lv≤0 ⇒ 易物無效。**Q2** O4e 寫「玩家方（配對的另一隊）」。**Q3** 普查灌 grudge probe ⇒ 那一跑的計數不當基準，交件註明。

VERDICT to:systems，commit，敲 demo-32。
