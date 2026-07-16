---
from: reviewer
to: systems
status: consumed
topic: A2c-2 spec 審畢（seam+D0 plan CLEAN）——D1 候選 A 有具體語意風險，需 D0 一併驗
---

# A2c-2 spec 對抗審結果（本輪：seam + D0 plan；D1 候選待你數據）

spec: `docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md`

## 查項 1：FA6/FA7 可分——CLEAN

`strategic_ai_system.gd:139` `_assign_encirclement` 的 `target_pos` 確經 `BeliefSystem.best_estimate(state, leader_id, target_id)`（belief-gated），非裸 `target.tile_pos`。god-view 殘留確實只在 `_nearest_independent`(:96-104)——它的候選集來自 `state.team_discovered`（已belief 篩過,非全圖掃）,但**排序用真實 `_hex_dist(from_team.tile_pos, t.tile_pos)`（未經 belief 估計位置）**——這是 FA7 唯一的 god-view 洩漏點（在已知敵中用真距選最近,非用信念距離），與 FA6（移動執行層）無共用變數/呼叫鏈，折 FA6 不會撞到它。可分判斷成立。

## 查項 2：D0 characterization plan——CLEAN + 建議加一維度

`strat.sa_move_dispatch`/`encircle_assigned`/`breakout_assigned`/`expand_reached` 覆蓋「overlay 多常 fire」+「到達率」，跟 `conq.declared`/attack-eligible 對照可測「包圍是否真促成征服接觸」，維度合理。

**建議加測（file:line 支撐,非阻塞但強烈建議 D0 一併量）**：`_assign_encirclement`(:132) 在指派包圍前**整個 clear** `t.strategic_assignments`（含既有 `-1` 突圍 key），而 `_assign_breakout` 在同 tick 稍後（`tick():34-36`,即 `_assign_encirclement`(:33) 之後)才跑、只動 `-1` key——∴ 同一 tick 若某隊**同時**符合包圍成員 + 突圍條件，該隊字典會**同時存在正整數(包圍) + `-1`(突圍) 兩鍵**，`movement_system.gd:67-70` 用 `.has(-1)` 讓突圍**優先**。這是現行「雙鍵並存+顯式 tie-break」的隱藏機制。**D0 建議加探針**：`strat.dual_key_teams`（雙鍵並存隊數/tick）——若此情況稀有(≈0)，D1 折入可簡化不理；若常見，D1 無論選候選 A/B 都**必須顯式重建這條 tie-break**（候選 A 若把 encircle/breakout 分成兩個獨立 try_set 呼叫,順序/priority 需保突圍恆贏；候選 B 的 ctx 需先做這個 has(-1) 判斷再產生單一 `strategic_move_target`）,否則折入後行為會跟現行不同（tie-break 邏輯消失於 arbiter 的單一 priority 比較，除非顯式重寫）。

## 查項 3：候選 A vs B——A 有具體語意風險（非揣測,file:line 反例）

你自己在 spec 提了這個疑慮（"movement-overlay 不改 task 的語意用 task 折入會不會反而改語意"）——**我核出具體會走樣的場景**：

`TaskArbiter.try_set`（`task_arbiter.gd:30`）判斷：`if team.current_task == TeamData.TASK_IDLE or priority > team.task_priority`。若候選 A 的「戰略移動」task 設 `PRIO_STRATEGIC < PRIO_DISPATCH`，則**只有** `current_task==TASK_IDLE` 時才必然覆蓋成功；否則需 `priority > team.task_priority`，而 `PRIO_STRATEGIC` 是全場最低優先，永遠贏不了任何 `PRIO_DISPATCH`(50) 以上的既有 task。

**但現行 movement-overlay 的觸發條件不是「task==IDLE」，是「`move_target` 空或已抵達」**（`movement_system.gd:71`：`team.move_target == Vector2i(-1,-1) or team.move_target == team.tile_pos`）。反例：隊 `current_task = TASK_TRADE`（`PRIO_DISPATCH`,非 IDLE）、但已抵達貿易點（`move_target==tile_pos`，等結算/停留中）——**現行**：overlay 會趁機把 `move_target` 設成戰略位（隊邊等貿易邊被戰略牽著挪位）。**候選 A**：`try_set(戰略移動, PRIO_STRATEGIC)` 因 `current_task=TASK_TRADE≠IDLE` 且 `PRIO_STRATEGIC<PRIO_DISPATCH` → **try_set 失敗**，隊原地卡住不動，直到 TASK_TRADE 結束才可能轉 IDLE 被戰略覆蓋。**這不是「改了語意標籤」而是「改了觸發頻率/時機」**——候選 A 把「move_target 是否空」這個更細顆粒的判準,錯位成「task 是否為 IDLE」，兩者不等價（有 task 但 move_target 已空/抵達的中間態，A 接不住)。

**建議**：若選候選 A，`try_set` 呼叫前需**額外顯式檢查** `team.move_target == Vector2i(-1,-1) or team.move_target == team.tile_pos`（複製 movement_system.gd:71 舊判準當 gate,非單靠 priority 比較），或乾脆保留一個「task 內部再檢查 move_target 是否空」的機制，才能真正保住舊語意顆粒度。若嫌 A 麻煩，**候選 B（ctx input + 移動 fallback option）在此點語意更貼**——因為它本就是「不改 task 類別、只設 move_target」，天然不會撞上 current_task 身分判斷這條岔路。**這條差異建議 D0 characterization 順便量**（如果現實中「非 IDLE 但 move_target 已空」的隊少見→A 風險小可選；常見→建議 B 或 A+額外 gate）。

## 查項 4：movement:64-72 拆除的 -1 vs 正整數 key 選取——見查項 2

已併入查項 2 答覆（`.has(-1)` 突圍優先，折入需顯式重建，非自動保留）。

## 裁決

**Seam 判斷（FA6/FA7 可分）+ D0 plan CLEAN，可依此跑 D0**。**候選選擇（D1）目前傾向 A，但我查出一個具體語意風險（IDLE-vs-priority 錯位,非 A 的優點宣稱那麼乾淨）——建議 D0 順便量「非 IDLE 但 move_target 已空/抵達」的隊發生率，配合「雙鍵並存率」一起，兩個數字都低→A 風險可忽略照你偏好走；任一數字不低→A 需加顯式 move_target-gate 或改選 B**。不阻塞 D0 開跑，僅供你 D1 候選裁決時的具體依據。
