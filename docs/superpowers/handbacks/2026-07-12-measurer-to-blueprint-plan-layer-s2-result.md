---
from: measurer
to: blueprint
status: consumed
topic: plan-layer S2(phase導出+偏置term)驗收——determinism CLEAN+0新增SCRIPT ERROR(3pre-existing相符)+TC7 divergence OK+兩phase單元測試PASS；★organic 3mo跑無plan_phase分布probe(僅單元測試涵蓋#1/#2驗收項,無獨立探針)
---

# 量測回報：plan-layer S2（phase 導出 + 偏置 term）驗收

工單：`2026-07-12-implementer-to-measurer-plan-layer-s2.md`。`.worktrees/plan-layer-s2`（feat/plan-layer-s2 @e14f1cb）。

## ①headless——0新增SCRIPT ERROR，TC7/phase測試PASS
- `_test_plan_phase_derive` `[OK]`、`_test_plan_phase_bias` `[OK]`。
- `TC7 divergence OK (3 leader 3 option: ["建設", "貿易", "駐守"])`——霸主/商人/隱士三distinct，裁決B（貿易移出SEEK_FOOD map）生效確認。
- 3個SCRIPT ERROR assert名單與S1同批一致（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`），非本slice新增。

## ②determinism——CLEAN
`WARRING_SEEDS=1337 WARRING_MONTHS=3`（warring_states.json）兩跑，`s2_det1.json`/`s2_det2.json` **byte-identical**。

## ③organic 3mo快照
seed1337：attrition=32.9%，established=0，intent分布{RICH:21, DEFEND:10, FOUND:1, HOLD:1}，g2.ambition_promote=259/demote=238（S1 churn同量級，S2非rung相關slice符合預期無明顯位移）。

## ★無organic phase分布探針
implementer信§驗收法①②項（phase分布≥2種模式/偏置生效）目前**只由implementer自己的單元測試覆蓋**（`_test_plan_phase_derive`/`_test_plan_phase_bias`，皆PASS）——`warring_harness.gd`目前**沒有`plan_phase`/`plan_phase_drive`相關probe key**，我這邊在organic多隊3mo跑裡**看不到**「哪些隊實際落在哪個phase、選了哪個偏置option」的統計。若你要organic層級的phase分布驗證（非單元測試的孤立場景），需implementer/systems加一個`plan_phase`分布probe（比照`rung_dist`模式），我再補跑。目前headless單元測試+determinism+0新增FAIL已算驗收基本盤過。

## 產物
`s2_det1.json`/`s2_det2.json`（determinism）。

## 待你
- 若單元測試+determinism+0新增FAIL已夠判驗收通過，可推merge。
- 若要organic phase分布數字（GROW紮營watch#3、貿易util量級watch#4這類需要跑起來看的項目），需先補probe，我再跑。
