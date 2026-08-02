---
from: implementer
to: systems
status: consumed
topic: "[done·persist floor·安全閘全綠·★但 complete_build>0 UNMET=founding 從不 dispatch 上游·請裁] feat/peaceful-economy-bed 957cde14。CONSTRUCTION_ACTIVE_FLOOR 0.15 施工中隊 hard-floor。unit 4/4(floor/非施工不floor/擋routine/crisis bypass)+determinism 三跑 byte-identical+不凍(attrition2.03%≠0,teams63)+headless 3=baseline+constitution74+observability PASS+upgrade 6→7不退化+persist.hold14→24 floor fire。★但和平床 complete_build 仍=0:action=build 計數=0/indep.found_*=0=founding-build 從不 dispatch(①隊買 material+就地 upgrade,買主導 preempt founding-to-forest);floor 無 founding TASK_BUILD 可保護→complete_build>0 屬 founding-dispatch 上游,非本 floor 職責。請 systems 裁(force-founding fixture vs 上游 dispatch 根)。"
branch: feat/peaceful-economy-bed
commit: 957cde14
base: 613d763d (local main HEAD)
measurements:
  - docs/measurements/2026-07-30-peaceful-econ-bed-POSTFLOOR-957cde14.txt
  - docs/measurements/2026-07-30-warring-seed1337-floor-957cde14.json
---

# done：active-construction persist floor（★但 complete_build>0 UNMET，請裁）

floor 照 spec 做好、**安全閘全綠、unit-proven、零回歸**。但 spec §5 頭號驗收 `complete_build>0` **測不到**——不是 floor 壞，是 **founding-build 從不 dispatch**（上游）。measure-first honest 呈報，不粉飾（[[feedback_verify_execution_end]]）。

## 做（persist_strength.gd）
- 新 `const CONSTRUCTION_ACTIVE_FLOOR: float = 0.15`（>PERSIST_HOLD_THRESHOLD 0.1+margin）。
- TASK_BUILD 分支：`computed = base_persist × safe_factor`；若 tile `construction_ticks_left>0` → `return maxf(computed, CONSTRUCTION_ACTIVE_FLOOR)`（hard floor 蓋過 safe_factor）。
- 均一 floor 非 ×lean（R² §4）；crisis 靠 task_arbiter ≥THREAT bypass、不靠 persist 降 floor 下（team14 保留）。

## 驗（安全閘全綠）
- **unit 4/4**（`persist_construction_floor_test.gd`）：cold-start 低 lean persist=0.150≥floor>threshold / 非施工(ticks_left=0)不 floor persist=0 / floor→persist.hold 擋 routine 覓食@DISPATCH(bump=1 留 TASK_BUILD) / crisis survival@SURVIVAL bypass 打斷(離 TASK_BUILD，team14 保留)。
- **不凍紅線**：seed1337 1mo attrition=**2.03%≠0**、teams_final=63、start_pop 444→435（churn，非 latch 凍）。
- **determinism**：seed1337 三跑 WARRING_OUT byte-identical（MD5 `D44CA043…`）——floor 純算術零 RNG。
- **own-outpost upgrade 不退化**：complete_upgrade_facility **6→7**（+1，floor 也護 own upgrade active-construction）。
- **persist.hold fire**：和平床 14→**24**（floor 讓更多 routine 搶班被擋）。
- headless **3=baseline(0-new)**、constitution PASS 74 removed=0、observability PASS。

## ★complete_build>0 UNMET——founding-build 從不 dispatch（上游，非 floor 職責）
和平床 re-run（POSTFLOOR dump）坐實：
```
construct.start=15  (全 15 筆 action=upgrade_facility，action=build 計數=0)
indep.found_ally/subjugate/timeout=0/0/0  indep.gate_*=0  construct.complete_build=0
```
**根**：①founding 隊（coin 充 + ②/③ 有 material 賣家）→ `_resolve_resource_prereq` **買 material 先於採@forest**（買成功）→ 買到料就**就地 upgrade own facility**（apothecary，action=upgrade_facility）→ **founding-to-forest 分支從不觸發**。∴ 沒有 founding TASK_BUILD 存在給 floor 保護。earlier stall samples 的 ct_task=覓食/外交 全是 **own-outpost upgrade_facility** stall（非 founding）——我上一份 dump 摘要已標「①founding remote 子隊行為需讀完整 dump」，今坐實=founding 根本沒 dispatch。

∴ **complete_build=0 是 founding-dispatch 上游問題**（買主導 preempt founding），**非 active-construction floor 能解**。floor 對「已 dispatch 的 active TASK_BUILD」有效已 unit + own-upgrade stall 降（6→7）證，只是本床無 founding build 可測。

## 請 systems 裁（design/scope，非我自定）
1. **floor 本身**：安全、proven、零回歸 → 可 ship（它正確保護 active-construction，own-upgrade 已受益）。
2. **complete_build>0 怎麼測**：
   - (a) force-founding fixture：①隊移除 material 賣家 / 砍 coin → 買失敗 → founding-to-forest dispatch → 再測 floor 對 founding 完工效果。
   - (b) 或 complete_build=0 的真根是「買 preempt founding」= founding-dispatch 動機/優先序上游問題（另 arc），floor 是正交的 pipeline 保護。
3. spec §5「persist.hold 真對 founding 子隊 fire 斷言」：本床無 founding 子隊 → 改由 unit test 證 floor→persist.hold 機制（synthetic TASK_BUILD 隊，4/4 綠）；founding-specific 需 (a) 的 force fixture。

★卡在此設計決策 → 等 systems 判 (a)/(b)。floor code + TDD 已 commit 保留。
