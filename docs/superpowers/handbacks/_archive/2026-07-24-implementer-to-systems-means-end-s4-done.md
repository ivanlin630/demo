---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S4 設施發展·8 座 build_F goal+設施/人力型前置·收+驗+S4 R²請] feat/means-end-s4-facility 8a2d862d off local main 54e38f8c(含 S3)。修:GoalRegistry 8 build_F/_resolve_build_facility(resource→facility→manpower→build_F action,first-unsatisfied 遞迴 S2/S3)/manpower 靜默/facility goal 生成(_facility_deficit)/unowned track。TDD 7/7/headless 0-new(慢但 exit 0 非 hang)/gate 74 removed=0/determinism 0efd2191。★perf 註:goal 生成加 facility_deficit(team-cadence),較慢可後續 optimize(非 blocker)。whole-system-first:只設施+人力型。完成→收+驗+S4 R²→CLEAN merge→dispatch S5/S6。"
branch: feat/means-end-s4-facility
commit: 8a2d862d
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S4 設施發展（8 座設施 goal，請 systems 收+驗+R²）

HOW spec §10 S4。設施發展：8 座 `build_F` goal + 設施/人力型前置 handler。

## 修
1. **GoalRegistry 8 build_F goal**（farming/workshop/apothecary/mint/stable/smeltery/weaponsmith/armorsmith）：facility 標記，prereqs 動態導 `OutpostSystem.FACILITY_DEF`（cost/allowed_outpost/level_key）。
2. **`_resolve_build_facility`（組件 C 設施型）**：walk build_F 前置鏈——
   - **resource**（build-cost material/tools）：缺 → 接 S2/S3 資源鏈（`_resolve_resource_prereq`，`need_keep` 已含 construction need）。
   - **facility**（allowed_outpost type）：無合適 type outpost → 建 outpost frontier（隊在自己 tile 未建→`TASK_BUILD`）。
   - **manpower**（pop<6）：★靜默無 frontier（S4 最小，passive 繁殖增，無主動 recruit＝不造假 candidate）。
   - **全滿 → build_F action**：`TASK_BUILD` at own outpost + facility → 既有 build 機械挑 wanted facility（team desire 高→_pick_facility 選 F，emergent 對齊）。
   - first-unsatisfied 前置生 frontier = means-end 湧現順序。
3. **facility goal 生成（組件 A 最小）**：`_facility_deficit(F) ≥ CONSTRUCTION_DESIRE_MIN` 且未建 → 掛 build_F goal（只 allowed-type + 有 outpost 隊算，決定性 REGISTRY key 序）。S7 才做掛退泛化。
4. **★unowned track**（reviewer R²）：build outpost `start_build` 自然擋已占；隊自有 outpost 才建 facility。
5. **util 護欄沿用 S2** `_candidate_util`（絕境設施 goal 折趨零）。

## 驗（皆綠）
- TDD `means_end_s4_test` **7/7**（①8 build_F registry 對 FACILITY_DEF ②build_F action candidate 前置全滿→TASK_BUILD workshop ③manpower pop<6 靜默無假 candidate ④缺 material→資源鏈 frontier 非 build action ⑤must-fix① range regression）。RED：build_F action 移除→②FAIL（load-bearing）。
- headless **0-new**（3 baseline；S4 慢但 exit 0 = 非 hang，只多計算）。
- **gate PASS sites=74 removed=0**（讀自有 outpost + belief 非 god-view；無 RNG）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `0efd2191`（純讀狀態無 randf）。

## ★perf 註（非 blocker，供 systems/measurer 留意）
S4 goal 生成每 team-cadence 加 `_facility_deficit`（限 allowed-type + 有 outpost 隊，多數早期無 outpost 隊早退）→ headless/warring 較慢（~2× 決策成本）。功能正確、0-new、determinism 綠。**可後續 optimize gen cadence**（如 facility goal 生成降頻 / cache desire），非本 slice blocker。

## ★whole-system-first
S4 只設施 + 人力型；子目標遞迴 / 折現 / 委派 = S5-S6 未提前（build_F 遞迴到資源=接 S2/S3 既有鏈，非新）。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S4 R²（8 build_F prereqs 對 FACILITY_DEF / build_F walk 湧現順序 / manpower 靜默不造假 / facility goal 生成決定性 / unowned 自然擋 / must-fix① regression / perf 是否需 optimize）→ CLEAN merge → dispatch S5（委派 peer option）/ S6（折現）。
base=local main 54e38f8c（含 S3）。
