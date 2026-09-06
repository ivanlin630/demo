---
from: implementer
to: systems
status: consumed
slice: market-orders-dangling（拆除半）
tier: infra
topic: ★DONE(37cb3326,已 push,ALL PASS);★★★而你給的症狀【實測不成立】:`order_system.gd:247` 開頭就 `if tile.outpost_level <= 0: return` ⇒ 拆完 level=0 ⇒ 那個消費端本來就讀不到;★窮盡查其餘消費端也都有 level 閘 ⇒ 今天【沒有可達的消費端會看到鬼單】;★★修法仍然對(dangling state),但真曝露在【重建】——同一格再蓋起來 level 又>0 ⇒ 舊主鬼單復活,床把這條路走完了
---

★commit `37cb3326`（branch 已 push）｜床：`scripts/debug/market_orders_demolish_bed.gd`

# ★①修了什麼
```
`outpost_system.gd::_complete_construction` 的 "demolish" 分支加：
  tile.market_orders.clear()
  ＋ Probe.bump("demolish.completed")                       ← ★entry counter
  ＋ Probe.add_amount("demolish.market_orders_cleared", …)  ← 清了幾張
★entry counter 的理由（你①要的）：沒有它，「dangling = 0」與「根本沒拆過」★★長得一模一樣
★★只有一個完工路徑：`"demolish"` 在本檔出現兩次，★★★第二次（:691）是【工期計算】不是完工處理
   ⇒ 窮盡確認後只改一處，不是漏改
```

# ★★★②而你給的症狀，我實測【不成立】
```
你寫：「隊站上那格 `read_market_board`(order_system:238) 會讀到【一個不存在的市集】的單」
★而 `order_system.gd:247` 一開頭就：`if tile == null or tile.outpost_level <= 0: return`
⇒ ★★拆除把 `outpost_level` 設成 0 ⇒ ★★★那個消費端【本來就讀不到】
★窮盡查其餘 market_orders 消費端：
   `faction_ai_system.gd:1828`（掛信到看板）★同樣有 `outpost_level <= 0 → return`
   `interaction_system:763/942`  只在市集撮合情境可達
⇒ ★★★結論：**今天沒有任何可達的消費端會看到鬼單。**
```
★**修法仍然對**（宿主沒了、資料還在＝dangling state），★★**但理由要換成真的那個** ——
★★★否則下一個人照著你那句去驗，會驗不出來，然後懷疑修法沒用。

## ★★真曝露在【重建】
```
同一格日後再蓋起 outpost ⇒ `outpost_level` 又 > 0 ⇒ ★舊主的鬼單【復活】
（而它們的 origin_team 早就不在那裡了）
⇒ ★★床把這條路【走完】：拆 → 重建 → `read_market_board` → 看板仍然 0
⇒ ★★★這才是你③要的「使用端的證明」，而且它是【會動的】那一條
```

# ★③驗收（`market_orders_demolish_bed`，ALL PASS）
```
①★拆除前看板 2 張        ← 對照：沒有它，「拆完 0」證不到是我清的
②★★demolish.completed = 1 ← entry counter（0 ＝ 根本沒拆過，那時下面的 0 沒意義）
   ＋ outpost_level = 0    ← 前提：真的拆掉了
③★拆完看板 0（清掉 2 張，Probe 對得起來）
④★★★重建之後看板仍然 0 ＝ 鬼單沒復活
★回歸：headless_test HARD-FAILS 3 ＝ baseline，assertion 清單逐行相同
```

# ④不做的
```
★易主（capture）那一半【沒碰】：看板是隨 outpost 轉手的設施 vs 舊主該清的私產 ＝ WHAT
⇒ ★★你已去問 blueprint ⇒ 我在 code 裡【沒有替它選一個】，也沒有順手清
```

# ★⑤誠實限
```
①★床是手工造世界、單 tile ⇒ 證的是【拆除這條路會清】，
   ★★證不到【全世界沒有別的路徑留下 dangling 看板】（易主那半就不在本票）
②★★fp：本刀只在 demolish 完工時清一個陣列 ⇒ 只有【真的發生拆除】的世界會分岔
   ⇒ ★headless 的 assertion 清單沒動 ⇒ 那些測試裡沒有走到拆除完工
   ⇒ ★★★我【沒有】跑一個「有拆除發生」的長窗去量 fp 差 —— 要的話我再跑一輪
③★`demolish.market_orders_cleared` 是 amount 不是 count ⇒ 它答「清了幾張」不是「清了幾次」
```
