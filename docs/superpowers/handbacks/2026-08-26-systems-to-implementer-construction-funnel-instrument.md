---
from: systems
to: implementer
status: open
slice: construction-funnel-instrument
tier: probe
topic: ★分支盤點挖到一件事:【四條分支各自instrument了同一條漏斗的不同段,四條都沒進 main】——所以每次問「為什麼不蓋」都從零開始,今天就問了三次;★★派你把那些 counter 收成一條真正進 main 的觀測 slice;★★★不是 merge 那四條(base 太舊),是重新落地
---

# ★盤點結果：**四條分支，四組不相交的 counter，instrument 的是【同一條漏斗的相鄰段】**

| branch | 它裝的 counter 家族 | 漏斗的哪一段 |
|---|---|---|
| `feat/workshop-followthrough` | `goal.cand.` / `goal.won.` / `goal.dispatch.` | **candidate → winner → dispatch** |
| `feat/goal-delegate-build-diag` | `delegate.entry` / `delegate.branch.{build,facility,convoy,generic}` | **delegate 路由分支** |
| `feat/camp-construction-duration` | `build.floor_{applied,skipped,absent}` / `build.preempted_by.` | **build floor 與被 pre-empt** |
| `feat/a1-construction-dispatch-drop` | `root.commit.entered` / `root.commit_drop.*` / `root.funnel.pre_try_set_drop.*` | **紮根 commit 與 try_set 前的掉點** |

★★**四條都沒進 `main`** ⇒ **main 看不見這條漏斗的任何一段。**
★★★**而今天我們問了三次同一個問題**：
①means-end 的「蓋兵器坊」`util` 全場最高卻一次都沒贏 ②紮根從沒走到執行（`41/41` 全卡建材）
③stock 定價接線是活的但世界走不到礦（鏈停在「你沒有工坊」）
⇒ ★**每一次都是從零重新推**，**而答案的儀器早就有人做過了，只是死在 branch 上。**

---

# ★派你：**把這條漏斗的觀測收成一條真正進 main 的 slice**

## ★不要 merge 那四條
它們 base 太舊（最舊 7/26），**merge 會帶進一堆與本題無關的東西** ——
★★**這正是我今天對 `failure-memory` 用的同一條判準：branch 帶的不只是你要的那一顆。**
⇒ ★**從那四條【抄 counter 的設計】，在 main 上重新落地。**

## 範圍（★只做觀測，零決策改動）
| 段 | 至少要能回答 |
|---|---|
| ① **candidate → winner** | 有沒有提出來？提出來的 util 排第幾？**贏了沒？** |
| ② **winner → delegate 路由** | 進了哪個分支（build／facility／convoy／generic）？ |
| ③ **路由 → dispatch** | 有沒有真的派出去？**掉在哪一道閘？**（★這一段今天已有一顆：`dispatch_builder.attempt`） |
| ④ **dispatch → 執行** | `try_set` 前掉點／被 pre-empt／build floor |

★**判準（寫死）**：
1. ★**每一段都要有【分母】** —— **只有失敗計數沒有嘗試計數，就是我們今天在 `33→41` 上踩過的坑。**
2. ★★**`fp` 必須不變**（Probe-gated、零 RNG、不動控制流）—— **變了就是 tap 改了被觀測物。**
3. ★★★**非零證據**：交件時附**一輪實跑**，證明**每一顆 counter 都至少非零過一次**；
   ★**恆為 0 的 counter 要嘛掛錯位置、要嘛那條路不可達 —— 兩種都要在交件裡講明是哪一種。**
4. ★**不要一次做四段** —— **先做 ①②，交一次；③④ 第二次。** 一次交太多，非零證據會變成走過場。

## ★★你可以直接拿那四條當設計參考
```
git diff $(git merge-base main <branch>)..<branch> -- scripts/simulation/
```
★**但抄設計不抄實作** —— **它們寫在舊 base 上，中間那條漏斗已經被改過好幾輪**
（★means-end 接線、`stock` 分支、`state` 改必填都是今天的事）。

---

# ★序
**這條是【下一個 arc 需要的儀器】** —— 那個 arc（**材料經濟 catch-22**）的排序在 blueprint 手上，
★★**但儀器不必等排序**：**三條線已經卡在同一扇門上，而我們每次都在重造尺。**
