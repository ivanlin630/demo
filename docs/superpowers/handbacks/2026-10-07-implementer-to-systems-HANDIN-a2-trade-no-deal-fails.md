---
from: implementer
to: systems
status: open
slice: A2 貿易等不到對手＝失敗＋自家市集只禁自己的單
topic: ★**交件｜已知紅 0**｜BATTERY_RC=0｜111 綠／0 紅（run-id `21966-20261007-174354`，HEAD `7993010b7`）｜branch `feat/a2-trade-no-deal-fails` 遠端 tip **`3562864ee`**（已疊 origin/main ccf281aba；含 artifact 一顆）｜world-fp → **6019f170**｜新列 a2-trade-no-deal｜★P7 C2 分子變小、比例沒變小 ⇒ 要你裁
---

# 一、改了什麼（spec 2026-10-07-a2-trade-that-finds-no-deal-fails-and-releases-HOW.md）

```
①入口兩道閘（A3 的自家市集領取分支／別人市集才進 resolver）拿掉 ⇒ _step3c_read_market_board 只留 resolver 一條路
  resolver 的「自家市集不自交易」從【地點】改成【單】：撮合時跳過 origin_team ＝ 訪客的那幾張
②SimRunner.trade_arrived（抵達判法抽成一支：current_task＝TRADE 且 move_target＝這格或已清成 (-1,-1)）
  承諾「貿易」而來（current_option＝貿易）、沒成交 ⇒ FailureMemory.record(…"貿易", tile_id, ORDER_LIFETIME, "trade_arrived_no_deal")＋當場 release
  「貿易」從缺席表移到 OPTION_FAIL_KEY：target ＝ ctx:trade_target_tile_id
  ★DecisionContext 新欄 trade_target_tile_id：商人有套利單 ⇒ 那張單的市集，否則最近已知市集（同 options.gd「貿易」to_task 的 _merchant_trade_target）
    ——兩個值 gather 裡本來就算了（best_arbitrage_order、_nearest_market_outpost）⇒ 零新呼叫
  ★只記 option「貿易」：領取有自己的落空記號（A3）；別的 option 帶 TRADE 抵達照放手、不記
③賣單到期：不做（照 spec）
```

# 二、驗收（新床 a2_trade_no_deal；修前紅 5 條 → 修後綠）

```
P2 自家市集、板上只有別人的收購單 ⇒ 成交 true（修前 false）｜反向：只有自己的單 ⇒ false
P3 承諾貿易抵達空板市集：move_target＝這格／已清成 (-1,-1) ⇒ 失敗記號＋放手（修前兩格都沒記號）｜反向：路過 ⇒ 不記、不放手
P4 同一市集連撞兩次 ⇒ 貿易折價 0.800 → 0.600（修前 1.000／1.000）
P6 claim_on_arrival 呼叫點 2 → 1
P1 Team40（fp 世界 t9000 後一天）：「帶貿易站在自家市集、已抵達」0 tick —— ★修前就是 0（A4 落地後前提消失，spec §1⑤ 預告的那件事）⇒ 留作回歸守衛，這一格修前沒有鑑別力
P7 普查床 C2（window_timing_ticketA_ratios.gd，seed 1337，同機；修前樹 ccf281aba／修後 f7d079f8c）：
   15 天 19／38 → 18／34｜30 天 22／43（51.2%）→ 21／39（53.8%）
   ★分子變小、分母縮得更多 ⇒ 比例略升 ⇒「必須變小」看你指的是哪一個；我沒有改量法
P8 fp 6019f170（單跑量）
```

# 三、電池第一輪紅 1 ⇒ 已改判

```
claim-own-market P4「非領取 option 帶 TRADE 抵達自家市集不 release」—— A3 時 systems 裁 (B)；A2 spec（藍圖裁 eeca99661）明文拆閘、只留一條路
⇒ 改成「抵達即放手」（舊斷言劃線保留、註明 A2 改判）；「不是承諾領取 ⇒ 不記領取落空」那半照舊
```

# 四、要你知道的

```
①自家市集跟別人的單成交，結算照既有「主人居中」：訪客就是主人 ⇒ 錢與貨在自己隊與自家庫房之間移轉（收購單：自家付錢收貨進庫）
  ⇒ 藍圖裁「只禁自己的單」照做；這個結算形狀是否合理是另一件事（沒動）
②序列裡 A2 前面的「B」沒有發給我的派工信 ⇒ 我照 A2 派工直接做（A2 依賴 A4，已落地）
③下一張照你的序：M 一顆 tick（修法＋E2E 已寫好在 feat/move-command-one-tick，接著跑）
```
