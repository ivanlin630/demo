---
from: systems
to: reviewer
status: open
slice: 殭屍窗群甲（決策污染兩站）
topic: ★R² 送審：`specs/2026-09-10-zombie-window-group-A-decision-poisoning-HOW.md`｜★★而我要先講一件比那張票大的事：我去驗 implementer 的前提（「壽命比那一 tick 長」）時查到，`sim_runner` 有**兩條路會整段跳過 `_step_cleanup_extinct_teams`**（`:354` 伏擊早退／`:272-281` encounter 分支）⇒ **殭屍不是活一 tick，是活過整個 encounter**｜★★★我要你打的三格都在內文，其中一格是【我沒有查就寫進 spec 的】，我標了
---

# ① 我查到的根（★file:line，請你獨立覆核）

```
sim_runner.gd:379  _step_cleanup_extinct_teams(state)   ← 清除掛在 tick 尾
①sim_runner.gd:354  if pass_r["result"] == "player_turn": return "player_turn"
   ⇒ 伏擊起 encounter ⇒ ★這一 tick 走不到 :379
②sim_runner.gd:272-281  if state.encounter_active:
   ⇒ ★★整個 tick body 被 encounter 分支取代 ⇒ **encounter 多長，cleanup 就多久沒被呼叫**
★★★而 `WorldEvents.consume_and_clear` 在 encounter 那條路【有】被特別補上
   （:279 註解逐字寫著「encounter 路也要，否則跨 tick 存活」）
   ⇒ **同一個「跨 tick 存活」的問題被想過一次，而 `teams_pending_erase` 沒有跟著補。**
```

⇒ ★**所以群甲那兩站是症狀，根是【清除可以被跳過】。**
★★而我認為正確的形狀不是兩處各補一行，是把清除搬到**所有 return 路徑都會經過**的地方
（`advance_tick` 包一層 wrapper，拿到結果後、回傳前呼一次）
—— ★★★這樣**下一個新增的 early return 不會再製造同一個洞**。

# ★我要你優先打的三格

```
(1)★★★【我沒有查就寫進 spec 的那一格】：encounter 期間清除死隊，
   encounter 自己可能持有 team ref（玩家正在打的那一隊）
   ⇒ 若那一隊就是被判死的那一隊，清除會不會把 encounter 的地基抽掉？
   ★我標了【未驗】，但我要你直接查，因為它決定 wrapper 該放哪裡
     （放 body 之外／放 body 之內但 encounter 分支之後／encounter 期間不清只在結束時清）。

(2)★在 early-return 路徑上跑清除的安全性：我的論證是
   「那條路早退之後本 tick 後面的系統都不會跑 ⇒『多系統持 team_ids 快照』的原始理由不成立」。
   ★★這是我【讀出來的】不是量出來的 ⇒ 請你找反例
     （例如 bridge 在 player_turn 之後、下一次 advance_tick 之前會不會碰 team refs）。

(3)★★驗收⑤我寫成【反向斷言】：fp【必須變】，fp 相同反而是紅燈
   （表示兩站的守衛沒咬到任何東西）。
   ⇒ 請打：這個反向斷言會不會太脆？（例如某個 seed 下那兩站本來就沒觸發 ⇒ fp 不變是合理的）
     ★若會，正解可能是「窗要選到【確定有滅團】的那一段」而不是放棄這個斷言。
```

# ② 兩站本身（★其中一站有個我覺得你會有興趣的形狀）

```
npc_combat_system.gd:150  team_strength 的護衛加總 ⇒ 殭屍護衛灌水戰力，而戰力餵決策
vision_system.gd:41       被觀測側的迴圈
  ★★★而觀測者那一側（:27）【已經有守衛】：`if not state.teams.has(tid): continue`
     ⇒ **它知道有這個問題，卻用了錯的謂詞** —— has() 認不出 pending_erase。
  ⇒ 這是「半個守衛」的形狀：★它讓人以為這裡已經被想過了。
```

# ③ 這張票會改變行為（★所以驗收的主詞換了）

```
★本批第一張【不是零行為改變】的票 ⇒ 不得拿「fp 不變」當綠。
驗收主詞換成【差異是可解釋、可歸因、有界的】：
  ①根：encounter 期間 teams_pending_erase 必須是空的（含拿掉 wrapper 就紅的對照）
  ②窗長度：判死到消失經過幾 tick（修前 >1，修後 =1）
  ③戰力灌水：逐次呼叫值分布，★灌水那幾次要具名（哪 tick／哪隊／灌多少）
  ④belief 污染：指向「已判死未 erase」的 team_intel row 數
     ★★若修前也是 0 ⇒ 那是【本窗不可達】，要如實回報，不得把 0 讀成修好了
  ⑤fp 必須變（反向斷言，見上面 (3)）
  ⑥既有紅不得變多（recovery_r1_test／headless_test 那組）
```
