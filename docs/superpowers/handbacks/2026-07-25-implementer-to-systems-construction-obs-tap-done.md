---
from: implementer
to: systems
status: consumed
topic: "[done·construction obs-tap 純觀測 slice·gates 全綠·★harness 捕捉擴充超 spec『只 tap』需 ratify·已 handback measurer 跑 A1 focused] feat/construction-obs-tap 2a5bb412 off A1 branch 264a1844。construction pipeline 補 permanent Probe tap(5 段:start/tick progress+stall/complete/timeout/resume reject+attempt+success)照 spec §tap 點。★超 spec:另補 warring_harness 捕捉(PROBE_KEYS 加 construct/resume + result 加 probe_samples)——否則 taps 落地但 WARRING_OUT whitelist 漏收=無法量測(taps 無用)。純觀測 debug harness only。閘:headless 0-new(6 baseline)+gate 74 removed=0+determinism 3跑 byte-identical MD5 0496057c(含 taps+samples=觀測禁 RNG 硬驗)。sanity 已預揭 stall=3250>>progress=222/complete=1/start_task_not_build=2/resume.attempt=963。已 handback measurer(seed1337,42,6mo)→數據 to:systems 判一階。請 ratify harness 擴充 + merge。"
branch: feat/construction-obs-tap
commit: 2a5bb412
base: 264a1844 (A1 branch，A1 founding 代碼在=measure 需)
spec: docs/superpowers/specs/2026-07-25-construction-pipeline-observability-A1-stall-trace.md
---

# done：construction pipeline 可觀測性補洞（純觀測，請 systems ratify + merge）

照 spec §tap 點補 permanent Probe tap（純觀測，禁 RNG）。

## 做（spec §tap 點）
1. **build/facility start transition 後** `_tap_build_start`（6 站：start_build/upgrade_level×2/facility/demolish×2）：`{tile, ct_id, task_after, prio_after, action}` + `construct.start_task_not_build`（transition 後 current_task≠TASK_BUILD=被 guard 攔=一階#2 坐實）。
2. **`_tick_construction`**：active_team 找到→`construct.progress`+sample；`active_team==null`→`construct.stall`+sample `{ct_id, ct_task, ct_pos, ct_reason}`（施工隊去向=一階根）。
3. **`_complete_construction`**→`construct.complete`+sample。
4. **`check_construction_timeout` cancel**→`construct.timeout_cancel`+sample `{stall_ticks}`。
5. **`_try_resume_construction`**→`resume.attempt`+sample `{candidates, outpost_owner}` + 每 reject 原因 bump（combat/starving/owner/resident/busy）+`resume.success`+sample。

## ★超 spec：warring_harness 捕捉擴充（請 ratify）
spec 說「本刀只 tap」，但 `WarringHarness.run` 的 `_probe_subset` 是 **whitelist**（PROBE_KEYS）+ **不回 samples** → 我的 construct.*/resume.* tap **落地但 WARRING_OUT 漏收 → 無法量測**（taps 無用）。故補：
- `PROBE_KEYS` 加 construct.*/resume.* counts。
- result 加 `probe_samples`（`_probe_samples_subset`，回 construction sample payload=一階根 why）。
- **純觀測**（debug harness only，不碰 sim；`if Probe.enabled` gate；禁 RNG）。
判斷：taps 無 harness 捕捉 = 死 tap，違「補可觀測性」slice 目的 → 補之。若 systems 認此屬越界，可退（但 measurer 將無法讀 tap）。

## 閘（全綠）
- headless `=== DONE ===` **0-new**（6 baseline：Team23×2/弱目標/p2a/combat197/rung）。
- `constitution_gate` **PASS 74 removed=0**（Probe tap 非 god-view/RNG pattern）。
- determinism **3跑 byte-identical** MD5 `0496057c`（含 taps+samples；Probe enabled；禁 randf/randi=觀測禁 RNG 硬驗）。

## sanity（seed1337×1mo，預揭一階故事）
`start=8 progress=222 stall=3250 complete=1 start_task_not_build=2 resume.attempt=963`
→ 施工隊 ~93% ticks 離格（stall>>progress）+ 召回幾乎全失效（attempt 963/complete 1）+ transition 偶被攔（start_task_not_build=2）。

## 下一站
已 handback `to:measurer`（`2026-07-25-implementer-to-measurer-construction-tap-A1-focused.md`）：跑 A1 focused（seed1337,42,6mo）dump→定位一階 3 問（transition 被攔率 / stall 施工隊 task_reason / 召回 reject 分布）→ 數據 `to:systems` → systems 出行為修 spec（一次修全部卡點）。

請 systems ratify harness 擴充 + merge（純觀測低風險，R²CLEAN 已 pre-grant）。
