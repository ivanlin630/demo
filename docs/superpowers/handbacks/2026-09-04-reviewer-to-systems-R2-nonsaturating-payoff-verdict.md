---
from: reviewer
to: systems
status: open
slice: payoff-derive-bridge（不飽和候選·R②三輪）
topic: R②判決:issues(小)——BASE_PRICE當單位換算器判定:合法,不是手抄物理。理由:①它不是為這票新造的,是既有「trade估值唯一真值源」,已經在local_value做同一件事(跨資源換成可比價值單位);②它的值不是拍腦袋選的,查了header自述定價規則「成品價≥Σ原料價值×1.2」,是內部一致的成本推導表非任意偏好表;③同源沿用既有東西做既有東西本來就在做的事,不是新增。但附帶一個要在implementer那份量測回來後一併看的殘留:BASE_PRICE本身跨resource有~40倍價差(food=2 vs weapon_ranged_high=77),用它當乘數會在maintain家族內部重新製造一種量級分散(這次來源是price非population),不必然是bug(經濟價值真的有高低,不像純population-scaling那樣明顯是artifact),但驗收要多問一句「有沒有單一資源因為BASE_PRICE系統性贏」,不能只問「還是不是常數」
---

# 判決：`issues`（小），`premise_contradiction: false`

## BASE_PRICE 當單位換算器——**合法，不是手抄物理**

查了 `trade_valuation.gd:1-29`：`BASE_PRICE` 是這個 codebase 的「trade 估值**唯一真值源**」（header 自述：消掉 `interaction_system`/`player_trade_system` 兩份漂移副本，收成 canonical 表）——**它不是為這票新造的常數表，是既有的、已經在服役的東西**。而且它的值不是拍腦袋選的：header 明寫定價規則「**成品價 ≥ 原料價值(Σ in × BASE_PRICE) × 1.2**」——這是一個內部自洽的成本推導表（高階成品的價格由它的原料成本推出來，不是每項各自拍一個數字），跟你們今天在別票反覆用過的「手抄物理 vs 同源推導」判準對照：

```
手抄物理 = 為了讓某個東西 fire，憑感覺挑一個新數字
同源推導 = 拿一個【已經存在、已經在做同一件事】的東西，去做它原本就在做的事
```
**`BASE_PRICE` 現在就已經在 `local_value` 裡做「把不同資源的量換成同一種可比較的價值單位」這件事**（跟你要拿它做的事完全同一種用途，只是消費者不同）——這是同源推導，不是手抄物理。

## ★附帶一個要跟 implementer 那份量測一起看的殘留

`BASE_PRICE` 本身跨資源有很大的價差（`food=2.0` vs `weapon_ranged_high=77.0`，將近 40 倍）。用它當乘數：`(target-stock) × BASE_PRICE[res]`，**會在 maintain 家族內部重新製造一種量級分散**——這次來源不是 `TARGET_PER_POP`（population 尺度），是 `BASE_PRICE`（價值尺度）。

★**這不必然是 bug**——跟純粹的 population-scaling 不一樣，「武器短缺比食物短缺更值錢」某種程度上是真實的經濟事實（武器本來就比食物貴），不是一個明顯的度量 artifact；而且 `TARGET_PER_POP`（食物需求量大、武器需求量小）跟 `BASE_PRICE`（武器單價高、食物單價低）方向剛好大致相反，兩者相乘後的實際分散幅度不是簡單疊加，得看真實數字才知道有沒有互相抵銷。

⇒ **這正是為什麼不能只問「換上去還是不是常數」**——implementer 那份量測（換算式印出來）該多問一句：**「有沒有單一資源，因為 `BASE_PRICE` 系統性地高，導致它的 maintain goal 幾乎總是贏過其他 4 個 maintain 資源」**——跟你之前查「maintain vs build 兩家族是否重疊」同一套邏輯，這次要在 **maintain 內部 5 個資源之間**也跑一次。若 dump 出來看到「這次不再是全常數，但變成 weapon 系永遠比 food 系分數高一截」，那還是換了一種恆等，只是換到「resource 之間」而不是「maintain vs build 之間」——跟這票這幾輪一路抓到的失敗模式是同一個家族。

## ⇒ 要你補的
1. `BASE_PRICE` 當換算器：判定合法，可以用，不用再猶豫這格。
2. implementer 的下一份量測，除了「還是不是常數」，補問一句「maintain 內部 5 個資源的導出值有沒有被 `BASE_PRICE` 系統性拉開排名」——用同一套 dump 機制多印一欄即可，不是新測法。

**premise_contradiction: false，判斷可以往下走，附帶那條在下一份量測回來時一併確認即可。**
