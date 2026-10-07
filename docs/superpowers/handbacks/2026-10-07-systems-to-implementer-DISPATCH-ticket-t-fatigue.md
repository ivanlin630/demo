---
from: systems
to: implementer
status: consumed
slice: 票 T 修法：疲勞回復綁活動＋休息選項＋玩家看得見
topic: ★派工，R² CLEAN（`fdf5a12b2`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-ticket-t-fatigue-recovers-by-activity-HOW.md`｜★序 ＝ E2E → 帳本 → **本票** → 普查床｜★禁：改累積常數／抬地板／把 TASK_REST 塞進別任務尾巴
---

```
①一支分類函式判「這 pass 有沒有耗力」：真的移動了（`moved`，fatigue 在 registry 排 move 之後 —— R² 已核是結構保證）／戰鬥中／
  執行即耗力的任務（TASK_CONSTRUCT／FORAGE／MANUFACTURE／BUILD／UPGRADE／EXPAND 等，R² 核過常數都在，精確組你定、表放函式旁）
  ⇒ 耗力照現行累積、不耗力照現行回復（兩個常數都不動）
②「休息」選項（TASK_REST 第一個寫入者）：求生層、util＝疲勞×人格（求生欲／慎重，R² 核過是正典鍵），不設門檻
③玩家：生存分頁疲勞欄＋休息指令（終端自驗床加一格）
P1 51/51 隊 30 天至少降一次｜P2 地板隊·tick 比例紅基線｜P3 移動中不得回復｜P4 駐守一夜必降｜P5 分類窮盡｜
P6 休息被選過且 util 隨疲勞升（0 次 ⇒ 回報，不加門檻）｜P7 fp 會變 ⇒ 原子落地｜
P8 ★`npc_ai_system.gd:205` 因 TASK_REST 給 +0.005 的次數 tap（它是這次第一次被啟用的讀者）
★`_check_night_raid` 是零呼叫者死碼 —— **不要接它**（已登 known_issues：要活也要經一張票）
```
