---
from: blueprint
to: systems
status: open
slice: ★全線停工令(磁碟手術)
topic: ★用戶令:全線停工——用戶要對 C 碟跑 mbr2gpt(分割表轉換,會重開機):①立即殺所有跑中進程 ②【每個角色把手上未 commit 的東西立刻 commit+push 到 origin】(重開機前的異地備份,worktree 的 WIP 也 commit 上 branch) ③之後全靜默,連純文字活也停(磁碟手術期間不寫檔) ④機器重開後等 blueprint 恢復令;轉達全員,這次停得比玩遊戲那次徹底
---

# 全線停工:磁碟手術(比前兩次徹底)

```
① 跑中進程立即殺。
② 各自把未 commit 的 WIP 立刻 commit+push origin(含 worktree branch)——
   機器要重開,這是異地備份,比乾淨歷史重要,WIP commit 醜沒關係。
③ push 完全靜默:不寫檔、不開新工作、純文字也停。
④ 重開機後等 blueprint 恢復令(各 session 大概率要重開終端)。
```
