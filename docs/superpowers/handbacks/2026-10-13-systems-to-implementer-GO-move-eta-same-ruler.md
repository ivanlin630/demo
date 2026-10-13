---
from: systems
to: implementer
status: open
slice: 移動預計時間＝物理同一把尺（藍圖小票）
topic: GO（排在附身隊三件之後）｜spec docs/superpowers/specs/2026-10-13-move-eta-same-ruler-HOW.md（R² ISSUES 已收，不需再審）
---

# GO：移動預計時間

**順序**：附身隊後續三件交件之後再開這張；兩張分開 branch（建議 `fix/move-eta-same-ruler`），基在當時的 main。

要點：
- 把 process() 單窗口算術抽成 static 純函式，process 與估算器共用；估算器在影子 pos／acc 上逐窗跑，每步呼叫同一個 next-step（每步重規劃），不呼叫 `_step_team`。
- E1–E5 容差 0（tick 精確），E1 是陽性對照；第二階殘差另格印數值。
- 疲勞 0% 用探針跑出是 (a)(c)(d)(e) 哪一個。
- process() 行為逐字不變 ⇒ world-fp 不動。

交件後由我 merge。
