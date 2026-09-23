# HOW spec：玩家指令佇列化（重播可重現）

owner: systems ｜ 2026-09-23 ｜ **player_reachable: yes**（它改變玩家指令何時生效）
上游：blueprint `2026-09-23-...-determinism-means-replay-give-the-ticket-its-own-home.md`
R①：reviewer `2026-09-23-...-R1-command-queue-premise-ok.md` ⇒ **premise_ok**
世代：8

★**這張票原本寄生在一份【已永久關閉】的 spec（分片＋邊界快照）的 §1 裡**。
★★門票（分片）死了、需求還活著 ⇒ blueprint 裁「給它自己的家」。
★★★**舊理由（讓分片有前提）已經消失，新理由是【重播可重現】** ——
**所以本 spec 不繼承舊 spec 的任何判準**，包括它寫的「已知牽動：14 處測試改寫」（見 §4）。

---

## §1 目標（blueprint 定，逐字）

```
決定性 ＝【重播可重現】：
  同種子 ＋ 同一串玩家指令（★每條帶「被套用的 tick 編號」）⇒ 同一個世界（fp 逐字相同）
★不是 (甲) tick 內順序本身（那是綁邊界之後的【自然結果】，不是目標）
★★不是 (乙) 存檔／載入（存檔終局在 sim 好之前最低優先）
★★★不是 (丙) 多人
```

**三個消費者（blueprint 的理由，收下當範圍的護欄）**：

```
①用戶問「什麼種子會錯」時要能重現
②量測要能把【玩家路徑】納進 fp 床（今天 fp 床只跑無人世界）
③bug 回報要能附一條指令串
⇒ ★這三個都要【指令串 ＋ 每條的 tick 編號】，★★而都不要求「立刻套用」
```

---

## ★★§2 前提（★全部 file:line；R① 已核）

### §2-1 今天沒有佇列、沒有記錄

```
scripts/simulation/player_command_api.gd
  :26 move_to／:45 execute_action／:91 equip_item／:113 deposit_item
  ／:145 post_buy_order／:182 possess … ⇒ ★每一支吃 state 並【當場寫入】
  :221 dispatch(state, name, args) ⇒ match 白名單，沒有任何佇列
scripts/ui/sim_bridge.gd:277 command_player → _cmd_api.dispatch(_state, …)
★★全庫 grep：沒有任何既有的指令記錄／重播機制（R① 獨立核過，零命中）
```

### §2-2 ★★★不決定性是【真實的】，不是理論的（R① 坐實 ＋ 他多給的一格）

```
①sim_bridge.tick_step() 是玩家路徑【唯一】的驅動，而它一次吃 min(TICKS_PER_HOUR=60, remaining) 個 tick
  ⇒ ★【無 delta-time 縮放】⇒ 同一段 wall-clock 內跑幾幀＝幀率決定
  ⇒ ★★幀率越高，單位時間吃掉越多 tick
②沒有「每幀恰好一個 tick」的路徑（R① 找過）
③★★★reviewer 多給的關鍵證據：`_input()` 【完全不看 `is_advancing()`】
  ⇒ 玩家在多 tick 批次進行中（例如推進一天 ＝ TICKS_PER_DAY=1440 ⇒ ≥24 幀的窗口）
    照樣能按鍵下指令
  ⇒ ★**那是一個有真實長度的時間窗，不是邊界上的理論競態**
```

⇒ **同一個玩家操作，在不同幀率的機器上會落在不同的 tick 之後** ⇒ 重播不可重現。

### ★§2-3 入口有【三個】，不是一個（★我實測，舊 spec 的「14 處」沒有被重現）

```
scripts/ui/text_ui_main.gd 對 bridge 的【會改世界】呼叫，逐個數：
  command_player               38 處   ← ★主入口（agent_repl／headless_test／ui_flow_test 也走它）
  set_player_input             26 處   ← 寫 state.player_state[key]（sim_bridge.gd:286）
  refresh_interaction_targets   3 處   ← ★★掃同格 NPC 並寫 pending_targets（開選單的副作用）
  （request_advance／cancel_advance／tick_step 不算：那是【推進】不是【指令】）
```

★**所以佇列的掛點是 `command_player` 一處**（38＋其餘呼叫端全部經過它），
★★**而另外兩支必須在本 spec 裡被【明文處置】**，不可以默默忽略（§3-3）。

---

## §3 設計

### §3-1 佇列本體

```
state.pending_commands: Array[Dictionary]
  每筆：{ "name": String, "args": Dictionary, "seq": int }
★SimBridge.command_player(name, args)：★★不再呼叫 dispatch，改成【推進佇列】並回
  { "ok": true, "queued": true, "seq": n }
★★★回傳型別改變 ⇒ 所有呼叫端要面對「我還不知道它成不成功」——見 §3-4
```

### ★★§3-2 消費點：tick 邊界，一次吃光

```
sim_runner 的 tick 開頭（★在任何系統跑之前）：
  for c in state.pending_commands: PlayerCommandApi.dispatch(state, c.name, c.args)
  記錄 ⇒ state.command_log.append({tick, seq, name, args, result_ok})
  state.pending_commands.clear()
★為什麼是【開頭】而不是結尾：玩家的意圖是「從現在起」，而
  ★★若放結尾，指令會在【它所看到的那顆 tick 已經跑完之後】才生效 ⇒ 畫面與因果差一拍
```

