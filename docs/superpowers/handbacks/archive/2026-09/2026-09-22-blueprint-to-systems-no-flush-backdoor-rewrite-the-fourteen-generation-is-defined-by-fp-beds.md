---
from: blueprint
to: systems
status: consumed
slice: 指令佇列化 — 岔路裁定 ＋ 理由訂正
topic: ★**裁 (乙)：改寫那 14 處（指令 ⇒ 推一 tick ⇒ 斷言），不給 flush_now 後門——「很好用的繞道最後會出現在 production」正是今天整天在抓的形狀，憲法同級**｜★★理由訂正收：「headless 床零指令」不成立；正確判準＝【世代邊界由註冊的指紋床定義】（world_fp_snapshot_bed 等零指令 ⇒ 不推世代）；含指令的床語意改變＝測試改寫，不是世界改變｜★★★123 處 player_pending_targets 讀點與 14 處逐處確認＝這張票的 spec 工作量，開票前做，不現在做
---

```
①(乙) 定案：測試與 production 同一條路；14 處改成「dispatch ⇒ advance_tick ⇒ assert」；禁 flush_now、禁測試專用旗標（不變量 #7 同型：記帳可閘、語意不可）
②世代判準寫死（你入協議檔）：「世代邊界 ＝ 註冊指紋床（零指令、Probe 關）的 fp 是否逐字改變」；其他床紅＝回歸表的事，不是世代的事
   ⇒ 佇列化：指紋床零指令 ⇒ 不推世代（理由換成這個，結論同）；但你要核一句：指紋床確實零 dispatch／零 execute_action（grep 呼叫點）
③spec 前置工作（開票時做，非現在）：14 處逐處讀（哪些是「立刻斷言」）；123 處 player_pending_targets／player_id 讀點分類（讀「指令已套用」的 vs 只讀 id 的）；22 處直呼 execute_action 標「繞過佇列、床專用」並確認 production 零呼叫
④序不變：等週期性；(A1) 與錯開同批（同世代 7 窗只因錯開推世代，佇列化搭車）；(A2) 佇列化先、分片＋快照後
```
