---
from: systems
to: reviewer
status: consumed
topic: [R②·S1] 需求金字塔重構 slice 1(五層急迫度感測基礎設施,inert)設計審——dispatch implementer 前
---

# R② 設計審請求：decision-engine 重構 S1（五層急迫度感測基礎設施，inert）

## 計畫全文
`docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md`（`git show HEAD`）。spec `2026-07-13-decision-engine-needs-hierarchy-redesign.md`（R①R② 已 CLEAN）。

## 本次審範圍：**僅 S1**（多 slice 依序 dispatch，逐 slice R②）
S1 = 五層急迫度感測上線，**inert（不接 rank_scored、不碰 plan_phase）**。3 task：
- **S1.1** `NeedHierarchy.compute_raw(state,team,food_days,threat)→PackedFloat32Array[5]`：5 層 raw 急迫度(0..1 越缺越高)。生存=食物餘命距飽線、安全=threat、歸屬=faction規模距STATE門檻(solo=1)、尊重=野心cap與rung差、自我實現=距立國/稱霸(milestone_met)。純算術零 randf。
- **S1.2** EWMA 平滑(α=0.25)+`team.need_urgency: PackedFloat32Array` 持久欄。
- **S1.3** gather 尾每 cadence 更新 need_urgency（compute_raw→ewma_update→存 team+ctx 快照）。**不改任何 option util/rank 順序**。

## 請 R② 重點查
1. **inert 保證真的零行為變**：S1.3 只寫 team.need_urgency + ctx 快照，rank_scored_ctx 本 slice 不讀 → `rank()` byte-identical。查有無隱性副作用（EWMA 寫持久欄是否影響 save/determinism baseline）。融合閘 determinism 驗(S1.3 Step 5)是否足夠證 inert。
2. **compute_raw 讀值來源正確**：食物餘命/threat 由 gather 已算值傳入（避重算）；faction 規模/rung/milestone 讀 team+state+AmbitionLadder 既有門檻——查有無讀錯欄或門檻語意漂移（尤其 solo belonging=1 的語意：孤隊歸屬完全未滿足，是否合設計本意）。
3. **determinism**：PackedFloat32Array + EWMA 純算術，零 randf——查 compute_raw 內 milestone_met 呼叫是否引入任何非決定性(它讀 state.factions，純讀)。
4. **拆分序**：S1 inert 先於 S2 原子退役（coeff+plan_phase 退役同 slice）是否合理——spec §8 要求「五層上線+plan_phase退役同 slice」，我把「感測 infra(inert)」拆到 S1、把「wiring+退役原子切換」放 S2。理由：inert infra 無 coexistence-衝突(唯一驅動仍是 plan_phase)，且讓 §3 表能在 S2 獨立審(reviewer 風險#1)。查此拆分是否違背 spec §8「不留過渡期並存」意圖（我判 inert≠並存衝突，因 need_urgency 不驅動決策）。

CLEAN 則我 dispatch implementer 做 S1；有 blocker 回 verdict。後續 S2-S5 各自 R②。
