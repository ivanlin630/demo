---
from: systems
to: reviewer
status: consumed
topic: "[R②·means-end A1 forest founding 修(whole 驗收 BLOCKER,用戶核准)·異質框外審·spec=docs/superpowers/specs/2026-07-25-means-end-A1-forest-founding-fix.md·前提已 code 坐實免 R①·核心=TASK_BUILD 無 consumer→複用既有 _dispatch_builder 派建造子隊 TASK_CONSTRUCT+★驗執行端 forest outpost 真建成] means-end whole A1 假閉環修。根(code 坐實):build-closure/delegate to_task=TASK_BUILD 但建 new outpost 正確 task=TASK_CONSTRUCT(begin_subteam_construction:538),TASK_BUILD 無 consumer→forest outpost 建不成→A1 核心鏈塞死。修:①S3 build-closure candidate 改=缺料+無 forest outpost→founding candidate(delegate:true,to_task 帶 build_type)→**複用既有 working _dispatch_builder(faction_ai:2597)**(SubteamSystem.dispatch(TASK_CONSTRUCT)+task_extra_data{build_type,level}+afford 1.5x+pop 門檻+caravan-load)②移除隊自己 in-place TASK_BUILD+TASK_MIGRATE frontier(founding 本質派子隊,隊自己 build new outpost 無路,合 WHAT §4 委派)③_dispatch_goal_delegate 擴:founding(帶 build_type)→呼 _dispatch_builder④forest tile 選 find_nearest_terrain_tile(forest)既有 must-fix②(i)。執行閉環:缺料→founding candidate→_dispatch_builder→子隊 TASK_CONSTRUCT→movement:291 抵達→begin_subteam_construction:538→start_build→forest outpost 真建成→harvest→build_F。★核審點(refute):(1)★複用 _dispatch_builder 對否(既有 working 派建造子隊路,非自拼 TASK_BUILD/CONSTRUCT)?(2)★★執行端 TDD 硬驗 forest outpost 真建成(子隊抵達→begin_subteam_construction→start_build→outpost_level>0)=A1 假閉環直接迴歸,夠否?(3)移除隊自己 in-place build+TASK_MIGRATE frontier 對否(founding=委派非 self-build)?(4)afford/pop gate 既有 _dispatch_builder 保留(chicken-egg 缺料建不起 forest outpost=whole measure 判 bootstrap 非本 slice 動)接受否?(5)must-fix① 護欄 founding candidate 沿用?(6)決定性/憲法(founding=rank-pool candidate 非 bespoke)?CLEAN→我 dispatch implementer→focused 重 measure(A1 閉環+A4/B)+QA。有洞→回 to:systems。用異質模型+明確 refute。"
branch: (spec 階段,未 dispatch implementer)
---

# R②：means-end A1 forest founding 修（whole 驗收 BLOCKER，異質框外審）

spec = `docs/superpowers/specs/2026-07-25-means-end-A1-forest-founding-fix.md`。用戶核准修（whole 驗收 A1 BLOCKER）。**前提已 code 坐實免 R①**（`begin_subteam_construction:538` / `TASK_BUILD 無 consumer` / `_dispatch_builder:2597` working）。異質框外 refute。

## 根 + 修摘要
- **根**：build-closure/delegate to_task=`TASK_BUILD`，但建 new outpost 正確 task=`TASK_CONSTRUCT`（`begin_subteam_construction:538`）；TASK_BUILD 無 consumer → forest outpost 建不成 → A1 假閉環。
- **修**：S3 build-closure candidate → **founding candidate**（`delegate:true`，帶 build_type）→ **複用既有 working `_dispatch_builder`（faction_ai:2597）**（`SubteamSystem.dispatch(TASK_CONSTRUCT)` + `task_extra_data{build_type,level}` + afford 1.5x + pop + caravan-load）；移除隊自己 in-place TASK_BUILD + TASK_MIGRATE frontier（founding=委派，合 WHAT §4）；forest tile 選 `find_nearest_terrain_tile("forest")`（既有 must-fix②(i)）。
- **執行閉環**：缺料→founding candidate→`_dispatch_builder`→子隊 TASK_CONSTRUCT→`movement:291` 抵達→`begin_subteam_construction`→`start_build`→**forest outpost 真建成**→harvest→build_F。

## ★核審點（refute）
1. ★**複用 `_dispatch_builder` 對否**（既有 working 派建造子隊路，非自拼 task）？
2. ★★**執行端 TDD 硬驗 forest outpost 真建成**（子隊抵達→begin_subteam_construction→start_build→outpost_level>0）＝ A1 假閉環直接迴歸，夠否？
3. **移除隊自己 in-place build + TASK_MIGRATE frontier** 對否（founding=委派非 self-build）？
4. **afford/pop gate 既有 `_dispatch_builder` 保留**（chicken-egg 缺料建不起 forest outpost = whole measure 判 bootstrap 非本 slice 動）接受否？
5. must-fix① 護欄 founding candidate 沿用？
6. 決定性 / 憲法（founding=rank-pool candidate 非 bespoke）？

**CLEAN → 我 dispatch implementer → focused 重 measure（A1 閉環+A4/B）+ QA。** 有洞 → 回 `to:systems`。用異質模型 + 明確 refute。
