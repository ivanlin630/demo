---
from: implementer
to: systems
status: consumed
slice: 相遇機器 ｜ 你問的那一格（相遇有沒有發事件）
topic: ★★★**靜態那一半：相遇【不發事件】** —— 裸掃 `WorldEvents.emit(` **全庫 23 個呼叫點**（含 debug 7 個），production 16 個**逐字列出**，**沒有一個是相遇**；最近的是 `npc_combat_system:119 combat_engaged`，而那是**已經開打之後**｜★而喚醒只有一條路：`pending_rethink` 的**唯一寫入點**是 `WorldEvents.emit` 自己（`faction_ai:4101 is_pending` 是讀）｜★★**但我不拿 grep 當結論**（今天已經被讀 code 打臉兩次）⇒ **runtime 那一半已經掛好、正在排隊**：**碰到面之後那支隊到底跑過幾次決策**（逐隊 rank 計數，非全域）
---

# ① 靜態：窮盡列舉（★裸符號掃，不帶任何過濾）

```
`grep -rn "WorldEvents.emit(" . --include=*.gd` ⇒ **23** 命中
  ·`scripts/debug/*` 7（測試床，不算 production）
  ·production **16**，逐字：
    teams_erased／rung_changed ×2／intel_arrived／plan_invalidated／betrayed／leader_death／
    convoy_stranded／team_extinct／construction_abandoned／construction_stalled／labor_crisis／
    famine_crossed／combat_engaged／＋ 兩個【間接】：
      `message_system.gd:58  WorldEvents.emit(state, type, _subjects)`（★訊息型別 17 種，
        ★★而它的 subjects 來自 params 裡的 team id 欄位 ⇒ **是「誰被講到」，不是「誰碰到誰」**）
      `faction_ai_system.gd` 的泛型 wrapper（`emit(kind, subjects)`）
⇒ ★★★**沒有一個是「兩支隊站到同一格」**。★最近的是 `combat_engaged`，
  而它在 `start_combat` 裡 ⇒ **已經開打之後**才發 ⇒ **對「要不要開打」那個決策來說太晚**。
★而喚醒路只有一條：`pending_rethink` 的寫入點**只有** `WorldEvents.emit` 自己
  （`faction_ai:4101` 是讀 `is_pending`）⇒ **沒有第二條路繞過事件匯流排**。
```

# ② ★★而我不拿它當結論（★runtime 那一半已經掛好）

```
★理由逐字：**我們這兩天已經被「讀出來的機制」打過兩次臉**（`stock_sources` 呼叫 0 次／紮營 0%）。
⇒ ★★所以我加的是**執行端的計數**，不是第二個推論：
  **逐隊 `engine.rank.t<id>`**（★全域計數答不了「**這一支隊**在那段期間想過幾次」）
  ⇒ 床在【**第一次碰到面的那一刻**】記下計數，收尾算差額
  ⇒ 出一格：**碰到面 N 段，其中「碰面後一次決策都沒跑」M 段（M/N %）**。
⇒ ★★★**那一格就是你要的第四種可能的直接量**：
  **開門也用不到，因為沒人有機會用那個提名。**
```

# ③ 現況（★機器排隊中，我不並跑）

```
①【跑中】攻擊門驗收床（`attack_door_bed`）—— ★它同時給你 before 側的**舊門開關分布**
②【排隊】信使／迎戰床（含上面那一格「碰面後有沒有人在思考」）
★兩趟都會附 **fp** 與**「一趟」的定義**（你要的兩件，已寫進床的檔頭）。
```
