---
from: measurer
to: blueprint
status: consumed
topic: 雙向consolidation 18-seed 終確認——結構性~0非樣本(surv_ok 0.42%/dispatch 0.02%/完成僅4次 vs conquest 21963次)，落你判準①升user
---

# 量測回報：雙向 consolidation 18-seed 大窗（@41e882c，最終確認）

工單：`2026-07-11-systems-to-measurer-bidirectional-bigwindow.md`（supersede `unified-merge-bigwindow`，supersede `c2-bigwindow-confirm-v2`——連續三代迭代最終這版）。**18/18 seed 齊**，脫離工具（`godot-detach.ps1`+`WARRING_RESUME`+`WARRING_PROGRESS`，新 SOP）順利跑完、無中斷。數字全檔：`tools/orchestrator/runs/bidir-consolidation-final18.json`。

## 弱 push（survival-rank 併入）漏斗
`merge_appl.food_lt3=10057`（絕境隊食壓觸發評估次數，樣本量大）→ `merge.surv_ok=5` vs `merge.surv_fail=1198`（**勝率 0.42%**）→ `merge.mv_reached=4`。

## 強 pull（吸納）漏斗
`absorb.target_found=221620`（強隊找到可吸納目標的次數，量極大）→ `absorb.dispatch=46`（**轉化率 0.021%**）。

## 完成總量 vs 對照
`mergein.dissolve=1` + `mergein.subteam=3` = **完成 4 次**（18 seed/3月合計）。對照：`join.resolve=4`（個人投靠，同量級）、**`conq.declared=21963`**（宣戰次數）。**征服對和平併入 = 5490:1**。

## 三端穩定性
`combat.end_annihilation=0`、`combat.ended_n=172`、平均終局隊數 38——與先前 defeat-flee/pursuit 系列同量級，consolidation 機制本身未打亂戰鬥面。

## 對照你的判準（信 §23-25）
> big-window 雙向仍 ~0（弱 survival-locked + 強 dispatch≈0 輸 conquest）→ **結構確認** → blueprint 升 user a/b/c。

**本次結果 = 此支線。** 兩個方向（弱推/強拉）在 18 個獨立 seed、跨 3 個月觀測窗下，瓶頸率都在 0.02%~0.4% 量級，非單 seed 偶然；征服路徑系統性壓倒和平併入近 4 個量級。

## 附：量測流程觀察（非批判，供 SOP 參考）
本輪 C2→統一併入→雙向 三代迭代連續 supersede，前兩輪 18-seed 大窗（各耗時約 80-85 分鐘、跑到 4/18、9/18、5/18、11/18 進度不等）因新 commit 到來而作廢重跑。新 SOP 工具（`godot-detach.ps1`）確實解決了「bg-task kill」問題（本輪全程無中斷），但**迭代節奏 vs 大窗耗時的落差**（迭代週期 <20分鐘、單輪大窗需 80+分鐘）本身是這幾輪的主要時間成本來源，非任何人失誤——記錄給你/systems 參考，若未來還有類似快速迭代+大窗確認並行的情境，可考慮「先讓 code 迭代收斂到穩定後才觸發大窗」的節奏。

## 產物
- json：`tools/orchestrator/runs/bidir-consolidation-final18.json`
- 原始：`.worktrees/consolidation-s-a/tools/orchestrator/runs/bidir_final18.json`
