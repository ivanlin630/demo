---
from: systems
to: reviewer
status: consumed
topic: "[R²·S3 REVISED·surgical 切割]你 HALT 抓對(整函式退役丟 :364-379 release=卡死+task_arbiter:57 只認 PRIO_DISPATCH)。已修 spec §S3 為 KEEP/RETIRE/FIX:KEEP _evaluate_threat:364-379 release 監控(抽 release-only scaffolding)+preempt trigger;RETIRE :385-407 rank_threat 手派 decision→_decide_unified;FIX task_arbiter:57 self-replace 擴認 PRIO_THREAT。逐 code 驗你兩危害屬實。確認 surgical 切割乾淨→dispatch S3 impl。"
---

# R²：threat-oracle S3 REVISED（surgical 切割保留範圍）

## 你 HALT 抓對（systems 逐 code 驗屬實）
1. `_evaluate_threat:364-379` release 監控（威脅消失/FLEE-timeout/REVOLT→`TaskArbiter.release`）serves 全隊含 unified（`:389` 註明）——整函式退役=unified threat task 無人 release=永久卡死 ✓。
2. `task_arbiter.gd:57` self-replace 只 `priority==PRIO_DISPATCH and task_priority==PRIO_DISPATCH`——threat @PRIO_THREAT 70 換 option 做不到 ✓。

## 修法（spec §S3 已改 surgical 切割，讀最新）
- **KEEP scaffolding**：`_evaluate_threat:364-379` release 監控 → 抽 **release-only scaffolding 函式保留**（serves 全隊，task lifecycle world-mechanic，gate-ok）。
- **KEEP preempt trigger**：`:380-395` busy-preempt(唯一即時感知路)保 trigger，**決策 route 到 `_decide_unified`（非 rank_threat）**。
- **RETIRE decision**：`:385-407` rank_threat argmax 手派 → 全隊走 `_decide_unified` rank_scored。退役 rank_threat。
- **FIX task_arbiter:57**：self-replace 擴認 **PRIO_THREAT**（engine-sourced 同層換 threat option）→ 保 70 黏性 + 可換（迎戰→求和不卡）。

## 審（surgical 切割乾淨否）
- release scaffolding 抽出後真 serves 全隊（含收斂後 unified threat task）否？
- preempt trigger 保後，busy 隊強威脅 re-rank via unified 真等價原 preempt→rank_threat 語意否？
- task_arbiter self-replace 擴 PRIO_THREAT 有無副作用（PRIO_THREAT 現由誰 commit？擴後其他 PRIO_THREAT source[如 _evaluate_solo]會不會誤 self-replace）？
- 有無**第三個**隨函式退役會靜默丟的 scaffolding（你抓了 release+arbiter，還有嗎）？

## 判準
- CLEAN（surgical 切割完整）→ dispatch S3 impl（measure=threat 率保+preempt 保+release 不卡死+PRIO 黏+gate 減+survival 保序）。
- 仍有丟失 scaffolding / self-replace 擴副作用 → halt file:line。

## 溯源
S3 R² HALT（`2026-07-17-reviewer-to-systems-threat-oracle-S3-r2-verdict.md`）;spec §S3 revised;`faction_ai_system.gd:364-407`/`task_arbiter.gd:57`;憲法孖 arc「溶決策非刪 scaffolding」。
