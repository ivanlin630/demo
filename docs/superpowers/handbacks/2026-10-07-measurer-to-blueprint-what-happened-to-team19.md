---
from: measurer
to: blueprint
status: open
slice: 用戶問「Team19 跑去哪」—— 滿上限接受求投靠的下場
topic: ★回應派工：重現確認——人口滿上限時按[A]接受求投靠，系統直接判「隊伍已滿無法收留」，收留【沒有生效】，Team19原樣留在原地。副本：systems。
---

# 白話：Team19 跑去哪

Team19 當時是一支獨立隊，跑來向玩家隊求投靠。玩家按下 [A] 選了「收留」，畫面上也
照常顯示了這次決定會扣的食物跟會加的人口——但因為玩家隊那時人口已經頂到上限，系統
在真正搬人、扣糧之前就先判了一句「隊伍已滿，無法收留」，整個收留動作當場失敗。
結果是：沒有人真的加入玩家隊，沒有扣一點食物，雙方的關係也完全沒變，Team19 自己
也毫髮無損——它就留在原地，日子照過（覓食），後來還派了一支信使隊想跟玩家隊談結盟。
對玩家來說，那次「求投靠」互動就這樣結束了（介面上的強制事件被清空），但背地裡什麼
都沒發生。Team19 不是被打發走、不是解散、也沒有去投靠別人——它只是單純地被拒絕了，
然後繼續過自己的生活。

# 重現設置

```
樹：HEAD=e81940f32（origin/main）｜seed=1337｜用戶實際存檔的seed未知，本次用任意seed佈置
玩家隊 Team15：改造前 population=10，effective_pop_cap=10（已經卡在上限）
手動灌入 anon ×2 → population=12（capacity = cap - population = -2，已超額）
選中世界裡真實存在的獨立隊 Team8 當 Team19 類比（population=8），teleport 到玩家腳下
寫入 join_request 強制事件，呼叫 PlayerCommandSystem.respond_to_forced(state,"accept")
   （跟真實 UI 按 [A] 走同一條程式碼路徑）
```

# 按下 [A] 那一刻

```
回傳：ok=false｜msg=你選了「收留（食物 -6.4,+8 人）」，但隊伍已滿，無法收留　沒有生效
玩家隊人口：12 → 12（Δ0）
玩家隊食物：50.00 → 50.00（Δ0.00）
Team8(類比Team19) 人口：8 → 8（Δ0）｜還在世界裡=true
關係帳：玩家對Team8＝0.500→0.500｜Team8對玩家＝0.500→0.500（雙向都沒變）
player_forced_event 清空：true（強制事件介面照常結束，不管收留有沒有真的成立）
```

★關於用戶記得的「−3.2」跟本次重現印出的「−6.4」：兩個數字不矛盾，是同一條公式
`player_command_system.gd:1463 cost = JOIN_ONBOARD_MEAL(0.8/人) × will_join人數`
的不同輸入。本次 Team8 有 8 人，8×0.8=6.4。若用戶看到的情境是 4 人求投靠，
4×0.8=3.2，剛好對得上。★但無論哪個數字，只要 will_join<=0（人口已滿），這筆扣款
根本不會執行——`−6.4`／`−3.2` 都只是介面上「如果收留成功會扣多少」的預告文字，
不是實際扣款結果。

# Team19（Team8）之後 120 tick（2小時）的動態

```
tick=1    task=idle　pos=(9,2)（留在玩家隊所在格）
tick=74   task=覓食　pos=(9,2)（位置沒變，只換了任務；population同時從8掉到7——
          這一人減少本床沒有追查原因，可能是獨立於此次拒絕事件的自然損耗/飢餓機制，
          不宜直接歸因於求投靠被拒）
tick≈73   旁側觀察：Team8 派出子隊 Team16（leader=P22，pop=1，task=信使），
          log印「[IndepStrategy] Team8 野心建國→派信使結盟 Team15（野心=0.62）」
          ——即 Team8 轉而嘗試跟玩家隊談「結盟」而非「投靠」。
          ★本床沒有證實這跟剛才被拒絕有因果關係，可能是這隊獨立AI本來就會做的動作，
          只是剛好發生在這次事件之後；留給下一層判斷。
```

# Team19 最終狀態（tick=120時）

```
仍存在｜task=覓食｜pos=(9, 2)｜population=7｜faction_id=-1
```

★沒有解散、沒有併入玩家隊、沒有去投靠別人——它就待在原地。

# 落地

```
床：scripts/debug/team19_what_happened.gd（純console print，無JSONL落地——
    本題性質是敘事性問答非資料集，用輸出即為答案）
跑法：.\tools\godot.ps1 --headless --script scripts/debug/team19_what_happened.gd
```
