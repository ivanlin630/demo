# Plan — BEG/JOIN 死路探針（measure-first）

> spec = `specs/2026-07-01-beg-join-deadpath-probe-design.md`。純觀測、零行為變。修不在本 plan（measure 先）。
> 前置：headless 基準 PASS。

## Task 1 — probe counter 埋點
- `probe_stats.gd`：加 counter（若既有 bump 夠則複用）。
- `interaction_system.gd _try_interact`：入口觀察 `a.current_task==TASK_BEG/TASK_JOIN` → `Probe.bump("beg.dispatch"/"join.dispatch")`;197 早退且有 BEG/JOIN task → `Probe.bump("beg.early_return_197"/"join.arrived_no_handler")`;247 BEG resolver 實呼（非 player）→ `Probe.bump("beg.resolve")`。
- **DoD**：埋點就位、no-op unless enabled、headless 全綠零行為變。

## Task 2 — 量測跑
- warring seed + econ_bed（絕境多）開 Probe 跑 → 讀:
  - `beg.dispatch` vs `beg.resolve`（NPC-NPC）
  - `beg.early_return_197` 對上 dispatch
  - `join.dispatch` vs `join.resolve`(預期 0)
- **DoD**：dispatch vs resolve 數在手,死路 runtime 影響量化。

## Task 3 — 回報
- handback：NPC 絕境乞食/投靠實際頻率 + resolve 率 → 死路影響級別 + 修向建議（量大:resolver 移 197 前 / combat_target 語意拆;量小:低優先標）。**修按數據另定,不在本 plan**。
- **DoD**：量化回報 + 修向建議。

## 不碰（scope + 並行 guard）
- 不修 dead path（measure 先）、不碰 faction_ai intent（首燒）、不碰 coin（單寫者）。**只碰 interaction 埋點 + probe + debug seed**。

## 完成
- handback：BEG/JOIN runtime 死路影響數據 + 修向。系統據此決是否開修 spec。
