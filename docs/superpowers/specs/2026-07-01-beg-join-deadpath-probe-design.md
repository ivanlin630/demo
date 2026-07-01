# BEG/JOIN 死路探針 — 設計 spec（measure-first）

> 系統 HOW spec。承藍圖 `matrix-rulings`（BEG/JOIN 探針驗）。統一矩陣 F-I3。
> **measure-first**：矩陣 code-flow 確認 NPC-NPC 乞食/投靠 resolve 死路,但**runtime 影響未量**。先探針證實際 dispatch+resolve 率,**別直接當實開修** [[feedback_avoid_rabbithole]]。本 spec 只**量測**,修向按數據另定。

## 假設（矩陣 code-flow）
- `interaction_system.gd:197` `if a.combat_target != -1 or b.combat_target != -1: return` **先於** BEG resolver(`:247` `a.current_task==TASK_BEG and a.combat_target==id_b`)。
- BEG/JOIN dispatch 恆設 `combat_target`（`decision/options.gd:96` JOIN→sn、`:104` BEG→aid;`faction_ai:1377` JOIN→ally）→ combat_target≠-1 → 197 早退 → 247 不可達。
- `TASK_JOIN` **interaction 無 handler**（grep 零）。
- player 版直呼 `_resolve_aid_request`（player_command:1072）繞過故沒露。

## 探針設計（純觀測、零行為變）
加 Probe counter 量 NPC-NPC BEG/JOIN 生命週期：
- `Probe.bump("beg.dispatch")`：team dispatch TASK_BEG（設 combat_target=aid）時。
- `Probe.bump("beg.resolve")`：`_resolve_aid_request` 實際被 NPC-NPC 路徑呼到時（非 player）。
- `Probe.bump("beg.early_return_197")`：兩隊有 BEG task 且被 197 早退時（證早退吃掉 BEG）。
- `Probe.bump("join.dispatch")` / `join.resolve`（resolve 預期 0=無 handler）。
- `Probe.bump("join.arrived_no_handler")`：JOIN team 到 ally tile 但無 resolver 處理時。

落點：`interaction_system._try_interact`（197 早退前後 + 247 分支）+ dispatch 端（options/faction_ai BEG/JOIN 設 combat_target 處，或 sim_runner task 觀察）。

## 量測
- warring seed + econ_bed（絕境多的場景）跑 → 讀 probe：
  - `beg.dispatch > 0 且 beg.resolve == 0`（NPC-NPC）→ **證死路真在 runtime 發生**。
  - `beg.early_return_197` 對上 dispatch → 證早退是死因。
  - `join.dispatch > 0 且 join.resolve == 0` → JOIN 全空轉。
- **產出**：NPC 絕境「乞食/投靠」實際發生頻率 + resolve 率 → 回報藍圖：死路影響大不大（P2a 絕境 repertoire 空轉多少）。

## 驗收
- probe 就位、零行為變（headless 全綠、coin_eq 0）。
- warring/econ seed 跑出 dispatch vs resolve 數 → 死路 runtime 影響量化。
- handback 回報：影響級別 + 修向建議（若量大：resolver 移 197 前 / combat_target 語意拆「社交 target ≠ 戰鬥 target」;若量小：低優先標記）。**修不在本 spec**（measure 先）。

## 檔案
- `scripts/debug/probe_stats.gd`：新 counter（若需）。
- `scripts/simulation/interaction_system.gd`：`_try_interact` probe 埋點（197/247）。
- BEG/JOIN dispatch 端埋點（`faction_ai_system.gd` / `decision/options.gd` 或 sim_runner 觀察 current_task）。
- warring/econ seed：開 Probe 跑讀。

## 風險 + 緩解
- **埋點誤改行為**：純 `Probe.bump`（no-op unless enabled），零決策影響。
- **dispatch 埋點位置**：BEG/JOIN 設 combat_target 的點分散 → 或在 `_try_interact` 入口統一觀察 `current_task==TASK_BEG/JOIN`（單點,較準）。plan 定。
- **與其他軌並行**：只碰 interaction + probe + debug seed → 與首燒(faction_ai intent)/單寫者(resource/coin) 檔案 disjoint（interaction 首燒不碰決策 intent、單寫者不碰 interaction）。
- **scope**：只量測。修按數據另 spec。
