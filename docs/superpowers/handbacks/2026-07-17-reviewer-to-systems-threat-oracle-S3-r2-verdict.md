---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict·異質(Sonnet)] threat-oracle S3 收斂：HALT。字面『退役 _evaluate_threat 手派路由』若整函式退役會靜默丟掉:364-379 的 release 監控（威脅消失/逃跑逾時→release），unified 隊 commit PRIO_THREAT 後無人 release；加上 task_arbiter.gd:57 self-replace 快捷路徑寫死只認 PRIO_DISPATCH 不認 PRIO_THREAT，同層換不同 threat option 做不到——兩者疊加=威脅任務永久卡死回歸。需 spec 明確切割保留範圍。"
---

# R② 判決：threat-oracle S3 收斂 — HALT（commit loop 有具體坑）

## 核實現況（S1/S1.5/S2 已 merge，逐 file:line）
`terms.gd:188-209` 確認 S2 severity-scaled util 已落地（prepare/confront/pacify 三式皆讀 `SEVERITY_MAX`/`winnable`/`lerpf` 等，與上輪 REVISED 判決核實內容一致）。S3 提案：退役 `rank_threat`（`decision_engine.gd:143`）filtered-hard subset + `_evaluate_threat`（`faction_ai_system.gd:364`）手派路由，preempt 改觸發 `_decide_unified` 走 `rank_scored` 全 pool；`_decide_unified` commit（現況 `:1556` 固定 `TaskArbiter.PRIO_DISPATCH`）依選中 option 類型分流 PRIO（threat 類→`PRIO_THREAT`70）。

## ★命中：`_evaluate_threat` 的 release 監控段跟手派 dispatch 段是兩件不同的事，spec 文字沒切開

逐讀 `faction_ai_system.gd:364-407` 全函式，內容分三段：
1. **`:365-372` cadence gate + REVOLT 特例**（純機械）。
2. **`:373-379` ★release 監控**：`if team.current_task in [TASK_DEFEND, TASK_PREPARE, TASK_FLEE, TASK_HOLD]:`——**已在威脅反應 task 中**，此段判「威脅消失→`TaskArbiter.release(team)`」或「FLEE 逾時→release」。**這段對 unified 隊同樣生效**（函式沒有依 `uses_unified(team)` 分流這一段，只在下面 `:387-390` 的「IDLE 分支」才排除 unified 隊避免雙觸發）——換句話說，**目前架構下，任何隊（含 unified）一旦 current_task 落在這 4 個威脅 task，都是靠這段邏輯定期檢查「該不該放手」**。
3. **`:380-407` preempt gate + 手派 dispatch**（`rank_threat` filtered dispatch 迴圈，S3 明確要退役的部分）。

**spec §S3 原文只講「退役 rank_threat filtered subset + `_evaluate_threat` 手派路由」——語意上可以讀成「整個 `_evaluate_threat` 函式退役」，也可以讀成「只退役函式內的手派 dispatch 那段（3）」。兩種讀法對系統行為的影響天差地遠**：若 implementer 照字面把整個函式砍掉（含第 2 段 release 監控），S3 收斂後 unified 隊透過 `_decide_unified` commit 了 `PRIO_THREAT` task，**將沒有任何邏輯負責在威脅消失時把它 release 回 IDLE**——因為：
- `_decide_unified` 本身（`:1476-1557` 全函式核對過）沒有等價的「威脅消失→release」檢查。
- `_should_reeval`（`:1820-1844`）沒有排除「current_task 是威脅回應」的情況，正常 cadence 一到就會嘗試重評——但重評結果要 commit 回同一個 `PRIO_THREAT` 層，撞第二個坑（下段）。

## ★疊加坑：`task_arbiter.gd:57` self-replace 快捷路徑硬寫死只認 `PRIO_DISPATCH`，不含 `PRIO_THREAT`

```
task_arbiter.gd:57   if priority == PRIO_DISPATCH and team.task_priority == PRIO_DISPATCH \
task_arbiter.gd:58           and _source in ENGINE_SOURCES \
```

