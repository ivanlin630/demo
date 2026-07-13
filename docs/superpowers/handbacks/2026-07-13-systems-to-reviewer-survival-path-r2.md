---
from: systems
to: reviewer
status: consumed
topic: [R②·survival-path] latch重選+FLEE威脅gate——審三修互擾/try_set同prio接點/threat=0判斷/真威脅不回歸;dispatch前
---

# R② 設計審：survival-path 解鎖（latch 重選 + FLEE 威脅 gate）

## 前置
- 藍圖確認範圍(`survival-path-scope-confirm`)：①latch 重選+②FLEE 威脅 gate(含 panic)。stress decay 另記 arc。
- spec `docs/superpowers/specs/2026-07-13-survival-path-unlock.md`。premise（餓隊 3023 early-return 鎖 + FLEE 0.6 floor spurious）已 code 坐實(前輪 survival-latch-root/spurious-flee-root)→免 R①,僅 R②。
- cadence(T-cad1/2)已 merge main;survival-path 建其上。

## 內容
- **①** `_evaluate_survival:3023-3028`：已餓+cadence 到→重跑 `_trigger_survival`(rank_survival 重選,換 survival option),非死等糧恢復。
- **②** `terms.gd threat_pressure`：`0.6+panic×0.4`(T1 誤 floor)→`ctx.threat<=0 ? 0 : clampf(threat+panic×0.4)`（撤 floor,無威脅→0,panic 僅威脅時計）。

## 請 R② 重點查
1. **① try_set 同-prio 接點（最關鍵）**：`_trigger_survival:3127` try_set **PRIO_SURVIVAL**。餓隊現任 survival task 也 PRIO_SURVIVAL→重選新 survival task 是**同 prio**。查 `try_set:42,57`——PRIO_SURVIVAL 非 ENGINE_SOURCES 白名單(只 unified/solo)→**同 prio survival 換不動**?若換不動,我 spec 的重選 no-op→需改 **release-then-retrigger**(release→IDLE→try_set PRIO_SURVIVAL 成立)。這是 ① 成敗關鍵,請坐實 try_set 同-prio survival 行為,判 spec 直呼 _trigger_survival 夠不夠 or 須 release 先。
2. **① 重選不 churn**：餓隊每 cadence 重選 survival——同 forage 持續失效會不會每 cadence 亂跳 survival option?（rank_survival 有 COMMITMENT?——`rank_survival` 比對 current_task 給 COMMITMENT_BONUS,查是否防抖）。
3. **② threat=0 判斷可靠**：`ctx.threat`(reputation-filtered `_max_threat`)無威脅時確 0?會否漏真威脅致該 FLEE 不 FLEE?（spec 主張真致命威脅走 `_evaluate_threat` PRIO_THREAT 反射插隊,不靠此 term——查此路確存,FLEE-term 歸零不影響真威脅反射）。
4. **② 真威脅不回歸**：threat>0 隊 eval=threat+panic 正常,FLEE 該 fire 仍 fire。
5. **三修互擾**：① 動 SURVIVAL_TASKS(不含 FLEE)、② 動 FLEE eval——不同 task 集,查真不互擾。
6. determinism（純算術+整數推進+純讀,零 randf）。

## 註
- 全 TEST VALUE,measurer 校。stress decay person-system arc 本 slice 不做(implementer 記 known_issues)。
- CLEAN(或 ① 接點需 release-then-retrigger 的修正建議)則 dispatch。互擾/真威脅回歸/churn 過險→回 verdict。
