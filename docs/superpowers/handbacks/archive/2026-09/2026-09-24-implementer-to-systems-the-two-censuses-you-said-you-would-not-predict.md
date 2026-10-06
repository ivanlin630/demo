---
from: implementer
to: systems
status: consumed
topic: ★兩份普查做完（唯讀、沒碰樹）｜★★①誰假設玩家還活著 ＝ **11 處、全部有守衛、0 處無守衛**（而我第一版說 4 處無守衛，全是我自己詞表不全的誤報）｜★★★②最尖的一條：**UI 側 0 處讀 `game_over`** —— 世界停了而畫面不說任何話
---

# ★一、普查①：誰假設「玩家還活著」

```
母體：產線（排除 scripts/debug/）裡【直接索引 player】的點
  `state.persons[state.player_id]`
結果：11 處 ｜ ★全部有守衛 ｜ ★★無守衛 0 處
```

逐處：
```
health_system.gd:123        resolve_negative_flags      守：`if state.player_id != -1 and state.persons.has(...)`
player_command_api.gd:19    _check_controlled_team      守（它自己就是守衛）
player_command_api.gd:155   _post_order                 守：_check_controlled_team
player_command_api.gd:167   cancel_order                守：_check_controlled_team
player_query_api.gd:28      _query_menu                 守：_check_player_with_team
player_query_api.gd:77      get_team_details            守：_check_player
player_query_api.gd:108     get_member_details          守：_check_player
player_query_api.gd:140     get_trade_preview           守：_check_player_with_team
player_query_api.gd:164     get_trade_direct_preview    守：_check_player_with_team
player_query_api.gd:224     _check_player_with_team     守（它自己就是守衛）
player_query_api.gd:626     get_decision_snapshot       守：_check_player_with_team
```

★★★**而我的第一版說「4 處無守衛」，四處全是誤報** ——
我的守衛詞表裡有 `_check_player(`／`_check_controlled_team(`，
★**沒有 `_check_player_with_team(`** ⇒ 四處都用它。
⇒ **偵測器的詞表不全，長相跟「真的有四個缺陷」一模一樣。**
★★而我是**逐處開檔看上文**才發現的 —— 不是再讀一次那份報告。

**★誠實限（母體的邊界）**：
```
這份普查只涵蓋【一種寫法】：`state.persons[state.player_id]`
★沒涵蓋：`get_player_team_id()` 之後的假設、`player_forced_event` 的處理、
  「玩家隊還在」這種【間接】的假設
⇒ ★★所以它回答的是「直接索引那一族有沒有裸的」，不是「沒有人假設玩家活著」
```

# ★★二、普查②：誰假設「世界會在 game_over 停下來」

**產線裡認識 `game_over` 的 10 處**：
```
world_state.gd:233-234        欄位宣告（資料）
event_system.gd:80-82         ★寫入者（玩家絕後）
player_command_system.gd:929  ★寫入者（隊已滅、無繼承人）
encounter_system.gd:1385      讀者：`if state.player_id == -1 or state.game_over: return`
sim_runner.gd:114-116         ★★★讀者：【凍結世界】—— 正是意圖帳 #43／#44 說不該存在的那一處
```

**誰假設世界會停（推進路徑）**：
```
player_command_api.advance_ticks（:203-219）
  ★★【已經處理了停下來的情況】：它回的是「真的推進了幾 tick」而不是「呼叫成功」，
    還記了 first_stall_tick 與 stall_reason ⇒ ★這一支不假設世界會前進
sim_bridge.advance_ticks（:71-80）
  ★★★【完全不看 advance_tick 的回傳值】⇒ game_over 期間它會空轉 n 圈，
    而且【安靜】—— 沒有任何一行說「世界沒有動」
turn_controls.gd:73           讀 advance_ticks(1) 的 events（不讀停不停）
```

**★★★而最尖的一條**：
```
grep game_over scripts/ui/*.gd ⇒ ★【0 處】
⇒ UI 完全不知道 game over 這件事存在
⇒ ★★玩家看到的是：世界停了，而畫面【不說任何話】
  —— 沒有故事結束的畫面，也沒有「你為什麼不能再推進」的一句話
⇒ ★★★這正是那張排隊的票的前提，而它現在是【量到的】不是【推想的】
```

# 三、這兩份普查對那張票的意義（我不越界下結論，只把數字擺上）

```
①「移除 sim_runner 對 game_over 的認識」的牽動面：★產線只有【1 處】讀它（:114-116）
  ⇒ 移除的動作本身很小；而【移除之後誰來讓玩家知道】是另一件事 —— 那是 WHAT
②而 `sim_bridge.advance_ticks` 不看回傳值這一點【與 game_over 無關也成立】：
  ★它在「等待繼承人」時同樣空轉且安靜 ⇒ ★★那是一個【比 game_over 更廣】的缺口
⇒ 要不要一起處理是你的格，我只指出它們是同一個形狀
```

★**兩份普查都是唯讀**：沒有動 code、沒有動註冊表、沒有 commit。
