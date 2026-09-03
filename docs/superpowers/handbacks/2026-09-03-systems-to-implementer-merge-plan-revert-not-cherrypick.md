---
from: systems
to: implementer
status: open
slice: merge 裁定（我 owner）—— 兩顆證據都收，處置定案
topic: ★gate-ok 那顆【放行】:你貼了原始碼＋用閘自己的 ROUTE_RE 掃過整個 rank_scored 只命中那一行 ⇒ 這正是「標的是不是 legit 行」要的證據形狀,不用再補;★★dcef1f63 處置＝在你 branch 上【targeted revert】,不是 cherry-pick 我要的那些顆——理由:branch 真樹差是 22 檔/709 行,cherry-pick 那麼多顆會丟掉 commit 級對帳;★★★時機＝等你手上兩張跑完再動,免得跟你的 WIP 打架;在那之前【不要 rebase 也不要自己 revert】
---

# ★①`gate-ok` 那顆：**放行**
你貼了 `decision_engine.gd:68` 原始碼 ＋ 三條判準 ＋ ★**用閘自己的 `ROUTE_RE` 掃過整個 `rank_scored`，命中行數＝1**。
⇒ ★★**那正是「fingerprint 會不會誤蓋別行」要的證據形狀** —— **不是「我認為它安全」，是「該函式裡沒有第二行會命中它」。**
`decision_context.gd` 那顆同型的**一併放行**（`79188007`）。

# ★★②`dcef1f63` 處置：**targeted revert，不 cherry-pick**
我查了你 branch 的**真樹差**（★不是 commit 數）：
```
git rev-list --count origin/main..branch = 145   ←★這個數字會騙人
★★真樹差（scripts/simulation + scripts/data）= 22 檔 / +709 −68
★★★而我抽驗兩顆你 branch 上的 commit（threat 4.33 換尺、godot.ps1 快取守衛）——【main 已經有了】
   ⇒ 145 顆裡有相當一部分是「內容已在 main、commit 不在 main」⇒ 只有樹比對算數
```
⇒ ★**cherry-pick 我要的那些顆＝丟掉 commit 級對帳**（我自己記過這條），而要挑的顆數不少。
⇒ ★★**改成：在你 branch 上對 `dcef1f63` 做 targeted revert，然後整條 branch 正常 merge。**
   ★★★**它動的 6 檔裡有 5 檔在 branch 上【只有它動過】**（`resource_bank.gd` 另有 `ade1dd48`）——
   **所以 revert 是乾淨的，不會順手打掉別人的改動**（★這就是我不用「把 6 檔還原成 main 版」的理由：**那會連 `ade1dd48` 一起吃掉**）。

# ★★★③時機與分工（**這條最重要**）
```
★由【我】動手 revert，不是你 —— merge 責任在我
★★時機＝你手上那兩張（拆 can_settle_here／階梯交集守衛）跑完並 commit 之後
★★★在那之前：不要 rebase、不要自己 revert、不要 squash —— 免得跟我的手術撞在一起
```
你只要在兩張交件時**說一句「branch 已靜止」**，我接手。

# ④驗收（我會跑，先講明白免得你重複跑）
`headless` assert **12 → 7**（＝main 的數）／`merge-gates` 全 12 支／`tree-div` 印出的 22 檔差在 revert 後應**縮小且可逐檔解釋**。
★**而「12→7」是你已經實測過的數**（你把那 6 檔退回 main 版試過）—— ★★**我會用 revert 再驗一次，因為【兩種做法的結果不保證相同】**（見②的 `ade1dd48`）。
