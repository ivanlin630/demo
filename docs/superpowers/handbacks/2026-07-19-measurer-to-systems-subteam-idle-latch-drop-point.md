---
from: measurer
to: systems
status: consumed
topic: "[drop 點定位·主嫌#3 CONFIRMED] subteam-idle-latch root = 1727-1728 arrive→merge_queue + loop2b 760-763 release。覓食 subteam 抵達 forage tile(move_target=-1,task≠IDLE)→1728 merge_queue→loop2b parent 不同格→release→IDLE→下 cadence 再派覓食→已在該 tile 秒到→再 release。THRASH,食物流不進。drop 計數 ARRIVE_MERGEQ 337≈LOOP2B_RELEASE 346(1:1 振盪),CADENCE_GATE 249(idle 間隔),DISCIPLINE 3(非因)。team73 逐 tick 血證:停在(26,9)覓食,parent(25,6),每~100-200t 抵達即被召回。1727 把『抵達 forage 目的地』誤當『歸建抵家』。標 9a915fe7(subteam 路同 980e0b1c)。"
measured_at_head: 9a915fe7
---

# subteam-idle-latch drop 點定位：主嫌 #3 CONFIRMED

你 4 候選中 **#3（覓食 arrive→歸建 release→IDLE thrash）坐實**，非 cadence/discipline/try_set-fail。

## drop 計數（seed1337 8mo，committed=覓食 subteam gated 探針）
| drop 點 | 次數 | 判 |
|---|---|---|
| **ARRIVE_MERGEQ**（:1728） | **337** | 主 |
| **LOOP2B_RELEASE_TO_IDLE**（:761） | **346** | 主（≈1:1 振盪） |
| CADENCE_GATE_IDLE（:1772） | 249 | 症狀（thrash 週期間 idle 等 cadence） |
| DISCIPLINE_DETACH（:1724） | 3 | 非因 |

ARRIVE_MERGEQ ≈ LOOP2B_RELEASE（1:1）＝振盪指紋。cadence gate 249 是 thrash 週期間 IDLE 等下次決策（＝lockpoint 抓到的「idle+committed=覓食」快照），非 root。

## team73 逐 tick 血證（raw: `docs/measurements/2026-07-19-subteam-idle-latch-trace-9a915fe7-1337.txt`）
```
tick=18000 tid=73 ARRIVE_MERGEQ task=覓食 move=-1
tick=18000 tid=73 LOOP2B_RELEASE_TO_IDLE parent_not_colocated sub_tile=(26,9) parent_tile=(25,6)
[SubAI] Team73 引擎→覓食           ← 再派覓食
tick=18100 tid=73 ARRIVE_MERGEQ task=覓食 move=-1   ← 已在(26,9),秒到
tick=18100 tid=73 LOOP2B_RELEASE_TO_IDLE ...          ← 又召回
tick=18110-18220 CADENCE_GATE_IDLE next=18250          ← idle 等 cadence
tick=18300 ARRIVE_MERGEQ→RELEASE→...（週期重複到 18800+）
```
team73 全程停在 forage tile (26,9)，parent 在 (25,6)/(24,7) 不同格。**每次抵達 forage tile 即被 loop2b 召回 IDLE，覓食任務從不在 tile 執行 → 食物流不進 → committed=覓食+would_succeed=true 卻 idle 坐死。**

## root（交你 spec 修）
`:1727` `if sub.move_target == Vector2i(-1,-1) and sub.current_task != TASK_IDLE: merge_queue.append; return` —— **把「抵達 forage 目的地（move_target 到達清 -1）」誤當「歸建抵家該 merge」**。覓食是「到目的地工作」語意（該留在 tile 覓食），非「回母團」。1727 一律送 merge_queue → loop2b 見 parent 不同格 → release → 召回。∴ **覓食/survival-work task 抵達目的地不該進 merge_queue**（該留下執行），只有 lifecycle-歸建（歸建 option/無 task）才 merge。

## 判準/建議（patch-gate-first）
這是**補丁閘型**：1727 的 arrive→merge 無條件對「非-IDLE 抵達」fire，pre-empt 掉覓食執行。修 = 1727 排除 survival-work task（覓食等在目的地工作的 task），別讓它們被當歸建召回。細節你 spec（我只定位 drop 點，不下 code 定案）。

## 可溯源
measured_at_head `9a915fe7`（transition merged 後 lineage ≥980e0b1c；subteam 決策路 line refs 1724/1727/1772/1808 與你 980e0b1c 一致，路未變）。instrumentation 純 print gated(committed=覓食)、determinism-safe、跑完 `git checkout` 還原、faction_ai clean。trace raw 見上檔（1150 行 STDROP+SubAI）。

## 下一站
你 spec 修（1727 排除 survival-work arrive）→ R² → dispatch。手不聽腦 mini-arc 第 3 種 root 定位完。
