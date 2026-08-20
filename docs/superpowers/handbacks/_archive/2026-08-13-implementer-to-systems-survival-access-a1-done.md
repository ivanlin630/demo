---
from: implementer
to: systems
status: consumed
topic: "[slice A1 DONE·feat/survival-access-a1 commit ac8f5418]紮營價值=MarginalEconomy 真帳(camp_drive term 換算法、禁 crank 雙防線、行為變 slice)·①新 MarginalEconomy.camp_marginal(est,forage_floor)=maxf(0,_inflow_est(est)−forage_floor)純算術零新常數鏡射 migrant_marginal②DecisionContext.gather 新欄 camp_target_est(VillageEstimate.make 靶 tile terrain belief 地理/outpost1/farming0/pop、無靶 null)+camp_forage_floor(=_forage_subsist_buffer/FORAGE_FLOOR_DAYS 覓食餬口日產)③camp_drive=marg/daily_need×urgency clamp[0,CAMP_CAP1.5]、URGENCY_DAYS=PROVISION_DAYS10 既有錨·★驗:camp_marginal_test ALL PASS bounded 四象限(①無可耕地 gate→0②富流浪 food_days≥10→urgency0→0③瀕餓+肥沃平原→1.0 高④瀕餓+低產森林高 pop→camp_marginal maxf(0)=0 不紮 anti-crank)+headless 0-new+constitution 75+determinism 3-run byte-identical(warring 678b3ee3)·感知鐵律(est belief 地理/food_days 自知)、零新 RNG、禁 crank 雙防線(has_farmable gate 排 mountain+maxf(0)+CAP bound)、fp intended-change·★measurer bounded 四象限量測請求(綠才 merge)·請 merge-gate 硬讀→measurer→綠 merge→dispatch A2/A3"
branch: feat/survival-access-a1
commit: ac8f5418
---

# slice A1 DONE — 紮營價值 = MarginalEconomy 真帳（camp_drive term 換算法、禁 crank 雙防線）

feat/survival-access-a1 commit `ac8f5418`（off main HEAD d9a05cff；已 push）。

## fix（term 非 gate、禁 crank 雙防線）
1. **`MarginalEconomy.camp_marginal(est, forage_floor)`** = `maxf(0, _inflow_est(est) − forage_floor)`。純算術零新常數、鏡射 `migrant_marginal`（god-view 防線=只吃純 struct est）。低產 tile → maxf(0)=0。
2. **`DecisionContext.gather` 新欄**：`camp_target_est`（`VillageEstimate.make(靶 tile terrain=belief 地理, outpost1, farming0, pop)`、無靶→null）+ `camp_forage_floor`（`=_forage_subsist_buffer/FORAGE_FLOOR_DAYS`=覓食餬口日產同源）。
3. **`camp_drive`**：非紮營/無可耕地/est null→0；`clampf(marg/max(daily_need,ε), 0, CAMP_CAP)×urgency`。`CAMP_CAP=1.5` bound、`URGENCY_DAYS=PROVISION_DAYS`(10)既有錨。

## 命門守
感知鐵律（est 從 `_find_unowned_farmable_tile` 地理 belief 非他隊 live；food_days 自家自知）、零新 RNG、**禁 crank 雙防線**（has_farmable gate 排 mountain + camp_marginal `maxf(0)` + CAMP_CAP bound 非 inflate）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `camp_marginal_test` | **ALL PASS**：bounded 四象限（①無可耕地 gate→0 ②富流浪 food_days≥10→urgency 0→0 ③瀕餓+肥沃平原→**1.0 高** ④瀕餓+低產森林高 pop→camp_marginal `maxf(0)=0`→不紮 **anti-crank marginal 路徑**）+ camp_marginal 直測（森林 0/平原 4）+ CAP bound |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |
| determinism | **3-run byte-identical**（warring seed1337 1000t FP `678b3ee3`；純算術無新 randf） |

fp **intended-change**（camp_drive marginal vs 舊 flat 1.0）；warring 1000t camp 路徑 dormant（無 vagrant settle exercise）→ whole-sim 分化在 vagrant/founding 床。

## ★measurer bounded 四象限量測請求（交 measurer、綠才 merge）
- ①有家/已 resident→紮營 N/A or marg≈0 ②富流浪→camp_drive=0 ③瀕餓+肥沃→高紮 ④瀕餓+低產→不紮（anti-crank）。
- `CAMP_CAP`/`URGENCY_DAYS` bounded-verify（非 fire-crank、封頂 vs inflate）。realistic vagrant/founding 床。
- determinism/regression/constitution 綠（已達）。

## 路
1. **你 merge-gate 硬讀**（camp_marginal 只吃 est god-view 防線 + 雙 anti-crank + term 非 gate + CAP bound + 感知鐵律）。
2. → measurer bounded 四象限 → 綠 merge → dispatch A2/A3（diagnostic-first）。地基 KEEP。

（perf/F2 disk flag 續。）
