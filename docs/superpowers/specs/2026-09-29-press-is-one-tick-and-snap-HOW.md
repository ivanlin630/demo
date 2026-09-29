# HOW spec：按一下＝做一顆 tick ＋ X／Space 吸附整點與隔天

owner: systems ｜ 2026-09-29 ｜ **player_reachable: yes**
上游：blueprint 裁定 #8（`2026-09-29-blueprint-to-systems-RULING-press-is-do-one-tick-and-snap-to-hour-day.md`）
——**撤回** 2026-09-23 的「下令不推時間」。用戶逐字：「玩家的介面就是按啥做啥」。
序：**#8 先於 #7**（它把 #7 的「按 1 一直排」直接消掉）。

---

## ★★★§1 前提（逐字 file:line；★第一條決定這張票的形狀）

```
①★★★**訂正（implementer 2026-09-29 量出來的）：活的呼叫點是 45 個，不是 36**
   ·`text_ui_main.gd` **36**（我數的）
   ·★`encounter_view.gd` **5** ＋ `popup_layer.gd` **4** —— 它們也是活的
     （`text_ui_main:156` 動態 `new` 出來的物件）
   ·`main.gd` 那 10 個才是死樹
   ⇒ ★★我的 36 是【只數了一個檔】，而母體是【所有活的 UI 物件】
     ⇒ 「一個咽喉涵蓋 36 個」這句話**低估了自己的爆炸半徑**
   ⇒ ★★★而結論不變：那 9 個也走 `command_player` ⇒ 咽喉仍然涵蓋得住
     —— ★但 45 這個數字要寫在這裡，並且那 9 個的行為要【印成床的母體】
       （implementer 已記）—— ★★因為「45 vs 36」若只活在信裡，**信不是執行單位**。
   ⇒ ★★「每道令入列後推一顆」若寫在 UI，就是**貼 36 次**
   ⇒ ★★★而這個檔自己的註解（`:370-373`）剛好寫著反例：
     「★【不新開推進路徑】…兩個推進路徑其中一個沒跟上 ⇒ 我們不再製造第三條」
②`sim_bridge.gd:44 request_advance(n)`／`:52 is_advancing()` 都已存在
   ⇒ 「自動推進中按的令照舊入列」這個例外**有現成謂詞**，不必新造狀態
③`text_ui_main.gd:369 KEY_SPACE → request_advance(TICKS_PER_DAY)`
   `text_ui_main.gd:378 KEY_X   → request_advance(TICKS_PER_HOUR)`
   ⇒ 兩支都是【固定長度】，要改成【到邊界】
④`world_state.gd:12 TICKS_PER_HOUR = 60` 標著【唯一自由參數】
   ⇒ ★不准寫 60／1440；一律引用常數（該檔 `:370-376` 已為此立過規矩）
```

## ★★§2 做什麼（三件，而第一件的【位置】是本票的核心）

```
①★★★自動推進掛在【單一咽喉】：`SimBridge.command_player()` 裡，不在 UI 的 36 個呼叫點上
   偽碼：
     func command_player(name, args):
         var r = <既有邏輯：入列>
         if not is_advancing():        # ★例外：自動推進中按的令照舊入列，不另加推進
             request_advance(1)
         return r
   ⇒ ★**一個位置涵蓋 36 個呼叫點**（同「數那條邊不是數終點」那一條）
   ⇒ ★★而它同時保證【以後新增的 command_player 呼叫點自動有這個行為】——
     貼 36 次的版本會漏掉第 37 個，而且不會有人發現。
②X／Space 改成【吸附】：
     n = C - (tick_now % C)        # C ＝ TICKS_PER_HOUR 或 TICKS_PER_DAY
     ★剛好站在邊界（餘 0）⇒ n = C（推整段），**不是 0**
   ★★`tick_now` **必須呼 `_bridge.get_current_tick()`**（`sim_bridge.gd:147`，它 live 讀 `_state.world.current_tick`）
     ★★★**不得用 `_cached_snapshot` 裡那一份 tick**（那份只在 `_refresh()` 才更新）
     —— R² 指出它是【實作端最自然會誤用的那個來源】，所以這裡**把該叫哪一個方法寫死**，
     不讓他自己選。★畫面是「上一顆完整 tick」的快照——
     畫面是「上一顆完整 tick」的快照，而①會讓它們差一顆 ⇒ 用快照算會吸到前一格。
③頁腳「待執行 N 道」保留、重播語意不變（指令仍綁 tick）。
```

## §3 不在本票

```
✘ 計畫面板（可見佇列／排序／取消）＝ blueprint 明列「之後按需求開」
✘ #7 的面板人話／生命週期三點（那是 #7，本票落地後它的②簡化成「按了就結算」）
✘ `request_advance(-1)` 真無界（另一張小票，已登延後）
```

## §4 驗收

```
P1 [按一下＝一顆] 按一道**會成功**的令 ⇒ `current_tick` 恰 +1、結果句出現、頁腳 0
   ｜★陽性對照（blueprint 指定）：拿掉①的 `request_advance(1)` ⇒ P1 必紅
   ｜★★母體地板：先斷言那道令**真的成功**（ok=true）——
     失敗的令也會 +1，而「+1」在兩種情形下長得一樣
P2 [吸附兩向] 站在 `k*TICKS_PER_HOUR + 7` 按 X ⇒ 停在 `(k+1)*TICKS_PER_HOUR`；
   ★站在邊界按 X ⇒ `+TICKS_PER_HOUR`（不是原地不動）。Space 對 DAY 同理。
   ★★斷言**讀常數**不得寫 60／1440（負對照：把常數換成字面值 ⇒ 換根時它不會跟著動）
P3 ★[濫按床／世界的韌性] 同一分鐘內對同一 NPC 連發 20 次
   `demand_tribute`／`propose_alliance`／`recruit_anon`
   ⇒ 對方回應合理（冷卻／拒絕）、`world-fp` 對照組不崩、守恆不破
   ★★母體要印出來：20 次各自的回傳（ok／msg）＋冷卻欄位的值
     —— 否則「沒有崩」在一個【20 次全被擋在最前面】的世界裡沒有資訊量
P4 [例外成立] 自動推進中按令 ⇒ **不額外推進**（`is_advancing()` 為真那一支）
   ｜★負對照：拿掉 `is_advancing()` 判斷 ⇒ 推進中按令會多推 ⇒ 必紅
P5 [fp] ★本票改變【世界推進的時機】⇒ world-fp **會變是預期內的**
   ⇒ ★★基準值與本改動【同一顆 commit】落地（★而這一條與成功結果句那票相反，
     那票是「文字不進 fp ⇒ 逐字不變」；★★★所以不要照抄上一張票的 P5）
P6 ui-flow 綠；merge 前全電池 BATTERY_RC=0
```

## ★§5 誠實限

```
①本 spec 沒有跑 Godot，全部靜態 file:line。
②★我沒有量【每按一次就推一顆】對 NPC 決策節奏的影響 ——
  用戶自己在討論裡問過「最小 tick 的零碎化」，而 blueprint 的答覆是「錯開後每分鐘都有隊在想」。
  ⇒ ★★那是一個【已被上游回答、而我沒有獨立驗證】的前提，我照用但標明它是別人的數。
③★★★P3 那一格我只能定義形狀，**「合理」的判準是 blueprint 的格**——
  床印母體，而「20 次之後對方該怎樣」若卷面看起來不合理，那是 WHAT 不是 HOW。
```
