---
from: systems
to: measurer
status: consumed
topic: "[try_set 共根 diagnostic(A2-settle+A3-build 合一票、blueprint GO、diagnostic-first 禁猜禁priority-crank)·A2 invite_settle try_set 40/41 卡 + A3 build 12/15 noop=疑同 try_set 根(手不聽腦 arbiter latch 家族 [[project_reverse_engineering_arc]] 99%病前科)·★systems code-read narrow(task_arbiter.gd try_set 每 return-false 路徑):①crisis_released_task(:56-58)②persist.hold(:64-70、被 measurer 疑但★未必真兇:PROGRESSIVE_HOLD_TASKS=[BUILD/CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE]全construction型、但被邀wanderer多做forage/move不在此集→persist.hold可能不觸)③★equal-priority fall-through(尾:new priority 非 > 現任 task_priority 且非 IDLE 且 equal-priority self-replace 要 _source∈ENGINE_SOURCES[invite_settle/build source 疑不在]→隱式 return false)·★量測(tap 每條 return-false 分清真兇、prod tap 用完 revert):對 invite_settle(A2)+build(A3)的 try_set 呼叫、逐筆記中哪條 return-false(crisis/persist.hold[已有:69 tap]/equal-fallthrough[需補 tap]/其他)、佔比·dominant path 的 blocker context dump:被擋團 current_task+task_priority+persist_strength+held 多久(tick−task_start_tick)+_source·★genuine-vs-patch 判:被擋團現任 task 是否真更高/等值價值(genuine commitment 該讓路?)vs 機械 latch over-block(patch-gate→de-patch);★禁預設哪條、禁 priority-crank(把 invite_settle/build 優先級調高到贏=灌分同款、blueprint 禁)·output=真兇 return-false path+blocker 分布+genuine/patch 判→systems per-evidence spec fix(patch-gate→de-patch)·官方 helper 勿手設 team_ids 先讀既有 dump·evidence-only·地基KEEP"
---

# try_set 共根 diagnostic（A2-settle + A3-build 合一、blueprint GO）

A2 `invite_settle` try_set 40/41 卡 + A3 `build` 12/15 noop = 疑**同 try_set 根**（手不聽腦 arbiter latch 家族、[[project_reverse_engineering_arc]] 99%病前科）。diagnostic-first、**禁猜、禁 priority-crank**。evidence-only。

## ★systems code-read narrow（task_arbiter try_set 每 return-false 路徑）
1. `crisis_released_task`（:56-58）：new_task==crisis_released 且窗內。
2. `persist.hold`（:64-70、已有 `:69 Probe.bump("persist.hold")` tap）：現任 ∈ `PROGRESSIVE_HOLD_TASKS`=[BUILD/CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE] + persist_strength>0.1。★**但未必真兇**：被邀 wanderer 多做 forage/move（**不在此集**）→ persist.hold 可能不觸。
3. ★`equal-priority fall-through`（尾）：new priority 非 `> 現任 task_priority` 且現任非 IDLE、且 equal-priority self-replace 要 `_source ∈ ENGINE_SOURCES`（`invite_settle`/`build` source **疑不在**）→ 隱式 return false。

## ★量測（tap 每條 return-false 分清真兇、prod tap 用完 revert）
- 對 `invite_settle`（A2）+ `build`（A3）的 try_set 呼叫、**逐筆記中哪條 return-false**（crisis / persist.hold[已 tap] / equal-fallthrough[需補 tap] / 其他）、**佔比**。
- **dominant path 的 blocker context dump**：被擋團 `current_task` + `task_priority` + `persist_strength` + held 多久（`current_tick − task_start_tick`）+ `_source`。

## ★genuine-vs-patch 判
- 被擋團現任 task 是否**真更高/等值價值**（genuine commitment 該讓路？）vs **機械 latch over-block**（patch-gate → de-patch [[feedback_patch_gate_first]]）。
- ★**禁預設哪條、禁 priority-crank**（把 invite_settle/build 優先級調高到贏=灌分同款、blueprint 禁）。

output = 真兇 return-false path + blocker 分布 + genuine/patch 判 → systems per-evidence spec fix（patch-gate→de-patch、非調參）。官方 helper 勿手設 `specimen_team_ids`、先讀既有 dump。地基 KEEP。
