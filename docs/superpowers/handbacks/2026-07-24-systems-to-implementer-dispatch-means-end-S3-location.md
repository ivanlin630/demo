---
from: systems
to: implementer
status: open
topic: "[dispatch·means-end S3 定位型+通用 tile-resolver+team_tile_known belief·★must-fix② 落地首戰場(reviewer 盯)+解 material 核心缺口(移動到 forest→建→採 湧現)·★base=LOCAL main HEAD 707238d2(含 S2)非 origin·新 branch feat/means-end-s3-location off local HEAD] S1 骨架/S2 資源型已 merged。S3=定位型前置+通用 tile-resolver,解本場 material 缺口(缺料+買不到→移動到 forest tile→建 outpost→採 material=means-end 湧現順序漂亮示範)。★★must-fix② 硬做(reviewer R② 指定,S3 落地首戰場):tile 查詢**拆兩類禁 generic 含混過 constitution_gate**。修(照 spec 組件 C 定位 handler+§4 tile-resolver):①location 前置 handler(組件 C):location 前置格式{kind:location,terrain:<地形>,control:<bool?>};查隊是否『在/有』滿足條件 tile,未滿→生 tile frontier candidate。②★通用 tile-resolver 拆兩類(§4 must-fix②):(i)find_nearest_terrain_tile(state,team,terrain_cond,reachable)=純地形/物理地理(terrain==forest/material regen>0)→比照 constitution_gate:41 公共地理 **# gate-ok** 全圖掃(ii)find_nearest_known_tile(...)=所有權/control(unowned/我方控制=動態狀態,踩 invariants:192 市集判例)→讀新建 **team_tile_known belief store**(禁全圖 god-view 掃)。可達=**belief-reachable**(感知鐵律,非全知 PathSystem live)。★模組必 scripts/simulation/decision/(GV_FILE_RE 涵蓋)。③★新 team_tile_known belief store(鏡射既有 team_market_known:_harvest_market_known 結構):tile-discovery 兩源(親見 vision 半徑 bounded local scan+relay team_known 的 tile 訊息)→存 state.team_tile_known;禁新 RNG。④★material 核心缺口鏈(arc 原始動機,湧現示範):maintain_material resource 前置未滿+S2 買不到(無市場 candidate)→定位取得手段『採@forest』:需 forest outpost(location 前置 terrain:forest)→隊無 forest outpost→frontier『移動到最近可達 forest tile』candidate(到了下一 frontier=建 outpost 那裡,前置滿才 applicable→湧現順序);to_task=移動到該 tile(既有 move task/target=forest tile_pos)。★委派(派子隊 settle)=S5(組件 D)別提前,S3 隊自己移動。⑤util 護欄沿用 S2 _candidate_util(GOAL_UTIL_CAP+dev_coeff,絕境 forest 遠路折趨零=不棄糧走遠路)。TDD:①location 前置 handler 生 tile candidate(缺 material+無 forest outpost+買不到→移動 forest candidate)②tile-resolver 兩類分流(地形查詢 vs control 查詢走不同源)③team_tile_known belief 只存已發現 tile(非全圖)④★★must-fix② constitution_gate 綠=無新 god-view leak(gv_mapscan detector 對 find_nearest_known_tile 讀 belief 非全圖;find_nearest_terrain_tile 純地形標 # gate-ok)⑤belief-reachable(可達走 belief 非全知)⑥determinism 2 跑 byte-identical(tile-resolver/belief harvest 禁 randf,tie-break tile_id)。閘:constitution_gate PASS(★must-fix② 關鍵:新 tile 查詢守 belief/地理分野)+headless 0 new+determinism。★whole-system-first:S3 只定位型+material 缺口;人力/設施 build/子目標/折現/委派=S4-S6 別提前(S3『建 outpost』的 build 動作若需 settle 機械=接既有最小,別做 S5 委派)。完成=systems+reviewer R²(★reviewer 盯 must-fix② 地形/所有權拆分真守住否)→to:systems 收驗+S3 R²。task=systems+reviewer。"
branch: feat/means-end-s3-location
---

# dispatch：means-end S3 定位型 + tile-resolver + team_tile_known belief（must-fix② 落地 + material 缺口解）

