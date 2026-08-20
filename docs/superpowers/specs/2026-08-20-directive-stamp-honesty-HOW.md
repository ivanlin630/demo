# HOW spec：命令戳記誠實化（`directive_change_tick` 只在命令真的變了才蓋）

date: 2026-08-20 ／ owner: systems ／ 溯源：T0-A2 證偽「輪詢是浪費」→ `reeval.directive` 佔 92% → 證據刀坐實
狀態：待 R² → dispatch。**效能 arc 插隊刀**（比原定 B 空間索引更划算：它同時是**效能**與**決策 churn** 問題）。

## §1 前提（file:line + 實測）
- `faction_ai:1226` `_emit_goal` **無條件**蓋 `f.directive_change_tick = current_tick`。
- ★**更深一層（implementer 證據刀挖出）**：`_update_goals:1079` **每次評估先 `f.goals.clear()` + `goal_drivers.clear()` 再重發** → `if goal not in f.goals`（`:1224`）**永遠成立**（剛清空）→ **每次重發都看起來像全新命令** → **每次都 stamp**。
- `_directive_fresh`（`:2952`）：`directive_change_tick > team.last_decision_tick` → **全體成員重評**。
- **實測（warring 7 日窗、evidence-only）**：`emit = 1432`，其中**純重申 1260 ＝ 88.0%**、內容真變 172（12.0%）、**真新 goal 僅 10**；**成員喚醒 6850 中 6307 ＝ 92.1% 來自純重申**；分 faction **普遍**（f6 339／f1 318／f7 281／f3 209／f4 113）；分 goal：徵收 712／外交 548。`peaceful_economy` 對照 `emit=0`（無 faction 命令活動）。
- ★**同族第三例**：JOIN churn（同 target 純重申）／`order.replaced`（舊單未清再掛）／本條 ＝ **「重申即喚醒」**。

## §2 設計：戳記只在**結果真的不同**時才蓋
- **不改** `_update_goals` 的 clear-then-rebuild 結構（它簡單、不易漏）——**改的是「什麼算變化」**。
- 形狀：`_update_goals` 開頭**存舊快照**（`goals` 陣列 + `goal_drivers` 的 `intent`/`why`/`mode` 三欄），重建完**比對**：
  - **集合或內容有差** → `directive_change_tick = current_tick`（一次、在 `_update_goals` 尾端）。
  - **完全相同** → **不蓋**（成員不被喚醒）。
- ★`_emit_goal` **不再自己蓋戳記**（它現在是「寫入一筆」的低階操作，不該決定「世界要不要重新思考」）→ **戳記責任上移到「一輪評估的結果層」**。
- **比對只看語意欄**（`intent`/`why`/`mode` + goal 集合）；**不比對** tick 之類的附帶欄位（否則永遠不同）。

## §3 為什麼這是**語意修**而不只是效能修
「faction 發布了新命令 → 成員該重新想」是**正確的**；問題是**「發布同一道命令」被當成「新命令」**。
修完之後：成員重評 ≠ 減少反應性，而是**不再對「沒發生的事」反應** → **決策 churn 下降**、且**真有新命令時照樣瞬醒**（T0 事件 + 本戳記雙路）。

## §4 gate
1. ★**重申不喚醒**：合成床——faction 連續兩輪產出**完全相同**的 goals/drivers → 第二輪**不蓋戳記**、成員**不被喚醒**。
2. ★**真變化仍喚醒**：任一語意欄改變（新增 goal／`intent` 變／`why` 變／`mode` 變） → **蓋戳記**、成員**當輪喚醒**。
3. **T0 不受影響**：事件瞬醒（被襲等）**照樣**（兩路獨立）。
4. **量化（三方對照、對齊既有量法：全新檔名 + 序列跑 + 同窗）**：`reeval.directive` 次數、決策次數/日、`wall/day` —— **與 main 98.0 / A1 133.1 / A2×3 110.8 併排報**；★**預期這一刀能把 wall 壓到 main 以下**，若沒有，照實報、不要調參湊。
5. det×3 + constitution ≤75 + headless 0-new + **fp intended-change**（成員重評時機真的變了）。
6. ★**故事面**：抽樣看「命令沒變的那些輪」成員在做什麼——**應該是繼續執行原任務**，而非停滯（確認省下的是 churn、不是必要的重新規劃）。
