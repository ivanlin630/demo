---
from: systems
to: measurer
status: open
topic: C2 big-window 確認 marginal 結構非樣本——survival-rank%/accept/gate#1 逐站→to:blueprint
---

# 量測工單：C2 big-window 確認（marginal 結構 vs 樣本）

（前一封 `c2-bigwindow-confirm` 誤投佔位，以本封為準。）

C2 機制正確（`mv_reached` 0→1，priority 覆寫解）但 3mo 單 seed marginal（整併 survival-rank 罕勝 2.5%=19/772、merge_accept=0、join 蓋同 niche）。**big-window 確認 marginal 是結構非樣本**（觸 blueprint 決策樹 marginal 支→升 user，須先實證非 1-seed fluke）。

## 跑（★用長跑 tooling，別撞 bg-task kill）
- worktree `feat/consolidation-s-a @34034bb`（S-A 全 + C2 + 6 層漏斗探針）。**先 rebase/merge 最新 main 拿新 bed**（resume/detach/progress；否則載舊 bed）。
- **脫離啟動 `tools/godot-detach.ps1` + `WARRING_RESUME=1` + `WARRING_PROGRESS`**（03b SOP §大窗）：18 seed×3mo 單批脫離跑、輪詢、死了 resume 接。seed=1 先估耗時。★禁原地 checkout；`--path .worktrees/consolidation-s-a`。

## 量（6 層漏斗逐站 + gate）
- `merge_appl.food_lt3`→`merge.surv_ok/surv_fail`（整併 survival-rank 勝率%）→`mv_reached`→`pair_seen`→**`merge_accept`**。
- **gate#1 非搬餓**（每 accept 事件 combined_days≫joiner 原餘命、absorber surplus>0）+ **隊數不崩塌**（隊總數/最大隊 pop 佔比）+ 三 gate + churn + determinism。
- **對照 join**（`join.resolve`/`consol.accept_n`，證 join 蓋同 niche 常勝）。

## 判準（你出數字，blueprint 判決策樹）
- big-window 整併 survival-rank 仍 ~2.5% + merge_accept≈0 → **marginal 結構確認** → to:blueprint 升 user 願景 fork。
- big-window 整併 accept 顯著>0（隊漸大/gate#1/不崩）→ 有機政體交付 → to:blueprint signoff。
數字 to:blueprint。
