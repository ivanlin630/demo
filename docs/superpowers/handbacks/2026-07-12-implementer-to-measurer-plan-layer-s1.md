---
from: implementer
to: measurer
status: consumed
topic: 計畫層 S1 實作交付 — rung事件驅動化(milestone升/失守K降);branch feat/plan-layer-s1已push,待驗收
---
# Hand Back: 計畫層 S1（rung 事件驅動化）

branch `feat/plan-layer-s1`（已 push，疊 origin/main 9a5cd61）。plan `docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 1**（含 systems demote 裁決更新版）。

## 實作摘要
- `scripts/data/team_data.gd`：+`rung_stall_count: int`（**一欄**；EWMA/trend 兩欄棄——見裁決）。
- `scripts/simulation/ambition_ladder.gd`：
  - 常數 `RUNG_STALL_K = 3`。
  - `milestone_met(state, team, rung_val)`：累進階梯條件（SURVIVE 恆 true / ACCUMULATE food≥0.5 / EXPAND ＋pop≥8 / STATE ＋faction≥2 / HEGEMON ＋faction≥4）。
  - `update()` 重寫事件驅動：升=`milestone_met(next)`（reckless 直跳保留）；降=連續 `K` 次 `not milestone_met(current)`（遲滯，含 plateau-below-threshold）。無 trend/EWMA。target_rung 保留（外部 caller `specimen_tracer.gd:104`）。
- `scripts/debug/headless_test.gd`：+`_test_plan_rung_event_driven`（升 ACCUMULATE / 失守 K 降 SURVIVE / 撐住不降）；inline `_mk_min_state`/`_mk_team` helper。
- `scripts/debug/warring_harness.gd`：+probe `g2.ambition_promote`/`g2.ambition_demote`（rung churn 計數）+`_rung_histogram`（per-rung 階分布 r0-r4）。

## ★行為改動報備（非 regression，需你標 baseline 位移）
- **demote 語意變**：舊 update 瞬時（target<old 一次退）；新版 K=3 遲滯（連續失守 milestone 才降）。系統裁決確認（trend 對常數 metric 恆正永不 fire + plateau 死角 → 改綁 milestone）。
- **既有測 `_test_ambition_rung_climb` demote 段**：依賴舊瞬時（食物赤字 1 次退），我改為 loop `RUNG_STALL_K` 次（反映裁決後語意，非硬改遷就）。已在 diff。

## 我方自驗（非驗收，供參）
- headless `=== DONE ===`，`[OK] _test_plan_rung_event_driven` + `ambition rung climb OK`。
- **0 新增 SCRIPT ERROR**：我起 `_base_9a5cd61` worktree 對照——**origin/main 9a5cd61 baseline 同 3 assert**（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，皆 seeded 全 sim emergent assert，與 rung 無關；strategic_reads_ladder 手設 rung 不呼 update ∴我改動不觸及）→ 本 slice 0 淨新增。
- **determinism byte-identical**：`WARRING_SEEDS=1337 WARRING_MONTHS=1` 兩跑 `cmp` 完全相同。
- constitution_gate PASS（sites=29，removed=0）。

## 待驗收（plan §驗收）
1. **rung 抖動顯著降**：vs baseline 瞬時版，同 seed `g2.ambition_promote`+`g2.ambition_demote` 變更總次數（新 probe）。事件驅動應 << 瞬時。
2. **determinism** byte-identical（我已初驗 1seed×1mo；你擴 seed/月）。
3. **階分布**（`rung_dist` r0-r4）：不再全卡瞬時抖動；標 baseline 位移（plan-layer S1 位移，比照 world-gen）。
4. **融合閘**：constitution（我綠）/coin/framework/sanity 綠。
5. **headless 0 新增 FAIL**（3 pre-existing 見上，排除）。

## 連動風險
- rung 穩定化 → 下游讀 ambition_rung（intent scorer/strategic_ai/決策權重）軌跡位移 = baseline 位移。
- 3 pre-existing emergent assert 或因位移改內容仍 pre-existing（p2a/beg_join 為 seeded 全 sim 門檻，隨任何行為改動浮動）。
- **序列**：S1 merge 後 systems 才 dispatch S2（phase 讀 S1 穩定 rung）。本 slice 不碰 phase。
