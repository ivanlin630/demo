---
from: systems
to: implementer
status: consumed
slice: 殭屍窗群乙（玩家的互動對象清單）—— ★DISPATCH
topic: ★派工：`specs/2026-09-10-zombie-window-group-B-player-targets-HOW.md`（R² 補完即就緒，不再送審）｜★★而我要先講 R² 打回來的那件：我猜 `interaction_system:298` 的 append「可能有自己的前提所以更難觸發」，★★★查完是【相反】——它是排除 diplomacy/loot 之後的 **default 分支**，也就是「同格且平靜相遇」這個最常見情境本身 ⇒ 它是這張票裡風險比另一半更高的那一半
---

# ① 派工

```
spec  docs/superpowers/specs/2026-09-10-zombie-window-group-B-player-targets-HOW.md
R²    非 CLEAN 一格（反向格要拆兩條）⇒ 已補 ⇒ ★R² 明示補完不用再送審，直接 dispatch
blueprint 備註：★★它是玩家面，**用戶下次開玩前落地最好**
```

# ② ★★缺陷比普查點名的大一層

```
普查點名一站，而實際是【兩個寫入端 ＋ 一個沒人做的清除】：
  寫入端① player_command_system.gd:970  （普查點名的）
  寫入端② interaction_system.gd:296-299 （★普查沒點到，而 R² 查證它是【最常見的那條路】）
  清除端  ★★★**沒有** —— erase_teams 清了 team_intel 卻沒清 player_pending_targets
⇒ id 進了清單之後那支隊被 erase，**id 還在清單裡**
⇒ 玩家看到的不是「活了一 tick 的殭屍」，是【一個指向已刪除物件的 id】。
```

# ③ 修法三處（★第三處才是結構解）

```
(a) 寫入端①加 is_live_team 判斷
(b) 寫入端②同一個判斷 ⇒ ★★兩處抽一個 `_can_target(state, tid)` 共用
    ★★★否則下一次只會有一邊被改 —— 這正是本 spec 存在的理由（普查只點到一邊）
(c) ★清除掛進 erase_teams：world_state.gd:707-711 那個 for-loop 直接加一行
    `player_pending_targets.erase(dtid)`（R² 已確認沒有交錯風險）
★一句：**dangling ref 的清除要掛在【物件消失的那一刻】，不是【下次有人來看的時候】。**
★★而 (a)(b) 不能省：erase_teams 在 tick 尾，從判死到那一刻玩家仍可能按互動鍵
   ⇒ **(c) 治已刪除，(a)(b) 治待刪除。**
```

# ④ ★★★驗收①的反向格【拆成兩條】（R² 要求，理由值得看）

```
兩個寫入端的精確前提【不一樣】：
  ①同格 ＋ combat_target == -1
  ②同格 ＋ current_task 非 diplomacy/loot
★若反向格只寫「活著時必須進清單」，一個【前提被意外收窄】的退化
 （例如多加了「且要 named leader 在場」）會「有時進、有時不進」，
 ★★而寫得夠寬鬆的反向斷言會照樣判綠。
⇒ 反向格a：同格 ＋ combat_target==-1 ＋ 活著 ⇒ 必進清單
  反向格b：同格 ＋ current_task 非 diplomacy/loot ＋ 活著 ⇒ 必進清單
⇒ ★★★這樣【永遠不 append】與【前提被意外收窄】兩種退化都會被抓到，不只前者。
```

其餘驗收格照 spec：②已刪除要離開清單／③兩個寫入端都要驗（★不得只驗 refresh_colocation_targets）／
④玩家看到的清單與 `can_interact`／⑤fp 會變（跑構造場景＋附歸因）／⑥既有紅不得變多。

★**誠實限**：①②③ 全部跑【構造場景】——★★不得用自然長跑
（你自己量到的：`10000 tick ≒ 6.9 天` 滅團 0 次 ⇒ 自然窗裡「沒觸發」與「沒做」分不開）。

# ⑤ 一件要你量、不要假設的

```
erase_teams 多清一個容器 ⇒ 成本 O(pending)。★pending 應該是小陣列，
★★但交件裡要寫出它的【實際長度】——不要假設它小。
```

# ⑥ 種子（★不是這張票，寫給你知道它存在）

```
erase_teams 上到底該清幾個容器？目前是【想到一個補一個】。
⇒ 一張獨立普查票（R² 同意值得開、但不是現在），★而它的母體我已擴成兩種站點：
   ①誰在迭代／存 team_id
   ②★★誰拿 `state.teams.has()` 當【存活守衛】
     —— ★★★「半個守衛」今天第三次現形（vision_system:27／interaction_system:245／…），
        而它比完全沒守衛更危險：**它看起來已經被想過了。**
```
