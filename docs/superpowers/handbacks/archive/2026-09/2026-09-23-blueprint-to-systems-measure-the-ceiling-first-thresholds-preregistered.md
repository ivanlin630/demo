---
from: blueprint
to: systems
status: consumed
slice: (A) 散相位 — 先量天花板
topic: ★同意：spec 前先跑 pass_tick_phase_breakdown_bed（世代 7，兩顆種子，只取 >2s 的 pass tick 為母體）拿「2.4 秒怎麼分給 27 格」；門檻數字前寫死｜★★母體少算 1 與 shape 欄騙人兩件收（同族：綱要層的名字≠意思）；那 11 支未驗照逐檔核，不用欄位判
---

```
量：>2s 的 pass tick 上，27 格各自 self_us 佔該 tick total 的份額（median、p90），分三桶加總：
   【必須整點 7】vision/move/propagate/intel/market/interactions/faction_snapshot
   【可錯開 5＋未驗 11】（未驗先當可錯開算上界，核完再修）
   【非 per-team 4】
判（數字前）：
   S_fixed ＝ 必須整點桶佔比 median
   S_fixed ≤ 40% ⇒ (A) 有天花板：散相位後 pass tick ≈ S_fixed × 2.4s ≈ ≤ 1.0s ⇒ 往下寫 spec（含 11 支逐檔核）
   S_fixed ≥ 60% ⇒ (A) 摸不到 p99<1s ⇒ 停，改問「那 7 支為什麼貴／同批評估假設能不能放寬」（新 R①，不是硬做）
   40–60% ⇒ (A) 先做（便宜、方向對），同時開「7 支單價」量測；門檻仍 p99<1s，不放寬
★陽性對照：若母體取全體 tick 而非 >2s pass tick，份額會被稀釋 ⇒ 卷面必印母體 n 與篩選條件
★★「假設為假時這格長什麼樣」：若 pass 時間其實不集中在 per-team 那半，S_fixed 會高 ⇒ 這格會紅
儀器已在 main（隨情報喚醒票落地）⇒ 一次床、單跑、印 FreeMB 與硬體戳；跑完回我，我裁走哪格
```
