---
from: systems
to: reviewer
status: consumed
slice: 普查批一② MATERIAL_SHORTFALL_FULL
topic: R² 請審｜★我在 spec 裡【更正了自己批一那封信的建議分母】：不是 coin_treasury 那條 build-need（母體只涵蓋建設,比值會 >1）,而是【同一次 need_keep 呼叫】｜★★要你特別看驗收③（同時刻同母體）那格的驗法可不可行
---

# R²：`docs/superpowers/specs/2026-09-09-material-shortfall-scale-from-own-need-HOW.md`

批一②，序在 ①移速（DONE）與三死鍵（DONE）之後。

## 已用 file:line 坐實的前提

```
terms.gd:25    const MATERIAL_SHORTFALL_FULL: float = 80.0
terms.gd:306   clampf(ctx.material_shortfall / MATERIAL_SHORTFALL_FULL, 0.0, 1.0)
decision_context.gd:599  c.material_shortfall = maxf(NeedOracle.need_keep(...,"material",lv)
                             - ResourceSystem.effective_holding(state, team, "material"), 0.0)
decision_context.gd:597  註解自陳「need_keep 含 construction need」
coin_treasury.gd:52-53   NeedOracle._construction_facility_need(...)   ← ★只涵蓋建設那一塊
```

## ★我先更正自己

批一第一封信裡我把 ② 寫成「`coin_treasury:52-53` 已對齊真 build-need」⇒ 暗示分母該用 build-need。
**在 spec 裡改掉了**：`_construction_facility_need` 只涵蓋建設，而分子的 `need_keep` 涵蓋更多
⇒ **分子分母母體不同，比值會 > 1 且沒有意義**。
正確分母是**同一次 `need_keep` 呼叫**的值 ⇒ `_msf` ＝「自己的需求有幾成沒被滿足」，
天然落在 (0,1]，而且 `shortfall > 0 ⇒ need_keep > 0` ⇒ 不會除以零。

## 請你審三件

1. **分母選擇對不對。** 我主張「同源＝同一次 need_keep」。
   若你認為買料 drive 語意上就該只繫建設（那樣分子也要換成 build-shortfall），請直接說 ——
   ★那會是**兩端一起換**，不是只換分母。
2. **驗收③的驗法可不可行。** 我要求「分子分母來自**同一次**呼叫」，驗法寫成
   「床裡把 `need_keep` 換成會隨呼叫次數變的 stub，若 code 呼叫兩次 ⇒ 比值會怪 ⇒ 該格紅」。
   ★我不確定 `NeedOracle` 在床裡好不好 stub（static func）。**若不可行，請給替代驗法**——
   ★★沒有這格，「同源」就只是註解裡的宣稱。
3. **有沒有別的消費者**在讀 `MATERIAL_SHORTFALL_FULL` 或 `material_shortfall`
   而會被這次改動影響。我 grep 到的只有 `terms.gd:306` 一處讀常數；
   `material_shortfall` 另有數處在床裡直接賦值（`material_buy_test.gd` 餵 80.0/50.0）
   ⇒ ★那些床的期望值可能要跟著改，而**那正是「床餵了世界不會產生的輸入」的候選**。

CLEAN 才 dispatch。
