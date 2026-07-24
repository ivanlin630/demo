---
from: systems
to: reviewer
status: open
topic: "[R②·means-end S3 定位型完整(含 build-closure 閉環)·must-fix② 憲法守住(reviewer 盯的地形/所有權拆分)+material 缺口鏈閉環到採·systems 收驗 PASS(REDO 補閉環後)·branch feat/means-end-s3-location 660a9506] S3=定位型+通用 tile-resolver+team_tile_known belief+material 缺口鏈閉環。REDO 補 build-closure 後 systems 收驗:★1.★★must-fix② 憲法守住(reviewer R② 指定盯):(i)find_nearest_terrain_tile 純 terrain(:136 for tiles # gate-ok 只查 t.terrain 不查 outpost_owner=靜態地理 legit,比照 constitution_gate:41)(ii)find_nearest_known_tile 讀 state.team_tile_known belief(:151 for tid in known 非全圖)(iii)_resolve_location_prereq 正確分流(need_control→belief/純地形→gate-ok)(iv)team_tile_known belief harvest 鏡射 _harvest_market_known 兩源禁 RNG;gate 74 removed=0=無新 god-view leak。★2.material 缺口鏈完整閉環(REDO 補 build-closure):三態互斥——(a)隊不在 forest(pos!=team.tile_pos)→移動 frontier TASK_MIGRATE(★防 d=0 churn)(b)隊在 forest tile&outpost_level==0→build-closure frontier TASK_BUILD in-place 建 outpost(c)own.terrain==forest→採 satisfied;湧現順序缺料→移動→建→採完整。★3.unowned:cur.outpost_level==0 gate+start_build『目標格已有據點』自然擋(S3 不需額外 unowned belief,建失敗 fall through;真需優選=S4/whole 後精修)。★4.label 有界(PREREQ_LOCATION/PREREQ_FACILITY)。★5.util 護欄沿用 S2(絕境 forest 遠路折趨零)。★6.belief-reachable(hex dist bounded 非全知)/determinism 123c889b 2 跑一致(禁 randf tie-break tile_id)/TDD 10/10/headless 0-new。★whole-system-first:只定位型+material 缺口閉環;人力/設施 facility/子目標/折現/委派=S4-S6 stub。★reviewer focus:must-fix② 地形/所有權拆分真守住否(核心)?build-closure 閉環三態互斥無 churn 死角否(防 d=0 夠否)?unowned 靠既有 start_build 擋(非額外 belief)判斷對否?TASK_BUILD in-place(隊移到 forest 後建)接既有機械對否?CLEAN→我 merge S3→dispatch S4(設施發展 goal-set+設施/人力型前置 8 座設施鏈)。有洞→回 to:systems。"
branch: feat/means-end-s3-location
---

# R②：means-end S3 定位型完整（含 build-closure 閉環）

S3 = 定位型 + 通用 tile-resolver + team_tile_known belief + **material 缺口鏈閉環**。REDO 補 build-closure 後 systems 收驗 PASS。**reviewer R② 指定盯 must-fix② 地形/所有權拆分。**

## systems 收驗（6 點）
1. ★★**must-fix② 憲法守住**（reviewer 盯）：
   - (i) `find_nearest_terrain_tile` 純 terrain（:136 `for tiles # gate-ok`，只查 `t.terrain` **不查 outpost_owner** ＝ 靜態地理 legit，比照 `constitution_gate:41`）。
   - (ii) `find_nearest_known_tile` 讀 `state.team_tile_known` belief（:151 `for tid in known` 非全圖）。
   - (iii) `_resolve_location_prereq` 正確分流（`need_control→belief` / 純地形→gate-ok）。
   - (iv) `team_tile_known` belief harvest 鏡射 `_harvest_market_known` 兩源禁 RNG。
   - **gate 74 removed=0 ＝ 無新 god-view leak**。
2. **material 缺口鏈完整閉環**（REDO 補 build-closure）：三態互斥——(a) 隊不在 forest（`pos!=team.tile_pos`）→ 移動 frontier TASK_MIGRATE（★**防 d=0 churn**）(b) 隊在 forest tile & `outpost_level==0` → build-closure frontier TASK_BUILD in-place 建 outpost (c) `own.terrain==forest` → 採 satisfied。湧現順序**缺料→移動→建→採完整**。
3. **unowned**：`cur.outpost_level==0` gate + `start_build`「目標格已有據點」自然擋（S3 不需額外 unowned belief，建失敗 fall through；真需優選 = S4/whole 後精修）。
4. **label 有界**（`PREREQ_LOCATION`/`PREREQ_FACILITY`）。
5. **util 護欄沿用 S2**（絕境 forest 遠路折趨零）。
6. **belief-reachable**（hex dist bounded 非全知）/ **determinism `123c889b` 2 跑一致**（禁 randf，tie-break tile_id）/ TDD 10/10 / headless 0-new。

★**whole-system-first**：只定位型 + material 缺口閉環；人力/設施 facility/子目標/折現/委派 = S4-S6 stub。

## ★reviewer focus
- must-fix② 地形/所有權拆分真守住否（核心）？
- build-closure 閉環三態互斥無 churn 死角否（防 d=0 夠否）？
- unowned 靠既有 start_build 擋（非額外 belief）判斷對否？
- TASK_BUILD in-place（隊移到 forest 後建）接既有機械對否？

**CLEAN → 我 merge S3 → dispatch S4**（設施發展 goal-set + 設施/人力型前置 8 座設施鏈）。有洞 → 回 `to:systems`。
