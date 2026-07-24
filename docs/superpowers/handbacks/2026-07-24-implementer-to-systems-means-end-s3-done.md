---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S3 定位型+tile-resolver·must-fix② 落地守住·material 缺口解·收+驗+R²請(★reviewer 盯地形/所有權拆分)] feat/means-end-s3-location 135a2e3f off local main 3d11a506(含 S2)。6 塊:location handler/★tile-resolver 拆兩類(terrain # gate-ok/known belief)/team_tile_known belief store/material 缺口鏈(採@forest→移動 candidate)/util 護欄沿用/belief-reachable。TDD 7/7/headless 0-new/★gate PASS sites=74 removed=0=must-fix② 守住/determinism 2跑一致 ff4bdf91,S3!=S2。whole-system-first:只定位型+material 缺口。完成=systems+reviewer R²→CLEAN merge→dispatch S4。"
branch: feat/means-end-s3-location
commit: 135a2e3f
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S3 定位型 + tile-resolver（must-fix② 落地，請 systems 收+驗+R²）

HOW spec §10 S3。定位型前置 + 通用 tile-resolver；解 material 核心缺口（缺料+買不到→移動到 forest tile→建 outpost→採＝means-end 湧現順序）。★★**must-fix② 硬做**（reviewer R² 指定）：tile 查詢**拆兩類，禁 generic 含混過 constitution_gate**。

## 6 塊
1. **location 前置 handler**（`_resolve_location_prereq`，`{terrain, control?}`）：查隊在/有滿足 tile，未滿→tile candidate。
2. **★通用 tile-resolver 拆兩類（§4 must-fix②）**：
   - **(i) `find_nearest_terrain_tile`** = 純地形/物理地理（公共知識）→ 全圖掃標 **`# gate-ok`**（比照 `constitution_gate:41` 市集地理先例）。
   - **(ii) `find_nearest_known_tile`** = 所有權/control（動態，踩 `invariants:192` 市集判例）→ 讀 `team_tile_known` belief（**禁全圖 god-view**）。
   - belief-reachable = bounded hex dist（非全知 PathSystem live）。決定性 tie-break tile_id。
3. **新 `state.team_tile_known` belief store** + `_harvest_tile_known`（兩源：bounded vision scan + relay team_known tile 訊息，鏡射 `_harvest_market_known`）。禁 RNG。
4. **★material 缺口鏈**（arc 原始動機，湧現示範）：`_resolve_resource_prereq` 加採@地形——買不到（無市場）+ `RES_HARVEST_TERRAIN` material→forest → 無 forest outpost → frontier「移動到最近可達 forest tile」candidate（`to_task=TASK_MIGRATE`；到了下一 frontier=建 outpost，前置滿才 applicable→湧現順序）。★委派=S5 別提前，隊自己移動。
5. **util 護欄沿用 S2** `_candidate_util`（絕境 forest 遠路折趨零=不棄糧走遠路）。

## 驗（皆綠）
- TDD `means_end_s3_test` **7/7**（①material 缺口鏈:maintain_material:location candidate→MIGRATE forest(8,5) ②tile-resolver 兩類分流[terrain 全圖掃找到 vs known belief vision 外找不到] ③belief 37<400 只 vision 已發現 ⑤bounded reachable[max_range 5 排遠、30 含]）。
- headless 0-new（3 baseline；S3 行為變但無新 fail）。
- **★gate PASS sites=74 removed=0 = must-fix② 守住**：`find_nearest_terrain_tile` 的 `for tid in state.world.tiles` 標 `# gate-ok`（純地形公共地理）；`find_nearest_known_tile` 讀 belief store 無 mapscan → **無新 god-view leak**（reviewer 盯的地形/所有權拆分真守住）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `ff4bdf91`（純讀狀態/belief harvest 無 randf，tie-break tile_id）；★**S3 != S2-baseline `57381eace`**（定位型有真行為=material 缺口鏈 fire）。

## ★whole-system-first
S3 **只定位型 + material 缺口**；人力/設施 build/子目標/折現/委派 = S4-S6 未提前。resolver manpower/facility/subgoal kind → 無 candidate（stub）。material 「建 outpost」的 build 動作接既有（移動到 forest 後由既有 settle/build 機制承接），未做 S5 委派。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S3 R²（★reviewer 盯 **must-fix② 地形/所有權拆分真守住否**：`find_nearest_terrain_tile` gate-ok 是否 legit 公共地理 / `find_nearest_known_tile` 是否真只讀 belief 非全圖 / material 缺口鏈湧現順序 / belief-reachable 非全知）→ CLEAN merge → dispatch S4（設施型 build 前置 + 遞迴 build_<facility> subgoal）。
base=local main 3d11a506（含 S2）。
