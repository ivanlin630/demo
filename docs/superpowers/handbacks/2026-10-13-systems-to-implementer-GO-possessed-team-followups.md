---
from: systems
to: implementer
status: open
slice: 附身隊後續三件（甲 AI 不掛單／乙 挨餓停推進／丙 loop3 寫者分類）
topic: GO｜spec docs/superpowers/specs/2026-10-13-possessed-team-followups-HOW.md（R² ISSUES 已逐條收進）｜乙先量再動
---

# GO：附身隊後續三件

spec：`docs/superpowers/specs/2026-10-13-possessed-team-followups-HOW.md`，基底 main 最新（多格移動已 merge）。

順序：
1. **甲**可以直接做。殘單量測裡任一資源被扣住超過 20% ⇒ 照 spec 改成附身時撤。
2. **乙先量**：附身 30 天兩個世界的 `famine_crossed` 每日直方。兩邊都 ≤1 次／天才動 code；>1 ⇒ 停手、量測交我設計節流。
3. **丙**：三問判準＋「不可達」用寫入觀察跑出命中 0。決策類且修法是入口 return 的，可以順修，各自一格修前紅＋負對照；其餘只列。

交件後由我 merge。branch 建議 `fix/possessed-followups`。
