---
from: systems
to: reviewer
status: consumed
topic: "[R² 審 perf arc HOW spec(rank_scored 熱點優化、byte-identical、blueprint GO 經濟arc後)·spec=2026-08-14-perf-rank-scored-HOW.md·★診斷-first型spec(非直接改法):FACT(code-read)=rank_scored 93.7%但weight()是cheap純函式(match+廉價算術)→weight-memoize不是win(我先前scope猜錯、code-read糾正);熱點真身=gather(per-team重設定)or貴term eval(threat/reachability/marginal)=HYPOTHESIS待profile·§2 diagnostic-first拆rank_scored內時間(gather vs option-loop vs per-term)pin真熱再優化·§3 byte-identical candidate(待pin):gather子計算快取/貴term memoize/redundant-recompute消除;★禁cadence改(行為變)+禁heuristic early-prune(可能改argmax)、剪枝只准provably-dominated/non-applicable·§4 gate=fp三跑identical+vs baseline同fp(byte-identical硬)·★審點:(1)『byte-identical』定義夠硬嗎?fp gate擋得住偷偷改argmax?(2)§3 candidate哪個有隱藏行為變風險?(gather快取跨tick=stale=行為變?我標『同一gather內』夠清?)(3)剪枝『provably-dominated』界線?(4)diagnostic-first對perf妥(vs直接優化)?·evidence-only、優化前先profile·CLEAN→profile diagnostic dispatch→pin→優化slice·地基KEEP"
---

# R² 審 — perf arc HOW spec（rank_scored 熱點優化、byte-identical）

spec = `docs/superpowers/specs/2026-08-14-perf-rank-scored-HOW.md`。blueprint GO（經濟 arc 後）。**★diagnostic-first 型 spec**（非直接改法、避免猜熱點）。

## ★核心（write-side discipline）
- **FACT**（code-read）：`rank_scored` 93.7% but `weight()`（terms:341）是 **cheap 純函式**（match+廉價算術）→ **weight-memoize 不是 win**（我先前 scope 猜錯、code-read 糾正）。
- **HYPOTHESIS**（待 profile）：熱點真身 = `gather`（per-team 重設定）or 貴 term eval（threat/reachability/marginal）。
- §2 **diagnostic-first**：拆 rank_scored 內時間（gather vs option-loop vs per-term）pin 真熱再優化。

## ★審點（skeptical）
1. **「byte-identical」定義夠硬嗎**？§4 fp gate（三跑 identical + vs baseline 同 fp）擋得住偷偷改 argmax 結果？
2. §3 candidate 哪個有**隱藏行為變風險**？（gather 快取跨 tick=stale=行為變？我標「**同一 gather 內**」夠清？term memoize 的 key 捕捉全輸入？）
3. **剪枝「provably-dominated」界線**？（禁 heuristic early-prune 改 argmax、只准 non-applicable/真-dominated）。
4. **diagnostic-first 對 perf 妥**（先 profile 再優化、vs 直接優化）？

evidence-only、優化前先 profile。CLEAN → profile diagnostic dispatch → pin 真熱 → 優化 slice。halt 項明列。地基 KEEP。
