---
from: systems
to: implementer
status: open
topic: "[實作·糧流 SLICE B1(糧橋+食物top-up+派遣閘)·R²v2CLEAN·spec=2026-07-29-food-flow-slice-B-dispatch-founding-HOW.md §1-B1/§2·★解A1子隊餓死真victim·配糧測sub.resources.food(非carry_capacity重量上限空放行)+通用food top-up第5真新建(母隊撥food夠burn×ETA)+礦山bootstrap 2651-2674收編取代·接_dispatch_builder:2603-2698·harvest-only inflow暫不含打獵EV(B2)/立國投影(B3)·★cross-slice A1子隊真被gate execution-verified非aggregate] SLICE B第一sub-slice。解A1子隊餓死。★驗A1子隊真不餓死(target真fire非aggregate派遣數)。"
branch: feat/food-flow-slice-B1
---

# 實作：糧流 SLICE B1（糧橋 + 食物 top-up + 派遣閘）

R²v2CLEAN（3 項訂正核到）。SLICE B 第一 sub-slice（最小、**直解 A1 子隊餓死真 victim**）。inflow 用 SLICE A harvest-only（暫不含打獵 EV=B2/立國投影=B3）。

## spec
`docs/superpowers/specs/2026-07-29-food-flow-slice-B-dispatch-founding-HOW.md` §1-B1 + §2（讀它，R² 訂正版）。

## B1 scope
1. **糧橋 go/no-go**（§2）：`子隊實際糧 = sub.resources.food`（★非 carry_capacity 重量上限=空放行假陰性）；`需糧 = burn × ETA_total`（ETA_total=travel+build，§5）；`子隊實際糧 ≥ 需糧 × safe_margin` → go。
2. **★通用食物 top-up（第 5 真新建）**：子隊糧不足但**母隊撥得起** → top-up（母隊 food → 子隊 sub.resources.food 到夠 burn×ETA）→ go；母隊也不豐 → no-go（別派餓死）。★**收編取代礦山 ad-hoc bootstrap（faction_ai:2651-2674 BOOTSTRAP_DAYS=50 + 2721 upgrade 同款）**——非兩層補貼疊加（移除/整併礦山 bootstrap，通用 top-up 涵蓋）。
3. **半路求生重算 + 橋斷撤**（§2）：每日 cadence 算子隊 runway（SLICE A 感官）；`runway < return_ETA` 且橋真斷 → 撤退（返家/最近 outpost），非硬撐餓死。
4. **接 `_dispatch_builder`（faction_ai:2603-2698，經 `_dispatch_goal_delegate`:2836）**——糧橋 go/no-go gate 加在派子隊前。

## ★TDD + 驗（★★execution-verified A1 真 victim，非 aggregate）
- 糧橋 go/no-go 單測（sub.resources.food vs burn×ETA、top-up 補足、母隊不豐 no-go、撤退）。
- **★★A1 子隊真不餓死（cross-slice tripwire，memory 精化 4/5）**：**A1 forest founding 子隊真被糧橋 gate/top-up**（在 trace、被算）→ **子隊 arrive 率升 / construct.complete_build>0 vs baseline never-arrive/dissolved**。★驗 target(A1 子隊)真 fire，非只 aggregate 派遣數升（別重蹈 team14 覆蓋缺口）。
- **★世界不凍**（specimen-off、attrition/teams 活）。
- 純算術（top-up/go-no-go 零 RNG）。tap（bridge_go/no_go/topup/撤退，禁耗 RNG）。
- 閘：headless 0-new + gate 74 + determinism 3跑 byte-identical。

## 交付
handback `to:systems` → R²（B1）→ merge → **measurer specimen-off（★落地 docs/measurements 標 exact path 驗存在）→ QA A1 子隊真不餓死稽核**（子隊真 arrive/建成 vs baseline）→ B2（打獵 EV）。★execution-verified（A1 子隊真被 gate + 真不餓死 + 世界不凍）。
