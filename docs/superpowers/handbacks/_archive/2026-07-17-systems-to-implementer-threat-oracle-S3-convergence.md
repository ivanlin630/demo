---
from: systems
to: implementer
status: consumed
topic: "[dispatch·threat-oracle S3 收斂·真統一 finale] R² CLEAN(surgical)。KEEP _evaluate_threat:364-379 release 監控(抽 release-only scaffolding,serves全隊)+preempt trigger(決策 route _decide_unified);RETIRE :385-407 rank_threat 手派 decision(全隊走 _decide_unified rank_scored);FIX task_arbiter:57 self-replace 擴認 PRIO_THREAT。gate threat 控制流 fingerprint removed=零殘留。measure=threat 率保+preempt保+release不卡死+PRIO黏+gate減。worktree feat/threat-oracle-s3 off origin/main@d5bbbece。"
---

# threat-oracle S3：收斂（真統一 finale，surgical 切割）

## scope（讀 spec §S3 revised 全文，surgical KEEP/RETIRE/FIX）
spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md` §S3。threat 選項（S2 已 severity-scaled）收斂進 rank_scored 全 pool，退役 filtered rank_threat=真統一「一 encounter eval」。**★溶決策非刪 scaffolding**（憲法孖 arc 老區分，R² 逼出）：

## 逐項（KEEP / RETIRE / FIX）
1. **KEEP release scaffolding**：`_evaluate_threat:364-379`（cadence gate + REVOLT release + DEFEND/PREPARE/FLEE/HOLD 威脅消失 or FLEE-timeout→`TaskArbiter.release`）**抽成 release-only scaffolding 函式保留**（serves 全隊含收斂後 unified threat task；R² 驗:整函式退役=unified threat task 無人 release=永久卡死）。
2. **RETIRE decision**：`:385-407` 非統一 `rank_threat` argmax 手派 dispatch → **全隊 threat 決策走 `_decide_unified` rank_scored**（unified idle `:390` 已如此，擴全隊）。**退役 `rank_threat`**（+其 accessor if orphan；harness `threat_dissolution_check` 若引用另議）。
3. **KEEP preempt trigger, route decision unified**：`:380-395` busy-preempt(壓境威脅打斷忙碌隊=唯一即時感知路)保 trigger，**決策 route `_decide_unified`（非 rank_threat）**→ preempt 語意保。
4. **FIX task_arbiter:57**：self-replace 條件擴認 **PRIO_THREAT**（`priority in [PRIO_DISPATCH, PRIO_THREAT] and task_priority 同`，engine-sourced）→ 保 70 黏性 + threat option 可換（迎戰→求和不卡）。R² 驗:source 白名單擋 uprising 誤觸。
5. **_decide_unified commit threat option @PRIO_THREAT 70**（finding3 黏性；S1 probe 已在此接 threat.dispatch tap）。

## TDD + measure
1. char/threat_dissolution bed：收斂後 threat repertoire（迎戰/備戰/求和/FLEE）仍 fire + release 仍 release（威脅消失/timeout）+ preempt 忙碌隊仍應強威脅。
2. 收斂重構。
3. **measure（行為保 + 結構）**：threat 率（迎戰/備戰/求和/FLEE）收斂後 vs S2 similar（不因收斂變）+ **preempt 保**（忙碌隊強威脅仍打斷）+ **release 不卡死**（threat task 威脅消失後 release，無永久卡）+ **PRIO 70 黏性** + **gate:`_evaluate_threat` decision/`rank_threat` fingerprint removed（零殘留進度）** + survival 保序。**★R² 建議加:preempt 後選中結果分佈**（打斷後選哪 threat option 的分佈健康否）。
4. git commit per green。

## 完成 → 下一站
done+綠 → to:measurer（收斂中性複核:threat 率保 seeded + preempt/release + gate 減 + PRIO 黏 + preempt 分佈）。measurer 綠 → to:systems 判 merge。**threat-oracle arc 完成**（真統一達成，threat 進統一 rank）。

## 溯源
S3 R² CLEAN（`2026-07-17-reviewer-to-systems-threat-oracle-S3-revised-r2-clean.md`）;spec §S3 revised;`faction_ai_system.gd:364-407`/`task_arbiter.gd:57`/`_decide_unified`;seam#1 findings 3/4;[[project_unification_matrix]] 序3 北極星「一 encounter eval」。
