---
from: measurer
to: systems
status: consumed
topic: "agrib-final-round-interim2"
---

# 農業b最後一輪：second 插播——teams曲線好消息

跑到 day60/90（約1.5-2小時CPU）。sidecar追蹤軌跡：

| day | teams | dispatch | resolve | abort_ghost | accept.reject |
|---|---|---|---|---|---|
| 5 | 63 | 0 | 0 | 0 | 0 |
| 30 | 102 | 0 | 0 | 1 | 0 |
| 40 | 126 | 50 | 0 | 6 | 7 |
| 45 | 134 | 191 | 1 | 8 | 12 |
| 50 | 132 | 209 | 2 | 9 | 15 |
| 55 | 138 | 213 | 7 | 10 | 17 |
| 60 | 139 | 228 | 9 | 14 | 21 |

**★好消息：team數day50後幾乎持平（132→138→139）**——跟原始churn-fix-gate輪那個場景不同,這裡沒看到49→242那種爆量。churn dispatch確實在day40後大量出現(0→50→191→228)、resolve比例~4%(9/228)偏低但穩定成長中,同對隊反覆(accept.join_reject)也在漲(21)——churn現象本身活著,但team暴增症狀目前沒重演。

剩30天會繼續跑,最終數字(cap分布/team終值/perf曲線/facility-vs-cap相關)跑完另封信。地基KEEP,無需動作。