### ★★★§3-3 另外兩支入口的處置（★不可以默默忽略）

```
(a) set_player_input（26 處）⇒ ★【不進佇列】，而理由必須寫在 code 註解裡：
    它寫的是 state.player_state[key] ＝【尚未送出的表單欄位】（例：tribute_rate_input），
    ★★真正生效的是之後那一條 command_player ⇒ 它不改世界，只改「玩家打了什麼字」
    ⇒ ★★★驗收要證明這一句：§5 P4
(b) refresh_interaction_targets（3 處）⇒ ★【要進佇列】：
    它掃同格 NPC 並寫 state.pending_targets ⇒ ★★那是【世界狀態】，而它今天在開選單的瞬間發生
    ⇒ 重播時「玩家何時打開選單」會改變 pending_targets ⇒ 不決定
```

### §3-4 ★禁 flush 後門（舊 spec 的話，逐字保留）

```
★不得提供「立刻套用」的旁路 —— 那會把這張票的前提挖掉
★★包括：測試用的 flush、debug 旗標、「只有 agent_repl 走同步路徑」
★★★理由具體：只要存在一條同步路徑，重播就要問「那一次是走哪條」——
  而卷面上兩條路徑長得一模一樣
```

★**而它會痛在哪裡（先寫下來）**：`agent_repl` 與 `headless_test` 今天**下完指令就讀結果**。
⇒ 它們要改成「下指令 ⇒ 推進至少一個 tick ⇒ 再讀」。
★★**這不是為了測試方便才改，這就是玩家實際會經歷的語意** —— 測試原本測的是一個**玩家碰不到的路徑**。

---

## §4 ★舊 spec 的「14 處測試改寫」我【沒有重現】

```
舊 spec §1 逐字：「已知牽動：14 處測試改寫」
★我實測：直接引用 PlayerCommandApi 的只有 4 個檔（headless_test 4 次／agent_verbs_c1_bed 4 次
  ／sim_bridge 1／api 自己 1）；走 command_player 的另有 agent_repl 1、headless_test 3、ui_flow_test 2+
⇒ ★★我【不知道】14 是怎麼數出來的 —— 可能算的是別的東西，也可能是估的
⇒ ★★★所以本 spec 不引用那個數字：**實作端動工時自己數一次並回報**，
   而那個數字進 handback，不進這份 spec（★數字會變，spec 不該藏會變的數）
```

---

## §5 驗收

```
P1 [佇列] 下一條指令之後、在推進之前讀世界 ⇒ ★世界【沒有】改變；推進一個 tick ⇒ 改變了
P2 [★★★重播] 同種子 ＋ 同一份 command_log 重跑 ⇒ **final_fp 逐字相同**
   ★這一格是本票的全部意義；★★母體必須【非空】：那份 log 至少要有 N≥5 條真的改到世界的指令
   ★★★並附【負對照】：把 log 裡某一條的 tick 編號改掉一格 ⇒ fp 必須【不同】
     （否則「相同」可能只是因為那些指令根本沒生效）
P3 [無後門] grep 斷言：production 路徑上沒有任何 dispatch 的直接呼叫（只有消費點那一處）
P4 [set_player_input 的豁免不是我說了算] 對每一個被寫進 player_state 的 key：
   ★證明它【不被任何系統讀】，只被之後的 command_player 讀
   ⇒ ★★做法＝把 player_state 整個換成空的之後跑一輪，fp 必須不變（母體＝那些 key 真的有被設過）
P5 [ui-flow] 註冊表 `ui-flow` 仍綠（★指令語意改了 ⇒ 那 26 支 cell 會逐一面對「要先推進才看得到」）
P6 [fp] ★world-fp 不變 —— 無人世界不下指令 ⇒ 佇列恆空 ⇒ 世界必須逐字相同
   ★★這一格是【陽性對照的反面】：它證明本票沒有順手改到別的東西
P7 [電池] merge 前全部 merge-gates
```

## §6 不在本票

```
✘ 存檔／載入（blueprint 明說最低優先）
✘ 多人／網路
✘ 把玩家路徑納進 fp 床（★那是本票【解鎖】的下一張票，不是本票）
✘ 指令的 undo／預覽
✘ 分片、UI 讀邊界快照（★那份 spec 已永久關閉；本票【不復活】它）
```

## ★★§7 誠實限

```
①本 spec 沒有跑過 Godot —— 全部是靜態 file:line（R① 也是靜態的，他自己標了）
②★P2 的「重播」需要一個【重播驅動】，而它今天不存在 ⇒ 本票要一起做
  ★★而那是新 code，不是既有床的參數 —— 實作端請把它當成本票的一部分估
③★★★§3-2 說「一次吃光」——而【一顆 tick 之內收到 10 條指令】的行為我沒有定義上限。
  我認為不需要上限（玩家手速有限），★但這是【我的判斷】，若實作端看到真實上限問題請回我
```
