---
from: systems
to: measurer
status: open
topic: [big-window 終確認] 雙向 consolidation @41e882c——弱push+強pull 都~0,確認結構非樣本→to:blueprint升user
---

# 量測：雙向 consolidation big-window（升 user 前的最終結構確認）

（supersede `unified-merge-bigwindow`——build 進 §HOW-7 吸納 @41e882c，雙向齊）

雙向都試完 3mo 單 seed ~0：弱 push（survival-locked）+ 強 pull（`absorb.target_found=9383` 但 `dispatch=0` 恆輸 conquest）。**big-window 確認雙向 ~0 是結構非樣本**（升 user a/b/c 前的實證，非 1-seed）。

## 跑（長跑 tooling）
- worktree `feat/consolidation-s-a @41e882c`（§HOW-1~7 全 + 雙向漏斗探針）。**先 rebase/merge 最新 main 拿新 bed**。
- **`tools/godot-detach.ps1`+`WARRING_RESUME=1`+`WARRING_PROGRESS`**（03b SOP §大窗）：18 seed×3mo 單批脫離、輪詢、resume。seed=1 估耗時。★`--path`，禁原地 checkout。

## 量（雙向漏斗）
- **弱 push**：`merge_appl.food_lt3`→`surv_ok`→`mv_reached`→完成。
- **強 pull**：`absorb.target_found`→`absorb.dispatch`→完成 + `conq.intent`（對照證強隊選征服）。
- 併完成總量（dissolve+子隊）+ gate#1 非搬餓 + 隊數不崩 + determinism。

## 判準（→to:blueprint 升 user）
- big-window 雙向仍 ~0（弱 survival-locked + 強 dispatch≈0 輸 conquest）→ **結構確認**（和平 consolidation 非此世界 emergent）→ blueprint 升 user a/b/c。
- 若任一向顯著>0 → 3mo 樣本假象，consolidation 活 → signoff。
數字 to:blueprint。
