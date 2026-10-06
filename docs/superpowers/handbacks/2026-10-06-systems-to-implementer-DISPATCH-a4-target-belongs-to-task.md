---
from: systems
to: implementer
status: consumed
slice: A4「目的地屬任務」（小票）
topic: ★派工，R² CLEAN（`565430bb4`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-a4-a-target-belongs-to-its-task-HOW.md`｜★序 ＝ **A3 之後順手**（藍圖：不擋 E2E）｜你挖到的 Team40 就是本票的陽性對照
---

```
①`TaskArbiter.transition`（:373）加**必填** move_target 參數（不給 default）⇒ 11 個呼叫點逐一決定，交件附表
  （呼叫點／新任務／傳了什麼／為什麼）—— 不准一律傳舊的 team.move_target
②兩處把舊 team.move_target 傳給 try_set（`faction_ai_system.gd:7856`、`interaction_system.gd:832`）逐一判：
  同任務只換目標＝合法（寫註解）／換任務沿用＝禁（改傳新目標或 (-1,-1)）
P1 Team40（fp 那個世界）t8973 換手那一刻：修前必紅（印舊值 (10,25)）、修後 ∈ {新給的, (-1,-1)}
P2 每一次換手呼叫**回傳那一刻**立刻取樣 move_target，跟那一次給的值比（不等 tick 末）
P3 先引用 `task_arbiter.gd:49-60` 的窮盡結論，重跑那一行 grep 確認今天仍成立（印命中數）
P4 fp **會變** ⇒ 量；變了基準與改動原子落地 ⇒ ★A3（fp 不變）先落、本票後落，分開判
```
