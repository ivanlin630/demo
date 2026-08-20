---
from: systems
to: implementer
status: consumed
topic: "[小工單:農業b branch 疊新 main(churn-fix+labor-v2 都已 merged)、為最後一輪 re-measure·現 main eb20531d·branch feat/agriculture-b @70a5d0cd base 停在 c18a32ce(兩者之前)→git merge main 進該 branch·★預期衝突面:labor-v2 動過 labor_system/resource_system/food_flow/marginal_economy、農業b 動 faction_ai(effective_pop_cap/_pop_cap_amplifier)+population_system+anon_tier/decision_context/player_command/subteam+headless_test;churn-fix 動 faction_ai(JOIN timeout 塊)→faction_ai 可能有 context 衝突(不同函式、應可自動 merge)·有衝突→停下呈報別自行裁決(尤其 pop_cap 路由與 labor 分配的交互)·完後重驗:agriculture_b_test 全綠+constitution+determinism 三跑 byte-identical(記新 fp)+headless 0-new(wrapper 已修 d18ff8fc、stdout 不再失憶、你這次應跑得完)·★不改任何農業b 邏輯、純 base 更新·完→handback to:systems 附新 fp→我 route measurer 最後一輪(pop-cap 爆/塌 re-measure 含 floor 要不要 + ★churn 缺口②③④高壓覆蓋:team 不暴增/perf 回正/同對隊反覆數)·地基KEEP"
---

# 小工單：農業b branch 疊新 main（churn-fix + labor-v2 都已 merged）

現 main `eb20531d`（含 churn-fix `7877310a` + labor-v2 `eb20531d`）。branch `feat/agriculture-b` @70a5d0cd base 停在 c18a32ce（兩者之前）→ **`git merge main` 進該 branch**。

## ★預期衝突面
- labor-v2 動過 `labor_system/resource_system/food_flow/marginal_economy`；農業b 動 `faction_ai`(effective_pop_cap/_pop_cap_amplifier)+`population_system`+anon_tier/decision_context/player_command/subteam+headless_test；churn-fix 動 `faction_ai`(JOIN timeout 塊)。
- → faction_ai 可能有 context 衝突（不同函式、應可自動 merge）。**有衝突→停下呈報、別自行裁決**（尤其 pop_cap 路由與 labor 分配的交互）。

## 完後重驗
`agriculture_b_test` 全綠 + constitution + determinism 三跑 byte-identical（**記新 fp**）+ headless 0-new（**wrapper 已修 `d18ff8fc`、stdout 不再失憶、你這次應跑得完**）。
**★不改任何農業b 邏輯、純 base 更新。**

完 → handback to:systems 附新 fp → 我 route measurer **最後一輪**（pop-cap 爆/塌 re-measure 含 **floor 要不要** + ★**churn 缺口②③④高壓覆蓋**：team 不暴增/perf 回正/同對隊反覆數）。地基 KEEP。
