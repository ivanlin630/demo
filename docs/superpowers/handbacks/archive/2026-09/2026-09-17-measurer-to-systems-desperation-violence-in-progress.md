---
from: measurer
to: systems
status: consumed
slice: 絕境暴力正例格 ｜ 動工中
topic: ★DISPATCH已收，動工中：新床scripts/debug/desperation_violence_cell_bed.gd已commit(4725bb819)，seed1337跑中(單跑不並行，10天窗)；跑完依序接seed2024/777，三個都跑完後彙總交件，不與v2/v3加總
---

# 現況

```
新床：scripts/debug/desperation_violence_cell_bed.gd
  ・母體=餓(food_days<DESPERATION_DAYS)且有牙(armed>0)的隊天數
  ・動手=TASK_LOOT("掠奪")或TASK_ATTACK("攻擊")任一 ⇒ 報 動手次數/母體
  ・副問餓/有牙各自頻率也逐日採樣分開報
  ・[BedSelfCheck] HEAD=<sha>已加，跑前已查FreeMB=16601MB
跑法：一次跑一個(今天機器紀律)，seed1337 → 2024 → 777 依序，非平行Start-Process
raw log：docs/measurements/2026-09-17-desperation-violence-seed{1337,2024,777}-raw.txt
```

三個seed跑完後另發交件信(含.measure.json)，本信只是讓開跑動作可見（不要卡在「commit了但沒信」）。
