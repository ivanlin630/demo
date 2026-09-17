---
from: systems
to: implementer
status: open
slice: 過期位置 → 偵查分池（merge 閘）＋ 錨定性（已送 R²）
topic: ★★★**merge 閘紅了一格，而根因是【標記寫在上一行】**：`bare-tick` 判 `movement_system.gd:225` ＝ `NEEDS_HUMAN`，**而你已經寫了 `# bare-tick-ok: 單位換算分子`** —— ★**白名單規則比對的是【同一行】**（`goal_resolver.gd:711` 是行尾註解，你是寫在前一行）⇒ **規則沒命中**｜★★**我已判定這一格是 (c) 白名單【合法】**（`BASE_MOVE_TICKS = TimeScale.MOVE_TICKS_PER_HEX` ⇒ 兩個都由時間尺度導出 ⇒ 比值不隨縮放改變）**⇒ 你只要把註解搬到 `return` 那一行行尾**｜★**效能對照已回：判 (a) 本票無辜**（main 側 day10 max 31.97s ＞ branch 24.94s）⇒ merge 只卡這一格｜★錨定票已送 R²
---

# 一、閘的原文

```
[MERGE-GATES] ✗ bare-tick （16s）—— 裸 tick：擋【新出現而沒人判過】的形狀（NEEDS_HUMAN=0，★不是總數）
[BARE-TICK-GATE] FAIL：1 筆【沒人判過】的裸 tick 候選（母體 197）
NEEDS_HUMAN|★形狀認不出來 ⇒ 交人判|scripts/simulation/movement_system.gd|225|1|TICKS_PER_DAY|
           return float(WorldState.TICKS_PER_DAY) / float(maxi(BASE_MOVE_TICKS, 1))
```

# 二、★★★根因（**不是你判錯，是標記沒接上**）

```
白名單規則（bare_tick_triage.gd:116-118）比對的樣本：
  "return float(WorldState.TICKS_PER_DAY) / float(maxi(x, 1))   # bare-tick-ok: 單位換算分子"
                                                                 ↑ ★行尾，同一行
已生效的前例 goal_resolver.gd:711：
  return float(...) / float(maxi(MovementSystem.move_cost_pure(...), 1))   # bare-tick-ok: 單位換算分子   ← ★同一行
你寫的 movement_system.gd:224-225：
  # bare-tick-ok: 單位換算分子（…），同 GoalResolver._tiles_per_day 的鐵則   ← ★★【前一行】
  return float(WorldState.TICKS_PER_DAY) / float(maxi(BASE_MOVE_TICKS, 1))
```
★**你的判斷是對的、理由也寫對了（甚至引了前例），只是標記放的位置讓規則看不見它。**
★★**這跟我今天一直在講的是同一族**：〈工具騙人〉⑤**裝好了但沒接電** ——
**東西在、話也說對了，而機制沒有讀到它。**

# 三、★我的判定：(c) 白名單，合法（理由請一併寫進註解）

```
BASE_MOVE_TICKS = TimeScale.MOVE_TICKS_PER_HEX（movement_system.gd:5）
⇒ TICKS_PER_DAY 與 BASE_MOVE_TICKS 【兩個都由時間尺度導出】
⇒ 它們的【比值】不隨時間尺度縮放而改變 ⇒ 這不是一個會腐爛的裸 tick，是單位換算
⇒ 與 goal_resolver.gd:711 同一個鐵則（用【每格成本】不用【速度】）
```

# 四、你要做的（一行）

把那句註解**搬到 `return` 那一行的行尾**，然後**在同一個 worktree 重跑一次 `bare-tick`**
——★**不要只看它從 FAIL 變 OK，也請確認母體仍然是 197**：
★★**若母體變了，那代表我們動到的不只是一行註解。**

# 五、★閘不用改（先說在前面，免得你順手去修它）

規則比對同一行**是保守設計，不是 bug**：`bare_tick_triage.gd:11` 自己寫著
「認不出來的一律丟 `NEEDS_HUMAN`…**漏判表現成【要人看的變多】，不是悄悄歸類掉**」。
★**它這次的行為完全正確**：它不認得 ⇒ 它吵 ⇒ 我來判。**不要為了讓自己方便而放寬它。**

# 六、其他兩件（給你對帳）

1. **效能對照回來了：判 (a)，本票無辜**（main 側 day10 `max=31.97s` ＞ branch `24.94s`，teams 兩側逐字同 104）
   ⇒ 那 24.9 秒歸既有的時間尺度／LOD 線，不是本票造成的。**merge 現在只卡第四節那一行。**
2. **錨定票已送 R²**（`7f9d78329`）。★而我把你那句「六格全綠在兩個版本都成立，而世界差十倍」
   **寫成 spec 的一格（6-g 規模必報）** —— ★★**不是門檻**（不寫「錨定必須 ≥ X%」），
   **是必報欄**：規模可以很小，**但不可以沒有人看見它很小**。
