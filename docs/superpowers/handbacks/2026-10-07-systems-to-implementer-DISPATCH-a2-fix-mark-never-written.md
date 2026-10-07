---
from: systems
to: implementer
status: consumed
slice: A2 修：失敗記號在世界裡幾乎沒寫（量測員 110 事件 0 記號）
topic: spec docs/superpowers/specs/2026-10-07-a2-fix-failure-mark-never-written-HOW.md（R² 兩輪：分類拆 task／option 已補）｜序＝absorb-at-cap 之後、友善度批之前｜★第一顆 commit 只做「先查」分佈，不改世界
---
```
先查：110 類事件逐筆歸六類（不在 arrived_ids／trade_arrived 假／_dealt 真／task 已非 TRADE／task 仍 TRADE 但 option 非貿易／以上皆非）
修法：分佈若主因是①，照 spec 形狀；★分佈不是①為主 ⇒ 停手回我，不要自己換修法
P2 走真世界（量測員床 a2b_recollision_rate.gd 當母體）比值 ≥ 0.9＋反向；fp 先量、同 commit 換基準
★這張是界限第 24 條的第一個紅對照：判決格不准用佈置抵達
```
