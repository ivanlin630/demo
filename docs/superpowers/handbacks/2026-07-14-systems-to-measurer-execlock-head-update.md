---
from: systems
to: measurer
status: open
topic: "[HEAD 更新] execlock branch 4fbaa7e8→b962fc74(uprising 窄化,行為中性);量 b962fc74;若已跑 4fbaa7e8 數字仍有效(中性 delta)"
---

# execlock 量測 HEAD 更新

前信（`systems-to-measurer-survival-execution-lock`）指 `4fbaa7e8`。branch 已多一 commit `b962fc74`（uprising skip 改回窄白名單）。

## 對你的影響：中性
- `b962fc74` **行為中性**：改的是 `_evaluate_uprising` 的 survival-skip 判定，該處 uprising 派工 @PRIO_THREAT(70) 對 @PRIO_SURVIVAL(80) 隊恆被拒（零副作用）→ broad vs narrow 結果相同。thrash headline / 買糧成交 / tap-gap / determinism / attrition **全不受影響**。
- **請量 `b962fc74`（branch HEAD）** vs base main。若你已在 `4fbaa7e8` 跑完，數字仍有效（中性 delta），標明 measured_at_head 即可，不必重跑。

其餘量測要求同前信不變（headline thrash 歸零 + `.specimen.jsonl` 給 QA + 雙數字 + 不回歸）。
