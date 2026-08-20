---
from: systems
to: implementer
status: open
topic: "[dispatch 觀察者世界永不凍結(R²=CLEAN、下輪長考前置)·spec=2026-08-20-observer-world-never-freezes-HOW.md(含 §5 R²delta 與新增 T4)·★與你手上那張『大考床兩修』票【合併成同一支交付】(同族、都在處理玩家中心假設)·根:warring_states.json 有 player 區塊→headless 仍指定 player team(歷來都是 Team48)→該隊 leader 死+named 空→event_system:74 game_over=true→sim_runner:70-72 整 tick 不推進;大考 warring leg 就這樣 day70 凍死、其後 290 天假列;★retro-audit 確認【至少 4 個舊 run 同款】(2 個高風險宣稱 3 個月但疑似只真跑不到 1 個月)·★T1 production 守衛(兩處、R² 已親驗窮盡):event_system:74 與 player_command_system:926 加『state.player_id == -1 → 不得設 game_over』,改走既有 NPC 路(best named→anon 晉升→皆無則滅團);★R² 親追確認 choose_heir 那條第二凍結路在 player_id==-1 時【結構性不可達】(三個呼叫源全自帶 gate)→不必動·★T2 量測側:觀察者長跑(exam bed 等)setup 後清 state.player_id=-1 + 清 player_forced_event、床頭註明理由;★R² 紅利:codebase 既有一票『玩家豁免自動決策』gate 本來就寫成 and state.player_id != -1(faction_ai:4250/§4a 紮根等)→清這一個欄位會【一次性讓所有豁免 gate 自動失效】、原 player team 自動變回受 AI 決策,不必逐一改·★T4 新增(採 R② 加固但改置放位置):sim_runner.advance_tick 一次性守衛——若 player_pos==Vector2i(-1,-1)(呼叫端宣稱無玩家)卻 state.player_id!=-1(state 說有玩家)→print 一次 [ObserverGuard]...(一次性旗標不洗版)·★為何不照 R² 原建議放床裡:放床裡的斷言依賴的正是它要抓的那份紀律(床沒呼 T2 多半也不會呼斷言);放 production 是【兩個來源互相矛盾】的結構性偵測、不靠任何人記得·gate:①無玩家世界不凍(合成床:清 player_id 後殺該隊 leader 且 named 空→世界照常推進、該隊走正常繼承或滅團、game_over 保持 false)②★有玩家仍凍不得誤傷(player_id!=-1 同款情境→game_over=true、advance_tick 回 'game_over')③exam bed 短窗 smoke:day 欄與真 tick 一致(不再有 loop-counter 假天數)④T4 守衛真的 print(故意不清 player_id 跑三 tick)⑤det×3+constitution<=75+headless 0-new+fp intended-change(無玩家長跑不再提早凍→世界更長必然不同)·worktree feat/observer-never-freeze(或併你既有 branch)·完→handback to:systems·地基KEEP"
---

# dispatch：觀察者世界永不凍結（R²＝CLEAN、**下輪長考前置**）

spec＝`docs/superpowers/specs/2026-08-20-observer-world-never-freezes-HOW.md`（含 §5 R²delta 與新增 **T4**）。
★**與你手上那張「大考床兩修」票合併成同一支交付**（同族：都在處理玩家中心假設）。

**根**：`warring_states.json` 有 `player` 區塊 → headless 仍指定 player team（歷來都是 **Team48**）→ 該隊 leader 死 + named 空 → `event_system:74` `game_over=true` → `sim_runner:70-72` **整 tick 不推進**。大考 warring leg 就這樣 **day70 凍死**、其後 290 天假列；★**retro-audit 確認至少 4 個舊 run 同款**（2 個高風險：宣稱 3 個月、疑似只真跑不到 1 個月）。

- **T1 production 守衛**（兩處，R² 已親驗窮盡）：`event_system:74` 與 `player_command_system:926` 加「**`state.player_id == -1` → 不得設 `game_over`**」，改走既有 NPC 路（best named → anon 晉升 → 皆無則滅團）。
  ★R² 親追確認 **`choose_heir` 那條第二凍結路在 `player_id==-1` 時結構性不可達**（三個呼叫源全自帶 gate）→ **不必動**。
- **T2 量測側**：觀察者長跑 setup 後清 `state.player_id = -1` + 清 `player_forced_event`、床頭註明理由。
  ★**R² 紅利**：codebase 既有一票「玩家豁免自動決策」gate 本來就寫成 `and state.player_id != -1`（`faction_ai:4250`、§4a 紮根等）→ **清這一個欄位會一次性讓所有豁免 gate 自動失效**、原 player team 自動變回受 AI 決策，**不必逐一改**。
- **★T4 新增**（採 R② 加固、但**改置放位置**）：`sim_runner.advance_tick` **一次性守衛**——若 `player_pos == Vector2i(-1,-1)`（呼叫端宣稱無玩家）**卻** `state.player_id != -1`（state 說有玩家）→ **print 一次** `[ObserverGuard] …`（一次性旗標、不洗版）。
  ★**為何不照 R² 原建議放床裡**：放床裡的斷言**依賴的正是它要抓的那份紀律**（床沒呼 T2，多半也不會呼那個斷言）；放 production 是**兩個來源互相矛盾**的結構性偵測，不靠任何人記得。

**gate**：①無玩家世界**不凍**（合成床：清 `player_id` 後殺該隊 leader 且 named 空 → 世界照常推進、該隊走正常繼承或滅團、`game_over` 保持 false）②★**有玩家仍凍、不得誤傷** ③exam bed 短窗 smoke：**day 欄與真 tick 一致** ④T4 守衛真的 print（故意不清 `player_id` 跑三 tick）⑤det×3 + constitution ≤75 + headless 0-new + **fp intended-change**。

worktree `feat/observer-never-freeze`（或併你既有 branch）。完 → handback to:systems。地基 KEEP。
