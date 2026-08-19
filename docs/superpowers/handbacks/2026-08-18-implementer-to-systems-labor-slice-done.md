---
from: implementer
to: systems
status: consumed
topic: "[labor-slice DONE·feat/labor-marginal-food commit 02db6096·base bf911f51]T1 食物工位邊際分配+T2 估算器 coherence·T1:labor_system 食物組(gather:food+farm)合併 need=food_need 單一、組內 per-labor yield 比例分(gather=food_need×yg/(yg+yf)、farm=×yf/(yg+yf)、yg=productivity×COLLECT_RATE、yf=farming×FARM_UNIT_YIELD×harvest)→farm 高 level 拿多份治斷崖·實作=_workstation_need 加 tile 參+_food_group_need、allocation loop 不動·T2:food_flow._sustainable_inflow 移 farming_bonus 乘性 drift 加 farm_yield_contribution(勞力飽和 labor_mult(farm) fill×SCALE labor-starved 誠實低)+MarginalEconomy._inflow_est 鏡射(est-based farm_fill≈pop/farm_demand god-view 防線)·estimator==allocation 同源 coherence·驗:labor_marginal_test 9/9+constitution 77+determinism ed832403(2跑 detach、零新 RNG、sim 跑完)+fp intended·★未驗:headless full-run 0-new session tooling reap 無法自驗(機器慢 a4~115s+)、labor 改可能影響 labor/production 測(同農業b 風險)→measurer 跑 full headless·★measurer gate:治斷崖正相關+未發展 gather 照舊+guns-vs-butter 照抽+估算器誠實+cross-resource 不亂+守恆+headless 0-new·地基KEEP"
branch: feat/labor-marginal-food
commit: 02db6096
---

# labor-slice DONE — 食物工位邊際分配(T1) + 估算器 coherence(T2)

feat/labor-marginal-food commit `02db6096`（base main `bf911f51`；已 push）。與農業b/perf 刀3 平行。

## T1 食物工位邊際分配（治斷崖）
`labor_system` rebalance：食物組（`gather:food`+`farm`）**合併 need-weight=food_need**（單一非拆兩份重複計、跨資源 food-vs-material 不變）、**組內按 per-labor yield 比例分**：
- `gather share=food_need × yield_g/(yg+yf)`、`farm share=food_need × yield_f/(yg+yf)`。
- `yield_g=productivity×COLLECT_RATE`、`yield_f=farming_level×FARM_UNIT_YIELD×harvest_factor`（own-tile）。
- farm 發展好高 `yield_f` 自然拿多份=**治斷崖**（measurer inverse level1→0.267/2→0.103/3→0.067 → 正相關）。
- 實作=`_workstation_need` 加 tile 參 + `_food_group_need`（食物組專屬 yield-ratio 分）；**allocation loop 不動**（demand-cap/溢出串聯/cross-resource need-weight 全保）。純算術零 randf。

## T2 估算器 coherence（移 drift + 勞力飽和）
- `food_flow._sustainable_inflow`：**移 `farming_bonus=1+farming×0.5`**（乘性 gather-boost drift、農業a 已從 gather 移除、估算器同步移）、**改加項 `farm_yield_contribution=farming×FARM_UNIT_YIELD×harvest×labor_mult(farm)`**（★勞力飽和 `fill×SCALE`：labor-starved 誠實低 ROI、own-tile self-knowledge）。
- `MarginalEconomy._inflow_est` **鏡射**：est-based 勞力飽和估 `farm_fill≈est.pop/(farming×K_FARM)`（labor-starved 誠實低）、**god-view 防線守**（僅 est 結構欄 farming/pop/harvest、無 live-tile 讀）。
- estimator==allocation 同 per-labor 物理源=**coherence**。

守則守：感知鐵律全 self-knowledge；禁 crank（yields 既有真公式）；guns-vs-butter 動員抽勞力不動；守恆 farm_yield chokepoint 不動；零新 RNG。

## 驗
| 閘 | 結果 |
|---|---|
| `labor_marginal_test` | **9/9 PASS**（①食物組 yield 比例分非 equal(farm 4.94>gather 0.06) ②farm level 1<2<3 產出正相關治斷崖 ③cross-resource material fill 加農田前後相近(單一 need 不雙擠) ④farming0 gather 照舊 ⑤food_flow 農田團 inflow>無農田 + MarginalEconomy 足勞力 ROI>labor-starved(22>4.4 勞力飽和誠實)) |
| constitution_gate | **PASS 77** |
| determinism | seed1337 1000t **二跑(detach) byte-identical=`ed832403`**（零新 RNG、sim 跑完無 runaway） |
| fp | **intended-change**（≠base=食物 allocation+估算器變、food production 行為變） |

## ★未驗（honest）
**headless full-run 0-new 本 session 無法自驗**——tooling reap 長 run + 機器慢（a4 已 ~115s+、頻 timeout；detach 才捕到 determinism）。labor allocation 改**可能影響 labor/production headless 測**（同農業b 教訓風險）→ **請 measurer 跑 full headless 確認 0-new + 指出待訂正測**。

## ★measurer gate（bounded）
- **治斷崖**：farm level 回正相關 food production（inverse→positive）。
- 未發展團（farming0）gather 照舊；guns-vs-butter 動員照抽；**估算器誠實**（labor-starved ROI 低）；cross-resource food-vs-material 不亂；守恆 farm_yield 帳平；**headless 0-new**。
- K_FARM/FARM_UNIT_YIELD 量級校準（同農業a、food-account 承接）。

## 路
measurer full headless（0-new + 待訂正測）+ food-account（治斷崖 + 量級）→ 綠 merge。地基 KEEP。
