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
- **`_dispatch_goal_delegate`（faction_ai:2806）改/擴 = 3 分支**：candidate 依型別路由——
  - **(i) founding**（建 new outpost，帶 `build_type`）→ 呼既有 `_dispatch_builder(state, team, target, build_type, level)`（`SubteamSystem.dispatch(TASK_CONSTRUCT)` + afford 1.5x + pop + caravan-load）。
  - **(ii) facility**（在自家 owned outpost 建 F，帶 `facility` 無 build_type）→ 呼既有 `_dispatch_facility_builder(state, team, own_outpost_pos, facility)`（faction_ai:2851，派子隊 **TASK_EXPAND** → `begin_subteam_construction` → `_subteam_upgrade_facility`）。
  - **(iii) 既有 build/settle delegate** → 沿用 SubteamSystem.dispatch。
- ★**forest tile 選**：`find_nearest_terrain_tile("forest")`（S3 既有 must-fix②(i) 純地理 gate-ok）；unowned 靠 `_dispatch_builder` `target_tile.construction_team_id!=-1` 自然擋（★**有代價非零代價**：目的地在子隊在途中被搶建→子隊撲空等 ~10天殭屍逾時釋放，faction_ai:1721 既有機制；非本刀新增，mining bootstrap 共用；S3 unowned track 不變）。

## 2b. ★must-fix①（reviewer R②）：S4 build_F 同款 TASK_BUILD 死路一併修
reviewer 親驗 `goal_resolver.gd` **兩處 build_F 也發 `{task:TASK_BUILD}`＝同款死路**（`TASK_BUILD` 不在 `_on_arrival`/`begin_subteam_construction` match）：
- **`:171`（`_resolve_build_facility` 前置2，隊在自己 tile 未建 → 建 new outpost）**：`{TASK_BUILD, team.tile_pos}` → **同 A1 founding**：改 founding candidate（delegate + build_type）→ `_dispatch_builder`。
- **`:178`（build_F action，全滿 → 在自家 owned outpost 建 facility）**：`{TASK_BUILD, own_tile.tile_pos, facility}` → **語意 = 既有 outpost 建設施非新建 outpost** → facility candidate（delegate + facility key）→ `_dispatch_facility_builder`（既有 TASK_EXPAND 路）。
- ∴ **一次修全三處 TASK_BUILD 死路**（S3 build-closure + S4 :171 + S4 :178），whole-system-first 免下輪重演「候選贏 argmax 但蓋不出」。

## 3. 執行閉環（湧現）
缺料 → founding candidate（派子隊 TASK_CONSTRUCT 到 forest）→ `_dispatch_builder` → 子隊 TASK_CONSTRUCT → `movement:291` 抵達 → `begin_subteam_construction:538` → `start_build`（civilian lv1 on forest tile）→ **forest outpost 真建成**（outpost_level>0）→ 該隊/faction 得 forest outpost → material harvest（positional）→ 缺料緩解 → build_F 設施。

## 4. 護欄 / 憲法 / 決定性
- **must-fix① util 護欄沿用**（founding candidate 走 `_candidate_util`，clamp < survival）。
- **afford/pop gate = 既有 `_dispatch_builder`**（material cost×1.5 + pop 門檻）——保留（whole measure 判 bootstrap 是否卡 chicken-egg，非本 slice 動）。
- 決定性（founding candidate 純狀態 + `_dispatch_builder` 既有，禁 randf；tie-break tile_id）。
- 憲法（founding=委派 rank-pool candidate，非 bespoke；constitution_gate 74 removed=0 守）。

## 5. TDD（★含執行端 + ★must-fix② 打真管線）
1. build-closure 生 founding candidate（缺料 + 無 forest outpost + forest tile 可達 → founding delegate candidate）。
2. ★★**執行端硬驗（must-fix② 真管線，非抄近似）**：**從隊真 material 缺口 `goal_state` 出發 → 呼 `GoalResolver.frontier_candidates` 拿真 candidate → 餵真 `_dispatch_goal_delegate`（測 founding/facility 型別判斷分支本身，非繞過直呼 `_dispatch_builder`）→ 子隊 TASK_CONSTRUCT → 抵達 → begin_subteam_construction → start_build → forest outpost 真建成（outpost_level>0）**。這打中 A1 原始壞掉的整段管線（candidate 生成 + argmax 選中 + delegate 型別判斷走對路 + 執行）。
3. ★**S4 build_F 執行端硬驗**（must-fix①）：(a) `:171` 自建 outpost → founding → `_dispatch_builder` → outpost 真建成；(b) `:178` build_F action → facility → `_dispatch_facility_builder` → **facility 真建成**（own outpost 該 facility level>0）。
4. TASK_BUILD 三處全移除（frontier_candidates 不再生任何 `{task:TASK_BUILD}` candidate）。
5. ★次要：`_delegate_variant`（`goal_resolver:121`）加 `if self_cand.get("delegate", false): return {}` 早退（founding/facility candidate 已 delegate，別再包一層委派的委派）。
6. must-fix① range 斷言（founding/facility candidate util < survival）。
7. determinism 2 跑 byte-identical + headless 0-new + constitution_gate 74 removed=0。

## 6. 待驗收 + 序
- 完成 = systems + reviewer R²（異質）。→ implementer → **focused 重 measure**（measurer：A1 真閉環 forest outpost 真建成 + material 真流入 holding + 缺料隊真蓋成設施；A4/B 下游 EXPAND/harvest/afford）→ QA 故事稽核（A1 鏈真走完逐 tick）→ blueprint release-pass → 升用戶。
- gate② residency 路3 = A1 修後獨立 followup。material 續 PARK 到 release-pass。

## 溯源
means-end whole A1 BLOCKER（blueprint 裁 + 用戶接受）；code 坐實 `begin_subteam_construction:538`/`_dispatch_builder:2597`；[[feedback_verify_execution_end]]；means-end HOW spec `2026-07-24-long-range-planning-means-end-HOW.md`。
