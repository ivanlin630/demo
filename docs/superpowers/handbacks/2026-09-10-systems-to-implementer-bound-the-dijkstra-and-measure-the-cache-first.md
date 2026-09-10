---
from: systems
to: implementer
status: open
slice: bounded-dijkstra-prey-scan ｜ worktree `.worktrees/dijkbound` ｜ branch `feat/bounded-dijkstra-prey-scan`
topic: ★DISPATCH（R² CLEAN）：把 `_dijkstra` 收邊 —— ★★而**驗收①是【先量再改】：先量 `_sssp_cache` 的命中率，若命中率其實很高 ⇒ 本票前提就錯了，停下來回報，不要硬改**｜★★★上界是【算出來的】不是猜的（1200×1.0÷240＝5.0），但**三個數字都不准寫成字面值**
---

# ⓪ 先讀 spec

`docs/superpowers/specs/2026-09-10-bounded-dijkstra-for-prey-scan-HOW.md`
（★★§⑥ 是 R² 回件，它把我原本標「未驗」的兩格變成確定答案 —— **§⑥ 優先於 §①**。）

# ① 為什麼做這張（★序的來歷，一句）

```
★blueprint 裁 (c) 先行：把每次喚醒【變便宜】(33-50 ms／隊 → 1 ms 級)
  ⇒ 17 隊喚醒風暴 ＝ 17 ms ⇒ **「可慢不可卡」與「T0 瞬醒」的相撞【自動消失】**
  ——★★而它不用在兩條憲法之間選邊（K-cap 被拒的理由：**排程器不得決定誰先活**）。
```

# ② ★★★做之前先做驗收①（**它有權停掉整張票**）

```
量現況 `_sssp_cache` 的命中／未命中次數（★大世界 N ≥ 130）：
  ①全域命中率
  ②★★拆兩組分別報：【移動中的隊】vs【駐守/待命的隊】
     （R²：cache key 只認位置不認隊 ⇒ 別的隊從同一格查過也會命中
      ⇒ 一個混合平均會把「假設在哪一半成立」蓋掉）
⇒ ★★★**若命中率其實很高 ⇒ 本票的前提錯 ⇒ 停下來寫信回報，不要硬改。**
  （這不是形式：整張票的論點就是「快取看起來在運作、實際命中≒0」。）
```

# ③ 修法（語意不變是地基）

```
`_dijkstra(state, from, cost_limit)` 多一個上界，成本超過就不再 push；
`catch_cost(state, from, to, cost_limit)` 的快取 key **要包含 cost_limit**。
★正確性論證：`estimate_catch_up:258` 把 `eta > AI_ETA_LIMIT` 的**通通丟掉**，
  而 Dijkstra 由近而遠展開 ⇒ 超過上界的那些**本來就會被丟** ⇒ **結果逐次相同**。
```

★★**上界怎麼算（三個數字，一個都不准寫成字面值）**：

```
cost_bound = AI_ETA_LIMIT × MAX_SPEED_MULT ÷ BASE_MOVE_TICKS   (= 1200 × 1.0 ÷ 240 = 5.0)
①`AI_ETA_LIMIT`  —— path_system.gd:15，具名，直接讀。
②`MAX_SPEED_MULT` —— ★**新增一個常數，放在 `_team_speed_mult`（:183）旁邊**。
   值 1.0，理由寫在它旁邊：那支函式現在只有疲勞懲罰（clamp 上界 1.0），
   ★而它檔頭標著「Hook 預留 speed_class（未實作）」⇒ **將來接上坐騎/載具時上界會變**，
   ★★屆時 `cost_bound` 會**悄悄變太緊** —— 語意壞掉而**沒有任何報錯**。
   ⇒ 兩處放在一起，改那支函式的人一定看得到這個常數在講什麼。
③★★★`BASE_MOVE_TICKS` —— **它不是 240**：`movement_system.gd:5` 是
   `TimeScale.MOVE_TICKS_PER_HEX`（時間統一 wave 改過它一次，×5→1）。
   ⇒ **絕不可以把 cost_bound 寫成字面 `5.0`** —— 必須執行期由這三個具名量算出來。
⇒ ★這是【同一個 drift 形狀的兩個來源】：只修 ② 不修 ③，
  下一次動 TimeScale 的人會把語意改壞而所有閘全綠。
```

★**兩件讓本票更便宜的事實（我查過 caller 圖）**：

```
①`catch_cost` **全庫只有一個 caller**（`estimate_catch_up:246`）
  ⇒ 實務上只有一個 cost_limit 值 ⇒ key 多一維**不會讓記憶體翻倍**
  ⇒ ★上界可以**無條件套用**，不必做成 opt-in 兩條路徑。
②`clear_sssp()` 已存在（:36）且已被接上（:50）⇒ key 多一維不影響它。
```

# ④ 驗收（★spec §② 是本體，這裡只點三個最容易做錯的）

```
②★**語意不變＝逐次比對**，不是抽樣：`estimate_catch_up` 的
  `reachable`／`eta`／`reason` 改前改後**每一次呼叫都相同**。
④★★成本要報【絕對 us／隊】（改前 33-50 ms ⇒ 目標 1 ms 級），
  ★★★**在 N ≥ 130 的世界量**，並同時報 tick 數／遊戲天／規模三軸。
⑥★成對對照：把 `cost_limit` 拿掉（回到全圖）⇒ ④必須**回到 33-50 ms**。
  沒有這格，④的綠證明不了是收邊造成的。
③fp 不變 ⇒ ★依界限第十八條，**附一格行為證據**（fp 單腿聲明禁止）。
```

# ⑤ 不做

```
①不改 `AI_ETA_LIMIT` 的值（＝改決策語意）
②不做距離預篩（＝改「誰進得了候選」＝決策層語意，要 blueprint 裁）
③不動 `find_prosperity_prey` 的任何一個 `continue`
④不碰 belief-gate（`estimate_catch_up:237-245` 那段是感知鐵律的東西）
```
