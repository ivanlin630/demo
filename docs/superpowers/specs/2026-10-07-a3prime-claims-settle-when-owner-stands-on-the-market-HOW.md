# A3′：待領資產在本人站上那個市集的那一刻結清（任何市集、任何任務）（HOW）

```
票源 ＝ 藍圖裁 2026-10-06（`…RULING-a3prime-all-markets-and-tribute-messages-vs-ledger-must-reconcile.md` §一）：
  到場即結清適用**全市集**；結清後帶回家的路上風險是真實不是副作用；掠奪／勒索／徵收**不改**去讀 pending_claims；
  「故意不領來逃徵收」記一行不開票（已在 known_issues）
基準樹 ＝ `031492cce`｜序 ＝ **A2 之後**（A2 把入口自家市集分支拿掉、resolver 成唯一路；本票再把領取搬出 resolver）
```

## §0 現況（file:line）

```
①領取只在**帶 TASK_TRADE 抵達**時發生：`sim_runner.gd:856`（`if _t.current_task == TASK_TRADE`）內兩條路
   ·自家市集：`:864` claim_on_arrival（A3）｜·別人市集：resolver `interaction_system.gd:938` claim_on_arrival
   ⇒ 帶其他任務（行軍、運輸、逃跑…）站上有自己待領的市集 ⇒ **不結清**
②**站著不動的本人**：待領在本人**已經站著**的那一格產生（`add_pending_claim`，呼叫點 `interaction_system.gd:1177` 款／`order_system.gd:215` 貨）
   ⇒ 它不會「抵達」⇒ 只看抵達的話**永遠不結清**（Team14 那一型：站在自家市集，錢在腳下領不到）
③結清本體只有一份：`_claim_pending_here`（`:1072`）—— 這一點保留
```

## §1 做什麼

```
①【抵達觸發】結清從「TRADE 分支內」搬到 `_step3c_read_market_board` 的迴圈**最前面**、不看任務：
   arrived 的隊站在 outpost_level>0 的格 ⇒ claim_on_arrival(state, _t, tile)
   ⇒ resolver 內 `:938` 那一行**拿掉**（否則 TRADE 隊在同 tick 結清兩次 —— 第二次必空，但會誤記「領取落空」）
②【產生觸發】`add_pending_claim` 加 `state` 參數（呼叫點 2 處）：條目寫入後，若 owner 隊 `tile_pos == tile.tile_pos` ⇒ 當場呼 `_claim_pending_here`
   ⇒ ★語意：本人在場 ＝ 不需要待領（待領存在的理由就是「不在場」，`:1171-1172` 註解自己這樣寫）
   ⇒ ★走同一支 `_claim_pending_here`（帳本 reason 照舊 claim_coin／claim_goods）—— **不**改成直接 ResourceBank.add 繞過待領
     （理由：Probe 的 opened／taken 兩欄要能對帳；繞過會讓「產生了幾筆」與「領走幾筆」各自少一邊）
③「領取落空」記號不動：只在 `current_option == "領取"` 且這格領空時記（`:1066`）—— 路過的隊沒東西可領不是失敗
④不改掠奪／勒索／徵收的讀者（藍圖裁）
```

## §2 驗收

```
P0 [序依賴的機械守衛]（R² 打回：序只是一句宣告，不是擋板）動工前、交件時各跑一次並把輸出貼進卷面：
   `git grep -n "claim_on_arrival(" -- scripts/simulation/sim_runner.gd` ＝ **0 行**（A2 已拿掉入口自家市集分支）
   `git grep -n "outpost_owner != _t.team_id" -- scripts/simulation/sim_runner.gd` ＝ **0 行**（A2 已拿掉入口 owner 閘）
   ⇒ 任一非 0 ⇒ **不動工**，回報 systems（A2 未落地或落在別的 branch）
   ★今天（`86e01bc31`）兩條都非 0 ＝ 預期（A2 還沒做）
P1 [鑑別格・普查] 每 tick 末數「待領 amt>0 且 owner 隊正站在那一格」的 (隊, 格) 對 ⇒ **修後恆 0**
   ⇒ 修前先量紅基線（世界＝觀察輪那個 30 天 default seed 1337；也跑 fp 世界）並印出；若修前也是 0 ⇒ 本格無鑑別力，**回報不要硬過**
P2 [非 TRADE 抵達] 佈置：隊帶非貿易任務（例：行軍）抵達有自己待領的市集 ⇒ 同 tick 結清；★反向：**別隊**的待領不動
P3 [站著產生] 佈置：隊站在自己市集、別人吃了它的賣單（escrow 路）⇒ 同 tick 款進 team.coin，tile.pending_claims 不留它的條目
P4 [一次] TRADE 隊抵達別人市集且有待領 ⇒ 結清恰 1 次、「領取落空」記號 0（拿掉 :938 的證明）
P5 [守恆] 每筆結清：帳本 claim_coin／claim_goods 的 delta 總和 ＝ 條目 amt 總和（逐 tick）；`mkt.claim.added.*` − `mkt.claim.taken_*` ＝ 期末仍掛著的 amt
P6 [單一結清點] `_claim_pending_here(` 的呼叫者只有 claim_on_arrival 與 add_pending_claim 兩處（印出 grep 數，排除註解行）
P7 [負對照] 拿掉②⇒ P3 紅、P1 若有基線也紅；拿掉①的「不看任務」⇒ P2 紅
P8 fp 會變 ⇒ 先量、變了才換、原子落地
```

## §3 誠實限

```
·「抵達」以 arrived_ids 為準 —— 被傳送／生成在市集上的隊不經抵達；那一型靠②（產生觸發）也接不住（條目早於隊）
  ⇒ P1 的普查格就是為這個留的：若修後仍非 0，印出那些對，回報，不在本票擴
```
