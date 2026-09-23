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
  set_player_input             26 處   ← ★那是【呼叫次數】；去重後是 **24 個 key**（R② 逐一列出並核過）
                                        寫 state.player_state[key]（sim_bridge.gd:286）
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

### ★★§3-2 消費點：**`_step1_advance_time()` 之後、系統迴圈之前**（★R② 訂正，兩個位置都釘死）

```
scripts/simulation/sim_runner.gd 的 _advance_tick_body：
  :479  if state.encounter_active: … _step1_advance_time(state) … return   ← 分支A（跳過系統迴圈）
  :488  _step1_advance_time(state)                                          ← 分支B（正常）
  :519+ hour_tick／due_teams／due_factions… 系統迴圈本體
⇒ ★★★消費點放在【每一次 _step1_advance_time() 的正後方】（兩個分支【都】放）
```

**為什麼是它之後，不是之前（★R② 抓的，差 1 而且不會馬上紅）**：

```
current_tick += 1 發生在 _step1_advance_time() 裡
⇒ 放【之前】⇒ command_log 記到舊值；放【之後】⇒ 記到本 tick 真正在用的那個值
⇒ ★而全庫其餘印 tick 的地方（DayNight／Probe／FaiPhase…）都讀【遞增後】的 current_tick
⇒ ★★消費點跟著用同一個值，才不會出現「這個 tick 的指令」與「這個 tick 印出來的世界」
   引用兩個不同的整數
⇒ ★★★記錯側【不會馬上紅】：兩種選法【各自內部一致】，只有跟別的 tick 來源對帳時才現形
```

**分支A（`encounter_active`）：★二選一，我選【也消費】**：

```
★理由①：一條【沒有例外】的規則比兩條規則好 ——
  「指令永遠在下一個 tick 邊界生效」是玩家講得出來的語意；
  「除非你正在遭遇戰」是一句沒有人會記得的例外。
★★理由②：不消費 ⇒ 佇列在遭遇戰期間【持續累積但不消費】，
  而遭遇戰結束那一刻會一次全部生效 —— ★那是【被動產生】的行為，不是誰設計的。
★★★理由③：合法性不歸佇列管 —— handler 自己有 _check_controlled_team 等前置檢查，
  不合法就回 ok=false，而【那一條會被記進 command_log】⇒ 重播照樣重現得出來。
⇒ ★而「遭遇戰期間玩家其實按不到鍵」（_input 轉給 encounter_view）是【真的】，
  所以這個分支【多半】是空的 —— ★★但「多半空」不是「保證空」，所以規則要寫死，不是靠它空。
```

### ★★★§3-2b `player_state` 有【第三個寫入者】——新設計下的同 tick 競態（R② 多找到的）

```
scripts/simulation/sim_runner.gd:458      if 玩家格子變了: _player_cmd.clear_pending_targets(state)
scripts/simulation/player_command_system.gd:960-962
    state.player_pending_targets.clear()；state.player_state.erase("pending_trade_target")
⇒ ★這是【tick pipeline 自己】在寫 player_state ⇒ 它不是純粹的 UI→command 單向管道
```

**新設計下才會出現的窗口（★舊設計沒有）**：

```
舊：玩家下 trade 指令 ⇒ 立刻寫 pending_trade_target ⇒ 立刻被讀（時間點由玩家控制，
    幾乎不可能與該 tick 的 move 相位同時發生）
新：trade 指令在 tick 開頭被消費 ⇒ 寫 pending_trade_target
    ⇒ ★同一顆 tick 稍後的 move 相位若判玩家格子變了 ⇒ 把它清掉
```

**★★處置：不改那個清除鉤子，而是【把行為釘死】**：

```
①佇列以 seq 遞增順序消費（★同一顆 tick 內的兩條指令，順序是玩家下的順序）
②★清除鉤子【保留原樣】：玩家若在同一顆 tick 裡既下 trade offer 又移動走，
  那個 target 被清掉是【對的】——你不能跟一個你剛走開的人交易
③★★★而它必須【被測到】，否則下次有人改順序時沒有人會發現：
  驗收加一格（P8）：同一顆 tick 內先 trade offer 再 move ⇒ 斷言 pending_trade_target 被清掉
  ⇒ ★這一格【不是在測 bug】，是把一個【順序決定的結果】釘成守衛
```

### ★★★§3-3 另外兩支入口的處置（★不可以默默忽略）

