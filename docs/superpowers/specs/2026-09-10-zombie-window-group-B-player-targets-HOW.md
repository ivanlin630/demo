# HOW spec：殭屍窗群乙 —— 玩家的互動對象清單裡有死人

owner: systems ｜ 2026-09-10 ｜ 上游：`is_live_actor` 普查（群甲已落地）
blueprint 備註：**它是玩家面，用戶下次開玩前落地最好**，但不為它打亂甲先——★甲已完成 ⇒ 現在是它。

---

## ① 現況：★不是一個站，是【兩個寫入端 ＋ 一個沒人做的清除】

普查只點名了一站，而我去看的時候發現它**不完整**：

```
寫入端①  player_command_system.gd:970  refresh_colocation_targets
          for other_id in state.teams: … if 同格 且 combat_target == -1
                                        ⇒ player_pending_targets.append(other_id)
          ★殭屍隊同格 ⇒ 進清單
寫入端②  interaction_system.gd:298-299  ★★【同型另一處】——普查沒點到它，
          它也 append 到同一個 player_pending_targets
讀取端    player_api_mapper.gd:217（玩家看到的清單）／:183 can_interact／:56 has_pending_targets
★★★清除端：**沒有**。
   `erase_teams`（world_state.gd:700-711）會清 `team_intel` 裡指向死者的 row，
   ★而它【沒有】清 `player_pending_targets`。
   唯一會清的是 `clear_pending_targets`（玩家換格時）與逐 action 的 `.erase(target_id)`。
```

⇒ ★**所以真正的缺陷比「append 了一個殭屍」大一層**：
**一個 id 進了清單之後，那支隊死掉、被 erase 了，那個 id 還留在清單裡。**
⇒ ★★玩家看到的不是「一個活了一 tick 的殭屍」，是**一個指向已刪除物件的 id**。

---

## ② 修法：★三處，而第三處才是結構解

```
(a) 寫入端①：refresh_colocation_targets 的迴圈加 `if not state.is_live_team(other_id): continue`
(b) 寫入端②：interaction_system:298 append 前同一個判斷
    ★★這兩處是【同一條規則的兩個副本】⇒ 抽一個 `_can_target(state, tid)` 兩邊共用，
      ★★★否則下一次只會有一邊被改（這正是本 spec 存在的理由：普查只點到一邊）。
(c) ★★★清除端（結構解）：把 `player_pending_targets` 的清理掛進 `erase_teams`
    —— **那個 chokepoint 已經在清 `team_intel` 了**，多清一個是同一個地方、同一個理由。
    ⇒ ★理由一句：**dangling ref 的清除要掛在【物件消失的那一刻】，不是掛在【下次有人來看的時候】。**
```

★**為什麼 (a)(b) 不能省**：`erase_teams` 在 **tick 尾**；
從判死到那一刻之間，玩家仍可能按下互動鍵 ⇒ **(c) 治已刪除，(a)(b) 治待刪除**。

---

## ③ 驗收

| # | 格 | 判準 |
|---|---|---|
| ① | **待刪除不進清單** | 構造：同格有一支【已判死未 erase】的隊 ⇒ 按互動鍵 ⇒ `player_pending_targets` **不得**包含它；★成對對照：那支隊【活著】時**必須**進清單（否則這格會被一個「永遠不 append」的 bug 判綠） |
| ② | **已刪除要離開清單** | 構造：先讓 id 進清單，再讓那支隊死透（跑到 `erase_teams`）⇒ 清單裡**不得**還有它 |
| ③ | **★兩個寫入端都咬得到** | 對 `interaction_system` 那條路徑重跑①——★★**不得只驗 `refresh_colocation_targets`**（普查只點到一邊，而這張票的價值有一半在另一邊） |
| ④ | **玩家看到的東西** | `player_api_mapper:217` 產的清單裡不得出現死者 id；★`can_interact`（:183）對死者必須是 false |
| ⑤ | **fp** | ★會變（清單是 state 的一部分）⇒ 同群甲：**跑在構造場景上**，並附歸因（差異＝那個 id 在不在清單） |
| ⑥ | **既有紅不變** | 同群甲：那組既有 FAIL 修前後同一組，不得變多 |

★**誠實限**：①②③ 都是構造場景 —— ★★**不得用自然長跑驗**（同群甲的理由：
「沒觸發」與「沒做」在自然窗裡分不開，而群甲已經量到 `10000 tick ≒ 6.9 天` 滅團 0 次）。

---

## ④ 風險

