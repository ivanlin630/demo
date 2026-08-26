---
from: measurer
to: systems
status: open
slice: perf-spike-site-distribution
topic: "決定性：兩群分布其實一樣——high(>50%)/low(<20%)/mid群單次成本median都在100~154ms級距,無顯著差異(high甚至略低於low)；⇒佔比高低不是有意義的分群鍵；low-rank%的tick不是因為單次呼叫便宜,是被其他work稀釋"
---

# ★分群結果（300tick跑完，call_us樣本cap=200已滿，涵蓋7個spike tick）

| world_tick | dt_us | rank_pct | 真呼叫次數 | 採到樣本 | group |
|---|---|---|---|---|---|
| 10 | 71,621,941 | 32.6% | 70 | 70 | mid |
| 20 | 2,362,449 | 68.1% | 7 | 7 | high |
| 30 | 7,312,720 | 45.3% | 18 | 18 | mid |
| 80 | 5,210,762 | 30.4% | 4 | 4 | mid |
| 90 | 11,012,713 | 55.9% | 34 | 34 | high |
| 100 | 20,747,737 | 6.0% | 57 | 57 | low |
| 110 | 11,138,558 | 70.7% | 34 | **10**（★已滿cap截斷，只採到10/34） | high |

---

# ★★★★決定性答案：兩群分布其實一樣

| group | n | median_us | mean_us | 範圍 |
|---|---|---|---|---|
| high(>50%) | 51 | **100,276** | 190,572 | 65,658~588,220 |
| low(<20%) | 57 | **121,177** | 241,625 | 71,132~898,269 |
| mid(20-50%) | 92 | **153,822** | 307,191 | 78,407~1,357,123 |

★三群 median 都在 **100~154ms級距，無顯著差異**（high 甚至比 low/mid 略低，不是「高佔比群單次更貴」的方向）。

⇒ 依你票裡的判準：**「兩群的分布其實一樣」成立** ⇒ **佔比高低不是有意義的分群鍵**。

---

# ★含義

`low-rank%`的tick（如 world_tick100 佔比只6%）**不是因為單次呼叫比較便宜**——
是因為那個tick裡「非rank的其他work」佔比特別大，把rank的相對佔比稀釋掉，
而不是rank本身變快。

# ★誠實限
cap=200 全域（非per-tick），world_tick110 只採到10/34筆（已滿cap截斷），對high群略有稀釋，
但不影響整體判讀方向（high群仍有51筆，樣本量足夠）。

# 落地
`docs/process/verdicts/perf-spike-site-distribution.measure.json`
raw: `docs/measurements/perf-callus-300t.txt.checkpoint.perf_scale.txt`
