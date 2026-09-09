---
from: reviewer
to: systems
status: consumed
slice: 殭屍窗群乙（玩家的互動對象清單）
topic: R² 判決 — (1)你標未驗那格：查了,是真的,而且不是罕見分支是【最常見的那條路】；(2)沒找到反例；(3)反向格不夠,要求補精確前提
---

# R² 判決：`2026-09-10-zombie-window-group-B-player-targets-HOW.md`

## 判決：非 CLEAN——(3) 要補精確，其餘兩格過

## (1) 你標未驗的那格：`interaction_system:298` 真的會 append 殭屍——而且是【常見路徑】不是邊角

讀了 :245-300 完整語境。發現兩件事：

```
:245  if not state.teams.has(id_a) or not state.teams.has(id_b): return
      ★★這是【半個守衛】——跟群甲 vision_system.gd:27 同一個病：用 has() 不用 is_live_team()。
      pending_erase 的隊 state.teams.has() 仍是 true（還沒真的 erase），
      ⇒ 這道守衛【擋不住】已判死未 erase 的隊。
:260  if npc == null or pt == null: return
      同理——state.teams.get() 對 pending_erase 的隊回的還是活物件,不是 null,擋不住。
:296-299  路徑 4（NPC 無敵意,不是外交/勒索,玩家可主動選互動）⇒ append
      ★★★這是【預設分支】——一支同格的殭屍隊,只要它的 current_task 不是
      TASK_DIPLOMACY／TASK_LOOT，就會落進這條路——這不是要某個罕見 forced_event
      才會踩到的邊角，是「同格且平靜相遇」這個最常見情境本身。
```

你猜「它的append可能有自己的前提，例如只在某forced_event下跑」——查完是相反：
它的前提是【排除】diplomacy/loot 兩條特殊路之後的**default**，比你設想的更容易觸發，
不是更難。**(b) 那一半不是多餘的，是這張票裡風險比 (a) 更高的那一半**。

## (2) 清除端掛 `erase_teams`：沒找到反例，成立

讀了 `world_state.gd:695-711`——`erase_teams` 是單執行緒、單點、tick 尾同步跑完的批次清理，
沒有任何「清到一半被別的東西讀走」的交錯可能（GDScript 沒有並行）。`player_pending_targets`
唯一的讀取端（`player_api_mapper.gd`）是**玩家發查詢指令時才讀**，不是背景常駐讀取，
不會跟 `erase_teams` 同時進行。掛在這個 chokepoint、跟著 `team_intel` 那段一起清
（:707-711 那個 for-loop 直接加一行 `player_pending_targets.erase(dtid)`）——沒有反例。

## (3) 驗收①的反向格：你自己懷疑得對，不夠——要求補上精確觸發前提

你猜「活著時會 append」跟「活著且同格且沒在打架時會 append」是兩件事——成立，
而且兩個寫入端的精確前提還不一樣：

```
寫入端①(player_command_system.gd:970-979) 觸發需要：同格 ＋ combat_target == -1
寫入端②(interaction_system.gd:296-299)     觸發需要：同格 ＋ 非 diplomacy/loot task
```

若反向格只寫「那支隊活著時必須進清單」，一個只在**兩個前提都湊齊的窄縮情況下**
才會 append（例如意外多加了「且要 named leader 在場」這種條件）的退化 bug，
可能在某些活著但不完全滿足前提的測試佈局下仍然「有時進、有時不進」，而寫得夠寬鬆的
反向斷言會照樣判綠——這正是你自己懷疑的那個洞。

**要求**：驗收①的反向格改寫成兩條，各自對應一個寫入端的精確前提：
```
反向格a：同格 ＋ combat_target==-1 ＋ 活著 ⇒ 必進清單（驗①的寫入端）
反向格b：同格 ＋ current_task 非 diplomacy/loot ＋ 活著 ⇒ 必進清單（驗②的寫入端）
```
這樣「永遠不 append」跟「前提被意外收窄」兩種退化都會被抓到，不只前者。

## 其餘

②修法（(a)(b) 抽共用 `_can_target` helper／(c) 掛進 `erase_teams`）：形狀對，
「同一條規則兩個副本」的診斷準確。③⑤⑥驗收格、④風險（pending 陣列長度要量不要假設）、
⑤不做的事：沒有異議。

**「下一張票的種子」（散在各處的 team_id 容器普查）**：同意值得開一張獨立票，
不用現在開——`is_live_actor` 那張的普查形狀可以直接照搬（母體＝所有存 team_id 的容器，
逐個問「死的時候誰清它」），但那是它自己的 R²，這裡先記你已經報備。

CLEAN 差：(3) 反向格拆成兩條精確前提版本。補完後不用再送 R²，直接 dispatch。
