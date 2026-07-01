# Plan — 後期 scaling 加固 P0 + tick 計時 + scaling bed

> spec = `specs/2026-07-01-scaling-hardening-p0-design.md`。承評估 `specs/2026-07-01-late-game-scaling-assessment`。
> **measure-first 加固**：安全優化(零行為變) + instrument 先 → 量曲線 → 行為變 honor-LOD 留 measure-gated。

## 前置
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # 基準 PASS
```
重型 seed 用 `GODOT_TIMEOUT=2500` + run_in_background。

## Task 1 — #3 tick 計時 instrument（先鋪，量 baseline）
- `sim_runner.gd advance_tick`：包 `Time.get_ticks_usec()` 差 → 本 tick wall-time。累積、週期 flush（每日印 `[TickPerf] avg/max us, teams=N, factions=F`）。
- **DoD**：長跑印得出 tick-time 帶 tick/N;無 spam。

## Task 2 — scaling bed（大 N + die-off，量 baseline 曲線）
- 新 `scripts/debug/scaling_bed.gd`：seed 大 N 階梯（100/200/400 隊）+ 滅團潮場景（飢荒/大征服同 tick 多 erase）。開 TickPerf。
- **先跑 baseline**（加固前）：記 tick-time vs N + die-off spike。
- **DoD**：baseline 曲線在手（加固後對照用）。

## Task 3 — tile→teams 共用空間索引（零行為變，TDD）
- **測先**：索引查 == 全掃結果（一致性）。
- `world_state.gd`：加 `teams_by_tile: Dictionary`（`tile_id→Array[int]`）+ rebuild helper（每 tick 開頭 rebuild，O(N) 一次）。呼叫點 `sim_runner` advance_tick 頭。
- **改用點**（掃全隊→查索引，行為不變）：
  - `faction_ai_system.gd:1455 _has_hostile_within`（主 O(N²)/hr）
  - `interaction_system.gd:49/74`（co-location）
  - `faction_ai_system.gd:399 _has_resident_team_on_tile` / `:407 _has_inflight_settler`
- **DoD**：三處改索引、行為不變（headless 回歸綠 + 一致性測綠）、warring seed 意圖分布/probe 同量級（行為不變證）。

## Task 4 — team_intel prune 進 erase_team（零行為變，top leak 修，TDD）
- **測先**：erase 隊後 `team_intel.has(tid)`=false + 無 observer 留其 target claims。
- `world_state.gd:123 erase_team`（緊鄰 `:154-157` registry 清理）：加 `team_intel.erase(tid)` + `for obs in team_intel: team_intel[obs].erase(tid)`。
- 順修 nit：`team_known[obs].erase(tid)` no-op（array 存 MessageData 非 int）→ 移除/改對（plan 執行時裁，低優先）。
- **DoD**：erase 後 team_intel 無死 tid、決策 belief 不回歸、coin_eq/pop 守恆、測綠。

## Task 5 — 加固後量曲線對照
- scaling bed 重跑（加固後）：tick-time vs N 曲線 vs Task 2 baseline。**滅團潮 spike 收斂**可見。
- **DoD**：加固前後對照（該顯著降 O(N²) 段）;die-off spike 收。

## Task 6 — （measure-gated，量到才做）faction AI honor-LOD
- **只在** Task 5 顯 faction AI `evaluate_all`（`faction_ai_system.gd:513`）仍主導 tick-time 才動。
- 空間索引（Task 3）已收 `_has_hostile_within` O(N²) inner → 可能已足。
- 若仍主導：`evaluate_all` honor 傳入 subset（far 隊決策降 FAR cadence）。**行為變** → 須驗世界不退化（意圖分布/建國率/戰爭同量級）。**沒量到就不做**（別猜）。
- **DoD**：量到才做;做則附行為不退化證。否則明確記「Task 3 索引已足，honor-LOD 未觸發需求」。

## Task 7 — 守恆 + 回歸閘
```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # PASS ≥ 基準
```
- **DoD**：framework S1-S6 PASS、coin_eq 0、pop 守恆、InvariantAudit 0、warring seed 行為不變、無 GDScript 錯。

## 不碰（scope guard）
- 經濟/決策/戰鬥邏輯（純 perf + 觀測 + 測床）。R1 食物不碰（藍圖緩）。honor-LOD 行為變 = measure-gated（Task 6，沒量到不做）。

## 完成
- handback：tick-time vs N 曲線（加固前後）+ 收掉哪些 O(N²) + die-off spike 收否 + honor-LOD 觸不觸發。
- ⚠ 與軌 A（specimen-tracer）並行同觸 sim_runner/world_state/faction_ai/headless_test 不同函數 → 系統 merge 順序解。
