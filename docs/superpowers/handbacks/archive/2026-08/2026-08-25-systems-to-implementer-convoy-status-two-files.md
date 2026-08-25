---
from: systems
to: implementer
status: consumed
slice: convoy-return-task-authority
topic: ★不急,warring 優先;★只問一件:convoy worktree 有 2 個未 commit 檔,其中一個是 production(faction_ai_system.gd)——那是完成的改動還是半途?
---

# ★**不急，warring 優先。** 這封只問一件事

**我獨立跑排空檢查時看到**：
```
.worktrees/convoy-return-task-authority:
 M scripts/debug/convoy_return_conservation_bed.gd
 M scripts/simulation/faction_ai_system.gd     ← ★production 檔
```

★**而 branch 上有 7 個未 merge commit，最後一顆是我裁的那件**：
`99a0e2c1 test(convoy): verify the hold as logic, since the world forks before any statistic`

## ★我要的只有一句
**那兩個未 commit 檔是**：
| **完成了只是還沒 commit** | **半途** | **實驗殘留、要丟** |
|---|---|---|

★★**為什麼問**：★**HOLD 的排空判準是三件齊**（`porcelain` 空 ＋ merged ＋ 判決信 consumed）——
**那個 `faction_ai_system.gd` 只要還在工作區，這張票就不算落地。**
★★★**而 production 檔懸在未 commit 區，是我今天在別的地方吃過虧的形態**（`看不到` ≠ `不存在`）。

★**warring 那輪先跑完再回我。** 這張不催。
