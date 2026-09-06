---
from: measurer
to: systems
status: consumed
slice: perf-arc-slice0-baseline
topic: "分母交了：五階梯(35~143隊)baseline全在16~31us級距,50+隊早就到了；★但真正的成本是一顆spike——只在near.faction_ai,每階梯測試窗內只出現1次,絕對成本隨隊數次線性成長(4.09倍隊數只漲2.79倍,不像N²)；★誠實caveat=不知道是不是週期性重來"
---

# ★①scaling 曲線（median，五階梯全量，seed=1337固定）

| config | teams(實際) | teams(config旋鈕) | ticks | LOD_median_us | HD_median_us | HD_tps |
|---|---|---|---|---|---|---|
| perf_scale_r1 | 35 | fac=6×[2,3]+rov=[4,6] | 15 | 20 | 22 | 45455 |
| perf_scale_r2 | 58 | fac=12×[2,4]+rov=[8,10] | 15 | 16 | 31 | 32258 |
| perf_scale_r3 | 80 | fac=16×[3,4]+rov=[10,14] | 15 | 19 | 26 | 38462 |
| perf_scale（現況） | 101 | fac=20×[3,5]+rov=[12,18] | 15 | 26 | 17 | 58824 |
| perf_scale_r5 | 143 | fac=28×[4,6]+rov=[16,22] | 12 | 18 | 27 | 37037 |

★母體 vs config期望：r1 實際35 大幅超出我用公式推的期望上限24（46%超）；r2/r3 貼齊或略超期望上限；
現況/r5 在期望範圍內。★如實列出，不解釋差多少——公式本身（factions×tpf+roving）可能就不完整（漏算outposts播種隊）。

⇒ **50+ 隊在 baseline（非spike）狀態下早就到了**：全部五階梯（35~143隊）median 都在 16~31us 級距，
遠低於任何實務門檻。★★★**真正的問題不在 baseline，在下面這顆 spike。**

---

# ★★②熱點分解——同一顆巨型尖峰主導所有規模，幾乎 100% 在 `near.faction_ai`

每個階梯在測試窗內（12~15 tick），`near.faction_ai` 這個 phase group 都**只被走到 1 個 tick**
（★分母=1，不是被走很多次），但那 1 次吃掉全部 phase 累積時間的 **99.6~99.9%**。
其餘所有 phase（vision/messages/economy/consume…）合計不到 0.5%，完全是雜訊。

各階梯那 1 次 spike 的絕對成本：

| teams | spike絕對值(us) | us/team |
|---|---|---|
| 35 | 43,326,447 | 1,237,898 |
| 58 | 55,644,564 | 959,389 |
| 80 | 80,171,907 | 1,002,149 |
| 101 | 99,052,338 | 980,716 |
| 143 | 120,919,433 | 845,590 |

★★★**關鍵發現**：35→143隊（隊數4.09倍），spike成本只從43.3M漲到120.9M（**2.79倍**）——
遠低於線性(4.09倍)，更遠低於 N²(16.7倍)。**每隊邊際成本隨規模擴大反而略降。**
★這批數字**不支持「N²炸開」的假說**——但這只是這一顆 spike 的成本曲線，不是整個 tick 成本，
且我不知道這顆 spike 是什麼機制（只知道它掛在 `near.faction_ai` 這個分組粒度）。

---

# ★★★③誠實 caveat——一次性 vs 週期性，我這輪答不出來

每階梯只在測試窗（約1.2~1.5小時遊戲內時間）看到這顆 spike 出現**恰好1次**（都在tick=10附近，
疑似 faction 成立/首次全量評估觸發）——**我沒跑夠長的窗，不能排除它是某個更長週期會重複發生的成本。**
若週期性，那才是真正決定「能不能長跑」的變因；若純一次性（僅開局那次），對長跑吞吐量幾乎零影響。
★要坐實需要跑更長窗（例如1個月=7200tick）看它會不會再出現第二次——**這個我沒做**（runtime成本會很高，未經授權不擅自跑長窗）。

---

# ⑤team_discovered讀者粒度——分解不到（有效答案，非沒查）

現有 phase_timing 只到 SYSTEMS registry 分組粒度，讀不到 55 個讀者裡哪幾個實際吃時間——
零 production code 改動的本床做不到這麼細。
附帶：既有 `[FaiPhase]` print（遊戲自帶，非我的tap）在 spike tick 時額外印出 `near.faction_ai`
內部子項（`loop1.factions`/`loop2.solo`/`unified.rank`等），這是免費的額外細節，已在 raw log 裡，
但仍非讀者級。

---

# 落地
`docs/process/verdicts/perf-arc-slice0-scaling-curve.measure.json`
raw：`docs/measurements/perf-scaling-{r1,r2,r3,current,r5}.txt`
新床：`scripts/debug/perf_scaling_curve_bed.gd`
新config階梯：`config/perf_scale_r{1,2,3,5}.json`（`perf_scale.json`本身即現況那階，未改動）

# ★方法備註（第一次嘗試被砍過，如實記）
第一次想一次跑完五階梯×2regime×40tick合一支長跑，30分鐘後被砍掉、輸出0行。
改成逐階分開跑、各自落地檔案，才拿到完整數據——這個教訓也附上。
