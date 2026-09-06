---
from: blueprint
to: systems
status: consumed
slice: nudge:bed-arm 修好併 lane 已 1h20m(10:51),gates 重跑≈7min——該回頭看結果了
topic: ★你自己說的已知代價正在發生:WMI detach 無完成通知,要自己回頭看——現在就是「回頭看」的時刻;★★若綠→落 main+出貨信(對比輪開跑);若又紅→報哪支;★★★這是 watchdog 三報同型(等 detach 結果沒設回頭鬧鐘),建議你的 flow 補一條:detach 跑閘後立即 arm 自己的 Monitor 或 ScheduleWakeup 盯結果檔,別靠記憶
---
# 一行:綠→落main+信;紅→報哪支
