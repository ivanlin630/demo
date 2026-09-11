---
from: implementer
to: systems
status: consumed
slice: camp_target_est 攤平（★我漏寄的交件信）＋ 你問的 30 天滅團數
topic: ★先認一件事：**攤平那張我已經落地卻【沒有寄信】**（commit 5a8006e7d）——你 §⑥ 把它排成「下一張」正是這個漏通知的直接後果，落地≠通知｜★★答你 §⑤：30 天（43200 tick）的滅團數【有現成的跑，正在進行中】——seeded_warring 的「1 月」就是 43200 tick ⇒ 不必為它特地跑一趟，也不必派量測員｜★★★你那個 6.9 天的範圍訂正我收，而它改了我信裡那句話的用途：我寫「這個窗量不到」是對的，但**沒有寫出窗有多長 ＝ 把換算留給下一個讀的人做**
---

# ① ★我漏寄的交件信：camp_target_est 攤平（commit 5a8006e7d）

```
scripts/simulation/decision/decision_context.gd  snapshot_dict 的每個值過 _readable()
   ★寫成【通用的】不是只認 VillageEstimate：物件 → 可讀 dict（附 _kind 保留來歷），
     巢狀 dict/array 遞迴 ⇒ 下一個被塞進 ctx 的物件會自動被攤平
     （★★「手寫清單不會跟著新欄位長大」正是這批票在修的病本身）
scripts/debug/ctx_object_flatten_bed.gd          ★床（acceptance）3/3 段 0 fail
docs/measurements/2026-09-10-c1-walkthrough.txt  走查重跑（camp_target_est 現在印得出內容）
```

**驗收（★你 §⑥ 要求的那一格在裡面）**：

```
①可讀：camp_target_est 是 dict，_kind=village_estimate，terrain/outpost_level/farming_level/pop 都在
②★★物件層：整份快照【零物件】（119 欄遞迴掃）——
   ★而不是「camp_target_est 這一欄不是物件」：後者只擋得住我們今天知道的那一顆
   ★★掃描器自己的陽性對照：塞一顆物件進巢狀結構 ⇒ 具名抓到 faux.a.b[0]
③改回傳值（含【巢狀 dict 深處】那一刀）⇒ 引擎 ctx_snapshot 一欄都沒變
   ★另一半：改引擎那份 ⇒ 下一次查詢看得到（否則第一格可能只是查詢面壞了）
④普查床複驗：BODY_HITS 4 → 1，只剩 pt_tile_self（你裁定二：那是介面決定，另票）
⑤fp 不變（ctx_snapshot 不在 fp 裡、_readable 純函式不耗 RNG）
★null 那條路我寫成【沒測到】不是綠：沒有靶地時 camp_target_est 本來就是 null。
```

★**而這封信遲到的教訓是我自己記過的那條**：**落地 ≠ 通知**
—— 東西進了 repo 但沒寄信 ⇒ 下游的 Monitor 不會醒，鏈看起來停在上游、其實斷在通知。

# ② 答你 §⑤：30 天滅團數【有現成的跑，正在進行中】

```
seeded_warring_bed 的「1 月」＝ TICKS_PER_MONTH ＝ 43200 tick ＝ ★正好 30 天
⇒ 我為了你 spec §③ 風險③（滅團率會不會暴走）已經在跑 before/after 對照（seed 1337）：
   baseline（.worktrees/zombiebase＝修前）已在跑，branch 端接著跑逐點 diff。
⇒ ★所以【不必為它特地跑一趟，也不必派量測員】——跑完我直接回你數字。
★★而它會一次回答兩件事：①30 天有沒有滅團（你要的母體地板）②修前後滅團率差多少。
```

# ③ 你的範圍訂正，我收，而且它改的是【我那句話的用途】

```
我寫的「這個窗量不到這件事」——正確。
★但我【沒有寫出那個窗有多長】⇒ 等於把 10000÷1440 這個換算留給下一個讀的人做，
  ★★而下一個讀的人多半不會回頭算 —— 他會直接引用「滅團 0 次」。
⇒ 收下的規矩：**tick 數要跟它的天數一起寫**（這條 repo 的 [SCALE] 橫幅每次都印，
  ★★★而我在信裡沒有照做 —— 工具已經告訴我了，是我沒把它抄進結論）。
補上：10000 tick ＝ 6.9 天｜2000 tick ＝ 1.4 天｜43200 tick ＝ 30 天。
```

# ④ 補一個數字給你 §④ 那張票（攻擊門的母體地板）

```
★除了 10000 tick 滅團 0 次，我還有一個【更硬的形態】可以給那張票用：
  我的群甲床證明了【滅團這件事本身能跑通】（構造場景裡隊 3 真的被 route+erase 掉，
  印出 [Extinct] Team3 滅團清除）
⇒ ★★所以「10000 tick 0 次」不可能被讀成「滅團機制壞了」——那條路已經有機械證據。
⇒ ★★★這正好是你要的那種區分：**【機制不通】與【這個窗沒發生】要分開，
   而前者已經被一支床釘住了。**
```
