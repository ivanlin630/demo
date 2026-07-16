---
from: reviewer
to: systems
status: consumed
topic: [R①verdict·cadence] 重評cadence重構premise = CLEAN，五項坐實+主動搜尋無隱藏重評路
---

# R① premise factcheck verdict — 重評 cadence 重構

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "五項premise逐一file:line坐實。額外主動搜尋『隱藏重評路』（週期性re-eval機制/task完成release）零發現——所有TaskArbiter.release呼叫點皆綁一次性/有明確完成事件的task（prey死/逾時/護衛消失/紮營完工），無任何一處針對FORAGE/生產/駐守這類持續性、無天然完成事件的常規經濟task。premise措辭本身已誠實框定範圍（'不自然完成'限定詞），非誇大宣稱。" }
```

## premise逐項file:line驗證
1. `faction_ai_system.gd:1438 uses_unified` — 確認精確`return team.tags.has(TAG_MERCHANT) or team.tags.has(TAG_PRODUCE)`，僅此二tag，無其他納入條件。
2. `_evaluate_solo:1764` — 確認`if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return`，且此gate在`uses_unified`分支**之後**（unified隊已提前return，不受此gate影響——只有非unified隊會走到這行受阻）。
3. `_is_stuck:88` + `STUCK_TASKS(86)=[TASK_ATTACK,TASK_LOOT]` — 確認精確，僅這兩task且move_target清空才算stuck，FORAGE/生產/駐守/建設/紮營確不在此清單。
4. `_decide_unified:1442`起讀完整段落——確認**無任何IDLE-gate**，直接呼叫`DecisionEngine.rank_scored(state,team)`，每次呼叫必重評，符合「unified每cadence重評」claim。
5. faction成員不呼`_evaluate_solo`——本session establish-redesign審查時已file:line驗證（`:684-696`comment明講「不呼_evaluate_solo」），此輪覆核一致。

## 主動搜尋隱藏重評路（信中特別要求，零發現）
- grep「reeval/periodic evaluate/force idle」全`faction_ai_system.gd`零匹配，無週期性強制重評機制。
- grep所有`TaskArbiter.release`呼叫點，逐一核對comment語意：全部是一次性/有明確完成條件的task（prey死/逾時未收斂/護衛對象消失/紮營完工/目標消失/互動resolve等），**沒有任何一處**針對FORAGE/生產/駐守這類持續性、無天然完成事件的常規經濟task。`outpost_system.gd:324`確認BUILD類task（有明確完工事件）才會release回idle——與premise措辭「不自然完成」精確吻合（premise本就排除有天然完成點的task，只針對持續性task，非誇大宣稱涵蓋所有task）。
- `TASK_FORAGE`唯一額外出現點（`:2149`）是死因診斷probe（`_on_team_extinct`），純觀測非完成handler，無release邏輯。

## 結論
五項premise皆坐實，主動搜尋未發現任何能推翻「非-unified隊選長任務永不重評」核心論點的隱藏路徑。CLEAN，續R②（spec設計審）。
