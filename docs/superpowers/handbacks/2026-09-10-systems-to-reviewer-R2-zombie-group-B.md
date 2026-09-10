---
from: systems
to: reviewer
status: consumed
slice: 殭屍窗群乙（玩家的互動對象清單）
topic: ★R² 送審：`specs/2026-09-10-zombie-window-group-B-player-targets-HOW.md`｜★★普查只點名一站，而我去看的時候發現它【不完整】：有【兩個寫入端】（`interaction_system:298` 普查沒點到）＋【一個沒人做的清除】（`erase_teams` 清 `team_intel` 卻不清 `player_pending_targets`）⇒ 玩家看到的不是「活了一 tick 的殭屍」，是**一個指向已刪除物件的 id**｜★★★我要你打的第一格是【我標未驗的那一格】：我只讀了 `interaction_system` 的 append 兩行，沒讀它的語境
---

# ① 我查到的（★file:line）

```
寫入端①  player_command_system.gd:970 refresh_colocation_targets（★普查點名的那站）
寫入端②  interaction_system.gd:298-299                      ★★普查【沒有】點到
讀取端    player_api_mapper.gd:217／:183 can_interact／:56 has_pending_targets
★★★清除端：**沒有** —— erase_teams（world_state.gd:700-711）清了 team_intel 裡指向死者的 row，
   而它【沒有】清 player_pending_targets；唯一會清的是玩家換格與逐 action 的 .erase()。
```

⇒ ★**缺陷比「append 了一個殭屍」大一層**：id 進了清單之後那支隊被 erase，**id 還在清單裡**。

# ★我要你優先打的三格

```
(1)★★★【我標未驗的那一格】：interaction_system:298 我【只讀了 append 那兩行】，
   沒有讀它的完整語境 ⇒ 它的 append 可能有自己的前提（例如只在某種 forced_event 下跑）。
   ⇒ 請你確認【它是不是真的會 append 到殭屍】——
     ★而不是像我一樣「看到 append 就假設它會」。
     （★★若它其實不會，那 (b) 那一半是多餘的，spec 要縮。）

(2)★清除端該掛哪裡：我主張掛進 erase_teams（那個 chokepoint 已經在清 team_intel）。
   ★★理由是「dangling ref 的清除要掛在【物件消失的那一刻】，不是【下次有人來看的時候】」。
   ⇒ 請打：有沒有反例（例如 erase_teams 當下 player_pending_targets 還在被別人讀）？

(3)★★驗收①我加了一個【反向格】：那支隊【活著】時必須進清單。
   理由：沒有它，一個「永遠不 append」的 bug 會讓①判綠。
   ⇒ 請打：這個反向格夠不夠？（我懷疑它還不夠，因為「活著時會 append」與
     「活著且同格且沒在打架時會 append」是兩件事，而我只寫了前者。）
```

# ② 一個我要順便報備的【下一張票的種子】

```
erase_teams 已經在清 team_intel，本票再加一個 player_pending_targets
⇒ ★那個 chokepoint 上到底該清幾個容器？目前是【想到一個補一個】。
⇒ ★★這與 is_live_actor 那張是同一個形狀（指向死者的參照散在各處），
  ★★★值得一張獨立普查票：掃所有存 team_id 的容器，逐個問「死的時候誰清它」。
⇒ 我還沒開，先寫在 spec §⑤ 當種子。★你若覺得它應該現在就開，說一聲。
```
