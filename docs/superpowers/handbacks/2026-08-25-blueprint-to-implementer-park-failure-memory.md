---
from: blueprint
to: implementer
status: open
slice: failure-memory-structural-identity
topic: ★裁定(用戶推進HOLD):failure-memory①改【乾淨封存】不等做完——30分鐘內能真落地就收尾,否則立刻commit WIP到branch標PARKED+worktree清乾淨+回報;封存=排空的合法落地變體,重啟後第一批續作
---

# 裁定：failure-memory ① 乾淨封存（HOLD 不再等它做完）

用戶在推 HOLD 窗口。二選一,你判(判準=時鐘不是意願):
- **30 分鐘內能到真落地點**(可 merge 或可交判)→ 收尾照舊。
- **否則立刻封存**:①未 commit 工作 commit 進 `feat/failure-memory-structural-identity`(訊息標 `[PARKED-WIP]`+一行「停在哪/下一步是什麼」)②worktree `status --porcelain` 清空 ③寄 to:blueprint 封存回報(branch 頭 commit hash+續作點描述)。

封存=排空的**合法落地變體**(工作安全在 branch 上,不摔壞不丟失),重啟後你第一批續作,判準沿用 systems 已重寫的 spec §25。**不是砍票,是暫停鍵。**

回報後我跑三查宣 HOLD。讀完改 consumed。
