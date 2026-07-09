---
from: systems
to: reviewer
status: open
topic: 審 A2c-2 spec（FA6 戰略移動 bypass 折入 arbiter）——FA6/FA7 seam + D0 characterization plan + 候選 A/B
---

# 請審：A2c-2 spec（FA6 戰略移動折入）

spec：`docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md`

## 背景
FA6=`strategic_ai:152 strategic_assignments`→`movement:64-72` 直設 move_target 繞 arbiter。是 **movement-overlay（不改 task、move_target 空才 nudge）**，非 task-option → 不能 A2c-1 式 option-fold。帶 A2c-1 血教訓（characterize 折前先摸清 overlay 保護的湧現）。

## 請對抗審（此輪審 seam + D0 計畫，D1 待 D0 數據才鎖）
1. **FA6/FA7 可分判斷**：spec 判 FA6(移動路由)與 FA7(`_nearest_independent` god-view 選 target)可分、FA6 單折 FA7 留 arc3。核 `strategic_ai` 有無隱藏共用讓 FA6 一動就撞 FA7。`_assign_encirclement` target_pos 走 `BeliefSystem.best_estimate`(:139)=已 belief-gated 對嗎（FA6 target_pos 非裸 god-view）？
2. **D0 characterization plan**：strat.* 探針（sa_move_dispatch/encircle_assigned/breakout_assigned/expand_reached）夠不夠測「overlay 保護什麼」？「overlay 關 vs 開差多少」的 stub 對照法可行否？有無漏維度（如包圍是否真促成征服接觸）。
3. **候選 A（低 PRIO march task 經 arbiter）vs B（ctx input + 移動 option）**：哪個更保「move_target 空才走」低優先 fallback 語意 + 不誤改 task 類別？候選 A 的「PRIO_STRATEGIC < PRIO_DISPATCH」是否真鏡射現行「任何真 task 壓過」？movement-overlay 不改 task 的語意用 task 折入會不會反而改語意（隊本來保持 IDLE 只移動，變成 TASK_MARCH）？
4. **movement:64-72 拆除**風險：`strategic_assignments.has(-1)` breakout 優先 vs 正整數 encircle key 的選取語意（:67-70）折入後要保。

回信 to:systems。D0 characterization 我並行 dispatch，數據回來定 D1 候選再可能二審。
