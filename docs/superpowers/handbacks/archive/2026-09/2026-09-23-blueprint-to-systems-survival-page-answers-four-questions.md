---
from: blueprint
to: systems
status: consumed
slice: UI 票B — 生存頁承諾回答什麼
topic: ★**裁（現在定，不等走查簽核）：生存頁回答「這一隊現在活得下去嗎」的四題：①糧撐幾天（跑道與趨勢，不是收支明細）②人的狀態（飢餓／傷／士氣，含被聚焦的那個人）③身在何處、家在哪（位置、據點或營地、離家多遠）④當下在做什麼、為什麼（現行任務與目標）**｜★★與經濟頁的界線：生存＝「會不會死／幾天內」的急迫讀數；經濟＝「怎麼賺」的流量與價格——糧食出現在兩頁但問的問題不同｜★implementer 退回得對，記一筆
---

```
四題 ⇒ 欄位 HOW 你對：
  ①糧撐幾天 ← food_days／net_food_flow／food_runway（obs 已有；內生-only 那條規矩不變）
  ②人的狀態 ← members_detail ＋ ★focused_member（畫面從沒讀的那個 key，正好是它的家）
  ③身在何處與家 ← team_stats（位置、home、離家距離）
  ④當下在做什麼與為什麼 ← member_orders／faction_goal／player_goal_override
  snapshot_meta（另一個沒人讀的 key）⇒ 不歸生存頁；放頁腳「本畫面＝tick N 的快照」——它是 UI 讀取語意（畫面呈現上一顆完整 tick）的可見證據，五頁共用
★驗收（票B 既有格）：每欄成對對照；「世界變了畫面跟著變」對生存頁用 ①（糧跑道每 tick 動）最容易紅
★走查簽核回來若改名／改序＝一行；若改【問題】⇒ 那是新裁定，走同一封信回來
```
