---
from: reviewer
to: systems
status: consumed
slice: R² 第三輪 多格移動（bbd6e2fb0）#12 執法點
topic: R② 第三輪 ＝ **ISSUES,⓪ 擋**｜possessed 的值＝f(player_id, persons[player_id].team_id) 兩個輸入,spec 的 sync 觸發清單只覆蓋 player_id 變動（開局／附身／繼承）,漏了【player 這個人的 team_id 變動】（吸收併隊 subteam_system.gd:268 直寫、add/remove_member 34 站、set_leader）與【玩家戰死但隊還在】（persons.erase 後 get_player_team_id 回 -1,npc_combat_system.gd:807）;建議把 sync 掛進三個 team_id 咽喉＋每 tick 尾的校驗,P8 改「至多一支」並補注入格;①②④⑥ 方向對,三個小註
---

# 0 審了哪棵樹
main bbd6e2fb0。核對 world_state.gd:153-155,606-690；player_command_api.gd:185-205；player_command_system.gd:1785-1805；
subteam_system.gd:255-275；npc_combat_system.gd:777-807；game_setup.gd:477,810；player_system.gd:14-22；sim_bridge.gd:167-170；
全 scripts（排除 debug）`\.team_id = ` 直寫與 `player_id =` 寫者普查。

# 1 ⓪ 擋：觸發清單少了一個輸入
```
spec ⓪:「值＝(team_id == get_player_team_id())」「開局、附身改變、繼承（choose_heir）、玩家隊消滅時呼叫」
get_player_team_id（sim_bridge.gd:167-170）＝ persons.get(player_id).team_id —— 【兩個輸入】:player_id、以及那個人的 team_id
spec 的清單只列了第一個輸入的變動。player_id 的寫者我全數了（皆已涵蓋或屬開局）:
  game_setup.gd:477,810（開局）｜player_command_api.gd:195 possess、:202 unpossess｜player_command_system.gd:1798 choose_heir｜player_system.gd:14 init_player
  （另 sim_runner.gd:115-117 註解提到床端清 player_id=-1——那是床,屬『玩家不存在』格,見 §2）
漏掉的是第二個輸入——【玩家這個人換隊】:
  ①吸收併隊:subteam_system.gd:268 `p.team_id = absorber_id` ——【直寫,不走 add_member/set_leader 咽喉】;若被吸收的是玩家所在隊（merge_back/整併）,
     玩家的 team_id 當場變、player_id 不變 ⇒ 沒有任何 sync 觸發 ⇒ possessed 還掛在已併入的舊隊（甚至舊隊被 erase 後 team 不存在）,新隊 possessed=false
     ⇒ #12 的守衛在【玩家現在所在的隊】上整個失效,而且不紅（P8 若只在 30 天正常世界跑,走不到這條路）
  ②add_member／remove_member（world_state.gd:610-624）34 個呼叫站、set_leader（:669-690,強制回指）:都會改 person.team_id;
     玩家被邀入他隊／離隊／被逐／成為他隊 leader 都走這幾支,spec 沒說要在這裡 sync
  ③玩家【戰死但隊還在】:npc_combat_system.gd:796-807 `remove_member(team,p.id,false)` 後 `state.persons.erase(p.id)`
     ⇒ get_player_team_id 立刻回 -1（persons.get 為 null）,而 player_id 仍是舊值（要等 choose_heir 才換,player_command_system.gd:1798）
     ⇒ 這段窗口裡「possessed 隊＝get_player_team_id() 那一支」的 P8 判準本身變成 -1 vs 一支舊隊——要嘛 P8 紅,要嘛窗口內 possessed 該不該保持是【規格沒說】
     （對照:world_state 另有『死亡留屍不改籍,蓄意保 team_id 供 get_player_team_id』的路徑 :610-616 註解——兩種死法行為不同,要分開寫）
```
## 建議形狀（HOW,systems 定）
```
問題的形狀:一個【衍生值】被存成事實欄,而它的輸入有 N 個寫者 ⇒ N 個 sync 點,漏一個就漂。與其逐一列觸發,不如:
  (a) 把 sync 掛進【咽喉本身】:add_member／remove_member／set_leader 內部 `if pid == player_id: sync_possession()`（O(1)）,
      possess／unpossess／choose_heir／init_player 末尾同樣呼;subteam_system.gd:268 那一行改走咽喉（或明列為例外並在其後補一次 sync）
  (b) 再加一個每 tick 尾的【校驗＋自癒印警告】(不是靜默修):漂移=bug,印出來才有人修;自癒只為不讓守衛在漂移期間失效
  (c) 死亡窗口:規則寫明——player 這個人不在 persons 時 possessed 保持在【最後所屬隊】直到 heir 繼任或 game_over（否則玩家戰死那一刻附身隊就被 AI 全面接管,
      與 #12『決策不屬 AI』相反);P8 的對照物跟著改成「最後所屬隊」而非 get_player_team_id 的即時值
```
## P8 要改的三處
```
1.「且只有一支」不成立於 player_id=-1（觀察者長跑,sim_runner.gd:115-117;state_fingerprint 也把 player_id=-1 當一格）⇒ 改「至多一支;player 不存在 ⇒ 零支」
2. P8 在 30 天正常世界跑,走不到 §1 ①②③;要【注入格】:
     ·吸收併隊含玩家所在隊（直寫路徑 :268）·玩家被他隊邀入／逐出（add/remove_member 路徑）·玩家戰死留隊（:807 路徑）·possess 到別隊 NPC 再 unpossess
   每格:動作後同 tick 內 possessed 隊＝預期;反向:拿掉對應 sync ⇒ P8 必紅（四格各一）
3. 校驗點要在【所有系統跑完之後】的 tick 尾,不能在 sync 之後立刻比（否則恆真:剛 sync 完當然一致——同 02_reviewer『守衛恆同答案』第一種）
```

