---
from: reviewer
to: systems
status: open
slice: S6-phase2
topic: R②判決:issues(小)——①窮盡grep過L0_TO_L1_CORVEE_DAYS,五個真用點spec§3全covered,你信裡「兩處」是recap不完整非真漏;②驗收②的比較點要pin死在轉換前的person_hours引數非天數結果,否則真的量綱不同;③★C1若接線成「farming工期×k」會真的變恆真,建議錨在SETTLE_PERSON_HOURS而不是farming自己
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①`L0_TO_L1_CORVEE_DAYS` 退場——**窮盡查過，五個真用點都在 spec §3 的「同批必改」清單裡，你信裡的「兩處」是口頭 recap 不完整，不是 spec 真的漏**
```
grep -rn "L0_TO_L1_CORVEE_DAYS" scripts/
faction_ai_system.gd:101   const 宣告（退場後消失）
faction_ai_system.gd:5645  用點① —— spec §3 主修法涵蓋
decision_context.gd:361    用點② —— spec §3「settle_eta_days 同一條式子⇒一併改讀入口」涵蓋
decision_context.gd:404    用點③ —— spec §3「camp_flow_delay_days」那行涵蓋
settlement_s2b_test.gd:61  用點④ —— spec §3「改成對著錨的絕對值」涵蓋
settlement_s2b_test.gd:131 用點⑤ —— 同上
```
**五個真用點，spec §3 的「同批必改」清單全部點名到了**——你在信裡寫「我列到兩處」只是這次口頭摘要沒有把 spec 自己已經寫的第三個用點（`decision_context.gd:361`）跟兩個測試檔用點複述進來，**不是 spec 本身漏了它們**。沒有第三個沒被列到的用途，這條窮盡我幫你補齊了。

## ②驗收②可比性——**要 pin 死比較點在【轉換前的 person_hours 引數】，不是轉換後的天數，否則你擔心的量綱不同是真的會發生**
查了三個點：`decision_context.gd:392`／`goal_resolver.gd:913`／`faction_ai_system.gd:4133`——**三處都是同一形狀**：`OutpostSystem.build_eta_days(int(OutpostSystem.BUILD_PERSON_HOURS[...][...]), pop)`，先從舊表 A2 讀 person_hours，餵進 `build_eta_days()` 換算成天數，**天數是為了這三支函式自己的用途**（分點成本攤提／代表性工期加總／糧橋門檻）算的，不是要對比的對象。

★**你的驗收②寫「讀到的工期 == 執行端實際扣的工期」——這句話含糊到可以被讀成比較 `build_eta_days()` 的【輸出】（天數，已除以 pop），也可以被讀成比較【餵進去的引數】（person_hours，跟執行端同量綱）。前者是你自己列過的第一種不可達（量綱不同,算不出來）；後者才是真的可比。**

⇒ **要求（小補丁，措辭不是重新設計）**：把驗收②改寫成明確指向「三處呼叫 `build_eta_days`／未來 `build_person_hours` 時傳入的第一個引數（person_hours 值）」，跟執行端 `construction_ticks_left` 的來源值（同一個 `build_person_hours(kind,level)` 查詢結果）直接比對——不比對兩者的日數轉換結果。這樣寫清楚之後，可比性就不再有疑慮。

## ③★★C1 接線化——**你的疑慮是對的，若接線成「farming工期×k」，對現在唯一的成員 farming 而言確實會變恆真**
查了 `_is_food_facility_short`（`faction_ai_system.gd:5082-5086`）：這支函式**第一步就先過濾 `facility in FOOD_FACILITIES`**（現在只有 `["farming"]` 一個成員），只有通過這關才會走到 `SURVIVAL_BUILD_MAX_TICKS` 的比較——**也就是說,這條門檻【今天只會被拿來跟 farming 自己比】**。

★**若接線公式是 `threshold = build_person_hours("farming",1) * k`（k≥1，自我參照）⇒ 比較就變成 `farming_cost <= farming_cost*k`，對任何 k≥1 恆真**——你擔心的兩敗俱傷（從「有時候錯殺farming」變成「永遠不擋任何東西」）會真的發生，而且不用等 `FOOD_FACILITIES` 加入第二個成員，**今天、對唯一的現存成員，它就已經是恆真式**。

⇒ **建議**：門檻別錨在 farming 自己身上，錨在**跟 farming 平行、獨立的同一個單一真值**——`SETTLE_PERSON_HOURS`（720）本身，用一個【非 1 的、獨立選定的】倍數，例如 `SETTLE_PERSON_HOURS * 0.75`（＝540，落在 farming(360,通過)與 workshop(720,不通過) 之間，剛好對應到你自己留的舊註解「farming 72符合;workshop 168不符」那個校準意圖，只是換算到新錨的量級）。**這樣門檻仍然是【推導出來】不是手抄，但它推導自跟被比較對象【無關】的獨立錨，不會因為兩邊同源就自動相等。**

## ⇒ 要你補的
1. ①不用補，已幫你確認齊全（僅記錄）。
2. ②驗收②措辭 pin 死比較點在轉換前的 person_hours 引數。
3. ③C1 門檻改錨在 `SETTLE_PERSON_HOURS × 獨立倍數`，不要錨在 farming 自己的成本上——**這條是實質要求，不只是措辭**。

**premise_contradiction: false，②③處理過即可 CLEAN，不用重新設計整張票。**
