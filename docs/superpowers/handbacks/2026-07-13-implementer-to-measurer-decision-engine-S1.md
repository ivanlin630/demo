---
from: implementer
to: measurer
status: consumed
topic: 決策引擎重構 S1 交付 — 五層急迫度感測(inert);branch feat/decision-needs-hierarchy已push,待determinism inert驗
---
# Hand Back: 決策引擎重構 S1（五層急迫度感測基礎設施，inert）

branch `feat/decision-needs-hierarchy`（已 push，疊 origin/main ab3a118）。plan `docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md` **Slice 1**（三 task 逐 commit）。

## 實作摘要
- **S1.1** `scripts/simulation/decision/need_hierarchy.gd`（新）：`class_name NeedHierarchy`，layer 常數（L_SURVIVAL=0..L_ACTUAL=4/N_LAYERS=5）+ `compute_raw(state,team,food_days,threat)→PackedFloat32Array[5]`（五層 raw 急迫度 0..1 越缺越高，純算術零 randf）。TDD `_test_need_raw_urgency` PASS。
- **S1.2** `ewma_update(prev,raw)`（α=0.25，冷啟 prev 空視全 0）+ `TeamData.need_urgency: PackedFloat32Array`（size 5 或 0 冷啟，持久）。TDD `_test_need_ewma` PASS。
- **S1.3** `decision_context.gd` gather 尾每 cadence 更新 `team.need_urgency` + `c.need_urgency` 快照欄。**inert**：`compute_raw` 只寫不讀決策，不接 `rank_scored`、不碰 `plan_phase`。TDD `_test_need_gather_updates` PASS。

## ★inert 驗（融合閘全綠）
- **determinism byte-identical**：`WARRING_SEEDS=1337 WARRING_MONTHS=1` 兩跑 `cmp` **完全相同** → need_urgency 只寫不讀 → `rank()` 零變（inert 保證成立）。
- **constitution PASS**（sites=29，removed=0）。
- **multi sanity**：`game_sim_multi` 4 config（game_sim_test/tyrant/merchant/warzone）跑完，**0 SCRIPT ERROR、無崩潰**。
- **headless**：3 新 test 全 PASS，**0 新增 SCRIPT ERROR**（3 pre-existing `_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，同 main baseline）。

## 待驗收（plan S1 §交付）
1. **determinism inert**：same-seed byte-identical（我已初驗 1seed×1mo；你擴 seed/月確認 rank 零變）。
2. **need_urgency 五層更新**：gather 後 team.need_urgency size 5 + EWMA 累積（不重置）。
3. **organic 不需**（零行為變，純感測器 online）。

## 連動風險 / 註
- 純 inert 感測器：本 slice 無行為變（S2 才接 rank_scored + plan_phase 原子退役）。
- PackedFloat32Array 型別：need_urgency size 5 或 0（冷啟），ewma_update 處理 prev 空。
- 序：S1 merge 後 systems dispatch S2（一致性係數表 + rank_scored 接入 + plan_phase 退役）。