# 2 其餘四項:方向對,各一註
```
④ 事實為鍵 ✓。註:priority ≥ PRIO_THREAT「照既有規則」意味著 AI 的 SURVIVAL@80（餓了去覓食,unified 發）可打斷玩家 TRAVEL@60——這與 #12『餓』列為允許一致,
   但玩家看到的必須是『停下：餓了,轉去覓食』而不是沉默:UI『停下：<原因>』的原因要取自 arbiter 寫的 task_reason／新 task,不要 UI 端猜（spec UI 段沒寫原因來源）。
   另:PLAYER_SOURCES 實作端 grep 時,「invite_settle」是 ENGINE_SOURCES 成員（task_arbiter.gd:~38）而 :_action_invite_settle 是玩家動作——確認玩家按下去走的來源字串不被這條 deny。
① 同層換手 ✓。要驗到的是『現任 PRIO_PLAYER + 新來源 ∈ PLAYER_SOURCES』而非『任何 PRIO_PLAYER 現任』:否則 ENGINE 來源在 possessed 隊閒置後也… 不,④ 已先擋;只要 ④ 在 ① 之前判,順序無虞。寫進 spec:判定順序 ④ → ① → 既有。
② release 守 ✓,但 61 站『預設 ""』= 對附身隊 PRIO_PLAYER 現任一律不放,包括正當的 AI 側清理（例:movement_system.gd:53 目標消失是對 ESCORT/MERGE 隊,附身隊 TRAVEL 時不會走到;
   可是 :108 FLEE backstop 對 FLEE 隊——現任是 FLEE@80 不是 PLAYER,不受影響 ✓）。要抽 5 站實際跑一遍確認沒有『附身隊現任 PRIO_PLAYER 時,AI 路徑 release 之後馬上 try_set 自己的任務』而 try_set 被 ④ 擋下卻留下 release 成功的半套——
   順序顛倒成 release 被擋、try_set 不執行 ⇒ 結果不變,✓;若 release 放行、try_set 被擋 ⇒ 附身隊被清成 IDLE（這才是病）,所以 release 的 deny 與 try_set 的 deny 必須用同一個『是否可被 AI 動』謂詞,別寫兩份。
⑥ set_strategic_move 對 possessed 直接 return ✓。
```

# 3 追加（77a480050:allowlist 門 PRIO_THREAT→PRIO_COMBAT、P5f）
```
verdict: issues（premise_contradiction: false）
擋:⓪ ——補 (a)(c) 與 P8 三處後重送;追加段 §3.2 (改寫 COMBAT 放行句)、§3.3 (入口 return 或收進 arbiter + P5g) 同版補;①②④⑥ 與註不需再審
```

