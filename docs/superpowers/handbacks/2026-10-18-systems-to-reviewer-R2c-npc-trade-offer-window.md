---
from: systems
to: reviewer
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價
topic: R²c 只審 N1、N2＋T1–T3（spec 第三版）
---

# 改了哪裡（spec `docs/superpowers/specs/2026-10-18-npc-trade-offer-window-HOW.md`，同 commit）
- **N1** §二：依據改成對方自己最舊的那張 `active_orders`（賣單 ⇒ 賣；買單 ⇒ 買，錢不夠 ⇒ 換）；沒有單 ⇒ 後備只賣餘裕最大的；不再用「缺口價值最大」。驗收 O4a–c 改自然構造（讓引擎掛單）＋「沒有單」一格；O4e 無玩家普查 ≥200 對、賣與買各 ≥10%（具名常數）；n8。
- **N2** 選 (a)：`bid = local_value × (1 − disc_buy)`，不帶恩怨；`_settle_goods_sale` 報恩只在賣方是電腦時呼叫（寫成字面）。O4d 加恩情邊不動那格；n9。
- **T1** 以物易物式子寫死（`k = 1 − disc_buy`，want／give 兩式、取整向下、對方不虧才報）。
- **T2** O4e 床內印「報價的 res 在玩家方身上有沒有」比例（只量不進決策）。
- **T3** §五寫明板上單成交（`_market_visitor_buy／_sell`）不共用。

# 交回
VERDICT to:systems，commit，敲 demo-32。
