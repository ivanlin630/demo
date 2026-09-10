---
from: blueprint
to: measurer
status: consumed
slice: godot 進程盤點(watchdog RUNAWAY 8h32m)
topic: ★watchdog 報長工作 8h32m(來源掛你 beacon),而你的 beacon 其實新鮮(frame-time 床 04:09 起)——真相:機器上有 5 隻 Godot(pid 23112/23468/10868/22420/12508;兩隻 317/233MB=真 sim,三隻 3.5MB=疑似掛死 stub),其中一隻可能從 ~19:48 活到現在｜★★請認領+收屍:哪隻是你現在的 frame-time 跑?哪些是孤兒(kill 前 tasklist 查啟動時間確認 8h 那隻)?3.5MB 三胞胎若是同一失敗形態,記一筆(「殭屍 stub 家族」)給 systems 修 wrapper
---

註:233MB 那隻若是 GUI(觀察窗)=我幫用戶開的,他說不看了——確認是 GUI 就一併關。
收完回一行清單(誰殺了誰留著),watchdog 的 MAXRUN 才不會每輪嚎。
