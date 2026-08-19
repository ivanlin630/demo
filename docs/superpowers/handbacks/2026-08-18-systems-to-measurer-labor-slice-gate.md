---
from: systems
to: measurer
status: consumed
topic: "[labor-slice bounded merge-gate·feat/labor-marginal-food 02db6096·食物邊際分配+估算器coherence·核心HOW我硬讀diff驗held:T1 _food_group_need:119食物組(gather:food+farm)合併food_need單一、組內per-labor yield比例分(yield_g=productivity×COLLECT_RATE/yield_f=farming×FARM_UNIT_YIELD×harvest)、allocation loop不動minimal、cross-resource不變;T2 food_flow移farming_bonus(:9-10)加farm_contribution=farming_level×FARM_UNIT_YIELD×harvest×farm_fill(:16、farm_fill=labor_mult(farm)own-tile self-knowledge勞力飽和labor-starved誠實低)、MarginalEconomy._inflow_est鏡射god-view防線、estimator==allocation同源·9/9+constitution77+determinism ed832403+fp intended·★★★決定性gate=治斷崖:發展farm團flabor隨level回正相關(現0.267→0.103→0.067單調負斷崖→修後應正或平、farm高level拿多份)=labor-slice真效果驗·其餘gate:①未發展團(farming0)gather照舊②guns-vs-butter動員照抽(未動員才算)③cross-resource food-vs-material-mfg比例不亂(食物組合併weight保)④★估算器誠實:facility_roi(farming)labor-starved時ROI低(非舊boost假高)、camp_marginal反映新物理⑤★broad-effects watch:估算器改→camp/facility決策變、留意downstream(camp數/facility投資/居民行為非預期偏移=估算器誠實副作用、design-aligned or異常判)⑥headless full-run 0-new(implementer tooling reap無法自驗、你跑full確認+指殘餘、同農業b款)⑦守恆farm_yield chokepoint照關⑧determinism ed832403·跑法godot --path .worktrees/labor-marginal-food developed-farming/economy床·baseline=main·出.measure.json落地path·地基KEEP"
---

# labor-slice bounded merge-gate（食物邊際分配 + 估算器 coherence）

branch=`feat/labor-marginal-food` 02db6096。核心 HOW **我硬讀 diff 驗 held**：T1 `_food_group_need:119` 食物組合併 food_need 單一、組內 per-labor yield 比例分、allocation loop 不動（minimal）、cross-resource 不變；T2 food_flow 移 farming_bonus 加 `farm_contribution=...×farm_fill`（farm_fill=`labor_mult(farm)` own-tile self-knowledge 勞力飽和誠實低）、MarginalEconomy 鏡射 god-view 防線、estimator==allocation 同源。9/9+constitution77+determinism ed832403+fp intended。

## ★★★決定性 gate=治斷崖
發展 farm 團 flabor 隨 level **回正相關**（現 0.267→0.103→0.067 單調負斷崖 → 修後應正或平、farm 高 level 拿多份）=labor-slice **真效果驗**。

## 其餘 gate
1. 未發展團（farming0）gather 照舊。
2. guns-vs-butter 動員照抽（未動員才算）。
3. cross-resource food-vs-material-mfg 比例不亂（食物組合併 weight 保）。
4. **★估算器誠實**：facility_roi(farming) labor-starved 時 ROI 低（非舊 boost 假高）、camp_marginal 反映新物理。
5. **★broad-effects watch**：估算器改→camp/facility 決策變、留意 downstream（camp 數/facility 投資/居民行為非預期偏移=估算器誠實副作用、design-aligned or 異常判）。
6. **headless full-run 0-new**（implementer tooling reap 無法自驗、你跑 full 確認+指殘餘、同農業b款）。
7. 守恆 farm_yield chokepoint 照關。8. determinism ed832403。

跑法 `godot --path .worktrees/labor-marginal-food` developed-farming/economy 床、baseline=main。出 `.measure.json` 落地 path。綠 → 我 merge。地基 KEEP。
