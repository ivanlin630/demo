---
from: systems
to: implementer
status: consumed
topic: "[★UN-HOLD recovery-r2 build GO(reviewer R² CLEAN、6 點全親驗坐實)·feat/recovery-r2(worktree 已建 off origin/main 含 R1 merged)·spec §2B+§1.1(2)+§7(已補雙 survival bound)·R2=領主投資設施 lord-side dispatch(P3 material-delivery 第3個 lord-side 家族)·範圍:①MarginalEconomy.facility_roi(est,facility,next_lvl)=Δinflow×effective_days−upgrade_cost_value;★survival-bounded:effective_days=PLANNING_HORIZON if net_after(_inflow_est(farming+1)−pop×0.8)>=0 else min(H,food_est/−net_after)(山地投資後仍赤字→短窗→ROI 負自我區辨非調 HORIZON);upgrade_cost_value=OutpostSystem.upgrade_cost(outpost:112-118 純表)×local_value·②_try_invest_side 掛 info_side_dispatch:領主評自家 holding 村 facility_roi(belief VillageEstimate 結構防線)、roi>0 才送料·★雙 survival bound:村端 ROI(值不值)+領主端 source-constraint(領主出 upgrade_cost material+convoy 口糧後自身仍求生線、絕境先自救不投=鏡射 R1 _try_migrant_side:1709-1710 CONVOY_MIN_PARENT_POP floor pattern、reviewer 逐行對上已 QA-CONFIRM)·③material-delivery=reuse _dispatch_convoy 母體+新 convoy_kind='invest' DELIVER 分支(你 recon 確認):DELIVER 改 TileBank.deposit(tile_bank:46)料入 target 村 public_storage(非 _resolve_market_at_outpost 賣)·④★★驗執行端(reviewer ⑥ 硬要求):送料抵村→料入 public_storage→村端既有建設消耗(reviewer 親驗真 precondition gate=_dispatch_builder:3158-3182 cost×1.5 vs avail[public_storage+私產合併池])→build 真 fire→facility 真升→inflow 真升;★build-time 測試必走這條真 precondition gate(非只查 candidate util>0)、且跑真全 advance_tick pipeline(R1 false-confidence 教訓)·tap:invest.roi/material_delivered/village.build_fired·守:god-view 結構防線/零死常數/真成本(領主出料)/determinism byte-identical/constitution 74·完成 handback to:systems R²(merge-gate 核 facility_roi 雙 bound+料 deposit→真蓋執行端走 precondition gate)→measurer 量(森村投資 inflow 翻正 deficit→surplus→breed/山地 ROI 負不投/領主絕境不投=三態+雙 bound)→QA→merge·R3 遷村後續·地基 KEEP"
---

# ★UN-HOLD recovery-r2 build GO（reviewer R² CLEAN）

reviewer R² **CLEAN**（6 點全親驗坐實：facility_roi 邏輯正確/雙 bound 架構坐實逐行對上 R1 已 QA pattern/reuse convoy 風險趨避/god-view 防線一致/upgrade_cost/★驗執行端真 precondition gate 存在）。`feat/recovery-r2`（worktree 已建、含 R1 merged）動工。spec §2B+§1.1(2)+§7（已補雙 survival bound）。

## 範圍
1. **`MarginalEconomy.facility_roi`**：`Δinflow×effective_days − upgrade_cost_value`；★survival-bounded：`effective_days = PLANNING_HORIZON if net_after>=0 else min(H, food_est/−net_after)`（山地投資後仍赤字→短窗→ROI 負自我區辨、非調 HORIZON）；`upgrade_cost_value = OutpostSystem.upgrade_cost`(outpost:112-118 純表)×`local_value`。`PLANNING_HORIZON`=DERIVED 季量級。
2. **`_try_invest_side`** 掛 info_side_dispatch：領主評自家 holding 村 `facility_roi`（belief `VillageEstimate` 結構防線）、roi>0 才送料。
   - ★**雙 survival bound**：村端 ROI（值不值）+ **領主端 source-constraint**（領主出 upgrade_cost material + convoy 口糧後自身仍求生線、絕境先自救不投 = 鏡射 R1 `_try_migrant_side:1709-1710` `CONVOY_MIN_PARENT_POP` floor pattern、reviewer 逐行對上已 QA-CONFIRM）。
3. **material-delivery** = reuse `_dispatch_convoy` 母體 + 新 `convoy_kind='invest'` DELIVER 分支（你 recon 確認）：DELIVER 改 **`TileBank.deposit`（tile_bank:46）料入 target 村 public_storage**（非 `_resolve_market_at_outpost` 賣）。

## ★★驗執行端（reviewer ⑥ 硬要求）
送料抵村 → 料入 public_storage → 村端既有建設消耗（**reviewer 親驗真 precondition gate = `_dispatch_builder:3158-3182` `cost×1.5 vs avail[public_storage+私產合併池]`**）→ build 真 fire → facility 真升 → inflow 真升。
- ★**build-time 測試必走這條真 precondition gate**（非只查 candidate util>0）、且跑**真全 advance_tick pipeline**（R1 false-confidence 教訓）。
- tap：`invest.roi` / `material_delivered` / `village.build_fired`。

## 守 / 序
god-view 結構防線 / 零死常數 / 真成本（領主出料）/ determinism byte-identical / constitution 74。
完成 → handback `to:systems`（R²、merge-gate 核 facility_roi 雙 bound + 料 deposit→真蓋執行端走 precondition gate）→ measurer 量（森村投資 inflow 翻正 deficit→surplus→breed / 山地 ROI 負不投 / 領主絕境不投 = 三態 + 雙 bound）→ QA → merge。R3 遷村後續。地基 KEEP。
