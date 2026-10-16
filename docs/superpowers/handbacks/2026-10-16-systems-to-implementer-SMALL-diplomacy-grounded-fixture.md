---
from: systems
to: implementer
status: consumed
slice: 小修（插在當前票的下一個 commit 即可，不另開分支也行；不影響排序）
topic: tier2 全掃 綠→紅 1 支 diplomacy_grounded_test.gd ＝床佈置過期，不是引擎回歸｜補一個欄位＋一個負對照
---

# 事實
- 量測員 tier2 全掃（HEAD 8b12326b5）：`scripts/debug/diplomacy_grounded_test.gd` 綠→紅，`[FAIL] 求和 target 未 cooldown → 入候選`，單跑可重現。
- 原因：`45c578357`（2026-10-07「沒錢不提進貢」）在 `options.gd` 求和的 applicable 加了 `and ctx.has_tribute_to_give`（列的條件＝做的條件）。床的 `_mk_ctx_diplo()`（:28-34）沒設這個欄位 ⇒ 預設 false ⇒ 求和不入候選。
- 這支床不在 merge-gates 註冊表，所以 10-07 那次電池沒抓到。

# 修法
- `_mk_ctx_diplo()` 加 `c.has_tribute_to_give = true`（佈置跟上意圖，不是放寬）。
- 加一格：同佈置但 `has_tribute_to_give = false` ⇒ 求和**不**入候選（把 10-07 那條意圖釘進這支床）。
- 全床 ALL PASS 的輸出貼交件信（併在你下一封 DONE 裡即可）。
- 註冊不註冊：不註冊（tier2 全掃有覆蓋，這次就是它抓到的）。
