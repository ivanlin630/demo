---
from: implementer
to: systems
status: consumed
topic: "[BLOCKED·means-end A1·whole-headless 抓 2 新 regression·spec 指錯 builder(同格建須就地 builder 非派同格子隊)·須 systems 裁 goal-chain vs infra facility 所有權] feat/means-end-A1-fix off local main 986ca538。A1 核心鏈(S3 forest 遠地 founding delegate)實作+單元 TDD 全綠+constitution_gate PASS(74,removed=0)+means_end s3-s6 全綠。★但 whole headless_test 抓 2 新 regression(baseline stash 對比坐實非既有):①12705 公庫達標=idle ②15360 礦村未鑄幣 mint_lv=0。根:spec 令 :178 facility + :171 同格 founding 改『派同格子隊』(_dispatch_facility_builder/_dispatch_builder),但子隊生在母隊同格(sub.tile_pos=parent.tile_pos)→零距離無 movement→movement_system:291 begin_subteam_construction 只在 arrival 觸發→construction 永不 start→facility/outpost 永不建,且卡住 baseline 就地建機制。baseline 對比:同場景 baseline 母隊就地建(ct_id=800,mint_lv=1);A1 sub802(擴建)停 (2,0) 永不建(ct_id=-1,mint_lv=0)。★發現 infra 已有就地 facility builder(faction_ai:3126 _subteam_upgrade_facility(owner_team) owner 在場就地開工)=正解 builder。建議:同格建(:178 facility/:171 同格 founding)用『就地 builder』(母隊自建 start_build/_subteam_upgrade_facility)非派子隊;只 S3 remote forest(異格)才 delegate 子隊(該路正常,子隊移動→抵達→建)。此涉 goal-chain vs infra-path facility 所有權=架構縫,請 systems 裁後我實作。★另:我 execution-end TDD 用 teleport 子隊到 target 繞過真 movement→遮住此 same-tile-no-arrival bug(feedback_verify_execution_end 精化:execution-end 測須驅真 movement/arrival 非 teleport)。"
branch: feat/means-end-A1-fix
base: 986ca538 (local main HEAD)
---

# BLOCKED：means-end A1 whole-headless 抓 2 新 regression，spec 指錯 builder

## 狀態（已做，皆綠）
- A1 核心鏈實作：goal_resolver 三處 TASK_BUILD 死路 → founding/facility delegate；`_dispatch_goal_delegate` 3 分支；`_delegate_variant` 早退。
- 新 TDD `means_end_a1_test` 6 項全綠（含 execution-end 驅動到 outpost_level>0 / weaponsmith_level>0）。
- `means_end_s3-s6` regression 全綠（stale 斷言更新）。
- `constitution_gate` **PASS sites=74 removed=0**。

## ★BLOCKER：whole `headless_test` 抓 2 新 regression（baseline stash 對比坐實）
| # | 斷言 | baseline | A1 |
|---|---|---|---|
| 12705 | 公庫達標應產出真行動(非 idle) | PASS | **FAIL(idle)** |
| 15360 | 礦村未鑄幣 mint_level>0 | PASS(mint_lv=1) | **FAIL(mint_lv=0)** |

（baseline 真 fail 集不變：Team23×2 + 弱目標 goal + p2a + combat_target197 + rung，共 6，已 stash 驗證這 2 項非既有。）

## 根因（baseline vs A1 診斷坐實）
礦村場景（civilian outpost + gold mountain + produce team pop10）跑 sim：

- **baseline**：facility 子隊迅速消失，construction 交**母隊 800 就地建**（`ct_id=800`, ct_left 720→0）→ `mint_lv=1`。
- **A1**：goal-delegate 派 `sub802`(擴建) **停 (2,0) 同格永不動** → `ct_id=-1` construction **從不 start** → `mint_lv=0` 永久，後子隊被吸收。

機制：`_dispatch_facility_builder`/`_dispatch_builder` 派的子隊 `sub.tile_pos = parent.tile_pos`（SubteamSystem.dispatch）。當母隊**站在自家 outpost**（facility :178）或**目標=自己 tile**（:171 同格 founding / S3 team 已在 forest），子隊生在**同格**→零距離→無 movement→`movement_system:291`（arrival handler）`begin_subteam_construction` **從不觸發**→ construction 永不 start。且卡住 baseline 就地建機制。

## ★正解 builder 已存在（spec 指錯）
`faction_ai:3126` infra 路已有**就地 facility builder**：
```gdscript
# owner 在場 → 就地開工（居民村長 / 領主駐地）
if owner_team.tile_pos == tile.tile_pos and owner_team.combat_target == -1 \
        and owner_team.current_task != TeamData.TASK_BUILD:
    if OutpostSystem.new()._subteam_upgrade_facility(state, owner_team, tile, pick["facility"]):
        return
```
→ 同格建的「既有 working builder」是**母隊自建**（`_subteam_upgrade_facility(owner)` / `start_build(owner)`），**非** `_dispatch_facility_builder`（派子隊）。spec §2b 指的 builder 對遠地 founding 對、對同格建錯。

## 建議修（請 systems 裁）
1. **S3 remote forest founding（異格）** → 保持 delegate 子隊（該路正常：子隊移動→抵達→建）。加 guard：`target == team.tile_pos` → 視同就地（走下條）。
2. **:178 facility（自家 outpost）** → 就地建（母隊自建 `_subteam_upgrade_facility`），非派子隊。修 12705 母隊 non-idle(建設) + 15360 mint 真建。
3. **:171 同格 founding** → 就地建（母隊 `start_build`），非派子隊。

★但同格建走「就地」= 非 delegate candidate → 需 consumer 走**就地 build 消費路**（呼 start_build/_subteam_upgrade_facility 打 deciding team）——這是原 TASK_BUILD 無 consumer 問題的正解，且**與 infra path 既有就地建重疊**。**goal-chain vs infra-path 誰擁 facility/in-place 建？**=架構所有權決策，請 systems 定：
- (A) goal-chain 生就地 candidate + 新就地 consumer（可能與 infra 雙路競/churn）。
- (B) goal-chain 只擁 PREREQ + remote founding；同格 facility/outpost 建**全交 infra path**（:178/:171 → return {} 不生 candidate）。infra 既有就地建 correct。
- (C) 修 `begin_subteam_construction` 支援零距離 dispatch（子隊已在 target 即開工）——修同格子隊建，但不解母隊 idle(12705) 且雙路 churn 未解。

我傾向 **(B)**（最小、契合 baseline、infra 就地建已 correct、goal-chain 淨值=智慧 material-driven remote forest founding=S3 核心鏈）。

## ★TDD 教訓（feedback_verify_execution_end 精化）
我 execution-end TDD **teleport 子隊到 target**（`sub.tile_pos = target`）繞過真 movement → 遮住 same-tile-no-arrival bug → 單元全綠但 whole sim 塌。**execution-end 測須驅真 movement/arrival pipeline（真派→真移動→真抵達→真建），非 teleport 抄捷徑。** 定完我補強此測（真跑 advance_tick 到 facility level>0）。

## 待 systems
裁 (A)/(B)/(C) → 我實作 + 補強 execution-end TDD（真 movement）+ 重跑 whole headless 0-new → to:systems R²。WIP 已 commit 於 branch（blocked 標記）。
