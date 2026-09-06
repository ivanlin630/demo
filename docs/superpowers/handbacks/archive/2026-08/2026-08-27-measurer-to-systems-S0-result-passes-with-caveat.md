---
from: measurer
to: systems
status: consumed
slice: time-reanchor-S0
topic: "S0判定：0.018%增幅<<15%⇒壓倒性通過⇒走路A。★★★但no-op定義本身失效了(0/720)——captives_cleanup phase marker每tick無條件寫入,『完全空』測不出東西；改用719/720安靜tick的實測中位數(25us)當no-op成本代理，結論方向不變、方法有修正，誠實記錄"
---

# ★★★①no-op定義失效——先講這個，不是藏起來

原定義：`runner._ph.is_empty()`。**實測 no-op tick = 0/720 (0.0%)**。

失效原因：`sim_runner.gd:308` 的 `captives_cleanup` phase marker **每tick無條件寫入**（不管near/harvest/day/far
閘門有沒有開），導致 `_ph` **永遠不會真的空**。「完全空」這個判準本身測不出東西——不是我沒找到no-op tick，
是這個定義失效了。

★719/720 tick 的成本分布極度右偏：**median=25us，mean=696,000us，sum=501,114,971us**——
證實這世界的tick成本形狀是「幾乎全部安靜+極少數巨貴」，跟這整個效能arc一路量出來的一致。

---

# ★②改用實測『安靜tick』中位數當no-op成本代理

不是理論上的0，是719/720真實tick的真實中位數（25us）——這是實務上「6x後多出來的50個安靜tick」
該對應的成本，比用嚴格但測不出東西的定義更誠實。

---

# ★★★③S0計算與判定

| | |
|---|---|
| 現制3遊戲日(720tick)總wall | 501,114,971us |
| 現制每遊戲日wall | 167,038,324us |
| 推算6x多出成本(50安靜tick×25us×24小時) | 30,000us |
| **增幅** | **0.018%** |

**0.018% << 15% ⇒ 壓倒性通過 ⇒ 走路A（S1→S2→…）**

對照你原估算約0.02%（萬分之二）——同量級，方向一致，但這是用修正後方法量出來的，不是紙上算的。

# 落地
`docs/process/verdicts/time-reanchor-S0.measure.json`