`try_set` 的一般晉升規則（`:42`）要求 `priority > team.task_priority`（**嚴格大於**）。同層想換（同優先層、不同 task/target）唯一走得通的路是這條 self-replace 快捷路徑——**但它硬編碼比對 `priority == PRIO_DISPATCH`（字面值50），非泛用的 `priority == team.task_priority`**。若 `_decide_unified` 改成對 threat option 用 `PRIO_THREAT`(70) commit，之後**同樣是 PRIO_THREAT 層、rank 結果換了一個不同 threat option**（如威脅位置變了，該從迎戰換 FLEE）想要更新——`priority(70) == team.task_priority(70)` 但 `priority != PRIO_DISPATCH`，self-replace 分支不觸發，`try_set` fall through 到 `:86 return false`，**commit 靜默失敗，隊伍卡在舊 threat option 上**。

**這兩個坑疊加的後果**：若 release 監控（第2段）被砍掉，`try_set` 又無法同層換手，PRIO_THREAT task 一旦 commit，**除非被更高優先層（PRIO_SURVIVAL 80/PRIO_COMBAT 100）或 timeout 打斷，否則永久卡死**——威脅早就消失了，隊伍還在原地「迎戰」，直到某個外部機制解套。這正是 seam#1/finding3 想解決的「黏性」問題被**過度解決**：從「掉黏性（70→50 太快掉）」變成「黏死（release 路徑斷）」。

## Preempt 語意本身：核實通過
`:380-395` preempt gate（`_busy_preemptible`/`PREEMPT_MARGIN` 門檻）本身若保留為 world-mechanic 觸發器、只改觸發目標（從 `:396` 的 `rank_threat` 迴圈改成呼叫 `_decide_unified` 走 `rank_scored`），語意合理：「威脅夠大→觸發一次全局重評，威脅選項現在能在全 pool 自然競秤」，符合「一次 encounter eval」北極星。**此部分設計無問題**，前提是 release 監控（第2段）明確保留、且不受此改動影響。

## 判準結果
**HALT**——不是設計方向錯，是 spec 文字對「`_evaluate_threat` 退役範圍」交代不清，實作時真的可能整函式砍掉，連帶丟失 release 監控，撞上 `try_set` self-replace 白名單缺口，兩者疊加 = 威脅任務卡死回歸。**要求 systems 明確裁定並寫進 spec（二選一或混合，皆可，只要明講）**：

1. **保守路（建議）**：`_evaluate_threat` 只退役 `:380-407`（preempt gate + 手派 dispatch，改觸發 `_decide_unified`），**明確保留 `:364-379`（cadence gate + REVOLT 特例 + release 監控）**，此函式瘦身成「威脅 task 的 release 看門人 + preempt 觸發器」，不再自己手派 task。release 監控**對 unified/non-unified 隊一視同仁**（現況已是如此，不必新寫）。
2. 或**明確擴充 `try_set`**：把 `task_arbiter.gd:57` 的 self-replace 快捷路徑從硬編碼 `priority==PRIO_DISPATCH` 擴大到 `priority in [PRIO_DISPATCH, PRIO_THREAT]`（連帶想清楚這會不會影響其他已用 `PRIO_THREAT` 的呼叫點，如 `:3694`/`:3698` 的起義 uprising——起義是否也該同層可換手，需一併裁定，非只為 threat 開特例）；**若走此路仍須决定 release 監控歸屬**（route 1 的 release 段是否仍需要，或改靠某種一般化 timeout 機制）。

**兩選一（或說明第三案）之後免重整輪**，implementer 落地時對 `_evaluate_threat` 保留/刪除範圍逐行核對 spec 明文，不留模糊空間。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md` §S3；systems handback `2026-07-17-R2-systems-to-reviewer-threat-oracle-S3-convergence.md`；`faction_ai_system.gd:360-407`（`_evaluate_threat` 全函式）/`:1476-1557`（`_decide_unified`）/`:1820-1844`（`_should_reeval`）/`:108-121`（`PREEMPTIBLE_TASKS` 排除威脅 task 註解）；`task_arbiter.gd:35-86`（`try_set` 全函式，self-replace 白名單）；先前本 reviewer threat-oracle v1/REVISED 判決。
