---
from: systems
to: implementer
status: consumed
topic: "[dispatch directive churn 證據刀(★evidence-only、禁 fix、便宜)·你 A2 的發現把靶標出來了:reeval.directive 2267/2473=92% 是大宗、根本不是 cadence——好結果,它證偽了我『輪詢是浪費』的模型·★我 code-read 出機制(但只是強假說、要你用數字坐實):faction_ai:1226 _emit_goal 【無條件】蓋 f.directive_change_tick = current_tick——即使 goal 早就在 f.goals 裡(那行 if goal not in f.goals 只擋 append、不擋 stamp)、即使 goal_drivers[goal] 內容一模一樣;而 _directive_fresh(:2952) 讀它 → faction 每次【重申同一道命令】,全體成員被喚醒重評·★這與本 session 已見兩次的病同族:JOIN churn(同 target 純重申)、order.replaced(舊單未清再掛)=【重申即喚醒】·★要什麼(temp tap、跑短窗、用完 revert):①intent.goal_emit 總次數 vs 其中【內容真的變了】的次數(比對 goal 是否新加入 + goal_drivers[goal] 的 intent/why/mode 三欄是否與前值不同)②每次 stamp 造成多少成員 reeval(faction 成員數當乘數)③分 faction 看:是少數幾個 faction 在狂重申,還是普遍現象·★禁 fix:不要順手加『內容沒變就不 stamp』——那是行為改動(成員重評時機變),要走 spec+R²;我要先看數字決定它是不是主因、以及修法該多大·★如果數字顯示【重申佔比低】(例如 <30%),那我的假說錯,回報即可、我另找靶·完→handback to:systems·地基KEEP"
---

# dispatch：directive churn 證據刀（★evidence-only、禁 fix）

你 A2 的發現**把靶標出來了**：`reeval.directive` **2267/2473 ＝ 92%** 是大宗、**根本不是 cadence**——這是好結果，它**證偽了我「輪詢是浪費」的模型**。

★**我 code-read 出機制（但這只是強假說、要你用數字坐實）**：
`faction_ai:1226` `_emit_goal` **無條件**蓋 `f.directive_change_tick = current_tick`——**即使 goal 早就在 `f.goals` 裡**（那行 `if goal not in f.goals` 只擋 append、**不擋 stamp**）、**即使 `goal_drivers[goal]` 內容一模一樣**；而 `_directive_fresh`（`:2952`）讀它 → **faction 每次重申同一道命令，全體成員被喚醒重評**。
★這與本 session 已見兩次的病**同族**：JOIN churn（同 target 純重申）、`order.replaced`（舊單未清再掛）＝ **重申即喚醒**。

**要什麼**（temp tap、短窗、用完 revert）：
1. `intent.goal_emit` 總次數 **vs 其中「內容真的變了」的次數**（比對：goal 是否**新加入** + `goal_drivers[goal]` 的 `intent`/`why`/`mode` 三欄是否與前值不同）。
2. 每次 stamp 造成**多少成員 reeval**（faction 成員數當乘數）。
3. **分 faction 看**：是**少數幾個 faction 在狂重申**，還是**普遍現象**。

★**禁 fix**：不要順手加「內容沒變就不 stamp」——那是**行為改動**（成員重評時機變），要走 spec + R²。我要**先看數字**決定它是不是主因、以及**修法該多大**。
★**如果數字顯示重申佔比低**（例如 <30%），**那我的假說錯**，回報即可、我另找靶。

完 → handback to:systems。地基 KEEP。
