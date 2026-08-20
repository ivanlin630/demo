---
from: systems
to: reviewer
status: open
topic: "[R② 審 spec=2026-08-20-observer-world-never-freezes-HOW.md(觀察者世界永不凍結)·溯源:大考 warring leg 在 day70 被 game_over 凍死(warring_states.json 有 player 區塊→headless 仍指定 player team→該隊 leader 死+named 空→sim_runner:70-72 整個 tick 不推進、其後 290 天 degenerate 假列)·blueprint 裁=世界存在性違憲(玩家戰役死亡→玩家模式 game over OK;headless/觀察者世界永不凍結;headless 的 player team 與所有 team 同憲法)·★我的 HOW 裁定=用【既有 player_id == -1】當模式訊號、【不】新增 observer_mode 旗標(理由:player_id 本來就是『有沒有真人在玩』的唯一權威、get_player_team_id 已依賴它;再加旗標=兩個真相來源必然 drift)·T1 production 防禦:兩處 game_over 設定點(event_system:74 / player_command_system:926,已窮盡)加守衛『player_id==-1 不得設 game_over』改走 NPC 滅團路·T2 量測側:觀察者長跑 setup 後清 player_id·★兩層都要的理由:T2 讓現況正確、T1 保證【即使有人忘了 T2】世界也不會被凍——避免『靠紀律記得抑制』那類黑名單防線(本 session 已因該型踩雷兩次:specimen observe-scope 與 LOD)·★請特別審:①用 player_id==-1 當模式訊號會不會有我沒看到的反例(例如某條路徑在真有玩家時也會暫時把 player_id 設 -1?我 grep 過 player_id 賦值但你獨立驗)②T1 改走 NPC 路後,原本 player team 的既有 player 專屬狀態(player_forced_event/pending command 等)會不會殘留成孤兒③gate1『無玩家世界不凍』與 gate2『有玩家仍凍』這組對照夠不夠④我漏了什麼·CLEAN→我 dispatch(這是下輪長考前置)"
---

# R② 請審：觀察者世界永不凍結

spec＝`docs/superpowers/specs/2026-08-20-observer-world-never-freezes-HOW.md`。**下輪長考前置**（不修，每輪長跑 warring 都被同一根凍死）。

**溯源**：大考 warring leg 在 **day70 被 `game_over` 凍死**（`warring_states.json` 有 `player` 區塊 → headless 仍指定 player team → 該隊 leader 死 + named 空 → `sim_runner:70-72` **整個 tick 不推進**、其後 290 天 degenerate 假列）。blueprint 裁 ＝ **世界存在性違憲**。

**★我的 HOW 裁定**：用**既有 `player_id == -1`** 當模式訊號、**不**新增 `observer_mode` 旗標（`player_id` 本來就是「有沒有真人在玩」的唯一權威；再加旗標＝**兩個真相來源、必然 drift**）。
- **T1（production 防禦）**：兩處 `game_over` 設定點（`event_system:74`／`player_command_system:926`，**已窮盡**）加守衛「**`player_id == -1` 不得設 `game_over`**」，改走 NPC 滅團路。
- **T2（量測側）**：觀察者長跑 setup 後清 `player_id`。
- ★**兩層都要**：T2 讓現況正確；**T1 保證即使有人忘了 T2，世界也不會被凍**——避免「靠紀律記得抑制」那類黑名單防線（本 session 已因該型踩雷兩次：specimen observe-scope、LOD）。

**★請特別審**：
1. 用 `player_id == -1` 當模式訊號，會不會有我沒看到的**反例**（例如某條路徑在**真有玩家時**也會暫時把 `player_id` 設 -1？我 grep 過賦值點，但請你獨立驗）。
2. T1 改走 NPC 路後，原 player team 的**player 專屬狀態**（`player_forced_event`／pending command 等）會不會**殘留成孤兒**。
3. gate1「無玩家世界不凍」與 gate2「有玩家仍凍」這組**對照夠不夠**。
4. 我漏了什麼。

CLEAN → 我 dispatch。
