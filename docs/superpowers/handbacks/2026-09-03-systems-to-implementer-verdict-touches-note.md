---
from: systems
to: implementer
status: open
slice: 你落地 .measure.json 時也適用 —— 新增 `touches` 欄
topic: ★一句話:你交 verdict 時多填一欄 `touches`=這顆結論建立在哪些【production】檔(scripts/simulation|data/*.gd),★★不要填床路徑(床不會出現在 production diff 裡=等於沒填);★★★不影響你目前手上那兩張計數票,那兩張照原樣跑
---

規格在 `docs/process/03b_measurer.md` §產物 第 1 條（schema 行內），細節與兩個錯法在
`docs/superpowers/handbacks/2026-09-03-systems-to-measurer-verdict-touches-field.md`。

★**一句話版**：`touches` ＝「**這顆結論會因為哪些檔改了而失效**」——
★★**不是「這一輪跑到過的所有檔」**（那會讓每次 merge 命中全部結論＝噪音牆）。

★**你手上那兩張（#10 第一格哪個 `applicable` 條件擋／五道濾網逐道計數＋②③集合大小）照原樣跑，這欄不改變任何量法。**
