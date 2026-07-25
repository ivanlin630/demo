---
type: spec
owner: systems
topic: A1 stall 根修 — construction commitment latch（施工中不被 unified argmax 搶外交）
status: ready-for-R2
---

# Spec：construction commitment latch（A1 stall 根修）

## 根定案（measurer 6mo tap 坐實，三根連鎖同一）

A1 forest founding/facility construction **stall 95.6-96%**（outpost_built≈0）。measurer construction pipeline tap（seed1337/42，6mo）三問坐實，**三者連鎖同一根**：

- **①transition 被蓋 63.8-67.7%**（`start_task_not_build/start`）：start_build set TASK_BUILD 成功，但隨即被別 task 蓋。samples `task_after` 混「外交/投靠」(unified) + 「逃跑/覓食/return_home」(survival)。
- **②stall 95.6-96%**：samples 全數 `ct_reason='unified'` + `ct_task='外交'`（少數貿易/ambition）——**unified 決策引擎 argmax 每 reeval 把施工隊搶去外交**。
- **③resume 全失效 0.5-0.7%**：candidates=0（沒合格隊派回，二階；owner 非-1 **反駁**「荒地 owner==-1」假設——measure-first 抓翻 code 詮釋）。

### 機制根（code 坐實）
- 外交與 build transition **同用 PRIO_DISPATCH(50)**（faction_ai:809 主 rank@DISPATCH）。TaskArbiter guard（task_arbiter:116）只擋 `>=PRIO_THREAT(70)` 被低 prio stomp → **同級 50 互相 raw 覆蓋**。
- 施工隊走 `_decide_unified`（ct_reason='unified' 坐實，非 subteam 路，`_evaluate_subteam:1717` sub-TASK_BUILD 保護沒生效）。
- **`_should_reeval`（faction_ai）cadence 分支 `if current_tick >= decision_eval_next_tick: return true` 沒豁免施工中 TASK_BUILD** → 施工隊每 cadence 被 `_decide_unified` argmax 重評 → 選外交 raw 蓋 → construction 進度停（`_tick_construction` 找不到同格 TASK_BUILD → stall）。

∴ **統一根 = construction commitment（TASK_BUILD）在 unified 決策層無 latch，被 cadence argmax 搶去外交**（手不聽腦家族核心；統一決策框架缺 construction commitment 尊重）。①②同根兩面（開工被蓋 + 已 build 又搶），③二階（搶走後救不回）。

## 要做

### 修①核心：`_should_reeval` 加 construction commitment latch
`_should_reeval` cadence 節流前加：施工中（`current_task == TASK_BUILD`）→ `return false`（不重評經濟意圖）。**放在 IDLE/stuck/crisis/directive 例外之後**（survival 深餓走 crisis edge、威脅走 stuck/crisis、faction 命令走 directive 仍能即時打斷；只擋「經濟意圖 argmax（外交/貿易/ambition）每 cadence 搶 committed builder」）。

```gdscript
# _should_reeval，directive_fresh 之後、cadence 分支之前：
# ★construction commitment latch（A1 stall 根修）：施工中不被 cadence argmax 搶去外交/貿易。
# survival(crisis edge)/威脅(stuck/crisis)/faction 命令(directive) 已在上方 gate 打斷 → 非絕對 gate。
if team.current_task == TeamData.TASK_BUILD:
    if Probe.enabled: Probe.bump("reeval.build_latch")
    return false
```

### 修②對稱：`check_construction_timeout` 取消時 release 施工隊
`_complete_construction`:393 完工有 `TaskArbiter.release(team)`（latch 自解）；但 `check_construction_timeout`（工地逾時取消）**沒 release 施工隊 current_task** → latch 下若施工隊卡 TASK_BUILD 停滯 30 天 → 永卡。對稱補：取消時 `TaskArbiter.release(ct)`（ct=construction_team_id 隊，防 latch 永卡邊角）。

## 憲法論證（守「人格 WEIGH 不 GATE」）
latch skip reeval **不違憲**：這是**已 committed 執行的 construction task latch**（隊已投料開工、專程派來建），非「人格 gate 掉決策選項」。類 `COMMANDER_COMMITMENT_BONUS`(faction_ai:910) hysteresis 精神但更強（skip 而非 bonus，因 build 非 argmax 的 intent 選項、無法用 bonus 壓）。survival/威脅/faction 命令例外全保留（crisis edge/stuck/directive 在上方 gate）→ 非絕對 gate，餓死/被打仍打斷。owner=invariants「人格 WEIGH 不 GATE」針對決策要不要做某事；施工中不每 cadence 重議經濟意圖是執行 commitment，非人格 gate。

## TDD（execution-end，禁 teleport）
- **`_test_construction_commitment_latch`**：派子隊建（`_dispatch_builder`）→ start_build set TASK_BUILD → **驅真 tick 迴圈**（`FactionAISystem.process()` + `MovementSystem.process()` + construction tick，非 teleport）跑滿工期 → 斷言：施工隊 current_task 全程 TASK_BUILD 不被外交蓋（或最終 `outpost_level>0` 真完工）。對照無 latch baseline（施工隊被搶、outpost_level=0 不完工）。
- **完工釋放驗**：完工後施工隊 current_task 釋放（非卡 TASK_BUILD）→ 可正常接新 task。
- **survival 例外驗**：施工中深餓 → crisis edge 仍能打斷 latch（不餓死工地）。
- 閘：headless 0-new + gate 74 removed=0 + determinism 3跑 byte-identical。

## 交付 → measurer execution-verified（★這輪硬標準）
重跑 A1 focused（seed1337/42，6mo）：**outpost_built > 0**（forest founding + facility 真完工，對照 stall baseline 95.6%）+ stall 佔比消退 + construct.complete 上升 + reeval.build_latch fire。★fix 驗收 = execution-verified（跑起來 outpost_built>0），非只 R² CLEAN（上輪教訓）。→ 數字 to:blueprint（release-pass）+ specimen to:QA（A1 鏈真走完）。

## ③resume 候選池空 followup（治本後 watch）
latch 修好後施工隊不離格 → resume 需求淡化。measure 若 resume.attempt/stall 消退 → ③自然解，純紀錄；若殘留（施工隊仍偶離格）→ 補 resume 候選資格（優先召原 construction_team_id 隊）。**不本刀修**（whole：先治本 latch，measure 定 ③殘否）。material 續 PARK。
