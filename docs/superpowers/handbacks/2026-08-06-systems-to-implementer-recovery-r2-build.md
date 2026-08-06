---
from: systems
to: implementer
status: open
topic: "[dispatch build recovery-path Slice R2 投資(HOW R²round2 已 CLEAN 涵蓋 R2 設計、鏡射 R1 流)·spec docs/superpowers/specs/2026-08-06-recovery-path-HOW.md §2B+§1.1(2)+§7·新 slice feat/recovery-r2 off 更新後 main(含 R1 merged 53907687:MarginalEconomy/VillageEstimate 已在)·★R2 範圍=領主投資設施 lord-side dispatch(P3 material-delivery 新機制):①MarginalEconomy 加 facility_roi(est,facility,next_lvl)=Δinflow(_inflow_est farming+1 − current)×effective_days − upgrade_cost_value;★★命門 survival-bounded(治 HORIZON 自打臉):effective_days = PLANNING_HORIZON if net_after(_inflow_est(farming+1)−pop×0.8)>=0 else min(PLANNING_HORIZON, food_est/−net_after)→山地投資後仍赤字→短窗→ROI 負自我區辨、非調 HORIZON;upgrade_cost_value=OutpostSystem.upgrade_cost(facility,target_level)(outpost_system.gd:112-118 純表零 god-view)×TradeValuation.local_value·禁 _construction_facility_need(自 outpost 加總+god-view)②_try_invest_side 掛 info_side_dispatch 家族:領主評自家 holding 村 facility_roi(belief VillageEstimate、同 R1 god-view 結構防線 _inflow_est 拿不到 live target)、roi>0 才送料;PLANNING_HORIZON=DERIVED 季量級 TICKS_PER_DAY·③material-delivery=reuse _dispatch_convoy/_try_distribute_side 母體換 payload=material(非 food)指定 facility 類型→★reuse proven convoy machinery(避 R1 migrant 新 dispatch 的 subteam-lifecycle 三坑:convoy 已正確處理 transit/merge-back)·④★★驗執行端(R1 血證:candidate≠真發生):送料抵村→村端既有建設 option(options.gd:40-47 target 自 tile)收 holding material→idle labor 在地蓋→facility 真升→inflow 真升;測試必跑真全 advance_tick pipeline(非 hand-step、R1 false-confidence 教訓)驗:料真到村 holding+村建設真 fire TASK_BUILD+facility level 真升+invest.roi/material_delivered/village.build_fired tap·守:god-view 結構防線(facility_roi 全 belief est)/零死常數(roi 真值)/真成本(領主出料)/determinism byte-identical/constitution 74·完成 handback to:systems R²(merge-gate 核 facility_roi survival-bounded+料到村真蓋執行端)→measurer 量(森村投資後 inflow 翻正 deficit→surplus→breed;山地投資 ROI 負不投=三態)→QA→merge·R3 遷村後續·地基 KEEP"
---

# dispatch build recovery-path Slice R2 投資（P3 material-delivery lord-side dispatch）

新 slice `feat/recovery-r2` off 更新後 main（含 R1 merged `53907687`：`MarginalEconomy`/`VillageEstimate` 已在）。spec：`2026-08-06-recovery-path-HOW.md` §2B + §1.1(2) + §7。HOW R² round2 已 CLEAN 涵蓋 R2 設計（P3 + survival-bounded ROI + upgrade_cost），鏡射 R1 流。

## R2 範圍
1. **`MarginalEconomy.facility_roi(est, facility, next_lvl)`**：
   - `Δinflow = _inflow_est(farming+1) − _inflow_est(current)`；
   - ★★**survival-bounded**（治 HORIZON 自打臉）：`net_after = _inflow_est(farming+1) − est.pop×0.8`；`effective_days = PLANNING_HORIZON if net_after>=0 else min(PLANNING_HORIZON, food_est/−net_after)` → **山地投資後仍赤字 → 短窗 → ROI 負自我區辨、非調 HORIZON**；
   - `roi = Δinflow × effective_days − upgrade_cost_value`；`upgrade_cost_value = OutpostSystem.upgrade_cost(facility, target_level)`（outpost_system.gd:112-118 純表零 god-view）× `TradeValuation.local_value`。**禁** `_construction_facility_need`（自 outpost 加總+god-view）。
   - `PLANNING_HORIZON` = DERIVED 季量級（`WorldState.TICKS_PER_DAY`）。
2. **`_try_invest_side`** 掛 `info_side_dispatch` 家族：領主評自家 holding 村 `facility_roi`（**belief `VillageEstimate`、同 R1 god-view 結構防線** `_inflow_est` 拿不到 live target）；`roi>0` 才送料。
3. **material-delivery** = **reuse `_dispatch_convoy`/`_try_distribute_side` 母體**、payload 從 food 換 **material**（指定 facility 類型）→ ★**reuse proven convoy machinery**（避 R1 migrant 新 dispatch 的 subteam-lifecycle 三坑：convoy 已正確處理 transit/merge-back）。

## ★★驗執行端（R1 血證：candidate≠真發生）
送料抵村 → 村端**既有建設 option**（options.gd:40-47 target 自 tile）收 holding material → idle labor 在地蓋 → **facility 真升 → inflow 真升**。
- **測試必跑真全 `advance_tick` pipeline**（非 hand-step、R1 false-confidence 教訓）驗：料真到村 holding + 村建設真 fire TASK_BUILD + facility level 真升 + `invest.roi`/`material_delivered`/`village.build_fired` tap。

## 守 / 序
- god-view 結構防線（facility_roi 全 belief est）/ 零死常數（roi 真值）/ 真成本（領主出料）/ determinism byte-identical / constitution 74。
- 完成 → handback `to:systems`（R²、merge-gate 核 facility_roi survival-bounded + 料到村真蓋執行端）→ measurer 量（森村投資後 inflow 翻正 deficit→surplus→breed；山地投資 ROI 負不投=三態）→ QA → merge。R3 遷村後續。地基 KEEP。
