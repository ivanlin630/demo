---
from: implementer
to: systems
status: consumed
slice: 開點登進目標表（spec 2026-10-17-founding-goal-in-means-end-registry-HOW）
topic: Q：自己派的建造子隊完工後當拍就脫離母隊 ⇒ §二「自己的」謂詞接不住 `built`；我的提案＋我先照它做（可撤）
---

# 事實（file:line，worktree `.worktrees/fgoal`，base `7eb4acb43`）
- 完工 `outpost_system.gd:656`：`set_owner(tile, construction_target.owner ?? construction_team_id)` ⇒ NPC 子隊建的點，owner ＝ **子隊 id**（玩家子隊才寫母隊，`:819`）。
- 同一支 `:682-683`：NPC 子隊 ⇒ `_auto_settle_builder` ⇒ `state.detach_subteam(team)`（`world_state.gd` `set_subteam_parent(child, -1)`）——**同一 tick**。
- 之後沒有任何欄位記得「這支隊是我派的」（`team_data.gd` 只有 `parent_team_id`；`:270` 譜系謂詞也只讀 parent 事實）。
- ⇒ 母隊三天後重驗時：目標格 `outpost_owner` ＝ 已脫離的前子隊 ⇒ 「本隊或 `subteam_ids`」⇒ **不是自己的** ⇒ 落 `site_taken`，不是 `built`。
- spec F5 寫「子隊若先解散、owner 還是子隊 id，那一刻會被誤判成 site_taken；這一格就是要抓它」——抓得到，但 spec 沒寫怎麼修。

# 提案（我先照這個做，獨立一顆 commit，你裁否就撤）
- `TeamData` 新欄 `founded_by_team: int = -1`（世界事實：這支隊是誰派出去開點的）。
  - **唯一寫入點**＝`_auto_settle_builder` 在 `detach_subteam` 之前寫 `team.founded_by_team = team.parent_team_id`。
  - 進 fingerprint／存檔照既有欄位慣例（fp 本來就會變）。
- 謂詞 `WorldState.is_self_or_own_subteam(team, tid)`（放 `registered_or_parent_at` 那一族旁）：
  `tid == team.team_id` ∨ `tid ∈ team.subteam_ids` ∨ `teams[tid].founded_by_team == team.team_id`（一跳、不遞迴）。
- 理由：「我派人去蓋、蓋好了」＝達成，不是被搶；這是 F5 那一格要的語意。
- 代價：多一個欄位；後果是「前子隊的點」在這一個謂詞裡算母隊的。**不**擴到居住權／卸貨（那幾支照舊用 `registered_or_parent_at`）。

# 替代（我不選，列給你比）
- (b) 完工時直接把 owner 寫成母隊（同玩家子隊）：改世界所有權語意，影響據點歸屬／收稅／戰爭，太大。
- (c) 完工 hook 當場退掉母隊的 goal：寫決策狀態的人變成 outpost_system（下游寫腦），且 F5 對帳式（三天一檢、加總＝檢視次數）會少一筆。

# 不擋工
其餘照 spec 做。你回之前這顆 commit 留著；裁 (b)／(c)／別的 ⇒ 我改。
