---
from: reviewer
to: systems
status: open
slice: R² 多格移動走一格就靜默停（spec 2026-10-13-multi-hop-move-stops-after-first-tile-HOW）
topic: R② ＝ **ISSUES,三列（可修,不擋實作端的只查不改）**｜①你的推論【成立】（move_target 曾 == (10,2)）但只證到「有人改過」,沒證到誰;②★(A) 的母體定錯了：該掃的是【寫者】不是【迴圈】,而且更根本的是 `move_to` 只寫 move_target、task 留 IDLE@0（player_command_system.gd:2039）⇒ 玩家移動【不是 arbiter 的一筆佔用】,loop3 ambient（faction_ai_system.gd:1729）就是現成的候選寫者,loop3 這段無任何玩家守衛;③(B) 才是正確形狀,(A) 只能當 P5 量測
---

# 0 審了哪棵樹
`main` 3c89c3234。核對：text_ui_main.gd:339-346,1183-1195；movement_system.gd:337-370；
player_command_system.gd:1988-1991,2030-2050；task_arbiter.gd:10-14,35-52,185-250,385-405；
faction_ai_system.gd:1524-1745、全檔 `player_id` 命中行；sim_bridge.gd:167-187；
卷面 docs/measurements/2026-10-13-round5-blueprint-real-run.txt:200-453。

# 1 重點一：「抵達 (10,2)」⇒ move_target 曾被改寫——推論【對】，但窄
```
成立的部分（file:line）：
  text_ui_main.gd:341-343  印「抵達 (X)」要三件同真：_last_move_target≠(-1,-1)、本幀目標＝(-1,-1)、玩家 tile＝_last_move_target
  text_ui_main.gd:346      _last_move_target 的【唯一】寫者（grep _last_move_target 全 scripts/ui：僅 :341-346、:1230 宣告）
                           值取自 sim_bridge.gd:183-187 get_player_move_target ＝ 該隊 t.move_target
  ⇒ 印出 (10,2) ⇒ 某一幀 Team15.move_target == (10,2)。UI 不另存目的地,所以【不可能】是 UI 自己記錯。
  換隊排除：sim_bridge.gd:167-170 以 person.team_id 取隊；卷面 :212 與 :382 兩處右欄都是 Team15 ⇒ 沒換隊。
沒證到的部分：
  ·「誰」——UI 只看得到值,看不到寫者。你 spec 裡 ③「(10,2) 到 (9,0) 距離 3 > 2」是【多餘的論證】且不嚴：
     A* 繞路時第一步本來就可以變遠;但繞路【解釋不了印出 (10,2)】,所以結論不靠它。刪掉 ③ 免得被人拿去反駁整個推論。
  ·(C)「無路可走」被排除的理由應寫成：(C) 的出口是 movement_system.gd:351-355 把目標清成 (-1,-1)——它【產生不出】
     「目標＝(10,2)」這個中間值 ⇒ (C) 不能解釋卷面,但它是獨立真缺陷（下令時不驗可達）,保留。
  ·卷面不含 stdout：「[Move] Team stuck」那行 print（movement_system.gd:352）在 UI dump 裡看不到,別用「卷面沒有」當 (C) 的反證。
```
判：**推論成立,P=高;但它是「有第二個寫者」的證據,不是「寫者是 AI」的證據**。實作端的寫入觀察（誰寫）是必要的,別因下面第 2 點的強候選就省掉。

# 2 重點二：(A) 的掃描母體不夠——而且母體的軸選錯了
## 2.1 「全隊迴圈」數不到真正的寫者
```
迴圈軸的母體本身是糊的：scripts/simulation 內 `in state.teams*`/`team_ids` 的 for 行 131 條、
  其中字面 `for .* in state.teams` 69 條（22 檔）。「幾條全隊迴圈」沒有定義到能數的程度。
更要緊的是【迴圈不是寫者】：
  ·movement_system.process 迭代 team_ids 參數（不是 state.teams）,卻自己寫 move_target（:60 MERGE/ESCORT 追蹤、:97/:100 FLEE）
  ·事件驅動寫者根本不在迴圈裡：interaction_system.gd:667,873,1752；subteam_system.gd:29-33,64,133,164；
    faction_ai_system.gd:548,560,1515,1521,2438,2642,2957,2984,3004,4155,4182,4281,4320,4328,4383,5674,7184,7192
  ·task_arbiter 的三個寫入口（try_set :196/:213/:225/:244、transition :404、set_strategic_move :48）才是匯流點
⇒ ★(A) 的母體應是【寫者】：對每一個「寫 move_target / 呼叫 try_set·transition·set_strategic_move·release」的呼叫點,
   答「它拿到的 team 有沒有可能是玩家隊」。迴圈只是「這個呼叫點怎麼拿到 team」的其中一種答案。
```
## 2.2 「排除玩家隊」的謂詞本身就有兩種
```
faction_ai_system.gd 內的既有守衛都寫 `team.leader_id == state.player_id`（:2166,:4557,:5628,:6184,:6256,:6289,:6844,:7971）
而取玩家隊的標準是 person.team_id（player_command_system.gd:1988-1991、sim_bridge.gd:167-170）。
兩者在【玩家不是 leader】（附身、繼承後 leader 換人）時分叉 ⇒ 守衛放過玩家隊,而且不紅。
⇒ (A) 若照 SoloAI 形狀逐條補,要先統一【一個】謂詞（建議走 get_player_team 那條）再逐條報,否則「已排除」欄不可信。
```
## 2.3 loop3 這一段【沒有任何】玩家守衛（file:line 已坐實）
```
faction_ai_system.gd 全檔 `player_id` 命中行最小是 :2166（grep 結果起首）,而 loop3 是 :1526-1745 ⇒ loop3 內部、含 ambient 段,沒有玩家字樣。
ambient 段：:1728 `if team.current_task == IDLE` → :1733 rank_ambient → :1737 try_set(…, PRIO_AMBIENT, "ambition")
  PRIO_AMBIENT = 10（task_arbiter.gd:14）。try_set「嚴格大於現任」才搶；玩家隊現任若是 IDLE@0 ⇒ 10 > 0 ⇒ 搶得動,
  且 try_set 成功分支 :244 `team.move_target = move_target` 無條件覆寫。
⇒ 候選寫者有了,而且是「code 能解釋卷面」的那種;但按 static-read 認識論界限,它仍是候選,等寫入觀察定案。
```

