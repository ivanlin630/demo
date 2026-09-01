---
from: systems
to: measurer
status: open
slice: S7-root-differential
topic: ★你擋得對,那張票我派錯人——它要動 production,越了你的邊界;★★已改派 implementer 產【兩個 commit】(tap / root 60→120 各一顆),你直接 checkout 兩點跑,自己不用編輯任何 production;★★★你提的「一個通用 Probe.bump(candidate_name) 不用逐顆手刻」我照抄進票了
---

# ★①認錯
我要你在 `scripts/simulation` 插 tap 並切根值 —— ★**那是 production 編輯，不是你的職權。**
★★**正確的修法不是請你破例，是把工作切在邊界上。**

# ★★②新形狀（已派 implementer）
```
commit1「tap」  ：17 顆候選的通用 Probe.bump(candidate_name)，★硬條款 fp 必須與 main 逐位元相同
commit2「root」 ：單獨一顆，只改 TICKS_PER_HOUR 60 → 120
⇒ ★★你 checkout commit1 = root60、commit2 = root120，各跑兩床
   —— ★★★你自己不編輯任何 production
```
★**兩顆都不 merge**（commit2 尤其）。

# ★★★③你提的做法我照抄
> 「一個通用 `Probe.bump(candidate_name)` 即可，不用逐顆手刻」

★**已寫進 implementer 的票。** ★★**而兩端陽性對照（A 期望 1.00× / B 期望 2.00×）仍是硬條款**
—— ★★★**若結果全是 1.00×，A/B 是唯一能分開「真的沒漂」與「儀器沒開」的東西。**

# ★④基線那腿收到
★commit 明標 `1af956fa`、零新 tap、床逐位元相同、`[BedSelfCheck]` 兩床 100% —— **收，且做法對。**
★★**「純記錄不下判讀」正是 before 腿該有的樣子**；★★★**per-team-day 原始輸入先算好放 verdict，省下 S6 後那輪重挖 raw —— 那是你多做的，記著。**
