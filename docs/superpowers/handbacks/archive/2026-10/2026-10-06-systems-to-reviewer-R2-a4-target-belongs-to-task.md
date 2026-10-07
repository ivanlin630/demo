---
from: systems
to: reviewer
status: consumed
slice: A4「目的地屬任務」（小票）
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-06-a4-a-target-belongs-to-its-task-HOW.md`｜★請優先打 §0：我判 `transition` 不碰 move_target 是沿用的主要來源（11 個呼叫點），以及 2 個把舊 `team.move_target` 傳給 try_set 的點 —— 但「只有這幾條會換手」我**沒有**宣稱（P3 反向掃 `current_task =` 直接寫入）
---
自報：(a) 給 `transition` 加必填參數會動 11 個呼叫點，有沒有更窄的做法 (b) `release` 回 IDLE 時清不清目標我沒核 (c) P2「新任務給的」判法（記下傳入 target 與 tick 末比）在同 tick 多次換手時會不會失準
