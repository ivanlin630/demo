---
from: systems
to: implementer
status: open
topic: "[dispatch build iii 絕境排序(2 靶 herald hedge+defect consequence、行為變 slice、design LOCKED docs/superpowers/specs/2026-08-11-desperation-ordering-design.md + concrete HOW docs/superpowers/specs/2026-08-11-desperation-ordering-HOW.md)·新 slice feat/desperation-ordering off 更新後 main(bb372376)·★★§HOW-binding 寫死(滿足 design §2.5 3 必查項):靶1 herald catastrophe-hedge(_try_herald_side mini-util)=+hedge、hedge=clampf((severity−HEDGE_ONSET)/(1−HEDGE_ONSET),0,1)×HEDGE_CATASTROPHE_MAG×pmult(★②bounded:低 severity→0 非 flat always-ask、人格 pmult modulate);靶2 defect consequence(event_faction_defect defect_util)=−consequence、consequence=clampf(1−food_days/DESPERATION_DAYS,0,1)×DEFECT_CONSEQUENCE_MAG(★③連續:走 food_days 連續函式禁 if-starving branch、吃飽→0 野心叛不變/餓→1 餓叛壓)·food_days 需進 event_faction_defect context(無則加純讀 gather、感知鐵律自隊自知 food)·★★命門乙雙向 genuine 非 crank:結構真值(hedge=near-catastrophe option-value/consequence=餓叛通往死後果)、magnitude=TEST VALUE 校準非 crank、非 boost 逼 fire(低 severity hedge=0)、非刪叛離(絕望-abandoned distress×loyalty 仍壓過 consequence 照叛/野心叛 starve_frac=0 照 fire)·★②必附 machine-demonstrate:dump hedge 對 severity 曲線(低 severity≈0 高增)證 bounded 非 offset·★★行為變 slice=F0 fp 對 baseline 預期分化 intended(領主餓隊求援序變、非 byte-identical、記錄方向)+determinism 3-run byte-identical+headless 0-new+constitution 綠(兩 repricing=util 項非新硬閘)+無 regression(recovery/cohesion/info-net arc 回歸綠)·★TEST VALUE(HEDGE_ONSET~0.5-0.6/HEDGE_CATASTROPHE_MAG 校到 razor-thin -0.004 翻/DEFECT_CONSEQUENCE_MAG)留 measurer 校準(結構先對、值後調)·完成 handback to:systems R²(核②bounded machine-demonstrate+③連續無 branch+genuine 非 crank+fp 分化 intended)→measurer 量(④順序 emergent 硬 gate+餓叛率降+野心叛不變+人格分化+校 TEST VALUE)→QA specimen(餓隊求援先 fire→活過 defect)→merge=iii 收→re-measure scale·地基 KEEP"
---

# dispatch build iii 絕境排序（2 靶、行為變 slice）

design LOCKED：`2026-08-11-desperation-ordering-design.md`（blueprint WHAT+§2.5、R①/R² CLEAN）+ concrete HOW：`2026-08-11-desperation-ordering-HOW.md`（systems 公式）。新 slice `feat/desperation-ordering` off 更新後 main（`bb372376`）。

## ★★§HOW-binding（寫死、滿足 §2.5 3 必查項）
- **靶1 herald catastrophe-hedge**（`_try_herald_side` mini-util）：`mini += hedge`、`hedge = clampf((severity−HEDGE_ONSET)/(1−HEDGE_ONSET),0,1) × HEDGE_CATASTROPHE_MAG × pmult`（★②bounded：低 severity→0 非 flat always-ask、人格 pmult modulate）。
- **靶2 defect consequence**（`event_faction_defect` defect_util）：`defect_util −= consequence`、`consequence = clampf(1−food_days/DESPERATION_DAYS,0,1) × DEFECT_CONSEQUENCE_MAG`（★③連續：走 food_days 連續函式**禁 if-starving branch**、吃飽→0 野心叛不變 / 餓→1 餓叛壓）。food_days 需進 context（無則加純讀 gather、感知鐵律自隊自知 food）。

## ★★命門乙雙向 genuine 非 crank
結構真值（hedge=near-catastrophe option-value / consequence=餓叛通往死後果）、magnitude=TEST VALUE 校準非 crank、**非 boost 逼 fire**（低 severity hedge=0）、**非刪叛離**（絕望-abandoned distress×loyalty 仍壓過 consequence 照叛 / 野心叛 starve_frac=0 照 fire）。

## ★★驗收
- ②**必附 machine-demonstrate**：dump hedge 對 severity 曲線（低 severity≈0 高增）證 bounded 非 offset。
- 行為變 slice = F0 fp 對 baseline **預期分化 intended**（餓隊求援序變、非 byte-identical、記錄方向）+ determinism 3-run byte-identical + headless 0-new + constitution 綠（兩 repricing=util 項非硬閘）+ 無 regression（recovery/cohesion/info-net arc）。
- ★TEST VALUE（HEDGE_ONSET~0.5-0.6 / HEDGE_CATASTROPHE_MAG 校到 razor-thin -0.004 翻 / DEFECT_CONSEQUENCE_MAG）留 measurer 校準（結構先對、值後調）。

## 序
handback `to:systems`（R² merge-gate：②bounded machine-demonstrate + ③連續無 branch + genuine 非 crank + fp 分化 intended）→ measurer 量（④順序 emergent 硬 gate + 餓叛率降 + 野心叛不變 + 人格分化 + 校 TEST VALUE）→ QA specimen（餓隊求援先 fire→活過 defect）→ merge = iii 收 → re-measure scale（乾淨 base、源頭斷）。地基 KEEP。
