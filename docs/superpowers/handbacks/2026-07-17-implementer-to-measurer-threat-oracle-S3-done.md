---
from: implementer
to: measurer
status: consumed
topic: "[threat-oracle S3 交付·真統一 finale] 退役 rank_threat 手派→threat 決策全走 _decide_unified rank_scored 全 pool。KEEP release+preempt trigger;FIX task_arbiter PRIO_THREAT self-replace;threat 反應 @PRIO_THREAT 70。gate _evaluate_threat::taskarbiter removed(64,零殘留)。branch feat/threat-oracle-s3 HEAD 7e8f61b0 off origin/main@d5bbbece。threat_dissolution ALL PASS(repertoire+live-seam 收斂驗)+headless 3-baseline。請 organic 中性複核:threat 率保+preempt保+release不卡死+PRIO黏+gate減+preempt 分佈。"
---
# Hand Back：threat-oracle S3 收斂（真統一 finale）

**branch** `feat/threat-oracle-s3`（已 push）**HEAD `7e8f61b0`**，off origin/main `d5bbbece`（S2 calibrate 版，base=(A) systems 確認）。

## 實作摘要（surgical KEEP/RETIRE/FIX）
- **RETIRE rank_threat 手派**（`_evaluate_threat` 內 `for opt in rank_threat: try_set`）→ **threat 決策全走 `_decide_unified` rank_scored 全 pool**（severity-scaled threat option 全 pool 競秤=北極星「一 encounter eval」）。unified 隊本就 _decide_unified；non-unified/busy-preempt 現亦 route。
- **KEEP release scaffolding**（`_evaluate_threat` REVOLT + DEFEND/PREPARE/FLEE/HOLD release，在 uses_unified gate **之前**=serves 全隊含收斂後 unified threat task→無永久卡死）。
- **KEEP preempt trigger**（busy gate + threat 門檻=trigger），決策 route `_decide_unified`（force reeval：threat 非 `_should_reeval` 內建 trigger→設 `decision_eval_next_tick=now` 保 threat 觸發即反應）。
- **FIX `task_arbiter:57`**：self-replace 擴認 **PRIO_THREAT**（`priority in [PRIO_DISPATCH, PRIO_THREAT] and task_priority==priority`）→ 同層 threat option 可換（迎戰→求和 不卡）；source 白名單(unified/solo)擋 uprising 誤觸。
- **`_decide_unified` commit 備戰/迎戰/求和 @PRIO_THREAT 70**（finding3 黏性——收斂後不被高值經濟 @50 stomp；S1 probe 已在此接 threat.dispatch tap）。side-effect（wire/flee/threat.dispatch/specimen）由 _decide_unified commit loop 承（DRY）。

## 自驗
- **constitution_gate PASS sites=64 removed=1**（★`_evaluate_threat::taskarbiter` fingerprint **removed**=threat 控制流零殘留進度，dispatch 目標達成；rank_threat::dispatch_entry 留=見下 flag）。
- **threat_dissolution_check ALL PASS**：4 原型 repertoire（迎戰/備戰/求和/FLEE 仍 fire）+ **★live-seam 收斂驗**（non-unified idle 狂徒 → `_evaluate_threat` route `_decide_unified` → 迎戰 實派 + `threat.dispatch.迎戰` bump 124→125=收斂路+observability 活）。
- **full headless**：`=== DONE ===` + 3 pre-existing baseline（無新增）。import clean。

## ★連動風險 / flag
- **★rank_threat orphaned（production 退役，harness 留）**：production 唯一 caller（`_evaluate_threat`）已移除；剩 `threat_dissolution_check`(harness 原型表)引用。**未刪 rank_threat 函式**（dispatch「harness 若引用另議」）→ 現為 test-only accessor。若要 gate `rank_threat::dispatch_entry` 也 removed（全零殘留），需刪函式 + 遷 threat_dissolution repertoire 到 rank_scored_ctx（我 S2 char bed 已 rank_scored_ctx 驗 4 象限，可覆蓋）——待你裁是否本 slice 做 or 另 slice。
- **★survival(FLEE) 不在 threat.dispatch tap**（S1 scope=備戰/迎戰/求和）：收斂後 threat-FLEE 走 _decide_unified 無 threat.dispatch.survival bump（舊 rank_threat 有）。observability 部分 gap（threat-FLEE 率不可直接由 threat.dispatch.survival 量）。若要補=_decide_unified 加 survival tap（但 survival 雙用 threat/絕境,需 ctx.threat gate 區分)——待裁。
- **★survival(FLEE) PRIO**：收斂後 survival @PRIO_DISPATCH 50（舊 rank_threat 路 @70）；threat-FLEE 黏性改由 util/boost/commitment 承（非 PRIO）。measurer 驗 FLEE 率保。
- **double-gather**（_evaluate_threat gather ctx 門檻檢 + _decide_unified re-gather）：perf 小增（per-cadence 非 per-tick）。measurer perf 留意。

## 下一站（★measurer organic 中性複核，非 byte-identical）
- **threat 率保**（迎戰/備戰/求和/FLEE 收斂後 vs S2 similar，不因收斂變）。
- **preempt 保**（忙碌隊強威脅仍打斷=route _decide_unified force reeval 生效）。
- **release 不卡死**（threat task 威脅消失/timeout release，無永久卡）。
- **PRIO 70 黏性**（threat 反應不被經濟 stomp）。
- **gate 減**（_evaluate_threat::taskarbiter removed 已證；rank_threat 見 flag）。
- **★R² 建議 preempt 後選中分佈**（打斷後選哪 threat option 分佈健康）。
- survival 保序。綠 → to:systems 判 merge。**threat-oracle arc 完成**（真統一達成）。

## 溯源
S3 dispatch `...S3-convergence.md`（R² CLEAN surgical）；base 確認 `...S3-base-confirm-A.md`；spec §S3；`faction_ai_system.gd:364-407`/`task_arbiter.gd:57`/`_decide_unified`；seam#1 findings 3/4；[[project_unification_matrix]] 序3 北極星。
