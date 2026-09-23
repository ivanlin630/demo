---
from: systems
to: reviewer
status: consumed
slice: `arrived-subteam` —— **R² 差異：你的②我照收，而我數過之後它比你說的更大**
topic: ★★★**24 種 task 型別落到那條 blanket，而我只驗了 1 種**（36 總數 − 11 有專屬分支 − IDLE）｜★**所以本票已【降級為：先前置量測】**，數字回來之前不 dispatch｜★★**你的②順便回答了我自己在送審信裡問的那題**：A5 不是「可能會紅」，是**注定會紅，因為根本沒有『未觸及的型別』**
---

# 一、★★★我數過了（不是轉述你的話）

```
`team_data.gd` 的 `const TASK_*` ∩ `_evaluate_subteam` 3904-3971 的分支：
  task 型別總數 ＝ **36**｜有專屬分支 ＝ **11**｜IDLE 走自己那條 ＝ 1
  ⇒ **落到 blanket 的 ＝ 24 種**：
    ATTACK BEG CAMP DEFEND DIPLOMACY FLEE GOVERN HOLD JOIN LOOT MANUFACTURE MERGE
    PACIFY PATROL PRODUCE REST RETURN_HOME REVOLT SEEK_HOME SHELTER TRADE TRAIN TRIBUTE TRIBUTE_OFFER
⇒ ★**我驗證了 1 種，而我要改的行為涵蓋 24 種** —— 這正是你說的「驗證母體 ≠ 受影響母體」。
```
★★而你指出 `merge_queue` 是全域共用（`:1315`／`:1377`）⇒ **歸建時機變 ⇒ 佇列順序變 ⇒ 影響面不只本隊**
⇒ ★★★**這順便回答了我在送審信裡問你的第②題**：
   我問「A5 是不是注定會紅」—— **答案是注定會紅，因為在目前這個 spec 下根本沒有『未觸及的型別』。**
   ⇒ **那不是一個驗收格，是我沒想清楚範圍的訊號** —— 而你把它指出來了。

# 二、★本票降級（status 已改）

```
**先前置量測，數字回來之前不 dispatch**：
  在現 main 加**按 task 型別分類**的 tap：`merge.blanket_evicted.<task>` ＋ `subteam.arrived.<task>`
⇒ ★★它把「影響面未知」變成一個數：**24 種裡，實際上有幾種真的會抵達並被歸建？**
⇒ ★**派工信（已寄出，exact path）**：`docs/superpowers/handbacks/2026-09-22-systems-to-implementer-DISPATCH-blanket-eviction-by-task-type.md`
⇒ ★★★**而那個數決定這是哪一張票**：
   少數幾種 ⇒ 影響面可控，照 §3 的 de-patch 做｜一大半都在發生 ⇒ **這不是 slice 是 arc**，退回 WHAT 重排
```

# 三、★你的③我照收，並且點名了

```
`faction_ai_system.gd:3943-3951`（CONSTRUCT／UPGRADE／EXPAND）：
  抵達後未轉 BUILD ⇒ 重試、逾時才 release/merge，
  而逾時是 `const CONSTRUCT_TRANSIT_TIMEOUT: int = 10 * TICKS_PER_DAY  # TEST VALUE`
⇒ ★同病同型，★★而且**多一顆死常數**（註解自己標著 TEST VALUE）
⇒ ★★★**我原本把它匿名丟進「六個 return」** —— 那是**把一個已知同型匿名化**。已點名進 §7.2。
```

# 四、★你的①（A1 門檻）我也改了

```
原本「降到 < 50%」—— **50% 是我隨手挑的**（我在送審信裡已承認）
⇒ 改成**錨在量測 baseline ＋ 多 seed 變異**，且**門檻在前置量測回來之後、實作之前**預註冊
⇒ ★★★**不是「看完數字再挑門檻」**，是「**先有 baseline 才知道門檻該用什麼單位**」。
```
★**請確認這個降級（先量測）是不是你要的方向**；若你認為連前置量測都該先普查那六個 return，我照做。
