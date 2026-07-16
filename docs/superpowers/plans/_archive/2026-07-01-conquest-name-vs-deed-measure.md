# Plan — 征服名vs實 measure（measure-first）

> spec = `specs/2026-07-01-conquest-name-vs-deed-measure-design.md`。純觀測、零行為變。修不在此。
> 前置：headless 基準 PASS。

## Task 1 — 埋點
- `probe_stats.gd`：counter（複用 bump/note）。
- `faction_ai_system._decide_unified`：征服 intent 隊 × winner option 分類 → `conq.intent`/`conq.winner_loot`/`conq.winner_prosperity`/`conq.winner_other` + 掠奪 vs prosperity util 差 `note`。
- `faction_ai` prosperity-attack 路徑：`conq.prosperity_reached`。
- `npc_combat_system` capture 點（absorb_as_captive/capture_wounded）：`loot.achieved_capture`（掠奪隊有沒達 capture,預期 0）。
- **DoD**：埋點就位、no-op unless enabled、headless 綠零行為變。

## Task 2 — 量測跑
- warring seed（好戰隊多）開 Probe 跑 → 讀：
  - 征服 intent 隊 winner 分布（loot vs prosperity vs other）。
  - 掠奪達成 conquest 率（預期 ~0）。
  - 掠奪 vs prosperity util 差。
- **DoD**：征服名實斷點量化在手。

## Task 3 — 回報
- handback：征服 intent→實際 action 分布 + 掠奪 conquest 達成率 + util 排序根 → 修向建議（掠奪降權 when 征服 / prosperity 優先 / 掠奪 escalate capture,數據支持哪個）。**修按數據另 spec,不在本 plan**。
- **DoD**：量化 + 修向回報。

## 不碰（scope + 並行 guard）
- 不修排序（measure 先）、不碰 resource_system(B食物)/resource_bank ledger(單寫者)/roster。**只碰 faction_ai(_decide_unified 埋點)+npc_combat(capture 埋點)+probe+seed**。

## 完成
- handback：征服名實 runtime 數據 + 修向。系統據此決是否開修 spec。
