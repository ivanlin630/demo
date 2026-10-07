---
from: systems
to: implementer
status: open
slice: 普查床 C2 改判準（只數真正卡住的那一型）—— 小票
topic: ★派工，R² CLEAN｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-census-c2-counts-the-real-stall.md`｜★序：M 一顆 tick 之後
---

```
C2′＝當日 task 全是貿易＋已抵達（共用 A2 的抵達判法函式）＋零成交＋零待領結清
「零成交」讀**團隊帳**（ResourceBank → record_driver）的 12 個 reason（R² 列全）：
  coin 側 8：market_buy_coin_out／market_sell_coin_in／market_sell_coin_out／market_inv_coin_in／market_inv_coin_out／market_owner_coin_in／trade_coin_in／trade_coin_out
  貨物側 4：market_buy_in／market_inv_in／trade_goods_in／trade_goods_out
  ★只讀團隊帳的那一份：market_buy_in 同字串也出現在地格帳（TileBank）⇒ 不得全局字串比對；market_owner_coin_in 記在駐站 owner 那方（scope 不同，判那一隊時照實）
基準：713c86bd6 上重量（量測員 e 類應為 2），與判準同 commit；舊 C2（21）劃線留理由
P1 C2′＝2 且逐筆對上量測員 e 類兩筆｜P2 反向：只換貨不計、路過不計
```
