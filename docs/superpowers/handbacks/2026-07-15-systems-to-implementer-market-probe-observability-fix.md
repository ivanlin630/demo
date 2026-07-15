---
from: systems
to: implementer
status: open
topic: "[FIX·前置·觀測] 新_resolve_market_at_outpost路徑probe不全(deal_merchant有但order_fulfilled等舊funnel probe沒bump)=shifted probe判不了revive;修=新路bump全funnel probe(order_id履約=order_fulfilled/deal等)鏡射舊路;續feat/unified-commerce"
---

# Fix：新 market resolver 路徑可觀測（全量暫態不變量前置）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

blueprint 裁 B（branch 建到 revive 才 merge）+ **probe 前置**：`_resolve_market_at_outpost`（新 market-as-place 路）**probe 不全**——measurer 見 `deal_merchant 0→2`（有）但 `order_fulfilled`/`deal`/`deal_resident`/`meet` 仍 0（新路 order_id 直沖履約沒 bump 舊 funnel probe）→ **shifted probe 下判不了 revive/regression**（全量暫態可觀測性不變量：新路徑必可觀測）。

## 根（觀測 gap，非行為 bug）
新路 `_resolve_market_at_outpost` 按 order_id 直沖 active_orders/board（非 settle_orders delta）→ **舊 funnel probe（`g1.order_fulfilled` 在 settle_orders 內 bump / `trade.deal` 在 `_resolve_market` 巧遇路 bump）新路沒經過 → 不計新路成交** → funnel 對照失真（order_fulfilled 7→0 疑遷移非 regression，但 shifted 判不清）。

## 修（新路 bump 全 funnel probe，鏡射舊路語意）
`_resolve_market_at_outpost` 成交/履約當下補 bump（純觀測，零行為/RNG，過 Probe.enabled gate）：
- **order_id 履約沖成**：bump `g1.order_fulfilled`（鏡射 settle_orders:282 語意——單被填）。
- **成交**：bump `trade.deal` + **`trade.deal_market`**（新路專屬，區分 market-as-place vs 巧遇 deal_resident；deal_merchant 已有保留）。
- **到場 bail**（無單/no_coin/ask>=bid/no_stock/carry）：bump 分因 probe（`trade.market_bail.<reason>`）——**讓 29 bail 因可觀測**（measurer 拆 bail 才有 headline probe，非複刻）。
- **coin/goods 搬**：既有 CoinAudit 池不變（守恆已驗）。

## 守則
- **純觀測**：只加 Probe.bump（zero state/RNG/behavior）→ on/off byte-identical 不破、同 seed 兩跑 bit-identical。
- **鏡射舊語意**：order_fulfilled/deal 計數口徑與舊路一致（新舊可比對，判 revive/regression）。
- **盲點閘**：新事件路徑接 probe（全量暫態可觀測性）——順手驗盲點閘綠。

## TDD
- 新路成交 → `g1.order_fulfilled`+`trade.deal`+`trade.deal_market` bump（單測斷言）。
- 各 bail 因 → 對應 `trade.market_bail.<reason>` bump。
- CoinAudit=0 不變；on/off byte-identical；憲法 sites 稽核。

## 完成後
→ handback `to:systems` → measurer 重測（★這次 funnel probe 齊：order_fulfilled/deal 真數 + 29 bail 因 headline）→ 判 revive 進度 + 定下層（no_coin→fold coin combo / 條件→tune liquidize）。
scope 疑義走 `to:systems`。**這是觀測前置修，非 revive 本身**（revive 靠後續 coin/tune）。
