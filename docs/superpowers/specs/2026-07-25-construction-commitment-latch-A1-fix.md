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

### 修①核心：`_should_reeval` 加 construction commitment latch（★R² 訂正：威脅 force 必繞）

**★R② 抓到的安全洞（reviewer HIGH，已訂正）**：latch **不能**對 `_should_reeval` 全函式無差別 `return false`。**威脅回應路徑是 `faction_ai:401-423` busy-preemptible check**（`TASK_BUILD ∈ PREEMPTIBLE_TASKS`，`threat_react ≥ threat_threshold + PREEMPT_MARGIN(2.0)` → `decision_eval_next_tick=current_tick`:422 → `_decide_unified`:423）——這條**靠「reset cadence timer → `_should_reeval` cadence 分支判 true」生效，不經 crisis/stuck/directive**。若 latch 放 cadence 分支前無差別擋 → 威脅 force reeval 被悶 → **施工隊被敵人跨過 preempt 門檻仍不逃、可能被殲滅**（比 A1 原 bug 更重）。

**訂正：force 參數穿透，威脅 force 繞 latch，只擋例行 cadence**：
```gdscript
# _decide_unified 加 force 參數，穿透到 _should_reeval：
func _decide_unified(state, team, force_reeval := false) -> void:
    if not _should_reeval(state, team, force_reeval): return
    ...

func _should_reeval(state, team, force_reeval := false) -> bool:
    if force_reeval: return true            # ★威脅 force(:401-423)/其他明確 force → 繞 latch+cadence
    if current_task == TASK_IDLE: return true
    if _is_stuck: return true
    # crisis edge ...
    if directive_fresh: return true
    # ★construction commitment latch（A1 stall 根修）：施工中不被【例行 cadence】argmax 搶去外交/貿易。
    #   威脅 force 已在上方 force_reeval 繞過（不悶逃命）；深餓走 crisis edge；命令走 directive。
    if team.current_task == TeamData.TASK_BUILD:
        if Probe.enabled: Probe.bump("reeval.build_latch")
        return false
    if current_tick >= decision_eval_next_tick: return true
    return false
```
- **威脅段 `:423` 改 `_decide_unified(state, team, true)`**（force=true 繞 latch，讓被逼近的施工隊能逃）。其他 `_decide_unified` 呼叫（1463/1485/1488/1920）保持預設 `force=false`（例行 → latch 對施工中生效）。
- ★實作細節（哪些呼叫傳 force、unified:1523 vs solo:1923 兩 `_should_reeval` 呼叫點是否都需穿透）由 implementer 判——**硬約束：威脅 force 路徑（:401-423）必繞 latch，純例行 cadence reeval 被 latch 擋**。

### 修②對稱：`check_construction_timeout` 取消時 release 施工隊
`_complete_construction`:393 完工有 `TaskArbiter.release(team)`（latch 自解）；但 `check_construction_timeout`（工地逾時取消）**沒 release 施工隊 current_task** → latch 下若施工隊卡 TASK_BUILD 停滯 30 天 → 永卡。對稱補：取消時 `TaskArbiter.release(ct)`（ct=construction_team_id 隊，防 latch 永卡邊角）。

## 憲法論證（守「人格 WEIGH 不 GATE」，★R² 訂正引錯 gate）
latch skip reeval **不違憲**：這是**已 committed 執行的 construction task latch**（隊已投料開工、專程派來建），非「人格 gate 掉決策選項」。類 `COMMANDER_COMMITMENT_BONUS`(faction_ai:910) hysteresis 精神但更強（skip 而非 bonus，因 build 非 argmax 的 intent 選項、無法用 bonus 壓）。

**★R② 訂正（我原論證引錯 gate）**：我原寫「威脅走 stuck/crisis」**錯**——`_decision_crisis`(1868) 只管人口崩潰/糧食流崩、`_is_stuck`(92) 管路徑卡，**都非威脅 gate**。正確的例外對應：
- **威脅**（被敵人逼近）→ `:401-423` busy-preemptible check，**靠 `force_reeval=true` 繞 latch**（本 spec 訂正後）——不是靠 crisis/stuck。
- **深餓** → `_decision_crisis` crisis edge（在 latch 上方 return true）。
- **faction 命令** → `directive_fresh`（在 latch 上方 return true）。
- **卡住** → `_is_stuck`（在 latch 上方 return true）。

∴ 該打斷施工的四路（威脅/深餓/命令/卡住）全保留、各走各 gate → latch **只擋純例行 cadence 的經濟 argmax（外交/貿易/ambition）**，非絕對 gate。owner=invariants「人格 WEIGH 不 GATE」針對決策要不要做某事；施工中不每例行 cadence 重議經濟意圖是執行 commitment，非人格 gate。

