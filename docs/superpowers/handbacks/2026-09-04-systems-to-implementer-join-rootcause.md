---
from: systems
to: implementer
status: open
slice: 「併入 committed 卻沒併成」根因（★用戶「先修吧」⇒ warring HOLD）
tier: probe
topic: ★我先看了路徑,所以票問得比「查一下」準:真正併成的地方在 `interaction_system`,而它【需要兩隊相遇】(a/b 配對)+`social_target` 對得上;★★所以這可能不是「committed 沒發生」,是【committed ≠ 送達】——committed 只代表 TaskArbiter 收下意圖;★★★而第一步【零新跑】:既有 tap `join.dispatch`(interaction_system:240-241)就在,先讀 seg1 輸出裡它是多少
---

# ①我先查過的路徑（★所以下面問的是【逐站】不是「查一下」）
```
①★意圖:faction_ai:3540 `TaskArbiter.try_set(state, team, TASK_JOIN, join_pos, ...)` ⇒ 成功 = result committed
②★★到達:併成的真正地點在 `interaction_system` —— 而它是【a／b 配對】= 兩隊要【相遇】
③★★★命中:`_resolve_join` 要求 `a.current_task == TASK_JOIN and a.social_target == id_b`
   ⇒ 相遇了還要【對象對得上】
④併成:`_resolve_join` 內部(複用 merge_teams full absorb,pop 守恆)
```
⇒ ★**所以假說是【committed ≠ 送達】**：**committed 只代表 TaskArbiter 收下意圖，不代表走到、遇到、對上。**
★★**而這正好是既有那條**：**活著 ≠ 前進 ≠ 送達 —— 這次多一站：【committed ≠ 送達】。**

# ★★★②第一步【零新跑】：既有 tap 就在
```
★interaction_system:240-241 已有 `join.dispatch`（＝到達核心互動的 JOIN 隊）
⇒ ★★先讀 seg1 三張的輸出:`join.*` 那組是多少?
   ①join.dispatch ＝ 0 ⇒ ★★★【從沒走到相遇】⇒ 病在【移動/距離/宿主移動】,不在 resolver
   ②join.dispatch > 0 而沒併成 ⇒ ★病在【social_target 對不上】或 resolver 內部
   ③兩者都有 ⇒ 照原樣報,分開計
★而 seg1 的 specimen 裡 team13 反覆 committed 10+ 次 ⇒ ★★母體現成,不必重跑
```

# ③若①指向「從沒相遇」，第二步（★到時候再做，先別做）
```
★逐站條件名:JOIN 隊每 tick 的【位置 vs 目標位置距離】有沒有在縮短?
   ⇒ ★★而 team13 是 pop=1 的餓死邊緣隊 —— ★★★它可能【根本走不動】(移動有沒有體力/糧食門檻?)
⇒ 而這一步要【逐站計數 + 對帳】,不是逐筆讀 trace
```

# ④紀律（★照舊，我只重申兩條最容易在急著修時掉的）
```
①★先查禁猜:①那一格是【讀既有輸出】,不是加 tap
②★★而若要加 tap:非空出口也要在母體裡,Σ各站 == entry,不平就宣告不可用
★★★而 warring HOLD ⇒ 現在【不要】為了趕 warring 而跳過①直接改 code
```
