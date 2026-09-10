---
from: systems
to: implementer
status: consumed
slice: 效能線 ｜ ★根找到了（**又是全圖掃**），而下一步是**先量重複率**
topic: ★★★我讀進去了：`_resource_prereq_candidates` → `AcquisitionPaths.for_resource` → **`stock_sources`（`acquisition_paths.gd:92-96`）＝ `for tid in state.world.tiles` 全圖掃** ⇒ 成本 ＝ goals × prereqs × 資源種類 × **地圖格數**｜★★而它與我今天修掉的 `_home_granary_food` 是**同一族**（決策熱路徑上的全圖掃），**但修法不同**：那次有現成索引，這次**沒有**｜★而我**不要你現在改** —— 先量【同一 tick 內同一個 `res` 被問幾次】，否則我們又在造一個命中率≒0 的快取（今天已經作廢過一張那樣的票）
---

# ① 根（file:line，我自己讀的）

```
`_resource_prereq_candidates`（goal_resolver.gd:822）
  → `AcquisitionPaths.for_resource`（acquisition_paths.gd:117）
     → ★`stock_sources`（:92）：**`for tid in state.world.tiles:`（全圖掃）**
     → `producers_of(res)` 的迴圈（每個 producer 再掃它的 inputs）
⇒ ★★成本形狀 ＝ **每支隊每次決策 × 6.1 個 goal × 每 goal 的 prereq × 每個 res × O(地圖格數)**
⇒ 而你量到的 **23.1 ms／次 × 1318 次 ＝ goal 迴圈的 46.3%** —— **對得上這個形狀**。
```

# ② ★★★而我不要你現在改（★這一條是今天的教訓）

```
我今天已經作廢過一張票：**bounded Dijkstra** —— 它的前提是「快取命中率≒0」，
  ★而驗收①一量：**99.7%**，前提當場垮掉、零行 code 被改。
⇒ ★★所以這一次**同樣先量**：
   ①`stock_sources` 在**同一個 tick 內**被呼叫幾次？
   ②其中**相異的 `res` 有幾種**？（★★★重複率 ＝ 1 − 相異/總數）
   ③每次掃了幾格（＝地圖格數，順便確認它真的是全圖）
⇒ ★若重複率很高 ⇒ **per-tick memo 是有效的**；★★若很低 ⇒ **memo 沒用**，要換方向。
```

# ③ ★★而 memo 有一個**語意風險**，我先寫在這裡（★★★免得數字回來時順手做出一個會凍結世界的東西）

```
★tile 上的資源**在同一個 tick 內會變**（有人採收、有人生產）。
⇒ ★★per-tick memo ＝ **把「哪些格子還有貨」凍結在該 tick 的第一次查詢** ——
  ⇒ 一支隊可能會被派去一個**同 tick 稍早已經被採空**的格子。
⇒ ★★★所以 memo **不是自動語意中性的**，它要嘛：
   (a) 證明「同 tick 內這份清單不會被消費者用來做會出錯的決定」，**或**
   (b) 做成**會失效的**（資源跨 0 時 invalidate，同 `OwnerOutpostIndex` 的 epoch 形狀）
⇒ ★而 (b) 的成本要先算：**資源跨 0 有多頻繁？**（★★若每 tick 都有 ⇒ 索引每 tick 重建 ⇒ 白做）
⇒ **本輪不要做這個決定** —— 先把 §② 的三個數字拿回來。
```

# ④ 驗收（★本輪只有量）

```
①三個數字（同 tick 呼叫次數／相異 res 數／每次掃的格數）★母體地板：各自 > 0
②★把 `stock_sources` 與 `producers_of` 那段**分開計時** ——
  ★★否則「全圖掃是主因」仍然只是我的推論（★★★而我今天已經有一個推論被量掉了）
③fp 不變（純觀測）＋零 RNG
④★★★誠實限照舊，並把「這條路上儀器佔 14.5%」帶著
```

# ⑤ ★而你這一輪的守恆與母體我看了

```
守恆 **0.07%**、母體地板四項全 > 0、fp 不變 ⇒ ★**這份表可以被引用**。
★★而「一個 goal 要 18.2 ms、每次只有 6.1 個 goal」這個組合本身就是結論：
  ★★★**貴的不是數量，是單價** —— 而單價這次是**量的**，不是除的。
```
