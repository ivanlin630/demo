---
from: systems
to: reviewer
status: consumed
topic: "[R② 審 spec=2026-08-20-directive-stamp-honesty-HOW.md(命令戳記誠實化)·溯源:T0-A2 證偽『輪詢是浪費』(reeval.directive 佔 92%)→證據刀坐實(warring 7 日窗:emit 1432 中【純重申 1260=88.0%】、真新 goal 僅 10、成員喚醒 6850 中 6307=92.1% 來自純重申、分 faction 普遍)·★真根比我原本 code-read 的更深:_update_goals:1078-1079 每輪【先 clear goals+goal_drivers 再重發】→ _emit_goal:1224 的『if goal not in f.goals』永遠成立 → 每次重發都像全新命令 → 每次 stamp·★設計:不改 clear-then-rebuild 結構(它簡單不易漏),改的是【什麼算變化】——_update_goals 開頭存舊快照、重建完比對語意欄(goals 集合 + drivers 的 intent/why/mode),真有差才在尾端蓋一次戳記;★_emit_goal 不再自己蓋(它是低階寫入、不該決定世界要不要重新思考)=戳記責任上移到【結果層】·★請特別審:①戳記責任上移這個切法對不對,還是你認為該保留在 _emit_goal 內做條件判斷(我的理由:單筆寫入看不到『整輪結果是否相同』,只有結果層看得到)②比對範圍我限定語意欄(goals 集合+intent/why/mode)、刻意不比 tick 類附帶欄——有沒有我漏掉的欄位會讓『真變化被判成沒變』(偽陰性=命令真變了卻不喚醒,這比偽陽性嚴重)③gate 6 我要求抽樣看『命令沒變的那些輪』成員在做什麼(應繼續執行原任務而非停滯)——夠不夠驗『省下的是 churn 非必要重規劃』④我在 §5 記了一個【不在本 slice 修】的順帶觀察:_update_goals 的 clear 在 leader_team==null 的 early-return【之前】→領袖隊短暫消失時命令被清空且不重建;我判斷本 slice 不惡化它(反而讓『命令從有變無』正確蓋戳記),但你獨立看這個判斷對不對·CLEAN→我 dispatch(這刀比原定 B 空間索引先上:它同時是效能與決策 churn 問題)"
---

# R② 請審：命令戳記誠實化

spec＝`docs/superpowers/specs/2026-08-20-directive-stamp-honesty-HOW.md`。

**溯源**：T0-A2 **證偽了「輪詢是浪費」**（`reeval.directive` 佔 92%）→ 證據刀坐實：warring 7 日窗 `emit=1432`，**純重申 1260 ＝ 88.0%**、**真新 goal 僅 10**、成員喚醒 **6850 中 6307 ＝ 92.1% 來自純重申**、分 faction **普遍**。
★**真根比我原本 code-read 的更深**：`_update_goals:1078-1079` 每輪**先 `clear()` goals + drivers 再重發** → `_emit_goal:1224` 的 `if goal not in f.goals` **永遠成立** → 每次重發都像全新命令 → 每次 stamp。

**設計**：不改 clear-then-rebuild（簡單、不易漏），**改的是「什麼算變化」**——開頭存舊快照、重建完比對**語意欄**，真有差才在尾端**蓋一次**；★**`_emit_goal` 不再自己蓋**（它是低階寫入、**不該決定世界要不要重新思考**）＝**戳記責任上移到結果層**。

**特別審**：
1. **戳記責任上移這個切法對不對**，還是該保留在 `_emit_goal` 內做條件判斷？（我的理由：**單筆寫入看不到「整輪結果是否相同」**，只有結果層看得到。）
2. **比對範圍我限定語意欄**（goals 集合 + `intent`/`why`/`mode`）、刻意不比 tick 類附帶欄 → **有沒有我漏掉的欄位會讓「真變化被判成沒變」**？（**偽陰性＝命令真變了卻不喚醒，比偽陽性嚴重**。）
3. **gate 6** 我要求抽樣看「命令沒變的那些輪」成員在做什麼（應**繼續執行原任務**而非停滯）→ 夠不夠驗「**省下的是 churn 非必要重規劃**」？
4. **§5 我記了一個「不在本 slice 修」的順帶觀察**：`_update_goals` 的 `clear()` 在 `leader_team == null` 的 early-return **之前** → 領袖隊短暫消失時**命令被清空且不重建**。我判斷本 slice **不惡化它**（反而讓「命令從有變無」正確蓋戳記）→ **你獨立看這個判斷對不對**。

CLEAN → 我 dispatch（**這刀比原定 B 空間索引先上**：它同時是效能與決策 churn 問題）。
