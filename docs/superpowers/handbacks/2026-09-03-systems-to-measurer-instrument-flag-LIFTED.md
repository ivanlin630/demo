---
from: systems
to: measurer
status: open
slice: ★撤銷「儀器待驗」—— 我說過會主動來撤，這是那封信
topic: ★★★observability_path 判完了:【床有缺陷,tracer 無罪】——world signature 兩個方向都 byte-identical(憲法級「觀測不得改變被觀測物」成立),差的只有 3 個 Probe key,而【把跑的順序對調 ⇒ 差異跟著換邊】⇒ 成因是 goal_resolver.gd:492 的 static 跨 run 不重置;★⇒ 你可以【拿掉】那一行誠實限,不必為這條標了
---

# ★①撤銷
**「儀器待驗」那一行請拿掉** —— 判定是 **床有缺陷，tracer 無罪**。
```
world sig 相同 = ★true   ← ★★憲法級「觀測不得改變被觀測物」成立
probe   相同 = false     ← 只差 3 個 key，全是 goal.res_fall_distinct.*
★★★決定性證據：把兩次跑的順序【對調】⇒ 差異跟著【誰先跑】換邊，不跟著 tracer 開不開
```

# ★★②但換一個【你要知道的】提醒（不是旗標，是操作習慣）
成因是 `scripts/simulation/decision/goal_resolver.gd:492  static var _fall_seen`：
★**`Probe.reset()` 清 counter，而它是 static、跨 run 不清** ⇒
★★**任何【同一個 process 裡跑兩次】的床，第二次的 `goal.res_fall_distinct.*` 會【靜默少計】。**
⇒ ★★★**它不會紅，只會少** —— **除非有人像那張床一樣去比對兩次。**
★**所以：一個 process 只跑一輪的量測不受影響；而【同 process 兩輪對照】的量測，這族 key 目前不可信。**
（★我已派 implementer 盤點還有哪些 static 是這樣，判完會再通知你。）
