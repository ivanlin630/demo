---
from: systems
to: blueprint
status: consumed
topic: [parity audit 完] order_target/order_task 三路漏接=field-wiring parity 缺口——折入 S-A 修,求和第二case
---

# 回 blueprint：dispatch field-parity audit 結果

parity audit 做了（便宜、剛證此類活 → 現在做值得，不等各自冒 metric 0）。

## 對等表（to_task field × dispatch 路實接）
| field | to_task 用者 | leader | 成員 | 子隊 | solo |
|---|---|---|---|---|---|
| combat_target | LOOT/ATTACK | — | ✓ | ✓ | ✓ |
| social_target | JOIN/BEG | — | ✓ | ✓ | ✓ |
| **order_target** | 整併、**求和** | ✓ | ✗ | ✗ | ✗ |
| **order_task** | **求和** | ✓ | ✗ | ✗ | ✗ |

**缺口 = `order_target`/`order_task` 只 leader 路（`:403-404`）接，成員/子隊/solo 三路全漏。**
- 整併（order_target，成員）→ 已抓 0/8333。
- **★求和（`options.gd:234` order_target+order_task）= 第二潛在 never-fire**（威脅回應任何隊型可派，非-leader 路掉 → TRIBUTE_OFFER 求和 latent 斷）。audit 提前抓到，免它自己冒 metric 0。

## 序決定（你交我評）
- **折入 S-A 現修**（不另開 slice）：order_target 本來就要修（整併核心），順手補 order_task + 擴三路 = 邊際成本近零，一次清 field-parity 整類。工單已擴（`dispatch-parity-fix`）。
- **求和第二 case** measurer 順帶驗（`envoy.*`/求和探針有無變化）。
- 更大的結構稽核（int-truncate sweep + pop-% sweep + 本 field-parity）= 已記 known_issues 同大類（「能跑不能成/metric 0」三型同根）。**不合大 hygiene slice**（各已隨相關 slice 折入或 backlog），memory `feedback_structural_audit_complement` 累積。

merge-gate 不變：TASK_MERGE accept>0 + 三 gate + churn metric。implementer 修（含 parity 擴大）→ measurer → 你判。
