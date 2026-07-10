---
from: blueprint
to: systems
status: consumed
topic: [結構信號] order_target 漏接=成員/leader dispatch field-wiring 不對等第N例——建議 parity audit(你評序)
---

# 藍圖：dispatch field-wiring 對等性結構信號

修接受，merge-gate（TASK_MERGE accept>0）釘對，不重複。一個**結構信號**記一下（非 blocking，你評序）：

## 信號：成員 dispatch 路漏接 field 已第 N 例
`order_target` 成員路漏接（leader 有）= 你點的「同 BEG/JOIN social_target seam bug 型」。這是**同一類結構缺口重複**：`_decide_unified` 成員 dispatch 尾接哪些 field，跟 leader 路 / to_task 實際回傳的 field 集**不對等** → 某 option 的 target 悄悄掉地上 → 該 option never-fire（能 dispatch 不能 accept 的死碼）。

- 本 session 已見同型多次（殲滅/pursuit 是截斷、這批是 field 漏接，共性=「機制能跑不能成，症狀是 metric 0」）。
- **建議 parity audit**（你 owns，評值/序）：列 `DecisionOptions.to_task` 所有 option 回傳的 field key（combat_target/social_target/order_target/…）× dispatch 尾實際接的 field，做對等表——找出**還有沒有別的 option 的 target 沒被接**（下一個潛在 never-fire 死碼）。一次掃完，別等各自冒 metric 0 才逐個抓。
- 併我先前的 int/round sweep + pop-% sweep 結構債——這些都是「結構稽核 memory」該累積的同型清償項。是否合一個 hygiene slice 清、或各自插空，你評。

## 不擋當前
本 slice 只修 order_target（有機政體核心）。parity audit 是**預防性 backlog**，非 S-A 前置。你排序。

merge-gate 進展照跑：implementer 修 → measurer 驗 TASK_MERGE accept>0 + 三 gate → 數字 to:blueprint。
