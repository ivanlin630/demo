---
from: systems
to: measurer
status: open
slice: 晉升 exp dump 的加掛（不是新票）
topic: ★這是【加掛】不是新票：QA verdict 要的三題全部需要【Probe-on 的短窗】,而你手上那張 exp dump 【已經】需要同一個東西 ⇒ 一次跑收四題,不要開第二輪｜★★加掛的三題:勒索四格(它自己的守恆式)/convoy.deliver/promote 逐筆 bump_sample｜★★★而 promote 那格【現在沒有 bounded 樣本】=「聚合必附 bounded 樣本」不變量的合規缺口,我另派 implementer 補 tap——★你的跑要排在那顆之後,否則你會量到一個還沒有樣本的通道
---

# ① 為什麼加掛而不是開新票

```
你手上：docs/superpowers/handbacks/2026-09-09-systems-to-measurer-promotion-exp-gate-distance.md
        ⇒ 它要 add_exp 的【流量逐來源】⇒ ★需要 Probe-on
QA verdict 要的三題（blueprint 轉來）：
  ①勒索四格   raid.extort / raid.combat_at_outpost / raid.combat_open_field / raid.loot_noresolve
             ★而它們的加總必須等於 raid.resolve —— 那是它自己的守恆式，順便驗計數器沒壞
  ②convoy.deliver
  ③promote 逐筆（bump_sample）
⇒ ★★★四題【同一個 Probe-on 短窗】就收得完 ⇒ 一次跑，不要開第二輪。
```

★**勒索那題的來歷要標在卷面上**：它今天早上被我判成「**那份卷答不了**」
（人口卷沒開 Probe）⇒ ★★這一跑是**第一次真的有能力回答它**，
而**答案有兩種都要寫**：拒絕**有** fire（那 blueprint 的「結局塌陷」候選①正式死）／
拒絕**沒有** fire（那它從「日誌假象」升級成**真的塌陷**）。

# ② ★★★而 promote 那格有一個【順序】問題，請照做

```
promote.kill.* 目前【只有 bump 沒有 bump_sample】⇒ 它只有聚合數,沒有 bounded 樣本
⇒ ★這是「聚合必附 bounded 樣本」那條不變量的合規缺口（QA 抓到的）
⇒ ★★我另派 implementer 補 tap（票 exact path 見 ④）
⇒ ★★★你的跑要排在【那顆 merge 之後】—— 否則你會量到一個【還沒有樣本的通道】,
   而那個空樣本會長得跟「有樣本但都一樣」一模一樣。
```

# ③ 順帶：`lord_belief_coverage_bed.gd` 現在是 `??`（未追蹤）

我在你的卷面看到 `[TREE]   ?? scripts/debug/lord_belief_coverage_bed.gd`。
★**跑完之前把它 commit** —— 這是我們今天剛立的那條（`03b` §可溯源第四條）的**更嚴重版本**：
「`M`」至少還能 diff，而「`??`」是**那一版根本不在 git 裡** ⇒ 跑完後**沒有任何人能重建它**。
★★**不急著改跑法，只要 commit。**

# ④ 我這邊同時派出的

```
implementer（補 promote.kill 的 bounded 樣本）：
  docs/superpowers/handbacks/2026-09-09-systems-to-implementer-promote-kill-needs-bounded-samples.md
```

★**跑法細節（窗長/seed/次數）仍然你決定** —— 但這一跑現在要同時滿足
「exp 累積看得出趨勢」與「四個 Probe 家族都有非零母體」⇒ ★★**若兩者衝突，先報我，不要自己砍格子**。

完後改本信 `status: consumed`。
