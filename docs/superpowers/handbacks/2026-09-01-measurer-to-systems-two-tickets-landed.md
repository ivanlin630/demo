---
from: measurer
to: systems
status: open
slice: S6-denominator-split / S7-lod-production-neutrality
tier: measure
topic: ★★★★★兩張票都落地——①隊-日+21.3%拆分:population-day積分實際只+11.9%(期末快照高估)，前段(day1-10)after反而少-12.1%、後段(day21-30)after多+27.1%，形狀比較像【隊活更久累積】不是【建國潮】，但沒有直接死亡計數佐證(零新跑限制)；②LOD產出中性性:far/near≈0.47~0.53(不是推導的1/10也不是1/1，第三種答案，方向違規但量級小很多)，附一個沒能完全排除的population分岔confound(11→near1/far9)已誠實標記
---

# ★①隊-日拆分：形狀像【存活】不是【建國潮】

```
population-day積分：before 2412 → after 2699 (+11.9%，比期末快照+21.3%小很多)
day1~10：before 686 → after 603 (-12.1%，after前段隊數較少)
day21~30：before 914 → after 1162 (+27.1%，after後段明顯較多)
```
after起步較慢、隨時間拉開差距後段反超——比較像存活率提升/流失減少的累積形狀，不是一開始就建國建得快。**沒有直接死亡/滅團計數佐證**（extinct.*是既有tap但這輪床沒印，零新跑=沒補），若要更硬的答案我可以再跑一輪加印。

# ★★②LOD產出中性性：第三種答案

```
arrows產出/日：near 0.4023 → far 0.1909，比值0.474(≈1/2.1)
fired次數：near 137 → far 72，比值0.526(≈1/1.9，互相佐證)
```
不是推導的1/10，也不是1/1——far明顯少於near(違規方向成立)，但量級只有推導預測的約1/5大小。推導只講對方向沒講對量級。

# ★★★③一個誠實限：population分岔(11→near1/far9)

單隊實驗理論上labor_share≈1不受絕對population影響(pool_of分子分母同隊)，但没能完全排除間接影響(如skill成長速率)。population為何分岔沒查出根因(不是food/material短缺，兩邊都塞爆量)，標記為已知局限。

完整數字：`docs/process/verdicts/S6-denominator-split.measure.json`、`docs/process/verdicts/S7-lod-production-neutrality.measure.json`
新床：`scripts/debug/s7_lod_neutrality_bed.gd`(純觀測，零production改動)
