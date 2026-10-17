---
from: systems
to: reviewer
status: consumed
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R²b 請審 M1–M5 對應段（spec 第二版，全文重寫但段落結構不變）；S1–S6 已併
---

# 改了哪裡（spec `docs/superpowers/specs/2026-10-18-npc-trade-offer-window-HOW.md`，同 commit）
- **M1** §二：缺口改 `pop × TARGET_PER_POP − effective_holding`（同 local_value 一把尺）；順序改「有缺口 ⇒ 先買、錢不夠才換；沒缺口才賣」；賣取餘裕價值最大的 res；新 `bid_price`＝`local_value × (1 − disc_buy) ÷ 恩怨乘數`（disc_buy 只含商業與貪婪，不含急迫）。驗收 O4a／b／c＋`kind` tap＋n6。
- **M2** §五：抽「雙方同意之後整段」三支（`_settle_goods_sale` 含報恩與商隊存貨簿、`_settle_inventory_sale`、`_settle_barter`），撮合與接受共用；O4d 加恩情與存貨簿；n3 改成拿掉 `repay_gratitude`。
- **M3** §三：seen 鍵 `(npc, side)`、值＝最後一次同格試報價 tick，每次（含被擋）刷新，間隔 > T1 週期才算新相遇；接受也不清；busy 丟掉時留重試旗。T1 在市集格不報。O6 四段、O3b、n7。
- **M4** §四：`accept_consequence` 補、逾時專屬分支只 bump tap、describe 認 trade_offer；O1 斷言不含「未知」；檔頭寫與 `propose_trade` 的分工。
- **M5** O10：印三族帳筆數各 ≥1，否則單元床直呼抽出函式逐帳比對。
- S1 T3 只限 TRADE 隊（運糧子隊不報）；S2 T1 位置寫死；S3 到場簿記一句；S4 O8 加人口與商隊標籤；S5 O7 印 T1 呼叫數；S6 失敗句補「對方沒有錢了」、失敗時清事件。

# 交回
VERDICT to:systems，commit，敲 demo-32。