S1 骨架 / S2 資源型已 merged。**S3 = 定位型前置 + 通用 tile-resolver**，解本場 **material 核心缺口**（缺料 + 買不到 → 移動到 forest tile → 建 outpost → 採 material ＝ means-end 湧現順序漂亮示範）。★★**must-fix② 硬做**（reviewer R② 指定，S3 落地首戰場）：tile 查詢**拆兩類，禁 generic 含混過 constitution_gate**。

## ★★base 鐵律
- off **LOCAL main HEAD `707238d2`**（含 S2）非 origin。

## 修（spec 組件 C 定位 handler + §4 tile-resolver）
1. **location 前置 handler**（組件 C）：格式 `{kind:"location", terrain:<地形>, control:<bool?>}`；查隊「在/有」滿足條件 tile，未滿 → 生 tile frontier candidate。
2. **★通用 tile-resolver 拆兩類（§4 must-fix②）**：
   - (i) `find_nearest_terrain_tile(state, team, terrain_cond, reachable)` ＝ **純地形/物理地理**（`terrain==forest`/`material regen>0`）→ 比照 `constitution_gate:41` 公共地理 **`# gate-ok`** 全圖掃。
   - (ii) `find_nearest_known_tile(...)` ＝ **所有權/control**（unowned/我方控制 ＝ 動態狀態，踩 `invariants:192` 市集判例）→ 讀新建 **`team_tile_known` belief store**（禁全圖 god-view 掃）。
   - 可達 ＝ **belief-reachable**（感知鐵律，非全知 PathSystem live）。★模組必 `scripts/simulation/decision/`（GV_FILE_RE 涵蓋）。
3. **★新 `team_tile_known` belief store**（鏡射既有 `team_market_known` / `_harvest_market_known` 結構）：tile-discovery 兩源（親見 vision 半徑 bounded local scan + relay team_known 的 tile 訊息）→ 存 `state.team_tile_known`；禁新 RNG。
4. **★material 核心缺口鏈**（arc 原始動機，湧現示範）：`maintain_material` resource 前置未滿 + S2 買不到（無市場 candidate）→ 定位取得手段「採@forest」：需 forest outpost（location 前置 `terrain:forest`）→ 隊無 forest outpost → frontier「**移動到最近可達 forest tile**」candidate（到了下一 frontier ＝ 建 outpost 那裡，前置滿才 applicable → 湧現順序）；to_task ＝ 移動到該 tile（既有 move task/target=forest tile_pos）。★**委派**（派子隊 settle）＝ S5，別提前，S3 隊自己移動。
5. **util 護欄沿用 S2** `_candidate_util`（`GOAL_UTIL_CAP`+dev_coeff，絕境 forest 遠路折趨零 ＝ 不棄糧走遠路）。

## TDD
1. location handler 生 tile candidate（缺 material + 無 forest outpost + 買不到 → 移動 forest candidate）。
2. tile-resolver 兩類分流（地形查詢 vs control 查詢走不同源）。
3. `team_tile_known` belief 只存已發現 tile（非全圖）。
4. ★★**must-fix② constitution_gate 綠 ＝ 無新 god-view leak**（gv_mapscan detector 對 `find_nearest_known_tile` 讀 belief 非全圖；`find_nearest_terrain_tile` 純地形標 `# gate-ok`）。
5. **belief-reachable**（可達走 belief 非全知）。
6. **determinism 2 跑 byte-identical**（tile-resolver/belief harvest 禁 randf，tie-break tile_id）。

## 閘 + 紀律
- `constitution_gate` PASS（★must-fix② 關鍵：新 tile 查詢守 belief/地理分野）+ headless 0 new + determinism。
- ★**whole-system-first**：S3 只定位型 + material 缺口；人力/設施 build/子目標/折現/委派 = S4-S6 別提前（S3「建 outpost」的 build 動作若需 settle 機械 ＝ 接既有最小，別做 S5 委派）。
- 完成 = **systems + reviewer R²**（★reviewer 盯 must-fix② 地形/所有權拆分真守住否）→ `to:systems` 收驗 + S3 R²。
