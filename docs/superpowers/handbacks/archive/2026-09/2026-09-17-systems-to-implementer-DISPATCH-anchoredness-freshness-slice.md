---
from: systems
to: implementer
status: consumed
slice: 錨定性讓情報保鮮（後續票，spec §6）
topic: ★**派工**：R② CLEAN（reviewer 三前提逐字核實皆真）⇒ 開後續票，spec §6 全節｜★★**修法比我原稿簡單**：**不新增 BeliefSystem 方法** —— 直接讀 `best_estimate()`（它本身不過期，`activity`/`last_tick`/`tile_pos` 在**同一個 dict**）；`appearance()` **逐字不動**（它唯一的生產消費者 `faction_ai_system.gd:934-935` 那道 `state != "fresh" ⇒ continue` 邀請門靠的正是它現在的過期行為）｜★★★**六格驗收**（6-a~6-f），其中 6-d 是「兩道門逐字未改」的 diff 格、6-f 是 default-pass 守衛
---

# 一、做什麼（一句話）

**錨定的目標，它的舊座標掉價慢；無錨的遊團，掉價快。** 零新 belief 欄位。

```gd
# decision_context.gd —— 本票 §1 已經在這裡呼叫 best_estimate 了，這節只是多讀一個 key
var bel := BeliefSystem.best_estimate(state, 觀察者, 目標)
    bel["tile_pos"]   # §1 已在用
    bel["last_tick"]  # §1 已在用（年齡）
    bel["activity"]   # ★本節新增 —— 同一次讀、同一個 tick
錨定 = (activity == BeliefSystem.ACT_SETTLED) or (belief 裡有它的據點 claim)
錨定 ⇒ freshness 慢線衰減；無錨 ⇒ 快線。★兩者都仍單調遞減、都永不歸零、沒有「不過期」這一檔。
```

# 二、★三個不准（每一條都有一格驗收盯著）

| 不准 | 為什麼 | 盯它的格 |
|---|---|---|
| ★不准改 `BeliefSystem.appearance()`（連加參數都不行） | 它唯一的生產消費者有一道 fresh-only 邀請門依賴現在的行為（reviewer 窮舉核實） | 6-c |
| ★★不准動 `BELIEF_STALE_TICKS` 那條全域線 | reviewer 窮舉 `belief_pos(` **30+ 個生產呼叫點**，橫跨攻擊/外交/加入/求助/威脅評估/movement ⇒ 動它＝**從後門鬆開攻擊門**＝本票 §2 明文擋的隔空作用 | 6-d（兩道門 diff 為空） |
| ★★★不准寫 `.get("activity", <某個錨定值>)` | 「沒看過」變成「看過它駐紮」＝ §1a 明文禁的 default-pass。**沒有 `activity` key ＝ 從未觀察到 ⇒ 走快線** | 6-f |

# 三、驗收

spec §6.4 六格（6-a 同齡兩目標分化／6-b 錨定也單調遞減且 > 0／6-c 舊 activity 也讀得到／
6-d 兩道門逐字未改／6-e **世界級**兩種行為各至少 1 例帶 tap／6-f default-pass 守衛）。

★**6-e 是世界級那格，別省** —— 我這一輪剛吃過「格綠但驗的是**函式**不是**世界**」的虧（spec §5④ 末段）。
★★**貼數時標【床的 commit】**，樹 sha 不夠。

# 四、前一票

`feat/stale-pos-recon`（§0-§5）**逐字不動**，照原樣收尾走 R² 再 merge。這一票是**後續**，不要混進去。
