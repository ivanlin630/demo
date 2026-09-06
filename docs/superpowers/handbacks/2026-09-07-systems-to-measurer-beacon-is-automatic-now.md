---
from: systems
to: measurer
status: open
slice: 你的 03b 文件我動了三處（★其中一處改變你的作業方式）
topic: ★★★作業方式改變:長工作 beacon【不要再手寫】—— tools/godot.ps1 現在自己蓋章(起跑寫、每 10s 續期心跳、結束刪),時窗寫進 .claude/hooks/.godot-runs.log;★而改的理由是 2026-09-06 稽核發現【一個 beacon 都沒被寫過】⇒ 護欄母體恆空 ⇒ 上線至今一次沒響,而它防的事(兩支 Godot 同跑污染 perf)當天正在發生;★★你要做的只剩一件:確認你那棵 worktree 的 godot.ps1 是新版(grep -c 'BUSY BEACON'),★★★因為舊版的樹跑的 Godot【一筆都不會被記到】,而「log 裡沒有紀錄」=【那棵樹沒有新版 wrapper】或【真的沒跑】,兩者長得一樣;★另兩處只是壓縮(cap 那節與檔頭流程說明搬 detail,原文逐字保留)
---

# ★★★一、作業方式改變：**beacon 不要再手寫**
```
舊制(你檔案裡原本寫的):
   echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.measurer   # 開跑前
   rm -f .claude/hooks/.busy.measurer                                # 跑完
★而 2026-09-06 稽核:`.claude/hooks/.busy.*` 【一個都沒有】—— 從來沒被寫過
⇒ ★★bash-guard 護欄②的母體【恆空】⇒ 上線至今【一次都沒響】
⇒ ★★★而它防的事當天正在發生:兩支 Godot 同時跑、合計吃 32.5% CPU
```
★**新制**：`tools/godot.ps1` **自己蓋章** —— 起跑寫 `.busy.<role>`、**每 10s 續期（心跳）**、結束刪，
並把**時窗**寫進 `.claude/hooks/.godot-runs.log`。
★★**用心跳不用「結束刪」的理由**：**「結束刪」正是被 kill 時唯一不會執行的那一步** ——
**否則我只是把【永遠不響】換成【永遠亂響】。**

# ★★二、你要做的只剩一件事，而它有個坑
```
確認你那棵 worktree 的 wrapper 是新版:grep -c 'BUSY BEACON' <worktree>/tools/godot.ps1
★因為每個 worktree 用的是【自己那個 branch 的 godot.ps1】(那是對的設計)
⇒ ★★舊版的樹跑的 Godot【一筆都不會被記到】
⇒ ★★★而「log 裡沒有紀錄」=【那棵樹沒有新版 wrapper】或【真的沒跑】—— 兩者長得一樣
⇒ 修法是【合 main】,不是改解析路徑
```
★**另外**：`docs/process/env-epochs.tsv` 已立 —— **2026-09-06 起牆鐘類讀數系統性變快**
（用戶加了 Defender 排除）⇒ **跨那天的 wall-clock before/after 是【不同源】，對比前先查那張表。**

# ★三、另兩處只是壓縮（原文逐字保留在 detail）
```
①「有 cap 的來源」那節 → 主檔留【機械偵測 + 三條紀律】,血證搬 detail/03b_measurer-cases.md
②檔頭「2026-07-09 流程改」→ 主檔留兩句操作性,原文搬 detail
⇒ 你的必讀從 204 行降到 183 行(上限 200)
★★而【開場合計】還差 3 行沒達標(603 vs 600)——我【沒有硬砍】,
   ★★★因為再砍就是把真內容換成好看的數字,而那正是這個上限要防的相反面
```
