---
from: systems
to: implementer
status: open
topic: A2c-2 D0 characterization——加 strat.* 探針 + overlay 開/關對照（折前摸清,別改 fold 邏輯）
---

# 工單：A2c-2 D0 characterization（探針 + 對照，非 fold）

spec：`docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md` §D0。**這步只加探針 + 產 characterization 數據，不動 fold 邏輯**（folder D1/D2 待 D0 數據才鎖）。A2c-1 血教訓：折前先摸清 FA6 overlay 保護什麼湧現。

## 在哪做
**新 worktree** `feat/machine-A2c2`（base origin/main）。可當首個 LG `--from-impl` 試水（實作自便，mailbox 亦可）。

## 做什麼
1. **加 strat.* 探針**（`warring_harness.gd` PROBE_KEYS + `movement_system`/`strategic_ai` bump，鏡射 A2c-1 full_probe 探針法）：
   - `strat.sa_move_dispatch`：`movement:64-72` 因 strategic_assignments 設 move_target 的次數。
   - `strat.encircle_assigned`（`_assign_encirclement:152` 每設）/ `strat.breakout_assigned`（`_assign_breakout:179`）。
   - `strat.expand_reached`：戰略移動到達 sa_pos 數（movement 到點且該 move_target 來自 SA）。
   - **★`strat.dual_key_teams`（reviewer 補）**：同 tick 某隊 strategic_assignments **同時有正整數(包圍)+`-1`(突圍)兩鍵** 的隊數/tick。現行 `movement:67-70 has(-1)` 讓突圍優先=隱藏 tie-break；量它稀有否（稀有→D1 可簡化不理；常見→D1 必顯式重建突圍優先）。
   - **★`strat.nonidle_empty_movetarget`（reviewer 補）**：`current_task != IDLE` 但 `move_target 空/抵達`（`==-1,-1 或 ==tile_pos`）的隊數/tick——現行 overlay 會趁機牽走這些隊（如 TASK_TRADE 抵達等結算）。量它定候選 A 風險：低→候選 A（arbiter task）風險小；高→候選 A 漏接此中間態（try_set 因非 IDLE 失敗）需加顯式 move_target-gate 或改候選 B。
2. **overlay 開/關對照**：加一個 flag/env（如 `STRAT_OVERLAY_OFF`）stub 掉 `movement:64-72` 分支 → 跑 baseline full_probe（3 seed 1337/42/7）**overlay 開 vs 關**，比 `conq.declared`/攻擊 eligible/`strat.*`/team 聚集度 → **量「overlay 保護了多少包圍/征服接觸湧現」**。
3. 產 `docs/process/verdicts/A2c2-d0.fullprobe.json`（3 seed × overlay 開/關並排）。

## 驗
- `--headless --import` 綠、sanity 無崩、constitution 綠（純加探針+flag，無 fold）。
- 探針 bump 正確（sa_move_dispatch >0 = overlay 有 fire；若近 0 = overlay 冗餘死路，折入零風險）。

## 完後
handback to:systems（+ 數據給我定 D1 候選 A/B）。**別鎖 fold**——這步純 characterize。measurer 可背景併行跑 3 seed。
