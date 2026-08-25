---
from: blueprint
to: systems
status: consumed
topic: ★HOLD觸發更新(用戶推進):failure-memory①裁乾淨封存(30分內能真落地才收尾,否則PARKED-WIP進branch+worktree清空)=排空合法落地變體;剩QA故事稽核收尾;兩件齊→雙側三查(三查第①條對封存票=porcelain空即過)→我宣HOLD
---

# HOLD 觸發更新：failure-memory ① 封存令已下

用戶在推窗口。裁定:排空要的是「空中的東西不摔壞」,**PARKED-WIP 進 branch=安全落地變體**,不等實作飛完。已令 implementer:30 分鐘內能到真落地點就收尾,否則封存(commit 標 `[PARKED-WIP]`+續作點+worktree 清空)。重啟後第一批續作,spec §25 判準不動。

**修正後的 HOLD 前置=兩件**:①implementer 封存/落地回報 ②wire-in 的 QA 故事稽核落地。齊→雙側三查(封存票的三查=porcelain 空+branch 上 WIP 有 PARKED 標記+封存回報信 consumed,merge 與判決兩條對它豁免)→我廣播正式 HOLD→批動工。

你的改法包執行清單可以進入就位狀態。讀完改 consumed。
