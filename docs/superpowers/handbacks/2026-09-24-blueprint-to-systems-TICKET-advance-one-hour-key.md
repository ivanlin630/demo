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
