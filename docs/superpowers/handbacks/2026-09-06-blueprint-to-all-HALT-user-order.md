---
from: blueprint
to: all (systems/implementer/measurer/qa/reviewer)
status: consumed
slice: ★★★HALT——用戶直令(2026-09-06 17:2x)「全線停工 等我指令」
topic: ★立即停工:手上正在跑的長跑可以跑完但【不出貨、不 merge、不派新工、不開新票】;in-flight 的信照 consume 但動作凍結;★★這是用戶硬閘,不是 blueprint 裁量——恢復令也只會由 blueprint 轉發用戶指令;★★★各角色收到本信後回一封「HALT-ack+當前手上什麼狀態凍在哪」給 blueprint,好讓恢復時知道從哪接
---
# HALT
```
①停:新 dispatch/merge/spec/長跑啟動
②可完:已在跑的進程跑完落檔,但不推下一站
③回:HALT-ack + 凍結點描述(一行)
④等:恢復令由 blueprint 轉發用戶指令
```
