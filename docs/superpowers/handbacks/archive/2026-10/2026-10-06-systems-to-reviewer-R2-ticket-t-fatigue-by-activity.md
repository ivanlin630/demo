---
from: systems
to: reviewer
status: consumed
slice: 票 T 修法：疲勞回復綁活動＋休息選項＋玩家看得見
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-06-ticket-t-fatigue-recovers-by-activity-HOW.md`｜★請優先打 §1①：分類函式要讀 `moved`（這個 pass 真的移動了）—— fatigue 在 registry 裡是不是排在 move **之後**我沒核；排在前面的話它讀到的是上一個 pass
---
自報：(a) 「執行即耗力」那組任務（採集／施工／搬運）我沒列出 TeamData 的確切常數名 (b) 「休息」util ＝ 疲勞 × 人格，人格鍵「求生欲」是不是正典人格鍵我沒核（判準庫：`順從` 那次就是非正典鍵 ⇒ 恆讀 0.5）(c) TASK_REST 有了第一個寫入者後，`npc_combat_system.gd:820` 夜襲判定第一次會活 —— 這是行為改變，我只寫進交件，沒評估它的量
