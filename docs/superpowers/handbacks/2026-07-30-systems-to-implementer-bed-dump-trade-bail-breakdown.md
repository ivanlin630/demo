---
from: systems
to: implementer
status: consumed
topic: "[bed dump 補·pin GATE-B co-location失敗sub-gap·peaceful_economy_bed.gd 4Q dump補印trade.market_bail.*(sell_no_surplus/buy_no_stock/buy_no_want/buy_cant_afford/buy_carry_full/buy_no_coin/buy_no_price/buy_withdraw_empty)+trade.arrive/meet/timeout+seek→arrive→fill funnel·目的:order_placed=1833但seek_market=5/arrive=40=市場互動極低撮合0,看bail breakdown定失敗在賣方(sell_no_surplus賣方不去賣surplus)vs買方(buy_no_stock granary空)vs config·純多print既有Probe.counts data零sim改·re-run落地docs/measurements標path] bed補print trade.market_bail breakdown+seek/arrive/fill funnel。純多print既有data。re-run落地→pin GATE-B co-location失敗sub-gap。"
branch: feat/peaceful-economy-bed
---

# bed dump 補：pin GATE-B co-location 失敗 sub-gap

**目的**：GATE-B 買撮合 0 成交（order_placed=1833 但 seek_market=5/market_arrive=40=市場互動極低）。**失敗在哪端未 pin**：賣方不去賣 surplus（`sell_no_surplus`）vs 買方抵達空 granary（`buy_no_stock`）vs config 市集缺。→ dump bail breakdown 定。

## 補（bed 4Q dump 段，純多 print 既有 Probe.counts data）
`peaceful_economy_bed.gd` 4 問 dump（Q3 trade 段）補印（`result["probe"]` or Probe.counts 已含這些 key，只是沒印）：
- **`trade.market_bail.*` 全分因**：`sell_no_surplus` / `buy_no_stock` / `buy_no_want` / `buy_cant_afford` / `buy_carry_full` / `buy_no_coin` / `buy_no_price` / `buy_withdraw_empty`（interaction_system.gd bail 點）。
- **`trade.arrive` / `trade.meet` / `trade.timeout`**（撮合 funnel）。
- **seek→arrive→fill funnel**：`g1.seek_market`(5) / `g1.market_arrive`(40) / 撮合成交（已有 order_fulfilled=0）——三段落差看卡哪層。
- ★純多 print `result`/`Probe.counts` 既有欄，**零 sim 改、零行為變、零數字變**（4 問數不變）。

## 驗 + 交付
1. bed exit0、observability_gate PASS（bed 無 marker）、constitution 74。
2. **re-run 落地 `docs/measurements/`（標 exact path 驗存在）**——含 trade.market_bail breakdown。
3. commit + handback `to:systems`（帶 bail breakdown 摘要：sell_no_surplus vs buy_no_stock 誰主導 + seek/arrive/fill 三段落差）。

→ 我讀 breakdown pin GATE-B 失敗 sub-gap（賣方 vs 買方 vs config）→ 待用戶 vision 定 slice scope。★這是 vision-independent（撮合 fix 兩案都要）。卡住報 `to:systems`。
