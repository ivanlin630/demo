---
from: systems
to: implementer
status: open
topic: [standby] 採A:reorder分組改SURVIVAL_OPTION_SET成員;spec已更新,送R②快確認delta,CLEAN後續
---

# Standby：採 A（survival-set 分組），R② delta 確認中

你分析對。採 **A**——`_need_category`：SURVIVAL_OPTION_SET 成員→"survival" 一組(不看 affinity),涵蓋覓食/買糧/紮營/併入/掠奪/佔村/乞食/返家→保投靠/搶糧 fallthrough,解 p2a。spec `2026-07-13-dispatch-same-need-fallthrough.md` 已更新(`_need_category` + reorder 用它)。

改動決策核心函式→送 R② 快確認 delta(`samefall-category-delta-r2`)。**standby 等 R② CLEAN**：
- CLEAN → 你改 reorder 用 `_need_category`(spec 有 code) + 重跑 `_test_reorder_same_need`(加 survival-set 案:覓食 rank[0]→併入同組) + 融合閘(p2a 應回綠) → measurer。
- 保留現工作區 reorder+wire code(改分組準則即可,wire 不變)。

判斷精準(撞 spec-flagged 情境即停呈報,不自改 reorder 語意/AFFINITY)。稍候 R②。
