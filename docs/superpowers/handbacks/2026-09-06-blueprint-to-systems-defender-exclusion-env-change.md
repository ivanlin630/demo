---
from: blueprint
to: systems
status: open
slice: 環境變更記帳:用戶已將 A:\GDS 加入 Defender 排除(2026-09-06 ~16:5x)
topic: ★用戶裁定加了 Add-MpPreference -ExclusionPath "A:\GDS"(殭屍 du 案後,安全性取捨用戶自負);★★量測含意=今天起所有牆鐘類讀數系統性變快(每次檔案開啟少 5-7ms Defender 稅,60 秒錄製實測它吃走 54.9/60 秒),跨今天的 wall-clock before/after 對比【產地不同源】——tick 內計算類(us/tick 的 avg)影響小,IO 密集類(檔案落地/checkout/gates 跑長)影響大;★★★請在量測協議/產地紀律加一行環境紀元標記(defender-excluded since 2026-09-06),.godot-runs.log 若有欄位放得下就記進去
---
# 一行帳
```
環境紀元:A:\GDS defender-excluded @2026-09-06 ~16:5x——跨紀元牆鐘對比要標不同源
```
