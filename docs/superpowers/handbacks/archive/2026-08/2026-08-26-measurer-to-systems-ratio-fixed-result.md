---
from: measurer
to: systems
status: consumed
slice: perf-spike-per-call
topic: "比率修正後：dt_per_call_true中位數220,795us(0.22s,非之前錯的0.5s)、CV=0.435(非0.838)——修正影響顯著；★新發現：unified.rank只佔整tick的43.7%,另外56.3%發生在它之外；top-1集中度需新tap才拿得到,本輪缺口"
---

# ★修正後結果（800tick完整跑完，75筆有效）

| | 修正前(錯分子) | 修正後(同母體) |
|---|---|---|
| dt_per_call 中位數 | 496,332us | **220,795us（0.22秒）** |
| CV | 0.838 | **0.435** |
| 範圍 | 13.4倍 | 33倍（絕對值窄很多，倍數關係較大因為分母小） |

★**你猜「可能影響不大」——實測影響顯著**：中位數降56%、CV降48%。這條法沒白立。

---

# ★★★新發現：unified.rank 只佔整tick的43.7%

```
rank_us(unified.rank自己計時)中位數 = 2,117,569us
佔整tick dt_us的比例中位數 = 43.7%
```

⇒ **另外56.3%的spike成本發生在`unified.rank`之外**——可能是`loop1.factions`其他子階段
（`member_snap`/`update_goals`/`infra`/`diplo`/`betray`）、迴圈本身迭代開銷、或`phase_timing`完全沒接到的部分。
★修正前的「0.97秒/次」是被這部分污染放大的假象；**真正單次`rank_scored()`成本是0.22秒**，
仍不小，但沒有之前想的誇張。

---

# ★單次呼叫成本分布（top-1集中度）——需新tap，本輪拿不到

現有機制（`_fai_pht`）只累加總量，沒有記錄「每一次」呼叫各花多少。要拿到 top-1 佔比，
需要在 `faction_ai_system.gd:2561` 附近加一個 `bump_sample`：

```gdscript
if Probe.enabled: Probe.bump_sample("unified.rank.call_us", {"us": (單次elapsed), "team": team.team_id}, cap>=100)
```

這是 production code 改動，我不自己動——跟你說一聲，你走 implementer 那條線。

---

# 落地
`docs/process/verdicts/perf-spike-per-call-fixed.measure.json`
raw: `docs/measurements/perf-ratiofixed-800t.txt.checkpoint.perf_scale.txt`
