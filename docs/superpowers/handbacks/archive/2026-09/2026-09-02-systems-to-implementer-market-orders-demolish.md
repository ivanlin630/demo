---
from: systems
to: implementer
status: consumed
slice: market-orders-dangling（★只做【拆除】那一半）
topic: ★族④ #6:capture/demolish 都不清 tile.market_orders(我複驗:三支函式對它的參照皆 0,而條目原本的錨指錯門牌已訂正);★★本票【只做拆除】——宿主沒了看板還在=結構問題,我可以派;★★★而【易主】那一半含設計成分(看板算誰的)已去問 blueprint,不要一起做;★驗收要能分「沒有 dangling」與「根本沒發生拆除」
---

# ①事實（我複驗過，不是照抄條目）
```
outpost_system.gd:839 capture / :636 start_demolish / :825 demolish_with_control
  ⇒ ★三支對 tile.market_orders 的參照【皆為 0】
★唯一會動 tile.market_orders 的是 order_system.gd:112/:256/:330 的到期/relay 裁剪
★★條目原本的錨寫 `slot_cap()`（設施格數函式，不是 capture）——★已訂正，別照舊條目找
```

# ★★②本票只做【拆除】那一半
```
★理由：outpost 被拆 ⇒ ★★【宿主沒了，看板不該還在】—— 這是結構問題(dangling state)，不是設計選擇
   ⇒ 症狀：隊站上那格 read_market_board(order_system:238) 會讀到【一個不存在的市集】的單
★★★而【易主】那一半我【沒有】派給你：看板是實體設施(隨 outpost 轉手) 還是舊主的私產(該清)
   ＝ WHAT，我已去問 blueprint。★不要順手一起做，也不要在 code 裡替它選一個。
```

# ★③驗收（★重點在能不能分辨「沒有 dangling」與「根本沒拆過」）
```
①★拆除路徑要有 entry counter：demolish 被走到幾次 —— ★★否則「dangling = 0」與「沒拆過」長得一樣
   （★這是本檔判準⑨與「指標=0 三讀法」的③：母體塌陷）
②★★拆除後該 tile 的 market_orders.size() 必須 0；★同一張床要有【拆除前 > 0】的對照，
   否則證不到是你清掉的
③★★★別忘了 `read_market_board` 那條讀路徑：拆除後隊走上去，board_read 必須讀不到東西
   —— ★這是使用端的證明，比直接看欄位強
④`fp`：★這是行為修正，fp 會變 ⇒ 照 godview-1a 的規矩：【差在哪要說得出來】
```
