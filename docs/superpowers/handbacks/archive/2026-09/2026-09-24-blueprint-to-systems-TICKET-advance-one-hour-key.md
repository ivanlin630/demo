---
from: blueprint
to: systems
status: consumed
slice: 玩家實跑回饋 #6（用戶 2026-09-24：問「排入待辦後啥時做」→ 我報最小推進是一天太粗 → 用戶裁「1小時吧」）
topic: ★小票：TextUI 加「推進一小時」鍵（TICKS_PER_HOUR=60 tick），跟空白鍵（一天）並列；鍵位 HOW 定但要印在頁腳 keymap；純 UI 呼叫既有 request_advance(60)，零 sim 改動、fp 不變｜★★併入游標真值那張一起做（同檔 text_ui_main.gd、同床 player_entry_smoke）
---

# 一、現況

```
text_ui_main.gd:352-353  KEY_SPACE → request_advance(TICKS_PER_DAY)   ← 唯一的手動推進，1440 tick
指令在下一次推進的第一顆 tick 開頭被消費（sim_runner.gd:567）⇒ 想看一道令成不成要跑掉一整天
```

# 二、裁

```
①新鍵：推進【一小時】＝ `WorldState.TICKS_PER_HOUR`。★用戶追加（逐字）：「記得統一單位 不要寫死60tick」⇒ code 與 keymap 字串都只准引用常數／時間單位（「1 小時」），任何地方出現字面 60 ＝ 不過（TICKS_PER_HOUR 是唯一自由參數，改它全世界要跟著動，見 world_state.gd:12）。鍵位你定（避開已占用：WASD/Enter/Space/T/G/R/M/./,/數字），並印進 _mode_keymap 的頁腳提示（「沒看到」與「沒有這個功能」在畫面上長得一樣）。
②語意同空白鍵：同一條 request_advance 路徑，Esc 可中斷；不另造推進路徑。
③不改 sim、不改 fp。
```

# 三、驗收（併入 player_entry_smoke）

```
排一道令 → 按該鍵 → 一小時後停：結果句出現、頁腳待執行歸 0、current_tick 恰 +TICKS_PER_HOUR（斷言讀常數，不寫 60）。
★靜態格：grep 該 diff 不得出現字面 `60`（含註解裡當數值用的）。
頁腳 keymap 字串含該鍵（機械 grep）。
```

# 四、追加（用戶 2026-09-24：「我跟他團在同格 我選招募匿名 待辦為何是3還4件事?」）

```
真因（file:line）：按 T 進互動模式時 text_ui_main.gd:395 呼叫 sim_bridge.refresh_interaction_targets()，
而 sim_bridge.gd:322-323 把它做成 command_player("refresh_targets") ⇒ ★每按一次 T 就多一道待執行。
招募流程本身只入列一道（recruit_anon，:2224-2228）；開招募選單是查詢不入列（:1268）。
⇒ 用戶看到 3–4 ＝ 幾次 T 的「掃描同格對象」＋一道招募（＋可能更早沒推進就留著的令）。
```

裁（併本票）：
```
①頁腳「待執行 N 道」後面列動作人話，最多 3 個，超過印「…」：「待執行 2 道：掃描同格對象、招募匿名」
  ⇒ 玩家看得出哪幾道是自己下的、哪一道是系統代他排的。動作人話用入列回音同一份字串，不另造。
②refresh_targets 入列本身不改（它寫 state，照「掃描入佇列」那一行）；但★同一批裡重複的 refresh_targets 只留一道
  （冪等指令重複入列＝噪音；HOW：入列時若佇列尾端已有同名無參數 refresh_targets 就不再加，這是「不讀世界」的檢查，可當場做）。
```

驗收追加：
```
連按 T 三次 ⇒ 待執行 1 道（不是 3）；再按 A 招募 ⇒ 2 道且頁腳列出兩個名字；推進一小時 ⇒ 0。
```
