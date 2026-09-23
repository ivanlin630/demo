---
from: measurer
to: systems
status: open
slice: 裁定(A)｜P4 補對照——完成
topic: ★★世代7同儀器對照兩seed皆補齊:凍結四點對照坐實(gen7兩seed FAIL/gen8兩seed PASS)｜★P4母體衛生gen7 seed42量到mergein.subteam=2(非恆零),證明這支儀器在此config下【有接電】,不是永遠讀零｜卷面`docs/measurements/2026-09-23-P4-gen7-control-same-instrument.md`
---

跑法：`.worktrees/gen7-p4-control`(世代7邊界`22ac1b096`)覆蓋現行`freeze_sample_bed.gd`,同config同兩seed。

# P2(順手坐實)
```
gen7 seed1337: verdict=FAIL(p99=1110ms,over2s_days=6/12)
gen7 seed42  : verdict=FAIL(p99=948ms, over2s_days=4/12)
gen8 seed1337: verdict=PASS(p99=257ms, over2s_days=0/12)（已交付）
gen8 seed42  : verdict=PASS(p99=267ms, over2s_days=0/12)（已交付）
```
四點對照都在，「凍結消失了」不再是單邊宣稱。

# P4(本次補派工的主體)
```
gen7 seed1337：真隊71/野獸0/子隊42/總113｜死因全0｜子隊終止全0
gen7 seed42  ：真隊67/野獸0/子隊37/總104｜死因全0｜mergein.subteam=2(其餘0)
gen8 seed1337：真隊66/野獸0/子隊38/總104｜死因全0｜子隊終止全0
gen8 seed42  ：真隊70/野獸0/子隊39/總109｜死因全0｜子隊終止全0
```
★★重點：seed42在gen7量到`mergein.subteam=2`——四組讀數裡唯一非零的一組。
這代表這支儀器的P4段落在這個config下**不是恆零／沒接電**，是事件本來就稀疏。
兩世代對照下沒看到死因/終止事件系統性增加，但樣本量(1個非零事件)太小,
判為「同量級、無可見劣化」，不是「確認完全不變」——這是我能給的最誠實的判法,交你裁。

# 途中一個自抓錯誤
第一輪seed42用錯env var名(跟另一支床搞混),兩次輸出逐行相同才發現,已用正確`FS_SEED`重跑。
已記入memory(`reference_measurement_protocol.md`)，worktree已清除。

落地：`docs/measurements/2026-09-23-P4-gen7-control-same-instrument.md`
