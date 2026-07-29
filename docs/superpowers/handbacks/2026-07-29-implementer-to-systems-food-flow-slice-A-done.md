---
from: implementer
to: systems
status: consumed
topic: "[done·糧流感知 Slice A 存活持守·請 R²(SliceA)] feat/food-flow-slice-A f945dd18 off main eab4bc64。food_runway 感官(harvest-only 內生每日快取)+safe_ratio×persist 乘法縮放(§4 講死:非硬塌避 regression)+人格 ratio_floor(team14 根治:務實早放/固執撐久)+5 無 ETA task 排除。驗:food_flow_test 9/9(含 ★team14 分化 固執 0.05 vs 務實 0.002)+headless 0-new+gate 74+determinism byte-identical(e5579227)+★世界不凍(attrition 2.03%/teams 49→63/foodflow 4569 fire=活,乘法沒向凍)。危機仍打斷。tap 禁 RNG。★ETA 粗估+ratio 常數 TEST VALUE(§6 measure-tuned)。"
branch: feat/food-flow-slice-A
commit: f945dd18
base: eab4bc64 (local main HEAD)
spec: docs/superpowers/specs/2026-07-29-food-flow-slice-A-survival-hold-HOW.md
---

# done：糧流感知 Slice A（存活持守）——請 R²(Slice A)

碰 regression-prone code（persist/task_arbiter）→ 照 spec §2-4 講死照做，未臨場發明。

## 做（spec §2-4）
1. **糧流感官（§2）**：新 `team.food_runway` 快取欄 + `FoodFlow.update`（每日 cadence，接 `resolve_consumption` 末）：`net=inflow−burn`；`runway=food/max(−net,ε)`（net≥0→RUNWAY_CAP）。**inflow=可持續 harvest-only 內生**（自家 outpost regen×outpost_mult×pop_mult×farming×prod_skill；★外生施捨/貿易/掠奪不算=解賭施捨；狩獵 EV 延後 B）。
2. **safe_ratio（§3）**：`runway/ETA`，只 `TASK_BUILD`（ETA=ticks_left/pop 真施工）；**5 無 ETA task（CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）排除**→走原 persist（維持 Slice 1-4）。
3. **★persist×safe_ratio（§4 講死）**：`persist_effective = persist × safe_factor`；**乘法縮放非硬塌**（★避 PROGRESSIVE_HOLD attrition→0 向凍 regression 同款）；`safe_factor=clamp((safe_ratio−ratio_floor(人格))/(RATIO_SAFE−ratio_floor),0,1)`；**人格 ratio_floor**：務實/機會（flex）floor 高→早放留餘裕；固執/恆心（stick）floor 低→撐久 edge-riding（=team14 根治）。抖動抑制=每日 cadence + gradual clamp band。

## 驗（全綠）
- `food_flow_test` **9/9**：runway surplus(net≥0→CAP)/starving(有限)/harvest-only(無 outpost=0) + safe_factor 乘法縮放(糧充裕 0.06→見底 0.0) + ★**team14 人格分化**（同 runway 8：固執 persist 0.050 撐 vs 務實 0.002 提前放）+ 5-task 排除(CONSTRUCT 走原 persist 0.15)。
- headless **0-new**（6 baseline）+ `constitution_gate` **74 removed=0**。
- determinism **3跑 byte-identical** `e5579227`（tap 禁 RNG）。
- **★★世界不凍**（regression 反例硬回歸，specimen-off）：seed1337 1mo **attrition 2.03%** / teams 49→**63** / pop 444→435 flux / `foodflow.update`=4569（感官每日 fire）= **活**（乘法縮放**沒**向凍，同 Slice 3 健康量級 2.03%）。
- 危機仍打斷（≥THREAT/survival 在 persist 前，不受 safe_ratio 影響）。

## ★透明（measure-tuned）
- **ETA=ticks_left/pop 粗估**（construction tick cadence 不確定→coarse sensor，staleness≤1日 spec 允）。
- `RATIO_SAFE=2.0`/`ratio_floor` mapping(BASE 0.5±SPAN 0.4)/= **TEST VALUE**（§6 measure 調）。
- 抖動：daily cadence + gradual clamp band（顯式 hysteresis deadband 若 measure 見抖再補）。

## 待
systems R²(Slice A)——★硬檢：乘法非硬塌避 regression（world 不凍坐實）+ 5 task 排除 + 人格餘裕分化(team14) + ETA/ratio 常數合理 → merge → **measurer specimen-off**（既有中性 SpecimenDumpHelper，★落地 docs/measurements/ 標 exact path）→ **QA team14 根治故事稽核** → Slice B（派遣立國）。★execution-verified（team14 根治真發生 + 世界不凍）已附。material PARK。
