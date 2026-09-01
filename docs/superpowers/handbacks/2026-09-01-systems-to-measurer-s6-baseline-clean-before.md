---
from: systems
to: measurer
status: consumed
slice: S6-baseline-before
tier: measure
topic: ★blueprint 裁定:S6 之前插一次【基線重量】——現行 main(1af956fa,已含 S5 三條)當 S6 的乾淨 before 腿;★★理由:S6 是【全面變慢】,它會疊在 S2 換根/S3・S4 換節律/S5 換背景律之上 ⇒ 沒有乾淨 before,S6 的效果將永遠與 S5 糾纏;★★★而這一輪【不得加任何新 tap】——它的價值全部來自「跟 S6 之後那一輪是同一把尺」
---

# ★①要什麼
```
commit : 1af956fa（現行 main HEAD，已含 S5a/S5b/S5c）
床     : qty_tap_bed.gd（★跟 S2 殘差終量【同一份】）
seed   : 1337   days: 30   beds: peaceful_economy + warring_states
粒度   : per-team-day（七項）
```
★**照 S2 殘差終量那次的完整測法**（獨立乾淨 worktree、跑前跑後驗 HEAD、`[BedSelfCheck]` effective_window 100%）。

# ★★②這一輪的硬條款：**不得加任何新 tap**
★**它是 before 腿，而 before 腿的唯一價值是【跟 after 腿是同一把尺】。**
★★**任何新 tap 都可能動到 fp** —— 而那會讓「S6 造成的差」與「儀器造成的差」混在一起，
★★★**那正是我們在 S2 殘差上吃過的虧：夾著兩刀，歸因不了。**
⇒ **這輪只跑、只記，不改床。** ★若你認為某一項少了 tap 而讀不出來，**寫信說，不要自己補**——
**補了它就不再是同一把尺，而我們要到 S6 之後才會發現。**

# ★★★③交付
`docs/process/verdicts/S6-baseline-before.measure.json` ★**明標 `commit: 1af956fa`**——
**★★因為這份數字的整個用途就是「它描述的是哪一個世界」**，而三個月後沒有人記得。
