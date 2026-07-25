---
from: systems
to: implementer
status: open
topic: "[dispatch·means-end A1 forest founding 修(whole 驗收 BLOCKER,R②CLEAN)·三處 TASK_BUILD 死路一併修→複用既有 builder+★TDD 打真管線執行端硬驗·★base=LOCAL main HEAD 0c2623b0(whole-done)非 origin·新 branch feat/means-end-A1-fix off local HEAD] means-end whole A1 假閉環修(R①免/R②異質 CLEAN)。spec=docs/superpowers/specs/2026-07-25-means-end-A1-forest-founding-fix.md。根:goal_resolver 三處發 {task:TASK_BUILD} 但 TASK_BUILD 無 new-outpost/facility consumer(begin_subteam_construction 只認 TASK_CONSTRUCT/UPGRADE/EXPAND)→建不成→A1 核心鏈塞死=假閉環。修(照 spec §2/§2b,複用既有 working builder 非自拼 task):①S3 build-closure(_resolve_resource_prereq 採@地形手段):缺料+無該地形 outpost→**founding candidate**(delegate:true+build_type:civilian+target=find_nearest_terrain_tile(forest));★移除隊自己 in-place TASK_BUILD+TASK_MIGRATE frontier(該路死路,founding 本質派子隊,合 WHAT §4)②S4 _resolve_build_facility:171(隊自己 tile 未建→建 new outpost)→同 founding(delegate+build_type)③S4 build_F action:178(自家 owned outpost 建 facility)→**facility candidate**(delegate+facility key,無 build_type)④★_dispatch_goal_delegate(faction_ai:2806)擴 3 分支:founding(帶 build_type)→_dispatch_builder(state,team,target,build_type,1);facility(帶 facility)→_dispatch_facility_builder(state,team,own_outpost_pos,facility)[既有 faction_ai:2851 派子隊 TASK_EXPAND];既有 build/settle→SubteamSystem.dispatch⑤_delegate_variant:121 加 if self_cand.get(delegate,false): return {} 早退(founding/facility 已 delegate 別再包委派的委派)。★★TDD(照 spec §5,must-fix② 打真管線非抄近似):①build-closure 生 founding candidate②★★執行端硬驗真管線=從隊真 material 缺口 goal_state→呼 GoalResolver.frontier_candidates 拿真 candidate→餵真 _dispatch_goal_delegate(測 founding/facility 型別判斷分支本身,非繞過直呼 _dispatch_builder)→子隊 TASK_CONSTRUCT→抵達→begin_subteam_construction→start_build→forest outpost 真建成(outpost_level>0)③S4 build_F 執行端硬驗(:171 outpost 真建成/:178 facility 真建成 own outpost facility level>0)④三處 TASK_BUILD 全移除(frontier_candidates 不再生任何 {task:TASK_BUILD})⑤must-fix① range 斷言(founding/facility candidate util<survival)⑥determinism 2 跑 byte-identical。閘:constitution_gate 74 removed=0+headless 0-new+determinism。★whole-system-first:只修三處 TASK_BUILD 死路執行端接對;afford/pop gate 既有 _dispatch_builder/_dispatch_facility_builder 保留(chicken-egg=whole measure 判非本 slice)。完成=systems+reviewer R²(★我收驗必查執行端 outpost/facility 真建成,照 feedback_verify_execution_end)→to:systems 收驗+R²→CLEAN merge→我 dispatch measurer focused 重 measure(A1 閉環+A4/B)+QA。task=systems+reviewer。"
branch: feat/means-end-A1-fix
---

# dispatch：means-end A1 forest founding 修（三處 TASK_BUILD 死路一併修）

means-end whole **A1 假閉環修**（R①免 / R②異質 CLEAN）。spec = `docs/superpowers/specs/2026-07-25-means-end-A1-forest-founding-fix.md`。

## ★★base 鐵律
- off **LOCAL main HEAD `0c2623b0`**（whole-done，S1-S7）非 origin。

## 根
`goal_resolver` **三處**發 `{task:TASK_BUILD}`，但 TASK_BUILD **無** new-outpost/facility consumer（`begin_subteam_construction` 只認 TASK_CONSTRUCT/UPGRADE/EXPAND）→ 建不成 → A1 核心鏈塞死 = 假閉環。

## 修（複用既有 working builder，非自拼 task）
1. **S3 build-closure**（`_resolve_resource_prereq` 採@地形）：缺料+無該地形 outpost → **founding candidate**（`delegate:true` + `build_type:"civilian"` + target=`find_nearest_terrain_tile("forest")`）；★**移除隊自己 in-place TASK_BUILD + TASK_MIGRATE frontier**（死路，founding=派子隊，合 WHAT §4）。
2. **S4 `:171`**（隊自己 tile 未建 → 建 new outpost）→ 同 founding（delegate+build_type）。
3. **S4 build_F action `:178`**（自家 owned outpost 建 facility）→ **facility candidate**（delegate + facility key，無 build_type）。
4. ★**`_dispatch_goal_delegate`（faction_ai:2806）擴 3 分支**：founding（build_type）→ `_dispatch_builder(state,team,target,build_type,1)`；facility（facility）→ `_dispatch_facility_builder(state,team,own_outpost_pos,facility)`〔既有 faction_ai:2851 TASK_EXPAND〕；既有 build/settle → SubteamSystem.dispatch。
5. `_delegate_variant:121` 加 `if self_cand.get("delegate",false): return {}` 早退。

## ★★TDD（must-fix② 打真管線非抄近似）
1. build-closure 生 founding candidate。
2. ★★**執行端硬驗真管線**：隊真 material 缺口 `goal_state` → `GoalResolver.frontier_candidates` 拿真 candidate → 餵真 `_dispatch_goal_delegate`（測 founding/facility 型別判斷分支，**非繞過直呼 `_dispatch_builder`**）→ 子隊 TASK_CONSTRUCT → 抵達 → begin_subteam_construction → start_build → **forest outpost 真建成**（outpost_level>0）。
3. S4 build_F 執行端硬驗（:171 outpost 真建成 / :178 facility 真建成 own outpost facility level>0）。
4. 三處 TASK_BUILD 全移除。
5. must-fix① range 斷言（founding/facility candidate util<survival）。
6. determinism 2 跑 byte-identical。

## 閘 + 完成
- `constitution_gate` 74 removed=0 + headless 0-new + determinism。
- ★whole-system-first：只修三處死路執行端接對；afford/pop gate 既有 builder 保留（chicken-egg=whole measure 判）。
- 完成 = systems + reviewer R²（★我收驗必查執行端 outpost/facility 真建成，照 `feedback_verify_execution_end`）→ `to:systems` → CLEAN merge → 我 dispatch measurer focused 重 measure + QA。
