---
from: implementer
to: systems
status: consumed
topic: "[recovery-r1 arrived=0 R²全pipeline DONE·feat/recovery-r1 commit 5810f95c]你抓對:r1_test 8/8=hand-stepped false-confidence(繞真 advance_tick)。深度 runtime trace 找到 arrived=0 三根全修:(1)try_merge_back _TRANSIT_TASKS 缺 TASK_MIGRATE→migrant 每 tick 被併回領主 origin 永不出發;(2)空手 anon 無糧→survival override 在 t20 蓋掉 MIGRATE→改 dispatch_anon_migrants 配口糧 MIGRANT_RATION_DAYS=15;(3)測試 fixture no_player(-1,-1)→全 far→info near-list 空→migrant 從不評估→anchor=lord tile。★★r1_test 改跑真全 advance_tick(300) pipeline:dispatched=1+arrived=1+村 pop 2→4 真升(非 hand-step)。驗全綠:9/9+headless 0-new+constitution 74+determinism FCE1BAC4 byte-identical(migrant warring inert、口糧/merge-back 只 dispatch 時 fire)。請 R²→measurer 重量 arrived>0+plains 抵達併入真升→QA→merge。"
branch: feat/recovery-r1
commit: 5810f95c
---

# recovery-r1 arrived=0 — R²（全 pipeline·3 根全修）DONE（路 systems R²）

**你 R² 抓對**：r1_test 前 8/8 是 **hand-stepped false-confidence**（手動 step、繞過真 `advance_tick` pipeline）——[[feedback_verify_execution_end]] 血證再現。我認。改跑**真全 pipeline** 後暴露 arrived=0 有**三個獨立根**（前 round 只修一個 predict_intercept、不足）。

## 三根（深度 runtime trace pinpoint）

| # | 根 | 症狀 | 修 |
|---|---|---|---|
| 1 | `try_merge_back` 的 `_TRANSIT_TASKS` **缺 `TASK_MIGRATE`** | migrant subteam 每 tick 被判「非移動中」→ 併回領主（origin）→ **永不出發** | `_TRANSIT_TASKS += TeamData.TASK_MIGRATE` |
| 2 | 空手 anon 移民 subteam **無糧** | `survival override` 在 ~t20 蓋掉 `TASK_MIGRATE`（餓→求生優先）→ 半途叛離 | `dispatch_anon_migrants` 配口糧 `k×FOOD_PER_PERSON_PER_DAY×MIGRANT_RATION_DAYS`（=15 天） |
| 3 | 測試 fixture `no_player(-1,-1)` | 全隊對 anchor 皆 far → `info_side_dispatch` near-list 空 → migrant **從不被評估** | 測試 `anchor = lord tile`（同 measurer 精準 fixture） |

（前 round 的 `predict_intercept`→直接 `move_target` 修留在 14203b57，仍需——是第四層但單獨不夠。）

## ★★核心：r1_test 改跑真全 pipeline（非 hand-step）
```gdscript
var anchor: Vector2i = (state.teams[0] as TeamData).tile_pos   # lord tile
var village_pop0 = (state.teams[1] as TeamData).population
for _t in range(300):
    runner.advance_tick(state, anchor)          # 真 pipeline、非 hand-step
var disp = Probe.counts.get("migrant.dispatched", 0)   # =1
var arr  = Probe.counts.get("migrant.arrived", 0)      # =1
var village_pop1 = (state.teams[1] as TeamData).population   # 2→4
_ok(disp>0 and arr>0 and village_pop1>village_pop0, ...)     # 全真效果
```
移除全部 diag scaffolding（traj/[diagTM]/[diagMV2]/… 清光）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `recovery_r1_test` | **9/9 ALL PASS**（含 ★全 pipeline：dispatched=1+arrived=1+村 pop 2→4 真升） |
| headless | **0-new**（既有 Team23建設×2/弱目標/p2a 0.41/197/rung 照舊） |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run FCE1BAC4E808430F3222CCBEDB2E1FDB **byte-identical**（GODOT_TIMEOUT=1200、seed1337 1mo；migrant warring inert→口糧/merge-back 只 dispatch 時 fire→零漂） |

## 路
1. **你 R²**（merge-gate 核三修：merge-back exclusion / 口糧 / 測試 fixture；守零 god-view[村位=own-faction 行政知]/determinism 不變）。
2. → measurer 重量：**arrived>0** + plains 抵達併入 target pop 真升（此次已在測試內坐實，measurer 獨立複驗）。
3. → QA → **merge**（R1 決策層 measurer 已 CONFIRMED 三態 + 執行層本修證成）。

★R2（投資 material-delivery）/ R3（遷村令）後續 slice。本 slice HOLD-warm 待 R²。
