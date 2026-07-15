---
from: implementer
to: systems
status: consumed
topic: "[完·觀測] 新 market resolver 全 funnel probe 可觀測 — HEAD b2c850ce;成交口徑 deal/order_fulfilled/meet + 29 bail 分因;TDD 19綠+determinism byte-identical+盲點閘;live bail 拆出 sell_owner_no_coin=30(coin泵)/buy_no_want=11(商隊②)"
---
# Hand Back：新 market resolver 全 funnel probe 可觀測（全量暫態不變量前置）

branch `feat/unified-commerce` @ `b2c850ce`（已 push）。

## 修（純觀測，零行為/RNG）
`_resolve_market_at_outpost` order_id 直沖履約補 bump 舊 funnel probe（鏡射舊路口徑，新舊可比對判 revive/regression）：
- **成交口徑**：`trade.deal` + `trade.deal_market` + `deal_merchant/deal_resident`（既有）+ **`g1.order_fulfilled`**（`_settle_owner_order` 既有，單填滿）+ **`trade.meet`（新增，到市場會合＝鏡射舊 pairwise）**。
- **★bail 分因（29 bail 因 headline，measurer 拆得出）**：`trade.market_bail.<reason>`——`no_board_order` / buy: `no_coin/no_price/no_stock/no_want/cant_afford/carry_full/withdraw_empty` / sell: `ownerless/owner_no_coin/no_surplus/no_price/owner_cant_afford/zero_qty/storage_full`。
- 只 `Probe.bump`（Probe.enabled gate，zero state/RNG/behavior）。

## 驗（log `docs/measurements/2026-07-15-unified-commerce-observability-fix-b2c850ce.log`）
- **TDD unified_commerce_test 19/19 PASS**：成交 `trade.deal`+`deal_market`+`★order_fulfilled`+`trade.meet` bump；★bail 分因 `buy_no_coin` bump（可觀測）。
- **★live 自驗（trade_funnel_bed seed=1337 3mo）——funnel probe 現齊、bail 拆出**：
  - 成交口徑：deal=2 / deal_market=2 / order_settled_direct=2 / order_fulfilled=1 / **trade.meet=16（站6 會合 0→16）**。
  - **★bail 分因（revive sparsity 兩大根現可量）**：
    - **`sell_owner_no_coin=30`**（最大 bail）＝**owner 無 coin 收購訪客貨＝coin 單向泵風險**（spec R² 早警，coin combo backlog 下層）。
    - **`buy_no_want=11`**＝訪客(商隊)無個人 reserve 缺口不買＝**merchant 買低賣高 vs 補個人 reserve 語意差，下刀②（merchant 完成 trade）scope**。
    - no_board_order=6 / sell_no_surplus=6 / buy_no_stock=6。
- **determinism byte-identical MD5 C7862C80**（＝probe 前同 MD5 → 加 probe 零擾動世界，非侵入確認）+ 憲法 sites=29 + **盲點閘 PASS(cd10/cr1/ci2/co2/tryset6 不變)** + headless 3+3 baseline。
- CoinAudit：純 Probe.bump 不搬資源 → 前 commit 已驗 delta=0×4，本 commit 零資源改動。

## ★systems 定下層（觀測 gap 補齊，sparsity 兩大根現可量）
measurer 重測現可拆 bail headline 判 revive；兩大 sparsity 根已量：
1. **coin 單向泵**（`sell_owner_no_coin=30`）→ **no_coin→fold coin combo**（成員稅 coin-B 或 owner coin 補注）。
2. **商隊 buy-to-resell 未接**（`buy_no_want=11`）→ **merchant 完成 trade 下刀②**（co-locate，blueprint 預授）。
3. 域外 LOD arrive 4.4%（前 handback 已報）仍在。

## 待確認
- 完成判定 = systems + measurer 中性 full-HD 重測（funnel probe 齊、bail 拆）+ blueprint 批。**這是觀測前置修（非 revive 本身，revive 靠後續 coin combo / merchant ②）。** context hold warm 等裁決。
