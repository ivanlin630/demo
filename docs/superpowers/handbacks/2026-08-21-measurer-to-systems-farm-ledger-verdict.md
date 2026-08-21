---
from: measurer
to: systems
slice: dying-village-farm-ledger
status: open
topic: "★★優先題答案：terrain_tally={plains:9,forest:2}——82%萎縮隊在plains,cap假說死透,瓶頸在提取端★★★決定性發現:8/11萎縮隊站在滿/近滿食物池(runway 61-364天)卻effective_food只有2.3-9.2——『池滿人餓』用戶假說成立,是提取funnel斷非承載力;確認鏈證實無outpost+camp_level=0的團隊該cadence物理上零被動食物(collect.no_outpost_no_camp_zero_food累計984次)，camp_level=1的team10/11是正面對照組(ef暴漲至388/457)；③corvée結構code讀:labor_pop/pool_of未發現依construction狀態扣減的路徑,假說目前不成立(信心中等,未做即時快照)；四分流已逐隊分類，補collect.*確認鏈3個L3 tap"
---

# 四分流答卷：優先題先講

## ★★優先題：cap假說死透

**萎縮到pop<=1的11隊，terrain_tally = {plains: 9, forest: 2}**（82% plains）。

你的假說撤回是對的——若地格cap是決定性差異，萎縮隊該以forest為主，實際上絕大多數在plains。**cap不是解釋力，瓶頸在提取端。**

## ★★★決定性發現：8/11萎縮隊「池滿人餓」，是提取funnel斷

逐隊(見`.measure.json`完整表)：**幾乎所有萎縮隊站立的tile食物池都是滿的或接近滿的**(pool_food≈cap)，換算runway全部61~364天——遠超任何合理擔憂。但這些隊的`effective_food`(真實持有)只有**2.3~9.2**。

最刺眼一筆：**team17站在全場pool最大的tile(291)卻餓到effective_food=3.3**。

## ★★被動採集確認鏈：機制不是bug，是一個「開關」

```
collect.gather_ran                   = 1945
collect.l0_forage_ran                = 460
collect.no_outpost_no_camp_zero_food = 984
```

三條路徑都真的有跑(非死代碼)。但**984次「整條cadence零被動食物」**證實：`resource_system.gd:65-78`的邏輯是——**只有`camp_level>0`才會從腳下pool抽food**，否則除了被動小獵，什麼都拿不到。**無outpost且camp_level=0的孤身領主，站在滿池上也物理上拿不到食物。**

★**正面對照組**：team10/11同樣pop=1、同樣是plains，但**camp_level=1**——effective_food暴漲到**388/457**。camp_level是這個開關的鑰匙，而孤身領主似乎很難/很少去建camp（同corvée一樣需要主動觸發），導致長期卡在零被動食物態。

## ③corvée查點：結構code讀，假說目前不成立

`labor_system.gd:32-42`：`labor_pop(team)=population×(1-mobilized_fraction)`——只受**軍事動員**影響。`rebalance()`的demand字典只列gather/mfg/farm，**沒找到任何construction競爭同一勞力池的demand entry**。★這是code讀非量測，信心中等（沒做corvée進行中的即時labor_alloc快照）——如果corvée期間仍餓死，機制可能不在這個池，建議implementer查`faction_ai_system.gd:4547`一帶的P(survive_to_harvest)邏輯。

## 四分流逐隊分類（完整表在.measure.json，不重複貼）

- (i)沒建成：team11(有outpost，farm_level=0)
- (ii)建了但勞力=0，本輪無法測『math夠不夠』：team0/20/3/4/5/10——★注意本輪90天內沒有任何一隊farm labor接近滿載（最高team2的33%），你的「紅旗」計算假設滿載，滿載案例沒出現過，這題本輪答不了
- (iii)forest掙扎：team5/14，但已證非主因
- (iv)★池滿人餓＝提取funnel斷（addendum新增，本輪最大發現）：team3/4/5/16/17/18共6隊(佔萎縮隊過半)

## L3聲明

`resource_system.gd:collect_resources`加3個Probe.bump確認鏈tap（gather_ran/l0_forage_ran/no_outpost_no_camp_zero_food），純計數零行為改動，main+worktree同步。建議留permanent（補盲點，同named餓死tap先例）。

## 落地

`.measure.json`：`docs/process/verdicts/dying-village-farm-ledger.measure.json` @c40fa5c2(main) 2026-08-21
report：`docs/measurements/breed-deathcause/farm-ledger-addendum-90d.txt`

## 交你裁

①camp_level開關要不要開票查(為何孤身領主很少建camp，這可能是settlement funnel真正的斷點，比farm本身更上游)②三tap要不要permanent③farm labor從未滿載這件事本身值不值得另開一輪逼近滿載測試(例如控制pop固定較高值)去回答『math夠不夠』的原題。
