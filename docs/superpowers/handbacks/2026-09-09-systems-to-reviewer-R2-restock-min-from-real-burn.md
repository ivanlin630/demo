---
from: systems
to: reviewer
status: open
slice: 普查批一③ RESTOCK_MIN
topic: R² 請審｜★核心主張:N 不用發明——返家的成功條件已經定義它了(RETURN_HYSTERESIS_DAYS,options.gd:151)⇒ home_restock_min = 5天 × 真 burn,零新數字｜★★而它【綁定了兩個決定】,我寫進誠實限,請你判這個綁定是聰明還是偷懶｜★★★headless_test 有四處硬編舊公式期望,我要求「改表述不要改數字」,請看這條會不會被繞過
---

# R²：`docs/superpowers/specs/2026-09-09-restock-min-from-real-burn-HOW.md`

批一③。①移速、三死鍵、②材料標度化都已 DONE 並在 main。

## 已坐實的前提

```
terms.gd:29      const RESTOCK_MIN: float = 10.0
terms.gd:135     maxf(clampf(ctx.home_food / RESTOCK_MIN, 0,1), 1.0 if home_food_productive else 0.0)
options.gd:149   ctx.home_food >= DecisionTerms.RESTOCK_MIN or ctx.home_food_productive
decision_context.gd:642  var _burn := float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
                          ← ★真值已經在同一個 block 裡算好了（為了 home_food_productive）
terms.gd:4       const RETURN_HYSTERESIS_DAYS: float = 5.0
options.gd:151   or (current_task == TASK_RETURN_HOME and food_days < RETURN_HYSTERESIS_DAYS)
```

## 請你審三件

1. **★核心主張：N 不用發明。**
   我主張 `home_restock_min = RETURN_HYSTERESIS_DAYS × team_burn`，理由是
   **返家這件事自己的成功條件就是 `food_days ≥ RETURN_HYSTERESIS_DAYS`**
   ⇒ 家裡的糧若連這個都做不到，那趟返家依定義達不成目標。
   ⇒ 零新數字。**若你認為這是把兩件不同的事硬綁在一起，直接說。**
2. **★★而我自己標了它綁定兩個決定**（返家完成線／家糧門檻），寫進誠實限。
   請你判：**這個綁定是「同源，一起動才對」，還是「我為了不發明數字而偷懶」？**
   ★我的立場：分成兩個常數時它們會 drift，而 drift 的形狀正是「返家的目標」與
   「值不值得返家」各說各話。**但我承認這是我選的框，不是資料選的。**
3. **★★★`headless_test.gd` 四處硬編舊公式期望**（:2034 註解／:5011／:15634／
   :15659 `restock=home_food/RESTOCK_MIN(5/10)`）。
   我在 spec 寫「它們會紅而那是對的，要改成用 `ctx.home_restock_min` 表述，
   **不要把期望值硬改成新數字**」。
   ★請你看這條**會不會被繞過** —— 最省事的做法就是把 `10` 改成新的數，
   而那會把「公式改了」寫成「數字換了」，下一個人就看不出這裡發生過什麼。

## 我知道的盲區

`_home_granary_food`（`decision_context.gd:912`）掃全 tiles 找自家糧倉，標了 `gate-ok: legit-self`。
本票不動它，**但如果你認為「家」的定義本身有問題**（多個 outpost？），那會擴大 scope ⇒ 請直接說。

CLEAN 才 dispatch。
