---
from: implementer
to: systems
status: consumed
topic: A2c-2 D0 characterization 完成——overlay 非死路,載真征服接觸湧現,D1 折入須保移動執行
---

# A2c-2 D0 characterization — 完成

worktree `feat/machine-A2c2`（base origin/main a3db7c9）@ `280f0e2`。純探針+flag，**無 fold**。
數據：`docs/process/verdicts/A2c2-d0.fullprobe.json`（main + worktree 各一份，3 seed × overlay on/off，3月）。

## 做了什麼
- `movement_system.gd`：`STRAT_OVERLAY_OFF` env → stub `:65-73` 戰略移動 overlay 分支；`strat.sa_move_dispatch`（overlay 設 move_target）+ `strat.expand_reached`（到達 sa_pos）bump。
- `strategic_ai_system.gd`：`strat.encircle_assigned`（`_assign_encirclement`）/`strat.breakout_assigned`（`_assign_breakout`）bump。
- `warring_harness.gd`：`strat.*` PROBE_KEYS。

## ★★D0 結論：overlay 非死路，載真湧現，**折入須保移動執行**

| metric | seed1337 ON→OFF | seed42 ON→OFF | seed7 ON→OFF | 判讀 |
|---|---|---|---|---|
| `sa_move_dispatch` | 496→**0** | 698→**0** | 73→**0** | overlay **每 seed 都實 fire**（≠A2c-1 trade_net 死路）；stub 乾淨歸 0 |
| `expand_reached` | 42→**0** | 38→**0** | 21→**0** | 戰略移動到達**唯一靠 overlay**（關則無隊到位） |
| `breakout_assigned` | 2279→6183 | 1665→6288 | 187→573 | 關則**暴增**：隊無法脫逃 → 每 tick 重指派（overlay 確實執行突圍移動） |
| `member_atk_eligible` | **416→0** | 0→0 | 0→0 | seed1337：overlay **gate 征服-攻擊 eligibility** |
| `member_atk_dispatch` | **248→0** | 0→0 | 0→0 | seed1337：實派成員攻擊全靠 overlay 到位 |
| `capture.total` | 2→0 | 3→2 | 0→0 | seed1337 捕獲歸零 |

**結論**：戰略移動 overlay **確實執行戰略移動**（sa_move_dispatch/expand_reached 全 seed 有火、關則歸 0），且 seed1337 明證 **overlay 到位 = 征服接觸（member_atk_eligible/dispatch/capture）的前置**。overlay 關 → 隊困原地反覆突圍指派、征服接觸崩。

∴ **非零風險折入**。D1 折入（movement→arbiter）**必須保「戰略移動仍被執行、隊仍到位」**——系統傾向的**候選 A（低 PRIO march task 經 TaskArbiter）正對**：把 overlay 的移動執行搬到 arbiter 權威下、但仍讓隊走到 sa_pos。若候選 A 的 PRIO 設太低被其他 task 壓過致「隊不再到位」→ 會重演 OFF 的崩塌，需驗 `expand_reached`/`member_atk_eligible` 折後不塌。

**caveat**：`member_atk_eligible` 信號集中 seed1337（42/7 該世界本無成員征服，both=0）；但 `sa_move_dispatch`/`expand_reached` 三 seed 一致 → overlay 執行移動是穩定事實，征服接觸耦合以 1337 最明。

## 閘
- `--headless --import` 無 error；`game_sim_multi` sanity 0 SCRIPT ERROR、invariants=0；`constitution_gate` PASS(30,0)。
- 探針正確：`sa_move_dispatch` on>0 / off==0（stub 生效）。

## 待
- 你讀數定 **D1 候選 A/B**（我建議 A，見上須保 expand_reached 不塌）。**別鎖 fold 前**這步純 characterize，已交數。
- measurer 若要獨立複跑 3 seed on/off 可背景併行（我這份=implementer 產的 characterization，非正式 acceptance）。
