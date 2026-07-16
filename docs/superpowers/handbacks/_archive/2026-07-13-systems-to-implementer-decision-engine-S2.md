---
from: systems
to: implementer
status: consumed
topic: [dispatch·S2] 決策引擎重構 slice 2：coeff表+rank接入+plan_phase原子退役+§6標籤——R②CLEAN，照 plan TDD
---

# Dispatch：decision-engine 重構 S2（架構原子切換）

## 前置
- **計畫** `docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md` **# Slice 2**（S2.1~S2.6，逐 task bite-sized TDD，plan 有完整 code）。R②CLEAN(`reviewer-to-systems-decision-engine-S2-r2-verdict`)。
- **worktree**：`feat/decision-needs-hierarchy`（S1 已 merge 進 main → **先 rebase/merge main 進 branch 拿 S1 code**，或新開 branch 基於最新 origin/main。確認 branch 含 S1 的 NeedHierarchy）。code 寫 worktree、handback 寫 main mailbox 絕對路徑 `A:\GDS\demo\docs\superpowers\handbacks\`。

## 做什麼（6 task，spec §8：五層上線+plan_phase退役**同 slice**，不留並存過渡）
- **S2.1** `NeedHierarchy.AFFINITY` 純靜態 const 表(23×5,行和≈1)+`affinity_of`。TDD `_test_need_affinity_table`。
- **S2.2** `consistency_coeff(opt,urgency,leader_values)→float`（alignment×人格陡度,FLOOR=0.15 軟降權）。TDD `_test_need_coeff`。
- **S2.3** `rank_scored_ctx` util ×= coeff（全 23 統一，**乘在 COMMITMENT_BONUS 前**）。TDD `_test_rank_coeff_applied`(wiring 不炸)。
- **S2.4** `narrative_label`(argmax)→team.plan_phase（GUI 來源改接）。TDD `_test_need_narrative_label`。
- **S2.5** plan_phase **完整退役**：terms.gd eval+weight 移 `plan_phase_drive`；options.gd 6 REGISTRY row 移 `["plan_phase_drive","plan_phase_drive"]`(覓食/返家補給/併入/紮營/外交/買糧)；decision_context.gd 刪 PHASE 常數+plan_phase_drive_map+derive_plan_phase+_phase_option_bias+gather 三行(team.plan_phase 欄保留,S2.4 由 narrative_label 寫)。TDD `_test_plan_phase_retired`。
- **S2.6** warring_harness probe(全 23 覆蓋+coeff 分布) + 融合閘。

## 硬約束
- **§3 純靜態表**：AFFINITY=const Dict，`consistency_coeff` 零動態分支（唯一迴圈=固定 5 層加總）。
- **零 randf**；coeff **乘在 COMMITMENT_BONUS 之前**。
- **退役無殘引用**：改完 grep `plan_phase_drive|derive_plan_phase|_phase_option_bias|PHASE_SEEK_FOOD|PLAN_PHASE_DRIVE_MAG`，sim code 零引用。
- **reviewer 提醒**：`observer_inspect_test.gd:74` 有測試手動賦 team.plan_phase（非 production）——若該測試斷言撞退役語意(舊 plan_phase 值)則同步調測試,production 邏輯不動。
- 逐 task commit（尾 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`）。

## 回報
6 task 完 + 融合閘綠 → handback to:measurer。**驗收(spec §驗收)**：全面覆蓋(刻意製造某層急迫→原本無 bias 的 12 option 分數變化)、行為連貫性(同隊不搖擺,organic multi-seed)、determinism(same-seed byte-identical)、軟降權不死鎖(baseline 觀察)。有 blocker(plan 設計 bug/接點語意不符)→ handback to:systems，別自改設計。
