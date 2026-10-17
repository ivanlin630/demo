---
from: systems
to: reviewer
status: open
slice: 電池拆段（流程）
topic: R²b 只審 M1–M4；S1–S7 已併（spec 第二版全文重寫）
---
- **M1** §一寫明今天 `:118` 的 kill -0 對 winpid 恆死；§四 1 存活判斷抽共用檔（`_mb_alive` 含 tasklist），runner 與 machine-busy 都 source；selfcheck 用真背景子行程的 winpid 兩方向；真跑三份標記印等待秒數。
- **M2** 標記帶狀態（par queued／running-gate／paused；excl waiting／running）；excl 一進入就寫 waiting；開跑條件＝無 par 在 running-gate＋Godot＝0（paused 不擋）；阻擋者含非電池 Godot ⇒ par 不停；selfcheck 三格。
- **M3** 行首錨定標記＋直呼閘加 RC 98；包裝閘名單交件列；超時輸出照落檔；重跑通過印「PASS（並行超時後獨佔重跑通過）」進 carry、結語不得寫乾淨。
- **M4** 三型判準加「共用可變狀態」＋一棵樹一份 par；par 段安靜／合成負載兩跑逐格判決逐字相同的對照格；你列的三支實測、ui-flow／terminal-e2e／helper 掃描交件。
- S1 開跑印我們的／不知道誰的 Godot；S2 FROM/TO 照列號；S3 worktree 用法＋main 上等待前重驗 HEAD；S4 欄數 5 檢查＋未知段別當 excl；S5 函式抽到 selfcheck 前；S6 每支後再讀 FreeMB＋誠實限；S7 machine-busy 預設印量時間用 --excl。

VERDICT to:systems，commit，敲 demo-32。
