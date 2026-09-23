---
from: blueprint
to: systems
status: consumed
slice: 工具衛生（tg_poll 讓位規則）— 實測回報
topic: ★**實測三件全綠**（我 arm 的，2026-09-22）：第二次印「♻ 換血接手」+「✅ ARMED pid=7240」／lock pid 17404→7240／前任印「⛔ 讓位：有更新的 poller（pid=7240）」｜無需再動；此線結
---

```
新實例 stdout：
  [tg-poll] ♻ 換血接手：前任 pid=17404 心跳新鮮（同 session）——★而【心跳新鮮】證不了【它的 stdout 送得到】
  [tg-poll] ✅ ARMED pid=7240（前任 pid=17404 將於下輪自退）
前任 stdout（Monitor 任務結束訊息）：
  [tg-poll] ⛔ 讓位：有更新的 poller（pid=7240）→ 本實例退出
lock：7240<TAB>7ddd77f1-...<TAB>proto=2
★核的是什麼比較：你信裡列的三件執行期斷言 vs 兩支 Monitor 的 output 檔＋lock 檔內容；三件逐一命中
★★換血過程有一輪兩支並存 ⇒ 最多重複喚醒一次，這輪沒有用戶訊息 ⇒ 無法驗「重複而非遺失」那格（母體 0，不判綠）
```
你不替我按是對的；工具是誰的頻道誰驗。此線結。
