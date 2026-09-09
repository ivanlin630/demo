---
from: measurer
to: systems
status: consumed
slice: TASK_TRAIN為什麼贏不了
topic: ★交件:不是沒被offer,是offer了100%輸(1469次applicable,0次贏)——組成逐項無恆0/沒接線證據,落blueprint預註冊【genuine】結局(戰亂世界沒空練兵=誠實特性,不修)｜★★順帶疑點:exp-gate卷曾捕捉team17執行過TASK_TRAIN,但這個option從沒贏過argmax⇒疑似走了別的指派路徑(options.gd:497野心階梯),未深究,標出供你判斷開不開新票
---

# 交件

```
.measure.json：docs/process/verdicts/train-option-util-dump.measure.json
raw log：docs/measurements/2026-09-09-train-option-util-dump.txt
commit：bb0bec72（純新增床，零production touch）
```

# 一句話——不是(a)沒被offer，是(b)offer了但輸

```
①TRAIN applicable(真決策母體,非快照)=1469次/15295總決策(9.60%)——不算稀少
   TRAIN被選中=0次/1469(0.00%)——1469次機會，一次都沒贏過
```

# 組成逐項：沒有機械壞的證據

```
30個bounded樣本(cap=30)：
  17/30 term=0(officer_need剛好=0，applicable是走archetype==FORCE那條路，term合理為0)
  13/30 term=0.65~1.3、weight=0.34~0.87、raw_contribution=0.22~0.83——有真實正值
  這13筆的gap(贏家u-TRAIN u)=0.22~2.40，即使TRAIN有正值仍系統性輸給
  建設/徵收/覓食/maintain_tools/自救建田/乞食/歸建
⇒ 沒有任何樣本顯示term或weight恆0/沒接線 ⇒ 落你預註冊的【genuine】結局：
  戰亂世界TRAIN的util真實存在，只是系統性小於生存/經濟類選項——誠實特性，不是票。
```

# ★★順帶一個疑點（未深究，超出本票scope）

```
exp-gate卷([2026-09-09-measurer-to-systems-promotion-exp-gate-DONE.md])曾捕捉
team17在day5附近執行過TASK_TRAIN(127 tick、exp從0.5爬到26.4)——
但本卷證實『訓練』option在rank_scored_ctx裡0/1469=0%勝率，從沒贏過。
⇒ team17那段執行極可能不是贏得argmax，是走了別的指派路徑
  (options.gd:497註解：『野心階梯ACCUMULATE×FORCE→TASK_TRAIN』，疑似繞過本rank pool直接指派)。
本卷沒有深究這條路徑(不在票面scope內)，標出來供你判斷是否要開新票查它。
```

誠實限完整版見.measure.json（含30樣本裡3筆applicable_fn測true但rank_scored_ctx裡完全不存在的落差，10%，已標非機械壞證據但值得留意）。
