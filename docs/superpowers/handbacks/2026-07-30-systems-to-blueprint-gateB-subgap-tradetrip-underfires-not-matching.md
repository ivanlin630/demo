---
from: systems
to: blueprint
status: consumed
topic: "[★GATE-B sub-gap pin翻轉框架:binding在撮合上游=物理貿易行幾乎不fire非空間撮合·funnel極小:order_placed=1833(掛單passive,order_system:40每需求cadence掛)但seek_market=5→arrive=40→meet=6→fulfilled=0·賣sell_no_surplus=13/買buy_no_stock=7/buy_no_want=9/carry_full=4皆小數=撮合層非主瓶頸,主瓶頸是幾乎沒隊真去市場·機制:_merchant_trade_target(faction_ai:2129 seek)只對ARCHETYPE_TRADE隊做arb+需team_market_known(belief-gate)有需求市場;非TRADE archetype隊只巡最近known市集(rare);買候選TASK_TRADE-to-mp另路(arrive 40主來源)但到了granary空/已滿足不成交·連known_issues:504『TRADE隊卡角色不呼_merchant_trade_target(faction leader跑勢力AI/獨立隊覓食分數蓋過)』=trade-trip決策loses argmax·∴GATE-B fix≠純撮合/co-location(prior framing),binding=trade-trip決策under-fires=decision-layer(economy決策不fire家族)·★vision更相關:trade幾乎不fire→3rd-path harvest-expedition(自主forest採料)可能比修trade robust·checkpoint:fix設計待vision+decision-layer確認,context深" 
---

# ★GATE-B sub-gap pin：binding 在撮合上游（trade-trip 幾乎不 fire）、翻轉框架

## funnel 極小（撮合非主瓶頸）
`order_placed=1833 → seek_market=5 → arrive=40 → trade.meet=6 → fulfilled=0`。
- **order_placed=1833**＝掛單（passive，order_system:40，每需求 cadence 掛看板；1833 多為同需求重掛）。
- **物理貿易行極小**：seek_market=5 / arrive=40 / meet=6。**幾乎沒隊真去市場**。
- **撮合層 bail 皆小數**（賣 sell_no_surplus=13 / 買 buy_no_stock=7 / buy_no_want=9 / carry_full=4）＝**撮合層非主瓶頸**（prior GATE-B「local-only 撮合」framing 是抵達後的次要牆；主瓶頸在**根本沒抵達**）。

## 機制（撮合上游 = trade-trip 決策 under-fires）
- `_merchant_trade_target`（faction_ai:2129，seek 源）只對 **`ambition_archetype==ARCHETYPE_TRADE`** 隊做 arbitrage；非 TRADE archetype 隊只巡最近 **`team_market_known`**（belief-gate）市集（rare）。
- 買候選（goal_resolver:200-203 TASK_TRADE-to-mp）是**另一路**（arrive=40 主來源），但到了 granary 空/已滿足 → 不成交。
- ∴ **binding＝trade-trip 決策 under-fires**——連 **known_issues:504**「是 TRADE 的隊都卡在永不呼 `_merchant_trade_target` 的角色（faction leader 跑勢力 AI / 獨立隊覓食分數蓋過）」＝**trade-trip loses argmax 給覓食/外交**（economy 決策不 fire 家族，同 founding-preempt/construction-搶班 meta-theme）。

## ★翻轉：GATE-B fix ≠ 純撮合/co-location
prior framing「GATE-B=local-only 撮合（空間分配）」是**抵達後的次要牆**；**真 binding 在決策上游**（teams 不 dispatch trade-trip）。修撮合（co-location）**沒用如果沒隊真去市場**。∴ GATE-B 真 fix 方向 = **讓 trade-trip 決策 fire**（economy 決策權重 vs 覓食/外交）。

## ★vision Q 更相關了
trade-trip 幾乎不 fire → **3rd-path harvest-expedition（自主去 forest 採料帶回、不靠市場/不建永久 outpost）可能比修 trade 更 robust**（不依賴「別隊來賣 + 我去買 + 撮合」整條脆弱鏈，自主取得）。∴ 用戶 vision（買驅動 vs 賽跑/自主採集）**直接決定** GATE-B 是「修 trade-trip 決策」還是「加 harvest-expedition 繞過 trade 脆弱鏈」。

## checkpoint（context 深、vision pending）
- sub-gap **pin 完**（binding=trade-trip under-fires、非撮合）。
- **fix 設計待**：(a) 用戶 vision（修 trade vs harvest-expedition）(b) decision-layer 確認（trade-trip loses argmax 給啥，一次 confirm）。
- floor held、runway banked、RELEASED 持守不動。**你這端等用戶 vision；我 sub-gap 推到 pin 完、不空等**。vision 回 + 我 confirm decision-layer → scope slice。
