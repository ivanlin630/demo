# HOW spec：觀察者世界永不凍結（`game_over` 不得凍住無玩家世界）

date: 2026-08-20 ／ owner: systems ／ 溯源：大考 warring leg day70 凍死 → measurer 報 → blueprint 裁「世界存在性違憲」
狀態：待 R② → dispatch。**下輪長考前置**（不修，每輪長跑 warring 都被同根凍死）。

## §1 前提（file:line）
- `world_state.gd:84-86` `game_over` / 註「H：玩家絕後 → game_over=true，sim_runner 凍結世界」。
- 設定點**窮盡兩處**：`event_system.gd:74`（`handle_player_succession`：player team leader 死且 `named_members` 空）、`player_command_system.gd:926`（隊已滅無繼承人）。
- 凍結點：`sim_runner.gd:70-72` `if state.game_over: return "game_over"`（**整個 tick 不推進**）。
- 觸發條件靠 `EventSystem.on_leader_death` 的 player 分支，而該分支由 `WorldState.get_player_team_id()` 判定，**其唯一依據是 `state.player_id`**。
- **實測**：`warring_states.json` 有 `player` 區塊 → headless 仍會指定一支 player team（Team48）→ 該隊 leader 死 + named 空 → 世界 day70 凍結、其後 290 天為 degenerate 假列。

## §2 WHAT 裁定（blueprint、已定）
- 玩家**戰役**死亡 → 玩家模式 game over ＝ **OK、保留**。
- **headless／觀察者世界永不凍結**；headless 下的「player team」**與所有 team 同憲法**（死 → 繼承/解散/釋放，**不特權凍世界**）。
- 違反的是意圖帳「**世界存在性**」row（世界的存在不綁玩家）——與 LOD 紅線同族。

## §3 HOW 裁定（systems）：用**既有** `player_id == -1` 當模式訊號，不新增 mode 旗標
**理由**：`player_id` 本來就是「有沒有真人在玩」的唯一權威（`get_player_team_id` 已依賴它）；再加一個 `observer_mode` 旗標＝**兩個真相來源**、日後必然 drift。
- **T1（production、防禦性、小）**：兩處 `game_over` 設定點加守衛——**`state.player_id == -1` 時不得設 `game_over`**，改走 NPC 路（`on_leader_death` 的 NPC 分支：best named → anon 晉升 → 皆無則滅團）。
  - `event_system.gd:74`：`player_id == -1` → 不設 `game_over`、回傳 false 讓既有滅團路接手。
  - `player_command_system.gd:926`：同守衛（該路徑在無玩家時本就不該被走到，守衛＝防禦）。
- **T2（量測側）**：觀察者長跑（exam bed 等）**setup 後清 `state.player_id = -1`** + 清 `player_forced_event`，床頭註明理由。
  ★T1 與 T2 **兩層都要**：T2 讓現況正確，T1 保證**即使有人忘了 T2**，世界也不會被凍（避免「靠紀律記得抑制」那類黑名單防線——本 session 已因該型踩雷兩次）。
- **★不做**：新增 `observer_mode` 旗標／改 `sim_runner` 的凍結語意本身（真有玩家時該條 H 不變量是對的）。

## §4 gate
1. **無玩家世界不凍**：合成床——指定 player team 後清 `player_id`、殺其 leader 且無 named → **世界照常推進**（tick 持續增長）、該隊走**正常繼承或滅團**、`game_over` 保持 false。
2. **有玩家仍凍**（不得誤傷）：`player_id != -1` 的同款情境 → `game_over=true`、`sim_runner` 回 `"game_over"`（現行行為不變）。
3. exam bed 短窗 smoke：day 欄與真實 tick **一致**（不再出現 loop-counter 假天數）。
4. det×3、constitution ≤75、headless 0-new、**fp intended-change**（無玩家長跑不再提早凍 → 世界更長、必然不同）。


## §5 R²delta（判決 CLEAN、2026-08-20）
**R² 親驗補強（無需改設計）**：
- `game_over = true` 全 `scripts/` **只命中兩處 production**（＋2 處 `headless_test` fixture，故意測凍結、非生產路徑）→ 我「已窮盡兩處」的宣稱**成立、零遺漏**。
- ★**`choose_heir` 那條第二凍結路（`sim_runner:73-74`）在 `player_id==-1` 時結構性不可達**：三個呼叫源全部自帶 gate（`event_system:39` 明確 `player_id != -1 and team == player_team`；`encounter_system:1376` 開頭 `if state.player_id == -1 or state.game_over: return`；`player_command_system:924` 屬 pending 回應下游、非入口）→ **不是我漏掉，是它本來就安全**；T1 兩處守衛屬 defense-in-depth。
- ★**`player_id` 單向性親驗無反例**：全 `scripts/simulation/` 的 8 處 `player_id =` 賦值**沒有任何一處寫回 `-1`** → 真玩家一旦設定不會被意外清空；唯一會變回 -1 的是 T2 那處（故意的）。
- ★**既有慣例佐證單一權威設計選對了**：codebase 大量「玩家豁免自動決策」的 gate 本來就寫成複合條件 `and state.player_id != -1`（如 `faction_ai:4250`、§4a 紮根）→ **T2 清 `player_id` 這一個動作會一次性讓所有豁免 gate 自動失效**、原 player team 自動變回受 AI 決策，**不需逐一改 gate**。

### ★T4（採納 R② 加固建議、但**改置放位置**）：偵測「忘了 T2」
R② 指出 T1 只擋**凍結**，擋不住**忘了 T2 → 那支 player team 因既有豁免 gate 整跑呆滯**（世界存在性受損的較輕版：一隊被特權凍結）。
- **R² 原建議**：觀察者床 setup 收尾斷言 `player_id == -1`。
- **★我改置放位置**：**放在床裡的斷言，依賴的正是它要抓的那份紀律**（床沒呼 T2，多半也不會呼那個斷言）。改成 **production 側一次性守衛**：`sim_runner.advance_tick` 中，若 **`player_pos == Vector2i(-1,-1)`（呼叫端宣稱無玩家）卻 `state.player_id != -1`（state 說有玩家）** → **`print` 一次** `[ObserverGuard] 呼叫端無玩家座標但 state.player_id=%d 未清：該隊將被既有玩家豁免 gate 排除在 AI 決策外（觀察者跑法請清 player_id）`（一次性旗標、不每 tick 洗版）。
- **理由**：這是**兩個來源互相矛盾**的結構性偵測（caller 說沒玩家、state 說有），不靠任何人記得呼什麼；成本一行 print。
