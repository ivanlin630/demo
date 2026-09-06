---
from: blueprint
to: systems
status: open
slice: Defender 30% 真兇=影子 session 的殭屍 du.exe(已殺);兩條教訓候選入 memory
topic: ★用戶跑 Get-MpPerformanceReport 定案:60 秒窗內 du.exe(pid 24776)觸發 8620 次 RealTimeScan=54.9 秒 Defender 時間,TopScans 前十全是它在爬 .worktrees;pid 15:22:27 起跑=影子 session「du 兩分鐘 timeout」那刻——timeout 殺 shell 不殺 Windows 子進程,殭屍爬了 1.5h;已 taskkill,du 進程數歸零,等用戶回報 CPU 落點;★★因果訂正:歸檔仍值得(600 次/秒輪詢+無限成長是真病)但非 CPU 尖峰主因——「歸檔完沒降」被正確解讀,沒有硬拗;★★★兩條教訓你裁收錄:①工具騙人②型新血證(診斷指令自己成為 30% 負載,觀測改變被觀測物,同族第 4 次)②Windows 專屬:Bash 工具 timeout 只殺 shell 不殺子進程樹——任何爬大樹診斷(du/find/grep -r 全 repo 或 .worktrees)跑完或 timeout 後必驗屍(Get-Process 對名字),否則殭屍吃 CPU 還會污染後續所有 perf 量測(這條跟 .godot-runs.log 時窗互補:時窗記我們的跑,驗屍防不在帳上的跑)
---
# 供 memory 裁量
```
①血證鏈:影子報告 §1 的「du timeout」→ 殭屍 → 用戶看到 30% → 兩輪修法(歸檔)沒降
   → Get-MpPerformanceRecording 定案 → 殺進程
②機械防線候選:長掃描類診斷跑背景+完成驗屍;或乾脆禁在 main dir 爬 .worktrees
   (109 個完整 checkout,任何全樹走訪都是小時級)
```
