# HOW spec：C1 票① —— agent／REPL 動詞補課

owner: systems ｜ 2026-09-10 ｜ **player_reachable: yes** ｜ 用戶裁「好 那由我玩」

上游：用戶要**親手玩**。blueprint 裁：拉到 implementer 失敗反饋收尾後的下一張，
批二②③與市場窗後移。★**範圍釘死在 agent/REPL 層** —— GUI 五分頁與文字版畫面走查是**票②**。

## §1 現況（★我 grep 過的，不是印象）

```
player_command_api.gd 的動詞：move_to / cancel_move / execute_action / respond_to_forced
                              equip / unequip / deposit_item / take_team_item / dispatch
★市場：`grep -rn "market|買|賣|掛單" player_command_api.gd` ⇒ 【0 命中】
   ★★而 `execute_action` 的 "trade" 是【隊對隊直接交易】(`_action_trade` / `trade_offer`)，
     ★★★【不是】板上掛單／撮合（`order_system` 的 `post_order` / `read_market_board`）
★附身／離身：`grep -rn "possess|附身|離身" player_*.gd` ⇒ 【0 命中】
★時間控制：`grep -rn "set_speed|time_scale|pause" player_*.gd` ⇒ 【0 命中】
   （tick 推進在 `sim_runner.advance_tick`，而玩家層沒有入口）
```
⇒ ★**世界有市場，而玩家/agent 碰不到它** —— 這正是 `player_reachable` 那一欄要抓的東西。

## §2 範圍（★釘死，不得長大）

```
✔本票：agent／REPL 層
   ①市場四件套：看板 / 掛買單 / 掛賣單 / 撤單
   ②附身 / 離身
   ③時間控制
   ④★每個動詞【一條自檢腳本】（`player_reachable: yes` 的既有要求：agent 自檢要斷言得到）
✘不在本票：GUI 五分頁、文字版畫面走查給用戶簽（＝票②）
✘不在本票：改動任何 `order_system` 的既有行為（★只加入口，不改機制）
```

## §3 修法要點

```
①市場四件套【接既有函式，不要新寫一份市場邏輯】：
   看板   order_system.read_market_board(state, team)（★或讀 tile.market_orders 的既有結構）
   掛單   order_system.post_order(state, team, kind, res, qty)
   撤單   ★`grep` 現有的撤單路徑（`tick_team_orders` 內有過期/移除邏輯）——
          ★★若【沒有】獨立的撤單函式，那是本票要補的【唯一新機制】，
          ★★★而它要寫成【與既有移除路徑共用】，不是第二份。
②附身／離身：★語意先定——「附身」＝把 `state.player_id` 指到某隊 leader？還是換控制權？
   ⇒ ★★`grep` 現有的 `player_id` / `controlled_team` 用法，**沿用既有語意**，不要發明第三種。
③時間控制：★入口是 `sim_runner.advance_tick` ⇒ 玩家層要的是【推進 N tick】與【暫停】
   ⇒ ★★不要在 sim_runner 裡加狀態；★★★把「推進幾步」留在【呼叫端】(REPL)，
     否則會多出一個「誰在控制時間」的第二真相源。
④每個動詞一條自檢腳本：★格式沿用既有 agent 自檢；★★每條要能【斷言到世界真的變了】，
   不是「呼叫沒有報錯」。
```

## §4 驗收

```
①【每個動詞都有自檢】且★★自檢斷言的是【世界狀態變化】不是【回傳值非空】
   ★成對對照：把該動詞的實作註解掉 ⇒ 對應自檢必須紅
②★★★【市場動詞真的接到既有市場】：掛一張買單後，
   `tile.market_orders` 裡【看得到它】,且它會被既有撮合流程處理
   ⇒ ★不是「我們自己記了一筆」——那會是第二個市場。
③附身／離身：附身後 `get_player_snapshot` 的視角【真的換了】；離身後回到原狀
④時間控制：推進 N tick 後 `state.world.current_tick` 增加 N（★而不是「呼叫成功」）
⑤★不改既有行為：本票 merge 前後，★★headless／determinism fingerprint【不變】
   ⇒ ★★★這格是本票的安全網：只加入口不改機制,fp 變了就表示我們動到了世界
```

## §5 ★★★【資訊完整性格】—— 用戶追加，而它必須是**機械對帳不是自律**

> 用戶：「**UI 需有所有資訊，否則又像之前一樣我會很沮喪**」

★**母體不是「我們覺得玩家需要什麼」，是【決策引擎替這支隊讀的每一個欄位】**：
```
scripts/simulation/decision/decision_context.gd  的 `var` 欄位 ⇒ ★實測【119 個】
對照面：`player_query_api.gd` 的查詢動詞 ⇒ 實測【18 支】
⇒ ★★逐格打勾：每一個 ctx 欄位，玩家【讀不讀得到】？
⇒ ★★★盲格必須【歸零或具名豁免】，而具名豁免【呈用戶】——不是我們自己勾掉。
```

★**為什麼母體要取 `DecisionContext` 而不是別的**：
> **它是【引擎替那具身體看世界時真的讀了什麼】** —— 世界給的清單，
> ★★而不是**我們想像玩家需要什麼**（那會是作者想像中的形狀，今天已經栽過六次）。

★★**邊界（照既有 C1 裁定，寫死免得長大）**：
```
「所有資訊」＝【這具身體知道的所有】：
   隊的全狀態 ＋ belief store 完整顯示 ＋ 自己的單據/待領款 ＋ 事件流
✘【不含】他人內心 ⇒ ★非 god-view
★而附身 ＝【繼承記憶】⇒ ★★所以這是【顯示問題】不是【資料問題】：
   資料已經在 belief store 裡,缺的是把它端出來的動詞。
```

★★★**這一格的病歷（寫進 spec 免得下一輪又忘）**：
```
P9 交付【零玩家格】＋指令表停了六個月 ⇒ ★機制長了，而玩家面沒跟
⇒ ★★而 `player_reachable` 那一欄與本格,就是【防再犯的閘】
⇒ ★★★所以本格【不能是一句「我檢查過了」】—— 要有一份【逐格清單】落地成檔案。
```

**驗收（併入 §4）**：
```
⑥【資訊完整性對帳表】落地成檔案（★不是寫在 handback 正文裡就算）：
   `ctx 欄位 ｜ 玩家讀得到嗎 ｜ 經由哪個查詢動詞 ｜ 豁免理由（若盲）`
   ★★119 列全在（★缺列＝母體被削,而那是今天的頭號病）
   ★★★盲格數要【印在總結行】—— 讓它可以逐輪比較,而不是每次重讀全表
```

★誠實限：
1. 本票**不做** GUI、不做畫面走查（票②）。
2. ★**用戶玩 ＝ 體驗回饋，不是驗收**（既有裁定）⇒ **fidelity 義務仍在系統自己身上**；
   他玩到的問題**回 blueprint 彙整**，不直接當工單。
3. ★★**撤單若真的沒有既有路徑**，那是本票唯一的新機制 ⇒ **要在 handback 明講**，
   ★★★而不是混在「四件套都做好了」裡面。
