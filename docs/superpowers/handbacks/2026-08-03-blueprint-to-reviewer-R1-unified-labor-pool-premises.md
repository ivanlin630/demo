---
from: blueprint
to: reviewer
status: open
topic: "[R① factcheck 前提·新大框『統一勞力池讓size在生產matter』·spec=docs/superpowers/specs/2026-08-03-unified-labor-production-scale-design.md·逐條驗file:line+詮釋,premise_contradiction→halt:P1 manufacturing_system:82製造勞力=clampf(sqrt(pop/5),0.5,2.0)且RECIPE_GROUPS迴圈每設施免費並吃同pop_mult(設施間不競爭)·P2 resource_system:63採集用自己一份sqrt(pop/5)與製造獨立互不搶·P3 outpost_system:166 _has_resident_on_tile=布林閘非勞力量級,勞力量級=team.population,據點本身無獨立勞力stat·P4詮釋:兩套pop_mult互不搶(勞力現免費/無限,各取team.population無共享約束)·P5 resource_system:63的sqrt=tile覓食承載上限(sublinear蓄意不准動)·問:P1-P5成立否?尤其P4『互不搶』詮釋+P5承載cap認定·CLEAN才鎖spec才dispatch systems做HOW]"
---

# R① factcheck 前提 — 統一勞力池（新大框）

**新概念大框**：勞力變有限稀缺資源、統一池、size 在生產上 matter。前提含未驗 code 斷言 → R① 先於鎖 spec。

**spec**：`docs/superpowers/specs/2026-08-03-unified-labor-production-scale-design.md`（DRAFT，§現況前提 P1–P5）。

## 逐條驗（file:line 原始事實 + 詮釋，分開判）

| # | 斷言 | 型 |
|---|---|---|
| **P1** | `manufacturing_system.gd:82` 製造勞力 = `clampf(sqrt(team.population/5),0.5,2.0)`；`RECIPE_GROUPS` 迴圈裡**每座設施免費並吃同一 pop_mult、設施間不競爭** | 事實+詮釋 |
| **P2** | `resource_system.gd:63` 採集用**自己一份** `sqrt(pop/5)`，與製造**獨立、互不搶** | 事實+詮釋 |
| **P3** | `outpost_system.gd:166 _has_resident_on_tile` = **布林閘**（非勞力量級）；勞力量級 = 動作隊 `team.population`；據點本身**無獨立勞力 stat** | 事實 |
| **P4** | **詮釋**：兩套 pop_mult **互不搶**——勞力現「免費/無限」，各系統各取 `team.population`、**無共享約束** | 純詮釋 |
| **P5** | `resource_system.gd:63` 的 `sqrt` = **tile 覓食承載上限**（sublinear、蓄意、★不准動） | 事實+認定 |

## 重點盯
- **P4 是全 spec 地基**：若兩套其實已共享/競爭某勞力約束，則「加勞力池」是改錯根 → **premise_contradiction → halt**。
- **P5 承載 cap 認定**：sqrt 若不是承載而是別的語意，守憲條款要改。
- P1/P2「不競爭/互不搶」是詮釋，非只行號 → 照 [[feedback_fileline_vs_interpretation]] 深驗。

CLEAN → 我鎖 spec + 更 game-design.md + dispatch systems 做 HOW（K/cadence/seam/share 存放）。
contradiction → 回我修根。
