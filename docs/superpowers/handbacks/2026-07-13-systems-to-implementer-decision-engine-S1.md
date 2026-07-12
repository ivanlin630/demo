---
from: systems
to: implementer
status: consumed
topic: [dispatch·S1] 決策引擎重構 slice 1：五層急迫度感測基礎設施(inert)——R②CLEAN，照 plan TDD
---

# Dispatch：decision-engine 重構 S1（五層急迫度感測基礎設施，inert）

## 前置
- **計畫**：`docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md`，做 **# Slice 1** 三 task（S1.1/S1.2/S1.3）。R②CLEAN(`reviewer-to-systems-decision-engine-S1-r2-verdict`)。
- **spec**：`docs/superpowers/specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md`（背景，R①R②已CLEAN）。
- **worktree**：`feat/decision-needs-hierarchy` 基於 `origin/main`（main 已 push 到含 plan commit，base 新鮮）。code 寫 worktree、handback 寫 **main mailbox 絕對路徑** `A:\GDS\demo\docs\superpowers\handbacks\`。

## 做什麼（照 plan bite-sized TDD，逐 task commit）
- **S1.1** 建 `scripts/simulation/decision/need_hierarchy.gd`：`class_name NeedHierarchy`，layer 常數(L_SURVIVAL=0..L_ACTUAL=4/N_LAYERS=5) + `compute_raw(state,team,food_days,threat)→PackedFloat32Array[5]`（5 層 raw 急迫度公式，plan 有完整 code）。TDD `_test_need_raw_urgency`。
- **S1.2** EWMA `ewma_update`(α=0.25) + `team.need_urgency: PackedFloat32Array` 持久欄。TDD `_test_need_ewma`。
- **S1.3** gather 尾每 cadence 更新 need_urgency + ctx 快照欄。TDD `_test_need_gather_updates`。**inert**：不接 rank_scored、不碰 plan_phase。

## 硬約束（融合閘 + determinism）
- **inert 保證**：本 slice `rank_scored_ctx` 不讀 need_urgency，`rank()` 須 byte-identical。S1.3 Step 5 跑融合閘（headless 無新 FAIL / constitution PASS / multi 無崩潰）證零行為變。
- **零 randf**：compute_raw/EWMA 純算術。
- **PackedFloat32Array 型別**：need_urgency 持久欄 size 5 或 0(冷啟)；ewma_update 處理 prev 空。
- 逐 task commit（訊息尾 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`）。

## 回報
S1 三 task 完 + 融合閘綠 → handback to:measurer（determinism inert 驗：same-seed byte-identical + need_urgency 五層更新；organic 不需，零行為變）。有 blocker(plan 有設計 bug/接點語意不符)→ handback to:systems，別自行改設計。
