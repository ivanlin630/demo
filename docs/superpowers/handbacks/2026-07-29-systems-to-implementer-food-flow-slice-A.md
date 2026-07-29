---
from: systems
to: implementer
status: open
topic: "[實作·糧流感知 SLICE A(存活持守)·R²CLEAN(persist×safe_ratio三項講死+避regression同款)·spec=2026-07-29-food-flow-slice-A-survival-hold-HOW.md·糧流感官harvest-only每日快取+safe_ratio只有ETA task+persist×safe_ratio乘法縮放非硬塌+人格ratio_floor餘裕根治team14+5task排除+抖動hysteresis+tap禁RNG·★根治team14 nuance+世界不凍硬驗] 糧流感知3slice第一slice。存活持守最小。★碰task_arbiter/persist_strength(剛出過world regression)講死照做別臨場發明。"
branch: feat/food-flow-slice-A
---

# 實作：糧流感知 SLICE A（存活持守）

R②CLEAN（persist×safe_ratio 三項全講死 + 正確避 regression 同款陷阱）。3 slice 第一 slice。**存活持守最小 + 根治 team14 nuance**。

## spec
`docs/superpowers/specs/2026-07-29-food-flow-slice-A-survival-hold-HOW.md`（完整 §2-7，讀它）。

## 核心（照 spec 講死，別臨場發明——碰剛出過 world regression 的 code）
1. **糧流感官**（§2）：新 `team.food_runway` 快取欄；`net=inflow−burn`、`runway=food/max(−net,ε)`（net≥0→runway=∞）；**inflow=harvest-only 內生**（自家 outpost 真 collection resource_system:63-76 + 當前 tile 可持續採，★延後打獵 EV 到 B）；**每日 cadence 算 1 次 + 快取**（接既有日結算）。
2. **safe_ratio**（§3）：`runway/ETA_days`；**只對有真 ETA 的 TASK_BUILD**（persist_strength:51-61）；**5 種無 ETA（CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）排除**走原 persist。
3. **★persist×safe_ratio**（§4，講死照做）：`persist_eff = persist_strength × safe_factor`；**乘法縮放非硬塌**（★避 PROGRESSIVE_HOLD attrition→0 向凍 regression）；`safe_factor=clamp((safe_ratio−ratio_floor(人格))/(ratio_safe−ratio_floor),0,1)`；**人格 ratio_floor 餘裕**（務實 floor 高早放/固執 floor 低撐久=team14 根治）；抖動 hysteresis + 日 cadence。

## ★TDD + 驗（硬）
- safe_ratio/safe_factor 公式單測（runway vs ETA、人格 ratio_floor 分化、乘法縮放、5 task 排除、net≥0→∞）。
- **★team14 nuance 根治驗**：務實人格隊 runway 下坡**提前放手**（到 ratio_floor 就塌、非撐 food=0）；固執撐久但人格餘裕差異（非全體撐 0）。
- **★★世界不凍**（latch/regression 反例硬回歸）：specimen-off（★既有中性 SpecimenDumpHelper）seed1337/42 teams/pop churn、attrition 兩者皆活（乘法縮放沒向凍）。
- 危機仍打斷（≥THREAT/CRISIS_FLOOR 在 persist 前）。
- **tap**：food_runway/safe_ratio/safe_factor/persist_eff 接 Probe（★禁耗 RNG，feedback_observer_no_global_rng）。
- 閘：headless 0-new + gate 74 + determinism 3跑 byte-identical。

## 交付
handback `to:systems` → R²（Slice A 實作）→ merge → **measurer specimen-off（既有中性 helper、★落地 docs/measurements/ 標 exact path 驗存在，別重蹈交接 3x 失敗）→ QA team14 根治故事稽核** → SLICE B（派遣立國）。★execution-verified（team14 根治真發生+世界不凍）。持守 release 相關（blueprint 另跟用戶）。
