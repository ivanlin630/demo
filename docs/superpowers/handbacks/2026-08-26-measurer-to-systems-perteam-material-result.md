---
from: measurer
to: systems
status: open
slice: material-funnel-unlock
topic: "②逐隊分布=決定性:material>=50只有4/12隊，前3隊吃走80.8%，8隊<50(含1隊=0)——均值74是假象；①tick分布=真缺口,dispatch_builder.attempt是plain bump零tick,需implementer加"
---

# ②day30 private material 逐隊分布 —— **均值 74 是假象**

12隊全量（非樣本，無cap問題），由大到小：

| team | material |
|---|---|
| 4 | 250 |
| 3 | 246 |
| 7 | 159.8 |
| 5 | 65 |
| 11 | 26.8 |
| 0 | 18.8 |
| 10 | 15.4 |
| 2 | 8.3 |
| 9 | 7.8 |
| 6 | 7.4 |
| 1 | 6.7 |
| 8 | **0** |

★**`material >= 50` 只有 4 / 12 隊。**
★★**前 3 隊（4/3/7）持有 250+246+159.8 = 655.8，佔全部 811.9 的 80.8%。**
其餘 9 隊只分到 156.1，其中 1 隊（team8）＝0，另 4 隊個位數（6.7~8.3）。

**只列事實**：均分 74 這個數字，跟「大部分隊 <50」是兩件不同的事——material 高度集中在少數隊。

---

# ①tick分布 —— 真缺口，我沒法自己補

`dispatch_builder.attempt`（`faction_ai_system.gd:3803`）是 plain `Probe.bump()`，無 tick 欄。
同段 `funnel.build_gate.*`（六道閘）**全部也是 plain bump，零 tick sample**，沒有現成替代可用。

需要 implementer 在 `faction_ai_system.gd:3803` 加一行 `bump_sample` 帶 `tick`
（函式內 `state.world.current_tick` 本來就可讀），**cap 建議 ≥100**（遠大於 attempt 真 count，避免 first-N 截斷——上次 30 那個 cap 就是這樣被打滿的教訓）。
不自己加（`scripts/simulation/` 屬 implementer territory），不用鄰近 counter 推。

# 落地
`docs/process/verdicts/material-funnel-perteam.measure.json`
raw: `docs/measurements/breed-deathcause/material-funnel-30d.txt`（已更新逐隊區塊）
