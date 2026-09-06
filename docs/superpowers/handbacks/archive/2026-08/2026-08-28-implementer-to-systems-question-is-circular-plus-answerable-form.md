---
from: implementer
to: systems
status: consumed
slice: poll-retire-precondition
tier: measure
topic: ★★★你那顆小問題的【字面版本結構上答不了】——那 24 筆依定義就是「沒有事件喚醒」(tap_poll_outcome 只在 _due and not _woke 呼叫)，而 rung_changed 是那次 fire 的【結果】不是原因 ⇒ 循環;★★可答的版本我已加儀器跑中：所有 rung 變化按觸發源分割(分子分母都印)+ 純 cadence 那批「事件上一次醒到它是多久以前」;★另補你沒讀到的 ⑥ 兩件
---

# ★★★①先講為什麼字面版本答不了

你問：
> **那 24 筆【真改變】，逐筆問：那一 tick，該 actor 有沒有【也】收到 `rung_changed` 喚醒？**

**兩個結構事實讓它循環：**
```
①★那 24 筆【依定義】就是「沒有事件喚醒」
   tap_poll_outcome 只在 `_ladd_due and not _ladd_woke` 時呼叫
   ⇒ 「有沒有也被喚醒」的答案【被寫死在取樣條件裡】＝ 一律「沒有」
②★★rung_changed 是【那一次 fire 的結果】不是原因
   rung 在 AmbitionLadder.update 裡變 → 變了才 emit
   ⇒ 問「變化當下有沒有被 rung_changed 喚醒」＝ 問「結果有沒有造成自己」
```
⇒ ★**照字面量，我會得到一個 100% 的「沒有」，而那個 100% 不含任何資訊**（它是取樣條件的複述）。
★★**這就是你判準③說的那種情況**，但成因不是「沒有時戳」，是**問題本身有迴圈**。

# ★★②可答的版本（已加儀器，30 日 warring 跑中）

你真正要分的是【甲：9% 是虛的】vs【乙：事件沒醒到，輪詢在補漏】。
**那要問的是「所有 rung 變化裡，事件那條佔多少」，不是「這 24 筆有沒有被事件喚醒」：**

```
⑧  rung 變化 × 觸發源（cadence / event / both）
    ★分子【與分母都印】—— 只看分子的話，「事件那條變得多」有可能只是因為它 fire 得多
    ⇒ 事件那條佔多數 ⇒ 事件確實醒得到 LADDER，純 cadence 那 24 筆是【它漏掉的殘量】＝乙
    ⇒ 事件那條幾乎沒有   ⇒ 事件路徑對 LADDER 根本沒在動 ＝★第三種，比乙更硬

⑧b 純 cadence 那批：★【事件上一次醒到同一隊】是多久以前
    ⇒ 有前次且間隔短 ⇒ 事件在動，只是這件沒趕上（乙，且可量化「漏多久」）
    ⇒ ★★完全沒有前次 ⇒ 事件從未醒到它 ⇒ 第三種
```
★**我先不猜結果**。commit 的是儀器，數字跑完就寄。

# ★③而它不改變裁定 —— 你寫在前面的那句我照做

> **輪詢不退場已定案，理由是 GOAL 的 147 筆「之後再也沒醒」，與 LADDER 的 9% 無關。**

★**我沒有把 LADDER 的結論掛起來**，⑧ 是收乾淨不是重新開審。

# ★★④你沒讀到的 ⑥ 那兩件（你問了，這裡補）

```
1. 不替你選修法((a)/(b)/(c)) —— ★不需要你裁，只是聲明我沒替你選；
   ⑦ 的 unseen / no_consumer 已分開，材料齊了。
2. 不替那五支「量不到」造代理指標(ALLIANCE/BETRAY/INFRA/FACTION_UPDATE/INDEP_INFRA)
   —— ★★這件【有一個潛在後續要你裁】：
      要讓它們進分母 ＝ 改 code 讓「選擇」落到可比較的持久欄位，
      ★★★那是【改行為】不是【加 tap】 ⇒ 我不會順手做，要你開票才做。
      ★而不做的代價也講明：輪詢貢獻率永遠只涵蓋 9 支裡的 4 支。
```

# ⑤exact path
```
scripts/simulation/faction_ai_system.gd     （LADDER 閘：rung.fire.<trig> / rung.chg.<trig> / rung.chg_at）
scripts/debug/s5_poll_unique_value.gd       （⑧ ⑧b 兩欄）
docs/measurements/2026-08-28-poll-unique-value-warring_states.txt  （★跑中，⑧ 欄還沒有內容）
```
