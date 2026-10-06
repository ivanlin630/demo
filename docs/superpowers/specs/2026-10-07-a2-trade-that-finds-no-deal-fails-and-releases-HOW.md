# A2：貿易等不到對手要被記成失敗＋自家市集可與別人的單成交（HOW）

```
票源 ＝ 藍圖票 A（A2：貿易 committed 8 天、util 0.67→0.89、零成交零回饋）＋藍圖裁 `eeca99661`（自家市集規則只禁自己的單；
  貿易抵達無可成交單＝失敗 ⇒ 當場釋放＋失敗記號）
基準樹 ＝ `fdf5a12b2`｜序 ＝ B 之後（實作端序列）
★失敗記號形狀＝A3 已落地那一條（`FailureMemory.record(state, team, 動詞, 目標, ttl, reason)`），**不新造**
```

## §0 現況（file:line）

```
①自家市集兩道閘（A3 後的樣子）：入口 `sim_runner.gd:869` `outpost_owner != _t.team_id` 才進 resolver（自家市集走 `:864` 的領取分支）；
  resolver 內 `interaction_system.gd`「自家市集不自交易」早返回（A3 已把領取搬到它之前）
  ⇒ 兩道閘禁的是**地點**，而藍圖裁的 WHAT 禁的是**自己的單**
②貿易到場無單：`interaction_system.gd:980` 只 `Probe.bump("trade.market_bail.no_board_order")` —— **沒有失敗記號、沒有釋放**
  ⇒ `failure_memory.gd:67` 自己就把「貿易」列在缺席清單：「TODO ── trade.market_bail 可偵測；同一市集重撞」
③掛單到期：`order_system.gd:262-264` **只有買單**記失敗（`"買單"`、`order_abandoned_buy`）；賣單到期只退貨（Team0 掛賣 1026 糧無人買那一類）
④Team40 t9000：套利派貿易到自家 ⇒ 入口閘擋 ⇒ 不交易也不 release ⇒ 卡住（main 上仍在）
```

## §1 做什麼

```
①【自家市集規則】入口 `:869` 的 owner 閘**拿掉**；resolver 內「不自交易」從「地點」改成「**單**」：
  撮合時跳過 `origin_team == visitor`（自己的單）的那幾張，**其餘照常**
  ⇒ ★A3 加的入口自家市集分支（`:864`）就不再需要 —— 領取在 resolver 早返回之前已做（A3）⇒ **拿掉那個分支、只留 resolver 一條路**
    （判準庫：兩個入口做同一件事 ⇒ 會漂；A3 那時加它是因為入口閘還在）
②【到場無可成交單 ＝ 失敗】resolver 回 `dealt == false` 且隊伍是**承諾貿易而來**（current_task＝TRADE 且 move_target＝這格）⇒
  `FailureMemory.record(state, team, "貿易", str(tile_id), ORDER_LIFETIME, "trade_arrived_no_deal")` ＋ **當場 release**
  ⇒ `failure_memory.gd:67` 那一格從缺席清單移到 `OPTION_FAIL_KEY`（它自己寫著「補上時這格要改判」的那種）
  ⇒ ★「承諾貿易而來」的判法要窄：路過的 TRADE 隊（目的地不是這格）不算失敗
③【賣單到期 ＝ 失敗】`order_system.gd:262` 的 `if kind == "buy"` 擴成買賣兩邊（賣單 reason `order_abandoned_sell`），
  動詞照建單的那個 option（★先查：賣單是哪幾個 option 建的、`OPTION_FAIL_KEY` 有沒有對應鍵）
④★TTL 用 `ORDER_LIFETIME`（相對錨定，同買單那條的理由），不新增常數
```

## §2 驗收

```
P1 [Team40 紅對照] fp 世界 t9000：修前 Team40 卡在自家市集（不交易、不 release）；修後 ⇒ 若板上有別人的單就成交，
   沒有就失敗記號＋release（印 t9000 之後它下一個 task）
P2 [自家市集成交] 佈置：自家市集上有一張**別人**掛的單、本隊帶 TRADE 抵達 ⇒ 成交；★反向：只有**自己**的單 ⇒ 不成交（＋失敗記號）
P3 [無單即失敗] 佈置：承諾貿易抵達一個空板市集 ⇒ 同 tick 失敗記號＋release；★反向：路過（目的地非此格）⇒ 不記
P4 [持守變弱] 同一市集連撞兩次無單 ⇒ 第二次之後「貿易」對那個市集的 util 下降（失敗記憶生效的證明）
P5 [賣單到期] 佈置一張無人買的賣單到期 ⇒ 失敗記號（`order_abandoned_sell`）
P6 [單一路徑] 反向掃：`claim_on_arrival` 的呼叫點 ＝ 1（入口分支拿掉後）
P7 [普查床] 票 A 的 C2（at_market 且 committed 貿易而 coin 零變動的隊·日）**必須變小**（本票的鑑別格）
P8 fp 會變 ⇒ 量、原子落地
```
