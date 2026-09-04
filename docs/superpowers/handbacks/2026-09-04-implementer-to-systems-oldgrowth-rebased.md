---
from: implementer
to: systems
status: open
slice: `.worktrees/old-growth` rebase 完成（★衝突不是自動解的，我手動重貼並驗過）
touches: `feat/old-growth-forest` 61a3c34c
topic: ★rebase 撞衝突:`three_tickets_bed.gd` 兩邊都在檔尾長東西 —— main 已有 donor-ladder 那六節、我這邊有 HEARTBEAT＋政權盤點;★★我【沒有】用自動解:取 main 全量,再把我那三塊(`_hb_teams` 變數／日迴圈裡設值／HEARTBEAT 行／`_sec_factions`)手動重貼;★★★而我【跑了兩次驗證】才 continue:8 日驗六節與政權盤點都在、11 日驗 HEARTBEAT 真的印得出來——因為 8 日跑不到 day 10,心跳那行【不會被 8 日跑測到】
---

# ★①衝突的形狀
```
`scripts/debug/three_tickets_bed.gd`：★兩邊都在【檔尾】長新的 section
   main 側：`_sec_donorladder`／`_sec_zerowin`／`_sec_goalutil`／`_sec_aftermath`
            ／`_sec_unitoverlap`／`_sec_perf5`（★donor-ladder 那批已 merge）
   我側  ：`[HEARTBEAT]` 行 ＋ `_sec_factions`（4547c730）
⇒ ★★衝突區橫跨 358 行 ⇒ ★★★自動解在這種形狀上【會靜默丟掉一邊】
```

# ★★②我的解法：**取 main 全量，再手動重貼三塊**
```
①`var _hb_teams: int = 0`（★`_sec_interim` 拿不到 state，所以在日迴圈裡餵）
②日迴圈裡 `_hb_teams = state.teams.size()`
③`_sec_interim` 開頭的 `[HEARTBEAT]` 行（★三個量指向三個不同兇手）
④`_sec_factions(state)` 呼叫 ＋ 函式本體
⇒ ★而我在 ③ 的註解裡補上【它的實績】：warring 90 日靠它把三個結構性候選全部排除，
   ★★且 day 40 的記憶體外推（≈254 MB）與 day 90 實測（254.8 MB）對上
   ⇒ ★★★下一個讀到這段 code 的人會知道它為什麼在那裡，而不是只看到一行 print
```

# ★★★③我跑了【兩次】驗證才 continue —— 而第二次才是重點
```
★第一次（8 日）：六節都在、`[DonorLadder] entry=18 … hit=0`、政權盤點綠（空政權 0/2）
   ⇒ ★★但 `[HEARTBEAT]` 【沒有出現】—— 因為它是每 10 日印一次，而 8 日跑不到 day 10
   ⇒ ★★★也就是說：8 日跑【測不到我剛剛手動重貼的那一行】
★第二次（11 日）：`[HEARTBEAT day=10] wall_s=36.8 mem_static_mb=45.0 teams=21` ✅
⇒ ★這一格值得記：★★【驗證窗必須大於被驗證東西的週期】，
   否則「沒印出來」與「壞掉了」長得一模一樣 —— 而我差一點就拿 8 日那跑當通過
```

# ④現況
```
★`feat/old-growth-forest` 已 rebase 到 merged main 並 push（`--force-with-lease`）
★★`.worktrees/donor-ladder` 早先已 rebase
★★★`.worktrees/donor-baseline` 留著（cap 那票若要 before/after 可直接用；不要的話我下一封撤）
★warring 90 日已收工並回報：`completed=yes`、169.3 分、三個候選全排除
★★段級 phase 計時已回報：`wall_clock_s` 146.5 → 139.2（−5.0%）⇒ 沒有變慢
```
