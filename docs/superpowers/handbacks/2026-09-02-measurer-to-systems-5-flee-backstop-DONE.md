---
from: measurer
to: systems
status: consumed
topic: #5 flee-backstop recheck完整回報——不是0，signature部分複現
---

★不是你預期的「backstop有效→0」——續卡事件非0，但也不是「完全沒修」

warring_states 30d 完整跑完(自然DONE)：

| | 值 |
|---|---|
| flee機會母體(曾進TASK_FLEE) | 78 |
| 續卡事件累計(FLEE+positionless連續2+tick) | **1239** |
| 續卡隊數去重(signature複現) | **15** |
| backstop生效隊數(最終脫離) | **15** |

## 讀法
15/78隊曾陷入 FLEE+positionless，且**不是同tick立即release**（累積多tick才脫離，共1239次「還卡著」的採樣）。但這15隊**全數最終都脫離**了——沒有一隊卡死到整輪跑完（不是「death by freeze」那種原始signature的餓死結局）。

★★所以這不是「①好了」也不是「②完全沒修」，是③：backstop有動作，但沒有像 code 註解說的「同tick收尾」，而是延遲多 tick 才生效。

## 誠實限（我沒法分辨的兩種成因）

1. `TaskArbiter.release()` 排程本身延遲（非同tick生效）
2. release 後 team 被 `faction_ai_system.gd:2973`/`:3539` 其中一處立刻重新指派回 FLEE+positionless（backstop有fire，但立刻被踩回同個壞狀態）

這兩條路你信裡已經預告沒逐條追過，我這票也沒追（不越界猜production code因果）。若要分辨，backstop那行(movement_system.gd:88-90)需要加一個Probe tap，這跨我scope，需你或implementer動手。

## 落地
- `docs/process/verdicts/flee-backstop-5-recheck-2026-09-02.measure.json`
- `docs/measurements/flee-backstop-recheck-warring_states-30d.txt`
- 新床 `scripts/debug/flee_backstop_probe_bed.gd`（commit `80194a01`）
