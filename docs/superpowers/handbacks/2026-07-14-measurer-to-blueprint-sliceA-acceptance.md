---
from: measurer
to: blueprint
status: consumed
topic: [全slice A驗收·大幅進步待裁門檻] attrition 1.9-3.7x→1.3-1.7x;性格顯性化3樣本分化;Fix3c PASS;P25個案工具缺口
measured_at_head: branch=67d4a470 main_baseline=68c8febb
---

# 全 Slice A 驗收：大幅進步，門檻裁定交你

工單：`2026-07-14-systems-to-measurer-full-sliceA-acceptance.md`。完整數字：`docs/process/verdicts/survival-layer-sliceA-acceptance.measure.json`。raw log 全落地 `docs/measurements/2026-07-14-sliceA-*`。

## ★headline 1：attrition——大幅改善，未完全達 main 水準

| seed | sliceA | main | 倍數 | v1(對照) | v2(對照) |
|---|---|---|---|---|---|
| 1337 | 23.0% | 13.5% | 1.70x | 50.5% | 45.3% |
| 42 | 17.1% | 11.8% | 1.45x | 34.7% | 42.8% |
| 7 | 21.8% | 16.7% | 1.31x | 31.3% | 31.5% |

倍數從 v1/v2 的 1.9-3.7x **大降到 1.3-1.7x**——方向對、幅度大，但仍高 main 30-70%，非嚴格「≈main baseline」。established 無回歸（`[1,0,2]` vs main `[0,0,2]`——seed1337 branch 還**多達成一個** established，反向利多）。**是否算「可接受餘裕」，門檻裁定交你**。

## ★headline 0b：boost 頻率 10.52%

`slice_a_observe.gd`：`survival.boost_fire=2023/decision.coeff_applied_n=19224=10.52%`，跟 implementer 初值 9.46% 同量級。工單已定性此為 tuning 訊號非 boost 壞，照實回報。

## ★headline 2：性格顯性化——3 樣本分化明顯，但活教材 P25 沒鎖到

`single_team_trace_bed`（seed1337/42/7 各一次）湊到 3 種性格：

| 樣本 | 野心/慎重/好戰 | food_sec_target | winner分布特徵 |
|---|---|---|---|
| 中庸(seed1337 Team13) | 0.52/0.47/0.48 | 3.8天 | 覓食70/建設13/生產8/**買糧108**(5 option,買糧54%為主非monotonic) |
| 好戰武力(seed42 Team9) | 0.47/0.65/**0.97** | 4.7天 | **迎戰34**/囤貨71/覓食12/生產32/...(9 option極多樣) |
| 謹慎守成(seed7 Team15) | 0.40/0.65/0.62 | **5.0天** | **建設93**(79%)/迎戰13/覓食8 |

food_sec_target 隨慎重遞增（3.8→4.7→5.0），option 分布明顯不同——**非全隊同一套行為，方向對**。

**但工單點名的活教材「Team10 leader P25（野心0.89霸主）」沒能直接鎖定**——`single_team_trace_bed` 候選由 pop-swing 自動評分挑選，非 team_id 指定，3次 seed 都沒選中 Team10（候選演算法挑了別隊）。**沒有工具能強制指定 team_id=10 做 specimen**（累積第二個工具缺口，同前輪的 caution-trait log tap）——標記 `incomplete`，建議 implementer/systems 加一個「指定 team_id specimen」參數供下輪用。

## ★Fix3c 武備隊存活：PASS
`slice_a_observe.gd`：`has_specie=true`（修前應false）；barter `food 5→142, weapon 30→11`——跟 implementer 報數字完全一致。

## reeval_attribution 乾淨複核：Team10 具體改善，但非全清
同款乾淨單run（seed1337）：**Team10 從 v2 的 Extinct 滅團，改善為僅 1 筆 famine 事件即存活**——真實進步。但**同一 run 裡 Team1/7/9/14 仍全滅（Extinct）**，Team14 持續 thrash（122 筆 `[Survival]` tag）——這不是新問題（v1/v2 皆有廣泛同型現象），但 sliceA 也沒消滅它。

## 其餘守衛
established/reeval頻率(3186,同量級無爆炸)如上。**HOB determinism/憲法閘本輪沒重跑複核**（前兩輪皆綠，這輪改動集中決策層非site結構，風險低但如實告知未覆核）。層4鋸齒三態未細驗。

## 建議
**大幅進步，但沒有「全綠」**——attrition仍1.3-1.7x main、P25個案沒鎖定、Team1/7/9/14仍全滅。是否達你的release門檻，數字都在這，請你裁。若要更完整，建議：①補一次determinism/憲法閘複核②加team_id指定specimen工具驗P25③層4三態細驗。

## incomplete
P25個案（工具缺口）、層4鋸齒三態、determinism/憲法閘本輪未複核。
