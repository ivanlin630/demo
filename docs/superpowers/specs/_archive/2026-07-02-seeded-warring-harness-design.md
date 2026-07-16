# seeded warring 回歸 harness — 設計 spec

> 系統 HOW spec。承藍圖 `capture-pay-conqueror-lastmile` 平行（建議建）。
> **痛點**：一路撞「over-war/emergence 落 unseeded 噪、無法硬斷」（means-end over-war 4pp / CONQUER 全窗 / desync 復現 / capture 轉化——全被 unseeded drift 糊住,[[reference_multi_sanity_unseeded]]）。
> **目標**：seeded 可重現 warring → 所有 emergence/over-war **硬-verifiable**（before/after 同 seed 逐點對照）。解 recurring 盲點。infra。

## 現況
- `warring_states_seed.gd` **unseeded**：`Math.random`/Godot RNG 無 seed → 每跑 drift → 絕對數不可重現、before/after 只能比「量級/趨勢」非逐點。
- 所有 emergence 驗（CONQUER/over-war/capture/desync）都栽在此：4pp 是噪還訊號?無 seeded 對照無法斷。

## 設計
### A. deterministic seed
- warring harness 加 `WARRING_SEED` env（default 固定值）→ 開頭 `seed(WARRING_SEED)`（Godot `seed()` 播 global RNG）。**同 seed → 逐 tick 逐隊完全重現**。
- 確認全 RNG 走 seeded global（`randf`/`randi`）;若有獨立 RNG instance（如 path_cache/各系統 local）盤點納 seed（或記未納者）。

### B. before/after 對照 harness
- `scripts/debug/seeded_warring_bed.gd`：固定 seed 跑 N 月 → 輸出結構化 metric（意圖分布/CONQUER/established/capture.total/attrition%/famine/teams 曲線 + probe）。
- **對照模式**：同 seed 跑 baseline（git stash or ref）vs branch → **逐點 diff**（哪 metric 真變、變多少、是訊號非噪）。
- 短窗（timeout 內,如 3-6 月）+ 可選長窗（GODOT_TIMEOUT 拉）。

### C. 回歸閘化（可選）
- 關鍵 emergence metric（CONQUER>0 / over-war<閾 / capture>閾 / 不 mass-starve）→ seeded 斷言 → 回歸閘常駐（改動後同 seed 該穩,漂了報）。**先 harness 出數,閘化按需**。

## 驗收
- 同 seed 兩跑**逐點相同**（意圖分布/teams 曲線/probe 完全一致）→ 重現性證。
- before/after 對照跑得出逐點 diff（demo:對 means-end over-war 4pp 重測——seeded 下是訊號還噪）。
- 零行為變（harness 只加 seed + 觀測,不改 sim 邏輯;seed 只定 RNG 序不改機制）。headless 全綠。

## 檔案
- `scripts/debug/warring_states_seed.gd`：`WARRING_SEED` env + `seed()` 開頭。
- `scripts/debug/seeded_warring_bed.gd`（新）：固定 seed + 結構化 metric + before/after 對照。
- 盤點獨立 RNG instance（path_system `_path_cache` 等）→ 納 seed or 記。
- `headless_test.gd`：seeded 重現性測（同 seed 兩跑同 metric）。

## 風險 + 緩解
- **獨立 RNG 未納 seed → 仍 drift**：盤點全 `RandomNumberGenerator.new()` / local rng,納 global seed or 記未納（誠實標哪些仍非確定）。
- **Date.now/時間依賴**：確認無 wall-clock 進 sim（本專案 tick-based,應無）。
- **與 capture/combat_target 並行**：本軌**純 debug/infra**（warring seed + 新 bed），不碰生產 sim 邏輯 → 與兩軌完全 disjoint（除 headless_test 各加測,auto-merge）。
- **scope**：seed + 對照 harness + 重現性測。**不改** sim 機制、不做閘化（按需後續）。

## 開放細節（plan 定）
- WARRING_SEED default 值 + 多 seed 集（避單 seed 偏）。
- before/after 對照落 harness vs 手動兩跑 diff。
- 獨立 RNG 納 seed 範圍（全納 vs 只主 RNG + 記其餘）。
