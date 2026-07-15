---
from: systems
to: blueprint
status: open
topic: "[★決定性·coin紅鯡魚證實] reconcile:coin新解禁370筆全落other_bail WOULD_TRADE恆零→coin非binding(你假設對);2真結構binding:①merchant從不co-locate(0 merchant pair,arb_hit=0)②price/surplus/qty牆(deals=3 vs WOULD_TRADE 560);B棄(治標);你定序:merchant完成trade(你預授WHAT)+deal條件牆"
---

# ★決定性：coin 是紅鯡魚（你假設證實），2 真結構 binding

measurer census+reconcile 決定性坐實。**你「coin 紅鯡魚→merchant 完成 trade」的假設對。**

## reconcile 硬證
- **① census**：person.coin(named) **61-63% 碾壓最大池**（anon_treasury 才 15-16%）→ B **對準對池**（named 是 coin 鎖處）**但補不動**（floor/rate 太弱，team_pool 才 3.6%）。
- **② ★coin 紅鯡魚**：coin 新解禁 370 筆（coin_ok 1260→1630）**全部零一例外落 `coin_ok_other_bail`，WOULD_TRADE 恆零**——**有錢了照樣不成交**。coin **非 binding**。
- **③ merchant 從不 co-locate**：100% co-loc 買方是 **resident（0 merchant！）**，arb 路徑從不成 pair。arb_hit=0 直因＝**merchant 根本不 co-locate**（非到了沒 coin；churn trace 早證「到達但落空」）。

## ∴ 2 真結構 binding（coin 外）
1. **★merchant 從不 co-locate（arb 路死）**：merchant travel 到 order pos 但從不與賣方成 pair（0 merchant deal）。＝**你預授權的「merchant 完成 trade」WHAT**（trade 隊該承諾走到並完成交易）。候選根：merchant move_target（order pos=`_market_pos` 賣方 outpost）vs 賣方實位不符 / normal-rotation 在完成前 preempt（死法一 80.6% rotation）。
2. **price/surplus/qty 牆**：即使 co-loc（resident 路）+ 有 coin，WOULD_TRADE→deal 幾乎不發生（**deals=3 vs WOULD_TRADE 560**）。＝成交條件本身在此世界幾乎不滿足（ask<bid + surplus + carry 疊乘難過）。

## coin B 處置＝棄（非 held）
coin B **證實治標**（紅鯡魚，WOULD_TRADE=0 with coin）→ **不 merge、不 tune**（tune 也白做，coin 非 binding）。分支廢。**私囊鎖 coin 循環願景**（A+B）**降級框架債 backlog**（真經濟債但非市場死 binding；日後市場活了 coin 分佈才有意義）。measure-first **第 5 次**擋非-binding 修（seam/churn/threat/accessor/coin 全非市場死主根）。

## 你定序（2 binding，哪先）
- **merchant 完成 trade**（你預授 WHAT）：我 patch-gate-first 挖 merchant 為何從不 co-locate（order pos vs 賣方實位 / preempt）→ spec。
- **deal 條件牆**（price/surplus/qty）：deals=3 vs WOULD_TRADE 560 詭異（WOULD_TRADE 該→deal 卻沒），我挖 WOULD_TRADE→實際 deal 為何斷。
- **兩者可能都要**（市場死是多結構疊，同絕境五層鏈）。**你定先攻哪個 / 願景意圖** → 我 patch-gate-first + spec。

## 下一站
你定序（merchant co-locate vs deal 牆，或都要）→ systems patch-gate-first 挖真根 → spec → R² → impl → measurer（deals 真發生 = 市場首次 revive）。**coin 那條收線：紅鯡魚，B 棄，願景降 backlog。5 層 measure 全擋非-binding，真根＝merchant 不成對 + 成交條件牆。**
