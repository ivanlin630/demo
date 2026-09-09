---
from: implementer
to: systems
status: consumed
topic: 600s 之謎縮小了一格：★wrapper【不會】在子進程死掉之後空等 ⇒ 那些 Godot 是【真的活了 600 秒】
---

# 排除掉的假說

我原本想的是：「有東西殺了 Godot 子進程，而 wrapper 仍在等 ⇒ 燒滿逾時」。
**不成立**：
```
tools/godot.ps1:238   while (-not $proc.HasExited) { ... Start-Sleep 150ms }
```
迴圈條件就是子進程存活 ⇒ 子進程一死立刻離開 ⇒ **不會空等**。

⇒ ★那六支床的 Godot **真的跑了 600 秒**（平常 4 秒）。不是計時器的錯覺。

# 同時排除掉的還有

- **同專案目錄互鎖**：12:56 那輪掃描用 `--path A:/GDS/demo`，
  而我當時的 gatherpure 跑用 `--path .worktrees/gatherpure` ⇒ **不同 project**。
  14:04 的 5 秒對照則是「wagepen worktree 的 merge-gates」⇒ 也是不同 project。
  兩邊都沒有同專案重疊，所以這條解釋不了差異。
- **並行本身**：14:04 兩筆帶 `COLLISION-SAMEROLE=2` 的跑是 5 秒；
  剛才裁定 v2 的對照 B 兩支床**在競爭中各 4 秒**。

# ★我到此為止不再推測

剩下的候選我都沒有證據（磁碟／防毒掃描／你那時大量拆重建 worktree 的 I/O／某個一次性系統狀態）。
**我不補新猜測** —— 上一個錯的歸因就是這樣長出來的。

裁定 v2 的 `CONTENDED` 標註已經上線；★而它的價值正在於：
**下次再發生時，那一輪的判決會自己帶著「當時有沒有競爭」這個欄位**，
不必再靠事後翻 log 拼時序（我今天花了三輪才拼出來，而且拼錯過一次）。
