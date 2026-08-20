---
from: systems
to: implementer
status: consumed
topic: "[dispatch 訂單簿健康度 tap(純觀測、不急、★但禁在大考跑完前跑任何長 run:第二個 Godot 進程的 CPU contention 會污染大考正在量的 per-tick 時間)·來源:用戶追問訂單噪音、blueprint 立為大考經濟具名 metric;現況=12mo 大考已在跑且【床沒抓 trade./訂單類 probe、結尾也不 dump 全量 Probe.counts】→世界級數字這輪救不回、只能 specimen 層近似重建→tap 現在加、供【大考後的專用短窗(2-3 個月足夠)】·★T1 order 身分與壽命:active_orders 每筆加 order_id(全域遞增、存 WorldState 持久 counter 非 static var——static 跨 new() 會有 id 碰撞前科,見 known_issues beast id)+created_tick;既有讀 orders 的地方不受影響(只加欄)·★T2 生命週期 probe:order.placed / order.filled(qty 歸零完成)/ order.abandoned(逾時或主動撤)/ order.replaced(同 team 同 kind 同 res 在舊單未清時再掛=重掛 churn 的硬證據,取代現在靠 qty_rem 不減反增的推測)——每筆帶 order_id 便於事後串·★T3 床的過濾器補洞:exam_12mo_bed.gd 的 watch_prefixes 加 'trade.' 與 'order.'(現= [death./site_memory./need./diplo/alliance/betray/faction.]、訂單全漏);★另加『結尾 dump 全量 Probe.counts 到 JSONL 最後一行』——這輪的教訓:過濾器沒列到的 family 事後完全救不回,全量 dump 一行的成本近零卻保住所有未預見的問題·★T4 specimen orders 摘要加 order_id+created_tick(QA 讀故事時能直接看出『這是同一張單卡了 8 天』vs『重掛了 5 次』,現在他要用 qty_rem 跳動反推)·gate:純觀測 fp byte-identical+det×3+constitution<=75+headless 0-new+短窗 smoke 看 4 個 probe 都有值·worktree feat/orderbook-tap·完→handback to:systems(我排在大考之後跑)·地基KEEP"
---

# dispatch：訂單簿健康度 tap（純觀測、不急）

★**禁在大考跑完前跑任何長 run**：第二個 Godot 進程的 CPU contention 會**污染大考正在量的 per-tick 時間**（那正是 perf③ k 值測不準的元凶）。

**來源**：用戶追問訂單噪音 → blueprint 立為大考經濟具名 metric。**現況**：12mo 大考已在跑，而**床沒抓 `trade.`/訂單類 probe、結尾也不 dump 全量 `Probe.counts`** → 世界級數字**這輪救不回**、只能 specimen 層近似重建 → **tap 現在加，供大考後的專用短窗（2–3 個月足夠）**。

- **★T1 order 身分與壽命**：`active_orders` 每筆加 **`order_id`**（全域遞增、**存 `WorldState` 持久 counter**——**不要用 `static var`**，跨 `new()` 有 id 碰撞前科，見 known_issues 的 beast id 條）+ **`created_tick`**。既有讀 `orders` 的地方不受影響（只加欄）。
- **★T2 生命週期 probe**：`order.placed` ／ `order.filled`（qty 歸零完成）／ `order.abandoned`（逾時或主動撤）／ **`order.replaced`**（同 team 同 kind 同 res 在**舊單未清時**再掛＝**重掛 churn 的硬證據**，取代現在靠 `qty_rem` 不減反增的推測）——每筆帶 `order_id` 便於事後串。
- **★T3 床的過濾器補洞**：`exam_12mo_bed.gd` 的 `watch_prefixes` 加 `"trade."` 與 `"order."`（現＝`[death./site_memory./need./diplo/alliance/betray/faction.]`、**訂單全漏**）；★**另加「結尾 dump 全量 `Probe.counts` 到 JSONL 最後一行」**——**這輪的教訓：過濾器沒列到的 family 事後完全救不回**，而全量 dump 一行的成本近零、卻保住所有未預見的問題。
- **★T4** specimen `orders` 摘要加 `order_id` + `created_tick`（QA 讀故事時能直接看出「**這是同一張單卡了 8 天**」vs「**重掛了 5 次**」，現在他得用 `qty_rem` 跳動反推）。

**gate**：純觀測 **fp byte-identical** + det×3 + constitution ≤75 + headless 0-new + 短窗 smoke 看四個 probe 都有值。
worktree `feat/orderbook-tap`。完 → handback to:systems（**我排在大考之後跑**）。地基 KEEP。
