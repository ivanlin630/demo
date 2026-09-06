---
from: measurer
to: systems
status: consumed
slice: perf-spike-denominator
topic: "決定性：dt/次數 CV=0.84(13.4倍範圍)，不是常數 ⇒ 單次決策成本才是問題，非決策次數；真呼叫次數(median 9)只有eligible headcount(median 129)的7%，且本身劇烈波動(2~70)不穩定跟著隊數走；建議往下鑽gather.*"
---

# ★★★①③決定性結果：dt/次數變異巨大，不是常數

| | |
|---|---|
| dt_per_call 中位數 | 496,332 us |
| dt_per_call 平均 | 683,296 us |
| CV（變異係數） | **0.838** |
| 範圍 | 238,849 ~ 3,207,562 us（**13.4倍差距**） |

★依你判讀表：**CV=0.84遠非常數，13.4倍範圍** ⇒ **單次決策成本才是問題，不是決策次數** ⇒
建議往下鑽 `gather.*`（你的巢狀圖已指出它在 `unified.rank` 內部更深一層）。

---

# ★②headcount(上限) vs 真呼叫次數——巨大落差，本身是發現

| | |
|---|---|
| `rank_calls`（真呼叫，新tap） | 中位數 **9**，範圍 2~70 |
| `faction_deciders+solo_candidates`（eligible上限） | 中位數 **129** |
| 比例 | **只有約 7%** 的候選決策者那個 hourly 真的被重新評估 |

★`_should_reeval`(:2549) cadence 節流把 93% 的候選擋掉——你的 Σ(1+members) headcount 只是【上限】，
★★**真正驅動成本的分母遠比它小，而且本身劇烈波動（2~70，35倍範圍），不隨隊數/tile數穩定成長。**

---

# ★★★三方假說最終裁定

| 假說 | 判定 |
|---|---|
| cost ∝ teams | ❌ 已排除（長窗票） |
| cost ∝ tiles | ❌ 已排除（radius票） |
| cost ∝ 決策次數 | ❌ **本輪排除**——dt/次數CV=0.84非常數，真呼叫次數本身劇烈波動、不穩定跟著headcount走 |

**剩下的路**：單次決策成本本身不穩定，需要往下鑽 `gather.*`。

---

# ★樣本
800tick跑到tick729/800（91%）被砍，**checkpoint機制保住70筆完整記錄**——這是決定性樣本量。

# 落地
`docs/process/verdicts/perf-spike-denominator-final.measure.json`
raw: `docs/measurements/perf-rankcalls-800t.txt.checkpoint.perf_scale.txt`
