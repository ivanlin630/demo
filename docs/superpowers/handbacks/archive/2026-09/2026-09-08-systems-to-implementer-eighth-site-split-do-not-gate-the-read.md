---
from: systems
to: implementer
status: consumed
topic: ★第 8 處我裁**拆開，不要整支 gate**：★★`emit` 那半移到 `advance` 之下、**讀那半留著**；★★★理由是「讀到舊資料」與「叫醒別人」是**兩種完全不同的代價**
---

# 一、★我覆驗過你的發現（行號）
```gdscript
labor_system.gd:19  static func ensure_fresh(state, tile)
  :27   WorldEvents.emit(state, "labor_crisis", [_tid])   ★_tid ＝【那格上的別支隊】
  :28   if state.world.current_tick < tile.labor_eval_next_tick ...   ★cadence
呼叫點：decision_context.gd:297（★在觀測路徑上）
```
⇒ ★★**觀測 A 隊的 context，會替 B 隊發出 `labor_crisis` 事件**
⇒ ★★★那不是「改我自己的快取」，是**叫醒第三方** —— 所以你說「性質不同」是對的。

# 二、★★★裁決：**拆開**（★不要整支 advance-gate）
```
①emit 那半  ⇒ ★移到 advance 之下 —— 【發事件永遠不是觀測】
②讀那半    ⇒ ★★留著（含必要的 refresh）
③cadence 寫（:28 那條 labor_eval_next_tick）⇒ ★移到 advance 之下（與前七處同理）
```
★**為什麼不整支 gate**：
```
整支 gate ⇒ 觀測讀到【過期的 labor_alloc】⇒ ★觀測模式下的決策會【算錯】
⇒ 而那是把「觀測污染世界」換成「觀測看到假世界」——★★兩個都是病
⇒ ★★★正確的切法是照【代價】切：
   讀到舊資料 = 觀測者自己承受，且可標明
   叫醒別人   = ★成本外溢到第三方，而它【永遠】不該由觀測觸發
```

# 三、★驗收（★仍然成對）
```
①判準②（你現在紅的那格）⇒ 應轉綠
②★而判準①【不得回退】—— observe 仍要是 0
③★★新增一格：`labor_crisis` 事件的發出次數，修前 vs 修後
   ⇒ ★★★若修後【變成 0】⇒ 那不是修好，是【把功能關掉】——因為真決策路徑也該發得出來
   ⇒ 期望：總次數下降，而 advance 路徑上的次數【不變】
```

# 四、★而我要標一件我沒查的
```
`ensure_fresh` 的 refresh 若在觀測時被跳過，★觀測讀到的 labor_alloc 會有多舊？
⇒ ★★我沒量 —— 而它決定「讀那半留著」是不是也需要一條誠實限
⇒ ★★★若你在做的時候發現它可能很舊（例如 cadence 很長）⇒ 回報，我補 spec
```

# 五、★順帶：code 裡早就有人標過這一格
```
decision_context.gd:231 註解：「②:233 LaborSystem.ensure_fresh → rebalance 寫 tile.labor_alloc ＋ labor_eval_n…」
manufacturing_system.gd:163：「★★★誠實限：labor_share / ensure_fresh 每次【呼叫】算一次…」
⇒ ★★知識在，而且在兩個地方 —— ★★★缺的一直是【把它變成會擋人的東西】
```
