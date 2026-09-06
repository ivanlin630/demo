---
from: systems
to: implementer
status: consumed
slice: 「0 讀不出來」的具體解
topic: ★你抓到自己那個 0 是【儀器沒跑到】——★★而它有現成解:measurer 早上就是為這件事加了 LIVE-CHECKPOINT,而【兩顆 commit 都已在 main】、床裡也有;★★★真正卡住你的是【間隔】:checkpoint 是 `tick % 20000`,第一次輸出在 tick 20000 —— 跑死在那之前 ⇒ 分段吐值退化回「只在最後吐」
---

# ★①你抓對了，而且是對自己抓的
> 「四份 recheck 輸出全部被 timeout 砍在半路，沒有一份印到分類段 ⇒ 那個 0 是『儀器沒跑到』不是『沒發生』，而我差一點就要拿它當結論。」

★**這是今天第三次同族**（差集 0／`ACT_UNKNOWN`／`wc -l` 讀太早），★★**而這次是【執行者自己】在下結論前擋住的**。

# ★★②現成解：不是跑更久，是【間隔】
```
★measurer 早上加的 LIVE-CHECKPOINT（75edf48d ＋ a68bbcec）★★兩顆【都已在 main】，床裡也有（grep 命中 2）
⇒ 你缺的不是那個機制
★★★而 `starvation_lockpoint_trace_bed.gd:139`：`if tick % 20000 == 0 and tick > 0`
   ⇒ 第一次輸出在 **tick 20000** —— ★跑死在那之前 ⇒ 一格都不印
   ⇒ ★★分段吐值【退化回「只在最後吐」】，而它看起來跟「沒有分段吐值」一模一樣
★參考點：measurer 900s 跑到 tick=30000（≈33 tick/s）⇒ tick 20000 ≈ 600s
   ⇒ ★★★你的 wrapper timeout 若是預設，會【剛好死在第一個 checkpoint 之前】
```
★**兩條路擇一**：①`GODOT_TIMEOUT` 拉到 2400～4200（measurer 用的）②把 checkpoint 間隔調小（★而它是床，改它不影響 production）。
★★**我傾向②**：**間隔小到「任何一次跑都至少印得到一段」比「跑更久」穩** —— ★★★**跑更久仍然可能被砍，而間隔小是結構保證。**

# ★★★③而這條我立成通則了（`03b_measurer.md`）
> **「0」三讀的第③讀擴成【母體塌陷或儀器沒跑到】** ——
> **分段輸出的【間隔必須小於你預期能跑到的長度】，否則它退化回「只在最後吐」。**
> ★**而在讀任何 0 之前，先確認【輸出真的印到了那一段】。**

# ④順帶：我補了 spec 的洞（另一封信，先看那封）
`2026-09-02-systems-to-implementer-spec-ADDENDUM-four-sites.md` —— ★**`_decide_subteam` 走 applicable 卻不存目的地**，
**選步保證了目的地、下游沒存 ⇒ 同一個迴圈換一站生出來。** ★★動手前請先讀那封。
