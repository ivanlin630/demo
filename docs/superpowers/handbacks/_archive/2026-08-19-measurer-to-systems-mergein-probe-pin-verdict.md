---
from: measurer
to: systems
status: consumed
topic: mergein-probe-pin-verdict
---

# churn probe pin答案：(b) arrival-never——committed但joiner從沒到host

ticket:`2026-08-19-systems-to-measurer-mergein-probe-pin.md`
數字全落地:`docs/measurements/2026-08-19-mergein-probe-pin.measure.json`
床：原3mo popcap輪的bed沒印這三個probe（補印在跑完之後），另開2個月短局（同seed/config）補跑，`feat/agriculture-b`(70a5d0cd)。

## 三數

| probe | count |
|---|---|
| `join.resolve`（_resolve_join真fire） | **7** |
| `accept.join_accept` | 7 |
| `accept.join_reject` | 11 |
| `mergein.dissolve`（真滅團） | 1 |
| `mergein.subteam`（附庸化） | 6 |
| `merge.surv_ok`（survival路committed成功，含所有survival option非只併入） | 588 |
| `merge.surv_fail` | 685 |

## 答案：(b) arrival-never

`join.resolve`（2個月僅**7次**，外推3個月約10-11次）**遠遠小於**原3mo輪測到的`SurvivalMergeIn`commit次數（698次）——比例約1.4%。也就是說，一個隊commit去併入某host（`TaskArbiter.try_set`成功、印出`[SurvivalMergeIn]`）跟這個併入**真正resolve**（joiner移動到host tile觸發`_resolve_join`）之間，有巨大的落差。

`accept.join_reject`=11跟`join.resolve`=7同量級，不是主導——host拒絕(c)存在，但不是churn的主因。真正的落差在「commit到任務」（數百次）vs「真正resolve」（個位數）之間，指向：**joiner大多數時候從未真正移動抵達host所在tile**，每個cadence重新評估survival選項時又重新commit同一個（或另一個）併入target，如此反覆——這正是(b) arrival-never。

## 附帶發現

即使在少數真正resolve的join（7次）裡，`mergein.dissolve`只1次、`mergein.subteam`6次——多數併入結果是變附庸非真消失。但這是resolve之後的分流結果，不是churn的成因。

## 建議修復方向

churn的根因不在`_resolve_join`/`_resolve_mergein`本身（這條路真正走到時運作正常），是在**上游**：`TaskArbiter.try_set`成功commit後，joiner隊的實際MOVEMENT執行是否真的朝host移動、以及下個cadence重新評估時是否會（不必要地）打斷/重新選擇target，導致永遠走不到「共位觸發`_resolve_join`」那一步。建議查`faction_ai_system.gd:4863`那個survival路的task dispatch之後，movement層有沒有真的接手執行、跟每次cadence重評的頻率是否比移動到達所需時間短（後者若是，等於還沒走到就被重新argmax蓋掉，這是本session已知的「手不聽腦」/committed-but-never-resolves病灶家族典型模式）。

## 收尾

temp tap（`population_system.gd`的`popcap.*`，已在上輪revert過、此輪重加又revert）+ `agri_b_popcap_bed.gd`revert/刪中，完成後`--headless --import`確認乾淨編譯。
