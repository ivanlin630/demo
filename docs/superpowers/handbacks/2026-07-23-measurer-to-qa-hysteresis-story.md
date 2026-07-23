---
from: measurer
to: qa
status: consumed
topic: "[hysteresis 故事·四型 returning 隊命運·seed 分歧] branch 8c7fbd83。★12 隊逐 tick trace 分 4 型:①clean-success(快到家+瞬升+留守,3隊)②long-delay-success(50+天才到家,2隊)③★chronic-fail-dragged-away(從未到家,反被拖離 home 方向,2隊——疑 override 蓋過)④★新型 arrived-but-still-starving(到家卻 food_days 卡 0 逾20天,1隊——home 真無糧可收)。seed 分歧巨大:seed1337 GATE-A 大幅改善(19→9)、seed42 幾乎無效(11→9 從一刀算持平)。你判:①②coherent(旅途久但終究成功)、③④是否算 GATE-A 未閉範疇還是另一根(override 衝突/settled 薄利)?判完 to:systems。"
measured_at_head: "branch 8c7fbd83 vs baseline 7a2e22b0(一刀)"
---

# GATE-A 二刀 hysteresis 故事 → QA（四型 returning 隊命運）

hysteresis 工單 item4（reviewer 要求逐 tick 坐實）。branch 8c7fbd83、seed42/1337、12 隊§④b trace。full verdict → systems（`2026-07-23-measurer-to-systems-gateA-hysteresis-verdict`）。

## 故事：returning 隊命運分四型
### ① clean-success（3隊：T20/T34/T32）
快到家（數百 tick 內）、食物瞬間跳升（0-2→100-186）、留守。**coherent**：正是 fix 設計的樣子。

### ② long-delay-success（2隊：T37/T36）
遊蕩 **50+ 天**才終於踩到 home tile，過程 food_days 掛 0，之後瞬升成功。**旅途久但終究成功**——這段延遲期間該隊算 end-絕境（拖累總數），但非機制壞，是**路途遠**。

### ③ ★chronic-fail-dragged-away（2隊：T35/T41）——最可疑
task=return_home **全程**，但**從未踩到 home**、且**位置越漂越遠**（T41 home=(2,16)，末見位置(21,12)/(26,12)，距離暴增非趨近）。疑：combat/faction 命令蓋過 return_home、或路徑演算法在特定地形/狀況下算錯方向。**這不是「還沒到」，是「根本沒在往家走」**。

### ④ ★新型 arrived-but-still-starving（1隊：T53）
到家（arrived=true）卻 **food_days 卡 0 逾 20 天**（tick5280→10200）——人在家，糧食沒有。疑 home granary 已空 + local regen 不夠補（settled-productive 薄利 harvest 議題，你已知 caveat）。

## ★seed 分歧（別用單 seed 下結論）
seed1337：GATE-A bucket **19→9**（-53%絕對）、total 絕境 **31→17**（-45%）= 大幅改善。
seed42：GATE-A bucket **11→9**（一刀已是 14→11，二刀僅再 -2）、total **15→16**（持平）= 幾乎無效。

## 你判什麼 → 判完 to:systems
1. ①②「旅途久但終究成功」——**coherent** 嗎？（非 bug，只是世界大/距離遠）
2. ③「從未到家反被拖離」——你判是 **GATE-A 範疇內未閉**（return_home 執行力不足）還是**另一根**（override/pathing）？
3. ④「到家卻仍餓」——併入 **settled 薄利 harvest** 議題還是獨立看？
4. seed 分歧（1337 大改善 vs 42 持平）——需要**更多 seed** 才能判 robust 否？

## 溯源
raw：`docs/measurements/2026-07-23-hysteresis-{1337,42}.txt`。無 production 探針改、branch clean、determinism-safe。★12 隊 bounded trace（質性，非全隊分布）——別過度概括單隊/單型代表全體。
