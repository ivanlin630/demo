---
from: measurer
to: blueprint
status: consumed
topic: plan-layer S3(survival-bypass)驗收——determinism CLEAN+0新增SCRIPT ERROR+bypass確有觸發(每seed 4-9次)；★attrition跨輪對比不可靠(各branch base commit不同,非apples-to-apples)，僅回報本輪絕對值
---

# 量測回報：plan-layer S3（survival-bypass）驗收

工單：`2026-07-13-implementer-to-measurer-plan-layer-s3.md`。`.worktrees/plan-layer-s3`（feat/plan-layer-s3 @878c0c5）。

## ①headless——0新增SCRIPT ERROR，S1+S3測試皆OK
`_test_plan_rung_event_driven`[OK]（S1未回歸）、`_test_plan_rung_bypass`[OK]。3個SCRIPT ERROR assert名單同前幾輪一致（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`），非本slice新增。

## ②determinism——CLEAN
`WARRING_SEEDS=1337 WARRING_MONTHS=3`（default.json）兩跑，`s3_det1.json`/`s3_det2.json` **byte-identical**。

## ③organic 3seed×3mo——bypass確有觸發，非死代碼
| seed | attrition | established | crash_bypass觸發 | promote | demote |
|---|---|---|---|---|---|
| 1337 | 38.2% | 0 | **4** | 103 | 96 |
| 42 | 51.4% | 0 | **9** | 85 | 65 |
| 7 | 16.8% | 0 | **8** | 98 | 73 |

`g2.ambition_crash_bypass`三seed皆非0（4-9次/3mo），**bypass機制organic下確實有fire**，非只在implementer單元測試場景才會動。

## ★attrition跨輪對比——不可靠，僅回報本輪絕對值
implementer信§驗收②要求「加bypass後死磕原地減少，對照pre-S3 baseline」。我**沒有可靠的pre-S3同口徑基線**：`.worktrees/plan-layer-s1`（S1單獨,seed1337=22.3%）、`.worktrees/plan-layer-s2`（S1+S2,seed1337=32.9%）跟本輪S3（seed1337=38.2%）**各自base commit不同**（S1/S2 worktree可能fork於forage-floor-tune merge main之前，S3的base已含forage+更多下游變動）——**非同一份「除了S3以外都相同」的對照組**，數字漲跌可能來自任何上游變動疊加，不能歸因於S3本身。

若要嚴謹A/B（S3 on vs off），需implementer/systems指定一個**同base commit、只差S3 on/off**的對照分支給我跑，我才能做有效歸因比較。目前只能誠實回報：**bypass機制存在且organic下有觸發，但無法量化它對attrition的獨立貢獻**。

## 產物
`s3_det1.json`/`s3_det2.json`（determinism），`s3_organic_3mo.json`（organic快照）。

## 待你
- 若「bypass存在且會fire」已夠驗收（機制正確性 vs 量化效果分開判），可推merge。
- 若要量化S3獨立貢獻，需一個同base、僅差S3開關的對照跑法（cherry-pick revert或分支切點對齊），我再補測。
