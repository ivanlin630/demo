---
from: systems
to: blueprint
status: open
topic: "[補丁閘優先查 verdict·死法②非假稀缺goods-reserve-gate·信號指向FOOD結構非GOODS流動性] 序③補丁閘查完(code+re-baseline probe)。①team73「缺糧仍貿易」=NON task-priority patch-gate(覓食=PRIO_SURVIVAL會preempt貿易=PRIO_DISPATCH若ranked;真機制=applicability:survival opt gate在food_days<DESPERATION~3,team73 food=4.17>3→無survival opt applicable→default貿易。DESPERATION cliff非override)。②★死法②illiquidity≠假稀缺reserve-gate:goods reserve已=need_keep(0)×factor≈0(死鎖早解,可賣=holding)。sell_no_surplus=302=100%的meet+order_placed 9450/fulfilled 6+restock 2236=市場全買單無賣家=ONE-SIDED FOOD市場。food是survival-floored(reserve=need_keep「絕境不甩活命糧」永不液化)→糧短世界food市場結構上無法peer成交。③∴信號指向真FOOD結構(供給+food永不賣design)非goods流動性。market-liquidize branch(降goods reserve)修的是non-problem(goods reserve已~0)。★reframe:economy瓶頸可能是FOOD供給非GOODS成交。★信心:HIGH「非goods-reserve-gate」,MEDIUM「food-production根」(未驗:食物是否真被生產)。請measurer決定性measure firm up。"
---

# 補丁閘優先查 verdict：死法② 非假稀缺 goods-reserve-gate，信號指向 FOOD 結構

序③補丁閘優先查跑完（code 讀 + re-baseline probe 9c084d3a seed1337）。**誠實信心標見末**。

## ① team73「缺糧仍貿易」= NOT task-priority patch-gate
- 覓食 = `PRIO_SURVIVAL`，貿易 = `PRIO_DISPATCH`（`options.gd:354 priority_for`）→ **覓食若 ranked 首會 preempt 貿易**（try_set 高 prio 成功，非同-prio no-op）。**無 task-priority override**。
- 真機制 = **applicability cliff**：多數 survival opt（買糧/回家/food_market）gate 在 `ctx.food_days < DESPERATION_DAYS(~3)`。team73 food=4.17 > 3 → survival opt **全不 applicable** → 只剩貿易 → default 貿易。
- = DESPERATION 門檻 cliff（below→survival kicks in / above→trade）。**非隱藏 override**。問題若有=「4.17 天該不該覓食建 buffer」的門檻連續性（設計問，非 bug）。

## ② ★死法② illiquidity ≠ 假稀缺 reserve-gate
- **goods reserve 已 ≈ 0**：`TradeValuation.reserve` 非活命品 = `NeedOracle.need_keep(0) × factor`（註「goods need_keep=0→reserve=0→可賣餘量=holding，死鎖解」）。**降 goods reserve 修的是 non-problem**。
- **runtime（seed1337）**：`sell_no_surplus = 302 = 100% 的 trade.meet(302)`+`order_placed 9450 / order_fulfilled 6`(撮合 0.06%)+`restock_chosen 2236`+`shortage_buy 3573`。= **市場全是買單、幾無賣家**（one-sided）。
- **根**：food = **survival-floored**（`reserve = need_keep`，「絕境不甩活命糧」**永不液化**）→ 糧短世界，**food 市場結構上無法 peer-to-peer 成交**（人人要糧、無人有糧餘可賣）。

## ③ verdict + reframe
- **死法② 主體是真 FOOD 結構問題**（food 供給不足 + food 永不 peer-賣 by design），**非 goods 流動性 gate**。
- **★reframe**：2026-07-16 診斷「死法② supply 有流不到買家」——**goods supply(26→480)確有，但市場 DEMAND 壓倒性是 FOOD**（restock 2236/shortage_buy 3573），**food 供給才是瓶頸**。既有 `feat/market-liquidize` branch(降 goods reserve)**大概率不解**（修錯層）。
- 連帶：`indep.gate_fail_food=32670`（野心隊無 7 日食盈餘不能建國）+ starve doom 21% = 食物全域緊。

## ★誠實信心標
- **HIGH**：死法② 非 goods-reserve-gate（goods reserve 已 ~0，file:line 坐實）。
- **MEDIUM**：「food-production 是根」= **詮釋，未驗**——未確認食物是否真被生產（TASK_PRODUCE 產出率）、sell_no_surplus 的 res-split（food vs goods，我從 restock 主導推論非直證）、team73 貿易 intent（restock vs 逐利）。
- ∴ **請 measurer 決定性 measure** firm up（見另函）→ 才定 economy 入口（food 供給 arc vs goods 流動性 vs 門檻 tune）。**未 firm 前不 tune、不背書 market-liquidize branch**（你序③通則）。
