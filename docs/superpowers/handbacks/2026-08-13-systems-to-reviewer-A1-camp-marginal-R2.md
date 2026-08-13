---
from: systems
to: reviewer
status: consumed
topic: "[R② 審 A1 camp_marginal HOW-detail(dispatch 前、禁crank命門在正規化)·A1=紮營價值換 MarginalEconomy 真帳、但紮營是 DecisionEngine option(camp_drive term)非 R1/R2 領主側 gate→需把 camp_marginal 正規化成 util term band=crank-vector在此·★設計:①新 MarginalEconomy.camp_marginal(est,forage_floor)=maxf(0,_inflow_est(est)−forage_floor)純算術零新常數鏡射 migrant_marginal②DecisionContext.gather 建 camp_target_est(VillageEstimate 從 has_farmable_tile 靶 tile 可觀測 terrain/level=1/farming=0/pop)+camp_forage_floor 新 ctx 欄③camp_drive(terms:190)=clampf(camp_marginal/daily_need,0,CAMP_CAP)×urgency(food_days)·★審點禁crank命門:(1)正規化 marg/daily_need(daily_need=pop×FPPD 真錨=淨餘糧天數比)+CAMP_CAP clamp——genuine ratio 非 win-crank? CAMP_CAP 是 bound(封頂)非 inflate? 山地 marg≤0→0 經正規化仍保0(anti-crank 四象限④)?(2)感知鐵律:camp_target_est 從可觀測 terrain(隊在/見的 farmable tile=belief)非 god-view? gather 建 est 來源自審(3)urgency 讀自家 food_days(自知)shape genuine?(4)★紮營留 DecisionEngine term(正規化)vs 改領主側 gate(同R1/R2)——term 正規化是對的整合否? 還是紮營該重構成 marg>0 gate?·CLEAN→dispatch implementer+measurer bounded 四象限 gate(mountain→0 machine-demonstrate=anti-crank真閘)·halt項(crank/感知鐵律違)明列·地基KEEP"
---

# R② 審 A1 camp_marginal HOW-detail（dispatch 前、禁 crank 命門在正規化）

A1 = 紮營價值換 MarginalEconomy 真帳。但**紮營是 DecisionEngine option**（camp_drive term）**非 R1/R2 領主側 gate**（R1 `_try_migrant_side`:1831 用 `migrant_marginal>0` 當 action gate、非 util term）→ A1 需把 camp_marginal **正規化成 util term band** = **crank-vector 在此正規化**。HOW spec 已 R² CLEAN 概念、本封審此正規化細節。

## 設計
1. **新** `MarginalEconomy.camp_marginal(est, forage_floor)` = `maxf(0, _inflow_est(est) − forage_floor)`——純算術、**零新常數**、鏡射 `migrant_marginal`（god-view 防線一致=只吃 est）。
2. **DecisionContext.gather** 建：`camp_target_est`（VillageEstimate 從 `has_farmable_tile` 靶 tile 的**可觀測** terrain/outpost_level=1/farming=0/pop）+ `camp_forage_floor`（`_forage_subsist_buffer` 日產同源）。新 ctx 欄。
3. **camp_drive**（terms:190）= `clampf(camp_marginal / daily_need, 0, CAMP_CAP) × urgency(food_days)`。

## ★審點（禁 crank 命門）
1. **正規化**：`marg / daily_need`（daily_need=pop×FOOD_PER_PERSON_PER_DAY 真錨=**淨餘糧天數比**、dimensionless genuine）+ `CAMP_CAP` clamp。
   - genuine ratio 非 win-crank？`CAMP_CAP` 是 **bound（封頂）非 inflate**（同 clampf ceiling 慣例、bounded-verify 交 measurer）？
   - ★**山地 marg≤0 → 0 經正規化仍保 0**（anti-crank 四象限④「瀕餓+山地→不紮」結構保）？
2. **感知鐵律**：`camp_target_est` 從**可觀測 terrain**（隊在/見的 farmable tile=belief）非 god-view？gather 建 est 的 terrain 來源需自審（防線護 MarginalEconomy 內部、建 est 端要 belief）。
3. **urgency**：讀自家 `food_days`（自知）、shape genuine（低 food_days→高）？
4. ★**紮營留 DecisionEngine term（正規化）vs 改領主側 gate（同 R1/R2）**——term 正規化是對的整合、還是紮營該重構成 `marg>0` gate？（設計 §2 說「分數修法」=留 term；但正規化 divergence from R1/R2 pattern、請判是否引隱患）。

CLEAN → dispatch implementer + measurer **bounded 四象限 gate**（mountain→0 machine-demonstrate = anti-crank 真閘）。halt 項（crank/感知鐵律違）明列。地基 KEEP。
