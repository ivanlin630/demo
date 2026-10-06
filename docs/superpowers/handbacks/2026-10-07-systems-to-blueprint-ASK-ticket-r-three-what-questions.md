---
from: systems
to: blueprint
status: open
slice: 票 R 戰時徵用 —— R² 的五個先查答完後剩三個 WHAT 問題
topic: ①生存儲備「幾天」用哪一條既有線（全站沒有 3 天）②coin 要不要也有底線（「貧困鎖」全站零命中）③宣告只認「戰爭基金」＝窄範圍，可以嗎
---

# 背景

spec：`docs/superpowers/specs/2026-10-07-ticket-r-wartime-levy-HOW.md`（fa5bab2f3）。R² 第一輪 ISSUES 兩列已改，等他回。
下面三個是**數字／範圍的選擇**，我不發明，請裁。

# ① 生存儲備的天數

儲備改用 `team.food_runway`（自家數、每日快取）。量測報告裡的「糧撐 3 天」**在 code 裡找不到來源常數**。既有的線有這幾條：

```
LABOR_CRISIS_FOOD_DAYS   2.0   labor_system.gd:14       低於⇒危機搶勞力
SURVIVAL_SATED_DAYS      5.0   need_hierarchy.gd:16     生存需求「吃飽了」
SURVIVAL_RECOVER_DAYS    7.0   faction_ai_system.gd:115 脫離求生模式
SURPLUS_FOOD_DAYS        7.0   terms.gd:59              算有餘糧
```
我的建議：**SURVIVAL_SATED_DAYS（5）**——徵用不得把人推回「生存需求沒吃飽」，語意最貼；不另立常數。

# ② coin 要不要底線

今天的 code 是「coin 留一半」（手抄）。全站沒有「貧困」的既有定義。
(a) 只守糧（coin 可以被徵光；後果交給怨恨與脫離）
(b) coin 也要一條 ⇒ 那是一個新的設計數字，要你給
我的建議：**(a)**——糧是活命，coin 被徵光的後果已經有出口（記大怨→可能脫離）。

# ③ 宣告的範圍

全站沒有「勢力處於戰爭」的旗標。唯一能用的是 `strategy == "戰爭基金"`，而它**只在盟主隊 material < 200 時**才會是這個值
⇒ 材料充足的戰爭**不算宣告** ⇒ 那時不能徵用。
(a) 本票照窄範圍做，spec 已明寫「這不是廣義的戰爭宣告」
(b) 另開票立一個廣義的「宣戰／戰爭中」狀態，本票等它
我的建議：**(a)**——缺錢才徵用，語意本來就對得上；廣義宣戰要不要，等有第二個消費者再開。
