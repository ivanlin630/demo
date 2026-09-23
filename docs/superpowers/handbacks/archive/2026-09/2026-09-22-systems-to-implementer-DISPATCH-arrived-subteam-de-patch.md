---
from: systems
to: implementer
status: consumed
slice: 子隊抵達 ＝ 決策點（`subteam-idle` de-patch）—— **派工**
topic: ★**R² CLEAN，可以動 code**：`docs/superpowers/specs/2026-09-22-arrived-subteam-is-a-decision-not-a-lifecycle-HOW.md`｜★★★**但先做第 0 步**：R² 指出 **SCOUT 的分母可能混進 `info_scout`**（它們在更前面就 return，根本到不了那條 blanket）⇒ **基線要先修正，否則門檻的解讀是錯的**｜★★形狀是 **de-patch**：把抵達交還引擎，**不是加 `if task == FORAGE` 的例外**
---

# 一、★★★第 0 步：**先修基線，再動行為**（R² 的非阻塞小問，我判它會動到門檻）

```
★問題：`subteam.arrived.SCOUT` 目前數的是**所有** SCOUT 抵達，
   而 `info_scout` 那一支**在更前面就 return** ⇒ **它們到不了 blanket**
⇒ ★★**分母被墊高** ⇒ 16.6%／10.6% 是**被稀釋過的** ⇒ **真值更高**
⇒ ★★★而門檻寫的是「**下降 ≥ 一半**」⇒ **基線錯，門檻就錯**
**做法**：把那顆 tap 拆標籤 —— `subteam.arrived.SCOUT.info_scout` 與 `subteam.arrived.SCOUT.other`
  ★同窗同種子重跑一輪（**只跑這一顆，不必全套**）⇒ **拿到修正後的基線我再把門檻定死**
⇒ ★**在修正基線回來之前，不要動行為 code。**
```

# 二、★形狀（`spec §3`，★而它是 de-patch）

```
★**不要**：`if sub.current_task == TeamData.TASK_FORAGE: 不歸建`
   —— 那是**在補丁上加補丁**；下一個任務型別會再撞一次
★★**要**：抵達 ⇒ **成為一個決策點**，由引擎在【歸建】與【留下繼續做】之間**用 util 秤**
   （與 `TASK_IDLE` 進引擎是**同一條路**，只是觸發條件多一個「已抵達」）
★★★**歸建仍然可以是最常見的結果** —— 差別在於它是**秤出來的**，不是**寫死的**
```
★**明確排除**舊 branch `feat/subteam-idle` 的做法：`FORAGE_SATED_DAYS(10)`／`PARENT_LOW_DAYS(3)`
兩顆死常數 ＋ 型別例外，★★而 `_parent_needs_food` **直接讀母團 food_days ＝ god-view** ⇒ 撞感知鐵律。

# 三、★不變量（spec §4，逐條套回本票）

```
①新決策點**必接 tap**：`subteam.arrival_decision.{merge,stay}`（全量暫態可觀測性）
②★**記帳可以閘，語意不可以**（不變量 #7）⇒ 決策本身**不得**依附 `Probe.enabled`
③**util 必＝真值** ⇒ 「留下」的 util 要是真實期望價值，★不得為了讓它 fire 而 crank
④**感知鐵律** ⇒ 「母團缺不缺糧」必須走 belief，★★**不得直接讀母團真值**
```

# 四、★驗收（spec §5／§8.3，★門檻待第 0 步回來才定死）

```
A1【主】**SCOUT（扣掉 info_scout 之後）的歸建率下降 ≥ 一半** ← ★基線待第 0 步
A2【硬閘】`subteam.arrival_decision.*` 母體 > 0 **且兩個分支都出現過**
   ★只有 merge 沒有 stay ⇒ 引擎沒在秤，只是換個地方寫死
A3【母體衛生】各型別 arrived 與前置量測**同量級**（★掉一個量級 ⇒ 控制流被改）
A4【陽性對照】把新決策點的 util 差距人為拉到極端 ⇒ **兩個方向都要能翻**
A5【觀察欄，不設門檻】FORAGE —— ★**分母 3／9，動一格就翻**，不可當判準
★★整體 evicted/arrived **不得上升**（副）
```
★★★**第 0 步的結果回來 ⇒ 我把 A1 的數字定死 ⇒ 你再動行為 code。**
