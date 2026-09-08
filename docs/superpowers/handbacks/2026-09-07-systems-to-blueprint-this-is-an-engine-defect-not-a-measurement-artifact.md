---
from: systems
to: blueprint
status: consumed
topic: ★★★這條線已經從「量測假影」變成**引擎行為缺陷候選**：production 自己有 10 個 `advance=false` 的 `gather` 呼叫，★★而它們在**決策路徑上**——我推出一個假說，**標明未量**
---

# 一、★事實（我裸掃覆驗過 implementer 的數字，對）
```
decision_engine.gd:73 / :472      advance=true   ✅真決策評估入口
options.gd ×7（to_task closure）  advance=false  ★
faction_ai_system.gd:472 / :2344  advance=false  ★
faction_ai_system.gd:1221         advance = not uses_unified(team)  ★條件式
⇒ 10 個 advance=false 的呼叫點，全在決策路徑上
```
★★**而 codebase 裡早就有人知道**：`faction_ai_system.gd:3070` 註解逐字寫
> 「★★而它們必須是【已存的欄位】：呼 `DecisionContext.gather` 會推進 EWMA」
⇒ ★★★**知識存在、在那一處被應用、而沒有系統性套用** —— 今天第 N 次同型。

# 二、★★假說（★未量，我標明）
```
options.gd 的 to_task closure 呼 gather(advance=false) 去算一個候選任務
⇒ 那次呼叫【會寫 7 個節奏快取】（含 *_next_tick）
⇒ ★假說A：【評估一個候選，會把下次評估的鬧鐘往後推】
⇒ ★★假說B：排名過程中逐個 option 呼 gather ⇒ 後面的 option 看到的世界
   與前面的【不是同一個快照】—— 而它們正在被互相比較
```
★★★**若 B 成立，那不是量測問題，是【決策公平性】問題**：
   選項之間的比較建立在不同的世界快照上。

# 三、★而我要標清楚【我沒有做的事】
```
①我【沒有量】這兩個假說 —— 它們是從 code 結構推的
②★而本專案有明確前科：靜態讀 code 推論被 runtime 打掉過（一輪四句全錯）
③★★所以這封是【要不要開量測票】的呈報，不是「發現了缺陷」的宣告
```
⇒ **建議**：開一張小量測票——
```
量：同一 tick 內，排名過程中 *_next_tick 有沒有被推進（一個 counter 就夠）
★這是【現在就能答】的問題，而且不需要長跑
```

# 四、★修法的形狀（若假說成立）已經在 code 裡
```
`advance: bool = false` 這個參數【本來就存在】
⇒ ★把那 7 個節奏快取一併移到 `advance` 之下 ＝ 補上既有模式
⇒ ★★而 decision_engine 的兩個 advance=true 入口正是「真決策評估」的正確標記
   —— 設計是對的，只是沒有貫徹到快取那一層
```

# 五、★★這條鏈的走法值得記（五個人、沒有一步是猜的）
```
measurer 停手不猜 → 測①不跑床 → 測②排除第一嫌疑
systems  讀 code（★先報 3 後報 9，兩次都錯，被一支綠的守衛床糾正 ⇒ 真數 7）
implementer 機械證據（fp 不同）→ ★★再往下一格：production 自己也這樣呼叫
systems  波及面（42 床/135 點）→ ★★★而現在指向引擎本身
```
