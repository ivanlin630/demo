# means-end A1 forest founding 修 — HOW spec（systems 2026-07-25，用戶核准）

> **定位**：means-end whole 驗收 A1 BLOCKER 修（blueprint 裁 + 用戶接受序=『修』）。means-end 執行端 wrong-task bug：forest founding candidate 生了但 outpost 建不成＝假閉環。
> **前提已 code 坐實**（免 R①）：`begin_subteam_construction`（outpost_system:530-544）建 new outpost 正確 task = `TASK_CONSTRUCT`；`TASK_BUILD` 無 new-outpost consumer；既有 `_dispatch_builder`（faction_ai:2597）= working「派建造子隊 TASK_CONSTRUCT + build_type」路。
> **紀律**：★驗執行端（forest outpost 真建成，[[feedback_verify_execution_end]]）；憲法（委派=WHAT §4 選項）；決定性（禁 randf）。

## 1. 根（code 坐實）
means-end S3 build-closure（`goal_resolver._resolve_resource_prereq` 採@地形手段）+ S5 delegate 的 to_task = **`TASK_BUILD`**（target=team.tile_pos，隊自己 in-place）。但：
- `TASK_BUILD` **不在** `begin_subteam_construction` match（只 TASK_CONSTRUCT/UPGRADE/EXPAND）；`subteam:72` TASK_BUILD「讓正常邏輯＝不建只 merge」；隊自己 TASK_BUILD 無 handler；`start_build` 只 outpost 內部+玩家 caller。
- ∴ forest outpost **建不成** → 缺料鏈：缺料→移動 forest→到了→candidate（TASK_BUILD）argmax 贏→**建不成→隊卡→material 還缺** = A1 假閉環。

## 2. 修（複用既有 working 路 `_dispatch_builder`）
- **means-end forest founding = 派建造子隊**（founding new outpost = 委派 act 非 self-build；隊自己 build new outpost 無路）＝合 WHAT §4。
- **S3 build-closure candidate 改**（`_resolve_resource_prereq` 採@地形手段）：
  - 現 3 態（移動 TASK_MIGRATE / 建 TASK_BUILD in-place / satisfied）。
  - **改**：缺料 + 無該地形 outpost → 生 **founding candidate**（`delegate:true`）：`to_task = {task: <founding marker>, target: nearest forest tile, build_type: "civilian", level: 1}`。**移除隊自己 in-place TASK_BUILD frontier**（無 build 路）；隊自己移動 TASK_MIGRATE frontier 亦移除（改派子隊去建，隊自己不用先移動）。
- **`_dispatch_goal_delegate`（faction_ai:2806）改/擴**：candidate 若 founding（帶 build_type）→ **呼既有 `_dispatch_builder(state, team, target, build_type, level)`**（內部：afford 1.5x gate + pop 門檻 + advisor + `SubteamSystem.dispatch(TASK_CONSTRUCT, target)` + `task_extra_data{build_type, level}` + caravan-load）。非 founding（既有 build/settle delegate）→ 沿用既有 SubteamSystem.dispatch。
- ★**forest tile 選**：`find_nearest_terrain_tile("forest")`（S3 既有 must-fix②(i) 純地理 gate-ok）；unowned 靠 `_dispatch_builder` 的 `target_tile.construction_team_id`/`start_build` 目標格已有據點自然擋（S3 unowned track 不變）。

## 3. 執行閉環（湧現）
缺料 → founding candidate（派子隊 TASK_CONSTRUCT 到 forest）→ `_dispatch_builder` → 子隊 TASK_CONSTRUCT → `movement:291` 抵達 → `begin_subteam_construction:538` → `start_build`（civilian lv1 on forest tile）→ **forest outpost 真建成**（outpost_level>0）→ 該隊/faction 得 forest outpost → material harvest（positional）→ 缺料緩解 → build_F 設施。

## 4. 護欄 / 憲法 / 決定性
- **must-fix① util 護欄沿用**（founding candidate 走 `_candidate_util`，clamp < survival）。
- **afford/pop gate = 既有 `_dispatch_builder`**（material cost×1.5 + pop 門檻）——保留（whole measure 判 bootstrap 是否卡 chicken-egg，非本 slice 動）。
- 決定性（founding candidate 純狀態 + `_dispatch_builder` 既有，禁 randf；tie-break tile_id）。
- 憲法（founding=委派 rank-pool candidate，非 bespoke；constitution_gate 74 removed=0 守）。

## 5. TDD（★含執行端）
1. build-closure 生 founding candidate（缺料 + 無 forest outpost + forest tile 可達 → founding delegate candidate）。
2. ★★**執行端硬驗**：founding candidate 執行 → `_dispatch_builder` → 子隊 TASK_CONSTRUCT → **forest outpost 真建成**（合成/integration test：子隊抵達 forest tile → begin_subteam_construction → start_build → outpost_level>0）。**這是 A1 假閉環的直接迴歸**（若當初驗這就抓）。
3. TASK_BUILD frontier 移除（不再生 TASK_BUILD candidate）。
4. must-fix① range 斷言（founding candidate util < survival）。
5. determinism 2 跑 byte-identical。
6. headless 0-new + constitution_gate 74 removed=0。

## 6. 待驗收 + 序
- 完成 = systems + reviewer R²（異質）。→ implementer → **focused 重 measure**（measurer：A1 真閉環 forest outpost 真建成 + material 真流入 holding + 缺料隊真蓋成設施；A4/B 下游 EXPAND/harvest/afford）→ QA 故事稽核（A1 鏈真走完逐 tick）→ blueprint release-pass → 升用戶。
- gate② residency 路3 = A1 修後獨立 followup。material 續 PARK 到 release-pass。

## 溯源
means-end whole A1 BLOCKER（blueprint 裁 + 用戶接受）；code 坐實 `begin_subteam_construction:538`/`_dispatch_builder:2597`；[[feedback_verify_execution_end]]；means-end HOW spec `2026-07-24-long-range-planning-means-end-HOW.md`。
