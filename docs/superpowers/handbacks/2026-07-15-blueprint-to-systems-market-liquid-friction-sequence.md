---
from: blueprint
to: systems
status: consumed
topic: "[經濟定序+願景] coin紅鯡魚確認(你證的),B棄+coin循環A+B降框架債backlog。真根兩結構牆。序:①成交條件牆先(普世閘,流動化)→②merchant承諾完成trade後(預授)。願景=流動偏摩擦市場:willing夥伴大多成交(現560→3是死常數幾乎不對齊=壞非真摩擦),摩擦=價差/餘量/運力的少數且有理由,掛人格(急/絕境鬆手、貪婪守價)。成交率數字你tune,我只定流動為底摩擦為質感摩擦人格化"
---

# 經濟定序 + 願景：流動偏摩擦市場（用戶定）

coin 紅鯡魚你證得漂亮（reconcile 解禁 coin→WOULD_TRADE 恆零）。**先量隔離擋下第 5 個白工。** 定序 + 願景如下。

## coin 處置（同意你）
- **B 棄**（治標，紅鯡魚，不 merge 不 tune）。
- **coin 循環 A+B 願景 → 降框架債 backlog**（真經濟債但非市場死 binding；市場活了 coin 分佈才有意義，屆時再議）。已改 game-design 反映。

## 序（用戶定）
**① 成交條件牆先 → ② merchant 承諾後。**
- 理由：**牆②是普世閘**（擋 resident + merchant 所有路）。先修①開 merchant 也照撞牆 → 還是 ~0 deal。先流動化成交條件 → 市場在 resident 路首次 revive（proof of life）→ 再開 merchant 通道加量。

## 願景：流動偏摩擦市場（成交條件牆 = ①）＝WHAT
**不是 560→3（死牆），也不是 560→560（零摩擦）。**
- **底線＝流動**：雙方都想交易（WOULD_TRADE）→ **多數該成**。現 0.5% 不是真實摩擦,是**死常數幾乎不對齊＝壞**（照妖鏡病）。
- **質感＝摩擦**：交易不免費——**價差談判 / 餘量謹慎 / 運力成本** 讓**一部分** willing 夥伴談不攏,且**真實有意義**（真的價不對/運不划算），非全體卡死。
- **摩擦掛人格**（別 flat）：急著交易/絕境的**鬆手**（接受薄利）、貪婪/謹慎的**收緊**（守價、留餘量）→ 談不成＝**性格與情境的戲**。
- **一句**：willing 夥伴**大多能成交**,談不攏是**少數且有理由**（人格/情境），非常態。

## HOW 全交你（我不越界，這 arc 教訓）
- price/surplus/qty 三門檻怎麼從「幾乎不對齊死牆」變「流動偏摩擦」＝**你 HOW**（tune 門檻 + 掛人格函式；ask/bid overlap、surplus reserve、min carry qty 哪些鬆、哪些人格化）。
- 我只要結果：**WOULD_TRADE→deal 從 0.5% 升到「多數成」,且失敗筆有人格/情境理由（非齊平死擋）,成交隨人格分化**。
- 具體目標成交率／門檻值＝你 tune（balance HOW），我不給數字。
- **先量再修仍守**：挖 WOULD_TRADE→實際 deal 為何斷（哪道門檻主導：ask<bid? surplus? qty?）→ 再 spec，別猜。

## ② merchant 承諾完成 trade（預授 WHAT，序在①後）
- 願景：**trade 隊決定交易就該走到並完成**（走到賣方實位 + 成對成交），非途中漂走（normal-rotation preempt）或 target 錯位（order pos vs 賣方實位不符）。＝承諾原則（多-tick 動作 latch 到完成）。
- 你 patch-gate-first 挖「merchant 為何從不 co-locate」（order pos vs 賣方實位 / preempt）→ spec。序在①流動化見 proof of life 後。

## 下一站
系統 patch-gate-first 挖成交條件牆（哪門檻主導 WOULD_TRADE→deal 斷）→ spec 流動偏摩擦（門檻鬆 + 人格化）→ R②（新成交機制，審設計）→ impl → measurer 中性 full-HD（**deals 真發生＝市場首次 revive** + 失敗筆有人格理由）→ 我批 → 再攻②merchant 承諾。
**5 層 measure 全擋非-binding,真根＝成交條件死牆 + merchant 不成對。市場首次要活了。**
