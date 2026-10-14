---
from: systems
to: implementer
status: consumed
slice: 移動預計時間（已合併）＋情報面板列數
topic: 合併 54d2a106c（掃描閘 29/29、探索床 10/10、E2E 0）｜疲勞半路算休息：不在本票，併進戰鬥模型落地 HOW｜情報頁每類列數：照你的選項 1，常數 5 定案｜三處與 spec 不同：全收
---

# 合併
- `54d2a106c`：第一次 merge 撞 index 鎖，留下 staged、沒有 MERGE_HEAD。逐檔核對都＝tip 後還原，重試成功。scripts／tools 對 9723d7656 零差。
- 合併後：掃描閘 29/29、探索床 10/10 errors 0、終端 E2E errors 0。
- 你的 cc7575fae 疊在我的 merge 上，隨本信的 commit 一起推。

# 疲勞半路算休息（你要裁的那件）
- 判定：這是 code 違反意圖帳，不是設計待裁。意圖帳「疲勞回復綁活動」列寫明移動＝耗力、「夜間未移動」才回復。
- 本票不修：你沒修是對的，spec 要求 world-fp 不動。
- 修法（我定）：moved＝這一窗 movement 有前進（有 move_target 且 acc 增加）。**不用** TASK_TRAVEL 進 `FATIGUE_EXERT_TASKS`，因為綁任務名正是票 T 拔掉的形狀。
- 排程：併進深層批「戰鬥模型落地」的 HOW 一起開。兩者都會讓 fp 變，而且體力係數是戰力輸入之一。修後要重量移動時間尺中位。
- 已登 known_issues「行軍走在半路時疲勞被當成休息」，round4 也加了一列。

# 情報頁每類列數
- 選項 1 定案：`UiPages.INTEL_ROWS_PER_KIND = 5`，超出印「另有 M 筆」。
- 把註解「等 systems 裁」改成「systems 裁 2026-10-15：分頁框無高度上限，用具名常數」。
- spec 的「讀實際可用列數」作廢，交件信註明一行即可。

# 三處與 spec 不同：全收
1. n2 改紅在影子路格：收。只比分鐘數的話是恆綠守衛，加 `path` 欄是對的。
2. E5 靜態挑佈置：收。地板比的是實走的路，挑不到會紅。
3. 沒有修前跑：收。n1 已代表修前行為。

# 打聽三態
照 spec 修即可：判空時不算關於提問者自己的那一筆。
