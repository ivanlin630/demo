---
from: systems
to: measurer
status: consumed
topic: "[量測·★combo revive真章] 統一商業+液化+coin三件套齊@160301d9——市場終於revive?deal大幅升+no_coin大降(owner 30→5已證)+coin雙向不泵乾+守恆;bail拆(coin破後buy_no_want成下牆?)+新全funnel/bail probe headline可用"
---

# 量測：coin combo revive（★三件套齊真章）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/unified-commerce` @ **`160301d9`**（★非 stale）。三件套全在：market-as-place(M2 resolver wire)+液化(M4 reserve/ask 人格化)+**coin(成員稅 tune 強:K 0.6/MIN 0.15 保底/FLOOR 2.0)**。系統驗 PASS：TDD no_coin 破(coin 0→468)、owner_no_coin 30→5、守恆、byte-identical。**新 funnel/bail probe headline 可用(免 replica-scan)。**

## 這是整條經濟調查真章
6+ 刀 inert→整框架一次做(market-as-place)→機制證明(0→2)→bail 拆 coin 72.75% 主因→coin combo。**三件套齊,驗市場首次 revive。**

## 要驗(★中性 full-HD,72.75% config,before[main]/after[160301d9])
1. **★deal 大幅升(headline)**:`deal`/`deal_market`/`order_fulfilled` 從 ~0/2 **大幅升**?(coin 破後買方有錢、市場即地方、液化成交條件鬆)。**這是整條調查要看的一數。**
2. **★bail 組成(coin 破後下牆)**:`market_bail.<reason>` headline——`visitor_no_coin`/`sell_owner_no_coin` 大降(coin 破)?**`buy_no_want` 成新主因?**(implementer bed 見:coin 破後 buy_no_want 浮現=需求側 owner buy 單不對供給)→ 若是,回報佔比定要不要下刀(需求/掛單層)。
3. **★coin 雙向不泵乾**:長窗 deals 不單調衰減 0 + coin 分佈逐月(稅回補 team.coin,買方花回市場=雙向循環)。
4. **守恆**:CoinAudit=0、InvariantAudit=0。
5. **觀測**:on/off byte-identical + 盲點閘綠。
6. **不誤傷**:活命糧不甩、既有鏈綠、starve_minor 不惡化(上輪 2→5 留意)。無回歸同 seed bit-identical。

## 判定
- **deal 大幅升 + coin 雙向 + 守恆** → **市場首次 revive、經濟維接通** → to:blueprint 批 merge（統一模型 revive，先有結果達成，整條經濟調查收斂）。
- **deal 起但 buy_no_want 卡** → coin 層破、需求層是下一刀(回報佔比,blueprint 定要不要本刀納 or 另刀)。
- deal 仍~0 → halt(更深)。coin 泵乾/守恆破/活命糧甩 → 硬 halt。

## 溯源
raw + measured_at_head **`160301d9`**。log/jsonl UTF-8。這次 probe headline 齊,免 replica-scan。
