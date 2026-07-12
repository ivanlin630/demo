---
from: systems
to: implementer
status: open
topic: [工單 S1] 計畫層 rung事件驅動化—AmbitionLadder.update棄瞬時重算→milestone升/trend停滯降;plan Task1;疊新worktree feat/plan-layer-s1
---

# 工單 S1：rung 事件驅動化（計畫層第一 slice）

plan：`docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 1**（R² CLEAN）。中長期計畫層地基:把野心階梯從「每 10h 瞬時重算 rung」（抖動源）改成事件驅動（milestone 升 / trend 停滯降）=穩定化。**新 worktree `feat/plan-layer-s1` 疊當前 main（已 push）。**

## 做（照 plan Task 1 Step 1-6）
- team_data 加 3 欄（rung_trend_ewma/_last/stall_count）。
- `AmbitionLadder`:加 `milestone_met` + `_progress_metric` helper + 重寫 `update()`（事件驅動,見 plan Step 3 完整 code）。常數 RUNG_TREND_ALPHA=0.3/RUNG_STALL_K=3。
- `target_rung()` **保留不刪**（milestone_met 複用其語意;reviewer 確認唯一 caller 是 update 自身,改後零外部呼叫,留著相容）。
- TDD:`_test_plan_rung_event_driven`（milestone 升 + trend 停滯 K 降）。探針 warring_harness。

## 守（plan Global Constraints）
- **determinism byte-identical**:EWMA/trend 純算術零 randf。
- **本 slice 只 rung,不碰 phase**（phase 是 S2）。
- baseline 位移非 regression:rung 穩定化改行為（rung 變更次數/階分布變）→ measurer 標「plan-layer S1 位移」。
- 既有 rung 測（_test_r2_*/rung_dissolution）若依賴瞬時行為斷言 → 標「行為改動非 regression」報 systems,別硬改測遷就。

## 驗收（handback to:measurer）
- rung 抖動顯著降（vs baseline 瞬時版,同 seed rung 變更次數）+ determinism byte-identical + 階分布 + 融合閘（constitution/coin/framework/sanity）綠 + headless 零新增 FAIL。

## 註
- **序列 slice**:S1 merge 後才 dispatch S2（phase 讀 S1 的穩定 rung）。別碰 S2/S3/S4。
- test helper `_mk_min_state`/`_mk_team` 若 headless_test 無現成 → 比照 `consolidation_decision_trace.gd` `_mk_leader` 構造（plan 已註）。
- 卡點 → to:systems（別問 user）。
