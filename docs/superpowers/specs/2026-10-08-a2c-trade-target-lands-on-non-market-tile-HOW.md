# A2c：「貿易」的目標落在非市集格，隊伍在那格上反覆進出貿易（HOW，小票；先 R① 核前提）

```
證據（實作端 A2 修先查，c34e6440e，seed 7，30 天）：「貿易」零成交事件 110 筆裡 108 筆人站在非市集格
  全是 T14，day 16 起在 tile 5006 一天邊緣觸發十幾次（task 在 TRADE 與別的之間來回）；108 筆目標都不是 (-1,-1)
⇒ 目標本身就是 5006，而 5006 不是市集
候選來源（未驗證，實作端提）：options.gd「貿易」to_task → _merchant_trade_target → best_arbitrage_order 回 ord["pos"]＝訂單 origin_pos；
  faction_ai_system.gd:2582／2589／2633／2666 寫 origin_pos＝下單隊【當時的 tile_pos】，不保證是市集
```

## R① 請核
```
(a) 「貿易」的目標除了市集格，還有哪些合法形狀（options.gd:24 有「resident 擺攤 (-1,-1)＝原地交易」；去下單隊所在格做 peer 交易是不是設計內）
(b) 若去非市集格是設計內：到那格時誰負責成交（peer 交易路徑？），沒成交時誰放手／誰記失敗——今天這條路有沒有出口
(c) T14 一天十幾次在 TRADE 與別的之間來回：是同一個 cadence 重選、還是被別的 task 搶走再回來（需實測，讀碼只答得出可能性）
```
序：深層批或 A2 修之後；先核 (a)(b)，(c) 交量測

## R① 結果（0c37cdbd5）＋ systems 追到的真寫者
```
R① (a)：讀者 _merchant_trade_target（faction_ai_system.gd:4860）註解假設「單原點＝下單隊自家市集 outpost」——不成立 ✓
   ★但 R① 列的 4 個寫者（faction_ai:2582/2589/2633/2666）全是求援／施捨單，price＝0.0 ⇒ 套利公式 gain＝(0−估值)×量 ≤ 0，選不到
   ⇒ 真寫者是第 5 處：order_system.gd:81 一般買賣單 origin_pos＝_market_pos(state, team)（:646-657）
     _market_pos：有自家 outpost ⇒ 最近那座；★沒有 ⇒ 回 team.tile_pos（漫遊隊當下站的格）
     :84-86 註解自己寫明這是設計內的回退（「不登錄看板，回退既有碰面傳播」）——給【同格碰面】用的，不是給套利導航用的
   ⇒ 病＝讀者（套利選單）把「碰面傳播用的位置快照」當成「市集」去導航；那支漫遊隊早就走了 ⇒ 商人站在空地上
R① (b)：sim_runner.gd:920 整段（解算／到場判定／記號／release）都包在 `outpost_level > 0` 裡 ⇒ 目標不是 outpost 時沒有出口 ✓
```

## 做什麼
```
①讀者收斂（market-as-place 那條 M1 已立的原則落成結構）：OrderSystem.best_arbitrage_order 只考慮 pos 在【商人自己已知市集】裡的單
   ＝ pos ∈ state.team_market_known[merchant]（同 _nearest_market_outpost 讀的那份 belief；不讀 live tile）
   不在 ⇒ continue＋Probe "trade.arb_kill_not_market"
   ★漫遊隊的單照樣傳播、照樣在同格碰面時成交（interaction 那條不動）；只是不再被當成導航目的地
②出口（防禦，與 ① 互補）：sim_runner._step3c：current_task＝TRADE 且 trade_arrived 為真、而腳下【不是 outpost】⇒ release＋Probe "trade.arrived_off_market"（不記失敗：錯的是目標不是市集）
③不改：_market_pos 的回退（碰面傳播要它）；求援單四個寫者
```

## 驗收
```
P1 走真世界（界限第 24 條）：seed 7 30 天，「貿易」到場且人不在市集格的事件 改前 108 ⇒ 改後印出（先量）；trade.arb_kill_not_market 次數印出
P2 佈置（補充）：商人 belief 裡有一張漫遊隊的單（pos＝空地）＋一張市集單 ⇒ 選市集那張；只有漫遊單 ⇒ 回空 ⇒ _merchant_trade_target 退到最近已知市集
P3 反向：拿掉 ① ⇒ P2 第一格選到空地 ⇒ 必紅
P4 ②：佈置 TRADE 隊站在非 outpost 目標上 ⇒ 當拍 release；反向拿掉 ⇒ 仍是 TRADE
P5 world-fp 會變 ⇒ 先量、同 commit 換基準；A2 修那張的 P2 分母（人在市集格）不受影響
```
序：A2 修之後（同一支 _step3c，避免衝突）
