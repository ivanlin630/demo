---
from: systems
to: implementer
status: open
topic: "[dispatch build recovery-path Slice R1(R² round2 CLEAN、reviewer 親驗坐實三態 sign)·spec docs/superpowers/specs/2026-08-06-recovery-path-HOW.md·新 slice feat/recovery-r1 off 更新後 main(fd2d1ce3、含 HOW spec)·★Slice R1 範圍=最小閉環先坐實 substrate:①新 MarginalEconomy 計算層(§1.0/§1.1)②移民 marginal-util dispatch(§2 A)·★★命門①(god-view 結構防線、最高風險 R² blocker 訂正點):MarginalEconomy 禁呼 FoodFlow._sustainable_inflow(state, live_target)——結構上吃純 struct VillageEstimate、經內部 _inflow_est(est) 重算(鏡射 food_flow.gd:39-47 公式非直呼);VillageEstimate 逐欄來源=terrain/outpost_level/farming_level 自家村行政/holding 記錄(非 live-tile 讀)、pop=belief pop_est、harvest_factor=NEUTRAL 1.0+prod_skill=NEUTRAL 0.0(belief 無來源、誠實無知、同底查 Model B baseline);_inflow_est 簽名只吃 est 值不吃 state.teams[target](結構防線=拿不到 live 物件才不可能違憲、非道德勸說)·★★命門②三態由 terrain REGEN 主導湧現(禁地型查表):migrant_marginal=_inflow_est(pop+k)−_inflow_est(pop)−k×0.8;marginal≤0→util<0→不派(forest C=3→0.426<0.8 負/mountain C=0.5→0.071 負/plains C=8→1.14>0.8 正、REGEN plains8/forest3/mountain0.5 resource_system.gd:34-38);零 if-terrain 分支·移民 dispatch 掛 info_side_dispatch_all(:1667)家族(脫主 argmax、cadence-gate、mini-util、真成本 detach、throttle 鏡射 herald/distribute);來源約束=盈餘村/anon、抽走後源村 migrant_marginal 仍≥0(不拆東牆補西牆)·守:零 god-view(結構防線+新測)/零死常數(marginal 真值非門檻)/真成本/determinism byte-identical/constitution 74·TDD:①_inflow_est 三態 sign(plains 正/forest 負/mountain 負)②migrant_marginal 森林不派③★god-view 硬驗:給 stale/錯 VillageEstimate→決策跟 est 非 live 真值(_test_leak_ 家族、invariants:197)④來源不抽穿⑤determinism·完成 handback to:systems R²(merge-gate 逐行核 _inflow_est 簽名確認拿不到 live target)+measurer 量(移民只去邊際正的地:森林/山地村不收、平原欠人村收)→QA→merge·R2/R3(投資/遷村)後續 slice·地基 KEEP"
---

# dispatch build recovery-path Slice R1（R² round2 CLEAN）

新 slice `feat/recovery-r1` off 更新後 main（`fd2d1ce3`、含 HOW spec）。spec：`docs/superpowers/specs/2026-08-06-recovery-path-HOW.md`（DRAFT-v2、三 finding 訂正、reviewer round2 CLEAN 親驗坐實三態 sign）。

## ★Slice R1 範圍（最小閉環、先坐實 substrate）
1. **新 `MarginalEconomy` 計算層**（§1.0 / §1.1）。
2. **移民 marginal-util dispatch**（§2 A）。
（投資 R2 / 遷村 R3 = 後續 slice、本 slice 不做。）

## ★★命門①：god-view 結構防線（最高風險、R² blocker 訂正點）
- **`MarginalEconomy` 禁呼 `FoodFlow._sustainable_inflow(state, live_target)`**（讀 live target tile/leader = god-view、同已修的 `_resident_food_runway` 違規同款）。
- 改吃**純 struct `VillageEstimate`**、經內部 **`_inflow_est(est)`** 重算（鏡射 food_flow.gd:39-47 公式、**非直呼**）。
- `VillageEstimate` 逐欄來源：terrain / outpost_level / farming_level = 自家村**行政/holding 記錄**（非 live-tile 讀）；pop = **belief `pop_est`**；**harvest_factor = NEUTRAL 1.0** + **prod_skill = NEUTRAL 0.0**（belief 無來源、誠實無知、同 §3 底查 Model B baseline）。
- ★**結構防線**：`_inflow_est` 簽名**只吃 est 值、不吃 `state.teams[target]`**——拿不到 live 物件才不可能違憲（結構性、非道德勸說）。

## ★★命門②：三態由 terrain REGEN 主導湧現（禁地型查表）
- `migrant_marginal(est,+k) = _inflow_est(pop+k) − _inflow_est(pop) − k×0.8`；`marginal≤0 → util<0 → 不派`。
- REGEN（resource_system.gd:34-38）plains 8 / forest 3 / mountain 0.5 → Δpop_mult(2→3)=0.1421 → plains `8×0.1421=1.14>0.8 正`、forest `3×0.1421=0.426<0.8 負`、mountain `0.5×0.1421=0.071 負`。**三態從真數字湧現、零 `if terrain==X` 分支**。

## dispatch wiring
- 移民 dispatch 掛既有 `info_side_dispatch_all`（faction_ai_system:1667）家族：脫主 argmax（母隊 body 照自救）、cadence-gate（:1673）、mini-util cost-benefit、真成本 detach、throttle——鏡射 `_try_herald_side`/`_try_distribute_side`。
- 來源約束：migrant 來自盈餘村/anon 池，**抽走後源村 `migrant_marginal` 仍≥0**（不拆東牆補西牆）。

## 守 + TDD
- 零 god-view（結構防線 + 新測）/ 零死常數（marginal 真值非門檻）/ 真成本（人隨 convoy 離源村）/ determinism byte-identical / constitution 74。
- **TDD**：①`_inflow_est` 三態 sign（plains 正/forest 負/mountain 負）②`migrant_marginal` 森林村不派③★**god-view 硬驗**：給 stale/錯 `VillageEstimate` → 決策跟 est 非 live 真值（`_test_leak_*` 家族、invariants:197 契約）④來源不抽穿 sweet spot⑤determinism。
- 完成 → handback `to:systems`（R²、**merge-gate 逐行核 `_inflow_est` 簽名確認拿不到 live target**）+ measurer 量（移民只去邊際正的地：森林/山地村不收、平原欠人村收）→ QA → merge（atomic、憲法 74+、byte-identity）。地基 KEEP。
