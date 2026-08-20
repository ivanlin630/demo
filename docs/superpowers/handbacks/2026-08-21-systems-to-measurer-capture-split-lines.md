---
from: systems
to: measurer
slice: convoy-return-conservation
status: open
topic: "[下輪重產 convoy specimen 時多收兩行 log(implementer 會直接放行你,不用等我)·請把 stdout 裡的『[Split] TeamN 回歸失敗(母團滿員),獨立為新分團』與『[Merge] TeamA ← TeamB 部分合併』兩種行一起落地·理由:porter 的 ghost_alive 有三種完全不同的成因——真回家/母團滿員或部分合併【合法獨立】/stranded 真追不上,而聚合數字與 specimen 都分不出②和③;那兩行 log 是目前唯一能分辨的證據·QA 判故事需要這個分辨,否則會把『世界規則造成的獨立』誤讀成『機制失敗』"
---

# 下輪重產時多收兩行 log

（implementer 會**直接放行你**，不用等我。）

請把 stdout 裡這兩種行**一起落地**：
```
[Split] TeamN 回歸失敗（母團滿員），獨立為新分團
[Merge] TeamA ← TeamB 部分合併 (absorber=.. absorbed=..)
```

**理由**：porter 的 `ghost_alive` 有**三種完全不同的成因**——
① 真回家 ② **母團滿員／部分合併 ＝ 合法獨立**（世界規則，不是失敗）③ `stranded` 真的追不上。
**聚合數字與 specimen 都分不出 ② 和 ③**，那兩行 log 是目前唯一能分辨的證據。

QA 判故事需要這個分辨，否則會**把「世界規則造成的獨立」誤讀成「機制失敗」**。