```
①★清單少了一個目標 ⇒ 玩家的可選項變少。**這是本票的目的，不是副作用**。
②★★`erase_teams` 多清一個容器 ⇒ 那個 chokepoint 的成本 O(pending) —— pending 是小陣列，
   ★可忽略，但要在交件裡寫出它的實際長度（★★不要假設它小，量一下）。
③★★★`interaction_system` 那條路徑我【只讀了 append 那兩行】，沒有讀它的完整語境
   ⇒ 標【未驗】：那裡的 append 可能有它自己的前提（例如它只在某種 forced_event 下跑）。
   ⇒ R² 或實作要先確認**它是不是真的會 append 到殭屍**，而不是我看到 append 就假設它會。
```

---

## ⑤ 這張票【不做】

```
①不改 clear_pending_targets 的「換格才清」語意 —— ★那是玩法設計（換格取消互動），不是 bug
②不碰群丙（畫面閃現）與 A 其餘 25、C 6
③★不擴大到「所有 dangling ref 的普查」—— 那是另一張票（★而我認為它值得開，見下）
```

★**而我要記一個【下一張票的種子】**：
`erase_teams` 已經在清 `team_intel`，本票再加一個 `player_pending_targets`
⇒ ★★**那個 chokepoint 上到底該清幾個容器？** 目前是【想到一個補一個】。
⇒ ★★★這與 `is_live_actor` 那張是同一個形狀（**指向死者的參照散在各處**），
   **值得一張獨立的普查票**：掃所有存 `team_id` 的容器，逐個問「死的時候誰清它」。
---

## ⑥ ★★★R² 回件（2026-09-10）：(3) 已補，其餘兩格過 ⇒ 補完直接 dispatch

### (1) 我標未驗那格：★**真的會**，而且是【最常見的那條路】，不是邊角

```
interaction_system.gd:245  if not state.teams.has(id_a) or not state.teams.has(id_b): return
   ⇒ ★★【半個守衛】第三次現形（前兩次：vision_system:27／本檔）——
     用 has() 不用 is_live_team()；pending_erase 的隊 has() 仍是 true ⇒ 擋不住。
:260  if npc == null or pt == null: return
   ⇒ 同理：get() 對 pending_erase 的隊回的是【活物件】不是 null ⇒ 也擋不住。
:296-299  路徑 4（NPC 無敵意、非 diplomacy/loot、玩家可主動選互動）⇒ append
   ★★★這是【預設分支】：一支同格的殭屍隊只要 current_task 不是 TASK_DIPLOMACY／TASK_LOOT
     就會落進來 —— 不是罕見 forced_event，是【同格且平靜相遇】這個最常見情境本身。
```

⇒ ★**我猜錯的方向值得記**：我猜「它可能有自己的前提所以更難觸發」，
**查完是相反 —— 它是【排除兩條特殊路之後的 default】，比我設想的更容易觸發**。
⇒ ★★**(b) 那一半不是多餘的，是這張票裡風險比 (a) 更高的那一半。**

### (2) 清除端掛 `erase_teams`：★沒找到反例

```
erase_teams 是單執行緒、單點、tick 尾同步跑完的批次清理（GDScript 無並行）
⇒ 沒有「清到一半被別的東西讀走」的交錯。
player_pending_targets 唯一讀取端（player_api_mapper）是【玩家發查詢指令時才讀】，
不是背景常駐 ⇒ 不會與 erase_teams 同時進行。
⇒ 實作位置：world_state.gd:707-711 那個 for-loop 直接加一行 player_pending_targets.erase(dtid)。
```

### (3) ★★驗收①的反向格：我自己懷疑得對 —— **不夠，拆成兩條精確前提**

```
★兩個寫入端的精確前提【不一樣】：
  寫入端①(player_command_system:970-979)  同格 ＋ combat_target == -1
  寫入端②(interaction_system:296-299)     同格 ＋ current_task 非 diplomacy/loot
★★若反向格只寫「活著時必須進清單」，一個【前提被意外收窄】的退化
  （例如多加了「且要 named leader 在場」）在某些佈局下會「有時進、有時不進」，
  ★★★而寫得夠寬鬆的反向斷言會照樣判綠。
⇒ 反向格拆兩條（取代原本那一條）：
  反向格a：同格 ＋ combat_target == -1 ＋ 活著 ⇒ 必進清單
  反向格b：同格 ＋ current_task 非 diplomacy/loot ＋ 活著 ⇒ 必進清單
⇒ 這樣【永遠不 append】與【前提被意外收窄】兩種退化都會被抓到，不只前者。
```

### (4) 種子票：R² 同意值得開，★但不是現在

```
「散在各處的 team_id 容器普查」——★母體形狀可直接照搬 is_live_actor 那張
（所有存 team_id 的容器，逐個問「死的時候誰清它」）。
★★而我要在此把母體【擴一半】：R² 這輪讓「半個守衛」第三次現形
  ⇒ ★★★那張票的母體要涵蓋兩種站點：
     ①【誰在迭代／存 team_id】（原本的）
     ②★【誰拿 state.teams.has() 當存活守衛】（新加的——它看起來已經被想過了，而它沒有）
```
