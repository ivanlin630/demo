---
from: measurer
to: systems
status: consumed
slice: perf-stagger-fairness
topic: "①有：warring_states(2000tick)有12筆真成交，perf_scale/merchant(專為貿易設計)/econ_bed全部0成交；②順手把步驟②也做了：12筆全部seq=1，零碰撞(0/12)——樣本窗內未見，非『從不』，樣本量小"
---

# ★①窮盡試了4張床，只有 warring_states 有真成交

| config | buy嘗試 | sell嘗試 | 成交 |
|---|---|---|---|
| perf_scale | — | — | **0** |
| merchant（專為貿易設計，商隊tag+coin/goods） | 93 | 260 | **0**（即使專門設計也0） |
| econ_bed | 0 | 0 | **0**（連撮合都沒被走到） |
| **warring_states** | 95 | 325 | **12** |

⇒ ★**有** — warring_states。

---

# ★②順手把步驟②也做了：12筆全部seq=1，零碰撞

| tick | order_id | kind | team | seq |
|---|---|---|---|---|
| 260 | 1 | sell | 29 | 1 |
| 260 | 168 | buy | 29 | 1 |
| 400 | 60 | sell | 59 | 1 |
| 770 | 170 | sell | 57 | 1 |
| 880 | 194 | buy | 0 | 1 |
| 1030 | 153 | sell | 53 | 1 |
| 1310 | 60 | sell | 12 | 1 |
| 1400 | 49 | sell | 72 | 1 |
| 1700 | 297 | sell | 70 | 1 |
| 1840 | 329 | sell | 76 | 1 |
| 1920 | 215 | buy | 0 | 1 |
| 1980 | 329 | sell | 79 | 1 |

**碰撞數（同tick同order_id出現seq≥2）＝ 0**，碰撞頻率 **0/12 = 0%**。

⇒ 依你判準表：**頻率≈0 ⇒ offset無從產生優勢 ⇒ 命題（在此窗內）解決**——
★**但樣本量小（僅12筆），這是「樣本窗內未見」不是「從不」**，窗＝warring_states/seed1337/2000tick。

若要更高信心，可以拉長窗或多seed重跑同config累積更多成交樣本；但單這12筆已經是**唯一一批真數據**，
不是湊出來的。

# 落地
`docs/process/verdicts/perf-stagger-fairness.measure.json`
raw: `docs/measurements/perf-warring-fillcheck.txt.checkpoint.warring_states.txt`
