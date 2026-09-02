---
from: systems
to: implementer
status: open
slice: 自救建田導回設施仲裁（#35 修法）
topic: ★R② 過,而 reviewer 把範圍【縮小了】並且有 code 支撐:續蓋本來就是獨立分支(:5286-5293 直接 return),★★所以只換 :5294 起的選擇迴圈,:5271-5293 原樣保留;★★★而這不是新實驗:`_pick_facility:5147` 註解自述「S4 已移除飢餓 override,因 survival-crush 在秤上」⇒ `_food_rescue_eval` 是漏網的第二條走廊;★驗收有一條反過來:餓死出現【不是失敗是證據】
---

# ★①範圍（★reviewer 縮小的，照做）
```
★只換：`_food_rescue_eval` :5294 起的【選擇迴圈】⇒ 改呼 `_pick_facility`（同秤、同 argmax）
★★原樣保留：:5271-5293（entry checks ＋【續蓋分支】＋在建 guard）
   —— ★★★reviewer 查實：續蓋是【獨立分支、直接 return、不進選擇迴圈】，
      而那條分界線精確對上 `_evaluate_infrastructure:4985` 自己的既有 guard
   ⇒ ★續蓋【本來就不是選設施】⇒ 不進本刀
```
★**關鍵一條（別做成換名字的走廊）**：★★**不要「先算好 facility 再送去驗證」** ——
**由 `_pick_facility` 回傳的 winner 才是要蓋的，即使它不是 farming。**

# ★★②而這不是新實驗，是恢復既定範式（★做的時候心裡有底）
```
`faction_ai_system.gd:5147` 註解原文：「S4：移除飢餓 override —— S2 survival-crush 已讓餓隊 farming score 主導」
`:5241 const SURVIVAL_CRUSH: float = 5.0`（`_facility_score`：餓→農田 score 壓過發展，urgency² 軟連續）
⇒ ★★同一個病 S4 治過一次；`_food_rescue_eval` 是【漏網的第二條走廊】
```

# ★★★③驗收（★第①條是反過來的，看清楚）
```
①★★★餓隊床：導回後【餓死不該出現】——★而若出現，那【不是失敗，是證據】：
   代表 `SURVIVAL_CRUSH = 5.0`（TEST VALUE）不夠 ⇒ ★★開【修秤】票，★★★禁回頭開走廊（藍圖明令）
②mint 排得進去嗎：g1a 那條 baseline 應轉綠；★若仍紅，要說出【是哪一格擋住】
③`fp` 會變 ⇒ 差在哪要說得出來；★特別印「自救路的 facility 選擇改變了幾次、改成什麼」
④★★續蓋回歸斷言：續蓋次數【不變】（它不在本刀，若變了就是誤殺）
```

# ④不動的（★reviewer 順手撈到，我已立條目）
`_begin_facility_construction` **缺再入守衛**（`start_build:540`／`start_demolish:651` 都有）。
★**我複驗判【潛在非活】**：兩個呼叫端（`outpost_system.gd:592`／`:819`）**都在呼叫前檢查**。
⇒ ★★**本刀不夾帶**；已立條目，回訪＝**下一次新增呼叫端時**（★★★屆時補在被呼叫端，不要靠新呼叫端記得）。
