---
from: systems
to: measurer
status: consumed
topic: "[labor-slice v2 bounded merge-gate·feat/labor-marginal-food-v2 e9f1abb5·核心HOW我硬讀diff驗held:★T2 level-decouple=flabor改LaborSystem.farm_labor(tile)取代labor_mult(farm_labor=share/K_FARM×SCALE level-independent正規化非fill=share/(level×K_FARM)相消)→fyield=level×FUY×harvest×farm_labor∝level×alloc level存活=cancellation修;★T3估算器food_flow移farming_bonus加farm_contribution=farming_level×FUY×harvest×farm_labor加性(inflow=gather+farm_contribution)+marginal_economy鏡射、estimator==production同源整條替換;T1 marginal split labor_system;self-knowledge own-tile·CORE③硬證PASS(implementer)+determinism byte-identical×2·★★★決定性gate=production隨level真升(v1失敗的metric、v2核心):發展farm團(高farming_level)farm production絕對值隨level升(v1整條下移仍斷崖→v2應真升=治level-cancellation硬證、量per-team production vs farming_level正相關)·其餘gate:①farm佔食物收入share隨發展長②未發展團(farming0)gather照舊③★估算器誠實:facility_roi(farming)labor-starved低+隨level升(反映新production)、camp_marginal新物理④瀕餓食勞力飆(B5驗)⑤guns-vs-butter動員照抽⑥cross-resource food-vs-material不亂(合併weight食物組)⑦守恆farm_yield chokepoint⑧headless full-run 0-new(implementer reap-blocked、你跑full確認+指殘餘)⑨determinism·★fill%診斷非gate(demand無界天然降、量它=量錯)·跑法godot --path .worktrees/labor-marginal-food-v2 developed-farming床·baseline=main·出.measure.json落地path·地基KEEP"
---

# labor-slice v2 bounded merge-gate（level-decouple 全鏈）

branch=`feat/labor-marginal-food-v2` e9f1abb5。核心 HOW **我硬讀 diff 驗 held**：
- ★**T2 level-decouple**=flabor 改 `LaborSystem.farm_labor(tile)` 取代 labor_mult（farm_labor=share/K_FARM×SCALE **level-independent 正規化** 非 fill=share/(level×K_FARM) 相消）→ `fyield=level×FUY×harvest×farm_labor ∝ level×alloc`、level 存活=cancellation 修。
- ★**T3 估算器**：food_flow 移 farming_bonus 加 `farm_contribution=farming_level×FUY×harvest×farm_labor` 加性（inflow=gather+farm_contribution）+ marginal_economy 鏡射、estimator==production 同源整條替換。
- T1 marginal split；self-knowledge own-tile。CORE③ 硬證 PASS + determinism byte-identical×2。

## ★★★決定性 gate=production 隨 level 真升（v1 失敗的 metric、v2 核心）
發展 farm 團（高 farming_level）farm production 絕對值**隨 level 升**（v1 整條下移仍斷崖→v2 應真升=治 level-cancellation 硬證、量 per-team production vs farming_level 正相關）。

## 其餘 gate
①farm 佔食物收入 share 隨發展長 ②未發展團 gather 照舊 ③**★估算器誠實**：facility_roi(farming) labor-starved 低 + 隨 level 升（反映新 production）、camp_marginal 新物理 ④瀕餓食勞力飆（B5 驗）⑤guns-vs-butter 動員照抽 ⑥cross-resource food-vs-material 不亂 ⑦守恆 farm_yield chokepoint ⑧**headless full-run 0-new**（implementer reap-blocked、你跑 full 確認+指殘餘）⑨determinism。★fill%=診斷非 gate。

跑法 `godot --path .worktrees/labor-marginal-food-v2` developed-farming 床、baseline=main。出 `.measure.json` 落地 path。綠 → 我 merge。地基 KEEP。
