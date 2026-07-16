---
from: systems
to: implementer
status: consumed
topic: 實作 A2c-1 survival-value（consolidate_drive hunger 主 + critical_pop floor）
---

# 實作工單：A2c-1 survival-value

spec（已鎖，reviewer rev2 CLEAN）：`docs/superpowers/specs/2026-07-09-A2c1-survival-value.md`

## 在哪做
worktree `feat/machine-A2c1`（base @423924c = 純 fold + full_probe 探針）。若 worktree 未建先建。

## 做什麼（照 spec 全部設計決定，2 檔）
1. `scripts/simulation/decision/terms.gd`：`consolidate_drive` eval 換 D2' 算式（hunger_factor 主 + critical_pop floor，`maxf`）；加 `CONSOLIDATE_DRIVE_BASE=0.8`/`CONSOLIDATE_SURVIVAL_BOOST=3.0`/`CONSOLIDATE_CRITICAL_POP=2`，取代舊 flat `CONSOLIDATE_DRIVE`。用既有 `ctx.food_days`/`ctx.population`（**不加新 ctx 欄**，D3' 作廢）。
2. `scripts/simulation/faction_ai_system.gd`：`_decide_unified` ranked 迴圈補 `merge_appl` probe bump——applicable 命中（整併 在 ranked / `consolidate_target_id!=-1`）bump `merge_appl.total`；winner==整併 bump `chose_整併` 否則 `chose_other`。**★reviewer 提醒**：`chose_other` 只在該隊 total 也命中的**同一分支內** bump（total==chose_整併+chose_other，別對非-applicable 隊也算 chose_other，否則驗收線 3 比例失真）。

## 驗（spec §驗收法 1-3 你自跑，4+ 交量測員/QA）
- 無 GDScript 錯；`.\tools\godot.ps1 --headless --import` 綠。
- constitution_gate 綠（純 term/probe 改，無新 try_set 落點）。
- sanity `game_sim_multi` ≥1000 tick 無崩。
- TDD 逐步 commit。

## 完後
handback 寫**唯一 main mailbox 絕對路徑** `A:\GDS\demo\docs\superpowers\handbacks\`，to:systems，status:open。task 完成判定由 systems（我）+ reviewer/QA，非自判。
