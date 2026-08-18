---
from: systems
to: implementer
status: open
topic: "[dispatch labor-slice(食物工位邊際分配+估算器coherence、打包一slice一致落地)·base main bf911f51·spec=2026-08-18-labor-marginal-food-alloc-HOW.md R²-CLEAN(reviewer親推導機制完全解釋measurer斷崖非巧合、food_flow drift確認、T1對症根治非優先序常數、T2勞力飽和堵投資報酬騙人)·★T1食物工位邊際分配:labor_system rebalance(:45-93)食物組(gather:food+farm)合併need-weight=food_need(單一非拆兩份重複計、跨資源food-vs-material不變)、組內按per-labor yield比例分:gather share=food_need×yield_g/(yield_g+yield_f)、farm share=food_need×yield_f/(yield_g+yield_f);yield_g=productivity×COLLECT_RATE(own-tile)、yield_f=farming_level×FARM_UNIT_YIELD×harvest_factor(own-tile);farm發展好高yield_f自然拿多治斷崖(level1→0.267/2→0.103/3→0.067回正相關);cross-resource留原need-weight+demand-cap+溢出串聯機制保;純算術零randf·★T2估算器coherence:food_flow._sustainable_inflow(:46-47)移farming_bonus=1+farming_level×0.5乘性gather-boost、改加項farm_yield_contribution=farming_level×FARM_UNIT_YIELD×harvest_factor×expected_farm_labor_fill(★勞力飽和因子labor-starved時ROI誠實變低、own-tile labor_alloc[farm].fill或估);MarginalEconomy._inflow_est鏡射同步(est-based VillageEstimate帶farming_level+labor估、god-view防線守);estimator==allocation同per-labor物理源=coherence·感知鐵律全self-knowledge(own-tile yield/own-state estimator無god-view)·禁crank(yields既有真公式)·guns-vs-butter動員抽勞力(labor_system:43未動員才算)不動·守恆farm_yield chokepoint不動·TDD:①食物組per-labor yield比例分非equal②farm高level拿多份治斷崖③cross-resource food-vs-material比例不變④未發展團farming0 gather照舊⑤_sustainable_inflow移farming_bonus加farm_yield貢獻含勞力飽和⑥facility_roi(farming)labor-starved ROI誠實低⑦estimator==allocation同源⑧self-knowledge無god-view·gate:治斷崖level回正相關+未發展團gather照舊+guns-vs-butter動員照抽+估算器誠實+cross-resource不亂+determinism+守恆+fp intended標注·worktree feat/labor-marginal-food·與農業b/perf刀3平行·完→handback附measurer·地基KEEP"
---

# dispatch labor-slice（食物工位邊際分配 + 估算器 coherence、打包一 slice）

spec=`docs/superpowers/specs/2026-08-18-labor-marginal-food-alloc-HOW.md`（**R²-CLEAN**、reviewer 親推導機制解釋斷崖非巧合）。base=main `bf911f51`。與農業b/perf 刀3 **平行**。

## ★T1 食物工位邊際分配
`labor_system` rebalance（:45-93）食物組（`gather:food`+`farm`）**合併 need-weight=food_need**（單一非拆兩份重複計、跨資源 food-vs-material 不變）、**組內按 per-labor yield 比例分**：
- gather share = food_need × `yield_g/(yield_g+yield_f)`；farm share = food_need × `yield_f/(yield_g+yield_f)`。
- `yield_g=productivity×COLLECT_RATE`（own-tile）、`yield_f=farming_level×FARM_UNIT_YIELD×harvest_factor`（own-tile）。
- farm 發展好高 yield_f 自然拿多**治斷崖**（level 1→0.267/2→0.103/3→0.067 回正相關）。
- cross-resource 留原 need-weight + demand-cap + 溢出串聯機制保。純算術零 randf。

## ★T2 估算器 coherence
- `food_flow._sustainable_inflow`（:46-47）**移 `farming_bonus=1+farming_level×0.5` 乘性 gather-boost**、改**加項 `farm_yield_contribution=farming_level×FARM_UNIT_YIELD×harvest_factor×expected_farm_labor_fill`**（★**勞力飽和因子** labor-starved 時 ROI 誠實變低、own-tile `labor_alloc[farm].fill` 或估）。
- `MarginalEconomy._inflow_est` 鏡射同步（est-based VillageEstimate 帶 farming_level+labor 估、**god-view 防線守**）。
- estimator==allocation 同 per-labor 物理源=coherence。

## 守則
感知鐵律全 self-knowledge（own-tile yield / own-state estimator 無 god-view）。禁 crank（yields 既有真公式）。guns-vs-butter 動員抽勞力（labor_system:43 未動員才算）不動。守恆 farm_yield chokepoint 不動。

## TDD
①食物組 per-labor yield 比例分非 equal ②farm 高 level 拿多份治斷崖 ③cross-resource food-vs-material 比例不變 ④未發展團 farming0 gather 照舊 ⑤`_sustainable_inflow` 移 farming_bonus 加 farm_yield 貢獻含勞力飽和 ⑥`facility_roi(farming)` labor-starved ROI 誠實低 ⑦estimator==allocation 同源 ⑧self-knowledge 無 god-view。

## gate（measurer bounded）
治斷崖（level 回正相關）+ 未發展團 gather 照舊 + guns-vs-butter 動員照抽 + 估算器誠實 + cross-resource 不亂 + determinism + 守恆 + fp intended 標注。

worktree `feat/labor-marginal-food`。完 → handback 附 measurer。地基 KEEP。
