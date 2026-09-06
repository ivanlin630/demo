---
from: systems
to: implementer
status: consumed
slice: perf-spike-per-call-distribution
tier: probe
topic: ★一顆 bump_sample:每次 unified.rank 的【單次耗時】,要分辨「均攤地慢」還是「少數極貴」;★★★位置陷阱同上次:必須用【既有的那對計時】不要另外呼叫 Time.get_ticks_usec(),否則你新加的量測本身會被算進 unified.rank;★母體/取樣偏差要寫死(bump_sample 是 first-N,必報母體 vs 樣本)
---

# ★①要的東西
```gdscript
Probe.bump_sample("unified.rank.call_us", {"us": <單次耗時>, "team": team.team_id}, <cap ≥ 100>)
```
★**目的**：**分辨那 0.22 秒／次是【均攤地慢】還是【少數幾次極貴把中位數拉起來】** ——
★★**兩者要鑽的地方完全不同。**（★**若 top-1 就佔一半以上，要找的不是「決策很慢」，是【那一兩個特定的決策】。**）

# ★★★②位置陷阱：**用既有的那對計時，不要自己再呼叫一次 `Time.get_ticks_usec()`**
現場（你上次插 tap 的同一段）：
```gdscript
if Probe.enabled: Probe.bump("unified.rank.calls")                       ←你上次加的
var _tr: int = Time.get_ticks_usec() if SimRunner.phase_timing else 0    ←★計時起點（既有）
var ranked: Array = DecisionEngine.rank_scored(state, team)
ranked = DecisionEngine.reorder_same_need_first(ranked)
if SimRunner.phase_timing: _tr = _fai_pht("unified.rank", _tr)           ←★計時終點（既有）
```
★**要求：把單次耗時從【既有的 `_tr` 那對】取出來，`bump_sample` 放在終點【之後】。**
★★**不要在起點前後另外呼叫 `Time.get_ticks_usec()`** —— ★★★**那等於在被計時的區間裡再加一次量測，而 `unified.rank` 正是我們要歸因的數字。**
★**同上次那條，只是這次陷阱在「量測自己的量測」。**

★**注意 `_fai_pht` 會把 `_tr` 覆寫成新的時間戳** ⇒ **若要單次耗時，得在呼叫前自己算差，或看 `_fai_pht` 有沒有回傳耗時。**
★★**這一格你比我熟，做法你定 —— 我只要求【不新增計時呼叫進那個區間】。**

# ★★③母體與取樣偏差【寫死在 dump 裡】
★**`bump_sample` 是 first-N** ⇒ ★★**必報【母體】vs【樣本】**：
```
該 tick 真呼叫次數（= unified.rank.calls 的日/tick 增量）  ←★母體
實際採到幾筆（cap 截斷了沒有）                              ←★樣本
```
★★★**沒有這兩個數字，「top-1 佔 X%」是【樣本內】的 X%，而它會被讀成【母體】的 X%。**
★**若 cap 截斷了，dump 要自己說「本 tick 母體 N、樣本 M、以下比例僅樣本內」。**

# ★④驗收
1. ★**`fp` 逐位元不變** ＋ **當場重測基線寫進 handback**
2. ★**陽性對照照你上次立的形狀**：`Probe.enabled=false ⇒ key【不存在】`（不是「值為 0」）
3. ★★**加一組對照證明【沒有新增計時呼叫】**：**`phase_timing=false` 時這顆 sample 仍能運作或明確不運作** ——
   ★**講清楚它依賴誰**（若它依賴 `phase_timing`，那要寫進 dump 的前提，否則有人單開 `Probe` 會拿到空的）
4. headless（baseline 7）＋憲法閘 PASS
5. ★**只有這一顆，別順手加別的**

★**背景**：靶已經分成兩個 —— ★**A：`orders_ambition` cadence 對齊 burst（已坐實，刀＝錯峰）**；
★★**B：`loop2.solo`/`unified.rank` 這條 cross-cutting 路【不靠對齊也會把某個 tick 撐到 25M us】**。
**這顆是為了 B。**
