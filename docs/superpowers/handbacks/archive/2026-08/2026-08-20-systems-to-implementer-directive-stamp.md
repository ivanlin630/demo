---
from: systems
to: implementer
status: consumed
topic: "[dispatch 命令戳記誠實化(效能 arc 插隊刀、比原定 B 空間索引先上:它同時是效能與決策 churn 問題)·spec=2026-08-20-directive-stamp-honesty-HOW.md(含 R² 必查項)·R²=CLEAN+1 必查項(已納入)·★根(你的證據刀挖出、比我 code-read 更深):_update_goals:1078-1079 每輪先 clear goals+goal_drivers 再重發 → _emit_goal:1224 的『if goal not in f.goals』永遠成立 → 每次重發都像全新命令 → 每次蓋 directive_change_tick → 全體成員被喚醒;實測純重申 88.0%、成員喚醒 92.1% 來自純重申·★T1 戳記責任上移:_emit_goal 【不再自己蓋戳記】(它是低階寫入、不該決定世界要不要重新思考);改由 _update_goals 在【一輪評估的結果層】比對後蓋一次·★★T2 必查項(R² 抓):比對必須覆蓋【所有離開路徑】、不能只掛函式尾端——_update_goals 有兩個 early-return:①leader_team==null(在 clear 之後)②玩家 override(if not f.player_goal_override.is_empty(): append; return 【完全不經 _emit_goal】)·實作形狀=拆【薄外殼+內層重建】:外殼存快照→呼內層(內層可任意 early-return)→比對→蓋戳記;內層專心重建·★這條的重要性:玩家 override 那條路【今天完全不蓋戳記=玩家下令成員不被喚醒】,是被『_emit_goal 無條件蓋』掩蓋著的;若你只改成『真變化才蓋』而比較沒覆蓋它,會把這個既有缺口【引爆】(玩家下令徹底沒人理);做對了則是【順手修好】它·★T3 比對範圍=語意欄(goals 集合 + goal_drivers 的 intent/why/mode),不比 tick 類附帶欄;★偽陰性比偽陽性嚴重(命令真變卻不喚醒),不確定時寧可判『變了』·gate①★重申不喚醒(連續兩輪產出完全相同→第二輪不蓋、成員不被喚醒)②★真變化仍喚醒(任一語意欄變→蓋、成員當輪喚醒)③★玩家 override 改變時會蓋戳記(新 gate、對應必查項)④T0 事件瞬醒不受影響(兩路獨立)⑤量化三方併排(main 98.0/A1 133.1/A2×3 110.8/本刀 ?)+reeval.directive 次數+決策次數/日——★預期能把 wall 壓到 main 以下;若沒有,照實報別調參湊⑥det×3+constitution<=75+headless 0-new+fp intended-change⑦★故事面抽樣:命令沒變的那些輪,成員應【繼續執行原任務】而非停滯(確認省下的是 churn 非必要重規劃)·worktree feat/directive-stamp-honesty·完→handback to:systems·地基KEEP"
---

# dispatch：命令戳記誠實化（效能 arc 插隊刀）

spec＝`docs/superpowers/specs/2026-08-20-directive-stamp-honesty-HOW.md`（含 R² 必查項）。**R²＝CLEAN + 1 必查項（已納入）**。
**比原定 B 空間索引先上**：它同時是**效能**（92% 的決策量）與**決策 churn**（成員對「沒發生的事」反應）問題。

**根**（你的證據刀挖出、比我 code-read 更深）：`_update_goals:1078-1079` 每輪先 `clear()` 再重發 → `_emit_goal:1224` 的 `if goal not in f.goals` **永遠成立** → 每次重發都像全新命令 → **每次蓋戳記 → 全體成員被喚醒**。實測**純重申 88.0%**、**成員喚醒 92.1% 來自純重申**。

- **T1 戳記責任上移**：`_emit_goal` **不再自己蓋戳記**（低階寫入不該決定「世界要不要重新思考」）→ 改由 `_update_goals` 在**結果層**比對後**蓋一次**。
- **★★T2 必查項（R² 抓）**：**比對必須覆蓋所有離開路徑**，不能只掛尾端。`_update_goals` 有**兩個 early-return**：①`leader_team == null`（在 `clear()` 之後）②**玩家 override**（`append` 後 `return`、**完全不經 `_emit_goal`**）。
  **實作形狀**：拆**薄外殼 + 內層重建**——外殼：**存快照 → 呼內層（可任意 early-return）→ 比對 → 蓋戳記**。
  ★**這條的重要性**：玩家 override 那條路**今天完全不蓋戳記 ＝ 玩家下令、成員不被喚醒**，是被「`_emit_goal` 無條件蓋」掩蓋著的。若只改成「真變化才蓋」而比較沒覆蓋它，會把這個既有缺口**引爆**（玩家下令徹底沒人理）；做對了則是**順手修好**它。
- **T3 比對範圍**＝語意欄（goals 集合 + drivers 的 `intent`/`why`/`mode`），不比 tick 類附帶欄。★**偽陰性比偽陽性嚴重**（命令真變卻不喚醒）→ **不確定時寧可判「變了」**。

**gate**：①★重申不喚醒 ②★真變化仍喚醒 ③★**玩家 override 改變時會蓋戳記**（新 gate、對應必查項） ④T0 事件瞬醒不受影響 ⑤**量化三方併排**（main 98.0／A1 133.1／A2×3 110.8／本刀 ?）+ `reeval.directive` 次數 + 決策次數/日——★**預期能把 wall 壓到 main 以下；若沒有，照實報、別調參湊** ⑥det×3 + constitution ≤75 + headless 0-new + fp intended-change ⑦★**故事面抽樣**：命令沒變的那些輪，成員應**繼續執行原任務**而非停滯。

worktree `feat/directive-stamp-honesty`。完 → handback to:systems。地基 KEEP。
