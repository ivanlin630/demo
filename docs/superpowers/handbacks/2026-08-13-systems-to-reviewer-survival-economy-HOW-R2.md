---
from: systems
to: reviewer
status: consumed
topic: "[R② 審生存經濟基座 arc HOW spec(dispatch 前設計閘)·spec=2026-08-13-survival-economy-access-arc-HOW.md·design(WHAT)已 R² CLEAN、本封審 HOW 技術決策·★審點:①感知鐵律 A1/A2 est 從可觀測 terrain(belief)經 VillageEstimate god-view 防線建、camp_marginal 會不會漏讀 live 池 current?(marginal_economy:5 防線結構上拿不到 state.teams[target]、但 A1 呼叫端建 est 時是否從 belief terrain 非 god-view?)②禁 crank:A1 camp_marginal=maxf(0,_inflow_est−forage_floor)×urgency 全接既有 MarginalEconomy、零新分數常數——會不會偷渡 crank?(urgency 是讀真 food_days 非常數)③B5:_self_use food×famine-escalation(1+maxf(0,(SAFE−food_days)/SAFE)×GAIN)、thread state 進 _self_use(現無 state)、bounded 吃飽=1 瀕餓高——genuine 非 crank? SAFE_DAYS/FAMINE_GAIN 常數會不會變 knob?④slice 序 B4/B5 先(先讓安家能餵飽再 A 拉更多團)合理?⑤A2/A3 diagnostic-first(先 pin try_set_noop/settle dispatch 斷點再修、禁猜)妥?⑥bounded 四象限 machine-demonstrate 硬 gate·★build-unblock:主樹編譯 OK(faction_ai temp-diag 已 revert、perf bed 跑過)·CLEAN→我 plan slice→dispatch implementer(B4/B5 先)·地基 KEEP"
---

# R② 審 — 生存經濟基座 arc HOW spec（dispatch 前設計閘）

spec = `docs/superpowers/specs/2026-08-13-survival-economy-access-arc-HOW.md`。design（WHAT）已 R² CLEAN；本封審 **HOW 技術決策**。

## ★審點（skeptical、只信 file:line）
1. **感知鐵律**（A1/A2）：est 從**可觀測 terrain**（belief）經 `VillageEstimate` god-view 防線（marginal_economy:5 結構上拿不到 `state.teams[target]`）。★審：`camp_marginal` **呼叫端建 est 時**是否從 belief terrain 非 god-view live 池 current？（防線護的是 MarginalEconomy 內部、呼叫端建 est 的來源需自審）。
2. **禁 crank**（A1）：`camp_marginal = maxf(0, _inflow_est(est) − forage_floor) × urgency` 全接既有 MarginalEconomy、零新分數常數。★審：會不會偷渡 crank？（urgency=讀真 food_days 非常數；forage_floor=既有 subsist 同源）。
3. **B5**：`_self_use` food × `famine-escalation = 1 + maxf(0,(SAFE_DAYS−food_days)/SAFE_DAYS) × FAMINE_GAIN`、thread `state` 進 `_self_use`（現 food 分支無 state）。★審：genuine 非 crank？bounded（吃飽=1 照舊/瀕餓高）？`SAFE_DAYS`/`FAMINE_GAIN` 兩常數會不會變成新 knob（vs 用既有食物常數導出）？
4. **slice 序** B4/B5 先（先讓安家真能餵飽、A 層再拉更多團才不重蹈）——合理？
5. **A2/A3 diagnostic-first**（先 pin `try_set` noop / settle dispatch 斷點再修、禁猜）——妥？（呼應 measure-first 血證）。
6. **bounded 四象限 machine-demonstrate = 硬 gate**（§4）——判準夠硬？

## build-unblock
主樹編譯 **OK**（faction_ai temp-diag 已 revert、無 distance_to、perf bed 本 session 跑過）=blueprint 顧慮的 compile blocker 已清。

CLEAN → 我 plan slice 拆解 → dispatch implementer（B4/B5 先）。halt 項（premise_contradiction/感知鐵律違）請明列。地基 KEEP。
