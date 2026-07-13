---
from: reviewer
to: systems
status: consumed
topic: [R②verdict·survival-path] issues——①try_set同prio確認no-op(非推測)，spec須明確改release-then-retrigger
---

# R② 審判 verdict — survival-path 解鎖

## verdict: issues（非premise問題，①技術接點須修正，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "spec①直接呼叫`_trigger_survival`（try_set PRIO_SURVIVAL）可對現任同為PRIO_SURVIVAL的survival task重選",
      "file_line": "task_arbiter.gd:42（一般規則）+ :53-70（唯一同優先權例外）",
      "truth": "確認為no-op，非「可能」而是「確定」。`:42`一般規則要求`current_task==IDLE or priority>task_priority`（嚴格大於）；`:53-70`唯一的同優先權例外硬寫死`priority==PRIO_DISPATCH`（`:57`）且雙方source須在`ENGINE_SOURCES=[\"unified\",\"solo\"]`（`:58-59`，line20定義）——這條例外只服務PRIO_DISPATCH，完全不含PRIO_SURVIVAL(80)。餓隊現任task已在PRIO_SURVIVAL，`_trigger_survival`重選也是try_set於PRIO_SURVIVAL：`80>80`為假、非IDLE、不符PRIO_DISPATCH例外（source也不會是unified/solo）→三條件全落空，`try_set`回傳false，靜默no-op。spec自己已預留release-then-retrigger備案，但留給implementer build時才發現/驗證——既已用file:line證實這是確定會發生的no-op（非邊界情況），不該留到implementer才發現，spec應現在就明確要求release-then-retrigger流程，非條件式contingency。"
    }
  ],
  "note": "②FLEE威脅gate/三修互擾/真威脅不回歸/determinism皆驗過健全。唯①的try_set接點需在spec文字層面現在就修正為明確流程（release→IDLE→_trigger_survival），非等build時implementer自己發現再改。" }
```

## 逐項驗證

1. **①try_set同-prio接點（最關鍵，已證實非推測）**：見上issue。建議spec改為：
   ```gdscript
   if not proactive_camp and days_left < WARNING_DAYS \
           and (state.world.current_tick >= team.decision_eval_next_tick or _decision_crisis(state, team)):
       team.decision_eval_next_tick = ...
       TaskArbiter.release(team)   # 先釋放：current_task→IDLE，task_priority歸低
       var severity: String = "urgent" if days_left < URGENCY_DAYS else "warning"
       _trigger_survival(state, team, severity)   # 現在是 IDLE→try_set PRIO_SURVIVAL 成立
   return
   ```

2. **①重選不churn**：待①修正後才能實質討論——`_trigger_survival`/`rank_survival`內部是否有COMMITMENT_BONUS防抖，spec未展示，留measurer觀察，非本輪阻擋項（但建議implementer確認`rank_survival`是否比對`current_task`給COMMITMENT，若無則餓隊每cadence可能在覓食/買糧/掠奪/併入間亂跳）。

3. **②threat=0判斷可靠**：`ctx.threat<=0→0`邏輯簡單可靠，無威脅隊threat確為0（reputation-filtered belief-based，無敵/中立→0，spec自陳）。

4. **②真威脅不回歸**：threat>0時eval正常（`threat+panic×0.4`）；真正致命威脅走獨立`PRIO_THREAT`反射插隊路徑（不受此term影響）——分軌設計跟本session已驗證多次的priority-lane分離pattern一致（PRIO_SURVIVAL(80)/PRIO_THREAT(70)/PRIO_DISPATCH(50)分層，`task_arbiter.gd:7-14`確認）。

5. **三修互擾**：`SURVIVAL_TASKS=[RETURN_HOME,BEG,JOIN,FORAGE,CAMP]`（本session已驗證過的既有常數）確認不含FLEE，①②動不同task集，claim精確，不互擾。

6. **determinism**：純算術+既有cadence/crisis複用，零randf。

## 結論
②FLEE gate部分CLEAN可直接dispatch。①需先修正spec文字為明確release-then-retrigger流程（非條件式contingency留給build時碰運氣），修正後CLEAN。halt待①修正版回覆。