## TDD（execution-end，禁 teleport）
- **`_test_construction_commitment_latch`**：派子隊建（`_dispatch_builder`）→ start_build set TASK_BUILD → **驅真 tick 迴圈**（`FactionAISystem.process()` + `MovementSystem.process()` + construction tick，非 teleport）跑滿工期 → 斷言：施工隊 current_task 全程 TASK_BUILD 不被外交蓋（或最終 `outpost_level>0` 真完工）。對照無 latch baseline（施工隊被搶、outpost_level=0 不完工）。
- **完工釋放驗**：完工後施工隊 current_task 釋放（非卡 TASK_BUILD）→ 可正常接新 task。
- **★★威脅繞 latch 驗（R² 必補）**：施工中隊 + `threat_react ≥ threat_threshold + PREEMPT_MARGIN(2.0)`（真敵人壓境）→ `:401-423` 觸發 force reeval → **繞 latch、施工隊能逃/反應（非被 latch 悶住）**。★這與深餓測是**兩回事**（深餓走 `_decision_crisis`、威脅走 `:401-423`）——**兩者分開測，測深餓不能替代測威脅**。
- **深餓例外驗**：施工中深餓 → crisis edge 仍能打斷 latch（不餓死工地）。
- **★★directive-leak resume 救回驗（2nd-layer 必補）**：施工中隊被 faction directive leak 拉去外交（仍在工地格）→ `_try_resume_construction` 優先召回原隊 → 續建 → **驅真 tick 迴圈跑到 outpost_level>0 真完工**（execution-end，非 teleport）。對照無 resume（單 latch）baseline：leak 後永久棄、不完工。
- 閘：headless 0-new + gate 74 removed=0 + determinism 3跑 byte-identical。

## 交付 → measurer execution-verified（★這輪硬標準）
重跑 A1 focused（seed1337/42，6mo）：**outpost_built > 0**（forest founding + facility 真完工，對照 stall baseline 95.6%）+ stall 佔比消退 + construct.complete 上升 + reeval.build_latch fire。★fix 驗收 = execution-verified（跑起來 outpost_built>0），非只 R² CLEAN（上輪教訓）。→ 數字 to:blueprint（release-pass）+ specimen to:QA（A1 鏈真走完）。

## 修③ resume 治本（★2nd-layer，load-bearing——execution-verified 坐實非 followup）

**★訂正（我原判斷錯）**：spec 原把 resume 延 followup。implementer execution-verified（1mo tap）坐實 **resume 實為完工 load-bearing，非 optional**：
- latch fires 8332（擋 cadence steal 有效，94.6% held）但 **complete=1 未改善**（stall 3555 未消退）。
- 根：latch 減 leak 但**無法 0 leak**——`_decide_unified` latch 早退（:1523）→ `last_decision_tick`(:1528) 不更新 → faction 發 directive（`directive_change_tick > 舊 last_decision_tick`）→ `_directive_fresh` true（latch 上方）→ building member reeval → argmax 選外交 → **棄工地**（leak_directive=439 主 / crisis 19 / force 12）。
- **任一 leak = 永久棄**：builder→外交後**仍在工地格**（stall samples `ct_pos==tile`、`current_task=外交`），但 `_try_resume_construction` owner/resident gate **排除 builder 自己**（它非 outpost_owner、非 TAG_PRODUCE resident）→ 召不回 → 工地永久 stall → complete≈0。

∴ latch（減 leak）+ resume（救 residual leak）= **閉環，缺一不可**。resume 升 load-bearing、本刀同修（whole-system-first：一次修全部卡點）。

### 修：`_try_resume_construction` 優先召回原施工隊
`_try_resume_construction`（faction_ai:2742）「已有人施工 return」（:2746）後、現有 candidates 掃描前，插入：
```gdscript
# ★2nd-layer load-bearing：優先召回原施工隊(construction_team_id)。它專程來建、
# 常還在工地格只是被 directive/crisis/force leak 拉去外交(stall samples ct_pos==tile)→
# release 舊 task 續建。繞 owner/resident gate(它是原施工隊本人,非「找別隊接手」)。
var orig: TeamData = state.teams.get(tile.construction_team_id)
if orig != null and orig.combat_target == -1 \
        and orig.tile_pos == tile.tile_pos \
        and orig.current_task != TeamData.TASK_BUILD:
    # 糧 gate 仍守(餓不搬磚,避與 survival ping-pong,同現有 :2760)
    var od: float = ResourceSystem.effective_food(state, orig) \
        / maxf(float(orig.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
    if od >= 3.0:
        TaskArbiter.release(orig)                                       # release-first 過 transition guard
        TaskArbiter.transition(state, orig, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
        if Probe.enabled: Probe.bump("resume.orig_recall")
        return
# orig 死/離格/戰鬥/餓 → 落回現有 candidates(別隊接手)
```
- **繞 owner/resident gate 的理由**：orig 就是這 tile `construction_team_id` 記錄的原施工隊（它開的工），召它續建 ≠「找別隊接手」→ owner/resident 資格對它不適用。糧 gate 保留（餓不搬磚，survival 打斷正當）。
- orig 死/晉升/detach（`state.teams.get` null）/離格/戰鬥/餓 → 落回現有 candidates 邏輯（別隊接手，不退化）。

### （B）directive 對 building 例外 — followup watch（非本刀）
(A) resume 救回後，directive→外交→resume→build **ping-pong thrash** 可能是 decision 噪音（build progress 不因 task 變重置 → 仍完工，但決策噪音干擾 QA 故事）。若 execution-verified 後 measure 顯 thrash 兇（resume.orig_recall 巨量/complete 仍被拖）→ 補 (B)：`_directive_fresh` 對 building member（current_task==TASK_BUILD）免疫（faction 經濟 directive 不拆自家工地；survival/threat directive 走別 gate 仍打斷）。**先 (A) 治本，measure 定 (B) 需否**。material 續 PARK。
