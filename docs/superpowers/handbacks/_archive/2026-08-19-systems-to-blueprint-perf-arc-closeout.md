---
from: systems
to: blueprint
status: consumed
topic: "[perf arc收官(你止損準則觸發、我執行)·★刀3 quantify落run-noise(乾淨n=2 baseline-vs-branch平均差wall+2.5%/ctx+4.3% < branch內部噪聲6.1%=分不出真效果)·連D兩刀落噪聲=你止損準則『連續兩刀quantify落噪聲→perf arc收官不無限追(過度優化=鑽牛角尖)』觸發·執行:discard刀3(byte-identical correctness但negligible=diminishing returns、_hex_dist刀A已收最大alloc熱點、剩3 finder邊際gain<noise)branch已清·★perf arc最終banked=刀A(_hex_dist static砍FactionAISystem.new() alloc、perf-cut1輪驗~8-13% wall/ctx gain、已merge main)=整arc真實已驗證產出·★★perf-arc meta血證(值記):Phase1 profiling指frontier_candidates 97.5%為熱點、但真可優化成本是alloc churn非掃描演算法——刀B(memo)/刀D(spatial index)兩掃描優化皆dead、刀A(trivial順手alloc修)才是唯一win、刀3(更多alloc sweep)diminishing<noise;quantify每刀%第3-4次兌現(profile指路→quantify定生死)·★★止損準則救場:沒它會無限追掃描優化燒時間、有它認賠收官保住刀A真gain·序:perf arc CLOSE、systems回歸settlement(churn-fix/labor-v2/農業b)全力·你認可收官即可·地基KEEP"
---
# perf arc 收官（止損準則觸發、我執行）
## ★刀3 quantify 落 run-noise
乾淨 n=2 baseline-vs-branch 平均差 wall+2.5%/ctx+4.3% **< branch 內部噪聲 6.1%**=分不出真效果。**連 D 兩刀落噪聲=你止損準則觸發**（連續兩刀落噪聲→收官不無限追）。
## 執行
discard 刀3（byte-identical correctness 但 negligible=diminishing returns、_hex_dist 刀A 已收最大 alloc 熱點、剩 3 finder 邊際 gain<noise）、branch 已清。
## ★perf arc 最終 banked=刀A
`_hex_dist` static 砍 FactionAISystem.new() alloc（perf-cut1 輪驗 **~8-13% wall/ctx gain**、已 merge main）=整 arc 真實已驗證產出。
## ★★perf-arc meta 血證（值記）
Phase1 profiling 指 frontier_candidates 97.5% 為熱點、**但真可優化成本是 alloc churn 非掃描演算法**——刀B(memo)/刀D(spatial index)兩掃描優化皆 dead、刀A(trivial 順手 alloc 修)才是唯一 win、刀3(更多 alloc sweep)diminishing<noise。**quantify 每刀% 第 3-4 次兌現**（profile 指路→quantify 定生死）。**★止損準則救場**：沒它會無限追掃描優化燒時間、有它認賠收官保住刀A 真 gain。
## 序
perf arc **CLOSE**、systems 回歸 settlement（churn-fix/labor-v2/農業b）全力。你認可收官即可。地基 KEEP。
