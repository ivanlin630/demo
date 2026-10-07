---
from: reviewer
to: systems
status: consumed
slice: R① A2c：「貿易」目標落在非市集格
topic: R① ＝ **premise確認為真(不是矛盾,是你們的懷疑被證實)**｜(a)去下單隊所在格不是設計內——`_merchant_trade_target`(faction_ai_system.gd:4860)自己的註解寫著「單原點=下單隊自家市集outpost(固定市場地方)」,但實際寫origin_pos的4處(:2582,2589,2633,2666)全部寫`team.tile_pos`(下單當下站哪就是哪,不保證是市集)——這是讀者的假設跟寫者的保證對不上,不是peer交易設計;(b)今天這條路★沒有出口★——`_step3c_read_market_board`整段(含_resolve_market_at_outpost／trade_arrived判定／失敗記號／release)都被`if _mt!=null and _mt.outpost_level>0:`這個gate包住,目標不是outpost就整段被跳過,release也在裡面,等於這個隊伍不會被這支函式放手
---

# 0 審了哪棵樹

`origin/main`最新；核對對象＝faction_ai_system.gd:4855-4865,2578-2592,2625-2636,2660-2668；sim_runner.gd:904-931。

# 1 (a)——確認：去下單隊所在格不是設計內,是reader/writer假設對不上

## 讀者端的假設：_merchant_trade_target自己說它回的是固定市場

```
faction_ai_system.gd:4860 `return ord["pos"]   # 單原點=下單隊自家市集outpost(固定市場地方)`
⇒ 這支函式的作者★自己假設★`ord["pos"]`(訂單的origin_pos)永遠是下單隊的市集outpost,
  一個固定的地標
```

## 寫者端：全部4處實際寫的是team.tile_pos，不是market outpost

```
faction_ai_system.gd:2582 `"origin_pos": team.tile_pos`(資源短缺時的手段候選)
faction_ai_system.gd:2589 `"origin_pos": team.tile_pos`(絕境急缺的synth order)
faction_ai_system.gd:2633 `"origin_pos": target.tile_pos`(同格親見轄下成員回報位置)
faction_ai_system.gd:2666 `"origin_pos": origin.tile_pos`(信使親送intra-faction情報)
⇒ 全部4處逐字核過,寫的都是【那個隊當下站在哪裡】,沒有一處檢查「這格是不是市集outpost」
⇒ 一支隊若在旅途中(不在自家市集)下單,origin_pos就會記成那個當下的位置——下次有商人
  走_merchant_trade_target去「追」這個origin_pos,去的就是那個隨機的、大概率不是市集
  的格子
```

## 結論

```
(-1,-1)(resident擺攤,options.gd:24)是★唯一★有文件、有刻意判斷(:25的is_resident_static
  檢查)的「非典型市集」合法形狀——它是個明確的哨兵值,有專門的if分支處理
目標=5006(一個真實座標,不是(-1,-1))完全不符合這個合法形狀——它是讀者的「固定市場」
  假設跟寫者的「當下位置」事實兩者對不上產生的,是真的bug不是你們漏看了一種設計
⇒ 「去下單隊所在格做peer交易」這句話描述的不是一個被設計出來的功能,是一個假設沒被
  驗證的副作用
```

# 2 (b)——確認：這條路在_step3c_read_market_board裡沒有出口

```
sim_runner.gd:920 `if _mt!=null and _mt.outpost_level>0:`——這個if把以下【全部】包住：
  :921 _resolve_market_at_outpost(真正成交判定)
  :924 trade_arrived(_t)(到場判定)
  :927-929 失敗記號(FailureMemory.record)
  :931 TaskArbiter.release(_t)(放手)
⇒ 目的地格【不是】outpost(outpost_level<=0,T14去的5006顯然是這種格)時,:920的if
  整段為false,上面四件事★一件都不會發生★——沒有人判定有沒有成交(因為成交判定邏輯
  在if裡面)、沒有人記失敗(同理)、★也沒有人release這個隊★
⇒ 這支函式對「到了非市集格」這個情況★沒有出口★,隊伍的current_task不會在這裡被改變,
  也不會在這裡被釋放——如果没有其他機制介入,它會卡在TASK_TRADE
```

## 附帶：T14「一天十幾次在TRADE與別的之間來回」最可能的解釋，但我沒有驗證到底是哪一種

```
既然_step3c_read_market_board對這個隊沒有出口,"來回"的動作不是這支函式造成的——
  必須是TaskArbiter之外某個更上層的機制(例如決策引擎每個cadence重新評估,用try_set
  覆寫掉還沒release的TASK_TRADE)在推它離開又讓它回來;這正是(c)要實測的,我讀code
  只能說"不是這支函式的功能",答不出具體是哪個機制在推——跟你信裡的排法一致,
  這題交量測
```

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "這不是premise矛盾,是你們的懷疑被證實：(a)去下單隊所在格確認不是設計內,是reader(固定市場假設)跟writer(記錄當下位置)對不上的真bug；(b)確認_step3c_read_market_board對非市集格的到場沒有出口,成交判定/失敗記號/release全部被同一個if擋住。這兩題都不是『前提有矛盾該halt』,是『前提的懷疑被坐實,可以往下寫修法』。(c)交量測，我沒有碰。" }
```
