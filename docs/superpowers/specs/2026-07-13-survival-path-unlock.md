# survival-path 解鎖（survival-latch 重選 + FLEE 威脅 gate）— systems HOW

> 藍圖確認範圍(`survival-path-scope-confirm`)：①survival-latch 重選 + ②FLEE 威脅 gate(含 in-slice panic)。person-system stress decay 另記獨立 arc。解餓隊/食足隊 survival-path「卡住不鬆綁」死亡。

## 動機（坐實）
- **餓隊鎖死**（Team7 覓食 90 天）：`_evaluate_survival:3023-3028` 已在 survival task→early-return，只糧恢復(7天)才釋放，`_trigger_survival`(rank_survival 重選)在其後→**永不重選**。forage 失效永不換策略。
- **食足隊 spurious FLEE 餓死**：`threat_pressure`(FLEE eval)= `0.6+panic×0.4`(T1 我 spec 錯)→FLEE base 恆≥0.6 與威脅無關→食足無威脅隊被 FLEE 主導(Team7 94.3%)→不生產→餓死。panic 螺旋(FLEE PRIO_THREAT 鎖+timeout re-latch)。

## ① survival-latch 重選（`faction_ai_system.gd _evaluate_survival:3023-3028`）
現：
```gdscript
if team.current_task in SURVIVAL_TASKS:
    if days_left >= SURVIVAL_RECOVER_DAYS and not proactive_camp:
        TaskArbiter.release(team)
    return
```
改（已餓 + cadence 到 → 重跑 survival 重選,非死等恢復）：
```gdscript
if team.current_task in SURVIVAL_TASKS:
    var proactive_camp: bool = team.current_task == TeamData.TASK_CAMP \
        and team.task_priority == TaskArbiter.PRIO_DISPATCH
    if days_left >= SURVIVAL_RECOVER_DAYS and not proactive_camp:
        TaskArbiter.release(team)
        return
    # survival-latch 重選：仍餓 + 重評 cadence 到 → 重跑 survival 選擇(forage 失效換買糧/掠奪/併入),非死鎖首選。
    # proactive_camp 豁免(主動紮營在途,不打斷)。crisis 亦觸發(複用 _decision_crisis)。
    if not proactive_camp and days_left < WARNING_DAYS \
            and (state.world.current_tick >= team.decision_eval_next_tick or _decision_crisis(state, team)):
        team.decision_eval_next_tick = state.world.current_tick \
            + (DECISION_CADENCE / 4 if _decision_crisis(state, team) else DECISION_CADENCE)
        var severity: String = "urgent" if days_left < URGENCY_DAYS else "warning"
        _trigger_survival(state, team, severity)   # rank_survival 重選(同 prio,可換 survival option)
    return
```
- **注意**：`_trigger_survival:3127` try_set PRIO_SURVIVAL——重選同 prio(PRIO_SURVIVAL)換 survival task。查 try_set 同-prio survival self-replace 是否成立（PRIO_SURVIVAL 非 ENGINE_SOURCES 白名單→同 prio 換不動?）。**若同 prio 換不動→需先 release 再 _trigger_survival**（release→IDLE→_trigger_survival try_set PRIO_SURVIVAL 成立）。implementer build 時驗此接點,不成立則 release-then-retrigger。
- 復用既有 `decision_eval_next_tick`(cadence 欄)+ `_decision_crisis`（cadence slice 已加）。
- TDD `_test_survival_relatch_repick`：餓隊 current_task=FORAGE + forage 失效(food 持續低) + cadence 到 → _trigger_survival 重跑(mock 驗 rank_survival 被呼/task 可換)。

## ② FLEE 威脅 gate（`terms.gd threat_pressure`，撤 T1 0.6 floor）
現：`return clampf(0.6 + ctx.team_panic * 0.4, 0.0, 1.0)`
改（隨威脅存在,無威脅→~0；panic 僅威脅時放大）：
```gdscript
"threat_pressure":
    # FLEE=威脅反射:有威脅才驅動(撤 T1 0.6 flat floor=食足隊 spurious FLEE 餓死根)。
    # threat 存在→base=威脅強度+panic 放大;無威脅→~0(逃跑無意義)。panic 僅威脅時計(斷 panic 螺旋)。
    if ctx.threat <= 0.0:
        return 0.0
    return clampf(ctx.threat + ctx.team_panic * 0.4, 0.0, 1.0)
```
- `ctx.threat`= reputation-filtered belief-based 威脅(0..1,無敵/中立→0)。無威脅隊 threat=0→FLEE eval=0→不 spurious FLEE。
- panic gate 進 threat 存在(斷「安全+高 panic→FLEE」螺旋)。
- **注意**：FLEE 仍 applicable 恆候選(options.gd:86)，但 eval=0 時 util=0→rank 墊底不選（applicable≠選中,coeff/rank 自然汰）。threat 路(`_evaluate_threat` PRIO_THREAT 插隊)另有真威脅 FLEE 路徑,不受此 term 影響(那是反射插隊非主 rank)。
- TDD `_test_flee_threat_gate`：threat=0 隊→threat_pressure eval=0（不管 panic）；threat=0.8 隊→eval≈0.8+panic。

## 三修互擾檢查（R② 重點）
- ① 重選 vs ② FLEE gate：① 讓餓隊重選 survival option(覓食/買糧/掠奪…)；FLEE 不在 SURVIVAL_TASKS(=[RETURN_HOME,BEG,JOIN,FORAGE,CAMP])→① 不涉 FLEE。② 只改 FLEE eval。兩者作用不同 task 集,不互擾。
- ② 撤 FLEE floor 會否讓真威脅隊不 FLEE?——真威脅 threat>0→eval=threat+panic 正常;且真致命威脅走 `_evaluate_threat` PRIO_THREAT 插隊(反射,不靠此 term)。不回歸。

## 驗收（measurer 終驗）
- **★餓隊換策略**（Team7 式）：餓隊 forage 失效 → 重跑 survival → 換買糧/掠奪/併入/移動（非鎖死到死）。單隊 trace 看 survival option 有變化。
- **★食足隊不 spurious FLEE**：食足無威脅隊 FLEE 選中率→~0（撤 floor）；不再 survival 主導餓死（pop 不因 spurious FLEE 崩）。
- **真威脅不回歸**：真威脅隊仍 FLEE/threat 反應（PRIO_THREAT 插隊 + threat>0 eval）。
- **① cadence 頻率**（順帶）：② 斷螺旋後,前報 2023次/90天是否降（不再瘋狂 FLEE-timeout 循環）。
- determinism byte-identical、融合閘、TC2/consolidation/combat/established 不回歸。

## 風險（R②）
- ① try_set 同-prio survival 換不動 → 需 release-then-retrigger（接點,implementer 驗）。
- ② threat=0 判斷：`ctx.threat` 是否可靠反映「無威脅」（reputation-filtered,可能漏某些威脅→但那些走 threat_react/PRIO_THREAT 反射路）。
- 全 TEST VALUE，measurer 校。

---
## 附：stress decay 另記 arc（本 slice 不做）
記 `docs/known_issues.md` + memory：person-system 成員 stress「累積不釋放」(驅 team_panic)=death spiral 根層,跨 reaction/morale。本 slice #2 在決策層斷 FLEE 螺旋(安全→panic 不驅 FLEE),stress 累積本身待 person 情緒系統 arc 評估。
