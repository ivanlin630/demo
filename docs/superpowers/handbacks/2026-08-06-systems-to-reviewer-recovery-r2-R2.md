---
from: systems
to: reviewer
status: open
topic: "[R² 審設計:recovery-path Slice R2 投資(spec docs/superpowers/specs/2026-08-06-recovery-path-HOW.md §2B+§1.1(2)+§7)·blueprint R2 序要 R2 自己的 R²(非只 HOW R²round2)·R2=領主投資設施 lord-side dispatch(P3 material-delivery 第3個 lord-side 家族)·★R² 重點審:①facility_roi survival-bounded(§1.1.2 治 HORIZON 自打臉):effective_days=PLANNING_HORIZON if net_after>=0 else min(H,food_est/−net_after)→山地投資後仍赤字綁殘存活窗→ROI 負自我區辨、非調 HORIZON——此邏輯正確否?PLANNING_HORIZON DERIVED 季量級非 fire-crank?②雙 survival bound(§2B blueprint 加):村端 ROI(值不值)+領主端 source-constraint(領主出料後自身仍求生線、別掏空自己、鏡射 R1 migrant floor)——雙 gate 齊否/有無漏?③P3 material-delivery reuse:options.gd:40-47 建設 target 自 tile→領主送料 convoy(reuse _dispatch_convoy 換 payload=material)→村端既有建設收料在地蓋——reuse proven convoy 正確否(避 R1 migrant 新 dispatch 的 subteam-lifecycle 坑)?④god-view 結構防線:facility_roi 全 belief VillageEstimate(同 R1 _inflow_est 拿不到 live target)⑤material_cost=OutpostSystem.upgrade_cost(純表零 god-view)非 _construction_facility_need(自 outpost 加總+god-view)⑥★驗執行端:料到村→建設真 fire TASK_BUILD→facility 真升→inflow 真升、測試跑真全 pipeline(R1 false-confidence 教訓)·序:CLEAN→systems re-dispatch implementer build(feat/recovery-r2、已 HOLD 等你)·地基 KEEP"
---

# R² 審設計：recovery-path Slice R2 投資

spec：`2026-08-06-recovery-path-HOW.md` §2B + §1.1(2) + §7。blueprint R2 序要 **R2 自己的 R²**（非只 HOW R²round2）。R2 = 領主投資設施 lord-side dispatch（P3 material-delivery = 第 3 個 lord-side 家族）。

## ★R² 審查重點
1. **`facility_roi` survival-bounded**（§1.1.2、治 HORIZON 自打臉）：`effective_days = PLANNING_HORIZON if net_after>=0 else min(H, food_est/−net_after)` → 山地投資後仍赤字綁殘存活窗 → ROI 負自我區辨、**非調 HORIZON**——此邏輯正確否？`PLANNING_HORIZON` DERIVED 季量級非 fire-crank？
2. **雙 survival bound**（§2B、blueprint 2026-08-06 加）：村端 ROI（值不值）+ **領主端 source-constraint**（領主出料後自身仍求生線、別掏空自己、鏡射 R1 migrant floor）——雙 gate 齊否 / 有無漏？
3. **P3 material-delivery reuse**：options.gd:40-47 建設 target 自 tile → 領主送料 convoy（reuse `_dispatch_convoy` 換 payload=material）→ 村端既有建設收料在地蓋——**reuse proven convoy 正確否**（避 R1 migrant 新 dispatch 的 subteam-lifecycle 坑）？
4. **god-view 結構防線**：`facility_roi` 全 belief `VillageEstimate`（同 R1 `_inflow_est` 拿不到 live target）。
5. **material_cost** = `OutpostSystem.upgrade_cost`（純表零 god-view）非 `_construction_facility_need`（自 outpost 加總+god-view）。
6. ★**驗執行端**：料到村 → 建設真 fire TASK_BUILD → facility 真升 → inflow 真升；測試跑**真全 pipeline**（R1 false-confidence 教訓）。

## 序
CLEAN → systems re-dispatch implementer build（`feat/recovery-r2`、已 HOLD 等你）。若需異質框外審請 flag。地基 KEEP。
