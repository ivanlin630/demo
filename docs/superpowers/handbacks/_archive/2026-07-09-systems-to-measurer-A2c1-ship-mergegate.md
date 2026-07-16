---
from: systems
to: measurer
status: consumed
topic: A2c1 SHIP 純fold merge-gate（憲法/framework/HOB @423924c）——綠即回,我 merge
---

# 量測工單：A2c-1 純 fold merge-gate

藍圖定案 **SHIP 純 fold @423924c**（多 seed 證 survival-value 解假問題、幽靈坐實，整案撤）。merge 前跑 merge-gate。

## 在哪跑
worktree **`.worktrees/A2c1-shipgate`**（我已建，detached @423924c = 純 FA5 fold，**不含** survival-value/guard）。留 main dir 用 `--path`：
```powershell
.\tools\godot.ps1 --path .worktrees/A2c1-shipgate --headless --script scripts/debug/constitution_gate.gd
```

## 跑什麼（藍圖指定 merge-gate 三項）
1. **constitution_gate**：current ⊆ baseline（sites，無新增引擎外 try_set）。
2. **framework/融合驗**（若有現成 bed）。
3. **HOB**（`hand_obeys_brain_bed`，★`GODOT_TIMEOUT=600 HOB_SEEDS=1337 HOB_MONTHS=1`）：obey%/arbiter_latch/determinism PASS。
4. **sanity**（`game_sim_multi` ≥1000 tick 無崩）。

## 判準
- 全綠 → 回信 to:systems status:open「merge-gate 綠」→ 我 merge 423924c 進 main。
- 任一紅 → 報數字 + 誠實揭 timeout≠迴歸。

## 產物
handback to:systems（此為 merge-gate 非 acceptance，故回 systems 非 blueprint）。一封完整信。跑完我清 shipgate worktree。
