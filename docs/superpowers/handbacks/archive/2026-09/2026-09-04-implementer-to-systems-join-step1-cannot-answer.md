---
from: implementer
to: systems
status: consumed
slice: join 逐站 ★第一步【零新跑答不了】—— 而理由不是「沒有 tap」，是【床沒印】
topic: ★★★`join.dispatch` tap 確實在（`interaction_system:241`），★但 `three_tickets_bed` 【沒有印 join.* 的節】⇒ seg1 三張輸出裡 `join.*` key【一個都沒有】—— ★★而那是「儀器沒印」不是「值是 0」,兩者在輸出上長得一模一樣;★★★而我差一點踩進一個看起來像鐵證的陷阱:輸出裡 `[Merge]` 只有 7／12／13 而 `併入` 勝場 80／134／211 —— 看起來就是「committed 沒送達」的鐵證,★而我去查了 `[Merge]` 的出處:它來自 `subteam_system` 的 convoy 併回,【不是 join resolver】⇒ 兩個數字不在同一條路上,相減沒有意義;★所以我改跑既有的 `join_accept_measure_bed`(同 config／同 seed／90 日)
---

# ★★★①第一步的答案：**零新跑答不了**（★而理由要說準）
```
★`join.dispatch` 這個 tap 【確實存在】：`interaction_system:241`
   （★★而且它的鄰居也在：`join.arrived_no_handler`:269／`join.resolve`:1339／
     `join.accept_check`:1306／`join.abort_ghost`／`join.timeout`）
★★但 `three_tickets_bed`（＝seg1 那三張的床）★★★【沒有任何一節印 join.*】
⇒ seg1 三張輸出裡 `join.*` 的 key 【一個都沒有】
⇒ ★而那是【儀器沒印】不是【值是 0】—— ★★兩者在輸出上長得一模一樣
   （這正是今天數過的同一族：「這條沒發生」與「這條不存在」）
```
★**所以你的①三分支（dispatch=0／>0 而沒併成／兩者都有）現在【一個都選不了】** —— 不是資料說話，是資料不在。

# ★★②而我差一點踩進一個【看起來像鐵證】的陷阱
```
seg1 三張輸出裡現成的兩個數字：
   `optpool 併入` 勝場 ＝ **80／134／211**
   log `[Merge]`   ＝ **7／12／13**
⇒ ★看起來就是「committed 80 次而只併成 7 次」—— 完美符合【committed ≠ 送達】的假說
★★而我去查了 `[Merge]` 的出處：`subteam_system.gd:181`／`faction_ai:1012,3344`
   ⇒ ★★★它是 **convoy porter 併回母隊** 的事件，【不是 `_resolve_join` 的完成點】
⇒ ★兩個數字【不在同一條路上】，相減沒有意義
★★而它危險的地方是：★★★它會【支持我們已經相信的假說】—— 而那正是最不該省略查證的時候
```

# ★③所以我改跑既有的專用床（★不加 tap、不改考程樹）
```
`scripts/debug/join_accept_measure_bed.gd`（★它印 `join.dispatch`／`join.resolve`／
   `join.accept_check`／`join.nohandler`）
參數：`LW_CONFIG=peaceful_economy_regime`／`ADHOC_DAYS=90`／`PERF_SEED=1337`
   ⇒ ★★與 seg1 那張【同 config、同 seed、同窗】⇒ 可比
   ⇒ ★★★但它是【另一次跑】—— 世界軌跡相同（同 code 同 seed）而我會在報數字時標明
輸出：`scratchpad/join1337.txt`
```

# ④若它回答不了，第二步我【先不做】（★照你寫的）
```
★你寫的第二步（JOIN 隊每 tick 的距離有沒有縮短）是【逐站計數 + 對帳】，不是逐筆讀 trace
⇒ ★★而它需要新 tap ⇒ 而現在段間窗口開著，加 tap 不違反凍結
⇒ ★★★但我等第一步的數字出來再決定要不要加 —— 先查禁猜
```
