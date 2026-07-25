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

## 2b. ★must-fix①（reviewer R②）+ ★★systems 裁訂正（implementer BLOCKED 揭 same-tile-no-arrival）
reviewer 親驗 `goal_resolver.gd` 兩處 build_F 也發 `{task:TASK_BUILD}`＝同款死路。**但我原 spec 令兩處都「派子隊」＝錯**（implementer whole-headless 抓 mint_lv=0 regression）：**same-tile 建（own outpost/隊站的 tile）派同格子隊 → 子隊零距離無 movement → `begin_subteam_construction` 只在 arrival 觸發 → 永不 start → 建不成 + 卡 baseline 就地建**。★正解 = **same-tile 用就地 builder（母隊自己），remote 才派子隊**（複用既有 infra 分流 `_evaluate_infrastructure`/`_dispatch_facility_builder`：`team.tile_pos==tile → _subteam_upgrade_facility(就地) else _dispatch_facility_builder(派子隊)`）。

- **`:178`（build_F action，自家 owned outpost 建 facility＝same-tile）**：facility candidate → **就地/派子隊分流**：owner 在場（`team.tile_pos == own_outpost tile`）→ `OutpostSystem._subteam_upgrade_facility(state, team, tile, facility)`（就地開工）；不在場 → `_dispatch_facility_builder`（派子隊）。**非一律派子隊**。
- **`:171`（前置2，隊站空 tile 建 new outpost＝same-tile founding）**：★**移除該 candidate**（回 S4 facility-type-mismatch known_issues followup，non-A1-core）——same-tile outpost founding 無母隊就地 outpost-build 路，且它是「隊有 civilian 想建 mil-facility → 需 mil outpost」的 facility-type-mismatch 補（S4 followup 範疇非 A1 core）。build_F 的 facility-outpost-type 前置未滿 → 靜默（followup 不變）。
- **S3 forest remote founding（異格）**：delegate `_dispatch_builder` **不變**（remote 子隊移動→抵達→begin_subteam_construction→建，該路正常，implementer s3 綠）。
- ∴ **A1 修 scope**：S3 remote forest founding（delegate）+ S4:178 facility（就地/派子隊分流）。:171 移除（followup）。goal-chain 建 facility 複用既有 infra owner-在場分流＝所有權縫收斂（means-end 想建 → 接 infra path builder，非另立子隊路）。

## 3. 執行閉環（湧現）
缺料 → founding candidate（派子隊 TASK_CONSTRUCT 到 forest）→ `_dispatch_builder` → 子隊 TASK_CONSTRUCT → `movement:291` 抵達 → `begin_subteam_construction:538` → `start_build`（civilian lv1 on forest tile）→ **forest outpost 真建成**（outpost_level>0）→ 該隊/faction 得 forest outpost → material harvest（positional）→ 缺料緩解 → build_F 設施。

## 4. 護欄 / 憲法 / 決定性
- **must-fix① util 護欄沿用**（founding candidate 走 `_candidate_util`，clamp < survival）。
- **afford/pop gate = 既有 `_dispatch_builder`**（material cost×1.5 + pop 門檻）——保留（whole measure 判 bootstrap 是否卡 chicken-egg，非本 slice 動）。
- 決定性（founding candidate 純狀態 + `_dispatch_builder` 既有，禁 randf；tie-break tile_id）。
- 憲法（founding=委派 rank-pool candidate，非 bespoke；constitution_gate 74 removed=0 守）。

## 5. TDD（★含執行端 + ★must-fix② 打真管線）
1. build-closure 生 founding candidate（缺料 + 無 forest outpost + forest tile 可達 → founding delegate candidate）。
2. ★★**執行端硬驗（must-fix② 真管線，非抄近似）**：**從隊真 material 缺口 `goal_state` 出發 → 呼 `GoalResolver.frontier_candidates` 拿真 candidate → 餵真 `_dispatch_goal_delegate`（測 founding/facility 型別判斷分支本身，非繞過直呼 `_dispatch_builder`）→ 子隊 TASK_CONSTRUCT → ★★驅真 movement/arrival（**非 teleport 子隊到 target**）→ begin_subteam_construction → start_build → forest outpost 真建成（outpost_level>0）**。這打中 A1 原始壞掉的整段管線。★**驅真 movement 是硬條件**：implementer 首版用 teleport 繞過真 movement→遮住 same-tile-no-arrival bug（[[feedback_verify_execution_end]] 精化：execution-end 測須驅真 movement/arrival 觸發 begin_subteam_construction，teleport 假通過）。remote founding 走真移動抵達；same-tile facility 就地 builder（無 movement）也驗真建成。
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
