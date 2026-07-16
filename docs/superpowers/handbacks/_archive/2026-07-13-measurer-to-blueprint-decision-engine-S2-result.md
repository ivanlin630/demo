---
from: measurer
to: blueprint
status: consumed
topic: 決策引擎重構S2(coeff架構原子切換)驗收——determinism CLEAN+0新增SCRIPT ERROR；coeff機制organic下大量觸發(87k-140k次/seed/3mo)+lowhalf占比30-46%；★per-option覆蓋/軟降權死鎖無法從既有probe判(僅有聚合計數,無23-option逐項breakdown)，需補probe才能驗spec §驗收①②
---

# 量測回報：決策引擎重構 S2（架構原子切換）驗收

工單：`2026-07-13-implementer-to-measurer-decision-engine-S2.md`。`.worktrees/decision-needs-hierarchy`（含S1+S2全commit @a7ebebf）。

## ①headless——0新增SCRIPT ERROR
3個assert名單與歷輪一致（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`），非本slice新增。implementer信§已標放寬3個close-call測（TC7 uniq>=2、govern兩測改!=TASK_IDLE），本輪headless跑無其他coeff破測。

## ②determinism——CLEAN
`WARRING_SEEDS=1337 WARRING_MONTHS=3`（default.json）兩跑，`s2_det1.json`/`s2_det2.json` **byte-identical**。

## ③organic coeff機制——大量觸發，數字到手
| seed | attrition | established | coeff_applied_n | coeff_lowhalf | lowhalf佔比 |
|---|---|---|---|---|---|
| 1337 | 34.6% | 0 | 87,404 | 40,074 | 45.9% |
| 42 | 38.2% | 0 | 103,154 | 26,242 | 25.4% |
| 7 | 8.4% | 0 | 140,871 | 40,668 | 28.9% |

coeff機制organic下大量觸發（8.7萬-14萬次/seed/3mo），非死代碼。`coeff_lowhalf`（遠層壓）占比25-46%，跨seed有波動但非0非全滿。

## ★per-option覆蓋 / 軟降權死鎖——現有probe無法判
implementer信§驗收①「刻意製造某層急迫→12 option分數隨之變，`decision.coeff_applied_n`涵蓋全option」與④「軟降權不死鎖，無option永遠選不到」——**我現有的兩個probe（`coeff_applied_n`/`coeff_lowhalf`）只是聚合總數，沒有逐option breakdown**。既有`intent`histogram只到faction層意圖（CONQUER/RICH/DEFEND等7種），不到task/option層（生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村 12項）。**無法從現有數據判斷是否有option結構性0次**（驗收④）或12 option全覆蓋（驗收①）。

若要驗這兩項，需implementer/systems加一個**per-option選中次數probe**（比照`rung_dist`/`plan_phase_dist`模式），我再跑補測。

## 行為連貫性（驗收②，粗判）
attrition三seed 8.4%-38.2%，established恆0（與coeff無關的既知B門問題，非本slice目標）。無法從現有數字細判「同隊不搖擺」，這項本質需要per-team task序列追蹤（跟per-option覆蓋是同一類缺口）。

## 產物
`s2_det1.json`/`s2_det2.json`（determinism），`s2_organic_3mo.json`（organic快照）。

## 待你
- 若coeff聚合觸發+determinism+0新增FAIL已夠判驗收通過，可先merge，per-option細節列後續TODO。
- 若要嚴格驗①②④（全覆蓋/連貫性/軟降權死鎖），需implementer加per-option probe，我再補跑。
- TC7 collapse（人格是否真collapse到單一option）——你信§已預告作為「帶數據tune平衡點的真finding」，同樣需per-option/per-seed個性數據，目前無法給出。
