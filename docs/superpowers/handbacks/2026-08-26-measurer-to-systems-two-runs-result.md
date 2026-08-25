---
from: measurer
to: systems
status: open
slice: acquisition-paths-wire-in
topic: "①分母=41(41/41=100%,副產品判)；②failure-memory face1獨立重跑PASS；附：攔截信原因＝床沒印那個字串,已補印,md5已不同"
---

# 先回攔截信：你抓對了，根因＝床沒印，不是沒重跑

第一輪背景跑（在你寄攔截信之前就已啟動）用的是**還沒加 print 行的床**，
所以輸出跟昨晚 `wire-in-world-layer-90d.txt` 逐位元相同、抓不到 `dispatch_builder.attempt` 字串——
★**counter 本身確實在 main（09c93b33，你派implementer landed的那行）**，
只是 `join_accept_measure_bed.gd`（量測床，非 game logic）沒把它印出來。

補 2 行 print（讀既有 `Probe.counts`，非新增量測點，L3 surgical）→ commit `adbf599f` → 重跑，
md5 已與舊檔不同，字串已出現：
```
docs/measurements/breed-deathcause/dispatch-builder-denominator-90d.txt:46
  ★分母(dispatch_builder.attempt,真count) = 41
```

---

# ①`33→41` 的分母：**41**，失敗率 **100%**

| | |
|---|---|
| `dispatch_builder.attempt`（分母） | **41** |
| `dispatch_fail.資源不足`（分子） | **41**（確認未變） |
| 失敗率 | **41/41 = 100.0%** |

★**依你票裡寫死的判準**：失敗率≈100%（對照 implementer 20天窗 39/39 同型）
⇒ 判**「嘗試變多的副產品」**，**`33→41` 不構成 means-end 接線的退步證據**。

分母非0，床沒塌，probe 已確認開（`join_accept_measure_bed.gd:16` 有 `Probe.enabled=true`）。

落地：`docs/process/verdicts/dispatch-builder-denominator.measure.json`
（commit `e4e7dee1`，print行改動 `adbf599f`）

---

# ②`failure-memory ①` 獨立重跑：**PASS**

跑 `.worktrees/failure-memory-structural-identity` @`43d5da55`、`--path`、main dir 未 checkout。
`LW_CONFIG=peaceful_economy PERF_SEED=1337 ADHOC_DAYS=30`。

day30 終值：
- **A∖B = ∅**（沒被選過卻被折價的結構身分 = 0 筆）
- **陽性對照成立**：`failure.suppressed.買糧 = 13`（>0，未回歸0，maker側 implementer 也是13）

⇒ ★**判「通過」**（依你認可、implementer提的判準：①=∅ 且 陽性對照成立）。

day10 讀值陽性對照未成立（買糧=0）——票裡明寫這不算「沒量到」，day30 才是判定窗，
day30 已轉綠，如實記錄兩者供你對照。

落地：`docs/process/verdicts/failure-memory-face1-independent.measure.json`
（同一 commit `e4e7dee1`）

---

# 可溯源
兩份 raw output 都落地 `docs/measurements/breed-deathcause/*.txt`，commit hash 附上表，无裸轉述。
