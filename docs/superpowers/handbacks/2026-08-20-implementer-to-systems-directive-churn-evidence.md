---
from: implementer
to: systems
status: consumed
topic: "[directive churn 證據刀 done（evidence-only、temp tap 已 revert、零 production 改動）·★你的假說【數字坐實】:warring 7 日窗 emit=1432 其中【純重申 1260=88.0%】、內容真變只有 172(12.0%)、真新 goal 只有 10;★成員喚醒 6850 次中 6307=【92.1% 來自純重申】·分 faction:f6 339/f1 318/f7 281/f3 209/f4 113=普遍現象非少數;分 goal:徵收 712/外交 548·★★量測坑記帳:第一版 tap 量出 restate=0% 差點回報『假說錯』——真因是 _update_goals:1079 每次評估先 f.goals.clear()+goal_drivers.clear() 再重發 → 跟【剛清空的 dict】比永遠是『新 goal』;改成跟【上一輪快照】比才是真數字·peaceful_economy 對照 emit=0(無 faction 命令活動)]"
branch: feat/t0-event-bus（temp tap 已 revert、未 commit 任何 production 改動）
---

# directive churn 證據刀（evidence-only）

## ★你的假說：**數字坐實**

**warring_states、7 日窗**（同 A2 量法：`ADHOC_TICKS=1680`、序列跑）：

| 指標 | 數值 |
|---|---|
| `_emit_goal` 總次數 | **1432** |
| ├ 內容**真的變了** | **172（12.0%）** |
| ├ 其中真·新 goal | **10** |
| └ **純重申**（goal 早在、intent/why/mode 三欄全同） | **1260（88.0%）** |
| 成員喚醒總數（stamp × 該 faction 成員數） | **6850** |
| └ **來自純重申的喚醒** | **6307 ＝ 92.1%** |
| `reeval.directive` / `reeval_total` | 2267 / 3124 |

**分 faction**（誰在狂重申）：`f6` 339、`f1` 318、`f7` 281、`f3` 209、`f4` 113 → **普遍現象，不是少數幾個 faction**。
**分 goal**：**徵收 712**、**外交 548** ＝ 這兩道命令是重申大戶。
**對照組 `peaceful_economy`**：`emit=0`（該 config 幾乎無 faction 命令活動）→ 這條病**只在有 faction 政治的世界**發作，與 A2 觀察到的 `reeval.directive` 分布一致。

→ 你的 code-read 成立：`_emit_goal` **無條件** stamp `directive_change_tick`，`_directive_fresh` 讀它 → **重申即喚醒全體成員**。與本 session 已見兩次同族（JOIN 同 target 純重申、`order.replaced` 舊單未清再掛）。

## ★★量測坑記帳（差點誤報「假說錯」）
第一版 tap 量出 **`restate = 0%`、`new_goal = 1274/1432`**——看起來像「每次都是新命令」＝你的假說錯。
**真因**：`_update_goals`（`faction_ai:1079`）**每次評估都先 `f.goals.clear()` + `f.goal_drivers.clear()` 再重發** → 我在 `_emit_goal` 裡跟「**剛被清空的 dict**」比，當然永遠是新的。
改成**跟上一輪快照比**（clear 前存 `goal_drivers` 副本）才得到真數字 88%。
＝這也順帶回答了一個你可能會問的問題：**這裡的「重申」不是 caller 手誤重複呼叫，而是「每輪清空重建」的結構**——所以修法的著力點是 stamp 條件（內容比對），不是呼叫點去重。

## 邊界（照你指示）
- **沒有做任何 fix**：沒加「內容沒變就不 stamp」（那是行為改動：成員重評時機變、要走 spec+R²）。
- **temp tap 已 revert**（`git checkout`、`grep dc.` = 0），branch 上**零 production 改動**；`DECISION_CADENCE_MULT` 仍是 A2 交付的 ×3。

地基 KEEP。**待命中。**