```
(a) set_player_input（26 處呼叫／**24 個 key**）⇒ ★【不進佇列】——★★★R② 已逐一核過讀點，豁免成立：
    那 24 個 key 的讀點【全部】集中在 `player_command_system.gd` 的 handler 函式內，
    而那些 handler 只能經由 `PlayerCommandApi.dispatch()` 的 **14** 個白名單 name 到達（★2026-09-23 兩次訂正：我寫 12 → 實作端數出 13 → 第三個入口進佇列後 14；★★這個數字會隨票變動，**引用它的地方要能被重數**，不要當常數記；★★而 `advance_ticks` **不在**白名單 ⇒ 佇列不會遞迴推進世界，那一點成立）
    （`execute_action`／`respond_to_forced` 兩支路由過去）⇒ **沒有系統直讀路徑**
    ⇒ ★而這不是「我讀名字推的」了：是逐個 key grep 過 `scripts/simulation/**.gd` 的結果
    ★理由仍然要寫在 code 註解裡：
    它寫的是 state.player_state[key] ＝【尚未送出的表單欄位】（例：tribute_rate_input），
    ★★真正生效的是之後那一條 command_player ⇒ 它不改世界，只改「玩家打了什麼字」
    ⇒ ★★★驗收要證明這一句：§5 P4
(b) refresh_interaction_targets（3 處）⇒ ★【要進佇列】：
    它掃同格 NPC 並寫 state.pending_targets ⇒ ★★那是【世界狀態】，而它今天在開選單的瞬間發生
    ⇒ 重播時「玩家何時打開選單」會改變 pending_targets ⇒ 不決定
```

### ★★★§3-5 回饋契約（blueprint 裁定 2026-09-23，意圖帳「玩家指令回音」）

```
★病（實作端量出來的，不是我寫 spec 時知道的）：
  回傳值裡 `message` 被讀 21 次、`ok` 20 次（扣掉死樹後）＝ **印給玩家看的那一行**
  ⇒ 佇列化後回傳 {ok, queued, seq} ⇒ ★那一刻沒有結果可講
  ⇒ ★★而 TextUI 平常是停住的 ⇒ 玩家分不出「排進去了」與「我的鍵沒被吃到」

★★★裁定（(乙) 為底，三件缺一不可）：
  ①入列當下印「已排入：<動作的人話>」
  ②**消費點必回結果句**：成功一句／拒絕一句＋原因，印進【下一顆 tick 的畫面】
    ★★拒絕【禁靜默】——「執行失敗」那一行對玩家同樣適用
  ③畫面頁腳【常駐】「待執行 N 道」
    ⇒ ★★★這一格【結構性】消掉「按鍵沒被吃到」的疑慮：不依賴玩家記得自己按過什麼
  ✘ (丙) 否決：下令不推時間（節奏＝下令 → 推進 → 看結果）
  ✘ (丁) 否決：★入列時做合法性檢查 ＝ 兩份真相
    —— 實作端量過：前置檢查只答得出 9 種失敗，且【全部】是同兩支
       （「你沒有控制中的隊」「你不是玩家」）；真正有內容的錯誤 22＋10 種全在套用之中
    ⇒ ★★要讓 (丁) 有用得把 32 個判斷從套用路徑【複製】出來，而複製的那份過時時
      **沒有任何訊號**：玩家看到的是舊文案。

★★唯一允許【當場】拒絕的：**不讀世界的** —— 不認得的鍵／格式錯／沒附身
  判準句（blueprint 給的，逐字）：**「答案會不會因為推進一顆 tick 而變？」**
⇒ ★★★而由這句話推出一件【實作端不用動手】的事：
   `_check_player`／`_check_controlled_team` **兩支都讀 `state`**
   （`player_command_api.gd:10/15`：讀 `state.player_id`／`state.persons`／`state.teams`）
   ⇒ 它們的答案**會**因推進一顆 tick 而變（人會死、隊會散）
   ⇒ **所以它們留在原地不動** —— 它們本來就在 handler 裡，而 handler 在消費點跑
   ⇒ ★**零複製、零第二份真相**；當場那一關只擋 dispatch 的 match 認不認得這個 name。
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
   ★★★【負對照】（R② 訂正 2026-09-23）：**把某一條指令的 tick 位移到【跨過一個小時或一天邊界】**，
     fp 必須【不同】。
     ★不用固定的 ±1：同一小時內位移一格，很可能逐字相同 ⇒ ★★負對照恆綠（我自己標的疑慮，R② 證實）
     ★★★跨邊界則【母體選擇本身帶保證】：day_boundary 上 `check_starvation_deaths`／
       `flush_forage_episodes`／訊息剪枝本來就在動東西（`sim_runner.gd:490` 一帶），
       hour_tick 上有 NEAR_CADENCE 的到期檢查 ⇒ 前後保證有世界差異，不是「可能有」
P3 [無後門] grep 斷言：production 路徑上沒有任何 dispatch 的直接呼叫（只有消費點那一處）
P4 [set_player_input 的豁免不是我說了算] 對每一個被寫進 player_state 的 key：
   ★證明它【不被任何系統讀】，只被之後的 command_player 讀
   ⇒ ★★做法＝把 player_state 整個換成空的之後跑一輪，fp 必須不變（母體＝那些 key 真的有被設過）
P5 [ui-flow] 註冊表 `ui-flow` 仍綠（★指令語意改了 ⇒ 那 26 支 cell 會逐一面對「要先推進才看得到」）
P6 [fp] ★world-fp 不變 —— 無人世界不下指令 ⇒ 佇列恆空 ⇒ 世界必須逐字相同
   ★★這一格是【陽性對照的反面】：它證明本票沒有順手改到別的東西
P7 [電池] merge 前全部 merge-gates
P9  [入列有回音] 下一條指令 ⇒ ★當下畫面出現「已排入：<動作>」（★母體地板：那句話要含【動作】，
    不是只有「已排入」——否則玩家仍分不出他排的是哪一道）
P10 [★★消費點必回結果] 推進一顆 tick ⇒ 畫面出現該指令的結果句
    ★★★【母體地板，這一格最容易恆綠】：那一輪必須**同時**含
      ①至少一條【會成功】的指令 ②至少一條【會被拒絕】的指令（例：移到不相鄰的格）
    ⇒ ★沒有②的話，「拒絕禁靜默」是一句【對空集合為真】的話
P11 [頁腳計數] 佇列 0／1／多 三種狀態 ⇒ 頁腳的「待執行 N 道」逐一對得上
    ★負對照：入列後【不推進】⇒ N 必須【維持】不歸零（★那正是「鍵有沒有被吃到」要答的那件事）
P12 [★當場拒絕只擋不讀世界的] 送一個【不認得的 name】⇒ 當場拒絕；
    ★★送一個【格式對但世界不允許】的（例：沒有控制中的隊時下移動）⇒ **必須先「已排入」、
      到消費點才拒絕** ⇒ ★★★這一格擋的是實作端「順手把 _check_* 提前」＝ (丁) 從後門回來
P13b [★★★查詢分類的【對照面】：那個「指令」層真的有在寫嗎] 把 `confirm_gather_intel`
    （blueprint 2026-09-23 裁定的「真去問人＝指令、可有成本」那一層）一併放進 P13 的跑法
    ⇒ ★預期：它**應該**讓 world-fp 改變（它是指令）
    ⇒ ★★**若它 5 跑下來 world-fp 也不變** ⇒ 那代表【今天打聽整條線都不寫世界】
      ⇒ ★★★那不是本票的 bug，是一個**要回報給 blueprint 的事實**：
        他的兩層拆分（開選單＝查詢／問人＝指令）今天在 code 裡**還沒有落點**
      ⇒ 回報，不要順手去補（補它是新票）
    ★我為什麼不直接斷言：我讀了 `resolve_inquiry` 前 30 行沒看到寫入 ——
      ★★而「沒找到」不等於「沒有」，那正是 P13 這一格存在的理由；★★★我不用自己剛立的規矩的反面來下結論。

P13 [★★★「純讀」不能靠讀 code 斷言 —— 經驗層兜底] 對**每一支被分類為查詢**的端點：
    同一個世界【連呼 5 次】⇒ ★world-fp 逐字不變
    ★負對照（必須有）：故意讓其中一支寫一個欄位 ⇒ **這一格要紅**
    ⇒ ★★理由是實作端 2026-09-23 的血證：他的靜態稽核【錯了三次，而三次都往同一個方向錯】
      （委派走型別化變數／兩層索引寫入／內聯 `.new()` 鏈）—— 全部只會**少算寫點**
      ⇒ ★★★**一個靜態掃描器只能支持【正面斷言】（這裡有一個寫點），不能支持【負面斷言】（這支不寫）**，
        因為負面斷言的每一種失敗都長得一樣：**沒有輸出**。
    ⇒ 所以「它是查詢」這件事，**驗收要用會紅的方式證，不能用讀 code 的方式宣告**。
P8 [★同 tick 競態被釘死] 同一顆 tick 內：先 trade offer、再 move（兩條都進同一批佇列）
   ⇒ 斷言 `player_state["pending_trade_target"]` 在該 tick 結束時【已被清除】
   ★這一格不是在測 bug，是把 §3-2b 那個【由順序決定的結果】釘成守衛
   ★★母體要求：那一條 move 必須真的讓玩家格子改變（否則清除鉤子不會觸發 ⇒ 恆綠）
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
