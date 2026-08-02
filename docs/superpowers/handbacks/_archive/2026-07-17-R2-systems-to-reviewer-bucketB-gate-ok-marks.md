---
from: systems
to: reviewer
status: consumed
topic: "[R②·低優先於 seam#1] Bucket B gate-ok 批標提案:54待閘的 GUARD+world-mechanic 子集標 legit(投 constitution_baseline_v2.txt)。對抗雙向=請查我有無 over-mark（把真行為閘當 legit 藏掉，血證閘4/閘6 我曾 over-reach）。CLEAN→我 apply 標+跑 gate 綠證零殘留。facility cluster 已 route seam#2、照妖鏡候選 defer 序5，不在本批。"
---

# R②：Bucket B gate-ok 批標提案（對抗雙向查 over-mark）

## 背景
54 待閘全 triaged（`docs/superpowers/54-triage.md`）。Bucket B（investigator 抓 56 rows/18 func + systems 逐條判）分三：**B-legit(本批標)** / B-facility(route seam#2) / B2 照妖鏡候選(defer 序5)。本 R② 只審 **B-legit gate-ok 批標**——投進 `scripts/debug/constitution_baseline_v2.txt` 加 `# gate-ok:` 註，跑 constitution_gate 綠=證這批零殘留。

## 提案標 gate-ok（詳表+每項 file:line 條件見 54-triage.md「B-legit」段）
1. **GUARD**（null/empty/cadence-throttle/in-flight/player-skip=純資料守衛，非決策）：`_calc_diplomacy_score`、`_consider_extraction`(guards)、`_evaluate_infrastructure`(guards)、`_evaluate_independent_infrastructure`、`_evaluate_new_outpost_location`(candidates empty)、`_evaluate_outpost_residency`、`_evaluate_owner_contact`(guards)、`_evaluate_storage_visit`(guards)、`_trigger_defection_evaluation`、`_trigger_survival`、`_evaluate_independent_strategy`(guards)、`to_task`(IDLE fallback)。
2. **world-mechanic 閾**（世界規則非行為 gate）：outpost level cap 3、OUTPOST_TAKEOVER_DAYS 占領 timer、CONTACT_TIMEOUT_DAYS cadence、envoy timeout 2day(latch-timeout 守 invariant①)、tools>=3 材料需求、DISPATCH_DIST_THRESHOLD(=probe bookkeeping 非 option 選擇)、storage needed*2.0 庫存 housekeeping。

## ★對抗雙向：請重點查我 over-mark
血證:我(systems)曾把閘4(randi=ID-gen)/閘6(已軟 util)over-reach 當違規；**反向風險同在=把真行為閘當 legit 標掉=藏殘留閘=zero-residual 假綠**。請逐項質疑：
- 有無哪個「GUARD」其實藏決策（e.g. early-return 前有隱性人格判斷選擇路徑）？
- 有無哪個「world-mechanic 閾」其實 pre-empt 人格決策（照妖鏡）而我誤放行？特別 `_consider_extraction` 我判 guards=legit 但 extract_score>0.4 已列 B2 照妖鏡候選——同函式雙性質，確認我沒把該候選的閾也順手標掉。
- `_evaluate_storage_visit needed*2.0` / `_evaluate_infrastructure outpost_level>=3` 邊界:真 world-rule 還是 tuning const？

## 判準
- CLEAN（含「這批確為 legit 無 over-mark」）→ 我 apply 標 + 跑 `constitution_gate.gd` + 貼綠證。
- 揪出 over-mark → 該項移出本批（→ B2 照妖鏡 or 逐 code 再驗），halt 回 systems file:line。

## 優先序
**低於 seam#1 R² REVISED**（那個 unblock S1 dispatch，先）。本批不急，reviewer 依序處理即可。

## 溯源
`54-triage.md`；constitution_gate v2 baseline（91 閘 zero-residual 目標）；[[feedback_fileline_vs_interpretation]] 對抗雙向；[[project_unification_matrix]] 零殘留閘=硬驗收。
