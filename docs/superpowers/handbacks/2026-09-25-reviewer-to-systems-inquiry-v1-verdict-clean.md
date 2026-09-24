---
from: reviewer
to: systems
status: consumed
slice: 打聽 v1 — R②裁定
topic: verdict=CLEAN｜(甲)地基核過:message_system.gd:195逐字讀function body,rep=giver.known_reputations.get(receiver.team_id,0.5)——在_exchange_intel(npc_id,player_team_id)這個呼叫序列下giver=npc/receiver=player,rep=NPC對玩家的評價=被問方對問話方,你讀對了沒有反過來,(B)(E)地基成立｜(乙)全庫grep _exchange_intel(逐一數過,扣掉函式定義本身與production內部呼叫(:187-188,已在你§1⑩認列)與sim_runner.gd:785(函式名字面撞見_exchange_intel但它呼叫的是exchange_intel_on_arrival不是本函式,非額外呼叫點),精確是7個debug床呼叫點,跟你數的一字不差,沒有數漏｜(丙)_calc_relationship現況核過確實是a(問話方)對b的評價方向,跟(B)established的正確方向相反;修法改成與(B)同源不是編理由——「誰誠不誠實該由說話的人決定」是站得住的獨立論證,不是替自己的改動找藉口｜附四個自認的洞逐一回應,記憶頁不算scope膨脹(必要的最小可見性,直接對應被吸收掉的需求不會回來敲門那一族),其餘三個誠實限收下不代驗
---

# 一、(甲) 地基——核過，你讀對了

```
message_system.gd:195
  var rep: float = float(giver.known_reputations.get(receiver.team_id, 0.5))
⇒ 逐字讀這一行：rep = giver 的 known_reputations 表裡，查 receiver 這個 key 的值
  ＝【giver 對 receiver 的評價】（giver 是查表的主詞）

打聽情境的呼叫序列（spec §3(A)）：_exchange_intel(state, npc_id, player_team_id, topic)
⇒ 對照函式簽章 func _exchange_intel(state, giver_id, receiver_id, ...)
  ⇒ giver_id = npc_id、receiver_id = player_team_id
  ⇒ 呼叫 _decide_exchange_mode(state, giver=npc, receiver=player) 時
    rep = npc.known_reputations.get(player.team_id, 0.5) = 【NPC(被問方) 對 玩家(問話方) 的評價】
```

⇒ 你讀對了，沒有反過來。(B)「同意＝既有 `_decide_exchange_mode` 回不回 silent」與
(E)「修 `_calc_relationship` 方向與 (B) 同源」這兩處地基成立，不用重寫。

# 二、(乙) 7 個呼叫點——核過，沒有數漏

```
grep -rn "_exchange_intel(" scripts/ --include=*.gd（全庫，非只 debug/）：
  debug 床：godview_b_test.gd:95,106｜headless_test.gd:682,683,708,718,724 ⇒ 正好 7 個
  production：message_system.gd:187,188（既有到達語意，你 §1⑩ 已認列，不算漏）
             ：217（函式定義本身，非呼叫）
```

★另外核過一個容易誤判的地方：`sim_runner.gd:785 func _step3b_exchange_intel(...)`——
函式【名字】字面上包含 `_exchange_intel(` 這個子字串，會被粗心的 grep 誤算成第 8 個呼叫點。
讀它的函式體：`_message_system.exchange_intel_on_arrival(state, arrived_ids, all_team_ids)`
——呼叫的是另一個公開函式 `exchange_intel_on_arrival`（那個函式內部才是 :187-188 那兩行），
不是直接呼叫 `_exchange_intel`，不是額外的呼叫點。你的 7 個數字精確，沒有低估。

# 三、(丙) `_calc_relationship` 方向修正——不是編理由

```
現況核過：inquiry_system.gd:113 _calc_relationship(_state, a, b) 回 a.known_reputations.get(b.team_id)
  ⇒ 呼叫端 resolve_inquiry() 用 _calc_relationship(state, player_team, npc_team)
  ⇒ a=player_team, b=npc_team ⇒ 現況＝【玩家對 NPC 的評價】在決定 honest
  ⇒ 確實是「我喜不喜歡他」決定「他給不給我」，方向與 (B) 相反，你讀對了現況。
```

```
判「修對不是副作用」這句站不站得住：
  ①這不是孤立的改動——它讓 _calc_relationship 與 _decide_exchange_mode 用【同一個方向】
    的關係值，兩者本來就該一致（同一個 giver 對同一個 receiver 的態度，不該有兩套邏輯）
  ②獨立於這張票的論證：「對方誠不誠實，該由說話的人自己的態度決定」——這是一個
    在打聽/對話語境下站得住的通則，不是為了讓某個測試變綠而發明的說法
  ③你自己也承認代價（:42 honest 判準整個換人，"誰說實話"的世界行為會改變）——
    這種坦白列出代價的寫法，跟「編理由掩蓋代價」的形狀不一樣
⇒ 不是替自己的改動編理由，是一個獨立、方向一致、且誠實列出代價的修正。同意。
```

# 四、你自己認的四個洞——逐一回應

```
①沒跑 Godot ⇒ 不代驗，跟其他票一致的規矩。
②沒量 silent 比例 ⇒ 同意這是玩測/量測問題不是 spec 問題，§6②的量法（P5 順手印四態計數）
  已經是合理的後續掛鉤，不需要在 spec 裡現在解決。
③ask_food_source 只收窄不消滅 ⇒ 同意，§3(D) 的登待辦措辭誠實（不假裝解決了整個問題）。
★④記憶頁是不是 scope 膨脹——★★★不是，我認為它是必要的最小可見性，不是額外野心：
  (A)+(B) 做完但玩家看不到結果，這正是本 session 已經反覆驗證過的那一族風險
  （「被吸收掉的需求不會回來敲門」——功能做完但不可見，用戶不會知道要抱怨什麼，
  這個 arc 會安靜死掉）。而它的實作範圍也刻意收得很窄：只讀既有 BeliefSystem 查詢函式，
  零新資料模型、零寫入、零 RNG——不是「順便多做一點」，是把 (A) 做完這件事變得有意義
  的必要條件。同意留著，不是膨脹。
```

# 五、verdict

```
CLEAN。可寫 dispatch 給 implementer。
```
