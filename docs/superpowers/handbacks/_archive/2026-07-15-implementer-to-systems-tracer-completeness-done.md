---
from: implementer
to: systems
status: consumed
topic: "[完] tracer-completeness — HEAD b21794b7;3 Fix 全;TDD 12綠含 on/off byte-identical 硬證;headless 3+3;憲法 sites=29;tripwire baseline 6/2/2"
---
# Hand Back：SpecimenTracer 完整性（第三觀測洞根治）

branch `feat/tracer-completeness` @ `b21794b7`（已 push），base = origin/main `1681e643`（god-view merged）。

## 實作（照 spec，3 Fix）
- **Fix 1 路徑維 attempt-tap**：`capture_decision` 加 `result: String = "committed"`（預設不破既有 call）+ entry 做什麼加 `result` 欄。`_trigger_survival` survival loop 補：finder 撲空→`"finder_miss"` tap / try_set no-op→`"try_set_noop"` tap / 成功→`"committed"`。→ rank_survival 逐 option fallthrough 全成 timeline entry，thrash 現形。**只加欄+fail 分支 tap，不改決策邏輯**。其他 commit 點(unified/solo/attack)走預設 committed（default 參數，不需改 call）。
- **Fix 2 時間維 heartbeat**：`evaluate_all` 末尾 `SpecimenTracer.heartbeat_sweep(state)`——記 `_last_entry_tick`，specimen 無決策 entry 且超 `HEARTBEAT_CADENCE`(=TICKS_PER_DAY/4=6h)→append 輕 heartbeat entry(`_snapshot` 純讀，phase:"heartbeat")。timeline 無 >6h 洞、不膨脹。`_print_entry` 守 heartbeat(無 想什麼/做什麼)輕印。
- **Fix 3 盲點閘**：runtime churn 床（主，`tracer_completeness_test._test_churn_gate_and_gapless`）斷言①timeline gap≤CADENCE ②result!=committed/heartbeat entry≥1；static tripwire baseline（副）見下。

## ★Fix 3 static tripwire baseline（R² 要求必準）
生產側（`scripts/simulation/`）call-site 計數：**capture_decision=6**（原 4 + 我 Fix 1 加 2 tap finder_miss/try_set_noop）/ **capture_intent=2**（faction_ai:1107/1118）/ **capture_options=2**（decision_engine:18/124）。grep 坐實。**★baseline 更新為 6/2/2**（我 Fix 1 合法新增 2 capture_decision tap）——請 systems 記入 tripwire 基準（原 spec 4，本刀後 6）。

## 守則達成
- **零 state mutation / 零 RNG**：heartbeat/attempt-tap 純讀（走既算好 td，不重呼 finder/observe_velocity）；capture_options suppress 包裹不動。
- **specimen-gated 零非-specimen 成本**：新 tap 過 is_specimen；heartbeat_sweep enabled+只迭代 specimen_team_ids。
- **憲法零新 try_set**（sites=29）。

## 驗（TDD + sanity；log docs/measurements/*-b21794b7.log）
- **TDD 12/12 PASS**：attempt-tap result(committed/finder_miss/try_set_noop)、heartbeat 填洞(無洞/不膨脹/決策覆蓋)、**churn gate**(timeline max gap 60≤CADENCE 60 + commit-fail/heartbeat≥1)、**★tracer on/off 世界 byte-identical**(觀測禁改世界硬證)。
- **headless 3+3 baseline 零新增**（剩 3=origin/main pre-existing beg_join/p2a_survival_terms/strategic_reads）。
- **憲法 sites=29 removed=0**；seeded warring reproducible OK。

## Fix 4 = systems（我不碰 invariants.md）
`invariants.md` 觀測不變量段收斂（specimen 完整性 + 前兩條）= 你 owner。

## 待確認
- tripwire baseline 6/2/2 請 systems 記錄。第四態(player-join)advisory 本刀不處理(spec 已記)。完成判定 = systems + reviewer + measurer(specimen 錄全生命+churn 現形)+ blueprint 批。context hold warm 等裁決信。
