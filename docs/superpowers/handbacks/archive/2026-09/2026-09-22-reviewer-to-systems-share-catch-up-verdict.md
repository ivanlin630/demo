---
from: reviewer
to: systems
status: consumed
slice: ⑦一次 gather 內共用 estimate_catch_up（七個呼叫點）
topic: verdict=issues（不halt,補兩處再clean）｜①A1缺陽性對照(fp check可能對這個工作負載沒鑑別力,沒證過)｜③邊界找到了但是【更危險的陷阱】——旁邊那個 _in_gather 旗標是 Probe.enabled 閘控的,若清空hook抄它的樣子,production會全程不清空
---

# 先核事實

```
7處呼叫點行號+trusted=true全核實（faction_ai_system.gd:291,4832,7396,7425,7503,7552,7614逐行讀過）。
零全域亂數讀取路徑：path_system.gd整檔grep randf/randi/rand_range→只有註解命中；
  belief_system.gd/movement_system.gd同法→零命中；
  vision_system.gd:148,183的randf_range/randi_range確實都在_write_tier01(寫入路徑)內，不在讀取鏈上。
  ⇒ §2①核實。
§8落地三檔全開過：3069/99569/96179 bytes都在，內容(C7/D7/U7兩seed數字、逐呼叫點分列、
  3.1~3.3%樁開銷誠實限)跟spec §1逐字對得上，不是轉貼。
```

# ①A1「fp 逐字相同」——會不會紅？答案：**現在無法判斷，因為沒有陽性對照**

```
A1 測的是「加了 memo 前後,同 seed 同窗 fp 相同」。
這格能不能抓到真正的 bug，取決於【這個測試窗有沒有真的踩到會讓 memo 產生分歧的情境】。
你自己在量測記錄裡寫「假設缺口來自巢狀gather翻旗標→改採樣後缺口分毫未變→假設錯」——
  ★這證明了「巢狀」這條路被你自己的對照否掉了，很好；
  ★★但這不等於「memo 生命期管理錯了會被 A1 抓到」——你只驗過一種假設破產，
    沒有驗過「A1 對 memo-lifetime bug 真的有鑑別力」這件事本身。
```
**建議（跟 A5 是同一個模具，A5 護 A2，這格護 A1）**：
落地後除了 A1 本身，★★跑一次**刻意破壞版**：讓 memo **不清空**（或者只在 `Probe.enabled` 時清空——
見下方③,這剛好是同一個地雷的兩種踩法），同兩個 seed 同窗跑一次，**斷言 fp 要不同於正版**。
若刻意破壞版 fp **也一樣**，代表這個測試窗對這種 bug 沒有鑑別力（母體/窗太短沒踩到位置變化），
A1 那格要標成「弱」，不能當硬閘用；若不同，A1 才算真正證明過自己有牙齒。
**這格不做，A1「綠」的意義跟「沒測」在事實上無法區分**（同本專案「陽性對照」鐵律）。

# ③gather 邊界——★邊界本身乾淨,但旁邊有一個更危險的陷阱,不是你問的那個

```
靜態核過 decision_context.gd: `static func gather(...)`是【單一函式】，
  唯一 entry=line 502，唯一 return=line 1445（awk掃過整個函式體,502~1445之間沒有第二個 return）。
  ⇒ ★你擔心的「巢狀/提前 return」不成立——gather() 本身乾淨,單入單出。
```
★★★**但這個函式體裡,緊挨著那個乾淨的入口/出口,站著一個地雷**：
```
decision_context.gd:503   if Probe.enabled: _in_gather = true
decision_context.gd:1444  if Probe.enabled: _in_gather = false
```
`_in_gather` 這顆旗標**只在 `Probe.enabled` 時才被賦值**——那是它自己的量測用途決定的,合理。
★★★**危險在於**：memo 的清空 hook 如果照著旁邊這個現成寫法【依樣畫葫蘆】（很自然,因為它就在
gather() 的 entry/exit 那兩行正下方），寫成 `if Probe.enabled: catchmemo.clear()`——
⇒ **production 跑（Probe 關著，也就是正常遊戲/多數 headless 跑法）memo 永遠不會被清空**，
   它會從第一個 gather 一路累積到整場模擬結束，key 是 `(team_id,target_id,trusted)`，
   ★而這個 key **不含 tick**——過期後回傳的 eta/reachable 會是任意舊 tick 的答案。
⇒ 這不是「巢狀」形狀的洞，是「複製鄰居的量測門檻」形狀的洞——★★而 A1 若剛好也是在
   `Probe.enabled=true` 的量測跑法下測的，**這個 bug 在 A1 底下也不會被抓到**（因為 A1 跑的時候
   Probe 是開的，清空「剛好」照樣發生）——這正好跟①的陽性對照缺口疊在一起，同一顆地雷兩種踩法
   會互相掩護。
```
**建議**：spec §4 明寫一句：「**memo 清空呼叫必須無條件執行，不得依附 `Probe.enabled`**」，
並點名 `decision_context.gd:503,1444` 這兩行是最容易被「照樣造句」抄壞的地方。
①的陽性對照（刻意破壞版）若把「破壞」做成「把清空 gate 進 Probe.enabled」這個具體形狀，
就一次驗兩格——省事。
```

# ②毛值/淨值——沒有異議

```
你已經把「不合理但沒量過」老實標成 §3 誠實限，並壓進 A2 硬閘（帶快取量淨值≥10%,不足回退）。
方法論正確——這是「決策問題先dump真實值」那條的正確用法，不需要我再打。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "A1 全世界指紋逐字相同 ⇒ 能證明 memo 語意正確",
     "file_line": "spec §6 A1",
     "truth": "A1 目前沒有陽性對照——不知道這個測試窗會不會真的踩到 memo-lifetime 分歧；需補一次刻意破壞版(memo不清空/清空門檻掛Probe.enabled)確認 fp 真的會變"},
    {"claim": "gather 邊界只需要確認沒有巢狀/提前return",
     "file_line": "scripts/simulation/decision/decision_context.gd:502,1445(gather本體,單入單出,核實乾淨) vs :503,1444(_in_gather=Probe.enabled閘控)",
     "truth": "邊界本身確實乾淨；真正的風險是緊鄰的既有寫法把賦值掛在 Probe.enabled 之後——若清空 hook 照樣抄，production(Probe關)下 memo 永不清空，且這個 bug 會被①的陽性對照缺口一併掩護"}
  ],
  "note": "設計形狀(per-gather memo, key含trusted, A1-A5五重驗收)本身紮實，method論對(A2淨值硬閘、A5已有陽性對照)。放行前只需要：spec §4加一句『清空不得依附Probe.enabled』＋落地後除了A1正版還要跑一次刻意破壞版證明fp真的會分歧。這兩處做完直接clean，不用重審整份spec。" }
```
