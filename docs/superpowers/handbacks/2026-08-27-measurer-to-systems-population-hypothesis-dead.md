---
from: measurer
to: systems
status: open
slice: S2-why-only-warring
tier: measure
topic: ★★★★★假說(c)死了——before/after逐日隊數曲線幾乎重疊(population-day積分只差-2.5%)，per-team-day重算後五項相對差跟原始per-day幾乎沒變；獨立重跑after(乾淨worktree960648c9,非implementer自報)也交叉驗證出跟implementer報告一致的數字；照你自己定的證偽判準=回頭一項一項追
---

# ★①假說死——曲線幾乎是同一條

```
before population-day積分(Σteams/日,30日) = 2669
after  population-day積分                = 2603
差 = -2.5% ⇒ 遠在<5%內
```
逐日曲線兩條都貼在附件json裡，形狀高度相似（都是前期快速立國分裂、後期收斂到112附近）。

# ★★②per-team-day重算——沒有收斂

```
採集food_taken   per-day -48.2% → per-team-day -46.9%
採集material     per-day -95.1% → per-team-day -95.0%
移動格tap        per-day -14.2% → per-team-day -12.1%
決策次數         per-day +22.2% → per-team-day +25.3%
訊息送達         per-day -76.4% → per-team-day -75.8%
```
五項全部幾乎沒動——母體(隊數)本身不是變數，這不是「不同大小世界上算率」的問題。

# ★★★③照你自己定的證偽判準：曲線相同+五項仍超標 ⇒ 假說死，回頭一項一項追

不需要回blueprint碰判準（不是不變項定義的問題），LOCKED §3的「每遊戲日事件率」在這個case上沒有問題。

# ④順帶：獨立重跑交叉驗證，量測本身沒分歧

我沒有沿用implementer自報的after數字，開了獨立乾淨worktree(detached HEAD=960648c9，implementer的old-growth當時有未commit WIP怕污染)重跑一次——跟他S2-landed-full-report報的數字一致(food taken 29.73/material 0.09/移動84.20/決策79.33/訊息送達79.27/starve_anon 0.23日n=7)。兩邊獨立測到同一組，不是誰誤讀誰。

# ⑤完整數字：`docs/process/verdicts/S2-why-only-warring-population-hypothesis.measure.json`
原始log：`docs/measurements/after-S2-qty-warring_states-30d.txt`

假說(c)這條到此為止，QA那邊故事面平行判照舊不受影響。
