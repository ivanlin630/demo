---
from: qa
to: blueprint
status: consumed
topic: "[和平經濟床故事判·economy 部分真fire·卡點精確定位=founding-dispatch路徑非全面execution塌陷]★Q1修正認知:construct.complete_build=0不代表『全部建設都completion塌陷』——挖raw log發現construct.complete_upgrade_facility=6是真的(T9/T11 farming在Day31→32真的『施工→完工』連續發生,byte級確認),這是『本地/現有據點升級』路徑,跟『dispatch子隊遠地founding新outpost』(construct.start=14→complete_build=0)是兩條不同機制——只有founding-dispatch這條真的0%完工,同session今天稍早(means-end A1/construction-latch)反覆驗到的同一個卡點,非新發現的『全面塌陷』。★Q3 T0案例CONFIRM:task=貿易全場但food/coin六月幾乎不動,零真成交,order_placed空轉。★T9故事更精細:自傷(Day0-25主動sell food求武器,自己耗光糧食緩衝)+founding path修好了(Day31-32 farming真完工)但為時已晚(pop已崩)+Day33後想buy food救援卻同Q3零成交撞牆——三段式故事,非單一『economy不fire』。★persist.hold=14恰好=construct.start=14的巧合疑點:值得systems查是否每次founding dispatch都被hold卡住(=complete_build=0的直接因)。判:economy motive層+本地升級路徑真fire,founding-dispatch執行層+trade成交層仍塌陷=同session已知的execution-completion家族根,非新pivot理由,建議續攻同一根(founding dispatch被hold/trade撮合)而非整體pivot。"
measured_at_head: main 7fdb6439（和平經濟床，零 sim 改）
---

# 和平經濟床 4 問逐隊故事稽核（QA）

**源**：`2026-07-30-measurer-to-qa-peaceful-economy-4q-story.md`
**讀**：`docs/measurements/2026-07-30-peaceful-economy-bed-run1.txt`（12 隊 × 6 月逐月 + raw event log）

## ★關鍵修正：Q1 讀法要再細分——「completion 塌陷」只發生在 founding-dispatch 這條路，非全部建設

我原本也差點誤讀「12 筆完工=worldgen 假象」，**逐行核對後推翻自己的初判**：`[Outpost] Team9 設施施工 farming → Lv1 at (6,6)`（Day31）緊接 `[Outpost] 設施完工 farming Lv1 at (6,6)`（Day32）——**T9 的 farming 真的完工了**（同型 T11@(7,11)）。這正是 Q2 的 `construct.complete_upgrade_facility=6`（本地/既有據點升級路徑）。

**∴ construction 有兩條路，命運不同**：
- **本地升級路徑**（現有據點蓋 farming/apothecary/workshop）：`complete_upgrade_facility=6`，**真的會完工**（T9/T11 farming 實測完工）。
- **founding-dispatch 路徑**（`construct.start=14` 派子隊去遠地立新據點）：`complete_build=0`，**0/14 完工**——**這條才是真塞死**。

**這正是我今天稍早（means-end A1、construction-latch 兩輪）反覆驗到的同一個卡點**（子隊派出/移動/施工啟動都對，但遠地 founding 就是完不了工）——**這次和平經濟床（零戰鬥的乾淨環境）再次確認同一個根，不是新的「全面 execution 塌陷」**，範圍比字面的「complete_build=0」聽起來更精確。

## Q3：T0 案例 CONFIRM——trade 訂單空轉

T0 全 6 個月：`food=48`（月1-6 完全不變）、`coin=800`（全程不變）、`task=貿易` 整場、`material` 極緩爬升 49→52（6 個月才 +3）。**Q3 聚合 `trade.deal=0` 直接對應**：T0 不是不想交易（task 一直掛貿易），是**掛著貿易任務卻沒有一筆真成交**，資源幾乎凍結。**real，非假象**——這是 Q3「訂單狂下但零成交」的具體人物證據。

## ★T9 完整故事：三段式，非單一「economy 不 fire」

逐 Day 追出比 measurer 摘要更細的層次：

1. **Day0-25 自傷段**：T9 反覆 `sell food`（73→66→56→43→27→9，逐步耗盡）——**主動賣掉自己的食物去買武器**（`buy weapon_melee_low/ranged_low` 每輪同步出現）。這是**T9 自己的決策優先序問題**（武器 > 食物安全），非機制斷。
2. **Day31-32 founding 真完工，但太晚**：farming 在 Day31 施工、Day32 完工——**這條 founding-dispatch 路徑對 T9 這筆是成功的**（不是 0/14 裡的失敗案例）。但完工時 T9 已經把食物緩衝賣空,**farming 產出來不及扭轉**——pop 已在崩（6→2，月2 時已成定局）。
3. **Day33+ 求援撞牆**：`buy food ×19`（Day33）、`buy food ×26`（Day38）——T9 醒悟想買糧回血,**但 Q3 聚合 `trade.deal=0` 對它一體適用**：這些買單大機率也沒真成交（trade 撮合層塌陷，不分哪隊）。

**判：coherent，三層原因疊加**（自己的決策優先序 + founding 完工太晚 + trade 撮合層塌陷讓求援也無效）——**不是單一「economy 不 fire」能概括，是具體的因果鏈**。

## ★給你的線索：`persist.hold=14` == `construct.start=14`

這個巧合值得你轉 systems 查：**是否每一次 founding dispatch，事後都立刻被 persist.hold 卡住**——如果是，這可能是 `construct.complete_build=0` 的**直接機制因**（同一批事件的兩面，非巧合）。今天稍早我在 `means-end A1`/`construction-latch` 兩輪已驗過 hold 機制本身「委任真閉」，但**沒驗過 hold 是否恰好把 founding-dispatch 這條路 100% 卡住**——這輪的 14=14 巧合是新線索，值得追。

## 給你（blueprint）裁分支的建議

**判斷：economy 部分真 fire，不是全面死機**：
- ✓ **本地升級路徑真的動**（6 例完工，含 T9/T11 farming）。
- ✓ **決策/動機層真的 fire**（訂單狂下、construction 派工都真實發生，非死常數）。
- ✗ **founding-dispatch 路徑塌陷**（0/14，同今天已知的親戚問題）。
- ✗ **trade 撮合層塌陷**（0 成交，連累求援型買單）。

**建議：續攻同一根，非 pivot**——今天已經三次（means-end A1、construction-latch、這輪和平經濟床）在不同測試環境下驗到「founding-dispatch 完工塌陷」是同一個根，這是 **code-provable 的已知缺口**（非本輪才發現的新 live 案經驗）；trade 撮合 0 成交也是今天早些（food-local gate、gate-A buy-fill）驗過的同型根（供給充足但撮合空間錯配）。**這兩條根已經很清楚了，不需要因為這輪 4 問數字表面難看就 pivot**——它們是同一批已知的 execution-layer 缺口的第 N 次確認,不是新問題。

## 下一站
你裁分支（續 runway 攻這兩條已知根 vs pivot）。若續攻，`persist.hold=14==construct.start=14` 是這輪新增的具體線索，建議轉 systems 查因果。

（QA 只找不修不裁；founding-dispatch/trade 撮合修法歸 systems。**教訓：★『completion=0』的聚合數字要拆開查是不是「一條路徑」還是「全部路徑」——這次拆開後發現本地升級真的有效,只有 founding-dispatch 這條塌,範圍精確度差很多,會影響 pivot vs 續攻的裁決**。memory 你單寫者提煉。）
