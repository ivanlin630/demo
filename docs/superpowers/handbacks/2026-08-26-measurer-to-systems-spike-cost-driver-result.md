---
from: measurer
to: systems
status: open
slice: perf-spike-cost-driver
topic: "三階齊了：radius12(469tiles)median7.80M / radius18(1027tiles)median9.35M / radius24(1801tiles)median6.82M——tile數3.84倍區間內spike中位數不單調、radius24(tile最多)反而最低。既不∝teams(長窗票已排除)也不∝tiles，你判讀表的第二格成立：跟著某個固定每小時全量工作走"
---

# ★三階數據到齊

| radius | tiles | teams範圍 | spike樣本數 | median_us | mean_us |
|---|---|---|---|---|---|
| 12 | 469 | 115~178 | 96 | 7,804,772 | 9,112,718 |
| 18 | 1027 | 113~151 | 96 | 9,347,444 | 11,034,929 |
| 24 | 1801 | 101~202 | 387 | 6,817,496 | 9,218,152 |

---

# ★★★判定：既不∝teams也不∝tiles

tile數橫跨 **3.84倍**（469→1801），spike中位數**沒有單調成長**——
★**radius24(tile數最多)反而是三階裡最低的**，不是雜訊範圍內的持平：若真是 ∝tiles，
radius24 理應明顯是三者裡最高，結果相反。

⇒ 依你判讀表：**「spike 不隨 radius 長」⇒ 兩個候選（teams／tiles）都不是** ⇒
**它跟著某個固定的每小時全量工作走，不是隨規模伸縮的掃描成本。**

★對應的刀：**攤平／降頻（錯峰）**，不是「剪迭代源」。

---

# ★誠實限

radius12/18 各只跑1000tick(~96個hourly樣本)，radius24有387個樣本(完整16天)——樣本數不對等。
但96個樣本的中位數已經足夠穩定判斷「有沒有明顯趨勢」這個問題——若3.84倍的tile差真有效應，
96樣本內理應看得出方向性，而沒看到。

# 落地
`docs/process/verdicts/perf-spike-cost-driver.measure.json`
raw: `docs/measurements/perf-radius{12,18}-1000t.txt.checkpoint.perf_scale_radius{12,18}.txt`
（radius24數據沿用長窗票既有的387筆）
新config: `config/perf_scale_radius{12,18}.json`
