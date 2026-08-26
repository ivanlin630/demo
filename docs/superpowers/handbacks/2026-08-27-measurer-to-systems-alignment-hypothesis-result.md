---
from: measurer
to: systems
status: open
slice: perf-spike-coverage
topic: "對齊假說：確認但非唯一主因——ambition每~100tick爆一次(105~110隊同批)、order每~120tick爆一次(105~106隊同批)，burst tick dt中位數比non-burst高3.5倍(統計顯著)；★但有重疊(non-burst最大值25M > 多個burst tick)，代表loop2.solo/unified.rank那條路獨立也會把某tick撐很貴，不靠對齊"
---

# ★①對齊確認：真執行次數集中爆發，不均勻分布

跳過 tick9（開局全員第一次 cadence，101/101 一起爆，正常）：

| tick | ambition_fired | order_fired | dt_us |
|---|---|---|---|
| 109 | 105 | 0 | 12,957,823 |
| 129 | 0 | 105 | 18,121,379 |
| 209 | 107 | 0 | 4,039,243 |
| 249 | 1 | 105 | 37,762,163 |
| 309 | 108 | 0 | 2,929,094 |
| 369 | 2 | 106 | 16,887,122 |
| 409 | 110 | 1 | 3,014,230 |
| 489 | 0 | 106 | 26,380,169 |

其餘37個spike tick，af/of都是個位數（0~9，零星幾隊個別重評）。

⇒ ★**ambition大約每100tick爆一次（105~110隊同批），order大約每120tick爆一次（105~106隊同批）**
——不是均勻分布，是對齊集中爆，跟 `known_issues:912` 的舊機制診斷一致。

---

# ★★但對齊不是唯一主因——相關性只是部分的

| | |
|---|---|
| burst tick dt中位數（排除tick9） | 14,922,472us |
| non-burst tick dt中位數 | 4,222,220us |
| 倍率 | **3.5倍**（統計上顯著） |

★**但有重疊**：non-burst 最大值 **25,077,312us(tick99)** > 多個burst tick（tick209=4M／tick309=2.9M／tick409=3M）。

⇒ **對齊burst確實讓那個tick貴，但不是唯一驅動整體spike的原因**——有些non-burst tick(如tick99)
一樣貴甚至更貴，代表 `loop2.solo`／`unified.rank` cross-cutting 那條路本身也會獨立地把某個tick撐很貴，
不靠 `orders_ambition` 對齊。

# 落地
`docs/process/verdicts/perf-orders-ambition-alignment.measure.json`
raw: `docs/measurements/perf-alignment-500t.txt.checkpoint.perf_scale.txt`