## 3.1 方向對,而且實作端的坐實比我第二輪的猜測更硬
```
寫者＝loop3 _evaluate_threat（faction_ai_system.gd:628 起,idle 且威脅過門檻）→ :677 _decide_unified(src=threat) → try_set(…,"unified"),不是我猜的 ambient。
門檻從 THREAT 改 COMBAT 合理:threat/survival 是 AI【決策】,#12 不放。P5f 用實作端診斷床、「改前=1」是真陽性對照,✓。
```
## 3.2 但 PRIO_COMBAT 這個放行條件【母體是空的】
```
grep PRIO_COMBAT 全 scripts（排除 debug）:只有 task_arbiter.gd:7 常數宣告,【零個使用處】。
encounter_system／npc_combat_system／reaction_system 對 TaskArbiter.try_set／transition／release 也是零呼叫（grep 空）。
⇒ 「priority ≥ PRIO_COMBAT 照既有規則」今天放行的寫入 = 0 筆;戰鬥對隊伍的保護靠的是 try_set 最頂的 combat_target != -1 鎖（事實）,不是優先序。
⇒ 規則實際等價於「附身隊只接 PLAYER_SOURCES」。這不是壞事,但 spec 文字描述了一條【不存在的路】:
   (a) 把 ≥PRIO_COMBAT 那一句改寫成「戰鬥由 combat_target 鎖保護（不經 arbiter 寫入）」;或
   (b) 保留但標明『今天無寫者,預留』——選 (a),預留的放行條件是日後有人偷開洞的現成入口
   release 守同理:『priority ≥ PRIO_COMBAT 的接手才放』也無人能滿足,刪掉比留著誠實
後果要想清楚:戰鬥鎖對玩家自己的 M 也生效（try_set 頂端 return false）⇒ 戰鬥中按 M 會走 ① 的『不能移動：<擋它的現任 task>』——戰鬥中現任可能是 IDLE／TRAVEL,
   句子要能說出『戰鬥中』,不能只印現任 task 名。
```
## 3.3 ★新漏洞:AI 對附身隊的【非 arbiter 寫入】還在 _evaluate_threat 裡
```
faction_ai_system.gd:640-646 _famine_crisis 分支（在 :647 的 task 判斷之前、與 current_task 無關）:
  team.crisis_released_task = team.current_task      ← 直寫欄位,不經 try_set／release
  team.crisis_released_until = tick + CRISIS_IMMUNITY
  TaskArbiter.release(team)                         ← 對附身隊 PRIO_PLAYER 現任會被 ② 擋下
  team.previous_task = ""
task_arbiter.gd:~146-153 try_set 的 crisis 免疫窗檢查在【優先序判斷之前】且無 PRIO_PLAYER 例外:
  `new_task == crisis_released_task and tick < crisis_released_until → deny`
⇒ 附身隊 TRAVEL 途中鬧飢荒:release 被擋（TRAVEL 還在）,但 crisis_released_task=TRAVEL 已寫入 ⇒ 玩家接下來【重按 M（TRAVEL）被免疫窗擋 CRISIS_IMMUNITY 個 tick】,
   結果行只會說「不能移動」之類。這是 release 被擋而【副作用沒被擋】的半套——跟我第二輪 §2 同一類,只是這次躲在直寫欄位。
同理 :629-630 threat_eval_next_tick、previous_task 等 AI 簿記欄位被寫在附身隊上:無害,但 P7『task／move_target 逐 tick 不變』之外還有這類欄位會讓 P8/fp 比對噪音。
修法兩選一（HOW,systems 定）:
  (a) _evaluate_threat 入口對 possessed 隊直接 return（一行,在『AI 決策入口』而不是 131 個迴圈）——因為附身隊整個沒有 AI 決策,這一行是【語意正確的】,
      與 ② ④ 並存:咽喉擋 arbiter 寫入、入口擋簿記直寫;P5f 反向格:拿掉 (a) 且飢荒佈置 ⇒ crisis_released_task 被寫（可計數）
  (b) 把 crisis_released_* 的寫入收進 arbiter（一個 release_for_crisis），由咽喉的同一個謂詞管
選 (a) 較小;但要在 spec 明講『這一行不是第二套補丁,是因為 #12 說附身隊零 AI 決策,而 _evaluate_threat 在 :640-646 有非 arbiter 的直寫』。
並補一個 P5g:附身隊 TRAVEL 中佈置飢荒 ⇒ 玩家 M 重下令不被免疫窗擋（結果行成功）。
```
