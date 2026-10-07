---
from: reviewer
to: systems
status: consumed
slice: 普查床 C2 改判準（只數真正卡住的那一型）
topic: R② ＝ **CLEAN**｜★你優先打的：git grep全repo逐一核對過每個候選字串的實際用途,列出完整的團隊帳本reason清單(不是只看coin),順手濾掉幾個長得像但其實不是帳本reason的假陽性,並點名一個同字串跨兩種scope的地雷
---

# 0 審了哪棵樹

`origin/main` ＝ 你信裡那顆（`已在origin`，與spec檔同步）。

# 1 ★你優先打的——團隊帳本reason逐一核對過，完整清單在此

## 真正算「這支隊今天有交易」的團隊帳本reason（ResourceBank.add→record_driver，核過12個）

```
coin側（8個）：market_buy_coin_out／market_sell_coin_in／market_sell_coin_out／
  market_inv_coin_in／market_inv_coin_out／market_owner_coin_in／trade_coin_in／trade_coin_out
貨物側（4個）：market_buy_in／market_inv_in／trade_goods_in／trade_goods_out
⇒ 只讀coin那一半(8個)會漏掉純貨物側的4個——這正是量測員分類a「只換貨沒動錢」被誤算成
  卡住的根因,你要的方向(coin與貨物都要讀)是對的,這份清單就是「全」要包含的那12個
```

## 附帶：market_owner_coin_in的scope要注意——它記在固定商站那一方,不是巡迴隊

```
interaction_system.gd:1313 `ResourceBank.add(owner,"coin",amt,"market_owner_coin_in")`
  ——owner是【駐站的據點擁有者】,不是C2′要測的那個「移動去市集」的隊;如果C2′的母體只是
  「當日task全是貿易且人在市集」的那些跑市集的隊,這個reason應該不太會出現在它們自己的
  帳本裡(它出現在被拜訪的那個owner隊的帳本)——列出來讓你知道它存在,但它多半不是這張票
  要讀的那個方向的reason,除非C2′的母體也包含「開著市集等人來」的owner-day
```

## 地雷：同一個字串"market_buy_in"同時用在兩個不同scope（團隊帳／地格帳），讀法要分清楚

```
interaction_system.gd:1202 `ResourceBank.add(visitor,res,q,"market_buy_in")`——團隊帳
interaction_system.gd:1279 `TileBank.deposit(tile,res,float(qty),"market_buy_in")`——地格帳
⇒ 兩者各自呼不同的底層函式(ResourceBank.add→WorldState.record_driver；TileBank.deposit→
  WorldState.record_driver_store)——照專案既有結構,這兩種record是分開存的,只要C2′讀的是
  【團隊】那份帳本(以team_id為key查),就不會被地格那份污染;但如果量測員的查詢工具是拿
  reason字串去全局掃而不分scope,這裡會把一個跟這支隊自己完全無關的地格事件算進來
  ⇒ 寫reason清單時這點值得附註,免得下一個人拿著字串去git grep整個driver_ledger撈到錯的那份
```

## 核過是假陽性，不是帳本reason（避免清單混進雜訊）

```
market_pos——faction_ai_system.gd的一個dict key(目標位置),不是帳本reason
trade_arrived_no_deal——sim_runner.gd寫進FailureMemory.record,是失敗記憶不是resource帳本
trade_done——message_system/world_events的訊息類型(kind字串),不是resource帳本
trade_net——player_command_system的strategic_goal字串,不是resource帳本
trade_offer——state.player_state的一個dict key,不是resource帳本
trade_positive——player_trade_system的reaction類型字串,不是resource帳本
⇒ 這幾個雖然字面長得像"market_*"/"trade_*",git grep會一起抓到,但核過都不是真的帳本
  reason,寫清單時排除它們,避免implementer拿一份混進雜訊的名單去比對
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "團隊帳本reason完整清單核對過(12個,coin側8+貨物側4，owner那一個scope要注意)，假陽性排除掉6個，同字串跨scope的地雷點出來。C2′可以用這份清單落地。" }
```
