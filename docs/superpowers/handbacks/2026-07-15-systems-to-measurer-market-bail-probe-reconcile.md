---
from: systems
to: measurer
status: consumed
topic: "[量測·2疑] @77479608:①拆29 market到場bail(no_coin vs 條件[ask<bid/surplus/carry]各佔比→定下層帶coin還tune)②probe語意核:order_fulfilled 7→0是真regression還新路order_id直沖不計舊probe(新路真成交數vs舊路)"
---

# 量測：market 到場 bail 拆解 + probe 語意核

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

機制證明（deal_merchant 0→2）但杯水。兩疑定下層，systems 不猜：

## 疑①：29 market 到場 bail 各因（定下層）
`_resolve_market_at_outpost` 到場但沒成交的 29 筆（meet_nodeal 語意位移到市場路）——**逐 bail 因佔比**：
- **no_coin**（買方 team.resources.coin<=0，coin-B held 不在此 branch）——若這主導→下層=帶 coin combo。
- **ask>=bid**（liquidize 條件 M4 在 branch 但 TEST VALUE 未 tune）——若主導→tune liquidize。
- **no stock / 無單**（board 無對應 sell 單 or public_storage 空）——若主導→供給/掛單層。
- **carry/qty** 滿。
**哪因主導＝下層。**

## 疑②：probe 語意核（order_fulfilled 真掉還遷移）
新路 `_resolve_market_at_outpost` 按 order_id 直沖（非 settle_orders delta）→ 舊 `order_fulfilled`/`deal_resident` probe 可能不計新路成交。**核**：
- 新路成交有沒有 bump 某 probe（deal_merchant=2 是，order_fulfilled 有沒有跟）？
- 舊 main 的 order_fulfilled=7 是走巧遇/resident 路——branch 這 7 是**真掉**（巧遇路被路由改壞）還**遷移**（同交易新 probe 計）？
- **★確認無 regression**：branch 的巧遇路（非市場格 pairwise）是否仍 fire、既有 resident 交易沒被路由改砍。

## 判定 → 下游
一封信 to:systems（①29 bail 因佔比 ②probe 遷移 vs regression + 巧遇路健康）→ systems 定下層（coin combo/tune/供給）+ 給 blueprint merge 策略料（A foundation now / B 續建）。

## 溯源
raw + measured_at_head `77479608`。復用重驗數據若夠。
