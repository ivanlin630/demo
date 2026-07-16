# Plan — seeded warring 回歸 harness（infra）

> spec = `specs/2026-07-02-seeded-warring-harness-design.md`。純 debug/infra、零 sim 邏輯變。
> 前置：headless 基準 PASS。

## Task 1 — deterministic seed
- `warring_states_seed.gd`：`WARRING_SEED` env（default 固定）→ 開頭 `seed(WARRING_SEED)`（Godot global RNG）。
- **測**：同 seed 兩跑 → 意圖分布/teams 曲線/probe **逐點相同**。
- **DoD**：重現性證（同 seed 逐點一致）。

## Task 2 — 獨立 RNG 盤點
- grep `RandomNumberGenerator.new()` / local rng（path_system `_path_cache` 等）→ 納 global seed or 記未納。
- **DoD**：全 RNG 納 seed（或誠實記哪些仍非確定 + 影響）。

## Task 3 — before/after 對照 harness
- `scripts/debug/seeded_warring_bed.gd`（新）：固定 seed 跑 N 月 → 結構化 metric（意圖/CONQUER/established/capture.total/attrition%/famine/teams 曲線+probe）。對照模式支援 baseline vs branch 逐點 diff。短窗(3-6月)+可選長窗(GODOT_TIMEOUT)。
- **驗**：重測 means-end over-war 4pp——seeded 下是訊號還噪(demo harness 價值)。
- **DoD**：對照跑得出逐點 diff。

## Task 4 — 守恆閘（零行為變）
- headless PASS≥基準、coin_eq(全池)0、framework S1-S6 PASS（seed 只定 RNG 序、不改機制）。
- **DoD**：零 sim 行為變證（seeded run 機制與 unseeded 同、只是可重現）。

## 不碰（scope + 並行 guard）
- 生產 sim 邏輯、決策、戰鬥、capture(軌1)、combat_target(軌2)。**只碰 warring seed + 新 bed + RNG 盤點**。純 debug → 與兩軌 disjoint（除 headless_test 各加測）。

## 完成
- handback：seeded 重現性證 + 對照 harness + 獨立 RNG 盤點結果 + means-end over-war 4pp 重測結論(訊號/噪)。= 解 unseeded 盲點,後續 emergence/over-war 硬-verifiable。
