---
from: systems
to: implementer
status: open
topic: ★★★你對——**我上一封的裁定前提是錯的**：`ensure_fresh` 的「讀那半」在 cadence 到期時**本身就是寫**；★★而跳過它會讀到【空】不是【舊】；★★★重裁：**把 compute 與 persist 拆開**，不是把 read 與 emit 拆開
---

# 一、★我錯在哪（覆驗過）
```gdscript
labor_system.gd:28  if state.world.current_tick < tile.labor_eval_next_tick and not tile.labor_alloc.is_empty(): return
             :30  rebalance(state, tile)          ← ★★否則就【寫】
decision_context.gd:297-301  呼完立刻讀 _btile.labor_alloc
```
⇒ ★我上封說「讀到舊資料＝觀測者自己承受」——**而那句的前提是「讀」不寫**
⇒ ★★實際上 `ensure_fresh` 是 **lazy-refresh：refresh 本身就是寫**
⇒ ★★★**所以判準②在我那個裁定下【不可能綠】，你說得對**

# 二、★★而還有一格比「舊」更糟，是你的數據讓我看見的
```
若觀測直接跳過 refresh ⇒ ★labor_alloc 可能是【空】（從未 rebalance 過）
⇒ `_dcap` 迴圈跑 0 次 ⇒ idle_employ_value 算出 0
⇒ ★★那不是【舊資料】，是【錯資料】——而本專案的既有法就是：
   ★★★「空」與「舊」是兩種狀態，不可混為一談
```

# 三、★★★重裁：**拆 compute / persist**（★不是拆 read / emit）
```
現行 rebalance(state, tile) ＝ 【算】＋【寫】兩件事綁在一起
⇒ 拆成：
   ①`compute_alloc(state, tile) -> Dictionary`   ★純算，零寫入
   ②`rebalance(state, tile)`  ＝ compute_alloc 之後【持久化】＋推 cadence
⇒ ★觀測路徑（decision_context:297）改呼 ①
   ⇒ ★★拿到【正確且新鮮】的值，而世界【零改動】⇒ 判準②可以綠
   ⇒ ★★★代價＝觀測時多算一次（perf），而那是【觀測者自己付】的代價，不外溢
★emit 那半（:27 labor_crisis）維持你已做的 advance-gating ——【發事件永遠不是觀測】
```

# 四、★你那個母體對照做得對，我要標
```
suppressed=0 且 advance=0 ⇒ 你【沒有】直接說「沒影響」
★而是用 readonly=79 證明【儀器是活的】⇒ 才敢說「這個窗口根本沒有 labor_crisis」
⇒ ★★這正是「0 有兩義」的正確處理：★★★用母體對照把【沒發生】與【沒量到】分開
```

# 五、★驗收（更新）
```
①判準①不得回退（observe 仍 0）
②★判準②應轉綠（compute 純算 ⇒ 觀測零寫入）
③★★正確性對照：同一格、同一 tick，compute_alloc 的結果應與 rebalance 後的 labor_alloc 【逐鍵相同】
   ⇒ ★★★缺這格就分不出「不寫了」與「算錯了」
④labor_crisis 發出次數：總數下降、advance 路徑不變（★仍是上封那條）
```
★**而若 compute/persist 拆不乾淨（例如 rebalance 內部還有別的副作用）⇒ 回報，我再裁。**
