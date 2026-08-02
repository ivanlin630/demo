---
from: systems
to: implementer
status: consumed
topic: "[實作·construction pipeline 可觀測性補洞·純觀測 slice·R²CLEAN·spec=2026-07-25-construction-pipeline-observability-A1-stall-trace.md] A1 forest founding 仍 FAIL(outpost_built 兩 seed 0,dispatch 6080/1447 巨量但 completion 0)。QA 定位卡『施工啟動後~完工前』。construction pipeline 全無 Probe tap→違全量暫態可觀測性不變量→盲區猜一階。加 permanent Probe tap 定位一階。★純觀測禁改行為。閘:headless 0-new+gate 74 removed=0+★三跑 byte-identical(觀測禁 RNG 硬驗)。→handback to:measurer 跑 A1 focused 定位一階。"
branch: feat/construction-obs-tap
---

# 實作：construction pipeline 可觀測性補洞（A1 stall 一階定位）

R² CLEAN（reviewer 親驗因果鏈候選準確 + tap 對症）。**純觀測 slice**，照 spec 加 permanent Probe tap。

## spec
`docs/superpowers/specs/2026-07-25-construction-pipeline-observability-A1-stall-trace.md`（完整 tap 點 + 因果鏈候選群 file:line，讀它）。

## 核心（spec §要做）
construction pipeline（`outpost_system.gd` start_build/_tick_construction/_complete/timeout + `faction_ai:2742` _try_resume）**全無 Probe tap** → 補 permanent tap。

### tap 點（逐段，spec §tap 點）
1. **start/facility build 成功後**（start_build:390 / _subteam_upgrade_level:412 / _subteam_upgrade_facility / demolish:467 transition 後）：tap `{tile_pos, construction_team_id, current_task_after, task_priority_after, action}` — ★確認 transition 是否真讓 current_task 變 TASK_BUILD（一階#2 驗，最關鍵）。
2. **`_tick_construction`**：active_team 找到 → `Probe.bump("construct.progress")` + tap `{tile_pos, ticks_left, active_team_id, pop}`；**active_team==null（stall）** → tap `{tile_pos, construction_team_id, 該隊 current_task, 該隊 tile_pos, 該隊 task_reason}` — ★揭施工隊去向（一階根）。
3. **`_complete_construction`** → `Probe.bump("construct.complete")` + tap。
4. **`check_construction_timeout` cancel** → `Probe.bump("construct.timeout_cancel")` + tap `{tile_pos, 停滯 tick}`。
5. **`_try_resume_construction`** → attempt tap `{tile_pos, candidates_count}` + 每 reject 原因 bump（`resume.reject_owner`/`resume.reject_resident`/`resume.reject_starving`/`resume.reject_combat`）+ success tap `{worker_id}` — ★召回為何失效（二階#4 驗）。

## ★硬約束
- **觀測禁 RNG**（memory `feedback_observer_no_global_rng`，第 3 次同族）：Probe tap **禁耗 randf/randi**，走 `if Probe.enabled` gate。**三跑 byte-identical 硬驗**（觀測中性）。
- **純觀測不改行為**：無 side-effect 改 state/決策/資源。
- 閘：headless `=== DONE ===` 0-new SCRIPT ERROR + `constitution_gate` sites=74 removed=0 + determinism 三跑 byte-identical。
- ★報 tap 數量前實際跑讀 `=== DONE ===`（別憑印象，流程項）。

## 交付
handback `to:measurer`：跑 A1 focused（seed1337/42，6mo，base=加 tap 後 branch）→ dump construction pipeline tap，**聚焦定位一階**：①start_build 後 current_task 實際值（是否 TASK_BUILD／被 guard 攔留 TASK_CONSTRUCT）②stall 時施工隊去向（task_reason）③召回 reject 原因分布。→ 數據 to:systems 判一階 → systems 出行為修 spec（一次修全部卡點）。

## 不做
行為修（latch／召回放寬／tile 自倒數）**待一階定後** systems 出 spec。本刀只 tap。
