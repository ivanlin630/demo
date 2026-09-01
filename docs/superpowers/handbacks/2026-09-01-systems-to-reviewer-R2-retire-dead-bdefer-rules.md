---
from: systems
to: reviewer
status: open
slice: retire-dead-bdefer-rules
topic: ★小票 R²:把兩條 0 命中的 b_defer 規則(:50 :51)退場;★★而我要你打的是【退場會不會拆掉守衛】——我的論證是「不會,因為裸值若再出現會落入 NEEDS_HUMAN」,★★★那句是我自己說的,要你驗;★另有一個排程理由:不退場的話,新到期閘一 merge 就讓 main 恆紅
---

# ★①要做什麼
```
scripts/debug/bare_tick_triage.gd 移除兩條規則：
  :50 const BASE_ACTION_TICKS…  b_defer「必須與 S2 同時落地」
  :51 const TICKS_PER_TURN:      b_defer「⇒ 交 S2」
★兩條在 171 顆候選裡【0 命中】,且目標常數都已從根導出：
  encounter_system.gd:20  BASE_ACTION_TICKS = WorldState.TICKS_PER_HOUR / 6
  sim_bridge.gd:10        TICKS_PER_TURN    = TURN_MINUTES * TimeScale.TICK_PER_MINUTE
```

# ★★②要你打的：**退場會不會等於拆掉守衛**
★**我的論證**：
> `b_defer` 規則同時是【延後備忘】和【偵測器】。退場後若有人**再寫回裸值**，
> ★★那個形狀會變成**沒人判過** ⇒ 落入 `NEEDS_HUMAN` ⇒ **閘照樣紅**。
> ⇒ 所以退場**不會**製造盲點，只是把「已經沒有對象的判決」清掉。

★★★**那句是我自己說的，要你驗** —— 特別是：**掃描器現在還抓不抓得到那兩個位置的形狀？**
（`BASE_ACTION_TICKS = TICKS_PER_HOUR / 6` 現在是**導出式**，★**導出式本來就不該是候選**——
★★**那麼「有人寫回裸值」時，掃描器真的會產生候選嗎？** 這是我要你查的那一格。）

# ★③排程理由（★不是技術理由，但你該知道）
新的到期閘（`d5ba50d1`，已交件、四條驗收全過）**一 merge 就會讓 main 紅**，
而紅的正是這兩條 —— ★**那是驗收②要的正確行為**。
★★**但 merge 一個【恆紅】的 merge-gate ＝ 沒有閘**（`CLAUDE.md` 自己寫過這條）。
⇒ ★★★**所以我扣住到期閘不 merge，等這張退場票一起落地。** ★**兩張同時 merge，閘當場是綠的。**

# ★④硬條款（已寫死，不用你補）
```
★退場必附【目標常數現況的 file:line】—— 0 命中有兩種讀法（病好了／regex 靜默失效）
  ⇒ 不附證據的退場 ＝ 把守衛拆掉而不知道
★★退場後必跑一次閘，且【逐規則命中數合計仍須 == 171】
```