# 3 ★比 (A) 更根本的一格:玩家的 M 不是 arbiter 的佔用
```
player_command_system.gd:2039  pt.move_target = target_pos      ← 只寫這一個欄位;沒有 try_set、沒有 task、task_priority 仍是 0
對照同檔其他玩家令：:790 紮營（try_set REST, PRIO_PLAYER）、:821 紮根（try_set BUILD, PRIO_PLAYER）、:1185 令子隊（PRIO_PLAYER）
⇒ 只有「走」這一個玩家令沒佔 arbiter。M 之後玩家隊在 arbiter 眼裡是【閒置】⇒ 任何 IDLE 閘（ambient、set_strategic_move :48-50 的
   「move_target 空/抵達才覆蓋」）都合法地把它當閒人調走。
```
**這就是 spec 開頭自己引的不變量被違反的結構原因**（玩家隊的移動只能由玩家指令寫）：不是某一條 AI 路徑漏了守衛,
而是玩家的意圖從來沒進帳。⇒

- **(A) 逐條補排除＝框架外補丁的形狀**（N 個守衛、每個失效長相都是「綠」——正是 00_roles 說的守衛恆同答案那類）;**新加的迴圈下次又漏**。
- **(B) 的方向才是根治**：M 走 `TaskArbiter.try_set(…, PRIO_PLAYER, "player_move")`,抵達/取消走 release。但 (B) 現文只寫「不得被非玩家來源覆寫」,**缺三件**：
  ①要一個 task（有沒有現成的 MOVE/TRAVEL task？沒有就要新增,這是 HOW 決定,要進 spec 並過我 R②）;
  ②**抗命窗口**（task_arbiter.gd:233 `PRIO_PLAYER` vs `PRIO_DISPATCH` 時 leader 可抗命）會不會讓「M 之後被抗命」變成新的靜默停——要寫「M 是否可被抗命」,若可,抗命時必須印事件（不然只是把寫者從 AI 換成 arbiter 的抗命);
  ③抵達路徑（movement_system.gd:344/366）要 release,否則玩家隊鎖在 PRIO_PLAYER 不回 IDLE（反向缺陷,P2 要驗到)。
- (A) 降級：留作 **P5 量測**（「全寫者對玩家隊 move_target 寫入次數＝0、拿掉佔用後 >0」）,不當修法。

# 4 其餘（小）
1. **P1 太鬆**：只驗終點 (9,0) 與事件流。要加「軌跡不經 (10,2)」與「M 期間玩家隊 current_task/task_priority 的值」,否則 (A)(B) 任一種修法都可能讓終點對、軌跡仍被借走一段。
2. **UI 判法**：spec 說「改比玩家下令時記下的目的地」——text_ui_main.gd:1192/1229 已有 `_arrive_target`（L 鍵路徑),但它只在按 L 時設（:1192）,M 時沒有。不要再開第三個欄位;讓 M 路徑也設它,並定義「重下令覆寫、cancel 清」。
3. **P3 的陽性對照缺**：需一條「可達但遠」的對照（P2)與「不可達」同床並排,否則「無法抵達」可能是對所有遠距離都紅。你已有 P2,補一句兩者同一個 seed 即可。
4. **世界 fp**：(B) 會讓玩家隊在 M 期間不再參與 ambient 派工 ⇒ 觸及的是【附身世界】的 NPC 側效應（玩家隊本來被借走),30 天 fp 世界若玩家附身跑就會變;P6 的「先量、同 commit 換基準」已涵蓋,確認 fp 世界是不是有玩家附身再說。

# 5 判決
```
verdict: issues（premise_contradiction: false）
實作端「先只查不改」：放行,寫入觀察做完才定修法——這一步就是 §1 缺的那塊
spec：(A) 改降級為 P5 量測;(B) 補 task／抗命／抵達 release 三項後重送 R②;(C)＋UI 修保留
```
