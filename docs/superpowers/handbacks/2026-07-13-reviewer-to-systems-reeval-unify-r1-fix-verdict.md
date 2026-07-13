---
from: reviewer
to: systems
status: consumed
topic: [R①終審verdict] premise#1(directive_fresh)修正確認解決 = CLEAN，stamp點為單一choke point
---

# R①終審 verdict — ⑦釋放統一 premise#1修正確認

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "directive_fresh機制正確解決faction命令延遲風險，維持單一predicate架構紀律。stamp完整性確認：f.goals/f.goal_drivers只有唯一寫入函式_emit_goal(faction_ai_system.gd:1087-1093)，約11處呼叫點全部funnel進這一個函式，implementer只需在此函式內加一行stamp即可自動涵蓋所有命令發出點，非散落多處。" }
```

## 逐項驗證

1. **premise#1解決確認**：`_directive_fresh(state,team) = f.directive_change_tick > team.last_decision_tick`——邏輯正確：命令發出後stamp的tick晚於該成員上次決策tick→視為fresh→下一tick即重評；無新命令的忙碌成員仍走cadence throttle。維持「單一predicate」架構紀律（directive_fresh只是餵進`_should_reeval`的一個輸入條件，非另開判斷路），真正解決命令延遲風險同時保留過頻修正（兩全）。

2. **stamp完整性（你的問題2，確定性回答）**：grep `f\.goals\[`+`_emit_goal(`全codebase確認——`f.goals`/`f.goal_drivers`只有唯一一個寫入函式`_emit_goal`（`faction_ai_system.gd:1087-1093`），`:1088 f.goals.append`+`:1090 f.goal_drivers[goal]=...`。約11處呼叫點（`:971,981,1001,1007,1013,1016,1021,1025,1032,1082,1084`）全部funnel進這一個函式，無任何其他地方直接改`f.goals`（唯一另一筆`.goals[`匹配是`reaction_system.gd:79 person.goals[i]`，完全無關的person-level欄位）。**implementer只需在`_emit_goal`函式本體內加一行`f.directive_change_tick=state.world.current_tick`，即可自動涵蓋所有現有+未來的faction命令發出點，非散多處需逐一定位**——確定的單一choke point。

## 結論
premise#1/#2/#3皆CLEAN。續R②（dispatch前設計審）。附註給implementer：stamp點=`faction_ai_system.gd:1087-1093 _emit_goal`函式內加一行即可，勿誤以為需逐一處理11個呼叫點。
