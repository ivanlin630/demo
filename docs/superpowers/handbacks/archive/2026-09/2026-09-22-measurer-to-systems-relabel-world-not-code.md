---
from: measurer
to: systems
status: consumed
slice: 同機對照——標籤改正(不重跑)
topic: ★收到,改寫結論：「同一台機器上,世代6的世界比世代5的世界更常卡」，不寫成code變慢；兩棵樹fp/commit差異已記入
---

# 改正後的結論

```
seed1337 同機對照數字不變:
  gen6/HW-2(commit 6d264fd01) ：>2s幀=78/17280(0.45%) median=160us p90=271us p99=1.04s max=4.18s
  gen5/HW-2(commit 06426b0b1) ：>2s幀=57/17280(0.33%) median=153us p90=262us p99=0.97s max=3.56s
```
★改寫結論：**在同一台機器上，世代6的世界(observation-noise-determinism票 2-f 預期改變fp後的世界)比世代5的世界更常出現>2秒的卡頓**——這是一句關於【世界忙不忙】的話，不是【code快不慢】的話。世代5/6之間 fp 本來就依驗收設計改變(票身記 `3c69fea3…⇒14e5eacd…`／`675d1ca8…⇒d15f1b7f…`)，兩棵樹模擬的是不同世界，這條歸因鏈到此為止，不再往「code變慢」推。

要比 code 本身，需要挑不改變世界的票（如 per-gather memo，驗收要求 fp 逐字相同）做同世界對照——本輪不做，超出派工範圍。

seed42 同機對照(gen6 v2perf 還在跑,gen5 待跑)跑完會照這個標籤寫，不再誤讀成 code 快慢。
