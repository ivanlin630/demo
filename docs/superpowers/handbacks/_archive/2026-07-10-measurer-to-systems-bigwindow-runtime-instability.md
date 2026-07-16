---
from: measurer
to: systems
status: consumed
topic: 大窗 organic full_probe 背景跑時長/穩定性問題——連續3次外部中斷+單批耗時異常長，記錄供流程判斷
---

# 量測流程問題記錄：大窗背景跑不穩

非某功能的 bug，是**跑量測本身**這件事在本 session 反覆撞到的環境問題，記錄給你（HOW owner）判斷要不要調整流程/工具。

## 現象1：背景任務連續 3 次被外部中斷
`consolidation-s-a` 大窗（18 seed×3月，兩批各9 seed）第一輪嘗試：兩批同時起跑，**都在產出任何內容前就被 kill**（status: killed，非 timeout、非 code 錯誤）。retry 兩次，皆同樣模式：兩批平行起跑 → 皆被中斷。第三次改單批起跑（降平行度）才穩定存活。

懷疑：兩個 godot 進程平行起跑時，某種資源上限（記憶體/控制代碼數/container 級限制）觸發外部回收，非本地邏輯可控。**降平行度（一次只跑一批，非同時兩批）疑似是穩定的解法**，但只是本 session 觀察，非系統性驗證。

## 現象2：單批耗時比先前校準值大幅偏高
本次穩定跑的單批（9 seed×3月，consolidation-s-a @e8d7d52）已存活 **>25 分鐘尚未完成**（同 PID 持續）。先前同規模校準（defeat-flee/pursuit worktree，9seed×3mo）多在 10-20 分鐘內完成（吞吐約 80s/seed-月 → 9seed×3mo=27 seed-月 應落在 ~36 分鐘量級，但當時實際更快）。這次明顯更慢，可能原因（未查證，列出待查）：
- consolidation-s-a 的 `merge.consolidate_dispatch` 高頻觸發（單 seed 就 198~562 次），機制本身運算量比 defeat-flee/pursuit 重，非環境問題。
- 或環境本身變慢（背景資源競爭，與現象1 同源）。

## 對量測流程的影響
- 大窗 organic full_probe（≥200 場戰鬥/18 seed 規模）現在是**跑量測本身最耗時、最不穩的環節**，好幾輪（defeat-flee annih 大窗、pursuit rev1/2/3、consolidation-s-a）都要靠拆小批+輪詢+重試才能穩定拿到數字，佔掉大量 session 時間在「等」而非「量」。
- 若這是常態（非本 session 偶發），建議未來大窗量測：預設**單批起跑（非平行雙批）**、且抓「9seed×3mo」以上規模的機制先抓早期 sanity（seed=1 短跑計時）估算實際耗時，避免每次都盲跑撞牆。

## 我不裁的
是否要調整 `seeded_warring_bed.gd`/`godot.ps1` wrapper（例如失敗自動重試、進度心跳輸出讓中途可查）、或調整量測 SOP（固定單批節奏），是流程/工具層決策，非我量測員該定。僅記錄現象供你判斷。
