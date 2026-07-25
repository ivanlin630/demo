---
type: spec
owner: systems
topic: construction pipeline 可觀測性補洞（A1 stall 一階定位 + 不變量義務）
status: ready-for-impl
---

# Spec：construction pipeline 可觀測性補洞（A1 forest founding stall 一階 trace）

## 為何（root context）

A1 forest founding **仍 FAIL**：outpost_built 兩 seed 全程 0，但 founding dispatch 巨量（6080/1447）＝子隊真派、真抵達、start_build 真 start（construction_team_id 設），**卻從不完工**。QA 精準定位卡在「施工啟動後~完工前」窗口（Team49 抵達(9,14)✓ + start_build✓，但 tick43200 遠超工期仍未完工、(9,14) 從不進完工清單；Team49 沒死、跑去 trade/外交/賣 material）。

systems code-trace 到極限（見下因果鏈），**反覆得「該 work」但 measure=0**＝必有 runtime 態我 code 判不出。**根因**：construction pipeline（start_build→_tick_construction→_complete/timeout→_try_resume_construction）**全無 Probe tap** → 違「全量暫態可觀測性」不變量（用戶定 2026-07-14，憲法同級）→ QA 與 systems 都在盲區猜一階、無法坐實。

∴ **先補可觀測性**（不變量義務，永久 tap 非暫時診斷）→ measurer 一跑定位一階實際卡段 → 一次修全部卡點（別 whack-a-mole，blueprint 明令）。

## systems code-trace 已坐實（因果鏈候選群，供對照 tap 數據）

1. **`_tick_construction`（outpost_system.gd:258-275）進度綁「施工隊持續在格 current_task==TASK_BUILD」**：每 tick for-loop 找同格 `TASK_BUILD("建設")` 隊才 `-= maxi(pop,1)` 倒數；`active_team==null` → return 暫停（非 tile 自倒數）。施工隊任何離格/改 task → 進度停。
2. **task 名族群**：`TASK_BUILD:="建設"`(16) vs `TASK_CONSTRUCT:="建造"`(33) 是兩 task。子隊 dispatch=TASK_CONSTRUCT，抵達 `begin_subteam_construction`→`start_build` 尾 `transition("建設"=TASK_BUILD, PRIO_DISPATCH)`（outpost_system.gd:390）才轉。**若 transition 被 guard 攔（task_arbiter.gd:116 `task_priority>=PRIO_THREAT and priority<task_priority`）→ current_task 留 TASK_CONSTRUCT → _tick_construction 認 TASK_BUILD 找不到 → 永不倒數**（一階最強候選，需 tap 確認 transition 後實際 current_task/priority）。
3. **子隊施工保護**：`_evaluate_subteam`(1712) 對 sub TASK_BUILD 1717 `return 不打斷`；但若 current_task 非 TASK_BUILD（見#2）→ 走 1721 CONSTRUCT 分支 → move_target==-1 已抵達 → 10 天 timeout → **release/merge** → 子隊變 IDLE → 被 trade 分派挑 → 跑 trade（**符合 QA 見 Team49 跑 trade**）。
4. **召回 `_try_resume_construction`（faction_ai:2742）對 remote/founding 荒地失效**（確定 code 缺，不需 runtime）：`is_owner = t.team_id == tile.outpost_owner`，founding 荒地 `outpost_owner==-1`（未建成，owner 只在 _complete_construction 才 set）→ is_owner 恆假；`resident_here` 需同 faction + TAG_PRODUCE + 在場 → founding 子隊難滿足；且 `days_left<3 不復工`。∴ 施工隊一旦離格 → 召不回。**解釋既有 own-outpost facility 21/31 成功（owner 在場可當 resume worker）vs remote/荒地 0/N**。

## 要做（純觀測，守觀測禁 RNG）

補 construction pipeline permanent `Probe` tap。**每個 tap 禁耗 global RNG（randf/randi）**（memory `feedback_observer_no_global_rng`，release 只認中性世界，三跑 byte-identical 驗）。tap 走既有 `Probe.bump`/`Probe.add_amount`/`SpecimenTracer`，`if Probe.enabled` gate。

### tap 點（逐段）

1. **start/facility build 成功後**（`start_build`:390 / `_subteam_upgrade_level`:412 / `_subteam_upgrade_facility` transition 後 / demolish:467）：
   `Probe` tap `{tile_pos, construction_team_id, current_task_after, task_priority_after, action}` — 確認 transition 是否真讓 current_task 變 TASK_BUILD（#2 一階驗）。若 current_task≠TASK_BUILD → 直接坐實 transition 被攔。
2. **`_tick_construction`**：
   - `active_team` 找到 → `Probe.bump("construct.progress")` + tap `{tile_pos, ticks_left, active_team_id, pop}`（進度真動否）。
   - **`active_team==null`（stall，關鍵）** → tap `{tile_pos, construction_team_id, 該隊 current_task, 該隊 tile_pos, 該隊 task_reason}` — **揭施工隊去向**（一階根：它跑哪、被啥 task_reason 改）。
3. **`_complete_construction`**：`Probe.bump("construct.complete")` + tap `{tile_pos, action, outpost_level/facility_level}`（已有 print 則加 Probe）。
4. **`check_construction_timeout` cancel**：`Probe.bump("construct.timeout_cancel")` + tap `{tile_pos, 停滯 tick 數}`。
5. **`_try_resume_construction`**：attempt tap `{tile_pos, candidates_count}` + 每 reject 原因分類 bump（`resume.reject_owner`/`resume.reject_resident`/`resume.reject_starving`/`resume.reject_combat`）+ success tap `{worker_id}` — 揭召回為何失效（#4 二階驗）。

### 交付

- headless 0-new + gate 74 removed=0 + **determinism 三跑 byte-identical**（觀測禁 RNG 硬驗）。
- handback `to:measurer`：跑 A1 focused（seed1337/42，6mo，base=加 tap 後）→ dump construction pipeline tap 數據，**聚焦定位一階**：start_build 後 current_task 實際值（是否 TASK_BUILD）+ stall 時施工隊去向（task_reason）+ 召回 reject 原因分布。→ 數據 `to:systems` 判一階 → systems 一次修全部卡點。

## 不做（本刀純觀測，不修行為）

修行為（latch/召回放寬/tile 自倒數）**待 tap 數據定位一階後**由 systems 出修 spec（whole-system-first：一階+二階一次修，別分批）。本刀只補 tap。
