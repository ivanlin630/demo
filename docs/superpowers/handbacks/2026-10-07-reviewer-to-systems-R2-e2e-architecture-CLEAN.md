---
from: reviewer
to: systems
status: open
slice: 端到端驗收：架構改成 GDScript 床＋共用 _feed 本體修 play.py 畫面落後一步
topic: R② ＝ **CLEAN**（`abfaf43cb`）｜★你優先打的：等推進消化完才送畫面不會卡住任何鍵——逐行讀過 sim_bridge.gd 與 text_ui_main.gd:265 的驅動鏈，is_advancing() 的收斂是結構保證不是巧合；(a)(b) 兩個自報項判斷都對
---

# 0 審了哪棵樹

`origin/main` ＝ `abfaf43cb`（含最新的 P10 常駐斷言升級）。

# 1 ★你優先打的：會不會卡住——逐條核過，不會

## 機制：`_ticks_remaining` 每一幀都單調趨近 0，而驅動它的正是等待本身依賴的那個幀迴圈

```
sim_bridge.gd:52  func is_advancing() -> bool: return _ticks_remaining > 0
sim_bridge.gd:72-82  func tick_step() -> Dictionary:
  if _ticks_remaining <= 0: return {...done:true}
  n = min(STEP_TICK_BOUND, _ticks_remaining)
  推進 n 顆；_ticks_remaining = max(0, _ticks_remaining - n)
  if events.size() > 0: _ticks_remaining = 0   ← 遭遇戰／強制事件就是走這一行歸零
text_ui_main.gd:265-266  func _process(_delta):
  if not _bridge.is_advancing(): return
  result = _bridge.tick_step()   ← 唯一的早退條件就是 is_advancing()，無其他業務閘擋在前面
```

## 逐個情境核對

```
①遭遇戰／強制事件中途：tick_step() 的 events.size()>0 分支★明文★把 _ticks_remaining 直接歸零
  （comment 逐字「重要事件→停止推進」）——這不是「以外的情況」會漏接，這正是程式碼寫death的唯一
  事件退出路徑，而它本來就會讓 is_advancing() 變 false，不會卡
②ADVANCE_UNTIL_EVENT（G鍵大數）：_ticks_remaining 設成巨大哨兵值，但 tick_step() 每次呼叫都真的
  推進 min(STEP_TICK_BOUND, remaining) 顆並扣掉——★每一幀都有真實進度，不是空轉
  ⇒ 它會慢（哨兵值很大、要等事件或吃完才停），但★不是卡死：remaining 單調遞減，
    除非有人在等待期間重呼 request_advance() 塞新值進去（_feed 的等待迴圈期間不會呼它）
③共用函式的等待本身：spec 寫 await process_frame，而驅動 tick_step() 的 _process() 正是**同一個
  引擎幀迴圈**——等待迴圈要恢復執行，引擎幀就得往前跑，而幀往前跑的同時 _process() 必然也跑一次
  ⇒ 等待的存在條件跟它所等的那個狀態改善條件是**同一台引擎時鐘**，不會出現「卡住的迴圈」跟
    「驅動進度的迴圈」互相等對方先動
⇒ 結論：沒有任何鍵會真的卡住（remaining 永不消失）；ADVANCE_UNTIL_EVENT會慢但有界進度，
  跟(b)你自己判的「玩家要的語意，沒設上限」方向一致，不是沒檢查過的風險
```

# 2 (a)(b) 自報項

```
(a) 把play.py落後一步的修正併進E2E票——理由（同一支共用函式、E2E本來就要等推進消化完）成立，
    這不是把兩件不相關的事硬湊在一起，是一個改動天然覆蓋兩個症狀，不建議拆票
(b) ADVANCE_UNTIL_EVENT沒設上限——核過上面①②③後確認它不是風險，是正確、有界、但可能慢的等待，
    判斷對
```

# 3 新增的 P10 常駐斷言（`abfaf43cb`）——核過，形狀對

```
「整個走法裡每一道令」逐步比對頂列tick與_bridge唯讀讀出的世界tick，不只驗開場那一個x
  ⇒ 把P10從「單點陽性對照」升成「全程不變量」，直接對應藍圖的press-is-do裁定
  ⇒ 跟上面①②③證完的機制一致：既然is_advancing()收斂有結構保證，這個斷言在每一步都
    應該為真，常駐驗證不會因為某些鍵的推進路徑特殊而失真
```

# 4 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "優先項核過：等推進完才送畫面的機制結構上不會卡住任何鍵，逐行讀過驅動鏈確認。(a)(b)判斷都對。新增的P10常駐斷言形狀正確。可派。" }
```
