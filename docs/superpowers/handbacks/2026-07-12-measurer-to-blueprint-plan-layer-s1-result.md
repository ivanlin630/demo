---
from: measurer
to: blueprint
status: consumed
topic: plan-layer S1(rung事件驅動化)驗收——determinism CLEAN+0新增SCRIPT ERROR(3個pre-existing核對相符)+churn/rung_dist數字到手；★無同口徑舊瞬時版基線可比churn降幅(新probe)
---

# 量測回報：plan-layer S1（rung 事件驅動化）驗收

工單：`2026-07-12-implementer-to-measurer-plan-layer-s1.md`。`.worktrees/plan-layer-s1`（feat/plan-layer-s1 @b042877）。

## ①headless——0新增SCRIPT ERROR，3個pre-existing核對相符
跑`headless_test.gd`，`_test_plan_rung_event_driven` `[OK]`、`ambition rung climb OK`。3個assert名單與implementer信一致：
- `_test_p2a_survival_terms`（join weight太低0.41）
- `_test_beg_join_social_resolve`（戰鬥中197擋不resolve）
- `_test_strategic_reads_ladder`（rung擴張+武力未選擴張intent）
三者皆與implementer報備一致，非本slice新增。

## ②determinism——CLEAN
`WARRING_SEEDS=1337 WARRING_MONTHS=3`（warring_states.json）兩跑，`rung_det1.json`/`rung_det2.json` **byte-identical**。

## ③churn + rung分布（新probe，絕對值）
seed1337，3mo，warring_states.json：
- `g2.ambition_promote`=290，`g2.ambition_demote`=258
- `rung_dist`（最終快照）：r0=33 / r1=13 / r2=6 / r3=1 / r4=0
- attrition=22.3%，established=0（établissement與本slice無關，未變）

★**沒有同口徑舊瞬時版churn基線可比**——`g2.ambition_promote`/`g2.ambition_demote`是本branch新增probe，舊main分支無此欄位可回溯對照「事件驅動化前」churn次數。implementer信§驗收法要「同seed churn變更總次數，事件驅動應<<瞬時版」——**我這邊給不出對照組數字**（除非另跑舊main一份同款probe，但舊main沒有這兩個probe key，無法apples-to-apples比）。若你/systems需要量化降幅，需implementer在舊main版本也埋同款probe（或用其他既有間接指標，如`reaction.P4_expand`/intent histogram波動幅度代理）。

## 產物
`rung_det1.json`/`rung_det2.json`（determinism，含probe+rung_dist）。

## 待你
- churn降幅若要量化對照，需補基線probe（我可代跑，需implementer/你指定怎麼在舊版本埋同款key，或指定替代代理指標）。
- 若不需要量化降幅，僅要「新版可運作+determinism+0新增FAIL」即視為驗收通過，可直接推merge。
